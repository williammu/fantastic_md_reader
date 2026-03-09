// 段落分割器 - 将 Markdown 内容分割为适合朗读的段落

export interface Paragraph {
  id: number          // 段落索引
  text: string        // 朗读文本
  type: ParagraphType // 段落类型
  raw: string         // 原始 Markdown
}

export enum ParagraphType {
  TEXT = 'text',           // 普通文本
  HEADING = 'heading',     // 标题
  LIST_ITEM = 'list_item', // 列表项
  QUOTE = 'quote',         // 引用
  CODE = 'code',           // 代码块
  TABLE = 'table',         // 表格
  EMPTY = 'empty'          // 空段落（跳过）
}

// 段落分割器
export class ParagraphSplitter {
  /**
   * 分割 Markdown 内容为朗读段落
   */
  static split(md: string): Paragraph[] {
    const paragraphs: Paragraph[] = []
    const lines: string[] = md.split('\n')
    let currentBlock: string[] = []
    let inCodeBlock: boolean = false
    let codeLanguage: string = ''
    let id: number = 0
    
    for (let i: number = 0; i < lines.length; i++) {
      const line: string = lines[i]
      const trimmedLine: string = line.trim()
      
      // 代码块处理
      if (trimmedLine.startsWith('```')) {
        if (!inCodeBlock) {
          // 代码块开始
          // 先处理之前的内容
          if (currentBlock.length > 0) {
            const para: Paragraph | null = ParagraphSplitter.processBlock(currentBlock.join('\n'), id++)
            if (para) paragraphs.push(para)
            currentBlock = []
          }
          inCodeBlock = true
          codeLanguage = trimmedLine.substring(3).trim()
        } else {
          // 代码块结束
          const para: Paragraph = {
            id: id++,
            text: ParagraphSplitter.formatCodeForSpeech(codeLanguage),
            type: ParagraphType.CODE,
            raw: '```' + codeLanguage + '\n' + currentBlock.join('\n') + '\n```'
          }
          paragraphs.push(para)
          currentBlock = []
          inCodeBlock = false
          codeLanguage = ''
        }
        continue
      }
      
      if (inCodeBlock) {
        currentBlock.push(line)
        continue
      }
      
      // 空行表示段落分隔
      if (trimmedLine.length === 0) {
        if (currentBlock.length > 0) {
          const para: Paragraph | null = ParagraphSplitter.processBlock(currentBlock.join('\n'), id++)
          if (para) paragraphs.push(para)
          currentBlock = []
        }
        continue
      }
      
      currentBlock.push(line)
    }
    
    // 处理最后一块
    if (currentBlock.length > 0) {
      if (inCodeBlock) {
        // 未闭合的代码块
        const para: Paragraph = {
          id: id++,
          text: ParagraphSplitter.formatCodeForSpeech(codeLanguage),
          type: ParagraphType.CODE,
          raw: '```' + codeLanguage + '\n' + currentBlock.join('\n') + '\n```'
        }
        paragraphs.push(para)
      } else {
        const para: Paragraph | null = ParagraphSplitter.processBlock(currentBlock.join('\n'), id++)
        if (para) paragraphs.push(para)
      }
    }
    
    return paragraphs.filter((p: Paragraph) => p.type !== ParagraphType.EMPTY)
  }
  
  /**
   * 处理单个块
   */
  private static processBlock(block: string, id: number): Paragraph | null {
    const trimmed: string = block.trim()
    if (trimmed.length === 0) {
      return null
    }
    
    // 标题
    if (trimmed.startsWith('#')) {
      return ParagraphSplitter.processHeading(block, id)
    }
    
    // 引用块
    if (trimmed.startsWith('>')) {
      return ParagraphSplitter.processQuote(block, id)
    }
    
    // 列表
    if (/^[\-\*\+]\s/.test(trimmed) || /^\d+\.\s/.test(trimmed)) {
      return ParagraphSplitter.processList(block, id)
    }
    
    // 表格
    if (trimmed.includes('|')) {
      return ParagraphSplitter.processTable(block, id)
    }
    
    // 普通文本
    return {
      id,
      text: ParagraphSplitter.cleanMarkdown(trimmed),
      type: ParagraphType.TEXT,
      raw: block
    }
  }
  
