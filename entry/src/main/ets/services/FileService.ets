import { fileIo } from '@kit.CoreFileKit'
import { Document, createDocument } from '../models/Document'
import { BusinessError } from '@kit.BasicServicesKit'
import { util } from '@kit.ArkTS'
import { SharedFileStorage } from '../entryability/EntryAbility'
import { hilog } from '@kit.PerformanceAnalysisKit'

const DOMAIN = 0x0002

// 文档服务：管理本地 Markdown 文件
export class FileService {
  private static scanning: boolean = false
  private static abortFlag: boolean = false

  // 获取沙盒目录路径
  private static getSandboxDir(): string {
    const filesDir = SharedFileStorage.getFilesDir();
    hilog.info(DOMAIN, 'testTag', '[FileService] getSandboxDir, filesDir: %{public}s', filesDir)
    if (filesDir) {
      return filesDir + '/shared';
    }
    return 'files/shared';
  }

  // 获取应用根目录
  private static getFilesDir(): string {
    const filesDir = SharedFileStorage.getFilesDir();
    if (filesDir) {
      return filesDir;
    }
    return 'files';
  }

  // 确保沙盒目录存在
  private static ensureSandboxDir(): void {
    const filesDir = FileService.getFilesDir();
    const sandboxDir = FileService.getSandboxDir();
    
    try {
      try {
        fileIo.mkdirSync(filesDir)
        const msg = '[FileService] Created files directory: ' + filesDir
        hilog.info(DOMAIN, 'testTag', '%{public}s', msg)
        FileService.writeLogToFile(msg)
      } catch (e) {
        const msg = '[FileService] files directory already exists'
        hilog.info(DOMAIN, 'testTag', '%{public}s', msg)
        FileService.writeLogToFile(msg)
      }
      
      try {
        fileIo.mkdirSync(sandboxDir)
        const msg = '[FileService] Created shared directory: ' + sandboxDir
        hilog.info(DOMAIN, 'testTag', '%{public}s', msg)
        FileService.writeLogToFile(msg)
      } catch (e) {
        const msg = '[FileService] shared directory already exists'
        hilog.info(DOMAIN, 'testTag', '%{public}s', msg)
        FileService.writeLogToFile(msg)
      }
    } catch (e) {
      const msg = '[FileService] Failed to ensure sandbox directory: ' + e
      hilog.info(DOMAIN, 'testTag', '%{public}s', msg)
      FileService.writeLogToFile(msg)
    }
  }

  // 扫描沙盒中的共享文件
  private static async scanSandboxFiles(): Promise<Document[]> {
    const docs: Document[] = []
    const sandboxDir = FileService.getSandboxDir();

    try {
      // 确保目录存在
      FileService.ensureSandboxDir()

      const files = fileIo.listFileSync(sandboxDir)
      const msg = '[FileService] Found ' + files.length + ' files in sandbox: ' + files.join(', ')
      hilog.info(DOMAIN, 'testTag', '%{public}s', msg)
      FileService.writeLogToFile(msg)
      
      for (const fileName of files) {
        if (fileName.endsWith('.md') || fileName.endsWith('.markdown')) {
          const filePath = sandboxDir + '/' + fileName
          try {
            const stat = fileIo.statSync(filePath)
            docs.push(createDocument(filePath, fileName, stat.size, stat.mtime * 1000))
            const msg = '[FileService] Added file: ' + fileName + ', size: ' + stat.size
            hilog.info(DOMAIN, 'testTag', '%{public}s', msg)
            FileService.writeLogToFile(msg)
          } catch (e) {
            const msg = '[FileService] Failed to stat ' + filePath + ': ' + e
            hilog.info(DOMAIN, 'testTag', '%{public}s', msg)
            FileService.writeLogToFile(msg)
          }
        }
      }
    } catch (err) {
      const msg = '[FileService] Failed to scan sandbox: ' + err
      hilog.info(DOMAIN, 'testTag', '%{public}s', msg)
      FileService.writeLogToFile(msg)
    }

    return docs
  }

