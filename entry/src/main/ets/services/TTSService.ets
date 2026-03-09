// 朗读服务接口（阶段四完整实现预留）
// 当前仅提供接口定义和模拟实现

import { TTSSettings, getDefaultTTSSettings } from '../utils/StorageService'

// 朗读状态
export enum TTSState {
  IDLE = 'idle',       // 空闲
  PLAYING = 'playing', // 播放中
  PAUSED = 'paused'    // 暂停
}

// 朗读服务类（接口定义）
export class TTSService {
  private static instance: TTSService | null = null
  
  // 当前状态
  private state: TTSState = TTSState.IDLE
  private currentParagraph: number = 0
  private totalParagraphs: number = 0
  private paragraphs: string[] = []
  private settings: TTSSettings = getDefaultTTSSettings()
  
  // 回调函数
  private onStateChangeCallback: ((state: TTSState) => void) | null = null
  private onProgressCallback: ((paragraph: number, total: number) => void) | null = null
  private onCompleteCallback: (() => void) | null = null
  
  // 获取单例
  static getInstance(): TTSService {
    if (TTSService.instance === null) {
      TTSService.instance = new TTSService()
    }
    return TTSService.instance
  }
  
  private constructor() {
    // TODO: 初始化 TTS 引擎
    console.log('TTSService: 初始化（接口预留）')
  }
  
  // ========== 核心控制接口 ==========
  
  /**
   * 开始朗读
   * @param content Markdown 内容
   * @param fromParagraph 从第几段开始（默认0）
   */
  async start(content: string, fromParagraph: number = 0): Promise<void> {
    console.log(`TTSService.start: 从第${fromParagraph}段开始朗读（接口预留）`)
    
    // TODO: 实现 TTS 引擎调用
    // 1. 分割段落
    this.paragraphs = TTSService.splitParagraphs(content)
    this.totalParagraphs = this.paragraphs.length
    this.currentParagraph = fromParagraph
    
    // 2. 更新状态
    this.state = TTSState.PLAYING
    TTSService.notifyStateChange(this)
    
    // 3. 开始播放（模拟）
    TTSService.notifyProgress(this)
  }
  
  /**
   * 暂停朗读
   */
  pause(): void {
    console.log('TTSService.pause: 暂停朗读（接口预留）')
    if (this.state === TTSState.PLAYING) {
      this.state = TTSState.PAUSED
      TTSService.notifyStateChange(this)
    }
  }
  
  /**
   * 继续朗读
   */
  resume(): void {
    console.log('TTSService.resume: 继续朗读（接口预留）')
    if (this.state === TTSState.PAUSED) {
      this.state = TTSState.PLAYING
      TTSService.notifyStateChange(this)
    }
  }
  
  /**
   * 停止朗读
   */
  stop(): void {
    console.log('TTSService.stop: 停止朗读（接口预留）')
    this.state = TTSState.IDLE
    this.currentParagraph = 0
    TTSService.notifyStateChange(this)
  }
  
  /**
   * 跳转到指定段落
   */
  seekTo(paragraphIndex: number): void {
    console.log(`TTSService.seekTo: 跳转到第${paragraphIndex}段（接口预留）`)
    if (paragraphIndex >= 0 && paragraphIndex < this.totalParagraphs) {
      this.currentParagraph = paragraphIndex
      TTSService.notifyProgress(this)
    }
  }
  
  // ========== 状态查询接口 ==========
  
  /**
   * 获取当前状态
   */
  getState(): TTSState {
    return this.state
  }
  
  /**
   * 获取当前段落索引
   */
  getCurrentParagraph(): number {
    return this.currentParagraph
  }
  
  /**
   * 获取总段落数
   */
  getTotalParagraphs(): number {
    return this.totalParagraphs
  }
  
  /**
   * 获取当前播放进度（0-100）
   */
  getProgress(): number {
    if (this.totalParagraphs === 0) return 0
    return Math.floor((this.currentParagraph / this.totalParagraphs) * 100)
  }
  
  /**
   * 是否在播放中
   */
  isPlaying(): boolean {
    return this.state === TTSState.PLAYING
  }
  
  /**
   * 是否已暂停
   */
  isPaused(): boolean {
    return this.state === TTSState.PAUSED
  }
  
  // ========== 设置接口 ==========
  
