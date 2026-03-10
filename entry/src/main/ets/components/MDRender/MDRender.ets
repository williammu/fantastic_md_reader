import { ThemeColors } from '../../models/Theme'
import { MarkdownParser } from '../../utils/MarkdownParser'
import { HTMLGenerator } from '../../utils/HTMLGenerator'
import webview from '@ohos.web.webview'
import { socket } from '@kit.NetworkKit'

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
      const htmlBody = MarkdownParser.parse(this.content)
      const htmlContent = HTMLGenerator.generate(htmlBody, this.themeColors, this.fontSize, this.lineHeight)
      console.log('[MDRender] HTML generated, length:', htmlContent.length)

      // 发送 HTML 到本地服务器
      this.sendHtmlToServer(htmlContent)

      // 使用 data URL 方式加载 HTML
      this.htmlSrc = `data:text/html;charset=utf-8,${encodeURIComponent(htmlContent)}`
    } catch (e) {
      console.error('[MDRender] parse error:', e)
      this.htmlSrc = 'data:text/html,<h1>Error loading content</h1>'
    }
  }

  // 发送 HTML 到本地服务器
  private sendHtmlToServer(htmlContent: string) {
    try {
      console.log('[MDRender] Attempting to connect to server...')
      
      // 创建 TCP socket
      const tcpSocket = socket.constructTCPSocketInstance()

      // 连接到本地服务器 - 使用正确的IP地址
      const connectOptions: socket.TCPConnectOptions = {
        address: {
          address: '192.168.3.67',  // 本地电脑 IP (从 ipconfig 获取)
          port: 8080
        }
      }

      console.log('[MDRender] Connecting to:', JSON.stringify(connectOptions))

      tcpSocket.connect(connectOptions).then(() => {
        console.log('[MDRender] Connected to log server')

        // 发送 HTML 内容
        tcpSocket.send({
          data: htmlContent
        }).then(() => {
          console.log('[MDRender] HTML sent to server, length:', htmlContent.length)

          // 关闭连接
          tcpSocket.close()
        }).catch((err: Error) => {
          console.error('[MDRender] Failed to send HTML:', err)
          tcpSocket.close()
        })
      }).catch((err: Error) => {
        console.error('[MDRender] Failed to connect to server:', err)
      })
    } catch (e) {
      console.error('[MDRender] Error sending HTML to server:', e)
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
