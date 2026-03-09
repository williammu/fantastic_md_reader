import { http } from '@kit.NetworkKit'
import { fileIo } from '@kit.CoreFileKit'

// 日志服务器服务，用于通过 HTTP 提供日志文件访问
export class LogServerService {
  private static server: http.HttpServer | null = null
  private static port: number = 8080

  // 启动日志服务器
  static startServer(): void {
    try {
      // 创建 HTTP 服务器
      this.server = new http.HttpServer()
      
      // 监听端口
      this.server.listen(this.port, (err: Error) => {
        if (err) {
          console.error('[LogServer] Failed to start server:', err)
          return
        }
        console.log(`[LogServer] Server started on port ${this.port}`)
        console.log(`[LogServer] Access URL: http://localhost:${this.port}`)
      })

      // 处理请求
      this.server.onRequest((request: http.HttpRequest, response: http.HttpResponse) => {
        this.handleRequest(request, response)
      })

    } catch (e) {
      console.error('[LogServer] Error starting server:', e)
    }
  }

  // 停止日志服务器
  static stopServer(): void {
    if (this.server) {
      this.server.close()
      this.server = null
      console.log('[LogServer] Server stopped')
    }
  }

  // 处理 HTTP 请求
  private static handleRequest(request: http.HttpRequest, response: http.HttpResponse): void {
    try {
      const path = request.url?.pathname || '/'
      
      // 根路径返回日志文件列表
      if (path === '/') {
        this.handleLogList(response)
      } 
      // 日志文件内容请求
      else if (path.startsWith('/logs/')) {
        const logFileName = path.substring(6) // 去掉 /logs/ 前缀
        this.handleLogContent(logFileName, response)
      } 
      // 404
      else {
        response.statusCode = 404
        response.header['Content-Type'] = 'text/plain'
        response.body = '404 Not Found'
      }
    } catch (e) {
      console.error('[LogServer] Error handling request:', e)
      response.statusCode = 500
      response.header['Content-Type'] = 'text/plain'
      response.body = 'Internal Server Error'
    }
  }

  // 处理日志文件列表请求
  private static handleLogList(response: http.HttpResponse): void {
    try {
      // 扫描沙盒目录中的日志文件
      const sandboxDir = 'files/shared/'
      const files = fileIo.listFileSync(sandboxDir)
      
      // 筛选日志文件
      const logFiles = files.filter(file => file.endsWith('.log') || file.endsWith('.txt'))
      
      // 构建 HTML 响应
      let html = `
      <!DOCTYPE html>
      <html>
      <head>
        <title>MD Reader Logs</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 20px; }
          h1 { color: #333; }
          ul { list-style: none; padding: 0; }
          li { margin: 10px 0; padding: 10px; border: 1px solid #ddd; border-radius: 4px; }
          a { text-decoration: none; color: #0066cc; }
          a:hover { text-decoration: underline; }
          .file-info { font-size: 12px; color: #666; margin-top: 5px; }
        </style>
      </head>
      <body>
        <h1>MD Reader Logs</h1>
        <ul>
      `
      
      for (const fileName of logFiles) {
        const filePath = sandboxDir + fileName
        const stat = fileIo.statSync(filePath)
        const size = this.formatFileSize(stat.size)
        const mtime = new Date(stat.mtime * 1000).toLocaleString()
        
        html += `
            <li>
              <a href="/logs/${fileName}">${fileName}</a>
              <div class="file-info">Size: ${size} | Modified: ${mtime}</div>
            </li>
          `
      }
      
      html += `
        </ul>
      </body>
      </html>
      `
      
      response.statusCode = 200
      response.header['Content-Type'] = 'text/html'
      response.body = html
      
    } catch (e) {
      console.error('[LogServer] Error listing logs:', e)
      response.statusCode = 500
      response.header['Content-Type'] = 'text/plain'
      response.body = 'Error listing logs'
    }
  }

  // 处理日志文件内容请求
  private static handleLogContent(logFileName: string, response: http.HttpResponse): void {
    try {
      const fullPath = 'files/shared/' + logFileName
      const content = fileIo.readTextSync(fullPath)
      
      response.statusCode = 200
      response.header['Content-Type'] = 'text/plain; charset=utf-8'
      response.body = content
      
    } catch (e) {
      console.error('[LogServer] Error reading log:', e)
      response.statusCode = 404
      response.header['Content-Type'] = 'text/plain'
      response.body = 'Log file not found'
    }
  }

  // 格式化文件大小
  private static formatFileSize(bytes: number): string {
    if (bytes < 1024) return bytes + ' B'
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB'
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB'
  }
}