  /**
   * 设置语速（0.5 - 2.0）
   */
  setSpeed(speed: number): void {
    this.settings.speed = Math.max(0.5, Math.min(2.0, speed))
    console.log(`TTSService.setSpeed: ${this.settings.speed}（接口预留）`)
  }
  
  /**
   * 获取当前语速
   */
  getSpeed(): number {
    return this.settings.speed
  }
  
  /**
   * 设置音色
   */
  setVoice(voice: 'male' | 'female' | 'custom'): void {
    this.settings.voice = voice
    console.log(`TTSService.setVoice: ${voice}（接口预留）`)
  }
  
  /**
   * 获取当前音色
   */
  getVoice(): 'male' | 'female' | 'custom' {
    return this.settings.voice
  }
  
  /**
   * 设置音量（0 - 1）
   */
  setVolume(volume: number): void {
    this.settings.volume = Math.max(0, Math.min(1, volume))
    console.log(`TTSService.setVolume: ${this.settings.volume}（接口预留）`)
  }
  
  /**
   * 获取音量
   */
  getVolume(): number {
    return this.settings.volume
  }
  
  /**
   * 获取所有设置
   */
  getSettings(): TTSSettings {
    return {
      speed: this.settings.speed,
      pitch: this.settings.pitch,
      volume: this.settings.volume,
      voice: this.settings.voice,
      autoScroll: this.settings.autoScroll,
      highlightSentence: this.settings.highlightSentence,
      sleepTimer: this.settings.sleepTimer
    }
  }
  
  /**
   * 更新所有设置
   */
  updateSettings(settings: TTSSettings): void {
    this.settings.speed = settings.speed !== undefined ? settings.speed : this.settings.speed
    this.settings.pitch = settings.pitch !== undefined ? settings.pitch : this.settings.pitch
    this.settings.volume = settings.volume !== undefined ? settings.volume : this.settings.volume
    this.settings.voice = settings.voice !== undefined ? settings.voice : this.settings.voice
    this.settings.autoScroll = settings.autoScroll !== undefined ? settings.autoScroll : this.settings.autoScroll
    this.settings.highlightSentence = settings.highlightSentence !== undefined ? settings.highlightSentence : this.settings.highlightSentence
    this.settings.sleepTimer = settings.sleepTimer !== undefined ? settings.sleepTimer : this.settings.sleepTimer
    console.log('TTSService.updateSettings: 设置已更新（接口预留）')
  }
  
  // ========== 回调注册 ==========
  
  /**
   * 注册状态变化回调
   */
  onStateChange(callback: (state: TTSState) => void): void {
    this.onStateChangeCallback = callback
  }
  
  /**
   * 注册进度变化回调
   */
  onProgress(callback: (paragraph: number, total: number) => void): void {
    this.onProgressCallback = callback
  }
  
  /**
   * 注册播放完成回调
   */
  onComplete(callback: () => void): void {
    this.onCompleteCallback = callback
  }
  
  // ========== 后台播放接口（预留） ==========
  
  /**
   * 启用后台播放
   */
  enableBackgroundPlayback(): void {
    console.log('TTSService.enableBackgroundPlayback: 启用后台播放（接口预留）')
  }
  
  /**
   * 禁用后台播放
   */
  disableBackgroundPlayback(): void {
    console.log('TTSService.disableBackgroundPlayback: 禁用后台播放（接口预留）')
  }
  
  /**
   * 创建通知栏控制
   */
  createNotification(): void {
    console.log('TTSService.createNotification: 创建通知栏控制（接口预留）')
  }
  
  // ========== 私有方法 ==========
  
  /**
   * 分割段落
   */
  private static splitParagraphs(content: string): string[] {
    return content
      .split(/\n\n+/)
      .map((p: string) => p.trim())
      .filter((p: string) => p.length > 0)
  }
  
  /**
   * 通知状态变化
   */
  private static notifyStateChange(instance: TTSService): void {
    if (instance.onStateChangeCallback) {
      instance.onStateChangeCallback(instance.state)
    }
  }
  
  /**
   * 通知进度变化
   */
  private static notifyProgress(instance: TTSService): void {
    if (instance.onProgressCallback) {
      instance.onProgressCallback(instance.currentParagraph, instance.totalParagraphs)
    }
  }
}

// 导出单例实例
export const ttsService: TTSService = TTSService.getInstance()