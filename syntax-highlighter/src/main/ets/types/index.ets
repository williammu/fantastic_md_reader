export interface TokenInfo {
  type: string
  content: string
}

export interface HighlightOptions {
  language: string
}

export interface ThemeColors {
  syntaxKeyword?: string
  syntaxString?: string
  syntaxNumber?: string
  syntaxFunction?: string
  syntaxComment?: string
  syntaxOperator?: string
  syntaxConstant?: string
  syntaxEnum?: string
}

export type Language = 'typescript' | 'javascript' | 'ts' | 'js' | 'java' | 'python' | 'py' | 
                        'c' | 'cpp' | 'c++' | 'json' | 'go' | 'swift' | 'kotlin' | 'kt' | string
