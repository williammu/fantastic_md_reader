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
// 使用图片图标资源

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
      // 顶部标题栏 - 华为风格
      Row() {
        // Logo 和标题
        Row({ space: 8 }) {
          // 书本图标
          Image($r('app.media.startIcon'))
            .width(32)
            .height(32)
            .objectFit(ImageFit.Contain)
          
          Text('𝓕𝓪𝓷𝓽𝓪𝓼𝓽𝓲𝓬 𝓜𝓓')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeColors.textPrimary)
        }
        
        Blank()
        
        // 主题切换按钮
        this.ThemeIconButton()

        // 设置按钮
        Button() {
          Image($r('app.media.ic_settings_48'))
            .width(22)
            .height(22)
            .fillColor(this.currentTheme === ThemeType.DARK ? '#FFFFFF' : '#2C2C2C')
        }
        .width(40)
        .height(40)
        .backgroundColor(this.currentTheme === ThemeType.DARK ? '#3A3A3C' : '#F2F2F7')
        .borderRadius(20)
        .onClick(() => {
          router.pushUrl({ url: 'pages/SettingsPage' })
        })
      }
      .width('100%')
      .height(60)
      .padding({ left: 20, right: 12 })
      .backgroundColor(this.themeColors.background)
      
      // 搜索栏 - 卡片式设计
      Row({ space: 12 }) {
        Image($r('app.media.ic_search_48'))
          .width(18)
          .height(18)
          .fillColor(this.themeColors.textTertiary)
        
        Text('搜索 Markdown 文件')
          .fontSize(15)
          .fontColor(this.themeColors.textTertiary)
        
        Blank()
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 })
      .margin({ left: 16, right: 16, top: 12, bottom: 8 })
      .backgroundColor(this.themeColors.surface)
      .borderRadius(12)
      .shadow({
        radius: 2,
        color: 'rgba(0,0,0,0.04)',
        offsetY: 1
      })
      .onClick(() => {
        router.pushUrl({ url: 'pages/SearchPage' })
      })
      
      // 内容区域 - 使用 Refresh 实现下拉刷新
      Refresh({ refreshing: $$this.isLoading }) {
        List({ space: 0 }) {
          // 最近阅读区域
          if (this.recentDocs.length > 0) {
            ListItem() {
              Column() {
                Row() {
                  Text('最近阅读')
                    .fontSize(17)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeColors.textPrimary)
                  
                  Blank()
                  
                  Text('查看全部')
                    .fontSize(13)
                    .fontColor(this.themeColors.primary)
                }
                .width('100%')
                .padding({ left: 20, right: 20, bottom: 12 })
                
                // 横向滚动的最近阅读卡片
                List({ space: 12 }) {
                  ForEach(this.recentDocs, (doc: Document) => {
                    ListItem() {
                      this.RecentCard(doc)
                    }
                  }, (doc: Document) => doc.id)
                }
                .listDirection(Axis.Horizontal)
                .padding({ left: 20, right: 20 })
              }
              .width('100%')
              .margin({ top: 8, bottom: 16 })
            }
          }
          
          // 本地文件列表
          ListItem() {
            Column() {
              Row() {
                Text('本地文件')
                  .fontSize(17)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeColors.textPrimary)
                
                Blank()
                
                Text(`${this.documents.length} 个文件`)
                  .fontSize(13)
                  .fontColor(this.themeColors.textTertiary)
              }
              .width('100%')
              .padding({ left: 20, right: 20, bottom: 12 })
              
              if (this.documents.length === 0 && !this.isLoading) {
                // 空状态
                Column() {
                  Image($r('app.media.ic_folder_96'))
                    .width(64)
                    .height(64)
                    .fillColor(this.themeColors.textTertiary)

                  Blank().height(16)
                  
                  Text('未找到 Markdown 文件')
                    .fontSize(16)
                    .fontColor(this.themeColors.textSecondary)
                    .margin({ bottom: 8 })
                  
                  Text('将 .md 文件放入 Documents 目录')
                    .fontSize(13)
                    .fontColor(this.themeColors.textTertiary)
                }
                .width('100%')
                .padding(48)
              } else {
                ForEach(this.documents, (doc: Document) => {
                  ListItem() {
                    this.FileItem(doc)
                  }
                  .swipeAction({
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
  
  // 最近阅读卡片
  @Builder
  RecentCard(doc: Document) {
    Column({ space: 8 }) {
      // 文件图标
      Stack() {
        Rect()
          .width(56)
          .height(72)
          .radius(6)
          .fill(this.themeColors.surface)
          .shadow({
            radius: 4,
            color: 'rgba(0,0,0,0.08)',
            offsetY: 2
          })
        
        Column({ space: 4 }) {
          Rect()
            .width(28)
            .height(4)
            .radius(2)
            .fill(this.themeColors.textTertiary)
          Rect()
            .width(28)
            .height(4)
            .radius(2)
            .fill(this.themeColors.textTertiary)
          Rect()
            .width(20)
            .height(4)
            .radius(2)
            .fill(this.themeColors.textTertiary)
        }
      }
      .width(56)
      .height(72)
      
      // 文件名
      Text(doc.name.replace(/\.md$/i, ''))
        .fontSize(13)
        .fontColor(this.themeColors.textPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width(80)
        .textAlign(TextAlign.Center)
      
      // 时间
      Text(FileService.formatTime(doc.lastOpenTime))
        .fontSize(11)
        .fontColor(this.themeColors.textTertiary)
    }
    .width(80)
    .onClick(() => {
      StorageService.addRecentDocument(doc)
      router.pushUrl({
        url: 'pages/ReaderPage',
        params: { path: doc.path, name: doc.name }
      })
    })
  }
  
  // 文件项组件 - 列表样式
  @Builder
  FileItem(doc: Document) {
    Row({ space: 16 }) {
      // 文件图标
      Stack() {
        Rect()
          .width(48)
          .height(48)
          .radius(10)
          .fill(this.themeColors.surface)
        
        // MD 标识
        Text('MD')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeColors.primary)
      }
      .width(48)
      .height(48)
      
      Column({ space: 4 }) {
        Text(doc.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeColors.textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        
        Row({ space: 8 }) {
          Text(FileService.formatFileSize(doc.size))
            .fontSize(12)
            .fontColor(this.themeColors.textSecondary)
          
          Circle()
            .width(3)
            .height(3)
            .fill(this.themeColors.textTertiary)
          
          Text(FileService.formatTime(doc.modifyTime))
            .fontSize(12)
            .fontColor(this.themeColors.textSecondary)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      // 收藏标记
      if (doc.isFavorite) {
        Image($r('app.media.ic_star_48'))
          .width(18)
          .height(18)
          .fillColor('#FFB800')
      }

      // 前进箭头
      Image($r('app.media.ic_forward_48'))
        .width(20)
        .height(20)
        .fillColor(this.themeColors.textTertiary)
    }
    .width('100%')
    .height(76)
    .padding({ left: 20, right: 20 })
    .backgroundColor(this.themeColors.background)
    .onClick(() => {
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
      .height(40)
      .padding({ left: 16, right: 16 })
      .margin({ right: 20 })
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
        this.documents = this.documents.filter(d => d.id !== doc.id)
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
        isRawFile: true
      }
    })
  }
  
  // 主题图标按钮
  @Builder
  ThemeIconButton() {
    Button() {
      if (this.currentTheme === ThemeType.DARK) {
        Image($r('app.media.ic_sun_48'))
          .width(22)
          .height(22)
          .fillColor('#FFFFFF')
      } else {
        Image($r('app.media.ic_moon_48'))
          .width(22)
          .height(22)
          .fillColor('#FFFFFF')
      }
    }
    .width(40)
    .height(40)
    .backgroundColor(this.currentTheme === ThemeType.DARK ? '#5856D6' : '#007AFF')
    .borderRadius(20)
    .onClick(() => {
      this.toggleTheme()
    })
  }

  // 切换主题 - 简化为只有亮色和暗色
  toggleTheme() {
    let nextTheme: ThemeType
    if (this.currentTheme === ThemeType.LIGHT) {
      nextTheme = ThemeType.DARK
    } else {
      nextTheme = ThemeType.LIGHT
    }
    ThemeManager.setTheme(nextTheme)
  }
}
