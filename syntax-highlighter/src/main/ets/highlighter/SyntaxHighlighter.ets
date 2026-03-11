import { TokenInfo, HighlightOptions, Language } from '../types/index'

export class SyntaxHighlighter {
  static highlight(code: string, options: HighlightOptions): string {
    let html: string = code.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    
    const language = options.language.toLowerCase()
    
    switch (language) {
      case 'typescript':
      case 'javascript':
      case 'ts':
      case 'js':
        return SyntaxHighlighter.highlightTypeScript(html)
      case 'java':
        return SyntaxHighlighter.highlightJava(html)
      case 'python':
      case 'py':
        return SyntaxHighlighter.highlightPython(html)
      case 'c':
      case 'cpp':
      case 'c++':
        return SyntaxHighlighter.highlightC(html)
      case 'json':
        return SyntaxHighlighter.highlightJSON(html)
      case 'go':
        return SyntaxHighlighter.highlightGo(html)
      case 'swift':
        return SyntaxHighlighter.highlightSwift(html)
      case 'kotlin':
      case 'kt':
        return SyntaxHighlighter.highlightKotlin(html)
      default:
        return html
    }
  }
  
  private static highlightPlaceholder(html: string, tokens: TokenInfo[]): string {
    for (let i: number = tokens.length - 1; i >= 0; i--) {
      const token: TokenInfo = tokens[i]
      const placeholder: string = `@__PH_${i}__@`
      const span: string = `<span class="token-${token.type}">${token.content}</span>`
      
      html = html.replace(new RegExp(placeholder.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g'), span)
    }
    
    return html
  }
  
  private static highlightTypeScript(html: string): string {
    const tokens: TokenInfo[] = []
    let counter: number = 0
    
    const addToken = (match: string, type: string): string => {
      tokens.push({ type, content: match })
      return `@__PH_${counter++}__@`
    }
    
    html = html.replace(/\/[^\/\n]+\/[gimsuvy]*/g, (m) => addToken(m, 'string'))
    html = html.replace(/"[^"]*"/g, (m) => addToken(m, 'string'))
    html = html.replace(/'[^']*'/g, (m) => addToken(m, 'string'))
    html = html.replace(/\/\/.*$/gm, (m) => addToken(m, 'comment'))
    html = html.replace(/\/\*[\s\S]*?\*\//g, (m) => addToken(m, 'comment'))
    
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
    
    html = html.replace(/\b(?!PH_)[A-Z][A-Z_0-9]*\b/g, (m) => addToken(m, 'constant'))
    html = html.replace(/(?<!\w)(?!PH_)(0[xX][0-9a-fA-F_]+|0[oO][0-7_]+|0[bB][01_]+|\d[\d_]*\.?\d*([eE][+-]?\d+)?n?)(?!\w)/g, (m) => addToken(m, 'number'))
    html = html.replace(/@(?!__PH_)\w+/g, (m) => addToken(m, 'keyword'))
    html = html.replace(/(?!__PH_)\w+(?=\()/g, (m) => addToken(m, 'function'))

    return SyntaxHighlighter.highlightPlaceholder(html, tokens)
  }

  private static highlightJava(html: string): string {
    const tokens: TokenInfo[] = []
    let counter: number = 0
    
    const addToken = (match: string, type: string): string => {
      tokens.push({ type, content: match })
      return `@__PH_${counter++}__@`
    }
    
    html = html.replace(/"[^"]*"/g, (m) => addToken(m, 'string'))
    html = html.replace(/'[^']*'/g, (m) => addToken(m, 'string'))
    html = html.replace(/\/\/.*$/gm, (m) => addToken(m, 'comment'))
    html = html.replace(/\/\*[\s\S]*?\*\//g, (m) => addToken(m, 'comment'))
    
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
    
    html = html.replace(/\b(?!PH_)[A-Z][A-Z_0-9]*\b/g, (m) => addToken(m, 'constant'))
    html = html.replace(/(?<!\w)(?!PH_)(0[xX][0-9a-fA-F_]+|0[oO]?[0-7_]+|0[bB][01_]+|\d[\d_]*\.?\d*([eE][+-]?\d+)?([fFLlUu]+|j)?)(?!\w)/g, (m) => addToken(m, 'number'))
    html = html.replace(/@(?!__PH_)\w+/g, (m) => addToken(m, 'keyword'))
    html = html.replace(/(?!__PH_)\w+(?=\()/g, (m) => addToken(m, 'function'))

    return SyntaxHighlighter.highlightPlaceholder(html, tokens)
  }

  private static highlightPython(html: string): string {
    const tokens: TokenInfo[] = []
    let counter: number = 0
    
    const addToken = (match: string, type: string): string => {
      tokens.push({ type, content: match })
      return `@__PH_${counter++}__@`
    }
    
    html = html.replace(/"""[\s\S]*?"""/g, (m) => addToken(m, 'string'))
    html = html.replace(/'''[\s\S]*?'''/g, (m) => addToken(m, 'string'))
    html = html.replace(/"[^"]*"/g, (m) => addToken(m, 'string'))
    html = html.replace(/'[^']*'/g, (m) => addToken(m, 'string'))
    html = html.replace(/#.*$/gm, (m) => addToken(m, 'comment'))
    
    const keywords: string[] = ['def', 'class', 'var', 'return', 'if', 'elif', 'else', 'for', 'while', 'in', 'not', 'and', 'or',
                               'import', 'from', 'as', 'try', 'except', 'finally', 'raise', 'pass', 'break', 'continue',
                               'True', 'False', 'None', 'self', 'lambda', 'yield', 'async', 'await', 'with',
                               'global', 'nonlocal', 'del', 'assert', 'match', 'case', '__init__']
    for (const kw of keywords) {
      const pattern: RegExp = new RegExp(`\\b${kw}\\b`, 'g')
      html = html.replace(pattern, (m) => addToken(m, 'keyword'))
    }
    
    const builtinTypes: string[] = ['int', 'str', 'float', 'bool', 'list', 'dict', 'tuple', 'set', 'frozenset',
                                    'bytes', 'bytearray', 'memoryview', 'complex', 'object', 'type', 'NoneType',
                                    'Callable', 'Iterable', 'Iterator', 'Generator', 'Sequence', 'Mapping', 'MutableMapping',
                                    'List', 'Dict', 'Tuple', 'Set', 'Optional', 'Union', 'Any', 'Literal', 'Protocol',
                                    'NamedTuple', 'TypedDict', 'Final', 'ClassVar', 'InitVar', 'Self', 'TypeVar', 'Generic']
    for (const typeName of builtinTypes) {
      const pattern: RegExp = new RegExp(`\\b${typeName}\\b`, 'g')
      html = html.replace(pattern, (m) => addToken(m, 'keyword'))
    }
    
    html = html.replace(/\b(?<!\bTrue|False|None)(?!PH_)[A-Z][A-Z_0-9]*\b/g, (m) => addToken(m, 'constant'))
    html = html.replace(/(?<!\w)(?!PH_)(0[xX][0-9a-fA-F_]+|0[oO]?[0-7_]+|0[bB][01_]+|\d[\d_]*\.?\d*([eE][+-]?\d+)?j?)(?!\w)/g, (m) => addToken(m, 'number'))
    html = html.replace(/@(?!__PH_)\w+/g, (m) => addToken(m, 'keyword'))

    return SyntaxHighlighter.highlightPlaceholder(html, tokens)
  }

  private static highlightC(html: string): string {
    const tokens: TokenInfo[] = []
    let counter: number = 0
    
    const addToken = (match: string, type: string): string => {
      tokens.push({ type, content: match })
      return `@__PH_${counter++}__@`
    }
    
    html = html.replace(/#\s*include\s+&lt;[^&]+&gt;/g, (m) => addToken(m, 'keyword'))
    html = html.replace(/#\s*define\s+(?!__PH_)\w+/g, (m) => addToken(m, 'keyword'))
    html = html.replace(/#\s*ifdef\s+(?!__PH_)\w+/g, (m) => addToken(m, 'keyword'))
    html = html.replace(/#\s*ifndef\s+(?!__PH_)\w+/g, (m) => addToken(m, 'keyword'))
    html = html.replace(/#\s*elif\s+(?!__PH_).*/g, (m) => addToken(m, 'keyword'))
    html = html.replace(/#\s*else/g, (m) => addToken(m, 'keyword'))
    html = html.replace(/#\s*endif/g, (m) => addToken(m, 'keyword'))
    
    html = html.replace(/"[^"]*"/g, (m) => addToken(m, 'string'))
    html = html.replace(/'[^']*'/g, (m) => addToken(m, 'string'))
    html = html.replace(/\/\/.*$/gm, (m) => addToken(m, 'comment'))
    html = html.replace(/\/\*[\s\S]*?\*\//g, (m) => addToken(m, 'comment'))
    
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
    keywords.sort((a, b) => b.length - a.length)
    for (const kw of keywords) {
      const pattern: RegExp = new RegExp(`\\b${kw}\\b`, 'g')
      html = html.replace(pattern, (m) => addToken(m, 'keyword'))
    }
    
    html = html.replace(/\b(?!PH_)[A-Z][A-Z_0-9]*\b/g, (m) => addToken(m, 'constant'))
    html = html.replace(/(?<!\w)(?!PH_)(0[xX][0-9a-fA-F_]+|0[oO]?[0-7_]+|0[bB][01_]+|\d[\d_]*\.?\d*([eE][+-]?\d+)?([fFLlUu]+)?)(?!\w)/g, (m) => addToken(m, 'number'))

    return SyntaxHighlighter.highlightPlaceholder(html, tokens)
  }

  private static highlightJSON(html: string): string {
    const tokens: TokenInfo[] = []
    let counter: number = 0
    
    const addToken = (match: string, type: string): string => {
      tokens.push({ type, content: match })
      return `@__PH_${counter++}__@`
    }
    
    html = html.replace(/"(?:[^"\\]|\\.)*"/g, (m) => addToken(m, 'string'))
    html = html.replace(/(?<!\w)(?!PH_)(0[xX][0-9a-fA-F_]+|0[oO]?[0-7_]+|0[bB][01_]+|\d[\d_]*\.?\d*([eE][+-]?\d+)?[fFLl]?)(?!\w)/g, (m) => addToken(m, 'number'))
    
    const keywords: string[] = ['true', 'false', 'null']
    for (const kw of keywords) {
      const pattern: RegExp = new RegExp(`\\b${kw}\\b`, 'g')
      html = html.replace(pattern, (m) => addToken(m, 'keyword'))
    }
    
    return SyntaxHighlighter.highlightPlaceholder(html, tokens)
  }
  
  private static highlightGo(html: string): string {
    const tokens: TokenInfo[] = []
    let counter: number = 0
    
    const addToken = (match: string, type: string): string => {
      tokens.push({ type, content: match })
      return `@__PH_${counter++}__@`
    }
    
    html = html.replace(/`[^`]*`/g, (m) => addToken(m, 'string'))
    html = html.replace(/"[^"]*"/g, (m) => addToken(m, 'string'))
    html = html.replace(/\/\/.*$/gm, (m) => addToken(m, 'comment'))
    html = html.replace(/\/\*[\s\S]*?\*\//g, (m) => addToken(m, 'comment'))
    
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
    
    html = html.replace(/\b(?!PH_)[A-Z][A-Z_0-9]*\b/g, (m) => addToken(m, 'constant'))
    html = html.replace(/(?<!\w)(?!PH_)(0[xX][0-9a-fA-F_]+|0[oO]?[0-7_]+|0[bB][01_]+|\d[\d_]*\.?\d*([eE][+-]?\d+)?)(?!\w)/g, (m) => addToken(m, 'number'))
    
    return SyntaxHighlighter.highlightPlaceholder(html, tokens)
  }
  
  private static highlightSwift(html: string): string {
    const tokens: TokenInfo[] = []
    let counter: number = 0
    
    const addToken = (match: string, type: string): string => {
      tokens.push({ type, content: match })
      return `@__PH_${counter++}__@`
    }
    
    html = html.replace(/"""[\s\S]*?"""/g, (m) => addToken(m, 'string'))
    html = html.replace(/"[^"]*"/g, (m) => addToken(m, 'string'))
    html = html.replace(/'[^']*'/g, (m) => addToken(m, 'string'))
    html = html.replace(/\/\/.*$/gm, (m) => addToken(m, 'comment'))
    html = html.replace(/\/\*[\s\S]*?\*\//g, (m) => addToken(m, 'comment'))
    
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
    
    html = html.replace(/(?<!\w)(?!PH_)(0[xX][0-9a-fA-F_]+|0[oO][0-7_]+|0[bB][01_]+|\d[\d_]*\.?\d*([eE][+-]?\d+)?)(?!\w)/g, (m) => addToken(m, 'number'))
    html = html.replace(/@(?!__PH_)\w+/g, (m) => addToken(m, 'keyword'))
    html = html.replace(/\b(?!PH_)[A-Z][A-Z_0-9]*\b/g, (m) => addToken(m, 'constant'))
    
    return SyntaxHighlighter.highlightPlaceholder(html, tokens)
  }
  
  private static highlightKotlin(html: string): string {
    const tokens: TokenInfo[] = []
    let counter: number = 0
    
    const addToken = (match: string, type: string): string => {
      tokens.push({ type, content: match })
      return `@__PH_${counter++}__@`
    }
    
    html = html.replace(/"""[\s\S]*?"""/g, (m) => addToken(m, 'string'))
    html = html.replace(/"[^"]*"/g, (m) => addToken(m, 'string'))
    html = html.replace(/'[^']*'/g, (m) => addToken(m, 'string'))
    html = html.replace(/\/\/.*$/gm, (m) => addToken(m, 'comment'))
    html = html.replace(/\/\*[\s\S]*?\*\//g, (m) => addToken(m, 'comment'))
    
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
    
    html = html.replace(/\b(?!PH_)[A-Z][A-Z_0-9]*\b/g, (m) => addToken(m, 'constant'))
    html = html.replace(/(?<!\w)(?!PH_)(0[xX][0-9a-fA-F_]+|0[bB][01_]+|\d[\d_]*\.?\d*([eE][+-]?\d+)?[fFLl]?)(?!\w)/g, (m) => addToken(m, 'number'))
    html = html.replace(/@(?!__PH_)\w+/g, (m) => addToken(m, 'keyword'))
    
    return SyntaxHighlighter.highlightPlaceholder(html, tokens)
  }
}