  // 直接创建测试文件到沙盒
  private static async createTestFiles(): Promise<Document[]> {
    const docs: Document[] = []

    try {
      const msg1 = '[FileService] Starting createTestFiles'
      hilog.info(DOMAIN, 'testTag', '%{public}s', msg1)
      FileService.writeLogToFile(msg1)
      
      // 确保沙盒目录存在
      FileService.ensureSandboxDir()

      // 扫描 rawfile 目录中的所有 Markdown 文件
      // 使用应用包内的资源路径
      const rawfileDir = getContext().resourceDir + '/rawfile'
      const rawfileFiles: string[] = []
      
      try {
        const msgScanRawfile = '[FileService] Scanning rawfile directory: ' + rawfileDir
        console.log(msgScanRawfile)
        FileService.writeLogToFile(msgScanRawfile)
        
        const allFiles = fileIo.listFileSync(rawfileDir)
        for (const f of allFiles) {
          if (f.endsWith('.md') || f.endsWith('.markdown')) {
            rawfileFiles.push(f)
            const msgFound = '[FileService] Found rawfile: ' + f
            console.log(msgFound)
            FileService.writeLogToFile(msgFound)
          }
        }
        
        const msgScanResult = '[FileService] Found ' + rawfileFiles.length + ' Markdown files in rawfile'
        console.log(msgScanResult)
        FileService.writeLogToFile(msgScanResult)
      } catch (e) {
        const msgScanError = '[FileService] Failed to scan rawfile directory: ' + e
        console.log(msgScanError)
        FileService.writeLogToFile(msgScanError)
      }

      // 获取沙盒目录中的已有文件
      const sandboxFiles = new Set<string>()
      const sandboxDir = FileService.getSandboxDir()
      try {
        const msg2 = '[FileService] Listing files in sandbox directory'
        console.log(msg2)
        FileService.writeLogToFile(msg2)
        const existingFiles = fileIo.listFileSync(sandboxDir)
        const msg3 = '[FileService] Found ' + existingFiles.length + ' files in sandbox: ' + existingFiles.join(', ')
        console.log(msg3)
        FileService.writeLogToFile(msg3)
        for (const f of existingFiles) {
          if (f.endsWith('.md') || f.endsWith('.markdown')) {
            sandboxFiles.add(f)
            const msg4 = '[FileService] Sandbox has file: ' + f
            console.log(msg4)
            FileService.writeLogToFile(msg4)
          }
        }
      } catch (e) {
        const msg5 = '[FileService] Failed to list sandbox files: ' + e
        console.log(msg5)
        FileService.writeLogToFile(msg5)
      }

      // 拷贝 rawfile 中的所有 Markdown 文件到沙盒
      for (const fileName of rawfileFiles) {
        // 读取 rawfile 中的文件内容
        let content = ''
        try {
          const rawfilePath = rawfileDir + '/' + fileName
          content = fileIo.readTextSync(rawfilePath)
          const msgRead = '[FileService] Read ' + fileName + ' from rawfile, length: ' + content.length
          console.log(msgRead)
          FileService.writeLogToFile(msgRead)
        } catch (e) {
          const msgReadError = '[FileService] Failed to read ' + fileName + ' from rawfile: ' + e
          console.log(msgReadError)
          FileService.writeLogToFile(msgReadError)
          continue
        }
        
        // 删除已存在的文件以强制重新创建
        if (sandboxFiles.has(fileName)) {
          try {
            const existingFilePath = sandboxDir + '/' + fileName
            fileIo.unlinkSync(existingFilePath)
            const msgDelete = '[FileService] Deleted existing file: ' + fileName
            console.log(msgDelete)
            FileService.writeLogToFile(msgDelete)
          } catch (e) {
            // 忽略删除错误
          }
        }

        const destPath = sandboxDir + '/' + fileName

        try {
          // 写入文件到沙盒
          const msg7 = '[FileService] Creating file: ' + destPath
          console.log(msg7)
          FileService.writeLogToFile(msg7)
          const msg8 = '[FileService] File content length: ' + content.length + ' characters'
          console.log(msg8)
          FileService.writeLogToFile(msg8)
          
          const destFile = fileIo.openSync(destPath, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC)
          const msg9 = '[FileService] Opened file descriptor: ' + destFile.fd
          console.log(msg9)
          FileService.writeLogToFile(msg9)
          
          // 使用 UTF-8 编码写入文件
          const buffer = new ArrayBuffer(content.length * 3) // 预留足够空间
          const view = new Uint8Array(buffer)
          let offset = 0
          
          for (let j = 0; j < content.length; j++) {
            const code = content.charCodeAt(j)
            if (code < 0x80) {
              // 单字节 ASCII
              view[offset++] = code
            } else if (code < 0x800) {
              // 双字节 UTF-8
              view[offset++] = 0xC0 | (code >> 6)
              view[offset++] = 0x80 | (code & 0x3F)
            } else if (code < 0x10000) {
              // 三字节 UTF-8（中文常用）
              view[offset++] = 0xE0 | (code >> 12)
              view[offset++] = 0x80 | ((code >> 6) & 0x3F)
              view[offset++] = 0x80 | (code & 0x3F)
            } else {
              // 四字节 UTF-8
              view[offset++] = 0xF0 | (code >> 18)
              view[offset++] = 0x80 | ((code >> 12) & 0x3F)
              view[offset++] = 0x80 | ((code >> 6) & 0x3F)
              view[offset++] = 0x80 | (code & 0x3F)
            }
          }
          
          // 调整缓冲区大小
          const actualBuffer = new ArrayBuffer(offset)
          const actualView = new Uint8Array(actualBuffer)
          for (let i = 0; i < offset; i++) {
            actualView[i] = view[i]
          }
          
          const bytesWritten = fileIo.writeSync(destFile.fd, actualBuffer)
          const msg10 = '[FileService] Wrote ' + bytesWritten + ' bytes to file'
          console.log(msg10)
          FileService.writeLogToFile(msg10)
          
          fileIo.closeSync(destFile)
          const msg11 = '[FileService] Closed file descriptor'
          console.log(msg11)
          FileService.writeLogToFile(msg11)
          
          const msg12 = '[FileService] Created ' + fileName + ' in sandbox'
          console.log(msg12)
          FileService.writeLogToFile(msg12)

          const stat = fileIo.statSync(destPath)
          const msg13 = '[FileService] Created file size: ' + stat.size + ' bytes'
          console.log(msg13)
          FileService.writeLogToFile(msg13)
          const msg14 = '[FileService] Created file mtime: ' + stat.mtime
          console.log(msg14)
          FileService.writeLogToFile(msg14)
          
          const doc = createDocument(destPath, fileName, stat.size, stat.mtime * 1000)
          docs.push(doc)
          const msg15 = '[FileService] Added document to list: ' + fileName
          console.log(msg15)
          FileService.writeLogToFile(msg15)
        } catch (e) {
          const msg16 = '[FileService] Failed to create ' + fileName + ': ' + e
          console.log(msg16)
          FileService.writeLogToFile(msg16)
        }
      }
    } catch (err) {
      const msg17 = '[FileService] Failed to create test files: ' + err
      console.log(msg17)
      FileService.writeLogToFile(msg17)
    }

    const msg18 = '[FileService] createTestFiles completed, created ' + docs.length + ' files'
    console.log(msg18)
    FileService.writeLogToFile(msg18)
    return docs
  }

