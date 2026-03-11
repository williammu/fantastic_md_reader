import { ThemeColors, RenderOptions, ResolvedTheme } from '../types/index'

function toColorString(color: ResourceColor): string {
  if (typeof color === 'string') {
    return color
  } else if (typeof color === 'number') {
    return `#${color.toString(16).padStart(8, '0')}`
  }
  return '#000000'
}

function resolveTheme(themeColors: ThemeColors): ResolvedTheme {
  const theme = new ResolvedTheme()
  theme.textPrimary = toColorString(themeColors.textPrimary)
  theme.textSecondary = toColorString(themeColors.textSecondary)
  theme.textTertiary = toColorString(themeColors.textTertiary)
  theme.background = toColorString(themeColors.background)
  theme.surface = toColorString(themeColors.surface)
  theme.primary = toColorString(themeColors.primary)
  theme.primaryLight = toColorString(themeColors.primaryLight)
  theme.border = toColorString(themeColors.border)
  theme.divider = toColorString(themeColors.divider)
  theme.codeBackground = toColorString(themeColors.codeBackground)
  theme.quoteBackground = toColorString(themeColors.quoteBackground)
  theme.statusBar = themeColors.statusBar
  theme.syntaxKeyword = toColorString(themeColors.syntaxKeyword)
  theme.syntaxString = toColorString(themeColors.syntaxString)
  theme.syntaxNumber = toColorString(themeColors.syntaxNumber)
  theme.syntaxFunction = toColorString(themeColors.syntaxFunction)
  theme.syntaxComment = toColorString(themeColors.syntaxComment)
  theme.syntaxOperator = toColorString(themeColors.syntaxOperator)
  theme.syntaxConstant = toColorString(themeColors.syntaxConstant)
  theme.syntaxEnum = toColorString(themeColors.syntaxEnum)
  return theme
}

export class HTMLGenerator {
  static generate(htmlContent: string, themeColors: ThemeColors, fontSize: number = 16, lineHeight: number = 1.6): string {
    const theme = resolveTheme(themeColors)
    
    const html = `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
  <title>MD Reader</title>
  <script>
    document.addEventListener('click', function(e) {
      var target = e.target;
      while (target && target.tagName !== 'A') {
        target = target.parentElement;
        if (!target) return;
      }
      if (target && target.tagName === 'A') {
        var href = target.getAttribute('href');
        if (href && href.charAt(0) === '#') {
          e.preventDefault();
          var anchorId = href.substring(1);
          var el = document.getElementById(anchorId);
          if (el) {
            el.scrollIntoView({behavior: 'smooth'});
          }
        }
      }
    });
  </script>
  <style>
    ${HTMLGenerator.getCSS(theme, fontSize, lineHeight)}
  </style>
</head>
<body>
  <article class="markdown-body">
    ${htmlContent}
  </article>
</body>
</html>`
    
    return html
  }
  
