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
  // 解析 Markdown 为 HTML
  static parse(md: string): string {
    let html: string = md
    const saved: ProtectedContent = { blocks: [], tags: [] }
    
    // 代码块（需要在行内代码之前处理，且不转义内部内容）
    html = MarkdownParser.extractCodeBlocks(html, saved.blocks)
    
    // 引用块
    html = MarkdownParser.parseBlockquotes(html, saved.tags)
    
    // 列表（需要递归处理嵌套）
    html = MarkdownParser.parseLists(html, saved.tags)
    
    // 表格
    html = MarkdownParser.parseTables(html, saved.tags)
    
    // 分割线
    html = MarkdownParser.parseHorizontalRules(html, saved.tags)
    
    // 标题
    html = MarkdownParser.parseHeaders(html, saved.tags)
    
    // 段落（内部已包含行内元素解析）
    html = MarkdownParser.parseParagraphs(html, saved.tags)
    
    // 恢复所有保护的内容
    html = MarkdownParser.restoreProtectedContent(html, saved)
    
    return html
  }
  
  // 提取代码块
  private static extractCodeBlocks(text: string, blocks: string[]): string {
    return text.replace(/```(\w*)\n([\s\S]*?)```/g, (match: string, lang: string, code: string) => {
      const index: number = blocks.length
      const language: string = lang || 'text'
      // 使用 HTMLGenerator 进行语法高亮
      const highlightedCode: string = HTMLGenerator.highlightCode(code, language)
      blocks.push(`<pre><code class="language-${language}">${highlightedCode}</code></pre>`)
      return `\n\n___CODE_BLOCK_${index}___\n\n`
    })
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
  private static generateAnchorId(text: string): string {
    // 移除 HTML 标签
    let id = text.replace(/<[^>]+>/g, '')
    // 提取自定义 ID {...}
    const customIdMatch = id.match(/\{([^}]+)\}$/)
    if (customIdMatch) {
      return customIdMatch[1]
    }
    // 没有自定义 ID，生成默认 ID
    // 只保留中文、字母、数字
    id = id.replace(/[^\u4e00-\u9fa5a-zA-Z0-9]/g, '-')
    // 移除连续的 -
    id = id.replace(/-+/g, '-')
    // 移除首尾的 -
    id = id.replace(/^-|-$/g, '')
    // 转为小写
    return id.toLowerCase() || 'heading'
  }

  // 移除自定义 ID {...} 部分
  private static removeCustomId(text: string): string {
    return text.replace(/\s*\{[^}]+\}$/, '')
  }
  
  // 解析标题 # ## ###
  private static parseHeaders(text: string, tags: string[]): string {
    // H1-H6（处理行内元素，添加锚点）
    for (let i: number = 6; i >= 1; i--) {
      const pattern: string = `^#{${i}}\\s+(.+)$`
      const reg: RegExp = new RegExp(pattern, 'gm')
      text = text.replace(reg, (match: string, p1: string) => {
        const contentWithoutCustomId = MarkdownParser.removeCustomId(p1)
        const processedContent = MarkdownParser.parseInlineElements(contentWithoutCustomId)
        const anchorId = MarkdownParser.generateAnchorId(p1)
        return MarkdownParser.protectHtmlTag(
          `<h${i} id="${anchorId}"><a href="#${anchorId}" class="anchor-link">#</a>${processedContent}</h${i}>`,
          tags
        )
      })
    }
    
    // 替代 H1/H2 语法 === ---（处理行内元素，添加锚点）
    text = text.replace(/^(.+)\n={3,}$/gm, (match: string, p1: string) => {
      const contentWithoutCustomId = MarkdownParser.removeCustomId(p1)
      const processedContent = MarkdownParser.parseInlineElements(contentWithoutCustomId)
      const anchorId = MarkdownParser.generateAnchorId(p1)
      return MarkdownParser.protectHtmlTag(
        `<h1 id="${anchorId}"><a href="#${anchorId}" class="anchor-link">#</a>${processedContent}</h1>`,
        tags
      )
    })
    text = text.replace(/^(.+)\n-{3,}$/gm, (match: string, p1: string) => {
      const contentWithoutCustomId = MarkdownParser.removeCustomId(p1)
      const processedContent = MarkdownParser.parseInlineElements(contentWithoutCustomId)
      const anchorId = MarkdownParser.generateAnchorId(p1)
      return MarkdownParser.protectHtmlTag(
        `<h2 id="${anchorId}"><a href="#${anchorId}" class="anchor-link">#</a>${processedContent}</h2>`,
        tags
      )
    })
    
    return text
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
  
  // 解析引用块 > - 支持嵌套和多行
  private static parseBlockquotes(text: string, tags: string[]): string {
    const lines: string[] = text.split('\n')
    const result: string[] = []
    let inQuote: boolean = false
    let quoteLines: string[] = []
    
    for (const line of lines) {
      if (line.startsWith('> ')) {
        inQuote = true
        quoteLines.push(line.substring(2))
      } else if (line.startsWith('>')) {
        // 只有 > 没有内容
        inQuote = true
        quoteLines.push('')
      } else {
        if (inQuote) {
          // 结束引用块
          const content: string = MarkdownParser.processQuoteContent(quoteLines, tags)
          result.push(MarkdownParser.protectHtmlTag(`<blockquote>${content}</blockquote>`, tags))
          inQuote = false
          quoteLines = []
        }
        result.push(line)
      }
    }
    
    // 处理未闭合的引用
    if (inQuote) {
      const content: string = MarkdownParser.processQuoteContent(quoteLines, tags)
      result.push(MarkdownParser.protectHtmlTag(`<blockquote>${content}</blockquote>`, tags))
    }
    
    return result.join('\n')
  }
  
  // 处理引用内容（支持嵌套）
  private static processQuoteContent(lines: string[], tags: string[]): string {
    // 递归处理嵌套引用
    const content: string = lines.join('\n')
    
    // 检查是否有嵌套引用
    const nestedLines: string[] = []
    let hasNested: boolean = false
    
    for (const line of lines) {
      if (line.startsWith('> ')) {
        hasNested = true
        nestedLines.push(line.substring(2))
      } else if (line.startsWith('>')) {
        hasNested = true
        nestedLines.push('')
      } else {
        nestedLines.push(line)
      }
    }
    
    if (hasNested) {
      // 有嵌套，递归处理
      const processed: string = MarkdownParser.parseBlockquotes(nestedLines.join('\n'), tags)
      // 包装段落
      return MarkdownParser.wrapQuoteParagraphs(processed, tags)
    }
    
    // 无嵌套，直接包装段落
    return MarkdownParser.wrapQuoteParagraphs(content, tags)
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
    
    // 代码 `code`
    text = text.replace(/`([^`]+)`/g, '<code>$1</code>')
    
    // 粗体 **text**
    text = text.replace(/\*\*([^\*]+)\*\*/g, '<strong>$1</strong>')
    
    // 斜体 *text* (注意：不使用 _ 作为斜体标记，因为会和占位符冲突)
    text = text.replace(/\*([^\*]+)\*/g, '<em>$1</em>')
    
    // 删除线 ~~text~~
    text = text.replace(/~~([^~]+)~~/g, '<del>$1</del>')
    
    // 图片 ![alt](url)
    text = text.replace(/!\[([^\]]*)\]\(([^)]+)\)/g, '<img src="$2" alt="$1">')
    
    // 链接 [text](url) - 锚点链接添加特殊标记（处理 # 号前后有空格的情况）
    text = text.replace(/\[([^\]]+)\]\(\s*(#\S+)\s*\)/g, '<a href="$2" data-anchor-link="true">$1</a>')
    text = text.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2">$1</a>')
    
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
}
