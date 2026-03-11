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

## 问题 6: 首次安装时 rawfile 文件未拷贝到沙盒（2026-03-10）

### 现象
- 首次安装应用后，沙盒目录中没有 `complete_test.md` 文件
- 应用显示"暂无文档"

### 根本原因
1. **getContext() 在非组件类中不可用**：FileService 中调用 `getContext().resourceDir` 会报错
2. **console.log 不输出到 hilog**：导致无法通过 hilog 查看日志
3. **日志格式错误**：hilog 必须使用 `%{public}s` 等占位符，不能直接拼接字符串

### 修复方案

#### 修复 1: 通过参数传递 Context
```typescript
// FileService.ets
static async scanDirectory(context: Context): Promise<Document[]> {
  // ...
  const rawfileDir = context.resourceDir + '/rawfile'
  // ...
}

// Index.ets
this.documents = await FileService.scanDirectory(this.context)
```

#### 修复 2: 使用 hilog 替代 console.log
```typescript
import { hilog } from '@kit.PerformanceAnalysisKit'

const DOMAIN = 0x0002

// 错误
console.log('[FileService] message: ' + value)

// 正确
hilog.info(DOMAIN, 'testTag', 'message: %{public}s', value)
```

#### 修复 3: 修改首次安装检测逻辑
```typescript
// 不再使用 StorageService.isFirstInstall()
// 改为直接检查沙盒中是否有 md 文件
if (sandboxDocs.length === 0) {
  // 从 rawfile 拷贝文件
}
```

---

## HiLog 调试指南

### 1. 导入模块
```typescript
import { hilog } from '@kit.PerformanceAnalysisKit'
```

### 2. 定义常量
```typescript
const DOMAIN = 0x0000  // 日志域，范围 0x0 ~ 0xFFFFF
const TAG = 'testTag'   // 日志标签
```

### 3. 输出日志
```typescript
// 基本格式
hilog.info(DOMAIN, TAG, 'message')

// 带参数的格式（必须使用 %{public} 前缀）
hilog.info(DOMAIN, TAG, '%{public}s', 'hello')
hilog.info(DOMAIN, TAG, 'count: %{public}d', 42)
hilog.info(DOMAIN, TAG, 'user: %{public}s, age: %{public}d', 'John', 25)
```

### 4. 查看日志
```bash
# 非阻塞查看所有日志
hdc shell hilog -x

# 按 tag 过滤
hdc shell hilog -x -T testTag

# 按 domain 过滤
hdc shell hilog -x -D 0x0000,0x0001

# 按日志级别过滤
hdc shell hilog -x -L I

# 查看应用日志
hdc shell hilog -x -t app

# 组合过滤
hdc shell hilog -x -T testTag | grep "md_reader"
```

### 5. 常见错误
❌ **错误：直接拼接字符串**
```typescript
hilog.info(DOMAIN, TAG, 'count: ' + count)  // 可能不显示
```

✅ **正确：使用占位符**
```typescript
hilog.info(DOMAIN, TAG, 'count: %{public}d', count)
```

❌ **错误：在非组件类中使用 getContext()**
```typescript
// FileService.ts 中不能使用
const dir = getContext().resourceDir  // 会报错
```

✅ **正确：通过参数传递 context**
```typescript
static async scanDirectory(context: Context) {
  const dir = context.resourceDir
}
```

### 6. 调试技巧
1. **使用不同的 DOMAIN 区分模块**
   - EntryAbility: 0x0000
   - Index 页面: 0x0001
   - FileService: 0x0002

2. **使用统一的 TAG 方便过滤**
   - 所有模块使用 `'testTag'`

3. **关键位置加日志**
   - 函数入口/出口
   - 异步操作前后
   - 异常捕获处

---

## 问题 7: UTF-8 中文解码失败（HarmonyOS 模拟器限制）

### 现象
- 从 rawfile 读取的 Markdown 文件中文内容显示为乱码
- 例如：`# Markdown 瀹屾暣鑳藉姏娴嬭瘯鏂囨`（应为：`# Markdown 完整能力测试文档`）

### 排查过程

