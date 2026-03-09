import { ThemeType, ThemeColors, LightTheme, DarkTheme } from '../models/Theme'

// 常量定义
const THEME_KEY = 'app_theme'
const FONT_SIZE_KEY = 'reader_font_size'
const LINE_SPACING_KEY = 'reader_line_spacing'

// 全局状态键
export const CURRENT_THEME_KEY = 'current_theme_type'
export const CURRENT_COLORS_KEY = 'current_theme_colors'
export const FONT_SIZE_KEY_STORAGE = 'reader_font_size_val'
export const LINE_SPACING_KEY_STORAGE = 'reader_line_spacing_val'

// 主题管理器 - 全局状态管理
export class ThemeManager {
  // 初始化主题系统
  static init() {
    // 从存储读取主题设置，默认自动
    const savedTheme = AppStorage.get<string>(THEME_KEY) || ThemeType.AUTO
    AppStorage.setOrCreate(CURRENT_THEME_KEY, savedTheme)
    AppStorage.setOrCreate(CURRENT_COLORS_KEY, ThemeManager.getThemeColors(savedTheme))
    
    // 初始化字体大小（默认 16）
    const fontSize = AppStorage.get<number>(FONT_SIZE_KEY) || 16
    AppStorage.setOrCreate(FONT_SIZE_KEY_STORAGE, fontSize)
    
    // 初始化行间距（默认 1.6）
    const lineSpacing = AppStorage.get<number>(LINE_SPACING_KEY) || 1.6
    AppStorage.setOrCreate(LINE_SPACING_KEY_STORAGE, lineSpacing)
  }
  
  // 设置主题
  static setTheme(type: ThemeType) {
    AppStorage.set(CURRENT_THEME_KEY, type)
    AppStorage.set(CURRENT_COLORS_KEY, ThemeManager.getThemeColors(type))
    // 持久化
    AppStorage.setOrCreate(THEME_KEY, type)
  }
  
  // 获取主题颜色
  static getThemeColors(type: string): ThemeColors {
    // 自动模式根据系统判断
    if (type === ThemeType.AUTO) {
      // 简化处理：默认返回浅色主题
      return LightTheme
    }
    return type === ThemeType.DARK ? DarkTheme : LightTheme
  }
  
  // 设置字体大小
  static setFontSize(size: number) {
    AppStorage.set(FONT_SIZE_KEY_STORAGE, size)
    AppStorage.setOrCreate(FONT_SIZE_KEY, size)
  }
  
  // 设置行间距
  static setLineSpacing(spacing: number) {
    AppStorage.set(LINE_SPACING_KEY_STORAGE, spacing)
    AppStorage.setOrCreate(LINE_SPACING_KEY, spacing)
  }
  
  // 获取当前主题（用于装饰器）
  static getCurrentTheme(): ThemeType {
    const theme = AppStorage.get(CURRENT_THEME_KEY) as string
    if (theme === ThemeType.DARK) {
      return ThemeType.DARK
    } else if (theme === ThemeType.AUTO) {
      return ThemeType.AUTO
    }
    return ThemeType.LIGHT
  }
  
  // 获取当前颜色
  static getCurrentColors(): ThemeColors {
    const colors = AppStorage.get(CURRENT_COLORS_KEY) as ThemeColors
    return colors || LightTheme
  }
}