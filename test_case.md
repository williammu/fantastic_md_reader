# MD 阅读器 HTML 样式展示测试用例

> **文档说明**: 本文档通过检查生成的 HTML 输出，验证 MD 阅读器的所有 Markdown 语法和样式功能是否正确实现。

---

## 已修复问题总结

### 1. 引用块中的代码块显示多余 > 符号（已修复）
- **问题**: 引用块内部的代码块每行前都显示多余的 `>` 字符
- **修复方案**:
  - 调整了 MarkdownParser.parse() 方法中的解析顺序，先处理 parseBlockquotes 再处理外部代码块提取
  - 修复了 parseQuoteContent() 方法，正确合并引用块内部保存的 tags 和 blocks 到外部数组
  - 重新计算占位符索引并替换，确保内容正确恢复
- **验证**: debug_output.html:1477-1485，引用块内的代码块现在无多余 > 字符

### 2. 引用式链接未正确解析（已修复）
- **问题**: 引用式链接定义（[id]: url）和使用（[text][id]）未被解析
- **修复方案**:
  - 在 MarkdownParser.parse() 中添加解析引用式链接定义的代码
  - 添加静态变量 `currentLinkReferences` 存储链接定义
  - 在 parseInlineElements() 中添加解析引用式链接使用的代码
- **验证**: debug_output.html:1522-1524，引用式链接现在正确显示为可点击的链接

### 3. 嵌套方括号链接解析（已修复）
- **问题**: 链接文本包含方括号时无法正确解析
- **修复方案**: 新增 parseLinksWithNestedBrackets() 方法，使用平衡括号算法正确匹配括号
- **测试位置**: test_case.md:7.8, complete_test.md:嵌套方括号链接

### 4. override 关键字高亮（已修复）
- **问题**: Java、Swift、C/C++、Kotlin 的 override 关键字未高亮
- **修复方案**: 在各语言的关键字列表中添加 override 关键字

### 5. C/C++ 预处理指令 #else 和 #elif 高亮（已修复）
- **问题**: #else 和 #elif 预处理指令的井号颜色不一致
- **修复方案**: 添加 #else 和 #elif 的完整高亮支持

### 6. Go 常量高亮（已修复）
- **问题**: Go 的 const 常量未高亮
- **修复方案**: 常量改为全大写（PI, MAX_INT, SUNDAY 等）并正确高亮

### 7. 缩进代码块解析（已修复）
- **问题**: 缩进代码块与嵌套列表冲突
- **修复方案**: 调整解析顺序，在列表解析之后再解析缩进代码块

### 8. Python 语法高亮增强（已修复）
- **问题**: Python 的 `var` 关键字未高亮、类型注解（如 `int`）未高亮、`__init__` 未高亮
- **修复方案**:
  - 在 Python 关键字列表中添加 `var`
  - 在 Python 关键字列表中添加 `__init__`
  - 添加完整的内置类型和 typing 模块类型高亮支持（int, str, float, bool, list, dict, tuple, set, Callable, Iterable, Iterator, Optional, Union, Any 等）

### 9. 目录浮层跳转无效（已修复）
- **问题**: 点击目录浮层中的项目无法跳转到对应标题位置
- **修复方案**:
  - 在 MDRender 组件中添加 webController 控制 WebView
  - 使用 @Watch 装饰器监听 scrollToAnchor 属性变化
  - 通过执行 JavaScript 代码调用 element.scrollIntoView() 实现平滑滚动
  - 添加 pageLoaded 状态确保页面加载完成后再执行滚动

### 10. 列表前面偶尔出现灰色井号（已修复）
- **问题**: 某些列表项被错误地解析为标题，导致前面出现灰色的锚点链接符号（#）
- **修复方案**:
  - 重写 parseHeaders 方法，使用逐行处理代替正则表达式全局匹配
  - 在处理每行时检查是否是占位符（___HTML_TAG_xxx___ 或 ___CODE_BLOCK_xxx___）
  - 如果是占位符则直接保留，不进行标题解析
  - 分别处理替代语法标题（=== 和 ---）和标准 # 标题

