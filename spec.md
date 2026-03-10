# 纯血鸿蒙 Markdown 阅读器 - 产品规格文档

## 1. 产品概述

### 1.1 产品定位
一款专为 HarmonyOS NEXT 打造的原生 Markdown 阅读器，提供沉浸式阅读体验和智能朗读功能，支持后台播放，让用户在通勤、运动、休息时都能"阅读"。

### 1.2 目标用户
- 技术文档阅读者
- 知识管理爱好者
- 需要护眼/听书模式的用户
- 纯血鸿蒙生态早期用户

### 1.3 核心卖点
- **原生鸿蒙体验**：深度适配 HarmonyOS NEXT，流畅丝滑
- **智能朗读**：系统级 TTS 集成，支持后台播放、通知栏控制
- **沉浸式阅读**：专注模式、多种主题、自适应排版
- **文件管理**：本地文件 + 云同步（华为云盘）

---

## 2. 功能规格

### 2.1 核心功能

#### 2.1.1 Markdown 渲染
- 完整支持 CommonMark + GitHub Flavored Markdown
- 代码高亮（支持 100+ 编程语言）
- LaTeX 数学公式渲染（KaTeX 风格）
- Mermaid 图表支持
- 表格横向滚动优化
- 图片懒加载 + 点击预览

#### 2.1.2 朗读功能（核心亮点）
- **一键朗读**：悬浮按钮，随时开启/暂停
- **后台播放**：退出应用后继续在通知栏播放
- **智能分段**：按段落朗读，支持点击跳转
- **语速调节**：0.5x - 2.0x 无级调节
- **音色选择**：系统 TTS + 在线高质量语音包
- **进度记忆**：记录朗读位置，下次自动续读
- **定时关闭**：15/30/60 分钟后自动停止

#### 2.1.3 文件管理
- 本地文件浏览器（.md/.markdown/.txt）
- 华为云盘同步
- 最近阅读列表
- 收藏夹管理
- 全文搜索

### 2.2 阅读体验

#### 2.2.1 主题系统
- 日间模式：纯白、护眼黄、淡绿
- 夜间模式：深灰、纯黑（OLED 省电）
- 跟随系统：自动切换深浅色
- 字体大小：14sp - 24sp 连续调节
- 行间距：紧凑、舒适、宽松

#### 2.2.2 交互优化
- 左右滑动翻页（可选）
- 侧边栏目录导航
- 阅读进度条
- 快速返回顶部
- 双指缩放字体

### 2.3 系统级集成

- **Live View**: 朗读时在状态岛显示进度
- **服务卡片**: 桌面快捷入口，显示最近阅读
- **分享接收**: 接收其他应用分享的 Markdown 文件
- **后台任务**: 朗读保活，不中断播放

---

## 3. 技术架构

### 3.1 技术栈

| 层级 | 技术方案 |
|------|----------|
| 开发语言 | ArkTS（ArkUI 声明式 UI）|
| 最低版本 | HarmonyOS 5.0.0(12) |
| 架构模式 | MVVM + 组件化 |
| 状态管理 | AppStorage + LocalStorage |
| 本地存储 | 首选项 + 关系型数据库 |
| 文件存储 | 用户文件 + 应用私有文件 |
| 后台服务 | BackgroundTask + AVSession |
| TTS 引擎 | 系统 @ohos.speechTTS |

### 3.2 架构图

```
┌─────────────────────────────────────────────────────────────┐
│                        表现层 (UI)                           │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │ 文件列表  │ │ 阅读页面  │ │ 朗读控制  │ │ 设置页面  │       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                       业务逻辑层                             │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │ FileMgr  │ │ MDRender │ │ TTSService│ │ SyncMgr  │       │
│  │ 文件管理  │ │ 渲染引擎  │ │ 朗读服务  │ │ 云同步   │       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                        数据层                                │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │ 文件系统  │ │ 用户偏好  │ │ 阅读记录  │ │ 云存储   │       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. 核心模块设计

### 4.1 Markdown 渲染引擎

```typescript
// MDRenderEngine.ets
class MDRenderEngine {
  // 使用 Web 组件或原生 RichText 实现
  // 方案：Web 组件加载本地 marked.js + highlight.js
  
