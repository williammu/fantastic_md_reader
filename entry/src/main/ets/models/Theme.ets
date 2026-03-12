import { ThemeColors as BaseThemeColors } from 'markdown-renderer'

export type { TocItem, ParseOptions, RenderOptions } from 'markdown-renderer'
export type ThemeColors = BaseThemeColors

export enum ThemeType {
  LIGHT = 'light',
  DARK = 'dark',
  AUTO = 'auto',
  PAPER = 'paper',       // 华为风格类纸书主题
  DARK_EYE = 'darkEye',  // 华为风格深色护眼主题
  EYE_CARE = 'eyeCare'   // 传统护眼主题
}

export const LightTheme: ThemeColors = {
  background: '#FFFFFF',
  surface: '#F5F5F5',
  textPrimary: '#1A1A1A',
  textSecondary: '#666666',
  textTertiary: '#999999',
  border: '#E5E5E5',
  divider: '#EEEEEE',
  primary: '#2196F3',
  primaryLight: '#E3F2FD',
  codeBackground: '#F5F5F5',
  quoteBackground: '#F9F9F9',
  statusBar: 'dark',
  syntaxKeyword: '#0000FF',
  syntaxString: '#A31515',
  syntaxNumber: '#098658',
  syntaxFunction: '#795E26',
  syntaxComment: '#008000',
  syntaxOperator: '#000000',
  syntaxConstant: '#0070C1',
  syntaxEnum: '#800080'
}

export const DarkTheme: ThemeColors = {
  background: '#121212',
  surface: '#1E1E1E',
  textPrimary: '#FFFFFF',
  textSecondary: '#B3B3B3',
  textTertiary: '#808080',
  border: '#2C2C2C',
  divider: '#2A2A2A',
  primary: '#90CAF9',
  primaryLight: '#1A237E',
  codeBackground: '#1E1E1E',
  quoteBackground: '#252525',
  statusBar: 'light',
  syntaxKeyword: '#569CD6',
  syntaxString: '#CE9178',
  syntaxNumber: '#B5CEA8',
  syntaxFunction: '#DCDCAA',
  syntaxComment: '#6A9955',
  syntaxOperator: '#D4D4D4',
  syntaxConstant: '#4EC9B0',
  syntaxEnum: '#C586C0'
}

export const EyeCareTheme: ThemeColors = {
  background: '#F5F0E1',
  surface: '#EDE6D0',
  textPrimary: '#3D3D3D',
  textSecondary: '#666666',
  textTertiary: '#999999',
  border: '#D4CDB8',
  divider: '#E0D9C5',
  primary: '#8B6914',
  primaryLight: '#F0E6D2',
  codeBackground: '#E8E2D0',
  quoteBackground: '#EDE6D0',
  statusBar: 'dark',
  syntaxKeyword: '#4A6CD4',
  syntaxString: '#B45309',
  syntaxNumber: '#2D6A4F',
  syntaxFunction: '#7C6F0E',
  syntaxComment: '#5B8A4E',
  syntaxOperator: '#3D3D3D',
  syntaxConstant: '#2E7D7A',
  syntaxEnum: '#7B4B8C'
}

// 华为风格舒适阅读主题 - 类纸书体验
export const PaperTheme: ThemeColors = {
  background: '#FAF8F3',           // 暖白纸张色
  surface: '#F5F2EA',              // 浅米色表面
  textPrimary: '#2C2C2C',          // 深灰墨色，柔和不刺眼
  textSecondary: '#5A5A5A',        // 中灰次要文字
  textTertiary: '#8A8A8A',         // 浅灰辅助文字
  border: '#E8E4DC',               // 柔和边框
  divider: '#F0EDE5',              // 淡色分隔线
  primary: '#C45C26',              // 华为红橙色，温暖醒目
  primaryLight: '#FDF2ED',         // 淡橙背景
  codeBackground: '#F2EFE8',       // 代码块背景
  quoteBackground: '#F7F4ED',      // 引用块背景
  statusBar: 'dark',
  syntaxKeyword: '#2E5AAC',        // 深蓝关键字
  syntaxString: '#8B4513',         // 棕色字符串
  syntaxNumber: '#2D6A4F',         // 墨绿数字
  syntaxFunction: '#7C6F0E',       // 橄榄黄函数
  syntaxComment: '#6B8E6B',        // 灰绿注释
  syntaxOperator: '#4A4A4A',       // 深灰操作符
  syntaxConstant: '#1E6B6B',       // 青绿常量
  syntaxEnum: '#7B4B8C'            // 紫色枚举
}

// 华为风格深色护眼主题
export const DarkEyeTheme: ThemeColors = {
  background: '#1A1A1A',           // 深黑背景
  surface: '#252525',              // 深灰表面
  textPrimary: '#E8E4DC',          // 暖白主文字
  textSecondary: '#B8B4AC',        // 暖灰次要文字
  textTertiary: '#888480',         // 灰棕辅助文字
  border: '#3A3A3A',               // 深灰边框
  divider: '#333333',              // 分隔线
  primary: '#FF8C5A',              // 暖橙主色
  primaryLight: '#3D2A1F',         // 深橙背景
  codeBackground: '#2A2A2A',       // 代码块背景
  quoteBackground: '#303030',      // 引用块背景
  statusBar: 'light',
  syntaxKeyword: '#6B9BD0',        // 浅蓝关键字
  syntaxString: '#D4A574',         // 暖棕字符串
  syntaxNumber: '#8FBC8F',         // 浅绿数字
  syntaxFunction: '#DCDCAA',       // 浅黄函数
  syntaxComment: '#7A9A6A',        // 灰绿注释
  syntaxOperator: '#C0C0C0',       // 银灰操作符
  syntaxConstant: '#6BCBCB',       // 浅青常量
  syntaxEnum: '#C586C0'            // 浅紫枚举
}