  static getCSS(theme: ResolvedTheme, fontSize: number, lineHeight: number): string {
    return `
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "PingFang SC", "Hiragino Sans GB", "Microsoft YaHei", "Helvetica Neue", Helvetica, Arial, sans-serif;
      font-size: ${fontSize}px;
      line-height: ${lineHeight};
      color: ${theme.textPrimary};
      background-color: ${theme.background};
      word-wrap: break-word;
    }
    
    .markdown-body {
      max-width: 100%;
      margin-left: 15px;
      margin-right: 16px;
      margin-top: 16px;
      margin-bottom: 16px;
    }
    
    h1, h2, h3, h4, h5, h6 {
      margin-top: 24px;
      margin-bottom: 16px;
      font-weight: 600;
      line-height: 1.25;
      color: ${theme.textPrimary};
      scroll-margin-top: 20px;
    }
    
    h1 { font-size: ${fontSize * 2}px; border-bottom: 1px solid ${theme.divider}; padding-bottom: 8px; }
    h2 { font-size: ${fontSize * 1.5}px; border-bottom: 1px solid ${theme.divider}; padding-bottom: 8px; }
    h3 { font-size: ${fontSize * 1.25}px; }
    h4 { font-size: ${fontSize * 1.1}px; }
    h5 { font-size: ${fontSize}px; }
    h6 { font-size: ${fontSize * 0.9}px; color: ${theme.textSecondary}; }
    
    .anchor-link {
      position: absolute;
      left: -20px;
      color: ${theme.textTertiary};
      text-decoration: none;
      opacity: 0;
      transition: opacity 0.2s;
      width: 20px;
      text-align: right;
      padding-right: 4px;
    }

    h1, h2, h3, h4, h5, h6 {
      position: relative;
    }

    h1:hover .anchor-link,
    h2:hover .anchor-link,
    h3:hover .anchor-link,
    h4:hover .anchor-link,
    h5:hover .anchor-link,
    h6:hover .anchor-link {
      opacity: 1;
    }
    
    p {
      margin-bottom: 16px;
    }
    
    a {
      color: ${theme.primary};
      text-decoration: none;
    }
    
    a:hover {
      text-decoration: underline;
    }
    
    code {
      font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, monospace;
      background-color: ${theme.codeBackground};
      padding: 2px 6px;
      border-radius: 3px;
      font-size: ${fontSize * 0.9}px;
      color: ${theme.textPrimary};
    }
    
    pre {
      background-color: ${theme.codeBackground};
      padding: 16px;
      border-radius: 8px;
      overflow-x: auto;
      margin-bottom: 16px;
    }
    
    pre code {
      background: none;
      padding: 0;
      font-size: ${fontSize * 0.85}px;
      line-height: 1.6;
    }
    
    blockquote {
      border-left: 4px solid ${theme.primary};
      padding-left: 16px;
      margin: 0 0 16px 0;
      color: ${theme.textSecondary};
    }
    
    blockquote blockquote {
      border-left-color: ${theme.primaryLight};
      margin-top: 8px;
      margin-bottom: 8px;
    }
    
    blockquote blockquote blockquote {
      border-left-color: ${theme.textTertiary};
    }
    
    blockquote p:last-child {
      margin-bottom: 0;
    }
    
    blockquote p:first-child {
      margin-top: 0;
    }
    
    ul, ol {
      margin-bottom: 16px;
      padding-left: 24px;
    }
    
    li {
      margin-bottom: 4px;
    }
    
    li > ul, li > ol {
      margin-top: 4px;
      margin-bottom: 4px;
    }
    
    ul ul, ol ul {
      list-style-type: circle;
    }
    
    ul ul ul, ol ol ul, ul ol ul, ol ul ul {
      list-style-type: square;
    }
    
    ol ol {
      list-style-type: lower-alpha;
    }
    
    ol ol ol {
      list-style-type: lower-roman;
    }
    
    .task-list-item {
      list-style: none;
      margin-left: -24px;
      display: flex;
      align-items: flex-start;
    }
    
    .task-list-item input[type="checkbox"] {
      margin-right: 8px;
      margin-top: 4px;
      width: 16px;
      height: 16px;
      flex-shrink: 0;
    }
    
    table {
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 16px;
      display: block;
      overflow-x: auto;
    }
    
    th, td {
      padding: 8px 12px;
      border: 1px solid ${theme.border};
    }
    
    th {
      background-color: ${theme.surface};
      font-weight: 600;
    }
    
    tr:nth-child(2n) {
      background-color: ${theme.surface};
    }
    
    img {
      max-width: 100%;
      height: auto;
      border-radius: 8px;
      margin: 8px 0;
    }
    
    hr {
      border: none;
      border-top: 1px solid ${theme.divider};
      margin: 24px 0;
    }
    
    del {
      text-decoration: line-through;
      color: ${theme.textTertiary};
    }
    
    .token-keyword {
      color: ${theme.syntaxKeyword || '#c586c0'};
      font-weight: 500;
    }
    
    .token-string {
      color: ${theme.syntaxString || '#ce9178'};
    }
    
    .token-number {
      color: ${theme.syntaxNumber || '#b5cea8'};
    }
    
    .token-function {
      color: ${theme.syntaxFunction || '#dcdcaa'};
    }
    
    .token-comment {
      color: ${theme.syntaxComment || '#6a9955'};
      font-style: italic;
    }
    
    .token-operator {
      color: ${theme.syntaxOperator || theme.textPrimary};
    }
    
    .token-constant {
      color: ${theme.syntaxConstant || '#4EC9B0'};
      font-weight: 500;
    }
    
    .token-enum {
      color: ${theme.syntaxEnum || '#C586C0'};
      font-weight: 500;
    }
    `
  }
}
