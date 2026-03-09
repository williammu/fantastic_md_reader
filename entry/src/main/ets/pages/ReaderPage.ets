import { router } from '@kit.ArkUI'
import { ThemeColors, LightTheme } from '../models/Theme'
import { MDRender } from '../components/MDRender/MDRender'
import { TTSControlBar } from '../components/TTSControl/TTSControlBar'
import { ttsService, TTSState } from '../services/TTSService'
import { ParagraphSplitter } from '../utils/ParagraphSplitter'
import { FileService } from '../services/FileService'
import { fileIo } from '@kit.CoreFileKit'
import { buffer } from '@kit.ArkTS'
import { SharedFileStorage } from '../entryability/EntryAbility'
import { MarkdownParser, TocItem } from '../utils/MarkdownParser'
import { promptAction } from '@kit.ArkUI'

// UTF-8 解码函数（ArkTS兼容）
function decodeUtf8(uint8Array: Uint8Array): string {
  let result = ''
  let i = 0
  while (i < uint8Array.length) {
    const byte1 = uint8Array[i]
    if (byte1 < 0x80) {
      // 单字节 ASCII
      result += String.fromCharCode(byte1)
      i++
    } else if ((byte1 & 0xE0) === 0xC0) {
      // 双字节 UTF-8
      const byte2 = uint8Array[i + 1]
      const code = ((byte1 & 0x1F) << 6) | (byte2 & 0x3F)
      result += String.fromCharCode(code)
      i += 2
    } else if ((byte1 & 0xF0) === 0xE0) {
      // 三字节 UTF-8（中文常用）
      const byte2 = uint8Array[i + 1]
      const byte3 = uint8Array[i + 2]
      const code = ((byte1 & 0x0F) << 12) | ((byte2 & 0x3F) << 6) | (byte3 & 0x3F)
      result += String.fromCharCode(code)
      i += 3
    } else if ((byte1 & 0xF8) === 0xF0) {
      // 四字节 UTF-8
      const byte2 = uint8Array[i + 1]
      const byte3 = uint8Array[i + 2]
      const byte4 = uint8Array[i + 3]
      let code = ((byte1 & 0x07) << 18) | ((byte2 & 0x3F) << 12) | ((byte3 & 0x3F) << 6) | (byte4 & 0x3F)
      // 转换为 UTF-16 代理对
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
  @State showTTS: boolean = false
  @State ttsState: TTSState = TTSState.IDLE
  @State showToc: boolean = false  // 是否显示目录面板
  @State tocList: TocItem[] = []   // 目录列表
  @State currentAnchor: string = '' // 当前要跳转的锚点

  private fileUri: string = ''
  private sandboxPath: string = ''
  private isRawFile: boolean = false

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

    // 准备朗读段落（添加错误处理）
    try {
      const paragraphs = ParagraphSplitter.split(this.content)
      console.log(`文档分割为 ${paragraphs.length} 个段落`)
    } catch (splitError) {
      console.error('[ReaderPage] Failed to split paragraphs:', splitError)
    }

    // 监听 TTS 状态
    try {
      ttsService.onStateChange((state: TTSState) => {
        this.ttsState = state
        this.showTTS = state !== TTSState.IDLE
      })
    } catch (ttsError) {
      console.error('[ReaderPage] Failed to set up TTS:', ttsError)
    }
  }

  // 从 rawfile 读取文件内容
  private async readRawFile(fileName: string): Promise<string> {
    try {
      const context = getContext(this)
      const rawFile = await context.resourceManager.getRawFileContent(fileName)
      
      // 使用 UTF-8 解码
      const uint8Array = new Uint8Array(rawFile.buffer, rawFile.byteOffset, rawFile.byteLength)
      return decodeUtf8(uint8Array)
    } catch (e) {
      console.error(`[ReaderPage] Failed to read raw file: ${e}`)
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

  // 开始朗读
  private startTTS() {
    ttsService.start(this.content)
    this.showTTS = true
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button('‹')
          .fontSize(28)
          .backgroundColor(Color.Transparent)
          .fontColor(this.themeColors.textPrimary)
          .onClick(() => {
            router.back()
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
          Button('☰')
            .fontSize(20)
            .backgroundColor(Color.Transparent)
            .fontColor(this.themeColors.textPrimary)
            .onClick(() => {
              this.showToc = true
            })
            .bindSheet(this.showToc, this.TocSheet(), {
              height: 400,
              dragBar: true,
              showClose: true,
              onDisappear: () => {
                this.showToc = false
              }
            })
        }

        // 朗读按钮
        Button('🔊')
          .fontSize(20)
          .backgroundColor(Color.Transparent)
          .fontColor(this.themeColors.primary)
          .onClick(() => {
            this.startTTS()
          })
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
          enableHighlight: this.showTTS,
          scrollToAnchor: this.currentAnchor
        })
        .layoutWeight(1)
      }

      // 朗读控制条
      if (this.showTTS) {
        TTSControlBar({
          themeColors: this.themeColors
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeColors.background)
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
      
      List({ space: 0 }) {
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeColors.background)
  }
}