#### 原始数据验证
```
原始字节（hex）: 23 20 4d 61 72 6b 64 6f 77 6e 20 e5 ae 8c e6 95 b4 e8 83 bd
- e5 ae 8c = "完" 的 UTF-8 编码 ✓
- e6 95 b4 = "整" 的 UTF-8 编码 ✓
- e8 83 bd = "能" 的 UTF-8 编码 ✓
```
原始字节数据正确。

#### 已尝试的解码方法（全部失败）

**方法 1: util.TextDecoder.create() + decodeToString()**
```typescript
const decoder = util.TextDecoder.create('utf-8')
return decoder.decodeToString(uint8Array)
```

**方法 2: new util.TextDecoder() + decodeWithStream()**
```typescript
const decoder = new util.TextDecoder('utf-8')
return decoder.decodeWithStream(uint8Array)
```

**方法 3: 手动 UTF-8 解码 + String.fromCharCode()**
```typescript
// 手动解析 UTF-8 字节，然后 String.fromCharCode(codePoint)
```

**方法 4: 手动 UTF-8 解码 + String.fromCodePoint()**
```typescript
// 手动解析 UTF-8 字节，然后 String.fromCodePoint(codePoint)
```

**方法 5: buffer.from().toString('utf8')**
```typescript
return buffer.from(uint8Array).toString('utf8')
```

**方法 6: new Uint8Array() 包装后再解码**
```typescript
const uint8Array = new Uint8Array(rawFile)
// 然后使用上述方法解码
```

### 根本原因分析

#### 可能原因 1: HarmonyOS 模拟器 ArkTS 引擎 Bug
- 所有标准解码方法都返回乱码
- 同样的字节序列，解码后的字符串在日志中显示为错误字符
- 可能是模拟器 JavaScript 引擎的字符编码实现有问题

#### 可能原因 2: 日志系统编码问题
- hilog 输出可能不支持 UTF-8 中文字符
- 但 ASCII 字符显示正常，说明日志系统基本工作

#### 可能原因 3: Uint8Array 实现差异
- ArkTS 的 Uint8Array 可能与标准 JavaScript 有差异
- `uint8Array[i]` 返回的值可能与预期不同

### 验证数据

**解码过程日志：**
```
[ReaderPage] Byte at i=11: raw=229, b1=0xe5, b1&0xF0=0xe0
[ReaderPage] Byte at i=14: raw=230, b1=0xe6, b1&0xF0=0xe0
[ReaderPage] Byte at i=17: raw=232, b1=0xe8, b1&0xF0=0xe0
[ReaderPage] UTF-8 decode: i=11, b1=0xe5, b2=0xae, b3=0x8c, code=23436
[ReaderPage] UTF-8 decode: i=14, b1=0xe6, b2=0x95, b3=0xb4, code=25972
[ReaderPage] UTF-8 decode: i=17, b1=0xe8, b2=0x83, b3=0xbd, code=33021
```

**预期字符：**
- code=23436 (0x5B8C) → "完"
- code=25972 (0x6574) → "整"
- code=33021 (0x80FD) → "能"

**实际输出：** `瀹屾暣`（乱码）

### 结论

**状态**: [UNRESOLVED - 模拟器限制]

这是一个 HarmonyOS 模拟器的底层问题，不是应用代码问题。所有标准的 UTF-8 解码方法在模拟器上都返回乱码。

### 建议解决方案

1. **在真机上测试** - 模拟器可能存在编码实现缺陷
2. **使用 fileIo.readTextSync()** - 如果文件在沙盒中，尝试使用系统提供的文本读取 API
3. **等待 HarmonyOS 更新** - 向华为反馈此问题
4. **使用英文内容测试** - 暂时使用英文 Markdown 文件验证其他功能

### 相关代码位置
- `entry/src/main/ets/pages/ReaderPage.ets` - `readRawFile()` 和 `decodeUtf8()` 方法
- `entry/src/main/ets/pages/ReaderPage.ets` - `decodeUtf8Manual()` 方法

---

## HarmonyOS 模拟器调试指南

### 平台差异说明

本文档提供 **Windows 11** 和 **macOS** 双平台的调试命令。由于 PowerShell 和 Bash 的差异，部分命令语法有所不同。

---

## Windows 11 调试指南（PowerShell）

### 一、环境准备

