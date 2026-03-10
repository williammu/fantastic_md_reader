# Debug Session: md-render-crash-20260309
- **Status**: [RESOLVED]
- **Issue**: 点击 MD 文档后应用崩溃（期望正常渲染）

---

## 问题 1: WebView 组件崩溃

### Reproduction Steps
1. 安装并启动应用
2. 点击任意 .md 文档进入阅读页
3. 观察应用崩溃
4. 日志采集 runId=pre-fix，Debug Server: http://10.75.221.139:7777/event
5. 使用 LogSocketService 获取 app.log

### Hypotheses
- [x] Hypothesis A: Web 组件初始化或 controller 加载 HTML 时触发异常 | Evidence: Pre-fix 日志停在 MDRender refreshHtml，未出现 Web.onAppear
- [x] Hypothesis B: MarkdownParser/HTMLGenerator 生成内容包含异常导致 Web 组件崩溃 | Evidence: htmlLength 正常输出，解析阶段完成
- [x] Hypothesis C: ReaderPage 读取内容阶段异常导致崩溃 | Evidence: loadContent start/done 正常输出
- [x] Hypothesis D: 目录锚点跳转 JS 执行触发异常 | Evidence: 未出现 jumpToAnchor 日志

### Verification
Pre-fix 日志显示 ReaderPage 与 MDRender 解析完成，但 Web 组件 onAppear 未触发，崩溃发生在 Web 初始化或 controller 绑定阶段

---

## 问题 2: 锚点跳转失效

### 现象
- 点击目录中的链接无反应
- HTML 中标题 ID 与目录链接不匹配

### 根本原因
1. **MarkdownParser 未支持自定义 ID 语法**：`{#section-1-overview}`
2. **WebView 默认不处理锚点跳转**：需要 JS 拦截点击事件

### 修复方案

#### 1. MarkdownParser 支持自定义 ID
```typescript
// generateAnchorId 方法
private static generateAnchorId(text: string): string {
  let id = text.replace(/<[^>]+>/g, '')
  // 提取自定义 ID {...}
  const customIdMatch = id.match(/\{([^}]+)\}$/)
  if (customIdMatch) {
    return customIdMatch[1]  // 直接返回自定义 ID
  }
  // 生成默认 ID...
}
```

#### 2. HTMLGenerator 添加 JS 拦截器
```html
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
```

---

## 问题 3: 文件读取乱码（已解决）

### 现象
- 中文内容显示为乱码（如 `Kըc`）

### 坑点总结

#### 坑 1: rawFile.buffer 有 offset
```typescript
// 错误
const content = buffer.from(rawFile.buffer).toString('utf-8')

// 正确
const slicedBuffer = rawFile.buffer.slice(rawFile.byteOffset, rawFile.byteOffset + rawFile.byteLength)
const content = buffer.from(slicedBuffer).toString('utf-8')
```

#### 坑 2: fileIo.readSync 返回的 ArrayBuffer
```typescript
// 错误
const buf = new ArrayBuffer(stat.size)
fileIo.readSync(fd, buf)
const content = buffer.from(buf).toString('utf-8')  // 可能乱码

// 最简方案
const content = fileIo.readTextSync(filePath)  // 直接读取文本
```

#### 坑 3: buffer.from(uint8Array) Node.js vs ArkTS
- Node.js: `buffer.from(uint8Array)` 正常
- ArkTS: 需要用 `buffer.from(arrayBuffer)` 或直接用字符串

---

## 问题 4: ArkTS WebView API 类型严格

### loadData 方法签名（已废弃）
```typescript
// 不再使用 loadData，改用 data:text/html
```

### Web src 属性加载 HTML
```typescript
// 使用 data:text/html 方式
Web({
  src: `data:text/html;charset=utf-8,${encodeURIComponent(htmlContent)}`,
  controller: new webview.WebviewController()
})
```

---

## 测试验证

### anchor_test.md 用法
```markdown
## 目录
1. [Section 1: Overview](#section-1-overview)

## 第一节：测试概述 {#section-1-overview}
内容...
```

### 验证点
- [x] 标题渲染正确 ID：`id="section-1-overview"`
- [x] 目录链接正确：`href="#section-1-overview"`
- [x] 点击目录链接平滑滚动到标题

---

## 问题 5: 锚点 ID 生成规则不一致（2026-03-10）

### 现象
- anchor_test.md 和 AI 公司盈利分析文档的锚点跳转不工作
- 目录链接与标题 ID 不匹配

### 排查过程

#### Step 1: 建立 Socket 日志服务器
使用 Node.js 建立 TCP 服务器接收 HTML 内容：
```javascript
const server = net.createServer((socket) => {
  let dataBuffer = '';
  socket.on('data', (data) => { dataBuffer += data.toString(); });
  socket.on('end', () => {
    fs.writeFileSync(`logs/html_log_${timestamp}.html`, dataBuffer);
  });
});
server.listen(8080);
```

