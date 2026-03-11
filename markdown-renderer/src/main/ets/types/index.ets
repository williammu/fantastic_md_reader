export interface TocItem {
  level: number
  title: string
  anchorId: string
}

export interface ParseOptions {
  highlightCode?: boolean
}

export interface RenderOptions {
  fontSize?: number
  lineHeight?: number
}

export interface ThemeColors {
  textPrimary: ResourceColor
  textSecondary: ResourceColor
  textTertiary: ResourceColor
  background: ResourceColor
  surface: ResourceColor
  primary: ResourceColor
  primaryLight: ResourceColor
  border: ResourceColor
  divider: ResourceColor
  codeBackground: ResourceColor
  quoteBackground: ResourceColor
  statusBar: 'light' | 'dark'
  syntaxKeyword: ResourceColor
  syntaxString: ResourceColor
  syntaxNumber: ResourceColor
  syntaxFunction: ResourceColor
  syntaxComment: ResourceColor
  syntaxOperator: ResourceColor
  syntaxConstant: ResourceColor
  syntaxEnum: ResourceColor
}

export class ResolvedTheme {
  textPrimary: string = '#000000'
  textSecondary: string = '#666666'
  textTertiary: string = '#999999'
  background: string = '#FFFFFF'
  surface: string = '#F5F5F5'
  primary: string = '#2196F3'
  primaryLight: string = '#E3F2FD'
  border: string = '#E5E5E5'
  divider: string = '#EEEEEE'
  codeBackground: string = '#F5F5F5'
  quoteBackground: string = '#F9F9F9'
  statusBar: 'light' | 'dark' = 'dark'
  syntaxKeyword: string = '#c586c0'
  syntaxString: string = '#ce9178'
  syntaxNumber: string = '#b5cea8'
  syntaxFunction: string = '#dcdcaa'
  syntaxComment: string = '#6a9955'
  syntaxOperator: string = '#000000'
  syntaxConstant: string = '#4EC9B0'
  syntaxEnum: string = '#C586C0'
}
