import { ThemeColors } from '../../models/Theme'
import { MarkdownParser, HTMLGenerator } from 'markdown-renderer'
import webview from '@ohos.web.webview'
import { hilog } from '@kit.PerformanceAnalysisKit'

const DOMAIN = 0x0003

@Component
export struct MDRender {
  @Prop content: string
  @Prop themeColors: ThemeColors
  @Prop fontSize: number = 16
  @Prop lineHeight: number = 1.6
  @Prop @Watch('onScrollToAnchorChange') scrollToAnchor: string = ''

  @State htmlSrc: string = ''
  private webController: webview.WebviewController = new webview.WebviewController()
  private lastScrollAnchor: string = ''
  private pageLoaded: boolean = false

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

  aboutToRecycle() {
    this.webController = new webview.WebviewController()
  }

  // 监听 scrollToAnchor 变化，触发锚点跳转
  private onScrollToAnchorChange() {
    if (this.scrollToAnchor && this.scrollToAnchor !== this.lastScrollAnchor) {
      hilog.info(DOMAIN, 'testTag', '[MDRender] scrollToAnchor changed to: %{public}s', this.scrollToAnchor)
      this.lastScrollAnchor = this.scrollToAnchor
      
      // 如果页面已经加载完成，立即滚动
      if (this.pageLoaded) {
        this.scrollToElement(this.scrollToAnchor)
      } else {
        // 否则延迟执行，等待页面加载
        setTimeout(() => {
          this.scrollToElement(this.scrollToAnchor)
        }, 300)
      }
    }
  }

  // 滚动到指定锚点
  private scrollToElement(anchorId: string) {
    if (!anchorId) return
    
    hilog.info(DOMAIN, 'testTag', '[MDRender] Scrolling to anchor: %{public}s', anchorId)
    const jsCode = `
      (function() {
        var el = document.getElementById('${anchorId}');
        if (el) {
          el.scrollIntoView({behavior: 'smooth'});
          return true;
        }
        return false;
      })();
    `
    try {
      this.webController.runJavaScript(jsCode)
    } catch (e) {
      hilog.error(DOMAIN, 'testTag', '[MDRender] Failed to scroll to anchor: %{public}s', JSON.stringify(e))
    }
  }

  build() {
    Column() {
      if (this.htmlSrc !== '') {
        Web({
          src: this.htmlSrc,
          controller: this.webController
        })
          .javaScriptAccess(true)
          .domStorageAccess(true)
          .backgroundColor(this.themeColors.background)
          .onPageEnd(() => {
            hilog.info(DOMAIN, 'testTag', '[MDRender] Page loaded')
            this.pageLoaded = true
            // 页面加载完成后，如果有初始锚点，则滚动
            if (this.scrollToAnchor) {
              this.onScrollToAnchorChange()
            }
          })
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
