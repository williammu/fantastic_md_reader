import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { fileIo } from '@kit.CoreFileKit';
import { LogSocketService } from '../services/LogSocketService';

const DOMAIN = 0x0000;

// 分享文件信息接口
interface SharedFileInfo {
  uri: string;
  name: string;
  type: string;
  sandboxPath: string;  // 沙盒路径
}

// 全局存储，用于在 Ability 和 Page 之间传递数据
export class SharedFileStorage {
  private static sharedFileInfo: SharedFileInfo | null = null;
  private static shouldOpenDirectly: boolean = false;
  private static filesDir: string = '';
  
  static setFileInfo(info: SharedFileInfo): void {
    SharedFileStorage.sharedFileInfo = info;
    SharedFileStorage.shouldOpenDirectly = true;
  }
  
  static getFileInfo(): SharedFileInfo | null {
    return SharedFileStorage.sharedFileInfo;
  }
  
  static clearFileInfo(): void {
    SharedFileStorage.sharedFileInfo = null;
  }
  
  static shouldOpenReader(): boolean {
    const shouldOpen = SharedFileStorage.shouldOpenDirectly;
    SharedFileStorage.shouldOpenDirectly = false;
    return shouldOpen;
  }
  
  static clear(): void {
    SharedFileStorage.sharedFileInfo = null;
    SharedFileStorage.shouldOpenDirectly = false;
  }
  
  static setFilesDir(dir: string): void {
    SharedFileStorage.filesDir = dir;
  }
  
  static getFilesDir(): string {
    return SharedFileStorage.filesDir;
  }
}

export default class EntryAbility extends UIAbility {
  private pendingFileInfo: SharedFileInfo | null = null;
  private windowStage: window.WindowStage | null = null;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    
    // 启动日志 Socket 服务器
    LogSocketService.startServer();
    
