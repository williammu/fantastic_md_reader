import { http } from '@kit.NetworkKit'
import { fileIo } from '@kit.CoreFileKit'

// HTTP 服务器服务，用于查看沙盒文件
export class HttpServerService {
  private static server: http.HttpServer | null = null
  private static port: number = 8080

  // 启动 HTTP 服务器
  static startServer(): void {
    try {
      // 创建 HTTP 服务器
      this.server = new http.HttpServer()
      
      // 监听端口
      this.server.listen(this.port, (err: Error) => {
        if (err) {
          console.error('[HttpServer] Failed to start server:', err)
          return
        }
        console.log(`[HttpServer] Server started on port ${this.port}`)
        console.log(`[HttpServer] Access URL: http://localhost:${this.port}`)
      })

      // 处理请求
      this.server.onRequest((request: http.HttpRequest, response: http.HttpResponse) => {
        this.handleRequest(request, response)
      })

    } catch (e) {
      console.error('[HttpServer] Error starting server:', e)
    }
  }

  // 停止 HTTP 服务器
  static stopServer(): void {
    if (this.server) {
      this.server.close()
      this.server = null
      console.log('[HttpServer] Server stopped')
    }
  }

  // 处理 HTTP 请求
  private static handleRequest(request: http.HttpRequest, response: http.HttpResponse): void {
    try {
      const path = request.url?.pathname || '/'
      
      // 根路径返回文件列表
      if (path === '/') {
        this.handleFileList(response)
      } 
      // 文件内容请求
      else if (path.startsWith('/files/')) {
        const filePath = path.substring(6) // 去掉 /files/ 前缀
        this.handleFileContent(filePath, response)
      } 
      // 404
      else {
        response.statusCode = 404
        response.setHeader('Content-Type', 'text/plain')
        response.end('404 Not Found')
      }
    } catch (e) {
      console.error('[HttpServer] Error handling request:', e)
      response.statusCode = 500
      response.setHeader('Content-Type', 'text/plain')
      response.end('Internal Server Error')
    }
  }

  // 处理文件列表请求
  private static handleFileList(response: http.HttpResponse): void {
    try {
      // 扫描沙盒目录
      const sandboxDir = 'files/shared/'
      const files = fileIo.listFileSync(sandboxDir)
      
      // 构建 HTML 响应
      let html = `
      <!DOCTYPE html>
      <html>
      <head>
        <title>MD Reader Sandbox Files</title>
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
        <h1>MD Reader Sandbox Files</h1>
        <ul>
      `
      
      for (const fileName of files) {
        if (fileName.endsWith('.md') || fileName.endsWith('.markdown')) {
          const filePath = sandboxDir + fileName
          const stat = fileIo.statSync(filePath)
          const size = this.formatFileSize(stat.size)
          const mtime = new Date(stat.mtime * 1000).toLocaleString()
          
          html += `
            <li>
              <a href="/files/${fileName}">${fileName}</a>
              <div class="file-info">Size: ${size} | Modified: ${mtime}</div>
            </li>
          `
        }
      }
      
      html += `
        </ul>
      </body>
      </html>
      `
      
      response.statusCode = 200
      response.setHeader('Content-Type', 'text/html')
      response.end(html)
      
    } catch (e) {
      console.error('[HttpServer] Error listing files:', e)
      response.statusCode = 500
      response.setHeader('Content-Type', 'text/plain')
      response.end('Error listing files')
    }
  }

  // 处理文件内容请求
  private static handleFileContent(filePath: string, response: http.HttpResponse): void {
    try {
      const fullPath = 'files/shared/' + filePath
      const content = fileIo.readTextSync(fullPath)
      
      response.statusCode = 200
      response.setHeader('Content-Type', 'text/plain; charset=utf-8')
      response.end(content)
      
    } catch (e) {
      console.error('[HttpServer] Error reading file:', e)
      response.statusCode = 404
      response.setHeader('Content-Type', 'text/plain')
      response.end('File not found')
    }
  }

  // 格式化文件大小
  private static formatFileSize(bytes: number): string {
    if (bytes < 1024) return bytes + ' B'
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB'
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB'
  }
}
