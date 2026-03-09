import { router } from '@kit.ArkUI'
import { ThemeColors, LightTheme } from '../models/Theme'
import { StorageService } from '../utils/StorageService'

@Entry
@Component
struct SettingsPage {
  @StorageLink('current_theme_colors') themeColors: ThemeColors = LightTheme
  
  // 字体大小：默认54sp（3倍于原来的18sp），范围48-78
  @State fontSize: number = 18
  
  aboutToAppear() {
    // 读取保存的字体大小，默认54
    const savedSize: number = AppStorage.get<number>('reader_font_size_val') as number
    this.fontSize = savedSize > 0 ? savedSize : 18
  }
  
  // 保存字体大小
  saveFontSize(size: number) {
    this.fontSize = size
    AppStorage.setOrCreate('reader_font_size_val', size)
    StorageService.setFontSize(size)
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button('‹')
          .fontSize(28)
          .backgroundColor(Color.Transparent)
          .fontColor(this.themeColors.textPrimary)
          .onClick(() => {
            router.back()
          })
        
        Text('设置')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeColors.textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Blank().width(48)
      }
      .width('100%')
      .height(56)
      .padding({ left: 8, right: 8 })
      .backgroundColor(this.themeColors.background)
      
      // 设置项列表
      List() {
        // 字体大小设置
        ListItem() {
          Column() {
            Row() {
              Text('阅读字号')
                .fontSize(16)
                .fontColor(this.themeColors.textPrimary)
              
              Blank()
              
              Text(`${this.fontSize.toFixed(0)}`)
                .fontSize(14)
                .fontColor(this.themeColors.textSecondary)
            }
            .width('100%')
            
            // 字号滑块：48-78，默认54（3倍）
            Row() {
              Text('A')
                .fontSize(16)
                .fontColor(this.themeColors.textTertiary)
              
              Slider({
                value: this.fontSize,
                min: 48,
                max: 78,
                step: 2
              })
              .layoutWeight(1)
              .margin({ left: 12, right: 12 })
              .blockColor(this.themeColors.primary)
              .trackColor(this.themeColors.divider)
              .selectedColor(this.themeColors.primary)
              .onChange((value: number) => {
                this.saveFontSize(value)
              })
              
              Text('A')
                .fontSize(26)
                .fontColor(this.themeColors.textTertiary)
            }
            .width('100%')
            .margin({ top: 12 })
            
            // 预览文本
            Text('预览：这是一段示例文字')
              .fontSize(this.fontSize)
              .fontColor(this.themeColors.textPrimary)
              .margin({ top: 16 })
              .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.themeColors.surface)
          .borderRadius(12)
        }
        .padding({ left: 16, right: 16, top: 16 })
        
        // 关于应用
        ListItem() {
          Row() {
            Text('关于')
              .fontSize(16)
              .fontColor(this.themeColors.textPrimary)
            
            Blank()
            
            Text('MD 阅读器 v1.0')
              .fontSize(14)
              .fontColor(this.themeColors.textTertiary)
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .backgroundColor(this.themeColors.surface)
          .borderRadius(12)
        }
        .padding({ left: 16, right: 16, top: 16 })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(this.themeColors.background)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeColors.background)
  }
}