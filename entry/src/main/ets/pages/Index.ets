import { router } from '@kit.ArkUI'
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ThemeType, ThemeColors, LightTheme } from '../models/Theme'
import { ThemeManager } from '../utils/ThemeManager'
import { FileService } from '../services/FileService'
import { StorageService } from '../utils/StorageService'
import { Document } from '../models/Document'
import { SharedFileStorage } from '../entryability/EntryAbility'
import { fileIo } from '@kit.CoreFileKit'
import { promptAction } from '@kit.ArkUI'

// 分享文件信息接口
interface SharedFileInfo {
  uri: string
  name: string
  type: string
  sandboxPath: string  // 沙盒路径
}

@Entry
@Component
struct Index {
  @StorageLink('current_theme_type') currentTheme: ThemeType = ThemeType.LIGHT
  @StorageLink('current_theme_colors') themeColors: ThemeColors = LightTheme
  
  @State documents: Document[] = []
  @State isLoading: boolean = false
  @State errorMessage: string = ''
  @State recentDocs: Document[] = []

  private context: Context = getContext(this) as Context

  private static readonly DOMAIN = 0x0001;

  aboutToAppear() {
    hilog.info(Index.DOMAIN, 'testTag', '%{public}s', '[Index] aboutToAppear called')
    ThemeManager.init()
    StorageService.init(this.context)
    hilog.info(Index.DOMAIN, 'testTag', '%{public}s', '[Index] StorageService.init done')
    const savedSize: number = StorageService.getFontSize()
    AppStorage.setOrCreate('reader_font_size_val', savedSize)
    hilog.info(Index.DOMAIN, 'testTag', '[Index] font size: %{public}d', savedSize)
    this.loadRecentDocuments()
    hilog.info(Index.DOMAIN, 'testTag', '%{public}s', '[Index] calling scanDocuments')
    this.scanDocuments()
    hilog.info(Index.DOMAIN, 'testTag', '%{public}s', '[Index] scanDocuments called')
    this.handleSharedFile()
    
    // 自动打开测试文档用于调试
    setTimeout(() => {
      this.openRawFile('complete_test.md')
    }, 1000)
  }
  
  // 处理从其他应用分享的文件
  private handleSharedFile(): void {
    const sharedFileInfo = SharedFileStorage.getFileInfo()
    if (sharedFileInfo && sharedFileInfo.sandboxPath) {
      console.log(`[Index] Opening shared file: ${sharedFileInfo.name}, sandbox: ${sharedFileInfo.sandboxPath}`)
      
      // 延迟打开，确保页面已完全加载
      setTimeout(() => {
        // 如果是 .md 或 .txt 文件，直接打开阅读页面
        const ext = sharedFileInfo.name.toLowerCase()
        if (ext.endsWith('.md') || ext.endsWith('.markdown') || ext.endsWith('.txt')) {
          router.pushUrl({
            url: 'pages/ReaderPage',
            params: {
              name: sharedFileInfo.name,
              sandboxPath: sharedFileInfo.sandboxPath  // 传递沙盒路径
            }
          })
        }
      }, 500)
    }
  }

  // 加载最近阅读
  loadRecentDocuments() {
    this.recentDocs = StorageService.getRecentDocuments().slice(0, 5)
  }

  // 扫描文档
  async scanDocuments() {
    hilog.info(Index.DOMAIN, 'testTag', '%{public}s', '[Index] scanDocuments start')
    this.isLoading = true
    this.errorMessage = ''
    try {
      hilog.info(Index.DOMAIN, 'testTag', '[Index] calling FileService.scanDirectory')
      this.documents = await FileService.scanDirectory(this.context)
      hilog.info(Index.DOMAIN, 'testTag', '[Index] scanDirectory returned, doc count: %{public}d', this.documents.length)
    } catch (e) {
      this.errorMessage = '扫描文件失败: ' + (e as Error).message
      hilog.error(Index.DOMAIN, 'testTag', '[Index] scanDocuments error: %{public}s', (e as Error).message)
    } finally {
      this.isLoading = false
      hilog.info(Index.DOMAIN, 'testTag', '%{public}s', '[Index] scanDocuments done, isLoading: false')
    }
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('MD 阅读器')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeColors.textPrimary)
        
        Blank()
        
        // 主题切换按钮
        Button(this.getThemeIcon())
          .fontSize(20)
          .backgroundColor(Color.Transparent)
          .fontColor(this.themeColors.textPrimary)
          .onClick(() => {
            this.toggleTheme()
          })
        
