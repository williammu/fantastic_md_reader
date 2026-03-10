import { preferences } from '@kit.ArkData'
import { Document, ReadingProgress } from '../models/Document'

// 存储键名
const KEY_RECENT_DOCS: string = 'recent_documents'
const KEY_FAVORITE_DOCS: string = 'favorite_documents'
const KEY_TTS_SETTINGS: string = 'tts_settings'
const KEY_FIRST_INSTALL: string = 'first_install_done'

// 用户偏好存储服务
export class StorageService {
  private static pref: preferences.Preferences | null = null
  
  // 初始化存储
  static init(context: Context) {
    const options: preferences.Options = { name: 'md_reader_pref' }
    StorageService.pref = preferences.getPreferencesSync(context, options)
  }
  
  // ========== 最近阅读 ==========
  
  // 获取最近阅读列表（最多20条）
  static getRecentDocuments(): Document[] {
    if (StorageService.pref === null) return []
    const json: string = StorageService.pref.getSync(KEY_RECENT_DOCS, '[]') as string
    try {
      const docs: Document[] = JSON.parse(json) as Document[]
      // 按时间倒序
      return docs.sort((a: Document, b: Document) => b.lastOpenTime - a.lastOpenTime).slice(0, 20)
    } catch {
      return []
    }
  }
  
  // 添加/更新最近阅读
  static addRecentDocument(doc: Document) {
    if (StorageService.pref === null) return
    const docs: Document[] = StorageService.getRecentDocuments()
    // 移除已存在的
    const filtered: Document[] = docs.filter((d: Document) => d.id !== doc.id)
    // 创建新对象并添加到开头
    const newDoc: Document = {
      id: doc.id,
      name: doc.name,
      path: doc.path,
      source: doc.source,
      lastOpenTime: Date.now(),
      readingPosition: doc.readingPosition,
      ttsParagraph: doc.ttsParagraph,
      ttsProgress: doc.ttsProgress,
      isFavorite: doc.isFavorite,
      tags: doc.tags,
      size: doc.size,
      modifyTime: doc.modifyTime
    }
    filtered.unshift(newDoc)
    // 只保留20条
    const result: Document[] = filtered.slice(0, 20)
    StorageService.pref.putSync(KEY_RECENT_DOCS, JSON.stringify(result))
  }
  
  // 清空最近阅读
  static clearRecentDocuments() {
    if (StorageService.pref === null) return
    StorageService.pref.putSync(KEY_RECENT_DOCS, '[]')
  }
  
  // 删除单条最近记录
  static removeRecentDocument(docId: string) {
    if (StorageService.pref === null) return
    const docs: Document[] = StorageService.getRecentDocuments()
    const filtered: Document[] = docs.filter((d: Document) => d.id !== docId)
    StorageService.pref.putSync(KEY_RECENT_DOCS, JSON.stringify(filtered))
  }
  
  // ========== 收藏 ==========
  
  // 获取收藏列表
  static getFavoriteDocuments(): Document[] {
    if (StorageService.pref === null) return []
    const json: string = StorageService.pref.getSync(KEY_FAVORITE_DOCS, '[]') as string
    try {
      return JSON.parse(json) as Document[]
    } catch {
      return []
    }
  }
  
  // 切换收藏状态
  static toggleFavorite(doc: Document): boolean {
    if (StorageService.pref === null) return false
    const favorites: Document[] = StorageService.getFavoriteDocuments()
    let index: number = -1
    for (let i: number = 0; i < favorites.length; i++) {
      if (favorites[i].id === doc.id) {
        index = i
        break
      }
    }
    let isFavorite: boolean
    
    if (index >= 0) {
      // 取消收藏
      favorites.splice(index, 1)
      isFavorite = false
    } else {
      // 添加收藏
      const favDoc: Document = {
        id: doc.id,
        name: doc.name,
        path: doc.path,
        source: doc.source,
        lastOpenTime: doc.lastOpenTime,
        readingPosition: doc.readingPosition,
        ttsParagraph: doc.ttsParagraph,
        ttsProgress: doc.ttsProgress,
        isFavorite: true,
        tags: doc.tags,
        size: doc.size,
        modifyTime: doc.modifyTime
      }
      favorites.push(favDoc)
      isFavorite = true
    }
    
    StorageService.pref.putSync(KEY_FAVORITE_DOCS, JSON.stringify(favorites))
    return isFavorite
  }
  