    // 处理从其他应用分享打开的文件
    this.handleShareIntent(want);
  }
  
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'testTag', 'onNewWant called');
    // 处理从其他应用分享打开的文件（应用在后台时）
    this.handleShareIntent(want);
    
    // 如果窗口已创建，直接打开阅读器
    if (this.windowStage && this.pendingFileInfo) {
      this.openReaderPage();
    }
  }
  
  // 处理分享意图
  private async handleShareIntent(want: Want): Promise<void> {
    try {
      const action = want.action;
      const uri = want.uri;
      
      hilog.info(DOMAIN, 'testTag', 'handleShareIntent action=%{public}s, uri=%{public}s', 
        JSON.stringify(action), JSON.stringify(uri));
      
      // 处理 ACTION_VIEW_DATA (打开文件)
      if (action === 'ohos.want.action.viewData' && uri) {
        const fileName = this.extractFileName(uri);
        hilog.info(DOMAIN, 'testTag', 'Processing file: %{public}s', fileName);
        
        // 将文件拷贝到沙盒
        const sandboxPath = await this.copyFileToSandbox(uri, fileName);
        if (sandboxPath) {
          this.pendingFileInfo = {
            uri: uri,
            name: fileName,
            type: want.type || 'text/plain',
            sandboxPath: sandboxPath
          };
          
          // 保存到全局存储
          SharedFileStorage.setFileInfo(this.pendingFileInfo);
          hilog.info(DOMAIN, 'testTag', 'File copied to sandbox: %{public}s', JSON.stringify(this.pendingFileInfo));
          
          // 如果窗口已创建，直接打开阅读器
          if (this.windowStage) {
            this.openReaderPage();
          }
        } else {
          hilog.error(DOMAIN, 'testTag', 'Failed to copy file to sandbox');
        }
        return;
      }
      
      // 处理 ACTION_SEND / ACTION_SEND_MULTIPLE (分享文件)
      if (action === 'ohos.want.action.send' || action === 'ohos.want.action.sendMultiple') {
        // 从 parameters 中获取文件 URI
        const parameters: Record<string, string | string[]> | undefined = want.parameters as Record<string, string | string[]> | undefined;
        if (parameters) {
          // 尝试获取单个文件
          const stream: string | string[] | undefined = parameters['ohos.extra.param.key.stream'];
          if (stream) {
            let fileUri: string;
            if (Array.isArray(stream)) {
              fileUri = stream[0];
            } else {
              fileUri = stream;
            }
            const fileName = this.extractFileName(fileUri);
            
            // 将文件拷贝到沙盒
            const sandboxPath = await this.copyFileToSandbox(fileUri, fileName);
            if (sandboxPath) {
              this.pendingFileInfo = {
                uri: fileUri,
                name: fileName,
                type: want.type || 'text/plain',
                sandboxPath: sandboxPath
              };
              SharedFileStorage.setFileInfo(this.pendingFileInfo);
              hilog.info(DOMAIN, 'testTag', 'File copied to sandbox from send: %{public}s', JSON.stringify(this.pendingFileInfo));
              
              // 如果窗口已创建，直接打开阅读器
              if (this.windowStage) {
                this.openReaderPage();
              }
            }
          }
        }
      }
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to handle share intent. Cause: %{public}s', JSON.stringify(err));
    }
  }
  
  // 打开阅读页面
  private openReaderPage(): void {
    if (!this.windowStage || !this.pendingFileInfo) {
      return;
    }
    
    const fileInfo = this.pendingFileInfo;
    this.pendingFileInfo = null;
    
    // 直接加载 ReaderPage
    this.windowStage.loadContent('pages/ReaderPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load ReaderPage. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading ReaderPage.');
    });
  }
  
  // 将文件从 URI 拷贝到应用沙盒
  private async copyFileToSandbox(uri: string, fileName: string): Promise<string | null> {
    try {
      // 创建沙盒目录
      const sandboxDir = this.context.filesDir + '/shared';
      try {
        fileIo.mkdirSync(sandboxDir);
      } catch (e) {
        // 目录可能已存在
      }
      
      // 生成唯一的文件名（避免冲突）
      const timestamp = Date.now();
      const uniqueFileName = `${timestamp}_${fileName}`;
      const sandboxPath = sandboxDir + '/' + uniqueFileName;
      
      hilog.info(DOMAIN, 'testTag', 'Copying file from %{public}s to %{public}s', uri, sandboxPath);
      
      // 打开源文件
      const srcFile = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
      
      // 获取文件大小
      const stat = fileIo.statSync(srcFile.fd);
      const fileSize = stat.size;
      
      // 创建目标文件
      const destFile = fileIo.openSync(sandboxPath, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC);
      
      // 读取源文件内容
      const buffer = new ArrayBuffer(fileSize);
      fileIo.readSync(srcFile.fd, buffer);
      
      // 写入目标文件
      fileIo.writeSync(destFile.fd, buffer);
      
      // 关闭文件
      fileIo.closeSync(srcFile);
      fileIo.closeSync(destFile);
      
      hilog.info(DOMAIN, 'testTag', 'File copied successfully to %{public}s, size: %{public}d bytes', sandboxPath, fileSize);
      
      return sandboxPath;
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to copy file to sandbox. Cause: %{public}s', JSON.stringify(err));
      return null;
    }
  }
  
  // 从 URI 提取文件名
  private extractFileName(uri: string): string {
    try {
      // 处理 content:// 和 file:// URI
      const match = uri.match(/[^/\\]+$/);
      if (match) {
        return decodeURIComponent(match[0]);
      }
      return '未命名.md';
    } catch {
      return '未命名.md';
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
    // 停止日志 Socket 服务器
    LogSocketService.stopServer();
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    
    this.windowStage = windowStage;
    
    // 打印文件目录信息
    hilog.info(DOMAIN, 'testTag', '[EntryAbility] Files dir: %{public}s', this.context.filesDir);
    hilog.info(DOMAIN, 'testTag', '[EntryAbility] Cache dir: %{public}s', this.context.cacheDir);
    hilog.info(DOMAIN, 'testTag', '[EntryAbility] Temp dir: %{public}s', this.context.tempDir);
    
    // 保存沙盒目录路径供其他模块使用
    SharedFileStorage.setFilesDir(this.context.filesDir);
    
    // 如果有待打开的文件，直接打开阅读器
    if (this.pendingFileInfo) {
      this.openReaderPage();
    } else {
      // 否则加载首页
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
          return;
        }
        hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      });
    }
  }

  onWindowStageDestroy(): void {
    // Window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
    this.windowStage = null;
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
