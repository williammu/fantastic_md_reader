import { SyntaxHighlighter } from 'syntax-highlighter'
import { TocItem, ParseOptions } from '../types/index'

interface ListStackItem {
  type: string
  items: string[]
}

interface ListLevelItem {
  level: number
  type: string
  items: string[]
}

interface ProtectedContent {
  blocks: string[]
  tags: string[]
}

export class MarkdownParser {
  private static currentLinkReferences: Map<string, string> = new Map()
  
  static parse(md: string, options?: ParseOptions): string {
    let html: string = md
    const saved: ProtectedContent = { blocks: [], tags: [] }
    
    html = html.replace(/\r\n/g, '\n')
    
    const escapedChars: string[] = []
    html = html.replace(/\\(.)/g, (match: string, char: string) => {
      escapedChars.push(char)
      return `\u0003ESCAPE${escapedChars.length - 1}\u0003`
    })
    
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
    
    html = MarkdownParser.parseBlockquotes(html, saved.tags, saved.blocks)
    html = MarkdownParser.extractCodeBlocks(html, saved.blocks)
    html = MarkdownParser.parseLists(html, saved.tags)
    html = MarkdownParser.extractIndentedCodeBlocks(html, saved.blocks)
    html = MarkdownParser.parseTables(html, saved.tags)
    html = MarkdownParser.parseHeaders(html, saved.tags)
    html = MarkdownParser.parseHorizontalRules(html, saved.tags)
    html = MarkdownParser.extractHtmlBlocks(html, saved.tags)
    html = MarkdownParser.parseParagraphs(html, saved.tags)
    html = MarkdownParser.restoreProtectedContent(html, saved)
    
    for (let i = escapedChars.length - 1; i >= 0; i--) {
      html = html.replace(new RegExp(`\u0003ESCAPE${i}\u0003`, 'g'), escapedChars[i])
    }
    
    return html
  }
  
