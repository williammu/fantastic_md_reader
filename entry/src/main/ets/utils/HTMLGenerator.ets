import { ThemeColors } from '../models/Theme'
import { fileIo } from '@kit.CoreFileKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { util } from '@kit.ArkTS'

const DOMAIN = 0x0005

// Token 信息接口
interface TokenInfo {
  type: string
  content: string
}

// HTML 生成器 - 生成完整的 HTML 文档
export class HTMLGenerator {
  // 生成完整的 HTML 文档
  static generate(htmlContent: string, themeColors: ThemeColors, fontSize: number = 16, lineHeight: number = 1.6): string {
    hilog.info(DOMAIN, 'testTag', '[HTMLGenerator] Generating HTML, content length: %{public}d', htmlContent.length)
    
    const html = `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
  <title>MD Reader</title>
  <script>
    console.log('[WebView] HTML loaded, JS running');
    
    document.addEventListener('click', function(e) {
      console.log('[WebView] Click event detected');
      var target = e.target;
      while (target && target.tagName !== 'A') {
        target = target.parentElement;
        if (!target) return;
      }
      if (target && target.tagName === 'A') {
        var href = target.getAttribute('href');
        console.log('[WebView] Link clicked, href:', href);
        if (href && href.charAt(0) === '#') {
          e.preventDefault();
          var anchorId = href.substring(1);
          console.log('[WebView] Anchor ID:', anchorId);
          var el = document.getElementById(anchorId);
          if (el) {
            console.log('[WebView] Element found, scrolling...');
            el.scrollIntoView({behavior: 'smooth'});
          } else {
            console.log('[WebView] Element NOT found for ID:', anchorId);
            // 尝试查找所有ID
            var allIds = [];
            var elementsWithId = document.querySelectorAll('[id]');
            for (var i = 0; i < elementsWithId.length; i++) {
              allIds.push(elementsWithId[i].id);
            }
            console.log('[WebView] Available IDs:', allIds.join(', '));
          }
        }
      }
    });
    
    // 页面加载完成后输出所有锚点
    window.onload = function() {
      console.log('[WebView] Window onload');
      var headings = document.querySelectorAll('h1, h2, h3, h4, h5, h6');
      console.log('[WebView] Found', headings.length, 'headings');
      for (var i = 0; i < headings.length; i++) {
        var h = headings[i];
        console.log('[WebView] Heading:', h.tagName, 'ID:', h.id, 'Text:', h.textContent.substring(0, 50));
      }
    };
  </script>
  <style>
    ${HTMLGenerator.getCSS(themeColors, fontSize, lineHeight)}
  </style>
</head>
<body>
  <article class="markdown-body">
    ${htmlContent}
  </article>
</body>
</html>`
    
    console.log('[HTMLGenerator] HTML generated successfully')

    // 将 HTML 写入文件以便调试
    try {
      const htmlPath = '/data/storage/el2/base/haps/entry/files/shared/debug_output.html'
      hilog.info(DOMAIN, 'testTag', '[HTMLGenerator] Writing HTML to: %{public}s', htmlPath)
      const file = fileIo.openSync(htmlPath, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC)
      const encoder = new util.TextEncoder()
      const uint8Array = encoder.encode(html)
      const buffer = uint8Array.buffer.slice(uint8Array.byteOffset, uint8Array.byteOffset + uint8Array.byteLength)
      fileIo.writeSync(file.fd, buffer)
      fileIo.closeSync(file)
      hilog.info(DOMAIN, 'testTag', '[HTMLGenerator] HTML written to file successfully, size: %{public}d', uint8Array.length)
    } catch (e) {
      hilog.error(DOMAIN, 'testTag', '[HTMLGenerator] Failed to write HTML: %{public}s', JSON.stringify(e))
    }

    return html
  }
  
