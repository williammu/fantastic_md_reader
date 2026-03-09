import { fileIo } from '@kit.CoreFileKit'
import { Document, createDocument } from '../models/Document'
import { BusinessError } from '@kit.BasicServicesKit'
import { util } from '@kit.ArkTS'
import { SharedFileStorage } from '../entryability/EntryAbility'

// 文档服务：管理本地 Markdown 文件
export class FileService {
  private static scanning: boolean = false
  private static abortFlag: boolean = false

  // 获取沙盒目录路径
  private static getSandboxDir(): string {
    const filesDir = SharedFileStorage.getFilesDir();
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
        console.log(msg)
        FileService.writeLogToFile(msg)
      } catch (e) {
        const msg = '[FileService] files directory already exists'
        console.log(msg)
        FileService.writeLogToFile(msg)
      }
      
      try {
        fileIo.mkdirSync(sandboxDir)
        const msg = '[FileService] Created shared directory: ' + sandboxDir
        console.log(msg)
        FileService.writeLogToFile(msg)
      } catch (e) {
        const msg = '[FileService] shared directory already exists'
        console.log(msg)
        FileService.writeLogToFile(msg)
      }
    } catch (e) {
      const msg = '[FileService] Failed to ensure sandbox directory: ' + e
      console.log(msg)
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
      console.log(msg)
      FileService.writeLogToFile(msg)
      
      for (const fileName of files) {
        if (fileName.endsWith('.md') || fileName.endsWith('.markdown')) {
          const filePath = sandboxDir + '/' + fileName
          try {
            const stat = fileIo.statSync(filePath)
            docs.push(createDocument(filePath, fileName, stat.size, stat.mtime * 1000))
            const msg = '[FileService] Added file: ' + fileName + ', size: ' + stat.size
            console.log(msg)
            FileService.writeLogToFile(msg)
          } catch (e) {
            const msg = '[FileService] Failed to stat ' + filePath + ': ' + e
            console.log(msg)
            FileService.writeLogToFile(msg)
          }
        }
      }
    } catch (err) {
      const msg = '[FileService] Failed to scan sandbox: ' + err
      console.log(msg)
      FileService.writeLogToFile(msg)
    }

    return docs
  }

  // 直接创建测试文件到沙盒
  private static async createTestFiles(): Promise<Document[]> {
    const docs: Document[] = []

    try {
      const msg1 = '[FileService] Starting createTestFiles'
      console.log(msg1)
      FileService.writeLogToFile(msg1)
      
      // 确保沙盒目录存在
      FileService.ensureSandboxDir()

      // 测试文件内容
      const anchorTestContent = "# 锚点跳转测试文档\n\n> 测试时间：2026年3月8日\n> 用于测试 Markdown 中的目录链接跳转功能\n\n---\n\n## 目录\n\n1. [第一节：测试概述](#第一节测试概述)\n2. [第二节：问题描述](#第二节问题描述)\n3. [第三节：解决方案](#第三节解决方案)\n4. [第四节：测试结果](#第四节测试结果)\n\n---\n\n## 第一节：测试概述\n\n这是第一个章节的内容。点击上面的目录链接应该能够跳转到本章节。\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\n\n### 1.1 测试目的\n\n验证 Markdown 文档中的目录链接能够正确跳转到对应的章节。\n\n### 1.2 测试环境\n\n- 设备：HarmonyOS\n- 应用：MD Reader\n- 测试日期：2026年3月8日\n\n---\n\n## 第二节：问题描述\n\n这是第二个章节的内容。之前目录链接点击后没有反应，经过多轮调试发现以下问题：\n\n### 2.1 问题一：空格处理\n\n原始目录链接格式：\n\`\`\`\n[第一节：测试概述](#第一节测试概述)\n\`\`\`\n\n部分文档中可能包含空格：\n\`\`\`\n[第一节：测试概述](#第一节测试概述 )\n\`\`\`\n\n### 2.2 问题二：大小写不匹配\n\n标题 ID 会被转换为小写：\n- 标题：`## 第一节：测试概述`\n- 生成 ID：`#第一节测试概述`（小写）\n- 目录链接：`#第一节测试概述`（原始大小写）\n\n---\n\n## 第三节：解决方案\n\n这是第三个章节的内容。针对上述问题，采用了以下解决方案：\n\n### 3.1 修复空格处理\n\n修改正则表达式，支持 # 号前后有空格的情况：\n\`\`\`javascript\n/\\[([^\\]]+)\\]\\(\\s*(#\\S+)\\s*\\)/g\n\`\`\`\n\n### 3.2 修复大小写匹配\n\n在 JavaScript 中将锚点 ID 转换为小写：\n\`\`\`javascript\nvar anchorId = href.substring(hashIndex + 1).toLowerCase();\n\`\`\`\n\n---\n\n## 第四节：测试结果\n\n这是第四个章节的内容。测试结果如下：\n\n### 4.1 通过的测试项\n\n- ✅ 目录链接点击跳转\n- ✅ 标题 ID 生成\n- ✅ 空格处理\n- ✅ 大小写匹配\n\n### 4.2 待验证\n\n- [ ] 不同格式的锚点链接\n- [ ] 嵌套目录\n- [ ] 特殊字符处理\n\n---\n\n## 总结\n\n本文档用于测试 Markdown 目录链接跳转功能。通过点击上方的目录链接，可以快速跳转到对应的章节。"
      
      const testCaseContent = "# 测试用例文档\n\n## 基本测试\n\n- 测试 1: 基本功能\n- 测试 2: 性能测试\n- 测试 3: 兼容性测试\n\n## 高级测试\n\n- 测试 4: 边界情况\n- 测试 5: 安全测试"
      
      // 测试文件列表
      const testFileNames = ['anchor_test.md', 'test_case.md']
      const testFileContents = [anchorTestContent, testCaseContent]

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

      // 创建测试文件
      for (let i = 0; i < testFileNames.length; i++) {
        const fileName = testFileNames[i]
        const content = testFileContents[i]
        
        if (sandboxFiles.has(fileName)) {
          const msg6 = '[FileService] Skipping ' + fileName + ', already exists in sandbox'
          console.log(msg6)
          FileService.writeLogToFile(msg6)
          continue
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

  // 扫描指定目录下的 Markdown 文件
  static async scanDirectory(): Promise<Document[]> {
    if (FileService.scanning) {
      throw new Error('已有扫描任务进行中')
    }

    FileService.scanning = true
    FileService.abortFlag = false

    try {
      const msg1 = '[FileService] Starting scanDirectory'
      console.log(msg1)
      FileService.writeLogToFile(msg1)
      
      // 扫描沙盒中的共享文件
      const sandboxDocs = await FileService.scanSandboxFiles()
      const msg2 = '[FileService] Found ' + sandboxDocs.length + ' files in sandbox'
      console.log(msg2)
      FileService.writeLogToFile(msg2)

      // 创建测试文件到沙盒
      const testDocs = await FileService.createTestFiles()
      const msg3 = '[FileService] Created ' + testDocs.length + ' test files'
      console.log(msg3)
      FileService.writeLogToFile(msg3)

      // 重新扫描沙盒获取所有文件
      const allDocs = await FileService.scanSandboxFiles()
      const msg4 = '[FileService] Total files: ' + allDocs.length
      console.log(msg4)
      FileService.writeLogToFile(msg4)

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