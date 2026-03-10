import { ThemeColors } from '../../models/Theme'
import { MarkdownParser } from '../../utils/MarkdownParser'
import { HTMLGenerator } from '../../utils/HTMLGenerator'
import webview from '@ohos.web.webview'
import { hilog } from '@kit.PerformanceAnalysisKit'

const DOMAIN = 0x0003

@Component
export struct MDRender {
  @Prop content: string
  @Prop themeColors: ThemeColors
  @Prop fontSize: number = 16
  @Prop lineHeight: number = 1.6
  @Prop enableHighlight: boolean = false
  @Prop scrollToAnchor: string = ''

  @State htmlSrc: string = ''

  aboutToAppear() {
    try {
      hilog.info(DOMAIN, 'testTag', '[MDRender] aboutToAppear called, content length: %{public}d', this.content.length)
      hilog.info(DOMAIN, 'testTag', '[MDRender] Content preview: %{public}s', this.content.substring(0, 200))

      hilog.info(DOMAIN, 'testTag', '%{public}s', '[MDRender] Calling MarkdownParser.parse...')
      const htmlBody = MarkdownParser.parse(this.content)
      hilog.info(DOMAIN, 'testTag', '[MDRender] MarkdownParser.parse done, htmlBody length: %{public}d', htmlBody.length)

      hilog.info(DOMAIN, 'testTag', '%{public}s', '[MDRender] Calling HTMLGenerator.generate...')
      const htmlContent = HTMLGenerator.generate(htmlBody, this.themeColors, this.fontSize, this.lineHeight)
      hilog.info(DOMAIN, 'testTag', '[MDRender] HTML generated, length: %{public}d', htmlContent.length)
      hilog.info(DOMAIN, 'testTag', '[MDRender] HTML preview: %{public}s', htmlContent.substring(0, 500))

      // 使用 data URL 方式加载 HTML
      this.htmlSrc = `data:text/html;charset=utf-8,${encodeURIComponent(htmlContent)}`
      hilog.info(DOMAIN, 'testTag', '[MDRender] htmlSrc set, length: %{public}d', this.htmlSrc.length)
    } catch (e) {
      hilog.error(DOMAIN, 'testTag', '[MDRender] parse error: %{public}s', JSON.stringify(e))
      hilog.error(DOMAIN, 'testTag', '[MDRender] error stack: %{public}s', (e as Error).stack)
      this.htmlSrc = 'data:text/html,<h1>Error loading content</h1>'
    }
  }

  build() {
    Column() {
      if (this.htmlSrc !== '') {
        Web({
          src: this.htmlSrc,
          controller: new webview.WebviewController()
        })
          .javaScriptAccess(true)
          .domStorageAccess(true)
          .backgroundColor(this.themeColors.background)
      } else {
        Text('Loading...')
          .fontSize(16)
          .fontColor(this.themeColors.textSecondary)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeColors.background)
  }
}
