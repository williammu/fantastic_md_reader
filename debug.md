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

## 技术债务

1. MDRender 组件被意外重写为纯 Text 组件 → 已恢复 WebView 版本
2. 需要单元测试验证 UTF-8 解码正确性
3. LogSocketService 调试代码需清理
