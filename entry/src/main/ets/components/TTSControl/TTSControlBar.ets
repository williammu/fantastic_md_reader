import { TTSState, ttsService } from '../../services/TTSService'
import { ThemeColors } from '../../models/Theme'

// 朗读控制条组件（接口版）
@Component
export struct TTSControlBar {
  @Prop themeColors: ThemeColors
  @State isExpanded: boolean = false
  @State ttsState: TTSState = TTSState.IDLE
  @State currentParagraph: number = 0
  @State totalParagraphs: number = 0
  @State progress: number = 0  // 0-100
  
  // 播放/暂停切换
  private togglePlay() {
    if (this.ttsState === TTSState.PLAYING) {
      ttsService.pause()
    } else if (this.ttsState === TTSState.PAUSED) {
      ttsService.resume()
    } else {
      // 需要外部传入内容才能开始
      console.log('TTSControlBar: 需要先调用 start 方法传入内容')
    }
    this.syncState()
  }
  
  // 停止
  private stop() {
    ttsService.stop()
    this.syncState()
  }
  
  // 同步状态
  private syncState() {
    this.ttsState = ttsService.getState()
    this.currentParagraph = ttsService.getCurrentParagraph()
    this.totalParagraphs = ttsService.getTotalParagraphs()
    this.progress = ttsService.getProgress()
  }
  
  aboutToAppear() {
    // 注册状态监听
    ttsService.onStateChange((state: TTSState) => {
      this.ttsState = state
    })
    ttsService.onProgress((current: number, total: number) => {
      this.currentParagraph = current
      this.totalParagraphs = total
      this.progress = total > 0 ? Math.floor((current / total) * 100) : 0
    })
    this.syncState()
  }
  
  build() {
    Column() {
      // 迷你模式
      Row() {
        // 播放/暂停按钮
        Button(this.getPlayButtonIcon())
          .fontSize(24)
          .backgroundColor(Color.Transparent)
          .fontColor(this.themeColors.primary)
          .width(48)
          .height(48)
          .onClick(() => this.togglePlay())
        
        // 段落信息
        Column() {
          Text(`${this.currentParagraph + 1} / ${this.totalParagraphs}`)
            .fontSize(14)
            .fontColor(this.themeColors.textSecondary)
          
          // 进度条
          Slider({
            value: this.progress,
            min: 0,
            max: 100
          })
          .width('100%')
          .height(20)
          .blockColor(this.themeColors.primary)
          .trackColor(this.themeColors.divider)
          .selectedColor(this.themeColors.primary)
          .onChange((value: number) => {
            // 计算对应的段落
            if (this.totalParagraphs > 0) {
              const targetParagraph: number = Math.floor((value / 100) * this.totalParagraphs)
              ttsService.seekTo(targetParagraph)
            }
          })
        }
        .layoutWeight(1)
        .margin({ left: 8, right: 8 })
        
        // 停止按钮
        Button('⏹')
          .fontSize(20)
          .backgroundColor(Color.Transparent)
          .fontColor(this.themeColors.textTertiary)
          .width(44)
          .height(44)
          .onClick(() => this.stop())
        
        // 展开按钮
        Button(this.isExpanded ? '▼' : '▲')
          .fontSize(16)
          .backgroundColor(Color.Transparent)
          .fontColor(this.themeColors.textTertiary)
          .width(44)
          .height(44)
          .onClick(() => {
            this.isExpanded = !this.isExpanded
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 12, right: 12 })
      
      // 展开模式 - 更多设置
      if (this.isExpanded) {
        Column() {
          // 语速调节
          Row() {
            Text('语速')
              .fontSize(14)
              .fontColor(this.themeColors.textSecondary)
              .width(60)
            
            Slider({
              value: ttsService.getSpeed() * 100,
              min: 50,
              max: 200
            })
            .layoutWeight(1)
            .blockColor(this.themeColors.primary)
            .trackColor(this.themeColors.divider)
            .selectedColor(this.themeColors.primary)
            .onChange((value: number) => {
              ttsService.setSpeed(value / 100)
            })
            
            Text(`${ttsService.getSpeed().toFixed(1)}x`)
              .fontSize(14)
              .fontColor(this.themeColors.textSecondary)
              .width(50)
          }
          .width('100%')
          .margin({ bottom: 12 })
          
          // 音色选择
          Row() {
            Text('音色')
              .fontSize(14)
              .fontColor(this.themeColors.textSecondary)
              .width(60)
            
            Row({ space: 8 }) {
              Button('女声')
                .fontSize(12)
                .height(32)
                .backgroundColor(ttsService.getVoice() === 'female' ? this.themeColors.primary : this.themeColors.surface)
                .fontColor(ttsService.getVoice() === 'female' ? '#FFFFFF' : this.themeColors.textPrimary)
                .onClick(() => {
                  ttsService.setVoice('female')
                })
              
              Button('男声')
                .fontSize(12)
                .height(32)
                .backgroundColor(ttsService.getVoice() === 'male' ? this.themeColors.primary : this.themeColors.surface)
                .fontColor(ttsService.getVoice() === 'male' ? '#FFFFFF' : this.themeColors.textPrimary)
                .onClick(() => {
                  ttsService.setVoice('male')
                })
            }
          }
          .width('100%')
          .margin({ bottom: 12 })
          
          // 定时关闭
          Row() {
            Text('定时')
              .fontSize(14)
              .fontColor(this.themeColors.textSecondary)
              .width(60)
            
            Select([
              { value: '不开启' },
              { value: '15分钟' },
              { value: '30分钟' },
              { value: '60分钟' }
            ])
            .selected(0)
            .font({ size: 14 })
            .fontColor(this.themeColors.textPrimary)
            .backgroundColor(this.themeColors.surface)
            .onSelect((index: number) => {
              const timers: number[] = [0, 15, 30, 60]
              const settings = ttsService.getSettings()
              settings.sleepTimer = timers[index]
              ttsService.updateSettings(settings)
            })
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.themeColors.surface)
        .transition(TransitionEffect.asymmetric(
          TransitionEffect.OPACITY.combine(TransitionEffect.move(TransitionEdge.TOP)),
          TransitionEffect.OPACITY
        ))
      }
    }
    .width('100%')
    .backgroundColor(this.themeColors.background)
    .border({ width: { top: 1 }, color: this.themeColors.divider })
  }
  
  // 获取播放按钮图标
  private getPlayButtonIcon(): string {
    if (this.ttsState === TTSState.PLAYING) {
      return '⏸'
    }
    return '▶'
  }
}