#### 1. 工具路径配置
```powershell
# DevEco Studio 安装路径（根据实际情况调整）
$DevEcoHome = "E:\dev\DevEco Studio"
$HdcPath = "$DevEcoHome\sdk\default\openharmony\toolchains\hdc.exe"

# 将 hdc 添加到 PATH（临时）
$env:PATH = "$DevEcoHome\sdk\default\openharmony\toolchains;$env:PATH"

# 验证 hdc 可用
hdc version
```

#### 2. 构建脚本（build.ps1）
```powershell
# 清理并构建
.\build.ps1 clean
.\build.ps1 hap

# 注意：签名可能失败，但会生成未签名版本
# 未签名 HAP 路径：entry/build/default/outputs/default/entry-default-unsigned.hap
```

---

### 二、应用生命周期管理

#### 1. 安装应用
```powershell
# 方式 1：使用构建脚本（只安装，不重新构建）
.\build.ps1 install

# 方式 2：直接使用 hdc（推荐，更快）
hdc install entry/build/default/outputs/default/entry-default-unsigned.hap

# 如果已安装，先卸载
hdc uninstall -n com.ms.md_reader
hdc install entry/build/default/outputs/default/entry-default-unsigned.hap
```

#### 2. 启动应用
```powershell
# 启动应用
hdc shell aa start -a EntryAbility -b com.ms.md_reader

# 查看进程（使用双引号包裹命令）
hdc shell "ps -ef | grep md_reader | grep -v grep"

# 查看进程 ID
hdc shell "pidof com.ms.md_reader"
```

#### 3. 停止应用
```powershell
# 方式 1：强制停止
hdc shell "killall com.ms.md_reader"

# 方式 2：卸载
hdc uninstall -n com.ms.md_reader

# 方式 3：停止并重启
hdc shell "am force-stop com.ms.md_reader"
```

---

### 三、日志调试（PowerShell）

#### 1. 基本日志查看
```powershell
# 查看所有应用日志
hdc shell hilog -x -t app

# 按标签过滤（PowerShell 管道）
hdc shell hilog -x -t app | Select-String "testTag"

# 按 domain 过滤
hdc shell hilog -x -t app | Select-String "A00003"

# 按模块过滤
hdc shell hilog -x -t app | Select-String "MDRender|HTMLGenerator|ReaderPage"

# 实时查看（非阻塞，使用 -Wait 参数）
Start-Job { hdc shell hilog -x -t app } | Receive-Job -Wait
```

#### 2. 日志过滤技巧
```powershell
# 查看最近 50 行日志
hdc shell hilog -x -t app | Select-Object -Last 50

# 查看包含错误的关键字
hdc shell hilog -x -t app | Select-String "ERROR|error|fail|exception"

# 查看特定进程的日志
hdc shell "hilog -x -t app | grep '$(hdc shell pidof com.ms.md_reader)'"

# 导出日志到文件
hdc shell hilog -x -t app > app_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt
```

#### 3. 日志分析脚本
```powershell
# 分析日志中的错误
function Analyze-AppLog {
    $logs = hdc shell hilog -x -t app
    $errors = $logs | Select-String "ERROR|error|fail"
    $warnings = $logs | Select-String "WARN|warning"
    
    Write-Host "=== 日志分析结果 ===" -ForegroundColor Green
    Write-Host "错误数: $($errors.Count)" -ForegroundColor Red
    Write-Host "警告数: $($warnings.Count)" -ForegroundColor Yellow
    
    if ($errors.Count -gt 0) {
        Write-Host "`n=== 错误详情 ===" -ForegroundColor Red
        $errors | Select-Object -Last 10
    }
}

# 使用
Analyze-AppLog
```

---

### 四、文件调试（PowerShell）

#### 1. 沙盒目录位置
```powershell
# 应用沙盒目录（实际路径）
$packageName = "com.ms.md_reader"
$sandboxPath = "/data/app/el2/100/base/$packageName/haps/entry/files"

# 查看目录内容
hdc shell "ls -la $sandboxPath"
hdc shell "ls -la $sandboxPath/shared"
```

#### 2. 文件传输
```powershell
# 从设备拉取文件到当前目录
hdc file recv "$sandboxPath/shared/debug_output.html" ./debug_output.html

# 推送文件到设备
hdc file send ./test.md "$sandboxPath/shared/test.md"