  private webController: WebviewController
  
  render(mdContent: string, theme: MDTheme): void {
    const html = this.convertToHTML(mdContent, theme)
    this.webController.loadData(html, 'text/html', 'utf-8')
  }
  
  // 支持代码高亮、公式、Mermaid
  private convertToHTML(md: string, theme: MDTheme): string {
    // 注入 CSS 样式 + JS 脚本
  }
}
```

### 4.2 朗读服务（核心）

```typescript
// TTSService.ets
import { speechTTS } from '@kit.SpeechKit'
import { backgroundTaskManager } from '@kit.BackgroundTasksKit'
import { avSession } from '@kit.AVSessionKit'

@Singleton
class TTSService {
  private ttsEngine: speechTTS.TextToSpeechEngine
  private avSession: avSession.AVSession
  
  // 当前朗读状态
  @State isPlaying: boolean = false
  @State currentParagraph: number = 0
  @State progress: number = 0 // 0-100
  
  async init() {
    // 1. 初始化 TTS 引擎
    this.ttsEngine = await speechTTS.createEngine({
      language: 'zh-CN',
      person: speechTTS.VoicePerson.VOICE_PERSON_FEMALE,
      speed: 1.0,
      volume: 1.0
    })
    
    // 2. 创建媒体会话（用于通知栏控制）
    this.avSession = await avSession.createAVSession(context, 'MDReader', 'audio')
    this.setupAVSessionCallbacks()
    
    // 3. 申请后台任务保活
    this.applyBackgroundTask()
  }
  
  // 开始朗读
  async start(content: string, fromParagraph: number = 0) {
    const paragraphs = this.splitIntoParagraphs(content)
    
    for (let i = fromParagraph; i < paragraphs.length; i++) {
      this.currentParagraph = i
      await this.speakParagraph(paragraphs[i])
      this.updateProgress(i / paragraphs.length)
    }
  }
  
  // 后台播放保活
  private applyBackgroundTask() {
    backgroundTaskManager.requestSuspendDelay('MDReader_TTS', () => {
      // 申请延长后台运行时间
      this.applyBackgroundTask()
    })
  }
  
  // 通知栏媒体控制
  private setupAVSessionCallbacks() {
    this.avSession.on('play', () => this.resume())
    this.avSession.on('pause', () => this.pause())
    this.avSession.on('stop', () => this.stop())
    this.avSession.on('seek', (time) => this.seekTo(time))
  }
}
```

### 4.3 朗读 UI 控制条

```typescript
// TTSControlBar.ets
@Component
struct TTSControlBar {
  @Consume ttsService: TTSService
  @State isExpanded: boolean = false
  