  /**
   * 处理标题
   */
  private static processHeading(block: string, id: number): Paragraph {
    const match: RegExpMatchArray | null = block.match(/^(#{1,6})\s+(.+)$/m)
    if (match) {
      const level: number = match[1].length
      const text: string = match[2].trim()
      return {
        id,
        text: `第${level}级标题：${ParagraphSplitter.cleanMarkdown(text)}`,
        type: ParagraphType.HEADING,
        raw: block
      }
    }
    return {
      id,
      text: ParagraphSplitter.cleanMarkdown(block),
      type: ParagraphType.TEXT,
      raw: block
    }
  }
  
  /**
   * 处理引用块
   */
  private static processQuote(block: string, id: number): Paragraph {
    // 移除引用标记
    const text: string = block
      .split('\n')
      .map((line: string) => line.replace(/^>\s?/, ''))
      .join('\n')
      .trim()
    
    return {
      id,
      text: '引用：' + ParagraphSplitter.cleanMarkdown(text),
      type: ParagraphType.QUOTE,
      raw: block
    }
  }
  
  /**
   * 处理列表
   */
  private static processList(block: string, id: number): Paragraph {
    const lines: string[] = block.split('\n')
    const items: string[] = []
    
    for (const line of lines) {
      const match: RegExpMatchArray | null = line.match(/^[\-\*\+]\s+(.+)$/)
      if (match) {
        items.push(ParagraphSplitter.cleanMarkdown(match[1]))
      } else {
        const numMatch: RegExpMatchArray | null = line.match(/^\d+\.\s+(.+)$/)
        if (numMatch) {
          items.push(ParagraphSplitter.cleanMarkdown(numMatch[1]))
        }
      }
    }
    
    if (items.length === 1) {
      return {
        id,
        text: '列表项：' + items[0],
        type: ParagraphType.LIST_ITEM,
        raw: block
      }
    } else {
      return {
        id,
        text: `列表，共${items.length}项：` + items.join('；'),
        type: ParagraphType.LIST_ITEM,
        raw: block
      }
    }
  }
  
  /**
   * 处理表格
   */
  private static processTable(block: string, id: number): Paragraph {
    const lines: string[] = block.split('\n').filter((l: string) => l.includes('|'))
    if (lines.length < 2) {
      return {
        id,
        text: ParagraphSplitter.cleanMarkdown(block),
        type: ParagraphType.TEXT,
        raw: block
      }
    }
    
    // 解析表头
    const headers: string[] = lines[0]
      .split('|')
      .filter((c: string) => c.trim().length > 0)
      .map((c: string) => c.trim())
    
    return {
      id,
      text: `表格，包含${headers.length}列：${headers.join('、')}。建议查看原文了解详细数据。`,
      type: ParagraphType.TABLE,
      raw: block
    }
  }
  
  /**
   * 格式化代码块为朗读文本
   */
  private static formatCodeForSpeech(language: string): string {
    if (language.length > 0) {
      return `代码块，${language}语言。建议查看原文。`
    }
    return '代码块，建议查看原文。'
  }
  
  /**
   * 清理 Markdown 标记
   */
  private static cleanMarkdown(text: string): string {
    return text
      // 粗体/斜体
      .replace(/\*\*([^\*]+)\*\*/g, '$1')
      .replace(/__([^_]+)__/g, '$1')
      .replace(/\*([^\*]+)\*/g, '$1')
      .replace(/_([^_]+)_/g, '$1')
      // 行内代码
      .replace(/`([^`]+)`/g, '$1')
      // 删除线
      .replace(/~~([^~]+)~~/g, '$1')
      // 链接
      .replace(/\[([^\]]+)\]\([^)]+\)/g, '$1')
      // 图片
      .replace(/!\[[^\]]*\]\([^)]+\)/g, '图片')
      // HTML 标签
      .replace(/<[^>]+>/g, '')
      .trim()
  }
}