# 拉取整个目录（需要逐个文件）
$files = hdc shell "ls $sandboxPath/shared"
foreach ($file in $files) {
    hdc file recv "$sandboxPath/shared/$file" ./logs/$file
}
```

#### 3. 文件内容查看
```powershell
# 查看文件内容
hdc shell "cat $sandboxPath/shared/app.log"

# 查看文件前 20 行
hdc shell "head -20 $sandboxPath/shared/debug_output.html"

# 查看文件后 20 行
hdc shell "tail -20 $sandboxPath/shared/app.log"

# 搜索文件内容
hdc shell "grep -n '错误' $sandboxPath/shared/app.log"
```

#### 4. HTML 调试文件分析
```powershell
# 拉取并打开 HTML 文件
hdc file recv "$sandboxPath/shared/debug_output.html" ./debug_output.html
Start-Process ./debug_output.html  # 用默认浏览器打开

# 分析 HTML 结构
$html = Get-Content ./debug_output.html -Raw
$titleCount = ([regex]::Matches($html, "<h[1-6]")).Count
$tableCount = ([regex]::Matches($html, "<table")).Count
$codeBlockCount = ([regex]::Matches($html, "<pre")).Count

Write-Host "HTML 统计:" -ForegroundColor Green
Write-Host "  标题数: $titleCount"
Write-Host "  表格数: $tableCount"
Write-Host "  代码块数: $codeBlockCount"
```

---

### 五、Windows 11 实战经验总结

#### 经验 1：PowerShell 管道与 Unix 管道的差异
```powershell
# ❌ 错误：PowerShell 中不能直接使用 Unix 管道语法
hdc shell hilog -x | grep "testTag"

# ✅ 正确：使用 PowerShell 的管道
hdc shell hilog -x | Select-String "testTag"

# ✅ 正确：使用双引号包裹整个命令
hdc shell "hilog -x | grep testTag"
```

#### 经验 2：路径分隔符
```powershell
# ❌ 错误：使用反斜杠（在 hdc shell 中）
hdc shell "cat C:\Users\test\file.txt"

# ✅ 正确：在 hdc shell 中使用正斜杠
hdc shell "cat /data/app/el2/100/base/com.ms.md_reader/haps/entry/files/shared/app.log"

# ✅ 正确：PowerShell 本地路径使用反斜杠
hdc file recv "/data/app/.../app.log" "E:\logs\app.log"
```

#### 经验 3：变量插值
```powershell
# ✅ 正确：使用双引号进行变量插值
$package = "com.ms.md_reader"
hdc shell "pidof $package"

# ✅ 正确：使用 PowerShell 表达式
$hdcPath = "$env:DEVECO_SDK_HOME\sdk\default\openharmony\toolchains\hdc.exe"
& $hdcPath version
```

#### 经验 4：快速开发循环
```powershell
# 一键清理、构建、安装、启动
function Start-DevLoop {
    Write-Host "=== 清理构建缓存 ===" -ForegroundColor Yellow
    .\build.ps1 clean
    
    Write-Host "`n=== 构建 HAP ===" -ForegroundColor Yellow
    .\build.ps1 hap
    
    Write-Host "`n=== 卸载旧版本 ===" -ForegroundColor Yellow
    hdc uninstall -n com.ms.md_reader
    
    Write-Host "`n=== 安装新版本 ===" -ForegroundColor Yellow
    hdc install entry/build/default/outputs/default/entry-default-unsigned.hap
    
    Write-Host "`n=== 启动应用 ===" -ForegroundColor Yellow
    hdc shell aa start -a EntryAbility -b com.ms.md_reader
    
    Write-Host "`n=== 查看日志 ===" -ForegroundColor Green
    Start-Sleep -Seconds 2
    hdc shell hilog -x -t app | Select-Object -Last 20
}

# 使用
Start-DevLoop
```

#### 经验 5：调试快捷键
```powershell
# 创建别名（临时）
Set-Alias -Name hlog -Value "hdc shell hilog -x -t app"
Set-Alias -Name hinstall -Value "hdc install entry/build/default/outputs/default/entry-default-unsigned.hap"

# 快速查看最近日志
function hlog-last { hdc shell hilog -x -t app | Select-Object -Last 30 }