#### Step 2: 分析 HTML 输出
**anchor_test.md 问题：**
```html
<!-- 目录链接 -->
<a href="#section1overview">Section 1: Overview</a>

<!-- 标题 ID -->
<h2 id="section-1-overview">第一节：测试概述</h2>
```
**问题**：目录链接 `section1overview` vs 标题 ID `section-1-overview`

**AI 公司盈利分析文档问题：**
```html
<!-- 目录链接 -->
<a href="#一核心结论概览">核心结论概览</a>

<!-- 标题 ID -->
<h2 id="一-核心结论概览">一、核心结论概览</h2>
```
**问题**：目录链接 `一核心结论概览` vs 标题 ID `一-核心结论概览`

### 根本原因分析

#### 原因 1: 硬编码测试文件内容
`FileService.ets` 使用硬编码的中文内容创建测试文件，而非从 rawfile 目录复制：
```typescript
// 错误：硬编码内容
const anchorTestContent = "1. [第一节：测试概述](#第一节测试概述)"

// 正确：从 rawfile 复制原始内容
// 原始内容：1. [Section 1: Overview](#section-1-overview)
```

#### 原因 2: 中文标点处理不一致
`generateAnchorId` 早期实现将中文标点替换为连字符：
```typescript
// 早期实现（错误）
id = id.replace(/[^\u4e00-\u9fa5a-z0-9\s]/g, '-')  // 标点变连字符
// "一、核心" → "一-核心"
```

#### 原因 3: 英文标点被错误移除
正则表达式将连字符也视为标点：
```typescript
// 错误正则
/[\u3000-\u303F\uFF00-\uFFEF!"#$%&'()*+,\-./:;<=>?@[\\\]^_`{|}~]/g
// section-1-overview → section1overview（连字符被移除）
```

#### 原因 4: 目录链接锚点 ID 被处理
`parseInlineElements` 对目录链接中的锚点 ID 调用 `generateAnchorId`：
```typescript
// 错误：处理目录链接锚点 ID
text.replace(/\[([^\]]+)\]\(\s*(#[^)]+)\s*\)/g, (match, p1, p2) => {
  const anchorId = p2.substring(1);
  const processedId = MarkdownParser.generateAnchorId(anchorId);  // 错误！
  return `<a href="#${processedId}">${p1}</a>`;
});
```

### 修复方案

#### 修复 1: 更新硬编码内容
```typescript
// FileService.ets
const anchorTestContent = "1. [Section 1: Overview](#section-1-overview)"
```

#### 修复 2: 中文标点直接移除
```typescript
// generateAnchorId
// 步骤 2: 移除所有标点符号（包括中文标点），但保留空格
id = id.replace(/[\u3000-\u303F\uFF00-\uFFEF!"#$%&'()*+,\-./:;<=>?@[\\\]^_`{|}~]/g, '');
// "一、核心" → "一核心"（直接移除标点）
```

#### 修复 3: 目录链接锚点 ID 不处理
```typescript
// parseInlineElements
// 注意：不对锚点 ID 进行处理，保持用户原始输入
text.replace(/\[([^\]]+)\]\(\s*(#[^)]+)\s*\)/g, '<a href="$2">$1</a>');
```

### 最终锚点 ID 生成规则

| 步骤 | 规则 | 示例 |
|------|------|------|
| 1 | 移除 HTML 标签 | `<b>标题</b>` → `标题` |
| 2 | 转为小写 | `Hello World` → `hello world` |
| 3 | 移除所有标点符号（包括中文标点） | `一、核心结论` → `一核心结论` |
| 4 | 将空格替换为连字符 | `hello world` → `hello-world` |
| 5 | 合并连续的连字符 | `hello--world` → `hello-world` |
| 6 | 移除首尾的连字符 | `-hello-world-` → `hello-world` |

### 关键设计决策

**决策 1: 中文标点直接移除而非替换为连字符**
- **背景**：早期实现将中文标点替换为连字符，导致标题 ID 与目录链接不匹配
- **解决方案**：直接移除中文标点，不生成连字符
- **结果**：`一、核心结论概览` → `一核心结论概览`

**决策 2: 目录链接锚点 ID 不处理**
- **背景**：自定义 ID（如 `section-1-overview`）被处理后破坏链接
- **解决方案**：保持用户原始输入，不进行 `generateAnchorId` 处理
- **责任转移**：用户需确保目录链接的锚点 ID 与标题 ID 匹配

### 验证结果

| 文档 | 目录链接 | 标题 ID | 匹配 |
|------|----------|---------|------|
| anchor_test.md | `#section-1-overview` | `section-1-overview` | ✅ |
| AI 公司盈利分析 | `#一核心结论概览` | `一核心结论概览` | ✅ |

---

## 技术债务

1. MDRender 组件被意外重写为纯 Text 组件 → 已恢复 WebView 版本
2. 需要单元测试验证 UTF-8 解码正确性
3. LogSocketService 调试代码需清理
4. 考虑使用成熟的 Markdown 解析库（如 marked.js）替代自研解析器
