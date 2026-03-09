import { ThemeColors } from '../../models/Theme'
import { MarkdownParser } from '../../utils/MarkdownParser'

// Markdown 渲染组件（使用 Text 组件，支持 Markdown 解析）
@Component
export struct MDRender {
  @Prop content: string           // Markdown 内容
  @Prop themeColors: ThemeColors          // 主题颜色
  @Prop fontSize: number = 16             // 字体大小
  @Prop lineHeight: number = 1.6          // 行高
  @Prop enableHighlight: boolean = false  // 是否启用朗读高亮
  @Prop scrollToAnchor: string = '' // 要滚动到的锚点ID
  
  // 解析 Markdown 内容为纯文本
  private getParsedContent(): string {
    try {
      // 解析 Markdown 为 HTML
      const html = MarkdownParser.parse(this.content)
      // 移除 HTML 标签，保留纯文本
      return html.replace(/<[^>]+>/g, '')
    } catch (e) {
      return this.content
    }
  }
  
  build() {
    Scroll() {
      Column() {
        // 渲染 Markdown 内容（使用 MarkdownParser 解析）
        Text(this.getParsedContent())
          .fontSize(this.fontSize)
          .lineHeight(this.fontSize * this.lineHeight)
          .fontColor(this.themeColors.textPrimary)
          .padding(16)
          .textAlign(TextAlign.Start)
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeColors.background)
  }
}
