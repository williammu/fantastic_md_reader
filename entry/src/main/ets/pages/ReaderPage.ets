import { router } from '@kit.ArkUI'
import { ThemeColors, LightTheme } from '../models/Theme'
import { MDRender } from '../components/MDRender/MDRender'
import { FileService } from '../services/FileService'
import { fileIo } from '@kit.CoreFileKit'
import { buffer } from '@kit.ArkTS'
import { SharedFileStorage } from '../entryability/EntryAbility'
import { MarkdownParser, TocItem } from 'markdown-renderer'
import { StorageService } from '../utils/StorageService'
import { hilog } from '@kit.PerformanceAnalysisKit'
import webview from '@ohos.web.webview'
// 使用图片图标资源

const DOMAIN = 0x0004

// UTF-8 解码函数（使用 buffer 模块）
function decodeUtf8(uint8Array: Uint8Array): string {
  // 方法1: 直接使用 Uint8Array
  try {
    return buffer.from(uint8Array).toString('utf8')
  } catch (e) {
    hilog.error(DOMAIN, 'testTag', '[ReaderPage] buffer.from(uint8Array) failed: %{public}s', JSON.stringify(e))
    // 方法2: 使用 ArrayBuffer
    return buffer.from(uint8Array.buffer).toString('utf8')
  }
}

// 手动 UTF-8 解码（备用方案）
function decodeUtf8Manual(uint8Array: Uint8Array): string {
  let result = ''
  let i = 0
  while (i < uint8Array.length) {
    const byte1 = uint8Array[i]
    // 处理无符号字节
    const b1 = byte1 & 0xFF
    
    // 调试：打印前20个字节的处理信息
    if (i < 20) {
      hilog.info(DOMAIN, 'testTag', '[ReaderPage] Byte at i=%{public}d: raw=%{public}d, b1=0x%{public}s, b1&0xF0=0x%{public}s', 
        i, byte1, b1.toString(16), (b1 & 0xF0).toString(16))
    }
    
    if (b1 < 0x80) {
      // 单字节 ASCII
      result += String.fromCharCode(b1)
      i++
    } else if ((b1 & 0xE0) === 0xC0) {
      // 双字节 UTF-8
      const b2 = uint8Array[i + 1] & 0xFF
      const code = ((b1 & 0x1F) << 6) | (b2 & 0x3F)
      result += String.fromCodePoint(code)
      i += 2
    } else if ((b1 & 0xF0) === 0xE0) {
      // 三字节 UTF-8（中文常用）
      const b2 = uint8Array[i + 1] & 0xFF
      const b3 = uint8Array[i + 2] & 0xFF
      const code = ((b1 & 0x0F) << 12) | ((b2 & 0x3F) << 6) | (b3 & 0x3F)
      // 调试：打印前3个中文字符的解码信息
      if (i < 20) {
        hilog.info(DOMAIN, 'testTag', '[ReaderPage] UTF-8 decode: i=%{public}d, b1=0x%{public}s, b2=0x%{public}s, b3=0x%{public}s, code=%{public}d', 
          i, b1.toString(16), b2.toString(16), b3.toString(16), code)
      }
      // 使用 fromCharCode 代替 fromCodePoint
      result += String.fromCharCode(code)
      i += 3
    } else if ((b1 & 0xF8) === 0xF0) {
      // 四字节 UTF-8
      const b2 = uint8Array[i + 1] & 0xFF
      const b3 = uint8Array[i + 2] & 0xFF
      const b4 = uint8Array[i + 3] & 0xFF
      let code = ((b1 & 0x07) << 18) | ((b2 & 0x3F) << 12) | ((b3 & 0x3F) << 6) | (b4 & 0x3F)
      // 四字节字符需要转换为 UTF-16 代理对
      code -= 0x10000
      result += String.fromCharCode(0xD800 + (code >> 10), 0xDC00 + (code & 0x3FF))
      i += 4
    } else {
      // 无效字节，跳过
      i++
    }
  }
  return result
}

@Entry
@Component
struct ReaderPage {
  @StorageLink('current_theme_colors') themeColors: ThemeColors = LightTheme
  @StorageLink('reader_font_size_val') fontSize: number = 18