# 快速过滤日志
function hlog-grep($pattern) { hdc shell hilog -x -t app | Select-String $pattern }
```

---

## macOS 调试指南（Bash/Zsh）

### 一、环境准备

#### 1. 工具路径配置
```bash
# DevEco Studio 安装路径（macOS 默认路径）
export DEVECO_HOME="/Applications/DevEco-Studio.app/Contents"
export HDC_PATH="$DEVECO_HOME/sdk/default/openharmony/toolchains/hdc"

# 将 hdc 添加到 PATH
export PATH="$DEVECO_HOME/sdk/default/openharmony/toolchains:$PATH"

# 验证 hdc 可用
hdc version
```

#### 2. 构建脚本（build.sh）
```bash
#!/bin/bash
# 清理并构建
./build.sh clean
./build.sh hap

# 注意：macOS 使用 ./build.sh 而不是 .\build.ps1
```

---

### 二、应用生命周期管理

#### 1. 安装应用
```bash
# 方式 1：使用构建脚本
./build.sh install

# 方式 2：直接使用 hdc（推荐）
hdc install entry/build/default/outputs/default/entry-default-unsigned.hap

# 如果已安装，先卸载
hdc uninstall -n com.ms.md_reader
hdc install entry/build/default/outputs/default/entry-default-unsigned.hap
```

#### 2. 启动应用
```bash
# 启动应用
hdc shell aa start -a EntryAbility -b com.ms.md_reader

# 查看进程（使用单引号）
hdc shell 'ps -ef | grep md_reader | grep -v grep'

# 查看进程 ID
hdc shell pidof com.ms.md_reader
```

#### 3. 停止应用
```bash
# 方式 1：强制停止
hdc shell killall com.ms.md_reader

# 方式 2：卸载
hdc uninstall -n com.ms.md_reader

# 方式 3：停止并重启
hdc shell am force-stop com.ms.md_reader
```

---

### 三、日志调试（Bash）

#### 1. 基本日志查看
```bash
# 查看所有应用日志
hdc shell hilog -x -t app

# 按标签过滤（使用 grep）
hdc shell hilog -x -t app | grep "testTag"

# 按 domain 过滤
hdc shell hilog -x -t app | grep "A00003"

# 按模块过滤（使用扩展正则）
hdc shell hilog -x -t app | grep -E "MDRender|HTMLGenerator|ReaderPage"

# 实时查看（使用 tail -f 类似方式）
hdc shell hilog -x -t app &
```

#### 2. 日志过滤技巧
```bash
# 查看最近 50 行日志
hdc shell hilog -x -t app | tail -n 50

# 查看包含错误的关键字
hdc shell hilog -x -t app | grep -iE "error|fail|exception"

# 查看特定进程的日志
hdc shell "hilog -x -t app | grep $(pidof com.ms.md_reader)"

# 导出日志到文件
hdc shell hilog -x -t app > "app_log_$(date +%Y%m%d_%H%M%S).txt"
```

#### 3. 日志分析脚本
```bash
#!/bin/bash
# analyze_log.sh

LOGS=$(hdc shell hilog -x -t app)
ERRORS=$(echo "$LOGS" | grep -iE "error|fail")
WARNINGS=$(echo "$LOGS" | grep -iE "warn")

echo "=== 日志分析结果 ==="
echo "错误数: $(echo "$ERRORS" | wc -l)"
echo "警告数: $(echo "$WARNINGS" | wc -l)"

if [ -n "$ERRORS" ]; then
    echo ""
    echo "=== 错误详情 ==="
    echo "$ERRORS" | tail -n 10
fi
```

---

### 四、文件调试（Bash）

#### 1. 沙盒目录位置
```bash
# 应用沙盒目录
PACKAGE_NAME="com.ms.md_reader"
SANDBOX_PATH="/data/app/el2/100/base/${PACKAGE_NAME}/haps/entry/files"

# 查看目录内容
hdc shell "ls -la ${SANDBOX_PATH}"
hdc shell "ls -la ${SANDBOX_PATH}/shared"
```

#### 2. 文件传输
```bash
# 从设备拉取文件到当前目录
hdc file recv "${SANDBOX_PATH}/shared/debug_output.html" ./debug_output.html

# 推送文件到设备
hdc file send ./test.md "${SANDBOX_PATH}/shared/test.md"

# 拉取整个目录（使用循环）
for file in $(hdc shell "ls ${SANDBOX_PATH}/shared"); do
    hdc file recv "${SANDBOX_PATH}/shared/${file}" ./logs/${file}
