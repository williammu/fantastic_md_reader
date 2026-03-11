import { HTMLGenerator } from './HTMLGenerator'

// 列表栈项类型
interface ListStackItem {
  type: string
  items: string[]
}

// 列表层级项（用于新列表解析）
interface ListLevelItem {
  level: number
  type: string
  items: string[]
}

// 保护的内容
interface ProtectedContent {
  blocks: string[]
  tags: string[]
}

// 目录项
export interface TocItem {
  level: number
  title: string
  anchorId: string
}

// Markdown 解析器 - 将 Markdown 转换为 HTML
export class MarkdownParser {
  // 存储当前解析过程中的引用式链接定义
  private static currentLinkReferences: Map<string, string> = new Map()
  
  // 解析 Markdown 为 HTML
  static parse(md: string): string {
    let html: string = md
    const saved: ProtectedContent = { blocks: [], tags: [] }
    
    // 统一换行符为 LF，避免 CRLF 导致正则表达式匹配失败
    html = html.replace(/\r\n/g, '\n')
    
    // 先处理转义字符（避免被其他解析器误处理）
    // 使用临时占位符保存转义的字符
    const escapedChars: string[] = []
    html = html.replace(/\\(.)/g, (match: string, char: string) => {
      escapedChars.push(char)
      return `\u0003ESCAPE${escapedChars.length - 1}\u0003`
    })
    
    // 解析引用式链接定义 [id]: url "title"
    MarkdownParser.currentLinkReferences.clear()
    const lines: string[] = html.split('\n')
    const filteredLines: string[] = []
    
    for (const line of lines) {
      const refMatch = line.match(/^\s*\[([^\]]+)\]:\s*(\S+)(?:\s+"([^"]*)")?\s*$/)
      if (refMatch) {
        const id: string = refMatch[1].toLowerCase()
        const url: string = refMatch[2]
        MarkdownParser.currentLinkReferences.set(id, url)
      } else {
        filteredLines.push(line)
      }
    }
    html = filteredLines.join('\n')
    
    // 引用块（内部会自己处理内部的代码块）
    html = MarkdownParser.parseBlockquotes(html, saved.tags, saved.blocks)
    
    // 先提取三个反引号的代码块（避免被其他解析器误处理）
    html = MarkdownParser.extractCodeBlocks(html, saved.blocks)
    
    // 列表（需要递归处理嵌套）
    html = MarkdownParser.parseLists(html, saved.tags)
    
    // 提取缩进代码块（在列表解析之后，避免误识别列表项）
    html = MarkdownParser.extractIndentedCodeBlocks(html, saved.blocks)
    
    // 表格
    html = MarkdownParser.parseTables(html, saved.tags)
    
    // 标题（先处理标题，避免替代语法的===和---被分割线解析器误处理）
    html = MarkdownParser.parseHeaders(html, saved.tags)
    
    // 分割线
    html = MarkdownParser.parseHorizontalRules(html, saved.tags)
    
    // 提取 HTML 块
    html = MarkdownParser.extractHtmlBlocks(html, saved.tags)
    
    // 段落（内部已包含行内元素解析）
    html = MarkdownParser.parseParagraphs(html, saved.tags)
    
    // 恢复所有保护的内容
    html = MarkdownParser.restoreProtectedContent(html, saved)
    
    // 最后恢复转义的字符
    for (let i = escapedChars.length - 1; i >= 0; i--) {
      html = html.replace(new RegExp(`\u0003ESCAPE${i}\u0003`, 'g'), escapedChars[i])
    }
    
