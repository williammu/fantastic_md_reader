import { router } from '@kit.ArkUI'
import { ThemeColors, LightTheme, DarkTheme, PaperTheme, DarkEyeTheme, EyeCareTheme, ThemeType } from '../models/Theme'
import { StorageService } from '../utils/StorageService'
// 使用图片图标资源

@Entry
@Component
struct SettingsPage {
  @StorageLink('current_theme_colors') themeColors: ThemeColors = LightTheme
  
  // 字体大小：默认54sp（3倍于原来的18sp），范围48-78
  @State fontSize: number = 18
  @State currentThemeType: ThemeType = ThemeType.LIGHT
  
  aboutToAppear() {
    // 读取保存的字体大小，默认54
    const savedSize: number = AppStorage.get<number>('reader_font_size_val') as number
    this.fontSize = savedSize > 0 ? savedSize : 18
    
    // 读取保存的主题类型
    const savedTheme = AppStorage.get<string>('current_theme_type') as string
    if (savedTheme) {
      this.currentThemeType = savedTheme as ThemeType
    }
  }
  
  // 保存字体大小
  saveFontSize(size: number) {
    this.fontSize = size
    AppStorage.setOrCreate('reader_font_size_val', size)
    StorageService.setFontSize(size)
  }
  
  // 切换主题
  switchTheme(themeType: ThemeType) {
    this.currentThemeType = themeType
    AppStorage.setOrCreate('current_theme_type', themeType)

    let newTheme: ThemeColors
    if (themeType === ThemeType.DARK) {
      newTheme = DarkTheme
    } else {
      newTheme = LightTheme
    }

    AppStorage.setOrCreate('current_theme_colors', newTheme)
    StorageService.setThemeColors(newTheme)
  }
  
  // 获取主题名称
  getThemeName(themeType: ThemeType): string {
    switch (themeType) {
      case ThemeType.LIGHT:
        return '亮色'
      case ThemeType.DARK:
        return '暗色'
      default:
        return '亮色'
    }
  }
  
  // 主题选项构建器
  @Builder
  ThemeOption(themeType: ThemeType, name: string, bgColor: string, textColor: string) {
    Column() {
      Column()
        .width(48)
        .height(48)
        .backgroundColor(bgColor)
        .borderRadius(8)
        .border({
          width: this.currentThemeType === themeType ? 2 : 1,
          color: this.currentThemeType === themeType ? this.themeColors.primary : this.themeColors.border
        })
        .shadow({
          radius: this.currentThemeType === themeType ? 4 : 0,
          color: this.themeColors.primary,
          offsetY: 2
        })
      
      Text(name)
        .fontSize(12)
        .fontColor(this.currentThemeType === themeType ? this.themeColors.primary : this.themeColors.textSecondary)
        .margin({ top: 4 })
    }
    .onClick(() => {
      this.switchTheme(themeType)
    })
  }

  build() {
    Column() {
      // 顶部导航栏 - 华为风格
      Row() {
        // 返回按钮
        Button() {
          Image($r('app.media.ic_back_48'))
            .width(24)
            .height(24)
            .fillColor(this.themeColors.textPrimary)
        }
        .width(44)
        .height(44)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back()
        })
        
        Text('𝓢𝓮𝓽𝓽𝓲𝓷𝓰𝓼')
          .fontSize(19)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeColors.textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Blank().width(44)
      }
      .width('100%')
      .height(60)
      .padding({ left: 12, right: 12 })
      .backgroundColor(this.themeColors.background)
      
      // 设置项列表
      List() {
        // 字体大小设置
        ListItem() {
          Column() {
            Row() {
              Row({ space: 8 }) {
                Image($r('app.media.ic_font_size_48'))
                  .width(20)
                  .height(20)
                  .fillColor(this.themeColors.primary)
                Text('阅读字号')
                  .fontSize(16)
                  .fontColor(this.themeColors.textPrimary)
              }
              
              Blank()
              
              Text(`${this.fontSize.toFixed(0)}`)
                .fontSize(14)
                .fontColor(this.themeColors.textSecondary)
            }
            .width('100%')
            
            // 字号滑块：48-78，默认54（3倍）
            Row() {
              Text('A')
                .fontSize(14)
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
                .fontSize(24)
                .fontColor(this.themeColors.textTertiary)
            }
            .width('100%')
            .margin({ top: 16 })
            
            // 预览文本
            Text('预览：这是一段示例文字')
              .fontSize(this.fontSize)
              .fontColor(this.themeColors.textPrimary)
              .margin({ top: 20 })
              .width('100%')
          }
          .width('100%')
          .padding(20)
          .backgroundColor(this.themeColors.surface)
          .borderRadius(16)
        }
        .padding({ left: 16, right: 16, top: 12 })
        
        // 阅读主题设置
        ListItem() {
          Column() {
            Row({ space: 8 }) {
                Image($r('app.media.ic_sun_48'))
                  .width(20)
                  .height(20)
                  .fillColor(this.themeColors.primary)
              Text('阅读主题')
                .fontSize(16)
                .fontColor(this.themeColors.textPrimary)

              Blank()

              Text(this.getThemeName(this.currentThemeType))
                .fontSize(14)
                .fontColor(this.themeColors.textSecondary)
            }
            .width('100%')

            // 主题选择 - 简化为亮色和暗色两种
            Row({ space: 16 }) {
              // 明亮主题
              this.ThemeOption(ThemeType.LIGHT, '亮色', '#FFFFFF', '#2C2C2C')

              // 深色主题
              this.ThemeOption(ThemeType.DARK, '暗色', '#1C1C1E', '#E8E4DC')
            }
            .width('100%')
            .margin({ top: 16 })
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .padding(20)
          .backgroundColor(this.themeColors.surface)
          .borderRadius(16)
        }
        .padding({ left: 16, right: 16, top: 12 })
        
        // 关于应用
        ListItem() {
          Row({ space: 12 }) {
            Image($r('app.media.ic_info_48'))
              .width(20)
              .height(20)
              .fillColor(this.themeColors.primary)

            Text('关于')
              .fontSize(16)
              .fontColor(this.themeColors.textPrimary)
            
            Blank()
            
            Text('𝓕𝓪𝓷𝓽𝓪𝓼𝓽𝓲𝓬 𝓜𝓓 𝓡𝓮𝓪𝓭𝓮𝓻 v1.0')
              .fontSize(14)
              .fontColor(this.themeColors.textTertiary)
          }
          .width('100%')
          .height(60)
          .padding({ left: 16, right: 16 })
          .backgroundColor(this.themeColors.surface)
          .borderRadius(16)
        }
        .padding({ left: 16, right: 16, top: 12 })
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