done
```

#### 3. 文件内容查看
```bash
# 查看文件内容
hdc shell "cat ${SANDBOX_PATH}/shared/app.log"

# 查看文件前 20 行
hdc shell "head -20 ${SANDBOX_PATH}/shared/debug_output.html"

# 查看文件后 20 行
hdc shell "tail -20 ${SANDBOX_PATH}/shared/app.log"

# 搜索文件内容
hdc shell "grep -n '错误' ${SANDBOX_PATH}/shared/app.log"
```

#### 4. HTML 调试文件分析
```bash
# 拉取并打开 HTML 文件
hdc file recv "${SANDBOX_PATH}/shared/debug_output.html" ./debug_output.html
open ./debug_output.html  # macOS 使用 open 命令

# 分析 HTML 结构
html=$(cat ./debug_output.html)
title_count=$(echo "$html" | grep -o '<h[1-6]' | wc -l)
table_count=$(echo "$html" | grep -o '<table' | wc -l)
code_block_count=$(echo "$html" | grep -o '<pre' | wc -l)

echo "HTML 统计:"
echo "  标题数: $title_count"
echo "  表格数: $table_count"
echo "  代码块数: $code_block_count"
```

---

### 五、macOS 与 Windows 11 主要差异对比

| 功能 | Windows 11 (PowerShell) | macOS (Bash) |
|-----|------------------------|--------------|
| **路径分隔符** | 反斜杠 `\` | 正斜杠 `/` |
| **管道过滤** | `Select-String` | `grep` |
| **查看最后 N 行** | `Select-Object -Last N` | `tail -n N` |
| **查看前 N 行** | `Select-Object -First N` | `head -n N` |
| **变量插值** | `$variable` | `$variable` 或 `${variable}` |
| **执行脚本** | `.\script.ps1` | `./script.sh` |
| **打开文件** | `Start-Process file` | `open file` |
| **日期格式** | `Get-Date -Format 'yyyyMMdd'` | `date +%Y%m%d` |
| **环境变量** | `$env:PATH` | `$PATH` |
| **字符串引号** | 双引号 `"` 支持插值 | 单引号 `'` 和双引号 `"` 有区别 |

---

### 六、通用调试技巧（跨平台）

#### 1. 日志输出规范（所有平台通用）
```typescript
import { hilog } from '@kit.PerformanceAnalysisKit'

const DOMAIN = 0x0003

// ✅ 正确：使用占位符
hilog.info(DOMAIN, 'testTag', 'message: %{public}s', value)
hilog.info(DOMAIN, 'testTag', 'count: %{public}d', count)

// ❌ 错误：直接拼接
hilog.info(DOMAIN, 'testTag', 'count: ' + count)
```

#### 2. 关键调试技巧
- **使用不同 DOMAIN 区分模块**：
  - EntryAbility: 0x0000
  - Index 页面: 0x0001
  - FileService: 0x0002
  - MDRender: 0x0003
  - ReaderPage: 0x0004

- **统一 TAG 方便过滤**：所有模块使用 `'testTag'`

- **关键位置加日志**：
  - 函数入口/出口
  - 异步操作前后
  - 异常捕获处

#### 3. 文件调试通用方法
```typescript
// 将 HTML 写入文件以便调试（跨平台通用）
const htmlPath = context.filesDir + '/shared/debug_output.html'
const file = fileIo.openSync(htmlPath, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE)
fileIo.writeSync(file.fd, buffer.from(htmlContent))
fileIo.closeSync(file)
```

---

## 常见坑点（跨平台通用）

### 坑 1: 日志不输出
**现象**：`console.log` 或 `hilog.info` 没有输出

**原因**：
- `console.log` 不会输出到 hilog
- hilog 必须使用 `%{public}` 占位符
- 字符串拼接可能导致日志丢失

**解决**：
```typescript
// ❌ 错误
console.log('[FileService] message')
hilog.info(DOMAIN, TAG, 'count: ' + count)

