import { socket } from '@kit.NetworkKit'
import { fileIo } from '@kit.CoreFileKit'
import { util } from '@kit.ArkTS'
import { SharedFileStorage } from '../entryability/EntryAbility'

// 日志 Socket 服务，用于通过 Socket 提供日志文件访问
export class LogSocketService {
  private static tcpServer: socket.TCPSocketServer | null = null
  private static port: number = 8080

  // 启动 Socket 服务器
  static startServer(): void {
    try {
      // 创建 TCP 服务器
      LogSocketService.tcpServer = socket.constructTCPSocketServerInstance()
      
      // 监听端口
      const address: socket.NetAddress = {
        address: '0.0.0.0',
        port: LogSocketService.port
      }
      
      if (LogSocketService.tcpServer) {
        LogSocketService.tcpServer.listen(address, (err: Error) => {
          if (err) {
            console.log('[LogSocket] Failed to start server:', err)
            return
          }
          console.log(`[LogSocket] Server started on port ${LogSocketService.port}`)
          console.log(`[LogSocket] Access via: telnet localhost ${LogSocketService.port}`)
          
          // 创建日志文件
          LogSocketService.createLogFile()
        })

        // 处理连接
        LogSocketService.tcpServer.on('connect', (conn: socket.TCPSocketConnection) => {
          LogSocketService.handleConnection(conn)
        })
      }

    } catch (e) {
      console.log('[LogSocket] Error starting server:', e)
    }
  }
  
  // 获取沙盒目录路径
  private static getSandboxDir(): string {
    const filesDir = SharedFileStorage.getFilesDir();
    if (filesDir) {
      return filesDir + '/shared';
    }
    return 'files/shared';
  }
  
  // 创建日志文件
  private static createLogFile(): void {
    try {
      const filesDir = SharedFileStorage.getFilesDir();
      const sandboxDir = filesDir ? filesDir + '/shared' : 'files/shared';
      const logFilePath = sandboxDir + '/app.log';
      
      // 确保目录存在
      try {
        fileIo.mkdirSync(filesDir || 'files/')
        console.log('[LogSocket] Created files directory')
      } catch (e) {
        // 目录已存在，忽略错误
      }
      
      try {
        fileIo.mkdirSync(sandboxDir)
        console.log('[LogSocket] Created shared directory')
      } catch (e) {
        // 目录已存在，忽略错误
      }
      
      // 创建空日志文件
      try {
        const file = fileIo.openSync(logFilePath, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC)
        fileIo.closeSync(file)
        console.log('[LogSocket] Created app.log file')
        
        // 写入初始日志
        const initialLog = '[' + new Date().toISOString() + '] [LogSocket] Log file created\n'
        const fileAppend = fileIo.openSync(logFilePath, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.APPEND)
        const buffer = new ArrayBuffer(initialLog.length)
        const view = new Uint8Array(buffer)
        for (let i = 0; i < initialLog.length; i++) {
          view[i] = initialLog.charCodeAt(i)
        }
        fileIo.writeSync(fileAppend.fd, buffer)
        fileIo.closeSync(fileAppend)
      } catch (e) {
        console.log('[LogSocket] Failed to create log file:', e)
      }
    } catch (e) {
      console.log('[LogSocket] Error creating log file:', e)
    }
  }

  // 停止 Socket 服务器
  static stopServer(): void {
    if (LogSocketService.tcpServer) {
      LogSocketService.tcpServer.close()
      LogSocketService.tcpServer = null
      console.log('[LogSocket] Server stopped')
    }
  }

  // 处理客户端连接
  private static handleConnection(conn: socket.TCPSocketConnection): void {
    console.log('[LogSocket] New connection established')
    
    try {
      const sandboxDir = LogSocketService.getSandboxDir()
      
      // 首先尝试读取 debug_output.html 文件
      const htmlFilePath = sandboxDir + '/debug_output.html'
      let htmlBuffer: ArrayBuffer | null = null
      let htmlFound = false
      
      try {
        const file = fileIo.openSync(htmlFilePath, fileIo.OpenMode.READ_ONLY)
        const stat = fileIo.statSync(file.fd)
        const buffer = new ArrayBuffer(stat.size)
        fileIo.readSync(file.fd, buffer)
        fileIo.closeSync(file)
        htmlBuffer = buffer
        htmlFound = true
        console.log('[LogSocket] Successfully read debug_output.html, size:', stat.size)
      } catch (e) {
        console.log('[LogSocket] Failed to read debug_output.html:', e)
      }
      
      if (htmlFound && htmlBuffer) {
        // 直接发送二进制数据
        conn.send({
          data: htmlBuffer
        })
        console.log('[LogSocket] Sent HTML buffer, size:', htmlBuffer.byteLength)
      } else {
        // 读取日志文件作为 fallback
        let logContent = ''
        
        try {
          LogSocketService.createLogFile()
          
          const logFilePath = sandboxDir + '/app.log'
          try {
            logContent = fileIo.readTextSync(logFilePath)
          } catch (e) {
            console.log('[LogSocket] Failed to read app.log:', e)
            logContent = '=== App Log File ===\nFailed to read app.log: ' + e + '\n\n'
          }
          
          logContent += '=== System Logs ===\n'
          logContent += '[LogSocket] Server started on port ' + LogSocketService.port + '\n'
          logContent += '[LogSocket] Connection established\n'
          logContent += '[LogSocket] Current time: ' + new Date().toISOString() + '\n'
          
          try {
            const files = fileIo.listFileSync(sandboxDir)
            logContent += '=== Sandbox Files ===\n'
            logContent += 'Files in shared directory: ' + files.join(', ') + '\n'
          } catch (e) {
            logContent += '=== Sandbox Files ===\n'
            logContent += 'Failed to list sandbox files: ' + e + '\n'
          }
          
        } catch (e) {
          console.log('[LogSocket] Error reading logs:', e)
          logContent = 'Failed to read logs: ' + e
        }
        
        const response = `MD Reader Logs\n================\n${logContent}\n================\n`
        
        // 将字符串转换为 UTF-8 字节
        const encoder = new util.TextEncoder()
        const logBuffer = encoder.encode(response).buffer
        conn.send({
          data: logBuffer
        })
      }
      
      conn.close()
      console.log('[LogSocket] Connection closed')
      
    } catch (e) {
      console.log('[LogSocket] Error handling connection:', e)
      if (conn) {
        conn.close()
      }
    }
  }
}