  build() {
    Column() {
      // 迷你模式：进度条 + 播放/暂停
      Row() {
        // 段落指示器
        Text(`${this.ttsService.currentParagraph + 1}/${this.ttsService.totalParagraphs}`)
          .fontSize(12)
          .fontColor('#666')
        
        // 进度条
        Slider({
          value: this.ttsService.progress,
          min: 0,
          max: 100
        })
        .layoutWeight(1)
        .onChange((v) => this.ttsService.seekTo(v))
        
        // 播放/暂停按钮
        Button(this.ttsService.isPlaying ? '⏸' : '▶')
          .onClick(() => this.togglePlay())
        
        // 展开更多
        Button('⚙')
          .onClick(() => this.isExpanded = !this.isExpanded)
      }
      .width('100%')
      .padding(12)
      
      // 展开模式：更多控制
      if (this.isExpanded) {
        Column() {
          // 语速调节
          Row() {
            Text('语速')
            Slider({ value: this.ttsService.speed, min: 0.5, max: 2.0, step: 0.1 })
              .layoutWeight(1)
              .onChange((v) => this.ttsService.setSpeed(v))
            Text(`${this.ttsService.speed.toFixed(1)}x`)
          }
          
          // 定时关闭
          Row() {
            Text('定时关闭')
            Select([
              { value: '不开启' },
              { value: '15分钟' },
              { value: '30分钟' },
              { value: '60分钟' }
            ])
          }
          
          // 音色选择
          Row() {
            Text('音色')
            Row() {
              Button('女声')
                .type(this.ttsService.voice === 'female' ? ButtonType.Normal : ButtonType.Capsule)
                .onClick(() => this.ttsService.setVoice('female'))
              Button('男声')
                .type(this.ttsService.voice === 'male' ? ButtonType.Normal : ButtonType.Capsule)
                .onClick(() => this.ttsService.setVoice('male'))
            }
          }
        }
        .padding(12)
        .backgroundColor('#f5f5f5')
        .transition(TransitionEffect.asymmetric(
          TransitionEffect.OPACITY.combine(TransitionEffect.move(TransitionEdge.TOP)),
          TransitionEffect.OPACITY
        ))
      }
    }
    .width('100%')
    .backgroundColor('#ffffff')
    .shadow({ radius: 10, color: 'rgba(0,0,0,0.1)' })
  }
}
```

---

## 5. 页面设计

### 5.1 阅读页面（核心页面）

```
┌─────────────────────────────────────┐
│ 返回  文件名.md        目录  更多   │  ← 顶部导航（可隐藏）
├─────────────────────────────────────┤
│                                     │
│                                     │
│         Markdown 渲染区域            │  ← 主要内容区
│         支持上下滑动阅读             │
│                                     │
│                                     │
├─────────────────────────────────────┤
│  ⏪  ⏯  ⏩  [=======]  0:42/5:30   │  ← 朗读控制条（悬浮）
└─────────────────────────────────────┘
```

### 5.2 文件列表页面

```
┌─────────────────────────────────────┐
│  MD 阅读器              🔍  📁      │
├─────────────────────────────────────┤
│ 📄 最近阅读                         │
│    README.md              2小时前   │
│    设计文档.md            昨天      │
├─────────────────────────────────────┤
│ 📁 本地文件 /sdcard/Documents       │
│    📄 项目文档.md                   │
│    📄 学习笔记.md                   │
│    📁 技术博客/                     │
├─────────────────────────────────────┤
│ ⭐ 收藏夹                           │
│    📄 必读书单.md                   │
└─────────────────────────────────────┘
```

---

## 6. 数据模型

```typescript
// models/Document.ets
interface Document {
  id: string
  name: string
  path: string
  source: 'local' | 'cloud'
  lastOpenTime: number
  readingPosition: number // 字符偏移量
  isFavorite: boolean
  tags: string[]
}

// models/ReadingProgress.ets
interface ReadingProgress {
  documentId: string
  charOffset: number // 阅读字符位置
  ttsParagraph: number // 朗读段落索引
  ttsProgress: number // 朗读进度 0-100
  updatedAt: number
}