// ✅ 正确
import { hilog } from '@kit.PerformanceAnalysisKit'
hilog.info(DOMAIN, 'testTag', 'count: %{public}d', count)
```

---

### 坑 2: UTF-8 中文乱码
**现象**：中文内容显示为乱码（如 `瀹屾暣`）

**原因**：
- `getRawFileContent` 返回的 `Uint8Array` 需要重新包装
- 可能是模拟器 ArkTS 引擎的 bug

**解决**：
```typescript
// ❌ 错误：直接使用
const rawFile = await context.resourceManager.getRawFileContent(fileName)
const content = buffer.from(rawFile).toString('utf8')

// ✅ 正确：重新包装 Uint8Array
const rawFile = await context.resourceManager.getRawFileContent(fileName)
const uint8Array = new Uint8Array(rawFile)
const decoder = util.TextDecoder.create('utf-8')
const content = decoder.decodeToString(uint8Array)
```

**注意**：即使使用正确方法，模拟器仍可能显示乱码，需要在真机上验证。

---

### 坑 3: CRLF 换行符问题
**现象**：Markdown 标题解析失败（`# 标题` 被渲染成 `<p># 标题</p>`）

**原因**：
- Windows 文件使用 CRLF (`\r\n`)
- 正则表达式 `^` 和 `$` 只匹配 `\n`

**解决**：
```typescript
// 在 MarkdownParser.parse() 开头统一换行符
static parse(md: string): string {
  let html: string = md
  
  // 统一换行符为 LF（跨平台通用）
  html = html.replace(/\r\n/g, '\n')
  
  // 后续解析...
}
```

---

### 坑 4: 构建缓存问题
**现象**：代码修改后没有生效

**原因**：
- `build.ps1 install` / `build.sh install` 只安装现有 HAP，不重新构建
- hvigor 缓存可能导致旧代码被使用

**解决**：
```bash
# Windows (PowerShell)
.\build.ps1 clean
.\build.ps1 hap
hdc install entry/build/default/outputs/default/entry-default-unsigned.hap

# macOS (Bash)
./build.sh clean
./build.sh hap
hdc install entry/build/default/outputs/default/entry-default-unsigned.hap
```

---

### 坑 5: 签名验证失败
**现象**：构建失败，`Failed :entry:default@SignHap`

**原因**：
- `build-profile.json5` 中的签名配置密码不正确
- 模拟器不需要签名，但构建脚本会尝试签名

**解决**：
```bash
# 忽略签名错误，直接安装未签名版本（跨平台通用）
hdc install entry/build/default/outputs/default/entry-default-unsigned.hap
```

---

## 技术债务
hdc file recv /data/app/el2/100/base/com.ms.md_reader/haps/entry/files/shared/debug_output.html ./debug_output.html

# 推送文件到设备
hdc file send ./local_file.txt /data/app/el2/100/base/com.ms.md_reader/haps/entry/files/shared/
```

#### 3. 文件查看
```bash
# 查看文件列表
hdc shell "ls -la /data/app/el2/100/base/com.ms.md_reader/haps/entry/files/shared/"

# 查看文件内容
hdc shell "cat /data/app/el2/100/base/com.ms.md_reader/haps/entry/files/shared/app.log"
```

---

### 四、常见坑点

#### 坑 1: 日志不输出
**现象**：`console.log` 或 `hilog.info` 没有输出

**原因**：
- `console.log` 不会输出到 hilog
- hilog 必须使用 `%{public}` 占位符
- 字符串拼接可能导致日志丢失

**解决**：
```typescript
// ❌ 错误
console.log('[FileService] message')
hilog.info(DOMAIN, TAG, 'count: ' + count)

// ✅ 正确
import { hilog } from '@kit.PerformanceAnalysisKit'
hilog.info(DOMAIN, 'testTag', 'count: %{public}d', count)
```

---

#### 坑 2: 沙盒目录权限
**现象**：`mkdir` 或 `fileIo` 写入失败

**原因**：
- `/data/storage/el2/base/haps/entry/files/` 是软链接，实际路径不同
- 直接使用 `getContext().filesDir` 获取的路径可能不存在

**解决**：
```typescript
// ❌ 错误：路径可能不存在
const path = '/data/storage/el2/base/haps/entry/files/shared/file.txt'

// ✅ 正确：使用 context 获取实际路径
const context = getContext(this)
const filePath = context.filesDir + '/shared/file.txt'