  // 首次安装时从 rawfile 拷贝 md 文件到沙盒
  private static async copyRawFilesToSandbox(context: Context): Promise<Document[]> {
    const docs: Document[] = []

    try {
      hilog.info(DOMAIN, 'testTag', '%{public}s', '[FileService] Starting copyRawFilesToSandbox')
      
      FileService.ensureSandboxDir()

      const sandboxDir = FileService.getSandboxDir()
      
      // 使用 resourceManager 获取 rawfile 列表
      hilog.info(DOMAIN, 'testTag', '%{public}s', '[FileService] Getting rawfile list from resourceManager')
      const rawFileList: string[] = await context.resourceManager.getRawFileList('')
      hilog.info(DOMAIN, 'testTag', '[FileService] Rawfile list: %{public}s', rawFileList.join(', '))
      
      const rawfileFiles = rawFileList.filter((f: string) => f.endsWith('.md') || f.endsWith('.markdown'))
      
      hilog.info(DOMAIN, 'testTag', '[FileService] Found %{public}d md files in rawfile', rawfileFiles.length)

      for (const fileName of rawfileFiles) {
        try {
          const destPath = sandboxDir + '/' + fileName
          
          hilog.info(DOMAIN, 'testTag', '[FileService] Reading rawfile: %{public}s', fileName)
          // 使用 resourceManager.getRawFileContent 读取 rawfile
          const rawFileContent: Uint8Array = await context.resourceManager.getRawFileContent(fileName)
          hilog.info(DOMAIN, 'testTag', '[FileService] Rawfile content length: %{public}d', rawFileContent.length)
          
          // 直接将原始字节写入沙盒（保持 UTF-8 编码）
          const destFile = fileIo.openSync(destPath, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC)
          // 使用 slice 获取正确的 ArrayBuffer 部分
          const buffer = rawFileContent.buffer.slice(rawFileContent.byteOffset, rawFileContent.byteOffset + rawFileContent.byteLength)
          fileIo.writeSync(destFile.fd, buffer)
          fileIo.closeSync(destFile)
          
          const stat = fileIo.statSync(destPath)
          docs.push(createDocument(destPath, fileName, stat.size, stat.mtime * 1000))
          
          hilog.info(DOMAIN, 'testTag', '[FileService] Copied %{public}s (%{public}d bytes)', fileName, stat.size)
        } catch (e) {
          hilog.error(DOMAIN, 'testTag', '[FileService] Failed to copy %{public}s: %{public}s', fileName, JSON.stringify(e))
        }
      }
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', '[FileService] copyRawFilesToSandbox failed: %{public}s', JSON.stringify(err))
    }

    hilog.info(DOMAIN, 'testTag', '[FileService] copyRawFilesToSandbox completed, copied %{public}d files', docs.length)
    return docs
  }