// models/TTSSettings.ets
interface TTSSettings {
  speed: number // 0.5 - 2.0
  pitch: number // 0.5 - 2.0
  volume: number // 0 - 1
  voice: 'male' | 'female' | 'custom'
  autoScroll: boolean // 朗读时自动滚动
  highlightSentence: boolean // 高亮当前句子
  sleepTimer: number // 0 = 关闭, 15/30/60 分钟
}
```

---

## 7. 项目结构

```
entry/src/main/ets/
├── entryability/
│   └── EntryAbility.ets          # 入口 Ability
├── pages/
│   ├── Index.ets                 # 文件列表首页
│   ├── ReaderPage.ets            # 阅读页面
│   ├── SettingsPage.ets          # 设置页面
│   └── SearchPage.ets            # 搜索页面
├── components/
│   ├── MDRender/                 # Markdown 渲染组件
│   │   ├── MDRender.ets
│   │   └── MDStyles.ets
│   ├── TTSControl/               # 朗读控制组件
│   │   ├── TTSControlBar.ets
│   │   ├── TTSSettingsDialog.ets
│   │   └── ParagraphHighlight.ets
│   ├── FileList/                 # 文件列表组件
│   │   ├── FileList.ets
│   │   └── FileItem.ets
│   └── common/                   # 通用组件
│       ├── Loading.ets
│       └── EmptyState.ets
├── services/
│   ├── TTSService.ets            # 朗读服务（核心）
│   ├── FileService.ets           # 文件管理服务
│   ├── CloudSyncService.ets      # 云同步服务
│   └── StorageService.ets        # 本地存储服务
├── utils/
│   ├── MarkdownParser.ts         # Markdown 解析
│   ├── HTMLGenerator.ts          # HTML 生成
│   └── Constants.ets             # 常量定义
└── models/
    ├── Document.ets              # 文档模型
    ├── ReadingProgress.ets       # 阅读进度
    └── TTSSettings.ets           # TTS 设置
```

---

## 8. 关键功能实现要点

### 8.1 后台播放实现

```typescript
// 1. 在 module.json5 声明后台模式
{
  "abilities": [{
    "backgroundModes": ["audioPlayback"]
  }]
}

// 2. 申请长时任务
import { backgroundTaskManager } from '@kit.BackgroundTasksKit'

async function startLongRunningTask() {
  const request: backgroundTaskManager.DelaySuspendRequest = {
    reason: backgroundTaskManager.DelaySuspendReason.AUDIO_PLAYBACK,
    callback: () => {
      console.log('后台任务即将结束，申请延长')
      startLongRunningTask()
    }
  }
  const delayInfo = backgroundTaskManager.requestSuspendDelay(request)
}

// 3. 创建媒体会话（通知栏控制）
const session = await avSession.createAVSession(context, 'MDReader', 'audio')
await session.activate()
await session.setAVMetadata({
  title: '正在朗读',
  artist: document.name,
  mediaImage: 'icon.png',
  duration: totalDuration,
  presentPosition: currentPosition
})
```

### 8.2 Live View（状态岛）集成

```typescript
import { liveViewManager } from '@kit.PushKit'

// 朗读开始时创建 Live View
async function showLiveView() {
  const liveView = {
    id: 'md_reader_tts',
    template: {
      type: liveViewManager.LiveViewType.CAPSULE,
      title: 'MD阅读器',
      content: `朗读中: ${currentDoc.name}`,
      button: {
        text: this.isPlaying ? '暂停' : '继续',
        action: 'mdreader://tts/toggle'
      }
    }
  }
  await liveViewManager.startLiveView(liveView)
}
```

---

## 9. 语法高亮引擎实现

### 9.1 关键技术选型

| 技术点 | 方案 | 说明 |
|--------|------|------|
| **渲染方式** | `RichText` + 预生成 HTML | 性能优于 WebView，支持代码高亮注入 |
| **高亮算法** | 客户端正则表达式 | 无需网络，支持 8 种语言（TS/Java/Python/C/Go/Swift/Kotlin/JSON） |
| **冲突解决** | 占位符（Placeholder）保护 | 用 `@__PH_${i}__@` 临时替换已匹配 token，防止正则嵌套冲突 |
| **无语言标识** | 纯文本处理 | 未指定语言时只进行 HTML 转义，不做语法高亮 |

### 9.2 高亮处理流程

```
原始代码 → HTML 转义(&<>) → 字符串占位 → 注释占位 → 关键字占位 
                                                        ↓