  // 检查是否已收藏
  static isFavorite(docId: string): boolean {
    const favorites: Document[] = StorageService.getFavoriteDocuments()
    for (const d of favorites) {
      if (d.id === docId) {
        return true
      }
    }
    return false
  }
  
  // ========== 阅读进度 ==========
  
  // 保存阅读进度
  static saveReadingProgress(docId: string, progress: ReadingProgress) {
    if (StorageService.pref === null) return
    const key: string = 'reading_progress_' + docId
    StorageService.pref.putSync(key, JSON.stringify(progress))
  }
  
  // 获取阅读进度
  static getReadingProgress(docId: string): ReadingProgress | null {
    if (StorageService.pref === null) return null
    const key: string = 'reading_progress_' + docId
    const json: string = StorageService.pref.getSync(key, '') as string
    if (json.length === 0) return null
    try {
      return JSON.parse(json) as ReadingProgress
    } catch {
      return null
    }
  }
  
  // 删除阅读进度
  static deleteReadingProgress(docId: string) {
    if (StorageService.pref === null) return
    const key: string = 'reading_progress_' + docId
    StorageService.pref.deleteSync(key)
  }
  
  // ========== TTS 设置 ==========
  
  // 获取 TTS 设置
  static getTTSSettings(): TTSSettings {
    if (StorageService.pref === null) return getDefaultTTSSettings()
    const json: string = StorageService.pref.getSync(KEY_TTS_SETTINGS, '') as string
    if (json.length === 0) return getDefaultTTSSettings()
    try {
      const saved: TTSSettings = JSON.parse(json) as TTSSettings
      // 手动合并默认值
      const defaults: TTSSettings = getDefaultTTSSettings()
      return {
        speed: saved.speed !== undefined ? saved.speed : defaults.speed,
        pitch: saved.pitch !== undefined ? saved.pitch : defaults.pitch,
        volume: saved.volume !== undefined ? saved.volume : defaults.volume,
        voice: saved.voice !== undefined ? saved.voice : defaults.voice,
        autoScroll: saved.autoScroll !== undefined ? saved.autoScroll : defaults.autoScroll,
        highlightSentence: saved.highlightSentence !== undefined ? saved.highlightSentence : defaults.highlightSentence,
        sleepTimer: saved.sleepTimer !== undefined ? saved.sleepTimer : defaults.sleepTimer
      }
    } catch {
      return getDefaultTTSSettings()
    }
  }
  
  // 保存 TTS 设置
  static saveTTSSettings(settings: TTSSettings) {
    if (StorageService.pref === null) return
    StorageService.pref.putSync(KEY_TTS_SETTINGS, JSON.stringify(settings))
  }
  
  // ========== 字体大小设置 ==========
  private static readonly KEY_FONT_SIZE: string = 'reader_font_size'
  private static readonly DEFAULT_FONT_SIZE: number = 18  // 默认18sp
  
  static getFontSize(): number {
    if (StorageService.pref === null) return StorageService.DEFAULT_FONT_SIZE
    const size: number = StorageService.pref.getSync(StorageService.KEY_FONT_SIZE, StorageService.DEFAULT_FONT_SIZE) as number
    return size > 0 ? size : StorageService.DEFAULT_FONT_SIZE
  }
  
  static setFontSize(size: number) {
    if (StorageService.pref === null) return
    StorageService.pref.putSync(StorageService.KEY_FONT_SIZE, size)
    // 同时更新内存中的值
    AppStorage.setOrCreate('reader_font_size_val', size)
  }

  // ========== 首次安装检测 ==========

  static isFirstInstall(): boolean {
    if (StorageService.pref === null) return true
    const value: string = StorageService.pref.getSync(KEY_FIRST_INSTALL, '') as string
    return value !== 'true'
  }

  static setFirstInstallDone(): void {
    if (StorageService.pref === null) return
    StorageService.pref.putSync(KEY_FIRST_INSTALL, 'true')
  }
}

// TTS 设置接口
export interface TTSSettings {
  speed: number
  pitch: number
  volume: number
  voice: 'male' | 'female' | 'custom'
  autoScroll: boolean
  highlightSentence: boolean
  sleepTimer: number
}

// 默认 TTS 设置
export function getDefaultTTSSettings(): TTSSettings {
  return {
    speed: 1.0,
    pitch: 1.0,
    volume: 1.0,
    voice: 'female',
    autoScroll: true,
    highlightSentence: true,
    sleepTimer: 0
  }
}