  // 生成 CSS 样式
  private static getCSS(theme: ThemeColors, fontSize: number, lineHeight: number): string {
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
    
    /* 标题 */
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
    
    /* 锚点链接 */
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
    
    /* 段落 */
    p {
      margin-bottom: 16px;
    }
    
    /* 链接 */
    a {
      color: ${theme.primary};
      text-decoration: none;
    }
    
    a:hover {
      text-decoration: underline;
    }
    
    /* 代码 */
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
    
    /* 引用块 - 支持嵌套 */
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
    
    /* 列表 */
    ul, ol {
      margin-bottom: 16px;
      padding-left: 24px;
    }
    
    li {
      margin-bottom: 4px;
    }
    
    /* 嵌套列表 */
    li > ul, li > ol {
      margin-top: 4px;
      margin-bottom: 4px;
    }
    
    /* 二级列表样式 */
    ul ul, ol ul {
      list-style-type: circle;
    }
    
    ul ul ul, ol ol ul, ul ol ul, ol ul ul {
      list-style-type: square;
    }
    
    /* 有序列表嵌套 */
    ol ol {
      list-style-type: lower-alpha;
    }
    
    ol ol ol {
      list-style-type: lower-roman;
    }
    
    /* 任务列表 */
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
    
    /* 表格 */
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
    
    /* 图片 */
    img {
      max-width: 100%;
      height: auto;
      border-radius: 8px;
      margin: 8px 0;
    }
    
    /* 分割线 */
    hr {
      border: none;
      border-top: 1px solid ${theme.divider};
      margin: 24px 0;
    }
    
    /* 删除线 */
    del {
      text-decoration: line-through;
      color: ${theme.textTertiary};
    }
    
    /* 朗读高亮 */
    .tts-highlight {
      background-color: ${theme.primaryLight};
      border-radius: 2px;
    }
    
    /* 语法高亮 - 统一配色方案 */
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
  
  // 语法高亮器
  static highlightCode(code: string, language: string): string {
    // HTML 转义
    let html: string = code.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    
    // 根据语言选择高亮方案
    switch (language.toLowerCase()) {
      case 'typescript':
      case 'javascript':
      case 'ts':
      case 'js':
        return HTMLGenerator.highlightTypeScript(html)
      case 'java':
        return HTMLGenerator.highlightJava(html)
      case 'python':
      case 'py':
        return HTMLGenerator.highlightPython(html)
      case 'c':
      case 'cpp':
      case 'c++':
        return HTMLGenerator.highlightC(html)
      case 'json':
        return HTMLGenerator.highlightJSON(html)
      case 'go':
        return HTMLGenerator.highlightGo(html)
      case 'swift':
        return HTMLGenerator.highlightSwift(html)
      case 'kotlin':
      case 'kt':
        return HTMLGenerator.highlightKotlin(html)
      default:
        return html
    }
  }
  
  // 占位符类
  private static highlightPlaceholder(html: string, tokens: TokenInfo[]): string {
    console.log(`[highlightPlaceholder] Starting with ${tokens.length} tokens`)
    console.log(`[highlightPlaceholder] HTML before: ${html.substring(0, 200)}...`)
    
    // 从后往前替换，避免索引错位
    for (let i: number = tokens.length - 1; i >= 0; i--) {
      const token: TokenInfo = tokens[i]
      const placeholder: string = `@__PH_${i}__@`
      const span: string = `<span class="token-${token.type}">${token.content}</span>`
      
      // 使用 replaceAll 替换所有匹配项
      const beforeReplace = html
      html = html.replace(new RegExp(placeholder.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g'), span)
      
      if (html === beforeReplace) {
        console.error(`[highlightPlaceholder] WARNING: Placeholder ${placeholder} not found!`)
      } else {
        console.log(`[highlightPlaceholder] Replaced ${placeholder} with <span class="token-${token.type}">...</span>`)
      }
    }
    
    // 检查是否还有剩余的 PH 占位符
    const remainingPH = html.match(/@__PH_\d+__@/g)
    if (remainingPH) {
      console.error(`[highlightPlaceholder] ERROR: ${remainingPH.length} PH placeholders still in HTML: ${remainingPH.join(', ')}`)
    }
    
    return html
  }
  
  // TypeScript/JavaScript 高亮
  private static highlightTypeScript(html: string): string {
    const tokens: TokenInfo[] = []
    let counter: number = 0
    
    const addToken = (match: string, type: string): string => {
      tokens.push({ type, content: match })
      return `@__PH_${counter++}__@`
    }
    
    // 1. 字符串和正则表达式（最先处理）
    // 正则表达式 /pattern/flags
    html = html.replace(/\/[^\/\n]+\/[gimsuvy]*/g, (m) => addToken(m, 'string'))
    html = html.replace(/"[^"]*"/g, (m) => addToken(m, 'string'))
    html = html.replace(/'[^']*'/g, (m) => addToken(m, 'string'))

    // 2. 注释
    html = html.replace(/\/\/.*$/gm, (m) => addToken(m, 'comment'))
    html = html.replace(/\/\*[\s\S]*?\*\//g, (m) => addToken(m, 'comment'))
    
    // 3. 关键字
    const keywords: string[] = ['const', 'let', 'var', 'function', 'return', 'if', 'else', 'for', 'while', 'do', 'switch', 'case', 'default',
                               'class', 'interface', 'extends', 'implements', 'import', 'export', 'from',
                               'async', 'await', 'new', 'this', 'typeof', 'void', 'number', 'string', 'boolean',
                               'true', 'false', 'null', 'undefined', 'try', 'catch', 'finally', 'throw',
                               'enum', 'type', 'namespace', 'module', 'declare', 'abstract', 'readonly',
                               'super', 'in', 'of', 'instanceof', 'keyof', 'infer', 'is', 'as', 'template',
                               'break', 'continue', 'debugger', 'with', 'yield', 'static', 'public', 'private', 'protected']
    for (const kw of keywords) {
      const pattern: RegExp = new RegExp(`\\b${kw}\\b`, 'g')
      html = html.replace(pattern, (m) => addToken(m, 'keyword'))
    }
    
    // 4. 常量（全大写的标识符，排除 PH_ 开头的占位符）
    html = html.replace(/\b(?!PH_)[A-Z][A-Z_0-9]*\b/g, (m) => addToken(m, 'constant'))
    
    // 5. 数字 - FIX: 使用(?<!\w)(?!\w)替代\b，支持_分隔符、浮点数、科学计数法
    html = html.replace(/(?<!\w)(?!PH_)(0[xX][0-9a-fA-F_]+|0[oO][0-7_]+|0[bB][01_]+|\d[\d_]*\.?\d*([eE][+-]?\d+)?n?)(?!\w)/g, (m) => addToken(m, 'number'))

    // 6. 装饰器/注解 @decorator
    html = html.replace(/@(?!__PH_)\w+/g, (m) => addToken(m, 'keyword'))

    // 7. 函数名 - FIX: 排除 __PH_ 开头的占位符
    html = html.replace(/(?!__PH_)\w+(?=\()/g, (m) => addToken(m, 'function'))

    return HTMLGenerator.highlightPlaceholder(html, tokens)
  }

  // Java 高亮
  private static highlightJava(html: string): string {
    const tokens: TokenInfo[] = []
    let counter: number = 0
    
    const addToken = (match: string, type: string): string => {
      tokens.push({ type, content: match })
      return `@__PH_${counter++}__@`
    }
    
    // 字符串和字符字面量
    html = html.replace(/"[^"]*"/g, (m) => addToken(m, 'string'))
    html = html.replace(/'[^']*'/g, (m) => addToken(m, 'string'))
    
    // 注释
    html = html.replace(/\/\/.*$/gm, (m) => addToken(m, 'comment'))
    html = html.replace(/\/\*[\s\S]*?\*\//g, (m) => addToken(m, 'comment'))
    
    // 关键字
    const keywords: string[] = ['public', 'private', 'protected', 'class', 'interface', 'extends', 'implements',
                               'static', 'final', 'void', 'return', 'if', 'else', 'for', 'while', 'do', 'switch', 'case', 'default',
                               'new', 'break', 'continue',
                               'byte', 'short', 'int', 'long', 'String', 'boolean', 'char', 'float', 'double', 'import', 'package',
                               'true', 'false', 'null', 'try', 'catch', 'finally', 'throw', 'enum',
                               'abstract', 'native', 'strictfp', 'synchronized', 'transient', 'volatile',
                               'super', 'this', 'instanceof', 'goto', 'const', 'override']
    for (const kw of keywords) {
      const pattern: RegExp = new RegExp(`\\b${kw}\\b`, 'g')
      html = html.replace(pattern, (m) => addToken(m, 'keyword'))
    }
    
    // 常量（全大写的标识符，排除 PH_ 开头的占位符）
    html = html.replace(/\b(?!PH_)[A-Z][A-Z_0-9]*\b/g, (m) => addToken(m, 'constant'))
    
    // 数字 - FIX: 使用(?<!\w)(?!\w)替代\b，支持_分隔符、浮点数、科学计数法和后缀
    // Python: 0j (虚数), C/C++: 0LL, 0U, 0UL, 0ULL (整数后缀)
    html = html.replace(/(?<!\w)(?!PH_)(0[xX][0-9a-fA-F_]+|0[oO]?[0-7_]+|0[bB][01_]+|\d[\d_]*\.?\d*([eE][+-]?\d+)?([fFLlUu]+|j)?)(?!\w)/g, (m) => addToken(m, 'number'))

    // 注解 @Annotation
    html = html.replace(/@(?!__PH_)\w+/g, (m) => addToken(m, 'keyword'))

    // 函数名 - FIX: 排除 __PH_ 开头的占位符
    html = html.replace(/(?!__PH_)\w+(?=\()/g, (m) => addToken(m, 'function'))

    return HTMLGenerator.highlightPlaceholder(html, tokens)
  }

  // Python 高亮
  private static highlightPython(html: string): string {
    const tokens: TokenInfo[] = []
    let counter: number = 0
    
    const addToken = (match: string, type: string): string => {
      tokens.push({ type, content: match })
      return `@__PH_${counter++}__@`
    }
    
    // 字符串（多行和单行）
    html = html.replace(/"""[\s\S]*?"""/g, (m) => addToken(m, 'string'))
    html = html.replace(/'''[\s\S]*?'''/g, (m) => addToken(m, 'string'))
    html = html.replace(/"[^"]*"/g, (m) => addToken(m, 'string'))
    html = html.replace(/'[^']*'/g, (m) => addToken(m, 'string'))
    
    // 注释
    html = html.replace(/#.*$/gm, (m) => addToken(m, 'comment'))
    
    // 关键字
    const keywords: string[] = ['def', 'class', 'var', 'return', 'if', 'elif', 'else', 'for', 'while', 'in', 'not', 'and', 'or',
                               'import', 'from', 'as', 'try', 'except', 'finally', 'raise', 'pass', 'break', 'continue',
                               'True', 'False', 'None', 'self', 'lambda', 'yield', 'async', 'await', 'with',
                               'global', 'nonlocal', 'del', 'assert', 'match', 'case', '__init__']
    for (const kw of keywords) {
      const pattern: RegExp = new RegExp(`\\b${kw}\\b`, 'g')
      html = html.replace(pattern, (m) => addToken(m, 'keyword'))
    }
    
    // 类型注解和内置类型
    const builtinTypes: string[] = ['int', 'str', 'float', 'bool', 'list', 'dict', 'tuple', 'set', 'frozenset',
                                    'bytes', 'bytearray', 'memoryview', 'complex', 'object', 'type', 'NoneType',
                                    'Callable', 'Iterable', 'Iterator', 'Generator', 'Sequence', 'Mapping', 'MutableMapping',
                                    'List', 'Dict', 'Tuple', 'Set', 'Optional', 'Union', 'Any', 'Literal', 'Protocol',
                                    'NamedTuple', 'TypedDict', 'Final', 'ClassVar', 'InitVar', 'Self', 'TypeVar', 'Generic']
    for (const typeName of builtinTypes) {
      const pattern: RegExp = new RegExp(`\\b${typeName}\\b`, 'g')
      html = html.replace(pattern, (m) => addToken(m, 'keyword'))
    }
    
    // 常量（全大写的标识符，排除关键字 True/False/None 和 PH_ 开头的占位符）
    html = html.replace(/\b(?<!\bTrue|False|None)(?!PH_)[A-Z][A-Z_0-9]*\b/g, (m) => addToken(m, 'constant'))
    
    // 数字 - FIX: 使用(?<!\w)(?!\w)替代\b，支持_分隔符、浮点数、科学计数法和后缀
    // Python 支持: 123, 123.5, 1e10, 0j, 1j, 1.5j (虚数)
    html = html.replace(/(?<!\w)(?!PH_)(0[xX][0-9a-fA-F_]+|0[oO]?[0-7_]+|0[bB][01_]+|\d[\d_]*\.?\d*([eE][+-]?\d+)?j?)(?!\w)/g, (m) => addToken(m, 'number'))

    // 装饰器 @decorator
    html = html.replace(/@(?!__PH_)\w+/g, (m) => addToken(m, 'keyword'))

    return HTMLGenerator.highlightPlaceholder(html, tokens)
  }

  // C/C++ 高亮
  private static highlightC(html: string): string {
    const tokens: TokenInfo[] = []
    let counter: number = 0
    
    const addToken = (match: string, type: string): string => {
      tokens.push({ type, content: match })
      return `@__PH_${counter++}__@`
    }
    
    // 预处理指令
    html = html.replace(/#\s*include\s+&lt;[^&]+&gt;/g, (m) => addToken(m, 'keyword'))
    html = html.replace(/#\s*define\s+(?!__PH_)\w+/g, (m) => addToken(m, 'keyword'))
    html = html.replace(/#\s*ifdef\s+(?!__PH_)\w+/g, (m) => addToken(m, 'keyword'))
    html = html.replace(/#\s*ifndef\s+(?!__PH_)\w+/g, (m) => addToken(m, 'keyword'))
    html = html.replace(/#\s*elif\s+(?!__PH_).*/g, (m) => addToken(m, 'keyword'))
    html = html.replace(/#\s*else/g, (m) => addToken(m, 'keyword'))
    html = html.replace(/#\s*endif/g, (m) => addToken(m, 'keyword'))
    
    // 字符串和字符字面量
    html = html.replace(/"[^"]*"/g, (m) => addToken(m, 'string'))
    html = html.replace(/'[^']*'/g, (m) => addToken(m, 'string'))
    
    // 注释
    html = html.replace(/\/\/.*$/gm, (m) => addToken(m, 'comment'))
    html = html.replace(/\/\*[\s\S]*?\*\//g, (m) => addToken(m, 'comment'))
    
    // 关键字 - 按长度从长到短排序，确保长的先匹配
    const keywords: string[] = ['const_cast', 'static_cast', 'dynamic_cast', 'reinterpret_cast', 'static_assert',
                               'namespace', 'template', 'typename', 'constexpr', 'noexcept', 'alignof', 'alignas',
                               'char16_t', 'char32_t', 'char8_t', 'wchar_t', 'nullptr',
                               'signed', 'unsigned', 'volatile', 'restrict', 'explicit', 'virtual', 'override', 'mutable',
                               'friend', 'delete', 'typeid', 'decltype', 'sizeof', 'struct', 'typedef', 'static',
                               'const', 'break', 'continue', 'switch', 'return', 'while', 'class', 'public',
                               'private', 'protected', 'extern', 'inline', 'delete', 'throw', 'catch', 'enum',
                               'union', 'auto', 'register', 'goto', 'true', 'false', 'bool', 'int', 'char',
                               'float', 'double', 'void', 'long', 'short', 'if', 'else', 'for', 'do', 'case',
                               'default', 'new', 'try', 'this', 'NULL']
    // 按长度从长到短排序
    keywords.sort((a, b) => b.length - a.length)
    for (const kw of keywords) {
      const pattern: RegExp = new RegExp(`\\b${kw}\\b`, 'g')
      html = html.replace(pattern, (m) => addToken(m, 'keyword'))
    }
    
    // 宏定义常量（全大写的标识符，排除 PH_ 开头的占位符）
    html = html.replace(/\b(?!PH_)[A-Z][A-Z_0-9]*\b/g, (m) => addToken(m, 'constant'))
    
    // 数字 - FIX: 使用(?<!\w)(?!\w)替代\b，支持_分隔符、浮点数、科学计数法和后缀
    // C/C++ 支持: 123, 123u, 123U, 123l, 123L, 123ul, 123UL, 123ll, 123LL, 123ull, 123ULL
    // 浮点数: 1.5, 1.5f, 1.5F, 1.5l, 1.5L, 1e10, 1e10f
    html = html.replace(/(?<!\w)(?!PH_)(0[xX][0-9a-fA-F_]+|0[oO]?[0-7_]+|0[bB][01_]+|\d[\d_]*\.?\d*([eE][+-]?\d+)?([fFLlUu]+)?)(?!\w)/g, (m) => addToken(m, 'number'))

    return HTMLGenerator.highlightPlaceholder(html, tokens)
  }

  // JSON 高亮
  private static highlightJSON(html: string): string {
    const tokens: TokenInfo[] = []
    let counter: number = 0
    
    const addToken = (match: string, type: string): string => {
      tokens.push({ type, content: match })
      return `@__PH_${counter++}__@`
    }
    
    // 字符串（支持转义引号 \"）
    html = html.replace(/"(?:[^"\\]|\\.)*"/g, (m) => addToken(m, 'string'))
    
    // 数字 - FIX: 使用(?<!\w)(?!\w)替代\b，支持_分隔符、浮点数、科学计数法和后缀
    html = html.replace(/(?<!\w)(?!PH_)(0[xX][0-9a-fA-F_]+|0[oO]?[0-7_]+|0[bB][01_]+|\d[\d_]*\.?\d*([eE][+-]?\d+)?[fFLl]?)(?!\w)/g, (m) => addToken(m, 'number'))
    
    // 布尔值和 null
    const keywords: string[] = ['true', 'false', 'null']
    for (const kw of keywords) {
      const pattern: RegExp = new RegExp(`\\b${kw}\\b`, 'g')
      html = html.replace(pattern, (m) => addToken(m, 'keyword'))
    }
    
    return HTMLGenerator.highlightPlaceholder(html, tokens)
  }
  
  // Go 高亮
  private static highlightGo(html: string): string {
    const tokens: TokenInfo[] = []
    let counter: number = 0
    
    const addToken = (match: string, type: string): string => {
      tokens.push({ type, content: match })
      return `@__PH_${counter++}__@`
    }
    
    // 字符串（支持双引号，Go 还支持 raw string ``）
    html = html.replace(/`[^`]*`/g, (m) => addToken(m, 'string'))
    html = html.replace(/"[^"]*"/g, (m) => addToken(m, 'string'))
    
    // 注释
    html = html.replace(/\/\/.*$/gm, (m) => addToken(m, 'comment'))
    html = html.replace(/\/\*[\s\S]*?\*\//g, (m) => addToken(m, 'comment'))
    
    // 关键字
    const keywords: string[] = ['package', 'import', 'func', 'var', 'const', 'type', 'struct', 'interface',
                               'map', 'chan', 'go', 'defer', 'return', 'if', 'else', 'for', 'range',
                               'switch', 'case', 'default', 'break', 'continue', 'fallthrough',
                               'nil', 'true', 'false', 'iota', 'make', 'new', 'len', 'cap', 'append',
                               'int', 'int8', 'int16', 'int32', 'int64', 'uint', 'uint8', 'uint16', 'uint32', 'uint64',
                               'float32', 'float64', 'string', 'bool', 'byte', 'rune', 'error', 'select']
    for (const kw of keywords) {
      const pattern: RegExp = new RegExp(`\\b${kw}\\b`, 'g')
      html = html.replace(pattern, (m) => addToken(m, 'keyword'))
    }
    
    // 常量（全大写的标识符，排除 PH_ 开头的占位符）
    html = html.replace(/\b(?!PH_)[A-Z][A-Z_0-9]*\b/g, (m) => addToken(m, 'constant'))
    
    // 数字 - FIX: 使用(?<!\w)(?!\w)替代\b，支持_分隔符、浮点数、科学计数法
    html = html.replace(/(?<!\w)(?!PH_)(0[xX][0-9a-fA-F_]+|0[oO]?[0-7_]+|0[bB][01_]+|\d[\d_]*\.?\d*([eE][+-]?\d+)?)(?!\w)/g, (m) => addToken(m, 'number'))
    
    return HTMLGenerator.highlightPlaceholder(html, tokens)
  }
  
  // Swift 高亮
  private static highlightSwift(html: string): string {
    const tokens: TokenInfo[] = []
    let counter: number = 0
    
    const addToken = (match: string, type: string): string => {
      tokens.push({ type, content: match })
      return `@__PH_${counter++}__@`
    }
    
    // 字符串（支持多行 """ 和单行 "，以及插值 \()）
    html = html.replace(/"""[\s\S]*?"""/g, (m) => addToken(m, 'string'))
    html = html.replace(/"[^"]*"/g, (m) => addToken(m, 'string'))
    html = html.replace(/'[^']*'/g, (m) => addToken(m, 'string'))
    
    // 注释
    html = html.replace(/\/\/.*$/gm, (m) => addToken(m, 'comment'))
    html = html.replace(/\/\*[\s\S]*?\*\//g, (m) => addToken(m, 'comment'))
    
    // 关键字
    const keywords: string[] = ['import', 'func', 'var', 'let', 'class', 'struct', 'enum', 'protocol',
                               'extension', 'public', 'private', 'internal', 'fileprivate', 'open',
                               'static', 'final', 'mutating', 'lazy', 'weak', 'unowned',
                               'override', 'return', 'if', 'else', 'guard', 'switch', 'case', 'default',
                               'for', 'while', 'repeat', 'in', 'where', 'break', 'continue', 'fallthrough',
                               'self', 'Self', 'init', 'deinit', 'subscript', 'operator', 'precedence',
                               'nil', 'true', 'false', 'try', 'catch', 'throw', 'throws', 'rethrows',
                               'async', 'await', 'associatedtype', 'typealias', 'defer', 'do',
                               'Int', 'String', 'Double', 'Float', 'Bool', 'Array', 'Dictionary', 'Optional',
                               'some', 'any', 'is', 'as', 'Hashable', 'Codable', 'Sendable']
    for (const kw of keywords) {
      const pattern: RegExp = new RegExp(`\\b${kw}\\b`, 'g')
      html = html.replace(pattern, (m) => addToken(m, 'keyword'))
    }
    
    // 数字 - FIX: 使用(?<!\w)(?!\w)替代\b，支持_分隔符、浮点数、科学计数法
    html = html.replace(/(?<!\w)(?!PH_)(0[xX][0-9a-fA-F_]+|0[oO][0-7_]+|0[bB][01_]+|\d[\d_]*\.?\d*([eE][+-]?\d+)?)(?!\w)/g, (m) => addToken(m, 'number'))
    
    // 属性包装器 @ - FIX: 排除占位符格式 @__PH_
    html = html.replace(/@(?!__PH_)\w+/g, (m) => addToken(m, 'keyword'))
    
    // 常量（全大写的标识符，但排除 PH_ 开头的占位符）
    html = html.replace(/\b(?!PH_)[A-Z][A-Z_0-9]*\b/g, (m) => addToken(m, 'constant'))
    
    return HTMLGenerator.highlightPlaceholder(html, tokens)
  }
  
  // Kotlin 高亮
  private static highlightKotlin(html: string): string {
    const tokens: TokenInfo[] = []
    let counter: number = 0
    
    const addToken = (match: string, type: string): string => {
      tokens.push({ type, content: match })
      return `@__PH_${counter++}__@`
    }
    
    // 字符串（支持多行 """ 和单行 "）
    html = html.replace(/"""[\s\S]*?"""/g, (m) => addToken(m, 'string'))
    html = html.replace(/"[^"]*"/g, (m) => addToken(m, 'string'))
    html = html.replace(/'[^']*'/g, (m) => addToken(m, 'string'))
    
    // 注释
    html = html.replace(/\/\/.*$/gm, (m) => addToken(m, 'comment'))
    html = html.replace(/\/\*[\s\S]*?\*\//g, (m) => addToken(m, 'comment'))
    
    // 关键字
    const keywords: string[] = ['package', 'import', 'fun', 'val', 'var', 'const', 'lateinit',
                               'class', 'interface', 'object', 'data', 'sealed', 'open', 'abstract',
                               'public', 'private', 'protected', 'internal', 'final',
                               'override', 'companion', 'init', 'constructor', 'by', 'delegate',
                               'return', 'if', 'else', 'when', 'for', 'while', 'do', 'break', 'continue',
                               'try', 'catch', 'finally', 'throw', 'this', 'super',
                               'null', 'true', 'false', 'is', 'in', '!in', 'as', 'as?', 'typeof',
                               'suspend', 'inline', 'noinline', 'crossinline', 'reified',
                               'Int', 'Long', 'Short', 'Byte', 'Float', 'Double', 'Boolean', 'Char',
                               'String', 'Unit', 'Nothing', 'Any', 'List', 'Map', 'Set', 'Array',
                               'enum', 'out', 'where', 'field', 'property', 'receiver',
                               'setparam', 'param', 'expect', 'actual']
    for (const kw of keywords) {
      const pattern: RegExp = new RegExp(`\\b${kw}\\b`, 'g')
      html = html.replace(pattern, (m) => addToken(m, 'keyword'))
    }
    
    // 常量（全大写的标识符，但排除 PH_ 开头的占位符）
    html = html.replace(/\b(?!PH_)[A-Z][A-Z_0-9]*\b/g, (m) => addToken(m, 'constant'))
    
    // 数字 - FIX: 使用(?<!\w)(?!\w)替代\b，支持_分隔符、二进制、十六进制、浮点数、科学计数法和后缀
    html = html.replace(/(?<!\w)(?!PH_)(0[xX][0-9a-fA-F_]+|0[bB][01_]+|\d[\d_]*\.?\d*([eE][+-]?\d+)?[fFLl]?)(?!\w)/g, (m) => addToken(m, 'number'))
    
    // 注解 @ - FIX: 排除占位符格式 @__PH_
    html = html.replace(/@(?!__PH_)\w+/g, (m) => addToken(m, 'keyword'))
    
    return HTMLGenerator.highlightPlaceholder(html, tokens)
  }
}