完整 HTML ← 占位符还原 ← ... ← 数字占位 ← 常量占位 ← 函数名占位
```

### 9.3 关键坑点与修复

#### 坑点 1：占位符泄漏（最严重）
**现象**：代码中出现 `@__PH_216__` 等未替换的占位符

**根因**：
- Swift/Kotlin 的 `@\w+` 正则匹配了 `@__PH_XX__@` 中的 `@__PH_XX__` 部分
- 函数名 `\w+(?=\()` 匹配了 `__PH_216__`（如果后面有括号）

**修复**：添加负向前瞻排除占位符格式
```typescript
/@(?!__PH_)\w+/g        // Swift/Kotlin 注解
/(?!__PH_)\w+(?=\()/g   // 函数名
```

#### 坑点 2：数字后缀匹配失败
**现象**：`0L`、`0.0f` 只高亮部分字符或完全不高亮

**根因**：`\b`（单词边界）在数字和字母之间**不成立**（都是单词字符 `\w`）

**修复**：用 `(?<\w)(?!\w)` 替代 `\b`
```typescript
// 修复前：/\b\d+\.?\d*\b/g
// 修复后：
/(?<!\w)(?!PH_)(\d+\.?\d*[fFLl]?)(?!\w)/g
```

#### 坑点 3：字符字面量缺失
**现象**：`'t'`、`'\n'` 等单引号字符在 Java/Kotlin/Swift 中不高亮

**修复**：为相关语言添加单引号字符正则
```typescript
html = html.replace(/'[^']*'/g, (m) => addToken(m, 'string'))
```

#### 坑点 4：下划线数字分隔符
**现象**：Python `1_000_000` 只高亮 `1`

**修复**：数字正则添加 `_` 支持
```typescript
/\d[\d_]*\.?\d*([eE][+-]?\d+)?/g
```

### 9.4 正则表达式汇总

| 语言 | 关键正则 |
|------|----------|
| TypeScript/Java | `(?<!\w)(?!PH_)(0[xX][0-9a-fA-F_]+\|0[oO]?[0-7_]+\|0[bB][01_]+\|\d[\d_]*\.?\d*([eE][+-]?\d+)?[fFLl]?)(?!\w)` |
| Python | `(?<!\w)(?!PH_)(0[xX][0-9a-fA-F]+\|0[oO]?[0-7]+\|0[bB][01]+\|\d+\.?\d*([eE][+-]?\d+)?[fFLl]?)(?!\w)` |
| Swift/Kotlin | `(?<!\w)(?!PH_)(0[xX][0-9a-fA-F_]+\|0[oO][0-7_]+\|0[bB][01_]+\|\d[\d_]*\.?\d*([eE][+-]?\d+)?)(?!\w)` |
| 注解/属性 | `/@(?!__PH_)\w+/g` |
| 函数名 | `/(?!__PH_)\w+(?=\()/g` |

---

## 10. 锚点 ID 生成规则

### 10.1 规则概述

Markdown 阅读器支持自动生成锚点 ID（Anchor ID），用于实现目录跳转功能。锚点 ID 的生成遵循 GFM（GitHub Flavored Markdown）规范，并针对中文内容进行了优化。

### 10.2 生成规则

#### 10.2.1 自定义 ID 优先

如果标题包含自定义 ID 语法 `{#custom-id}`，直接使用该 ID：

```markdown
## 标题 {#my-custom-id}
```

生成 ID：`my-custom-id`

#### 10.2.2 默认 ID 生成规则

对于没有自定义 ID 的标题，按照以下步骤生成：

| 步骤 | 规则 | 示例 |
|------|------|------|
| 1 | 移除 HTML 标签 | `<b>标题</b>` → `标题` |
| 2 | 转为小写 | `Hello World` → `hello world` |
| 3 | 移除所有标点符号（包括中文标点） | `一、核心结论` → `一核心结论` |
| 4 | 将空格替换为连字符 | `hello world` → `hello-world` |
| 5 | 合并连续的连字符 | `hello--world` → `hello-world` |
| 6 | 移除首尾的连字符 | `-hello-world-` → `hello-world` |

**中文标点范围**：`\u3000-\u303F`（CJK符号和标点）、`\uFF00-\uFFEF`（全角字符）

### 10.3 生成示例

| 标题 | 生成 ID |
|------|---------|
| `## 一、核心结论概览` | `一核心结论概览` |
| `## Hello World` | `hello-world` |
| `## 2.1 Kimi (月之暗面)` | `21-kimi-月之暗面` |
| `## 标题 {#custom-id}` | `custom-id` |
| `## 标题 {#section-1}` | `section-1` |
| `## 国内外头部AI公司盈利状况` | `国内外头部ai公司盈利状况` |

### 10.4 目录链接处理

目录链接中的锚点 ID 也会经过同样的 `generateAnchorId` 处理：

```markdown
[链接文本](#一核心结论概览)
```

处理后：`#一核心结论概览`

### 10.5 关键设计决策

#### 决策 1：中文标点直接移除而非替换为连字符

**背景**：早期实现将中文标点替换为连字符（如 `、` → `-`），导致标题 ID 为 `一-核心结论概览`，而用户手动输入的目录链接为 `#一核心结论概览`，两者不匹配。

**解决方案**：直接移除中文标点，不生成连字符。这样：
- 标题 `## 一、核心结论概览` 生成 ID `一核心结论概览`
- 目录链接 `[文本](#一核心结论概览)` 指向 `#一核心结论概览`
- 两者匹配，锚点跳转正常工作

#### 决策 2：保留英文标点的连字符替换

英文标点（如 `.`、`-`、`(`、`)`）仍然替换为连字符，以兼容 GFM 规范：
- `## 2.1 Kimi (月之暗面)` → `21-kimi-月之暗面`

---

## 11. 性能优化

| 优化项 | 方案 |
|--------|------|
| 大文件渲染 | 虚拟滚动 + 分页加载 |
| 图片加载 | 懒加载 + 缓存池 |
| TTS 预加载 | 预读下一段落，无缝衔接 |
| 后台保活 | 合理使用后台任务 + 媒体会话 |
| 内存管理 | Web 组件复用 + 及时释放 |

---

## 12. 迭代路线图

### V1.0 - MVP（基础阅读）
- [x] 本地文件浏览
- [x] Markdown 基础渲染
- [x] 主题切换
- [x] 基础朗读功能

### V1.1 - 朗读增强
- [ ] 后台播放 + 通知栏控制
- [ ] 语速/音色调节
- [ ] 定时关闭
- [ ] 朗读进度记忆

### V1.2 - 体验优化
- [x] 华为云盘同步
- [x] 服务卡片
- [x] Live View
- [x] 代码高亮增强

### V1.3 - 高级功能
- [ ] 全文搜索
- [ ] 标签管理
- [ ] 导出 PDF
- [ ] 批注功能

---

## 13. 日志规范

### 13.1 日志系统选型

**禁止使用 `console.log`**，统一使用鸿蒙官方 `hilog` 模块：

```typescript
// 正确
import { hilog } from '@kit.PerformanceAnalysisKit'
hilog.info(DOMAIN, 'testTag', 'message: %{public}s', value)

// 错误
console.log('message:', value)  // 不会输出到 hilog
```

### 13.2 Domain 分配

| 模块 | Domain | 说明 |
|------|--------|------|
| EntryAbility | 0x0000 | 应用入口 Ability |
| Index 页面 | 0x0001 | 文件列表首页 |
| FileService | 0x0002 | 文件管理服务 |
| MDRender | 0x0003 | Markdown 渲染组件 |
| ReaderPage | 0x0004 | 阅读页面 |
| TTSService | 0x0005 | 朗读服务 |
| 其他模块 | 0x0006+ | 按需分配 |

### 13.3 日志格式

```typescript
const DOMAIN = 0x0003  // 模块对应的 domain
const TAG = 'testTag'   // 统一使用 testTag

// 字符串日志
hilog.info(DOMAIN, TAG, '%{public}s', '[MDRender] aboutToAppear called')

// 带参数的日志
hilog.info(DOMAIN, TAG, '[MDRender] content length: %{public}d', this.content.length)
hilog.info(DOMAIN, TAG, '[MDRender] preview: %{public}s', this.content.substring(0, 200))

// 错误日志
hilog.error(DOMAIN, TAG, '[MDRender] error: %{public}s', JSON.stringify(e))
```

### 13.4 关键规则

1. **必须使用 `%{public}` 前缀**：否则变量值不会输出
   ```typescript
   // 正确
   hilog.info(DOMAIN, TAG, 'value: %{public}s', value)
   
   // 错误 - 不会显示 value 的值
   hilog.info(DOMAIN, TAG, 'value: ' + value)
   ```

2. **占位符类型**：
   - `%{public}s` - 字符串
   - `%{public}d` - 整数
   - `%{public}f` - 浮点数

3. **查看日志命令**：
   ```bash
   # 查看所有日志
   hdc shell hilog -x
   
   # 按 domain 过滤
   hdc shell hilog -x -D 0x0000,0x0001,0x0002
   
   # 按 tag 过滤
   hdc shell hilog -x -T testTag
   
   # 查看应用日志
   hdc shell hilog -x -t app
   ```

### 13.5 迁移记录

**2026-03-10**: 全项目迁移 `console.log` → `hilog`
- MDRender.ets: 11 处替换
- FileService.ets: 待替换
- ReaderPage.ets: 待替换
- HTMLGenerator.ets: 待替换（JS 中的 console.log 保留）

**2026-03-10**: 语法高亮增强
- Python: 添加 `0j` 虚数支持，添加 `@decorator` 装饰器高亮
- C/C++: 添加 `nullptr` 关键字，支持 `0LL`, `0U`, `0UL`, `0ULL` 等整数后缀，添加 `do` 关键字
- C/C++: 扩展关键字列表（new, delete, try, catch, constexpr, noexcept 等）
- TypeScript/JavaScript: 添加 `@decorator` 装饰器高亮，添加 `do`, `switch`, `case`, `default`, `break`, `continue`, `debugger`, `with`, `yield`, `template` 关键字，添加正则表达式 `/regex/g` 高亮
- Java: 添加 `@Annotation` 注解高亮，添加 `do`, `switch`, `case`, `default`, `break`, `continue`, `byte`, `short`, `long` 关键字

**2026-03-10**: 语法高亮修复
- C/C++: 修复 `do` 关键字高亮问题（关键字按长度排序）
- Kotlin: 添加二进制数字 `0b1010` 高亮支持
- JSON: 修复转义引号导致的高亮问题
- Go: `const` 枚举常量高亮（全大写标识符）

**2026-03-10**: 样式修复
- 修复标题锚点链接（#）默认状态下显示并挤占内容的问题
- 使用绝对定位让锚点链接悬浮在标题左侧，不占据文档流空间

**2026-03-10**: 引用块渲染修复
- 修复引用块内列表不显示的问题
- 修复引用块内加粗不生效的问题
- 修复引用块内代码显示 `>` 的问题
- 修复嵌套引用层级关系显示问题
- 修复引用块内代码块处理逻辑

---

## 14. 开发注意事项

1. **权限申请**：文件读写、后台任务、TTS
2. **适配规范**：遵循鸿蒙设计规范，支持横竖屏
3. **隐私合规**：本地处理优先，云同步需用户授权
4. **性能监控**：大文件（>1MB）渲染性能测试
5. **日志规范**：统一使用 hilog，禁止 console.log

---

*文档版本: v1.3*
*更新日期: 2026-03-10*
*适配系统: HarmonyOS NEXT 5.0+*