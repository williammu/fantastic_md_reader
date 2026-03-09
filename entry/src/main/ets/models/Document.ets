// 文档数据模型
export interface Document {
  id: string           // 唯一标识（文件路径的 MD5）
  name: string         // 文件名
  path: string         // 完整路径
  source: 'local' | 'cloud'  // 来源
  lastOpenTime: number // 最后打开时间戳
  readingPosition: number    // 阅读字符偏移量
  ttsParagraph: number       // 朗读段落索引
  ttsProgress: number        // 朗读进度 0-100
  isFavorite: boolean        // 是否收藏
  tags: string[]             // 标签列表
  size: number               // 文件大小（字节）
  modifyTime: number         // 文件修改时间
}

// 阅读进度模型
export interface ReadingProgress {
  documentId: string   // 文档ID
  charOffset: number   // 字符位置
  ttsParagraph: number // 朗读段落
  ttsProgress: number  // 朗读进度 0-100
  updatedAt: number    // 更新时间
}

// 创建 Document 的辅助函数
export function createDocument(path: string, name: string, size: number, modifyTime: number): Document {
  // 简单ID生成：使用路径的 hash
  const id = hashString(path)
  return {
    id,
    name,
    path,
    source: 'local',
    lastOpenTime: Date.now(),
    readingPosition: 0,
    ttsParagraph: 0,
    ttsProgress: 0,
    isFavorite: false,
    tags: [],
    size,
    modifyTime
  }
}

// 简单的字符串 hash 函数
export function hashString(str: string): string {
  let hash = 0
  for (let i = 0; i < str.length; i++) {
    const char = str.charCodeAt(i)
    hash = ((hash << 5) - hash) + char
    hash = hash & hash
  }
  return Math.abs(hash).toString(16).padStart(8, '0')
}