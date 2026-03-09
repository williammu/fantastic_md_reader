// 主题类型枚举
export enum ThemeType {
  LIGHT = 'light',
  DARK = 'dark',
  AUTO = 'auto'
}

// 主题颜色配置
export interface ThemeColors {
  // 背景色
  background: ResourceColor
  surface: ResourceColor
  // 文字色
  textPrimary: ResourceColor
  textSecondary: ResourceColor
  textTertiary: ResourceColor
  // 边框和分割线
  border: ResourceColor
  divider: ResourceColor
  // 强调色
  primary: ResourceColor
  primaryLight: ResourceColor
  // 特殊状态
  codeBackground: ResourceColor
  quoteBackground: ResourceColor
  // 状态栏
  statusBar: 'light' | 'dark'
  // 语法高亮色
  syntaxKeyword: ResourceColor   // 关键字 - 蓝色/浅蓝
  syntaxString: ResourceColor    // 字符串 - 橙色
  syntaxNumber: ResourceColor    // 数字 - 浅绿
  syntaxFunction: ResourceColor  // 函数名 - 黄色
  syntaxComment: ResourceColor   // 注释 - 绿色
  syntaxOperator: ResourceColor  // 运算符
  syntaxConstant: ResourceColor  // 常量 - 青色
  syntaxEnum: ResourceColor      // 枚举 - 紫色
}

// 浅色主题
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
  // 语法高亮 - 浅色主题使用 VS Code 风格
  syntaxKeyword: '#0000FF',   // 蓝色
  syntaxString: '#A31515',    // 红棕色
  syntaxNumber: '#098658',    // 绿色
  syntaxFunction: '#795E26',  // 棕色
  syntaxComment: '#008000',   // 绿色
  syntaxOperator: '#000000',  // 黑色
  syntaxConstant: '#0070C1',  // 青色 - 常量
  syntaxEnum: '#800080'       // 紫色 - 枚举
}

// 深色主题
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
  // 语法高亮 - 深色主题使用 VS Code Dark+ 风格
  syntaxKeyword: '#569CD6',   // 浅蓝
  syntaxString: '#CE9178',    // 橙色
  syntaxNumber: '#B5CEA8',    // 浅绿
  syntaxFunction: '#DCDCAA',  // 黄色
  syntaxComment: '#6A9955',   // 绿色
  syntaxOperator: '#D4D4D4',  // 浅灰
  syntaxConstant: '#4EC9B0',  // 青色 - 常量
  syntaxEnum: '#C586C0'       // 紫色 - 枚举
}

// 护眼主题（淡黄色）
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
  // 语法高亮 - 护眼主题使用柔和配色
  syntaxKeyword: '#4A6CD4',   // 柔和蓝
  syntaxString: '#B45309',    // 柔和橙
  syntaxNumber: '#2D6A4F',    // 柔和绿
  syntaxFunction: '#7C6F0E',  // 柔和黄
  syntaxComment: '#5B8A4E',   // 柔和绿
  syntaxOperator: '#3D3D3D',  // 深灰
  syntaxConstant: '#2E7D7A',  // 柔和青 - 常量
  syntaxEnum: '#7B4B8C'       // 柔和紫 - 枚举
}