  @State content: string = ''
  @State fileName: string = '未命名'
  @State isLoading: boolean = true
  @State showToc: boolean = false  // 是否显示目录面板
  @State tocList: TocItem[] = []   // 目录列表
  @State currentAnchor: string = '' // 当前要跳转的锚点
  private tocScroller: Scroller = new Scroller() // 目录滚动控制器

  private fileUri: string = ''
  private sandboxPath: string = ''
  private isRawFile: boolean = false

  // WebView 控制器 - 用于处理返回逻辑
  private webController: webview.WebviewController = new webview.WebviewController()

  aboutToAppear() {
    // 获取路由参数
    const params: object = router.getParams() as object
    if (params) {
      const p = params as Record<string, string | boolean>
      if (p['name']) {
        this.fileName = p['name'] as string
      }
      // 获取沙盒路径（从其他应用分享打开）
      if (p['sandboxPath']) {
        this.sandboxPath = p['sandboxPath'] as string
        console.log(`[ReaderPage] Sandbox path from params: ${this.sandboxPath}`)
      }
      // 获取文件路径（从 Index 页面点击）
      if (p['path']) {
        this.sandboxPath = p['path'] as string
        console.log(`[ReaderPage] File path from params: ${this.sandboxPath}`)
      }
      // 获取文件 URI（兼容旧版本）
      if (p['uri']) {
        this.fileUri = p['uri'] as string
        console.log(`[ReaderPage] File URI: ${this.fileUri}`)
      }
      // 是否为 rawfile 文件
      if (p['isRawFile']) {
        this.isRawFile = true
        console.log(`[ReaderPage] Is raw file: ${this.isRawFile}`)
      }
    }
    
    // 如果没有从路由获取到沙盒路径，尝试从 SharedFileStorage 获取
    // 这是当 EntryAbility 直接打开 ReaderPage 时的情况
    if (!this.sandboxPath) {
      const sharedFileInfo = SharedFileStorage.getFileInfo()
      if (sharedFileInfo && sharedFileInfo.sandboxPath) {
        this.fileName = sharedFileInfo.name
        this.sandboxPath = sharedFileInfo.sandboxPath
        console.log(`[ReaderPage] Sandbox path from SharedFileStorage: ${this.sandboxPath}`)
        // 成功读取后清除，避免重复打开
        SharedFileStorage.clearFileInfo()
      }
    }

    // 加载文件内容
    this.loadContent()
  }

  // 加载文件内容
  async loadContent() {
    this.isLoading = true
    try {
      console.log(`[ReaderPage] Loading content for ${this.fileName}`)
      console.log(`[ReaderPage] Sandbox path: ${this.sandboxPath}`)
      console.log(`[ReaderPage] Is raw file: ${this.isRawFile}`)
      console.log(`[ReaderPage] File URI: ${this.fileUri}`)
      
      if (this.isRawFile) {
        // 从 rawfile 读取（示例测试文件）
        console.log(`[ReaderPage] Reading raw file: ${this.fileName}`)
        this.content = await this.readRawFile(this.fileName)
      } else if (this.sandboxPath) {
        // 从沙盒路径读取（其他应用分享，已拷贝到沙盒）
        console.log(`[ReaderPage] Reading from sandbox: ${this.sandboxPath}`)
        this.content = await this.readFileFromSandbox(this.sandboxPath)
      } else if (this.fileUri) {
        // 从 URI 读取文件（兼容旧版本）
        console.log(`[ReaderPage] Reading from URI: ${this.fileUri}`)
        this.content = await this.readFileFromUri(this.fileUri)
      } else {
        // 根据文件名从本地 Documents 目录读取
        const filePath: string = `/storage/Users/currentUser/Documents/${this.fileName}`
        console.log(`[ReaderPage] Reading from Documents: ${filePath}`)
        this.content = await FileService.readFileContent(filePath)
      }
      
      console.log(`[ReaderPage] Loaded content for ${this.fileName}, length: ${this.content.length}`)
      if (this.content.length > 0) {
        console.log(`[ReaderPage] First 200 chars: ${this.content.substring(0, 200)}`)
      }
      
      // 提取目录（添加错误处理）
      try {
        this.tocList = MarkdownParser.extractToc(this.content)
        console.log(`[ReaderPage] Extracted ${this.tocList.length} TOC items`)
      } catch (tocError) {
        console.error('[ReaderPage] Failed to extract TOC:', tocError)
        this.tocList = []
      }
    } catch (e) {
      console.error('加载文件失败:', e)
      this.content = `# 加载失败\n\n无法读取文件内容。\n\n错误信息: ${e}`
    } finally {
      this.isLoading = false
    }
  }