    return html
  }
  
  // 提取缩进代码块（4个空格或1个tab）
  private static extractIndentedCodeBlocks(text: string, blocks: string[]): string {
    const lines: string[] = text.split('\n')
    const result: string[] = []
    let inCodeBlock: boolean = false
    let codeLines: string[] = []
    
    for (const line of lines) {
      if (line.startsWith('    ') || line.startsWith('\t')) {
        if (!inCodeBlock) {
          inCodeBlock = true
        }
        if (line.startsWith('    ')) {
          codeLines.push(line.substring(4))
        } else {
          codeLines.push(line.substring(1))
        }
      } else {
        if (inCodeBlock) {
          const index: number = blocks.length
          const code: string = codeLines.join('\n')
          const highlightedCode: string = HTMLGenerator.highlightCode(code, 'text')
          blocks.push(`<pre><code class="language-text">${highlightedCode}</code></pre>`)
          result.push(`\n\n___CODE_BLOCK_${index}___\n\n`)
          inCodeBlock = false
          codeLines = []
        }
        result.push(line)
      }
    }
    
    if (inCodeBlock) {
      const index: number = blocks.length
      const code: string = codeLines.join('\n')
      const highlightedCode: string = HTMLGenerator.highlightCode(code, 'text')
      blocks.push(`<pre><code class="language-text">${highlightedCode}</code></pre>`)
      result.push(`\n\n___CODE_BLOCK_${index}___\n\n`)
    }
    
    return result.join('\n')
  }

  // 提取代码块
  private static extractCodeBlocks(text: string, blocks: string[]): string {
    let result: string = text
    
    // 先提取三个反引号的代码块
    result = result.replace(/```(\w*)\n([\s\S]*?)```/g, (match: string, lang: string, code: string) => {
      const index: number = blocks.length
      const language: string = lang || 'text'
      const highlightedCode: string = HTMLGenerator.highlightCode(code, language)
      blocks.push(`<pre><code class="language-${language}">${highlightedCode}</code></pre>`)
      return `\n\n___CODE_BLOCK_${index}___\n\n`
    })
    
    // 缩进代码块在列表解析之后再处理，避免误识别列表项
    return result
  }
  
  // 提取 HTML 块，避免被包裹在 <p> 标签中
  private static extractHtmlBlocks(text: string, tags: string[]): string {
    let result: string = text
    
    // 匹配以 < 开头，可能前面有空白的行开始的 HTML 块
    // 使用正则匹配完整的 HTML 块（简单处理，不处理嵌套）
    const htmlBlockPattern = /^(\s*<[a-zA-Z][\s\S]*?)(?=\n\s*<[a-zA-Z]|\n\s*$|\n\s*#{1,6}|\n\s*[-*+]\s|\n\s*\d+\.\s|\n\s*```|\n\s*---+|\n\s*___+|\n\s*\*\*\*+)/gm
    
    // 简单处理：匹配以 < 开头的行块，直到遇到空行或块级元素
    const lines: string[] = result.split('\n')
    const processed: string[] = []
    let inHtmlBlock: boolean = false
    let htmlBlockLines: string[] = []
    
    for (let i = 0; i < lines.length; i++) {
      const line: string = lines[i]
      
      // 检查是否是 HTML 块的开始
      if (!inHtmlBlock && line.trim().startsWith('<')) {
        inHtmlBlock = true
        htmlBlockLines.push(line)
      } else if (inHtmlBlock) {
        // 检查是否是 HTML 块的结束（遇到空行或块级元素开始）
        const isBlockElementStart: boolean = 
          line.trim().length === 0 ||
          line.trim().startsWith('#') ||
          !!(line.trim().match(/^[-*+]\s/)) ||
          !!(line.trim().match(/^\d+\.\s/)) ||
          line.trim().startsWith('```') ||
          !!(line.trim().match(/^---+/)) ||
          !!(line.trim().match(/^___+/)) ||
          !!(line.trim().match(/^\*\*\*+/))
        
        if (isBlockElementStart) {
          // 结束 HTML 块
          const htmlBlock: string = htmlBlockLines.join('\n')
          const index: number = tags.length
          tags.push(htmlBlock)
          processed.push(`___HTML_TAG_${index}___`)
          
          // 添加当前行
          processed.push(line)
          
          inHtmlBlock = false
          htmlBlockLines = []
        } else {
          htmlBlockLines.push(line)
        }
      } else {
        processed.push(line)
      }
    }
    
    // 处理最后剩余的 HTML 块
    if (inHtmlBlock && htmlBlockLines.length > 0) {
      const htmlBlock: string = htmlBlockLines.join('\n')
      const index: number = tags.length
      tags.push(htmlBlock)
      processed.push(`___HTML_TAG_${index}___`)
    }
    
    return processed.join('\n')
  }
  
  // 保护 HTML 标签
  private static protectHtmlTag(tag: string, tags: string[]): string {
    const index: number = tags.length
    tags.push(tag)
    return `___HTML_TAG_${index}___`
  }
  
  // 恢复保护的内容
  private static restoreProtectedContent(text: string, saved: ProtectedContent): string {
    // 恢复 HTML 标签（使用正则替换所有）
    for (let i: number = saved.tags.length - 1; i >= 0; i--) {
      const pattern: string = `___HTML_TAG_${i}___`
      text = text.replace(new RegExp(pattern, 'g'), saved.tags[i])
    }
    // 恢复代码块（使用正则替换所有）
    for (let i: number = saved.blocks.length - 1; i >= 0; i--) {
      const pattern: string = `___CODE_BLOCK_${i}___`
      text = text.replace(new RegExp(pattern, 'g'), saved.blocks[i])
    }
    return text
  }
  
  // 生成锚点 ID（支持自定义 ID 语法：{#custom-id}）
  // 符合 GFM 规范：小写、移除标点、空格变连字符
  private static generateAnchorId(text: string): string {
    // 移除 HTML 标签
    let id = text.replace(/<[^>]+>/g, '')
    
    // 提取自定义 ID {...}
    const customIdMatch = id.match(/\{([^}]+)\}$/)
    if (customIdMatch) {
      // 移除可能的 # 前缀
      let customId = customIdMatch[1]
      if (customId.startsWith('#')) {
        customId = customId.substring(1)
      }
      return customId
    }
    
    // GFM 规范：生成默认 ID
    // 1. 转为小写
    id = id.toLowerCase()
    
    // 2. 移除所有标点符号（包括中文标点），但保留空格
    // 中文标点范围：\u3000-\u303F（CJK符号和标点）
    id = id.replace(/[\u3000-\u303F\uFF00-\uFFEF!"#$%&'()*+,\-./:;<=>?@[\\\]^_`{|}~]/g, '')
    
    // 3. 将空格替换为连字符
    id = id.replace(/\s+/g, '-')
    
    // 4. 移除连续的连字符
    id = id.replace(/-+/g, '-')
    
    // 5. 移除首尾的连字符
    id = id.replace(/^-|-$/g, '')
    
    return id || 'heading'
  }

  // 移除自定义 ID {...} 部分
  private static removeCustomId(text: string): string {
    return text.replace(/\s*\{[^}]+\}$/, '')
  }
  
  // 解析标题 # ## ###
  private static parseHeaders(text: string, tags: string[]): string {
    // 先处理替代 H1/H2 语法 === ---（处理行内元素，添加锚点）
    // 但要跳过已经是占位符的行
    const lines: string[] = text.split('\n')
    const result: string[] = []
    
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i]
      
      // 如果是占位符，直接保留
      if (line.startsWith('___HTML_TAG_') || line.startsWith('___CODE_BLOCK_')) {
        result.push(line)
        continue
      }
      
      // 检查是否是替代 H1 语法（下一行是 ===）
      if (i + 1 < lines.length && lines[i + 1].match(/^={3,}$/)) {
        const p1 = line
        const contentWithoutCustomId = MarkdownParser.removeCustomId(p1)
        const processedContent = MarkdownParser.parseInlineElements(contentWithoutCustomId)
        const anchorId = MarkdownParser.generateAnchorId(p1)
        result.push(MarkdownParser.protectHtmlTag(
          `<h1 id="${anchorId}"><a href="#${anchorId}" class="anchor-link">#</a>${processedContent}</h1>`,
          tags
        ))
        i++ // 跳过下一行的 ===
        continue
      }
      
      // 检查是否是替代 H2 语法（下一行是 ---）
      if (i + 1 < lines.length && lines[i + 1].match(/^-{3,}$/)) {
        const p1 = line
        const contentWithoutCustomId = MarkdownParser.removeCustomId(p1)
        const processedContent = MarkdownParser.parseInlineElements(contentWithoutCustomId)
        const anchorId = MarkdownParser.generateAnchorId(p1)
        result.push(MarkdownParser.protectHtmlTag(
          `<h2 id="${anchorId}"><a href="#${anchorId}" class="anchor-link">#</a>${processedContent}</h2>`,
          tags
        ))
        i++ // 跳过下一行的 ---
        continue
      }
      
      result.push(line)
    }
    
    text = result.join('\n')
    
    // 再处理 H1-H6（处理行内元素，添加锚点）
    // 使用逐行处理，避免错误地匹配占位符
    const lines2: string[] = text.split('\n')
    const result2: string[] = []
    
    for (const line of lines2) {
      // 如果是占位符，直接保留
      if (line.startsWith('___HTML_TAG_') || line.startsWith('___CODE_BLOCK_')) {
        result2.push(line)
        continue
      }
      
      let processed = false
      
      // 从 H6 到 H1 依次检查
      for (let i: number = 6; i >= 1; i--) {
        const pattern: string = `^#{${i}}\\s+(.+)$`
        const reg: RegExp = new RegExp(pattern)
        const match = line.match(reg)
        if (match) {
          const p1 = match[1]
          const contentWithoutCustomId = MarkdownParser.removeCustomId(p1)
          const processedContent = MarkdownParser.parseInlineElements(contentWithoutCustomId)
          const anchorId = MarkdownParser.generateAnchorId(p1)
          result2.push(MarkdownParser.protectHtmlTag(
            `<h${i} id="${anchorId}"><a href="#${anchorId}" class="anchor-link">#</a>${processedContent}</h${i}>`,
            tags
          ))
          processed = true
          break
        }
      }
      
      if (!processed) {
        result2.push(line)
      }
    }
    
    return result2.join('\n')
  }
  
  // 提取目录结构
  static extractToc(content: string): TocItem[] {
    const toc: TocItem[] = []
    const lines = content.split('\n')
    
    for (const line of lines) {
      // 匹配 # ## ### 标题
      const match = line.match(/^(#{1,6})\s+(.+)$/)
      if (match) {
        const level = match[1].length
        let title = match[2].trim()
        // 移除行内 Markdown 标记获取纯文本
        title = title.replace(/\*\*/g, '').replace(/\*/g, '').replace(/~~/g, '').replace(/`/g, '')
        // 移除自定义 ID {...}
        const titleForDisplay = MarkdownParser.removeCustomId(title)
        const anchorId = MarkdownParser.generateAnchorId(title)
        toc.push({ level, title: titleForDisplay, anchorId })
      }
    }
    
    return toc
  }
  
  // 解析引用块 > - 支持嵌套和多行（根据 GFM 规范）
  private static parseBlockquotes(text: string, tags: string[], blocks: string[]): string {
    const lines: string[] = text.split('\n')
    const result: string[] = []
    let inQuote: boolean = false
    let quoteLines: string[] = []

    for (const line of lines) {
      if (line.startsWith('> ')) {
        inQuote = true
        quoteLines.push(line.substring(2))
      } else if (line.startsWith('>')) {
        inQuote = true
        quoteLines.push(line.substring(1))
      } else {
        if (inQuote) {
          const content: string = MarkdownParser.parseQuoteContent(quoteLines, tags, blocks)
          result.push(MarkdownParser.protectHtmlTag(`<blockquote>${content}</blockquote>`, tags))
          inQuote = false
          quoteLines = []
        }
        result.push(line)
      }
    }

    if (inQuote) {
      const content: string = MarkdownParser.parseQuoteContent(quoteLines, tags, blocks)
      result.push(MarkdownParser.protectHtmlTag(`<blockquote>${content}</blockquote>`, tags))
    }

    return result.join('\n')
  }
  
  // 解析引用内容（根据 GFM 规范递归解析内部 Markdown）
  private static parseQuoteContent(quoteLines: string[], tags: string[], blocks: string[]): string {
    const localSaved: ProtectedContent = { blocks: [], tags: [] }
    let html: string = quoteLines.join('\n')
    
    // 统一换行符
    html = html.replace(/\r\n/g, '\n')
    
    // 先处理转义字符
    const escapedChars: string[] = []
    html = html.replace(/\\(.)/g, (match: string, char: string) => {
      escapedChars.push(char)
      return `\u0003ESCAPE${escapedChars.length - 1}\u0003`
    })
    
    // 先提取三个反引号的代码块
    html = MarkdownParser.extractCodeBlocks(html, localSaved.blocks)
    
    // 再解析嵌套引用
    html = MarkdownParser.parseBlockquotes(html, localSaved.tags, localSaved.blocks)
    
    // 解析列表
    html = MarkdownParser.parseLists(html, localSaved.tags)
    
    // 解析表格
    html = MarkdownParser.parseTables(html, localSaved.tags)
    
    // 解析标题
    html = MarkdownParser.parseHeaders(html, localSaved.tags)
    
    // 解析分割线
    html = MarkdownParser.parseHorizontalRules(html, localSaved.tags)
    
    // 解析段落
    html = MarkdownParser.parseParagraphs(html, localSaved.tags)
    
    // 把本地保存的内容合并到外部传入的数组中
    // 但是需要重新生成占位符，因为索引变了！
    // 正确的做法是：先把本地的 blocks 和 tags 加到外部的数组
    // 然后把本地的占位符替换为全局的索引
    
    const blocksOffset: number = blocks.length
    for (let i: number = 0; i < localSaved.blocks.length; i++) {
      blocks.push(localSaved.blocks[i])
      html = html.replace(new RegExp(`___CODE_BLOCK_${i}___`, 'g'), `___CODE_BLOCK_${blocksOffset + i}___`)
    }
    
    const tagsOffset: number = tags.length
    for (let i: number = 0; i < localSaved.tags.length; i++) {
      tags.push(localSaved.tags[i])
      html = html.replace(new RegExp(`___HTML_TAG_${i}___`, 'g'), `___HTML_TAG_${tagsOffset + i}___`)
    }
    
    // 恢复转义字符
    for (let i = escapedChars.length - 1; i >= 0; i--) {
      html = html.replace(new RegExp(`\u0003ESCAPE${i}\u0003`, 'g'), escapedChars[i])
    }
    
    return html
  }
  
  // 包装引用内的段落
  private static wrapQuoteParagraphs(text: string, tags: string[]): string {
    const paragraphs: string[] = text.split('\n\n').filter((p: string) => p.trim().length > 0)
    
    return paragraphs.map((p: string) => {
      // 如果已经是 HTML 标签占位符或包含 HTML 标签，不包装
      if (p.startsWith('___HTML_TAG_') || p.includes('___HTML_TAG_')) {
        return p
      }
      // 如果已经是 <p> 标签，不包装
      if (p.includes('<p>')) {
        return p
      }
      // 将换行转为 <br>
      const content: string = p.replace(/\n/g, '<br>')
      return MarkdownParser.protectHtmlTag(`<p>${content}</p>`, tags)
    }).join('')
  }
  
  // 解析列表（支持嵌套）- 简化版，正确处理层级
  private static parseLists(text: string, tags: string[]): string {
    const lines: string[] = text.split('\n')
    const result: string[] = []
    
    // 栈中存储层级列表
    let stack: ListLevelItem[] = []
    
    const closeAllLists = (): void => {
      while (stack.length > 0) {
        const list = stack.pop()
        if (list) {
          const tag = list.type
          const items = list.items.join('')
          const listHtml = `<${tag}>${items}</${tag}>`
          if (stack.length > 0) {
            // 附加到父列表的最后一个项
            const parent = stack[stack.length - 1]
            const lastIdx = parent.items.length - 1
            if (lastIdx >= 0) {
              parent.items[lastIdx] = parent.items[lastIdx].replace(/<\/li>$/, `${listHtml}</li>`)
            }
          } else {
            result.push(MarkdownParser.protectHtmlTag(listHtml, tags))
          }
        }
      }
    }
    
    for (const line of lines) {
      // 匹配列表项
      const ulMatch = line.match(/^(\s*)[-\*+]\s+(.+)$/)
      const olMatch = line.match(/^(\s*)\d+\.\s+(.+)$/)
      const taskMatch = line.match(/^(\s*)[-\*+]\s*\[([ xX])\]\s*(.+)$/)
      
      if (ulMatch || olMatch || taskMatch) {
        let indent = 0
        let content = ''
        let type = ''
        let isTask = false
        let isChecked = false
        
        if (taskMatch) {
          indent = taskMatch[1].length
          isChecked = taskMatch[2].toLowerCase() === 'x'
          content = taskMatch[3]
          type = 'ul'
          isTask = true
        } else if (ulMatch) {
          indent = ulMatch[1].length
          content = ulMatch[2]
          type = 'ul'
        } else if (olMatch) {
          indent = olMatch[1].length
          content = olMatch[2]
          type = 'ol'
        }
        
        const level = Math.floor(indent / 2)
        
        // 关闭比当前层级深的列表（注意：同层级不关闭）
        while (stack.length > 0 && stack[stack.length - 1].level > level) {
          const closed = stack.pop()
          if (closed) {
            const tag = closed.type
            const items = closed.items.join('')
            const listHtml = `<${tag}>${items}</${tag}>`
            if (stack.length > 0) {
              const parent = stack[stack.length - 1]
              const lastIdx = parent.items.length - 1
              if (lastIdx >= 0) {
                parent.items[lastIdx] = parent.items[lastIdx].replace(/<\/li>$/, `${listHtml}</li>`)
              }
            } else {
              result.push(MarkdownParser.protectHtmlTag(listHtml, tags))
            }
          }
        }
        
        // 查找或创建当前层级的列表
        let currentList = stack.find(l => l.level === level)
        if (!currentList) {
          currentList = { level, type, items: [] }
          stack.push(currentList)
        }
        
        // 添加列表项（处理行内元素）
        const processedContent = MarkdownParser.parseInlineElements(content)
        if (isTask) {
          currentList.items.push(`<li class="task-list-item"><input type="checkbox" ${isChecked ? 'checked' : ''} disabled> ${processedContent}</li>`)
        } else {
          currentList.items.push(`<li>${processedContent}</li>`)
        }
      } else {
        // 非列表行，关闭所有列表
        closeAllLists()
        result.push(line)
      }
    }
    
    // 关闭剩余的列表
    closeAllLists()
    
    return result.join('\n')
  }
  
  // 解析表格
  private static parseTables(text: string, tags: string[]): string {
    const lines: string[] = text.split('\n')
    const result: string[] = []
    let i: number = 0
    
    while (i < lines.length) {
      const line: string = lines[i]
      
      // 检查是否是表格行
      if (line.startsWith('|') && line.endsWith('|')) {
        // 找到表格的所有行
        const tableLines: string[] = [line]
        let j: number = i + 1
        
        while (j < lines.length && lines[j].startsWith('|') && lines[j].endsWith('|')) {
          tableLines.push(lines[j])
          j++
        }
        
        // 至少需要表头和分隔行
        if (tableLines.length >= 2) {
          // 解析表头
          const headerCells: string[] = tableLines[0].split('|').filter((c: string) => c.trim().length > 0)
          
          // 解析对齐行
          const alignRow: string[] = tableLines[1].split('|').filter((c: string) => c.trim().length > 0)
          const alignments: string[] = alignRow.map((cell: string) => {
            const c: string = cell.trim()
            if (c.startsWith(':') && c.endsWith(':')) return 'center'
            if (c.endsWith(':')) return 'right'
            return 'left'
          })
          
          // 构建表头（处理行内元素）
          let thead: string = '<tr>'
          headerCells.forEach((cell: string, index: number) => {
            const align: string = alignments[index] || 'left'
            const processedCell = MarkdownParser.parseInlineElements(cell.trim())
            thead += `<th style="text-align: ${align}">${processedCell}</th>`
          })
          thead += '</tr>'
          
          // 构建数据行（处理行内元素）
          let tbody: string = ''
          for (let k: number = 2; k < tableLines.length; k++) {
            const cells: string[] = tableLines[k].split('|').filter((c: string) => c.trim().length > 0)
            tbody += '<tr>'
            cells.forEach((cell: string, index: number) => {
              const align: string = alignments[index] || 'left'
              const processedCell = MarkdownParser.parseInlineElements(cell.trim())
              tbody += `<td style="text-align: ${align}">${processedCell}</td>`
            })
            tbody += '</tr>'
          }
          
          result.push(MarkdownParser.protectHtmlTag(`<table><thead>${thead}</thead><tbody>${tbody}</tbody></table>`, tags))
          i = j
          continue
        }
      }
      
      result.push(line)
      i++
    }
    
    return result.join('\n')
  }
  
  // 解析分割线
  private static parseHorizontalRules(text: string, tags: string[]): string {
    return text.replace(/^(\*{3,}|-{3,}|_{3,})$/gm, (match: string) => {
      return MarkdownParser.protectHtmlTag('<hr>', tags)
    })
  }
  
  // 解析段落 - 修复：先解析行内元素再保护
  private static parseParagraphs(text: string, tags: string[]): string {
    const lines: string[] = text.split('\n')
    const result: string[] = []
    let paraLines: string[] = []
    
    for (const line of lines) {
      // 跳过空行和块级元素
      if (line.trim().length === 0 ||
          line.startsWith('___HTML_TAG_') ||
          line.startsWith('___CODE_BLOCK_')) {
        
        if (paraLines.length > 0) {
          // 合并段落内容，先解析行内元素，再包装成 <p>
          let paraContent: string = paraLines.join('\n')
          paraContent = MarkdownParser.parseInlineElements(paraContent)
          result.push(MarkdownParser.protectHtmlTag(`<p>${paraContent}</p>`, tags))
          paraLines = []
        }
        result.push(line)
      } else {
        paraLines.push(line)
      }
    }
    
    if (paraLines.length > 0) {
      let paraContent: string = paraLines.join('\n')
      paraContent = MarkdownParser.parseInlineElements(paraContent)
      result.push(MarkdownParser.protectHtmlTag(`<p>${paraContent}</p>`, tags))
    }
    
    return result.join('\n')
  }
  
  // 解析行内元素
  private static parseInlineElements(text: string): string {
    // 先把占位符保护起来（替换成不会被解析的格式）
    const tagPlaceholders: string[] = []
    const blockPlaceholders: string[] = []
    
    text = text.replace(/___HTML_TAG_(\d+)___/g, (match: string, index: string) => {
      tagPlaceholders[parseInt(index)] = match
      return `\u0001TAG${index}\u0001`
    })
    
    text = text.replace(/___CODE_BLOCK_(\d+)___/g, (match: string, index: string) => {
      blockPlaceholders[parseInt(index)] = match
      return `\u0002BLOCK${index}\u0002`
    })
    
    // 处理硬换行：行尾两个空格或反斜杠
    text = text.replace(/  \n/g, '<br>')
    text = text.replace(/\\\n/g, '<br>')
    
    // 处理 HTML 实体
    text = text.replace(/&amp;/g, '&')
    text = text.replace(/&lt;/g, '<')
    text = text.replace(/&gt;/g, '>')
    text = text.replace(/&quot;/g, '"')
    text = text.replace(/&copy;/g, '©')
    text = text.replace(/&nbsp;/g, ' ')
    
    // 处理数字字符引用
    text = text.replace(/&#(\d+);/g, (match: string, num: string) => {
      return String.fromCharCode(parseInt(num))
    })
    text = text.replace(/&#x([0-9a-fA-F]+);/g, (match: string, hex: string) => {
      return String.fromCharCode(parseInt(hex, 16))
    })
    
    // 代码 `code`
    text = text.replace(/`([^`]+)`/g, '<code>$1</code>')
    
    // 粗体 **text**
    text = text.replace(/\*\*([^\*]+)\*\*/g, '<strong>$1</strong>')
    
    // 粗体 __text__
    text = text.replace(/__([^_]+)__/g, '<strong>$1</strong>')
    
    // 斜体 *text*
    text = text.replace(/\*([^\*]+)\*/g, '<em>$1</em>')
    
    // 斜体 _text_ (需要确保不是单词中间的下划线)
    text = text.replace(/\b_([^_]+)_\b/g, '<em>$1</em>')
    
    // 删除线 ~~text~~
    text = text.replace(/~~([^~]+)~~/g, '<del>$1</del>')
    
    // 图片 ![alt](url)
    text = text.replace(/!\[([^\]]*)\]\(([^)]+)\)/g, '<img src="$2" alt="$1">')
    
    // 链接 [text](url) - 支持嵌套方括号
    text = MarkdownParser.parseLinksWithNestedBrackets(text)
    
    // 引用式链接 [text][id]
    const linkRefs: Map<string, string> = MarkdownParser.currentLinkReferences
    
    // 处理 [text][id] 格式
    text = text.replace(/\[([^\]]+)\]\[([^\]]*)\]/g, (match: string, textPart: string, idPart: string) => {
      let id: string = (idPart || textPart).toLowerCase()
      if (linkRefs.has(id)) {
        const url: string = linkRefs.get(id)!
        if (url.startsWith('#')) {
          return `<a href="${url}" data-anchor-link="true">${textPart}</a>`
        } else {
          return `<a href="${url}">${textPart}</a>`
        }
      }
      return match
    })
    
    // 自动链接 <url>
    text = text.replace(/<([\w.-]+@[\w.-]+)>/g, '<a href="mailto:$1">$1</a>')
    text = text.replace(/<(https?:\/\/[^>]+)>/g, '<a href="$1">$1</a>')
    
    // 恢复占位符
    text = text.replace(/\u0001TAG(\d+)\u0001/g, (match: string, index: string) => {
      return tagPlaceholders[parseInt(index)] || match
    })
    text = text.replace(/\u0002BLOCK(\d+)\u0002/g, (match: string, index: string) => {
      return blockPlaceholders[parseInt(index)] || match
    })
    
    return text
  }
  
  // 解析链接，支持嵌套方括号
  private static parseLinksWithNestedBrackets(text: string): string {
    let result: string = text
    let pos: number = 0
    
    while (true) {
      // 找到下一个 [ 的位置
      const openBracket: number = result.indexOf('[', pos)
      if (openBracket === -1) break
      
      // 找到匹配的 ]，支持嵌套
      let balance: number = 1
      let closeBracket: number = openBracket + 1
      while (closeBracket < result.length && balance > 0) {
        if (result.charAt(closeBracket) === '[') {
          balance++
        } else if (result.charAt(closeBracket) === ']') {
          balance--
        }
        closeBracket++
      }
      
      if (balance !== 0) {
        // 没有匹配的 ]，跳过这个 [
        pos = openBracket + 1
        continue
      }
      
      // 检查后面是否是 (url) 格式
      const afterCloseBracket: number = closeBracket - 1
      if (afterCloseBracket + 1 >= result.length || result.charAt(afterCloseBracket + 1) !== '(') {
        pos = afterCloseBracket + 1
        continue
      }
      
      // 找到匹配的 )
      const openParen: number = afterCloseBracket + 1
      let parenBalance: number = 1
      let closeParen: number = openParen + 1
      while (closeParen < result.length && parenBalance > 0) {
        if (result.charAt(closeParen) === '(') {
          parenBalance++
        } else if (result.charAt(closeParen) === ')') {
          parenBalance--
        }
        closeParen++
      }
      
      if (parenBalance !== 0) {
        pos = openParen + 1
        continue
      }
      
      // 提取链接文本和 URL
      const linkText: string = result.substring(openBracket + 1, afterCloseBracket)
      const url: string = result.substring(openParen + 1, closeParen - 1).trim()
      
      // 生成替换后的 HTML
      let replacement: string
      if (url.startsWith('#')) {
        replacement = `<a href="${url}" data-anchor-link="true">${linkText}</a>`
      } else {
        replacement = `<a href="${url}">${linkText}</a>`
      }
      
      // 替换原文
      result = result.substring(0, openBracket) + replacement + result.substring(closeParen)
      
      // 移动到替换后的位置继续查找
      pos = openBracket + replacement.length
    }
    
    return result
  }
}
