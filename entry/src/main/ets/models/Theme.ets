import { ThemeColors as BaseThemeColors } from 'markdown-renderer'

export type { TocItem, ParseOptions, RenderOptions } from 'markdown-renderer'
export type ThemeColors = BaseThemeColors

export enum ThemeType {
  LIGHT = 'light',
  DARK = 'dark',
  AUTO = 'auto'
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