  // 从 rawfile 读取文件内容
  private async readRawFile(fileName: string): Promise<string> {
    try {
      const context = getContext(this)
      const rawFile = await context.resourceManager.getRawFileContent(fileName)
      
      // 关键：getRawFileContent 返回的对象需要转换为 Uint8Array
      const uint8Array = new Uint8Array(rawFile)
      
      hilog.info(DOMAIN, 'testTag', '[ReaderPage] Raw file length: %{public}d', uint8Array.length)
      
      // 打印前 20 个字节的十六进制值，用于调试
      let hexBytes = ''
      for (let i = 0; i < Math.min(20, uint8Array.length); i++) {
        hexBytes += uint8Array[i].toString(16).padStart(2, '0') + ' '
      }
      hilog.info(DOMAIN, 'testTag', '[ReaderPage] First 20 bytes (hex): %{public}s', hexBytes)
      
      // 使用 UTF-8 解码
      const decoded = decodeUtf8(uint8Array)
      hilog.info(DOMAIN, 'testTag', '[ReaderPage] Decoded first 50 chars: %{public}s', decoded.substring(0, 50))
      return decoded
    } catch (e) {
      hilog.error(DOMAIN, 'testTag', '[ReaderPage] Failed to read raw file: %{public}s', JSON.stringify(e))
      return ''
    }
  }

  // 从 URI 读取文件内容
  private async readFileFromUri(uri: string): Promise<string> {
    try {
      // 使用 fileIo 读取文件
      const file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
      const stat = fileIo.statSync(file.fd)
      const buf = new ArrayBuffer(stat.size)
      fileIo.readSync(file.fd, buf)
      fileIo.closeSync(file)

      // 使用 UTF-8 解码
      const uint8Array = new Uint8Array(buf)
      return decodeUtf8(uint8Array)
    } catch (e) {
      console.error(`[ReaderPage] Failed to read file from URI: ${e}`)
      return ''
    }
  }

  // 从沙盒路径读取文件内容
  private async readFileFromSandbox(sandboxPath: string): Promise<string> {
    try {
      console.log(`[ReaderPage] Reading from sandbox: ${sandboxPath}`)
      
      // 使用 fileIo 读取沙盒文件
      const file = fileIo.openSync(sandboxPath, fileIo.OpenMode.READ_ONLY)
      const stat = fileIo.statSync(file.fd)
      const buf = new ArrayBuffer(stat.size)
      fileIo.readSync(file.fd, buf)
      fileIo.closeSync(file)

      // 使用 UTF-8 解码
      const uint8Array = new Uint8Array(buf)
      const content = decodeUtf8(uint8Array)
      console.log(`[ReaderPage] Successfully read ${uint8Array.length} bytes from sandbox`)
      return content
    } catch (e) {
      console.error(`[ReaderPage] Failed to read file from sandbox: ${e}`)
      return ''
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        // 返回按钮
        Button() {
          Image($r('app.media.ic_back_48'))
            .width(24)
            .height(24)
            .fillColor(this.themeColors.textPrimary)
        }
        .width(44)
        .height(44)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.handleBack()
        })