        // 设置按钮
        Button('⚙')
          .fontSize(20)
          .backgroundColor(Color.Transparent)
          .fontColor(this.themeColors.textPrimary)
          .onClick(() => {
            router.pushUrl({ url: 'pages/SettingsPage' })
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(this.themeColors.background)
      
      // 搜索栏
      Row() {
        Text('🔍')
          .fontSize(16)
          .margin({ right: 8 })
        Text('搜索 Markdown 文件')
          .fontSize(14)
          .fontColor(this.themeColors.textTertiary)
        Blank()
      }
      .width('100%')
      .height(44)
      .padding({ left: 16, right: 16 })
      .margin(16)
      .backgroundColor(this.themeColors.surface)
      .borderRadius(22)
      .onClick(() => {
        router.pushUrl({ url: 'pages/SearchPage' })
      })
      
      // 内容区域 - 使用 Scroll + Refresh 实现下拉刷新
      Refresh({ refreshing: $$this.isLoading }) {
        List({ space: 0 }) {
          // 最近阅读区域
          if (this.recentDocs.length > 0) {
            ListItem() {
              Column() {
                Text('最近阅读')
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeColors.textPrimary)
                  .alignSelf(ItemAlign.Start)
                  .margin({ bottom: 12, left: 16, right: 16 })
                
                ForEach(this.recentDocs, (doc: Document) => {
                  this.FileItem(doc, true)
                }, (doc: Document) => doc.id)
              }
              .width('100%')
              .margin({ bottom: 16 })
            }
          }
          
          // 本地文件列表
          ListItem() {
            Column() {
              Row() {
                Text('本地文件')
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeColors.textPrimary)
                
                Blank()
                
                Text(`${this.documents.length} 个文件`)
                  .fontSize(12)
                  .fontColor(this.themeColors.textTertiary)
              }
              .width('100%')
              .padding({ left: 16, right: 16 })
              .margin({ bottom: 12 })
              
              if (this.documents.length === 0 && !this.isLoading) {
                // 空状态
                Column() {
                  Text('📁')
                    .fontSize(48)
                    .margin({ bottom: 12 })
                  Text('未找到 Markdown 文件')
                    .fontSize(16)
                    .fontColor(this.themeColors.textSecondary)
                  Text('将 .md 文件放入 Documents 目录或使用其他应用分享')
                    .fontSize(12)
                    .fontColor(this.themeColors.textTertiary)
                    .margin({ top: 8 })
                }
                .width('100%')
                .padding(40)
              } else {
                ForEach(this.documents, (doc: Document) => {
                  ListItem() {
                    this.FileItem(doc, false)
                  }
                  .swipeAction({
                    start: {
                      builder: () => {
                        // 可以添加左侧操作
                      }
                    },
                    end: {
                      builder: () => {
                        this.DeleteAction(doc)
                      }
                    }
                  })
                }, (doc: Document) => doc.id)
              }
            }
            .width('100%')
          }
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(this.themeColors.background)
      }
      .layoutWeight(1)
      .onRefreshing(() => {
        this.scanDocuments()
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeColors.background)
  }
  
  // 文件项组件
  @Builder
  FileItem(doc: Document, isRecent: boolean) {
    Row() {
      Column() {
        Text('📄')
          .fontSize(24)
      }
      .width(48)
      .height(48)
      .backgroundColor(this.themeColors.surface)
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)
      
      Column() {
        Text(doc.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeColors.textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        
        Row() {
          Text(FileService.formatFileSize(doc.size))
            .fontSize(12)
            .fontColor(this.themeColors.textSecondary)
          
          Text(' · ')
            .fontSize(12)
            .fontColor(this.themeColors.textTertiary)
          
          Text(isRecent 
            ? FileService.formatTime(doc.lastOpenTime)
            : FileService.formatTime(doc.modifyTime))
            .fontSize(12)
            .fontColor(this.themeColors.textSecondary)
        }
        .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)
      
      if (doc.isFavorite) {
        Text('⭐')
          .fontSize(16)
          .margin({ right: 8 })
      }
      
      Text('›')
        .fontSize(24)
        .fontColor(this.themeColors.textTertiary)
    }
    .width('100%')
    .height(72)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.themeColors.background)
    .onClick(() => {
      // 更新最近阅读并跳转
      StorageService.addRecentDocument(doc)
      router.pushUrl({
        url: 'pages/ReaderPage',
        params: { path: doc.path, name: doc.name }
      })
    })
  }
  
  // 删除操作按钮
  @Builder
  DeleteAction(doc: Document) {
    Row() {
      Button() {
        Text('删除')
          .fontSize(14)
          .fontColor('#FFFFFF')
      }
      .type(ButtonType.Capsule)
      .backgroundColor('#FF4444')
      .width(64)
      .height(40)
      .margin({ right: 16 })
      .onClick(() => {
        this.confirmDelete(doc)
      })
    }
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
  
  // 确认删除
  private confirmDelete(doc: Document): void {
    promptAction.showDialog({
      title: '删除文件',
      message: `确定要删除 "${doc.name}" 吗？`,
      buttons: [
        { text: '取消', color: '#666666' },
        { text: '删除', color: '#FF4444' }
      ]
    }).then((result) => {
      if (result.index === 1) {
        this.deleteDocument(doc)
      }
    })
  }
  
  // 删除文件
  private deleteDocument(doc: Document): void {
    // 只能删除沙盒文件
    if (!doc.path.includes('/files/shared/')) {
      promptAction.showToast({ message: '只能删除沙盒中的文件' })
      return
    }
    
    FileService.deleteFile(doc.path).then((success) => {
      if (success) {
        // 从列表中移除
        this.documents = this.documents.filter(d => d.id !== doc.id)
        // 从最近阅读中移除
        StorageService.removeRecentDocument(doc.id)
        this.recentDocs = StorageService.getRecentDocuments()
        promptAction.showToast({ message: '已删除' })
      } else {
        promptAction.showToast({ message: '删除失败' })
      }
    })
  }
  
  // 打开 rawfile 中的示例文件
  private openRawFile(fileName: string): void {
    console.log(`[Index] Opening raw file: ${fileName}`)
    router.pushUrl({
      url: 'pages/ReaderPage',
      params: { 
        name: fileName,
        isRawFile: true  // 标记为 rawfile 文件
      }
    })
  }
  
  // 获取主题图标
  getThemeIcon(): string {
    switch (this.currentTheme) {
      case ThemeType.DARK:
        return '🌙'
      case ThemeType.AUTO:
        return '🔄'
      default:
        return '☀️'
    }
  }
  
  // 切换主题
  toggleTheme() {
    let nextTheme: ThemeType
    switch (this.currentTheme) {
      case ThemeType.LIGHT:
        nextTheme = ThemeType.DARK
        break
      case ThemeType.DARK:
        nextTheme = ThemeType.AUTO
        break
      default:
        nextTheme = ThemeType.LIGHT
    }
    ThemeManager.setTheme(nextTheme)
  }
}