  static extractToc(content: string): TocItem[] {
    const toc: TocItem[] = []
    // 统一换行符为 LF，避免 CRLF 导致正则表达式匹配失败
    const normalizedContent = content.replace(/\r\n/g, '\n')
    const lines = normalizedContent.split('\n')
    
    for (const line of lines) {
      const match = line.match(/^(#{1,6})\s+(.+)$/)
      if (match) {
        const level = match[1].length
        let title = match[2].trim()
        title = title.replace(/\*\*/g, '').replace(/\*/g, '').replace(/~~/g, '').replace(/`/g, '')
        const titleForDisplay = MarkdownParser.removeCustomId(title)
        const anchorId = MarkdownParser.generateAnchorId(title)
        toc.push({ level, title: titleForDisplay, anchorId })
      }
    }
    
    return toc
  }
  
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
          const highlightedCode: string = SyntaxHighlighter.highlight(code, { language: 'text' })
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
      const highlightedCode: string = SyntaxHighlighter.highlight(code, { language: 'text' })
      blocks.push(`<pre><code class="language-text">${highlightedCode}</code></pre>`)
      result.push(`\n\n___CODE_BLOCK_${index}___\n\n`)
    }
    
    return result.join('\n')
  }

  private static extractCodeBlocks(text: string, blocks: string[]): string {
    let result: string = text
    
    result = result.replace(/```(\w*)\n([\s\S]*?)```/g, (match: string, lang: string, code: string) => {
      const index: number = blocks.length
      const language: string = lang || 'text'
      const highlightedCode: string = SyntaxHighlighter.highlight(code, { language })
      blocks.push(`<pre><code class="language-${language}">${highlightedCode}</code></pre>`)
      return `\n\n___CODE_BLOCK_${index}___\n\n`
    })
    
    return result
  }
  
  private static extractHtmlBlocks(text: string, tags: string[]): string {
    const lines: string[] = text.split('\n')
    const processed: string[] = []
    let inHtmlBlock: boolean = false
    let htmlBlockLines: string[] = []
    
    for (let i = 0; i < lines.length; i++) {
      const line: string = lines[i]
      
      if (!inHtmlBlock && line.trim().startsWith('<')) {
        inHtmlBlock = true
        htmlBlockLines.push(line)
      } else if (inHtmlBlock) {
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
          const htmlBlock: string = htmlBlockLines.join('\n')
          const index: number = tags.length
          tags.push(htmlBlock)
          processed.push(`___HTML_TAG_${index}___`)
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
    
    if (inHtmlBlock && htmlBlockLines.length > 0) {
      const htmlBlock: string = htmlBlockLines.join('\n')
      const index: number = tags.length
      tags.push(htmlBlock)
      processed.push(`___HTML_TAG_${index}___`)
    }
    
    return processed.join('\n')
  }
  
  private static protectHtmlTag(tag: string, tags: string[]): string {
    const index: number = tags.length
    tags.push(tag)
    return `___HTML_TAG_${index}___`
  }
  
  private static restoreProtectedContent(text: string, saved: ProtectedContent): string {
    for (let i: number = saved.tags.length - 1; i >= 0; i--) {
      const pattern: string = `___HTML_TAG_${i}___`
      text = text.replace(new RegExp(pattern, 'g'), saved.tags[i])
    }
    for (let i: number = saved.blocks.length - 1; i >= 0; i--) {
      const pattern: string = `___CODE_BLOCK_${i}___`
      text = text.replace(new RegExp(pattern, 'g'), saved.blocks[i])
    }
    return text
  }
  
  private static generateAnchorId(text: string): string {
    let id = text.replace(/<[^>]+>/g, '')
    
    const customIdMatch = id.match(/\{([^}]+)\}$/)
    if (customIdMatch) {
      let customId = customIdMatch[1]
      if (customId.startsWith('#')) {
        customId = customId.substring(1)
      }
      return customId
    }
    
    id = id.toLowerCase()
    id = id.replace(/[\u3000-\u303F\uFF00-\uFFEF!"#$%&'()*+,\-./:;<=>?@[\\\]^_`{|}~]/g, '')
    id = id.replace(/\s+/g, '-')
    id = id.replace(/-+/g, '-')
    id = id.replace(/^-|-$/g, '')
    
    return id || 'heading'
  }

  private static removeCustomId(text: string): string {
    return text.replace(/\s*\{[^}]+\}$/, '')
  }
  
  private static parseHeaders(text: string, tags: string[]): string {
    const lines: string[] = text.split('\n')
    const result: string[] = []
    
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i]
      
      if (line.startsWith('___HTML_TAG_') || line.startsWith('___CODE_BLOCK_')) {
        result.push(line)
        continue
      }
      
      if (i + 1 < lines.length && lines[i + 1].match(/^={3,}$/)) {
        const p1 = line
        const contentWithoutCustomId = MarkdownParser.removeCustomId(p1)
        const processedContent = MarkdownParser.parseInlineElements(contentWithoutCustomId)
        const anchorId = MarkdownParser.generateAnchorId(p1)
        result.push(MarkdownParser.protectHtmlTag(
          `<h1 id="${anchorId}"><a href="#${anchorId}" class="anchor-link">#</a>${processedContent}</h1>`,
          tags
        ))
        i++
        continue
      }
      
      if (i + 1 < lines.length && lines[i + 1].match(/^-{3,}$/)) {
        const p1 = line
        const contentWithoutCustomId = MarkdownParser.removeCustomId(p1)
        const processedContent = MarkdownParser.parseInlineElements(contentWithoutCustomId)
        const anchorId = MarkdownParser.generateAnchorId(p1)
        result.push(MarkdownParser.protectHtmlTag(
          `<h2 id="${anchorId}"><a href="#${anchorId}" class="anchor-link">#</a>${processedContent}</h2>`,
          tags
        ))
        i++
        continue
      }
      
      result.push(line)
    }
    
    text = result.join('\n')
    
    const lines2: string[] = text.split('\n')
    const result2: string[] = []
    
    for (const line of lines2) {
      if (line.startsWith('___HTML_TAG_') || line.startsWith('___CODE_BLOCK_')) {
        result2.push(line)
        continue
      }
      
      let processed = false
      
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
  
  private static parseQuoteContent(quoteLines: string[], tags: string[], blocks: string[]): string {
    const localSaved: ProtectedContent = { blocks: [], tags: [] }
    let html: string = quoteLines.join('\n')
    
    html = html.replace(/\r\n/g, '\n')
    
    const escapedChars: string[] = []
    html = html.replace(/\\(.)/g, (match: string, char: string) => {
      escapedChars.push(char)
      return `\u0003ESCAPE${escapedChars.length - 1}\u0003`
    })
    
    html = MarkdownParser.extractCodeBlocks(html, localSaved.blocks)
    html = MarkdownParser.parseBlockquotes(html, localSaved.tags, localSaved.blocks)
    html = MarkdownParser.parseLists(html, localSaved.tags)
    html = MarkdownParser.parseTables(html, localSaved.tags)
    html = MarkdownParser.parseHeaders(html, localSaved.tags)
    html = MarkdownParser.parseHorizontalRules(html, localSaved.tags)
    html = MarkdownParser.parseParagraphs(html, localSaved.tags)
    
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
    
    for (let i = escapedChars.length - 1; i >= 0; i--) {
      html = html.replace(new RegExp(`\u0003ESCAPE${i}\u0003`, 'g'), escapedChars[i])
    }
    
    return html
  }
  
  private static parseLists(text: string, tags: string[]): string {
    const lines: string[] = text.split('\n')
    const result: string[] = []
    
    let stack: ListLevelItem[] = []
    
    const closeAllLists = (): void => {
      while (stack.length > 0) {
        const list = stack.pop()
        if (list) {
          const tag = list.type
          const items = list.items.join('')
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
    }
    
    for (const line of lines) {
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
        
        let currentList = stack.find(l => l.level === level)
        if (!currentList) {
          currentList = { level, type, items: [] }
          stack.push(currentList)
        }
        
        const processedContent = MarkdownParser.parseInlineElements(content)
        if (isTask) {
          currentList.items.push(`<li class="task-list-item"><input type="checkbox" ${isChecked ? 'checked' : ''} disabled> ${processedContent}</li>`)
        } else {
          currentList.items.push(`<li>${processedContent}</li>`)
        }
      } else {
        closeAllLists()
        result.push(line)
      }
    }
    
    closeAllLists()
    
    return result.join('\n')
  }
  
  private static parseTables(text: string, tags: string[]): string {
    const lines: string[] = text.split('\n')
    const result: string[] = []
    let i: number = 0
    
    while (i < lines.length) {
      const line: string = lines[i]
      
      if (line.startsWith('|') && line.endsWith('|')) {
        const tableLines: string[] = [line]
        let j: number = i + 1
        
        while (j < lines.length && lines[j].startsWith('|') && lines[j].endsWith('|')) {
          tableLines.push(lines[j])
          j++
        }
        
        if (tableLines.length >= 2) {
          const headerCells: string[] = tableLines[0].split('|').filter((c: string) => c.trim().length > 0)
          
          const alignRow: string[] = tableLines[1].split('|').filter((c: string) => c.trim().length > 0)
          const alignments: string[] = alignRow.map((cell: string) => {
            const c: string = cell.trim()
            if (c.startsWith(':') && c.endsWith(':')) return 'center'
            if (c.endsWith(':')) return 'right'
            return 'left'
          })
          
          let thead: string = '<tr>'
          headerCells.forEach((cell: string, index: number) => {
            const align: string = alignments[index] || 'left'
            const processedCell = MarkdownParser.parseInlineElements(cell.trim())
            thead += `<th style="text-align: ${align}">${processedCell}</th>`
          })
          thead += '</tr>'
          
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
  
  private static parseHorizontalRules(text: string, tags: string[]): string {
    return text.replace(/^(\*{3,}|-{3,}|_{3,})$/gm, (match: string) => {
      return MarkdownParser.protectHtmlTag('<hr>', tags)
    })
  }
  
  private static parseParagraphs(text: string, tags: string[]): string {
    const lines: string[] = text.split('\n')
    const result: string[] = []
    let paraLines: string[] = []
    
    for (const line of lines) {
      if (line.trim().length === 0 ||
          line.startsWith('___HTML_TAG_') ||
          line.startsWith('___CODE_BLOCK_')) {
        
        if (paraLines.length > 0) {
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
  
  private static parseInlineElements(text: string): string {
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
    
    text = text.replace(/  \n/g, '<br>')
    text = text.replace(/\\\n/g, '<br>')
    
    text = text.replace(/&amp;/g, '&')
    text = text.replace(/&lt;/g, '<')
    text = text.replace(/&gt;/g, '>')
    text = text.replace(/&quot;/g, '"')
    text = text.replace(/&copy;/g, '©')
    text = text.replace(/&nbsp;/g, ' ')
    
    text = text.replace(/&#(\d+);/g, (match: string, num: string) => {
      return String.fromCharCode(parseInt(num))
    })
    text = text.replace(/&#x([0-9a-fA-F]+);/g, (match: string, hex: string) => {
      return String.fromCharCode(parseInt(hex, 16))
    })
    
    text = text.replace(/`([^`]+)`/g, '<code>$1</code>')
    text = text.replace(/\*\*([^\*]+)\*\*/g, '<strong>$1</strong>')
    text = text.replace(/__([^_]+)__/g, '<strong>$1</strong>')
    text = text.replace(/\*([^\*]+)\*/g, '<em>$1</em>')
    text = text.replace(/\b_([^_]+)_\b/g, '<em>$1</em>')
    text = text.replace(/~~([^~]+)~~/g, '<del>$1</del>')
    text = text.replace(/!\[([^\]]*)\]\(([^)]+)\)/g, '<img src="$2" alt="$1">')
    
    text = MarkdownParser.parseLinksWithNestedBrackets(text)
    
    const linkRefs: Map<string, string> = MarkdownParser.currentLinkReferences
    
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
    
    text = text.replace(/<([\w.-]+@[\w.-]+)>/g, '<a href="mailto:$1">$1</a>')
    text = text.replace(/<(https?:\/\/[^>]+)>/g, '<a href="$1">$1</a>')
    
    text = text.replace(/\u0001TAG(\d+)\u0001/g, (match: string, index: string) => {
      return tagPlaceholders[parseInt(index)] || match
    })
    text = text.replace(/\u0002BLOCK(\d+)\u0002/g, (match: string, index: string) => {
      return blockPlaceholders[parseInt(index)] || match
    })
    
    return text
  }
  
  private static parseLinksWithNestedBrackets(text: string): string {
    let result: string = text
    let pos: number = 0
    
    while (true) {
      const openBracket: number = result.indexOf('[', pos)
      if (openBracket === -1) break
      
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
        pos = openBracket + 1
        continue
      }
      
      const afterCloseBracket: number = closeBracket - 1
      if (afterCloseBracket + 1 >= result.length || result.charAt(afterCloseBracket + 1) !== '(') {
        pos = afterCloseBracket + 1
        continue
      }
      
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
      
      const linkText: string = result.substring(openBracket + 1, afterCloseBracket)
      const url: string = result.substring(openParen + 1, closeParen - 1).trim()
      
      let replacement: string
      if (url.startsWith('#')) {
        replacement = `<a href="${url}" data-anchor-link="true">${linkText}</a>`
      } else {
        replacement = `<a href="${url}">${linkText}</a>`
      }
      
      result = result.substring(0, openBracket) + replacement + result.substring(closeParen)
      pos = openBracket + replacement.length
    }
    
    return result
  }
}