        Text(this.fileName)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeColors.textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 目录按钮（仅在存在目录时显示）
        if (this.tocList.length > 0) {
          Button() {
            Image($r('app.media.ic_list_48'))
              .width(22)
              .height(22)
              .fillColor(this.themeColors.textPrimary)
          }
          .width(44)
          .height(44)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.showToc = true
          })
          .bindSheet(this.showToc, this.TocSheet(), {
              height: 400,
              dragBar: true,
              showClose: true,
              onDisappear: () => {
                // 保存当前滚动偏移量
                const currentOffset = this.tocScroller.currentOffset().yOffset
                StorageService.saveTocScrollOffset(currentOffset)
                hilog.info(DOMAIN, 'testTag', '[ReaderPage] TOC bindSheet onDisappear, offset saved: %{public}d', currentOffset)
                this.showToc = false
              }
            })
        }
      }
      .width('100%')
      .height(56)
      .padding({ left: 8, right: 8 })
      .backgroundColor(this.themeColors.background)

      // Markdown 渲染区域
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color(this.themeColors.primary)
          Text('加载中...')
            .fontSize(14)
            .fontColor(this.themeColors.textSecondary)
            .margin({ top: 12 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        MDRender({
          content: this.content,
          themeColors: this.themeColors,
          fontSize: this.fontSize,
          scrollToAnchor: this.currentAnchor,
          externalController: this.webController
        })
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeColors.background)
    // 触摸指示器 - 用于调试显示点击位置
  }

  // 目录面板
  @Builder
  TocSheet() {
    Column() {
      Text('目录')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeColors.textPrimary)
        .margin({ top: 16, bottom: 12, left: 16, right: 16 })
      
      List({ scroller: this.tocScroller, space: 0 }) {
        ForEach(this.tocList, (item: TocItem) => {
          ListItem() {
            Row() {
              Text(item.title)
                .fontSize(16 - (item.level - 1) * 2)
                .fontColor(this.themeColors.textPrimary)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)
                .textAlign(TextAlign.Start)
            }
            .width('100%')
            .padding({ left: 16 + (item.level - 1) * 20, right: 16, top: 12, bottom: 12 })
            .backgroundColor(this.themeColors.background)
          }
          .onClick(() => {
            console.log(`[ReaderPage] TOC item clicked: ${item.anchorId}`)
            this.showToc = false
            this.currentAnchor = ''
            setTimeout(() => {
              this.currentAnchor = item.anchorId
              console.log(`[ReaderPage] Set anchor to: ${item.anchorId}`)
            }, 50)
          })
        }, (item: TocItem) => item.anchorId)
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(this.themeColors.background)
      .onReachEnd(() => {
        console.log(`[ReaderPage] TOC list reached end`)
      })
      .onScrollIndex((start: number, end: number) => {
        const currentOffset = this.tocScroller.currentOffset().yOffset
        hilog.info(DOMAIN, 'testTag', '[ReaderPage] TOC onScrollIndex triggered, start=%{public}d, end=%{public}d, offset=%{public}d', start, end, currentOffset)
        // 不再在这里保存偏移量，改在 onDisappear 中保存
        // 这样可以避免初始化时的滚动事件覆盖已保存的偏移量
      })
      .onAppear(() => {
        const savedOffset = StorageService.getTocScrollOffset()
        hilog.info(DOMAIN, 'testTag', '[ReaderPage] TOC List onAppear called, savedOffset=%{public}d', savedOffset)
        // 延迟滚动到保存的位置
        setTimeout(() => {
          hilog.info(DOMAIN, 'testTag', '[ReaderPage] TOC List scrolling to offset: %{public}d', savedOffset)
          this.tocScroller.scrollTo({ xOffset: 0, yOffset: savedOffset, animation: false })
        }, 100)
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeColors.background)
  }

  // 处理返回按钮点击
  private handleBack() {
    // 先尝试 WebView 回退
    try {
      if (this.webController.accessBackward()) {
        this.webController.backward()
        hilog.info(DOMAIN, 'testTag', '[ReaderPage] WebView goBack success')
        return
      }
    } catch (e) {
      hilog.error(DOMAIN, 'testTag', '[ReaderPage] WebView goBack error: %{public}s', JSON.stringify(e))
    }

    // WebView 无法回退，返回列表
    hilog.info(DOMAIN, 'testTag', '[ReaderPage] WebView cannot go back, returning to list')
    router.back()
  }
}
