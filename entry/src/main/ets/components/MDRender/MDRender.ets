import { ThemeColors } from '../../models/Theme'
import { MarkdownParser } from '../../utils/MarkdownParser'
import { HTMLGenerator } from '../../utils/HTMLGenerator'
import webview from '@ohos.web.webview'

@Component
export struct MDRender {
  @Prop content: string
  @Prop themeColors: ThemeColors
  @Prop fontSize: number = 16
  @Prop lineHeight: number = 1.6
  @Prop enableHighlight: boolean = false
  @Prop scrollToAnchor: string = ''

  private htmlContent: string = ''

  aboutToAppear() {
    try {
      const htmlBody = MarkdownParser.parse(this.content)
      this.htmlContent = HTMLGenerator.generate(htmlBody, this.themeColors, this.fontSize, this.lineHeight)
    } catch (e) {
      console.error('[MDRender] parse error:', e)
      this.htmlContent = '<html><body><p>Error rendering content</p></body></html>'
    }
  }

  build() {
    Column() {
      Web({
        src: `data:text/html;charset=utf-8,${encodeURIComponent(this.htmlContent)}`,
        controller: new webview.WebviewController()
      })
        .javaScriptAccess(true)
        .domStorageAccess(true)
        .backgroundColor(this.themeColors.background)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeColors.background)
  }
}