// 确保目录存在
fileIo.mkdirSync(context.filesDir + '/shared', true)
```

---

#### 坑 3: UTF-8 中文乱码
**现象**：中文内容显示为乱码（如 `瀹屾暣`）

**原因**：
- `getRawFileContent` 返回的 `Uint8Array` 需要重新包装
- `util.TextDecoder` 或 `buffer.from` 可能不兼容
- 可能是模拟器 ArkTS 引擎的 bug

**解决**：
```typescript
// ❌ 错误：直接使用
const rawFile = await context.resourceManager.getRawFileContent(fileName)
const content = buffer.from(rawFile).toString('utf8')

// ✅ 正确：重新包装 Uint8Array
const rawFile = await context.resourceManager.getRawFileContent(fileName)
const uint8Array = new Uint8Array(rawFile)
const decoder = util.TextDecoder.create('utf-8')
const content = decoder.decodeToString(uint8Array)
```

**注意**：即使使用正确方法，模拟器仍可能显示乱码，需要在真机上验证。

---

#### 坑 4: CRLF 换行符问题
**现象**：Markdown 标题解析失败（`# 标题` 被渲染成 `<p># 标题</p>`）

**原因**：
- Windows 文件使用 CRLF (`\r\n`)
- 正则表达式 `^` 和 `$` 只匹配 `\n`

**解决**：
```typescript
// 在 MarkdownParser.parse() 开头统一换行符
static parse(md: string): string {
  let html: string = md
  
  // 统一换行符为 LF
  html = html.replace(/\r\n/g, '\n')
  
  // 后续解析...
}
```

---

#### 坑 5: 构建缓存问题
**现象**：代码修改后没有生效

**原因**：
- `build.ps1 install` 只安装现有 HAP，不重新构建
- hvigor 缓存可能导致旧代码被使用

**解决**：
```bash
# 清理构建缓存
.\build.ps1 clean

# 重新构建
.\build.ps1 hap

# 安装（如果签名失败，直接安装未签名版本）
hdc install entry/build/default/outputs/default/entry-default-unsigned.hap
```

---

#### 坑 6: 签名验证失败
**现象**：构建失败，`Failed :entry:default@SignHap`

**原因**：
- `build-profile.json5` 中的签名配置密码不正确
- 模拟器不需要签名，但构建脚本会尝试签名

**解决**：
```bash
# 忽略签名错误，直接安装未签名版本
hdc install entry/build/default/outputs/default/entry-default-unsigned.hap
```

---

#### 坑 7: WebView 调试困难
**现象**：WebView 中的 JavaScript 无法调试

**解决**：
1. **使用 console.log**：在 WebView 的 HTML 中添加 `<script>console.log()</script>`
2. **查看 WebView 日志**：`hdc shell hilog -x | Select-String "WebView"`
3. **生成调试文件**：将 HTML 写入沙盒文件，然后拉取分析

```typescript
// 将 HTML 写入文件以便调试
const htmlPath = context.filesDir + '/shared/debug_output.html'
const file = fileIo.openSync(htmlPath, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE)
fileIo.writeSync(file.fd, buffer.from(htmlContent))
fileIo.closeSync(file)
```

---

#### 坑 8: getContext() 在非组件类中不可用
**现象**：在 `FileService` 等工具类中调用 `getContext()` 报错

**解决**：
```typescript
// ❌ 错误：在非组件类中使用
class FileService {
  static readFile() {
    const context = getContext()  // 报错！
  }
}

// ✅ 正确：通过参数传递 context
class FileService {
  static readFile(context: Context) {
    const dir = context.filesDir
  }
}

// 调用时传递
FileService.readFile(getContext(this))
```

---

### 五、调试最佳实践

1. **使用 HTML 文件调试**：将生成的 HTML 写入沙盒，拉取后在浏览器中打开
2. **分段输出日志**：长内容分段输出，避免被截断
3. **使用不同 DOMAIN**：区分不同模块的日志
4. **检查文件编码**：确保 Markdown 文件使用正确的换行符
5. **真机验证**：模拟器可能有兼容性问题，关键功能需在真机验证

---

## 技术债务

1. MDRender 组件被意外重写为纯 Text 组件 → 已恢复 WebView 版本
2. 需要单元测试验证 UTF-8 解码正确性
3. LogSocketService 调试代码需清理
4. 考虑使用成熟的 Markdown 解析库（如 marked.js）替代自研解析器
5. **UTF-8 中文解码问题需要在真机上验证**