---

---

## 目录

1. [基础文本元素测试](#1-基础文本元素测试)
2. [标题元素测试](#2-标题元素测试)
3. [代码块与语法高亮测试](#3-代码块与语法高亮测试)
4. [列表元素测试](#4-列表元素测试)
5. [引用块测试](#5-引用块测试)
6. [表格元素测试](#6-表格元素测试)
7. [链接与图片测试](#7-链接与图片测试)
8. [分隔线与混合内容测试](#8-分隔线与混合内容测试)
9. [锚点跳转测试](#9-锚点跳转测试)
10. [复杂嵌套场景测试](#10-复杂嵌套场景测试)

---

## 1. 基础文本元素测试

### 1.1 普通段落
- **检查项**:
  - [ ] 段落使用 `<p>` 标签
  - [ ] 段落间有适当的间距
  - [ ] 长文本能正确换行
  - [ ] 段落间距符合规范

### 1.2 粗体文字
- **检查项**:
  - [ ] 使用 `**text**` 时生成 `<strong>` 或 `<span class="bold">`
  - [ ] 使用 `__text__` 时生成 `<strong>` 或 `<span class="bold">`
  - [ ] 粗体文字有正确的样式（加粗）
  - [ ] 粗体与其他样式混合时正确嵌套

### 1.3 斜体文字
- **检查项**:
  - [ ] 使用 `*text*` 时生成 `<em>` 或 `<span class="italic">`
  - [ ] 使用 `_text_` 时生成 `<em>` 或 `<span class="italic">`
  - [ ] 斜体文字有正确的样式（倾斜）
  - [ ] 斜体与其他样式混合时正确嵌套

### 1.4 粗斜体文字
- **检查项**:
  - [ ] 使用 `***text***` 时同时包含粗体和斜体样式
  - [ ] 嵌套标签结构正确
  - [ ] 样式叠加正确显示

### 1.5 删除线
- **检查项**:
  - [ ] 使用 `~~text~~` 时生成 `<del>` 或 `<span class="strikethrough">`
  - [ ] 删除线有正确的样式（横线穿过文字）
  - [ ] 删除线与其他样式混合时正确嵌套

### 1.6 行内代码
- **检查项**:
  - [ ] 使用 `` `code` `` 时生成 `<code>` 标签
  - [ ] 行内代码有背景色
  - [ ] 行内代码有合适的内边距
  - [ ] 行内代码有圆角
  - [ ] 多个行内代码片段在同一段落中正确显示

### 1.7 转义字符
- **检查项**:
  - [ ] `\*` 显示为 `*` 而不是作为斜体标记
  - [ ] `\_` 显示为 `_` 而不是作为斜体标记
  - [ ] `` \` `` 显示为 `` ` `` 而不是作为代码标记
  - [ ] `\#` 显示为 `#` 而不是作为标题标记
  - [ ] `\[` 和 `\]` 显示为 `[` 和 `]` 而不是作为链接标记
  - [ ] `\\` 显示为 `\`
  - [ ] `\<` 和 `\>` 显示为 `<` 和 `>`

### 1.8 HTML 实体和数字字符引用
- **检查项**:
  - [ ] `&amp;` 显示为 `&`
  - [ ] `&lt;` 显示为 `<`
  - [ ] `&gt;` 显示为 `>`
  - [ ] `&quot;` 显示为 `"`
  - [ ] `&copy;` 显示为 `©`
  - [ ] `&nbsp;` 显示为不换行空格
  - [ ] 数字字符引用 `&#65;` 显示为 `A`
  - [ ] 十六进制数字引用 `&#x41;` 显示为 `A`

### 1.9 硬换行和软换行
- **检查项**:
  - [ ] 行尾两个空格生成硬换行 `<br>`
  - [ ] 行尾反斜杠 `\` 生成硬换行 `<br>`
  - [ ] 普通软换行不生成 `<br>`，只显示为空格
  - [ ] 段落内的多个软换行合并为单个空格

---

## 2. 标题元素测试

### 2.1 各级标题（H1-H6）
- **检查项**:
  - [ ] `# 标题` 生成 `<h1>` 标签
  - [ ] `## 标题` 生成 `<h2>` 标签
  - [ ] `### 标题` 生成 `<h3>` 标签
  - [ ] `#### 标题` 生成 `<h4>` 标签
  - [ ] `##### 标题` 生成 `<h5>` 标签
  - [ ] `###### 标题` 生成 `<h6>` 标签
  - [ ] 各级标题字号递减
  - [ ] 各级标题有合适的上边距和下边距
  - [ ] H1 和 H2 有底部边框
  - [ ] 所有标题都有正确的 `id` 属性用于锚点跳转

### 2.2 替代语法标题
- **检查项**:
  - [ ] `===` 替代语法生成 `<h1>`
  - [ ] `---` 替代语法生成 `<h2>`
  - [ ] 替代语法标题有正确的 id 属性

### 2.3 标题锚点链接
- **检查项**:
  - [ ] 每个标题旁边有锚点链接 `#`
  - [ ] 锚点链接使用 `position: absolute` 定位
  - [ ] 锚点链接默认不显示（opacity: 0）
  - [ ] 鼠标悬停在标题上时锚点链接显示（opacity: 1）
  - [ ] 锚点链接有正确的颜色
  - [ ] 锚点链接点击能正确跳转

---

## 3. 代码块与语法高亮测试

### 3.1 TypeScript / JavaScript 语法高亮
- **检查项**:
  - [ ] 代码块使用 `<pre>` 和 `<code>` 标签
  - [ ] 代码块有背景色
  - [ ] 代码块有内边距
  - [ ] 代码块有圆角
  - [ ] 代码块支持横向滚动
  - [ ] 关键字高亮（const, let, var, function, return, if, else, for, while, do, switch, case, default, class, interface, extends, implements, import, export, from, async, await, new, this, typeof, void, true, false, null, undefined, try, catch, finally, throw, enum, type, namespace, module, declare, abstract, readonly, super, in, of, instanceof, keyof, infer, is, as, break, continue, debugger, with, yield, static, public, private, protected）
  - [ ] 字符串高亮（双引号、单引号、反引号模板字符串）
  - [ ] 数字高亮（十进制、十六进制 0xFF、二进制 0b1010、八进制 0o777）
  - [ ] 正则表达式高亮（/regex/g）
  - [ ] 注释高亮（// 单行注释、/* */ 多行注释）
  - [ ] 函数名高亮
  - [ ] 装饰器高亮（@decorator）
  - [ ] 常量高亮（全大写标识符）

### 3.2 Java 语法高亮
- **检查项**:
  - [ ] 关键字高亮（public, private, protected, class, interface, extends, implements, static, final, void, return, if, else, for, while, do, switch, case, default, new, break, continue, byte, short, int, long, String, boolean, char, float, double, import, package, true, false, null, try, catch, finally, throw, enum, abstract, native, strictfp, synchronized, transient, volatile, super, this, instanceof, goto, const, override）
  - [ ] 字符串高亮（双引号、单引号字符）
  - [ ] 数字高亮（整数、长整型 0L、浮点数、十六进制）
  - [ ] 注释高亮（// 单行注释、/* */ 多行注释）
  - [ ] 注解高亮（@Override, @Deprecated）
  - [ ] 函数名高亮
  - [ ] 常量高亮（全大写标识符，包括 enum 常量）

### 3.3 Python 语法高亮
- **检查项**:
  - [ ] 关键字高亮（def, class, var, return, if, elif, else, for, while, in, not, and, or, import, from, as, try, except, finally, raise, pass, break, continue, True, False, None, self, lambda, yield, async, await, with, global, nonlocal, del, assert, match, case, __init__）
  - [ ] 类型注解和内置类型高亮（int, str, float, bool, list, dict, tuple, set, frozenset, bytes, bytearray, memoryview, complex, object, type, NoneType, Callable, Iterable, Iterator, Generator, Sequence, Mapping, MutableMapping, List, Dict, Tuple, Set, Optional, Union, Any, Literal, Protocol, NamedTuple, TypedDict, Final, ClassVar, InitVar, Self, TypeVar, Generic）
  - [ ] 字符串高亮（单引号、双引号、三引号多行字符串）
  - [ ] 数字高亮（整数、浮点数、虚数 0j、十六进制、八进制、二进制）
  - [ ] 注释高亮（# 单行注释）
  - [ ] 装饰器高亮（@classmethod, @staticmethod, @decorator）
  - [ ] 常量高亮（全大写标识符）

### 3.4 C / C++ 语法高亮
- **检查项**:
  - [ ] 预处理指令高亮（#include, #define, #ifdef, #ifndef, #elif, #else, #endif）
  - [ ] 关键字高亮（const_cast, static_cast, dynamic_cast, reinterpret_cast, static_assert, namespace, template, typename, constexpr, noexcept, alignof, alignas, char16_t, char32_t, char8_t, wchar_t, nullptr, signed, unsigned, volatile, restrict, explicit, virtual, override, mutable, friend, delete, typeid, decltype, sizeof, struct, typedef, static, const, break, continue, switch, return, while, class, public, private, protected, extern, inline, throw, catch, enum, union, auto, register, goto, true, false, bool, int, char, float, double, void, long, short, if, else, for, do, case, default, new, try, this, NULL）
  - [ ] 字符串高亮（双引号、单引号字符）
  - [ ] 数字高亮（整数、长整型 0L, 0LL, 无符号 0U, 0UL, 0ULL、浮点数、十六进制、二进制）
  - [ ] 注释高亮（// 单行注释、/* */ 多行注释）
  - [ ] 常量高亮（全大写标识符，包括 enum 常量）

### 3.5 Swift 语法高亮
- **检查项**:
  - [ ] 关键字高亮（import, var, let, func, class, struct, enum, protocol, extension, public, private, internal, fileprivate, open, static, final, mutating, lazy, weak, unowned, override, return, if, else, guard, switch, case, default, for, while, repeat, in, where, break, continue, fallthrough, self, Self, init, deinit, subscript, operator, precedence, nil, true, false, try, catch, throw, throws, rethrows, async, await, associatedtype, typealias, defer, do, Int, String, Double, Float, Bool, Array, Dictionary, Optional, some, any, is, as, Hashable, Codable, Sendable）
  - [ ] 字符串高亮（双引号、三引号多行字符串）
  - [ ] 数字高亮（整数、浮点数、十六进制、八进制、二进制）
  - [ ] 注释高亮（// 单行注释、/* */ 多行注释）
  - [ ] 属性包装器高亮（@）
  - [ ] 函数名高亮
  - [ ] 常量高亮（全大写标识符，包括 enum 常量）

### 3.6 Kotlin 语法高亮
- **检查项**:
  - [ ] 关键字高亮（package, import, fun, val, var, const, lateinit, class, interface, object, data, sealed, open, abstract, public, private, protected, internal, final, override, companion, init, constructor, by, delegate, return, if, else, when, for, while, do, break, continue, try, catch, finally, throw, this, super, null, true, false, is, in, !in, as, as?, typeof, suspend, inline, noinline, crossinline, reified, Int, Long, Short, Byte, Float, Double, Boolean, Char, String, Unit, Nothing, Any, List, Map, Set, Array, enum, out, where, field, property, receiver, setparam, param, expect, actual）
  - [ ] 字符串高亮（双引号、三引号多行字符串）
  - [ ] 数字高亮（整数、长整型 0L、浮点数、十六进制、二进制）
  - [ ] 注释高亮（// 单行注释、/* */ 多行注释）
  - [ ] 注解高亮（@）
  - [ ] 函数名高亮
  - [ ] 常量高亮（全大写标识符，包括 enum 常量）

### 3.7 Go 语法高亮
- **检查项**:
  - [ ] 关键字高亮（package, import, func, var, const, type, struct, interface, map, chan, go, defer, return, if, else, for, range, switch, case, default, break, continue, fallthrough, nil, true, false, iota, make, new, len, cap, append, int, int8, int16, int32, int64, uint, uint8, uint16, uint32, uint64, float32, float64, string, bool, byte, rune, error, select）
  - [ ] 字符串高亮（双引号、反引号 raw 字符串）
  - [ ] 数字高亮（整数、浮点数、十六进制、八进制、二进制）
  - [ ] 注释高亮（// 单行注释、/* */ 多行注释）
  - [ ] 函数名高亮
  - [ ] 常量高亮（全大写标识符，包括 const 声明的常量）
  - [ ] iota 常量正确高亮

### 3.8 JSON 语法高亮
- **检查项**:
  - [ ] 字符串高亮（支持转义引号 \"）
  - [ ] 数字高亮
  - [ ] 关键字高亮（true, false, null）
  - [ ] 嵌套对象正确显示

### 3.9 无语言标识代码块
- **检查项**:
  - [ ] 代码块有背景色
  - [ ] 代码块有内边距
  - [ ] 代码块有圆角
  - [ ] 代码块支持横向滚动
  - [ ] 特殊字符正确转义（<, >, &）

### 3.10 缩进代码块
- **检查项**:
  - [ ] 4 个空格缩进的内容被识别为代码块
  - [ ] 1个 tab 缩进的内容被识别为代码块
  - [ ] 代码块使用 &lt;pre&gt; 和 &lt;code&gt; 标签
  - [ ] 代码块有背景色
  - [ ] 代码块有内边距
  - [ ] 代码块有圆角
  - [ ] 代码块支持横向滚动
  - [ ] 缩进代码块的样式与三个反引号代码块一致

---

## 4. 列表元素测试

### 4.1 无序列表（短横线 -）
- **检查项**:
  - [ ] 使用 `<ul>` 标签
  - [ ] 每个列表项使用 `<li>` 标签
  - [ ] 有合适的左边距
  - [ ] 列表项间距合适
  - [ ] 列表标记样式正确

### 4.2 无序列表（星号 *）
- **检查项**:
  - [ ] 使用 `<ul>` 标签
  - [ ] 每个列表项使用 `<li>` 标签
  - [ ] 样式与短横线列表一致

### 4.3 无序列表（加号 +）
- **检查项**:
  - [ ] 使用 `<ul>` 标签
  - [ ] 每个列表项使用 `<li>` 标签
  - [ ] 样式与短横线列表一致

### 4.4 有序列表
- **检查项**:
  - [ ] 使用 `<ol>` 标签
  - [ ] 每个列表项使用 `<li>` 标签
  - [ ] 数字自动编号
  - [ ] 有合适的左边距
  - [ ] 列表项间距合适

### 4.5 嵌套列表
- **检查项**:
  - [ ] 嵌套列表使用正确的标签嵌套
  - [ ] 嵌套列表有缩进
  - [ ] 二级无序列表使用 circle 标记
  - [ ] 三级无序列表使用 square 标记
  - [ ] 二级有序列表使用小写字母
  - [ ] 三级有序列表使用罗马数字
  - [ ] 嵌套间距合适

### 4.6 混合列表（有序嵌套无序）
- **检查项**:
  - [ ] 有序列表中嵌套无序列表正确
  - [ ] 标签嵌套结构正确
  - [ ] 样式显示正确

### 4.7 任务列表
- **检查项**:
  - [ ] 使用 `<ul>` 标签
  - [ ] 任务列表项有 class="task-list-item"
  - [ ] 复选框正确显示
  - [ ] 已勾选的复选框显示为选中状态
  - [ ] 未勾选的复选框显示为未选中状态
  - [ ] 列表样式正确（无默认列表标记）

### 4.8 复杂任务列表（嵌套）
- **检查项**:
  - [ ] 任务列表可以嵌套
  - [ ] 嵌套任务列表正确显示
  - [ ] 复选框状态正确

---

## 5. 引用块测试

### 5.1 单行引用
- **检查项**:
  - [ ] 使用 `<blockquote>` 标签
  - [ ] 左边有边框
  - [ ] 边框颜色正确
  - [ ] 有合适的左边距
  - [ ] 文字颜色略浅

### 5.2 多行引用
- **检查项**:
  - [ ] 多行内容在同一个 `<blockquote>` 中
  - [ ] 段落间距正确
  - [ ] 样式与单行引用一致

### 5.3 嵌套引用
- **检查项**:
  - [ ] 使用嵌套的 `<blockquote>` 标签
  - [ ] 第一层引用使用主色边框
  - [ ] 第二层引用使用浅主色边框
  - [ ] 第三层引用使用三级文本色边框
  - [ ] 嵌套缩进正确
  - [ ] 多层嵌套的边框颜色层次分明

### 5.4 引用中的列表
- **检查项**:
  - [ ] 引用中可以包含列表
  - [ ] 列表在引用中正确显示
  - [ ] 列表样式正常

### 5.5 引用中的粗体
- **检查项**:
  - [ ] 引用中可以包含粗体
  - [ ] 粗体在引用中正确显示

### 5.6 引用中的代码块
- **检查项**:
  - [ ] 引用中可以包含代码块
  - [ ] 代码块在引用中正确显示
  - [ ] 代码块样式正常
  - [ ] 没有额外的 `>` 符号出现在代码块中

---

## 6. 表格元素测试

### 6.1 基础表格
- **检查项**:
  - [ ] 使用 `<table>` 标签
  - [ ] 使用 `<thead>` 和 `<tbody>`
  - [ ] 使用 `<th>` 表示表头
  - [ ] 使用 `<td>` 表示单元格
  - [ ] 表格有边框
  - [ ] 表头有背景色
  - [ ] 隔行有背景色（斑马纹）
  - [ ] 单元格有内边距
  - [ ] 表格支持横向滚动

### 6.2 对齐表格
- **检查项**:
  - [ ] 左对齐列文本靠左
  - [ ] 居中对齐列文本居中
  - [ ] 右对齐列文本靠右
  - [ ] 使用 `:-----` 表示左对齐
  - [ ] 使用 `:-----:` 表示居中对齐
  - [ ] 使用 `-----:` 表示右对齐

### 6.3 表格中包含行内元素
- **检查项**:
  - [ ] 表格单元格中可以包含粗体
  - [ ] 表格单元格中可以包含斜体
  - [ ] 表格单元格中可以包含行内代码
  - [ ] 表格单元格中可以包含删除线
  - [ ] 行内元素在表格中正确显示

### 6.4 宽表格（测试横向滚动）
- **检查项**:
  - [ ] 宽表格支持横向滚动
  - [ ] 表格不会破坏页面布局
  - [ ] 滚动条样式正常

---

## 7. 链接与图片测试

### 7.1 行内链接
- **检查项**:
  - [ ] 使用 `<a>` 标签
  - [ ] `href` 属性正确
  - [ ] 链接有颜色
  - [ ] 鼠标悬停有下划线
  - [ ] 点击能跳转

### 7.2 带标题的链接
- **检查项**:
  - [ ] `title` 属性正确设置
  - [ ] 鼠标悬停显示提示

### 7.3 引用式链接
- **检查项**:
  - [ ] 引用式链接正确解析
  - [ ] `href` 属性正确指向目标 URL

### 7.4 自动链接
- **检查项**:
  - [ ] `<https://example.com>` 生成链接
  - [ ] `<email@example.com>` 生成邮件链接
  - [ ] 链接样式正确

### 7.5 图片引用
- **检查项**:
  - [ ] 使用 `<img>` 标签
  - [ ] `src` 属性正确
  - [ ] `alt` 属性正确
  - [ ] 图片最大宽度 100%
  - [ ] 图片高度自适应
  - [ ] 图片有圆角
  - [ ] 图片有上下边距

### 7.6 带替代文字的图片
- **检查项**:
  - [ ] `alt` 属性正确
  - [ ] `title` 属性正确
  - [ ] 鼠标悬停显示提示

### 7.7 图片链接
- **检查项**:
  - [ ] 图片包裹在 `<a>` 标签中
  - [ ] 点击图片能跳转
  - [ ] 图片和链接都正确显示

### 7.8 嵌套方括号链接
- **检查项**:
  - [ ] 链接文本中包含方括号时能正确解析，如 `[link [with] brackets](url)`
  - [ ] 多层嵌套方括号能正确解析，如 `[outer [inner [deep]]](url)`
  - [ ] 使用平衡括号算法正确匹配括号
  - [ ] 链接跳转功能正常

---

## 8. 分隔线与混合内容测试

### 8.1 分隔线
- **检查项**:
  - [ ] `***` 生成分隔线
  - [ ] `---` 生成分隔线
  - [ ] `___` 生成分隔线
  - [ ] 分隔线使用 `<hr>` 标签
  - [ ] 分隔线样式正确（边框、间距）

### 8.2 HTML 混合
- **检查项**:
  - [ ] HTML 标签正确保留
  - [ ] HTML 样式正确应用
  - [ ] HTML 内容正确显示

### 8.3 HTML 块
- **检查项**:
  - [ ] 完整 HTML 块（如 `<div>`, `<p>`, `<pre>` 等）正确显示
  - [ ] 行内 HTML 标签（如 `<span>`, `<b>`, `<i>`）正确显示
  - [ ] HTML 块内的 Markdown 内容不被解析
  - [ ] 自闭合标签正确处理（如 `<br/>`, `<hr/>`）
  - [ ] HTML 注释 `<!-- comment -->` 正确显示或隐藏

### 8.4 细节折叠
- **检查项**:
  - [ ] `<details>` 和 `<summary>` 标签正确保留
  - [ ] 折叠功能正常
  - [ ] 展开/折叠样式正确

### 8.5 特殊字符与表情
- **检查项**:
  - [ ] 特殊符号正确显示（©, ®, ™, €, £, ¥, °C）
  - [ ] Emoji 表情正确显示
  - [ ] Unicode 字符正确显示

---

## 9. 锚点跳转测试

### 9.1 自动生成锚点
- **检查项**:
  - [ ] 标题有正确的 `id` 属性
  - [ ] 中文标点被移除（如 `、`, `：`, `；`, `！`, `？`, `“`, `”`, `‘`, `’`, `（`, `）`, `【`, `】`, `《`, `》`）
  - [ ] 英文标点转换为连字符（如 `:`, `;`, `!`, `?`, `"`, `'`, `(`, `)`, `[`, `]`, `{`, `}`, `<`, `>`）
  - [ ] 空格转换为连字符
  - [ ] 多个空格合并为一个连字符
  - [ ] 下划线被移除
  - [ ] 数字保留
  - [ ] 连字符保留
  - [ ] 目录链接 `href` 与标题 `id` 匹配

### 9.2 自定义锚点
- **检查项**:
  - [ ] `## 标题 {#custom-id}` 直接使用 `custom-id` 作为 `id`
  - [ ] 自定义锚点不经过自动生成处理
  - [ ] 自定义锚点中的连字符保留
  - [ ] 自定义锚点中的下划线保留
  - [ ] 自定义锚点中的点保留
  - [ ] 自定义锚点中的冒号保留
  - [ ] 目录链接 `href` 与自定义 `id` 匹配

---

## 10. 复杂嵌套场景测试

### 10.1 列表中的代码
- **检查项**:
  - [ ] 列表项中可以包含行内代码
  - [ ] 代码样式正确
  - [ ] 列表和代码都正确显示

### 10.2 引用中的表格
- **检查项**:
  - [ ] 引用中可以包含表格
  - [ ] 表格在引用中正确显示
  - [ ] 表格样式正常

### 10.3 综合复杂文档
- **检查项**:
  - [ ] 多种元素混合在一起正确显示
  - [ ] 标题、列表、代码、引用、表格、链接、图片都正确
  - [ ] 嵌套结构正确
  - [ ] 样式不冲突

---

## 测试执行记录

| 测试项 | 状态 | 备注 |
|--------|------|------|
| 1.1 普通段落 | ⏳ | |
| 1.2 粗体文字 | ⏳ | |
| 1.3 斜体文字 | ⏳ | |
| 1.4 粗斜体文字 | ⏳ | |
| 1.5 删除线 | ⏳ | |
| 1.6 行内代码 | ⏳ | |
| 1.7 转义字符 | ⏳ | |
| 1.8 HTML 实体和数字字符引用 | ⏳ | |
| 1.9 硬换行和软换行 | ⏳ | |
| 2.1 各级标题 | ⏳ | |
| 2.2 替代语法标题 | ⏳ | |
| 2.3 标题锚点链接 | ⏳ | |
| 3.1 TypeScript/JS高亮 | ⏳ | |
| 3.2 Java高亮 | ⏳ | |
| 3.3 Python高亮 | ⏳ | |
| 3.4 C/C++高亮 | ⏳ | |
| 3.5 Swift高亮 | ⏳ | |
| 3.6 Kotlin高亮 | ⏳ | |
| 3.7 Go高亮 | ⏳ | |
| 3.8 JSON高亮 | ⏳ | |
| 3.9 无语言代码块 | ⏳ | |
| 3.10 缩进代码块 | ⏳ | |
| 4.1 无序列表（-） | ⏳ | |
| 4.2 无序列表（*） | ⏳ | |
| 4.3 无序列表（+） | ⏳ | |
| 4.4 有序列表 | ⏳ | |
| 4.5 嵌套列表 | ⏳ | |
| 4.6 混合列表 | ⏳ | |
| 4.7 任务列表 | ⏳ | |
| 4.8 复杂任务列表 | ⏳ | |
| 5.1 单行引用 | ⏳ | |
| 5.2 多行引用 | ⏳ | |
| 5.3 嵌套引用 | ⏳ | |
| 5.4 引用中的列表 | ⏳ | |
| 5.5 引用中的粗体 | ⏳ | |
| 5.6 引用中的代码块 | ✅ | 已修复无多余 > 符号 |
| 6.1 基础表格 | ⏳ | |
| 6.2 对齐表格 | ⏳ | |
| 6.3 表格中行内元素 | ⏳ | |
| 6.4 宽表格滚动 | ⏳ | |
| 7.1 行内链接 | ⏳ | |
| 7.2 带标题链接 | ⏳ | |
| 7.3 引用式链接 | ✅ | 已正确解析并显示为链接 |
| 7.4 自动链接 | ⏳ | |
| 7.5 图片引用 | ⏳ | |
| 7.6 带替代文字图片 | ⏳ | |
| 7.7 图片链接 | ⏳ | |
| 7.8 嵌套方括号链接 | ✅ | 已实现平衡括号算法 |
| 8.1 分隔线 | ⏳ | |
| 8.2 HTML混合 | ⏳ | |
| 8.3 HTML块 | ⏳ | |
| 8.4 细节折叠 | ⏳ | |
| 8.5 特殊字符表情 | ⏳ | |
| 9.1 自动生成锚点 | ⏳ | |
| 9.2 自定义锚点 | ⏳ | |
| 10.1 列表中的代码 | ⏳ | |
| 10.2 引用中的表格 | ⏳ | |
| 10.3 综合复杂文档 | ⏳ | |

---

**测试状态说明**:
- ⏳ 待测试
- ✅ 通过
- ❌ 失败
- ⚠️ 部分通过

*最后更新: 2026-03-11*