  // 扫描指定目录下的 Markdown 文件
  static async scanDirectory(context: Context): Promise<Document[]> {
    if (FileService.scanning) {
      throw new Error('已有扫描任务进行中')
    }

    FileService.scanning = true
    FileService.abortFlag = false

    try {
      hilog.info(DOMAIN, 'testTag', '%{public}s', '[FileService] Starting scanDirectory')
      
      // 扫描沙盒中的现有文件
      const sandboxDocs = await FileService.scanSandboxFiles()
      hilog.info(DOMAIN, 'testTag', '[FileService] Found %{public}d files in sandbox', sandboxDocs.length)

      // 如果沙盒中没有 md 文件，从 rawfile 拷贝
      if (sandboxDocs.length === 0) {
        hilog.info(DOMAIN, 'testTag', '%{public}s', '[FileService] No files in sandbox, copying from rawfile')
        
        const copiedDocs = await FileService.copyRawFilesToSandbox(context)
        hilog.info(DOMAIN, 'testTag', '[FileService] Copied %{public}d files from rawfile', copiedDocs.length)
      } else {
        hilog.info(DOMAIN, 'testTag', '%{public}s', '[FileService] Files already exist in sandbox, skipping copy')
      }

      // 重新扫描沙盒获取所有文件
      const allDocs = await FileService.scanSandboxFiles()
      hilog.info(DOMAIN, 'testTag', '[FileService] Total files: %{public}d', allDocs.length)

      return allDocs
    } finally {
      FileService.scanning = false
    }
  }

  static abortScan() {
    FileService.abortFlag = true
  }

  static isScanning(): boolean {
    return FileService.scanning
  }

  // 读取文件内容
  static async readFileContent(path: string): Promise<string> {
    try {
      const content = fileIo.readTextSync(path)
      return content
    } catch (e) {
      console.log('[FileService] Failed to read file ' + path + ': ' + e)
      return ''
    }
  }

  // 删除文件
  static async deleteFile(path: string): Promise<boolean> {
    return new Promise((resolve) => {
      try {
        fileIo.unlinkSync(path)
        console.log('[FileService] Deleted file: ' + path)
        resolve(true)
      } catch (e) {
        console.log('[FileService] Failed to delete ' + path + ': ' + e)
        resolve(false)
      }
    })
  }

  // 格式化文件大小
  static formatFileSize(bytes: number): string {
    if (bytes < 1024) return bytes + ' B'
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB'
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB'
  }

  // 格式化时间
  static formatTime(timestamp: number): string {
    const date = new Date(timestamp)
    const now = new Date()
    const diff = now.getTime() - date.getTime()
    
    if (diff < 60000) return '刚刚'
    if (diff < 3600000) return Math.floor(diff / 60000) + ' 分钟前'
    if (diff < 86400000) return Math.floor(diff / 3600000) + ' 小时前'
    
    return `${date.getMonth() + 1}/${date.getDate()}`
  }

  // 写入日志到文件
  static writeLogToFile(message: string): void {
    try {
      const sandboxDir = FileService.getSandboxDir()
      const logFilePath = sandboxDir + '/app.log'
      const timestamp = new Date().toISOString()
      const logEntry = '[' + timestamp + '] ' + message + '\n'
      
      // 确保目录存在
      try {
        const filesDir = FileService.getFilesDir()
        fileIo.mkdirSync(filesDir)
        fileIo.mkdirSync(sandboxDir)
      } catch (e) {
        // 目录已存在，忽略错误
      }
      
      // 追加写入日志
      const file = fileIo.openSync(logFilePath, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE | fileIo.OpenMode.APPEND)
      const buffer = new ArrayBuffer(logEntry.length)
      const view = new Uint8Array(buffer)
      for (let i = 0; i < logEntry.length; i++) {
        view[i] = logEntry.charCodeAt(i)
      }
      fileIo.writeSync(file.fd, buffer)
      fileIo.closeSync(file)
    } catch (e) {
      // 日志写入失败，不影响主流程
      console.log('[FileService] Failed to write log to file: ' + e)
    }
  }
}