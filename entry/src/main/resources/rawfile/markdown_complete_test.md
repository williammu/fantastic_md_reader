# Markdown 完整测试文档

> **文档说明**: 本文档用于全面测试 MD 阅读器对所有 Markdown 语法的支持情况。包含从基础到高级的所有 Markdown 元素。

---

## 一、基础文本元素

### 1.1 普通段落

这是一个普通段落。它包含多行文本，用于测试段落的自动换行和行间距。Markdown 中的段落由一个或多个空行分隔。

这是另一个段落。好的段落间距对于阅读体验至关重要，特别是在移动设备上。

### 1.2 文本样式

**粗体文字**: 这是使用双星号的**粗体**，这是使用双下划线的__粗体__。

*斜体文字*: 这是使用单星号的*斜体*，这是使用单下划线的_斜体_。

***粗斜体***: 这是同时包含粗体和斜体的***粗斜体文字***。

~~删除线~~: 这是带~~删除线~~的文字，用于表示过时或删除的内容。

**混合样式**: 可以同时使用**粗体、*斜体*和~~删除线~~**。

### 1.3 行内代码

在行内使用 `console.log()` 输出信息。变量 `count` 的值为 `10`。

多个代码片段：`function`、`class`、`interface`、`type`。

### 1.4 转义字符

显示 Markdown 语法字符：\*星号\*、\_下划线\_、\`反引号\`、\# 井号、\[方括号\]。

特殊字符：\\ 反斜杠、\<尖括号\>、\& 与号。

---

## 二、标题元素

# 一级标题 (H1)

## 二级标题 (H2)

### 三级标题 (H3)

#### 四级标题 (H4)

##### 五级标题 (H5)

###### 六级标题 (H6)

### 替代语法 H1
==============

### 替代语法 H2
--------------

---

## 三、代码块测试

### 3.1 TypeScript / JavaScript

```typescript
import { Component } from '@angular/core';

interface User {
  id: number;
  name: string;
  email?: string;
}

class UserService {
  private users: User[] = [];

  async getUser(id: number): Promise<User | undefined> {
    return this.users.find(u => u.id === id);
  }

  addUser(user: User): void {
    this.users.push(user);
  }
}

// 测试数字高亮
const count = 100;
const pi = 3.14159;
const hex = 0xFF;
const binary = 0b1010;
const scientific = 1.5e10;

export default UserService;
```

### 3.2 Java

```java
package com.example.mdreader;

import java.util.ArrayList;
import java.util.List;

public class MarkdownParser {
    private static final String TAG = "MarkdownParser";
    private final List<Token> tokens = new ArrayList<>();

    public MarkdownParser() {
        // 构造函数
    }

    public String parse(String markdown) {
        if (markdown == null || markdown.isEmpty()) {
            return "";
        }
        
        // 解析逻辑
        long startTime = System.currentTimeMillis();
        String result = processMarkdown(markdown);
        long duration = System.currentTimeMillis() - startTime;
        
        System.out.println("Parsing took " + duration + "ms");
        return result;
    }

    private String processMarkdown(String input) {
        return input.replaceAll("\\\\n", "<br>");
    }
}
```

### 3.3 Python

```python
import re
from typing import List, Optional, Dict

def parse_markdown(content: str) -> List[Dict]:
    """
    解析 Markdown 内容为结构化数据
    """
    if not content:
        return []
    
    lines = content.split('\n')
    result = []
    
    # 处理标题
    for line in lines:
        if line.startswith('# '):
            result.append({
                'type': 'h1',
                'content': line[2:]
            })
        elif line.startswith('## '):
            result.append({
                'type': 'h2', 
                'content': line[3:]
            })
    
    return result

# 测试下划线分隔的数字
large_number = 1_000_000
hex_num = 0xDEADBEEF

if __name__ == "__main__":
    print("Parser ready!")
```

### 3.4 C / C++

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_BUFFER_SIZE 1024
#define VERSION "1.0.0"

typedef struct {
    char* content;
    size_t length;
} MarkdownDocument;

MarkdownDocument* create_document(const char* content) {
    MarkdownDocument* doc = (MarkdownDocument*)malloc(sizeof(MarkdownDocument));
    if (doc == NULL) {
        return NULL;
    }
    
    doc->length = strlen(content);
    doc->content = (char*)malloc(doc->length + 1);
    
    if (doc->content != NULL) {
        strcpy(doc->content, content);
    }
    
    return doc;
}

void free_document(MarkdownDocument* doc) {
    if (doc != NULL) {
        free(doc->content);
        free(doc);
    }
}

int main() {
    printf("MD Reader v%s\n", VERSION);
    return 0;
}
```

### 3.5 Swift

```swift
import Foundation
import UIKit

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

class MarkdownRenderer: NSObject {
    @UserDefault(key: "fontSize", defaultValue: 16.0)
    var fontSize: Double
    
    @UserDefault(key: "theme", defaultValue: "light")
    var theme: String
    
    func render(_ markdown: String) -> NSAttributedString {
        // 渲染实现
        let result = NSMutableAttributedString()
        
        // 测试数字后缀
        let floatValue: Float = 3.14
        let longValue: Int64 = 1000000000
        let doubleValue = 2.718281828
        
        return result
    }
}

// 测试字符字面量
let char1: Character = 'A'
let char2: Character = '\n'
let char3: Character = 't'
```

### 3.6 Kotlin

```kotlin
package com.ms.md_reader

import android.content.Context
import android.util.Log
import kotlinx.coroutines.*

class MarkdownParser(private val context: Context) {
    companion object {
        const val TAG = "MarkdownParser"
    }
    
    data class ParseResult(
        val html: String,
        val success: Boolean,
        val error: String? = null
    )
    
    suspend fun parseAsync(content: String): ParseResult {
        return withContext(Dispatchers.IO) {
            try {
                val html = parse(content)
                ParseResult(html, true)
            } catch (e: Exception) {
                Log.e(TAG, "Parse failed", e)
                ParseResult("", false, e.message)
            }
        }
    }
    
    private fun parse(content: String): String {
        // 解析逻辑
        val floatNum = 0.0f
        val longNum = 0L
        val doubleNum = 1.5
        
        return content.replace("# ", "<h1>")
    }
}

// 测试字符
val char1 = 'A'
val char2 = '\n'
```

### 3.7 Go

```go
package main

import (
    "fmt"
    "os"
    "strings"
)

type Document struct {
    Title   string
    Content string
    Tags    []string
}

func (d *Document) Render() string {
    var sb strings.Builder
    sb.WriteString("# ")
    sb.WriteString(d.Title)
    sb.WriteString("\n\n")
    sb.WriteString(d.Content)
    return sb.String()
}

func main() {
    doc := Document{
        Title:   "Hello Go",
        Content: "This is a Go document.",
        Tags:    []string{"go", "markdown"},
    }
    
    fmt.Println(doc.Render())
}
```

### 3.8 JSON

```json
{
  "app": {
    "name": "MD Reader",
    "version": "1.0.0",
    "bundleName": "com.ms.md_reader"
  },
  "features": {
    "markdown": true,
    "tts": true,
    "themes": ["light", "dark", "auto"],
    "languages": ["zh-CN", "en-US"]
  },
  "settings": {
    "fontSize": 16,
    "lineHeight": 1.6,
    "autoScroll": false
  }
}
```

### 3.9 无语言标识代码块

```
这是一个没有指定语言的纯文本代码块。
它应该被渲染为默认样式的代码块。

可以包含特殊字符: < > & "
```

### 3.10 缩进代码块

    这是使用 4 个空格缩进的代码块。
    它应该被识别为代码。
    
    function test() {
        return "indented";
    }

---

## 四、列表元素

### 4.1 无序列表（短横线）

- 苹果
- 香蕉
- 橙子
- 葡萄

### 4.2 无序列表（星号）

* 项目一
* 项目二
* 项目三

### 4.3 无序列表（加号）

+ 选项 A
+ 选项 B
+ 选项 C

### 4.4 有序列表

1. 第一步：准备工作
2. 第二步：执行操作
3. 第三步：检查结果
4. 第四步：完成

### 4.5 嵌套列表

- 水果
  - 苹果
    - 红富士
    - 青苹果
  - 香蕉
  - 橙子
- 蔬菜
  - 胡萝卜
  - 西红柿
    - 樱桃番茄
    - 牛番茄

### 4.6 混合列表（有序嵌套无序）

1. 前端框架
   - React
   - Vue
   - Angular
2. 后端语言
   - Java
   - Python
   - Go
3. 数据库
   - MySQL
   - PostgreSQL
   - MongoDB

### 4.7 任务列表

- [x] 项目初始化
- [x] 基础架构搭建
- [x] Markdown 渲染实现
- [ ] 语法高亮优化
- [ ] TTS 朗读功能
- [ ] 主题切换完善

### 4.8 复杂任务列表

- [ ] 第一阶段
  - [x] 需求分析
  - [x] 技术选型
  - [ ] 原型设计
- [ ] 第二阶段
  - [ ] 核心功能开发
  - [ ] 单元测试
  - [ ] 集成测试

---

## 五、引用块

### 5.1 单行引用

> 这是一段引用文字，用于强调或引用他人的观点。

### 5.2 多行引用

> 这是多行引用的第一行。
> 这是多行引用的第二行。
> 这是多行引用的第三行。

### 5.3 嵌套引用

> 外层引用内容
>
> > 内层引用内容
> >
> > > 最内层引用内容
>
> 回到外层引用

### 5.4 引用中的列表

> 引用段落说明：
>
> - 列表项一
> - 列表项二
> - 列表项三
>
> **重点提示**: 引用中可以包含粗体文字。

### 5.5 引用中的代码

> 以下是引用中的代码示例：
>
> ```typescript
> const greeting = "Hello World";
> console.log(greeting);
> ```

---

## 六、表格元素

### 6.1 基础表格

| 姓名 | 年龄 | 城市 | 职业 |
|------|------|------|------|
| 张三 | 25   | 北京 | 工程师 |
| 李四 | 30   | 上海 | 设计师 |
| 王五 | 28   | 深圳 | 产品经理 |
| 赵六 | 35   | 杭州 | 架构师 |

### 6.2 对齐表格

| 左对齐 | 居中对齐 | 右对齐 |
|:-------|:--------:|-------:|
| 文本1  |  文本2   |   文本3 |
| A      |    B     |       C |
| 长文本 |  中等    |     短 |

### 6.3 表格中包含行内元素

| 功能 | 描述 | 状态 |
|------|------|------|
| **粗体** | 支持 `**text**` | ✅ |
| *斜体* | 支持 `*text*` | ✅ |
| `代码` | 行内代码 | ✅ |
| ~~删除~~ | 删除线 | ✅ |

### 6.4 宽表格（测试横向滚动）

| 姓名 | 年龄 | 城市 | 职业 | 邮箱 | 电话 | 部门 | 入职日期 |
|------|------|------|------|------|------|------|----------|
| 张三 | 25   | 北京 | 工程师 | zhangsan@example.com | 13800138001 | 技术部 | 2020-01-15 |
| 李四 | 30   | 上海 | 设计师 | lisi@example.com | 13800138002 | 设计部 | 2019-06-20 |
| 王五 | 28   | 深圳 | 产品经理 | wangwu@example.com | 13800138003 | 产品部 | 2021-03-10 |

---

## 七、链接与图片

### 7.1 行内链接

访问 [华为开发者网站](https://developer.huawei.com) 获取更多信息。

### 7.2 带标题的链接

[MDN Web 文档](https://developer.mozilla.org "Web 技术文档")

### 7.3 引用式链接

[华为开发者]: https://developer.huawei.com
[Markdown 指南]: https://www.markdownguide.org

这是一个 [引用式链接][华为开发者]。

这是另一个 [Markdown 指南][Markdown 指南]。

### 7.4 自动链接

<https://www.example.com>

<email@example.com>

### 7.5 图片引用

![HarmonyOS Logo](https://developer.harmonyos.com/resource/image/logo.png)

### 7.6 带替代文字的图片

![风景图片](https://example.com/landscape.jpg "美丽的山景")

### 7.7 图片链接

[![点击访问华为开发者](https://developer.harmonyos.com/resource/image/logo.png)](https://developer.huawei.com)

---

## 八、分隔线

下面是三种不同语法的分隔线：

***

---

___

---

## 九、HTML 混合

### 9.1 基础 HTML

<div style="background-color: #f0f0f0; padding: 10px; border-radius: 5px;">
  <p>这是一个 HTML div 块</p>
  <p>包含多个段落</p>
</div>

### 9.2 细节折叠

<details>
  <summary>点击展开详情</summary>
  
  这是隐藏的详细内容。
  
  - 可以包含列表
  - 可以包含**粗体**
  
</details>

---

## 十、特殊字符与表情

### 10.1 特殊字符

版权符号：©
注册商标：®
商标：™
欧元符号：€
英镑符号：£
日元符号：¥
摄氏度：°C
分节符：§
省略号：…
破折号：—
短横线：–

### 10.2 Emoji 表情

🎉 庆祝
🔥 火热
✨ 闪亮
🚀 火箭
💡 灵感
📱 手机
🎨 艺术
⚡ 闪电
✅ 完成
❌ 错误

---

## 十一、复杂嵌套场景

### 11.1 列表中的代码

- 使用 `npm install` 安装依赖
- 运行 `npm run build` 构建项目
- 执行 `npm start` 启动服务

### 11.2 引用中的表格

> 产品对比表：
>
> | 特性 | 方案 A | 方案 B |
> |------|--------|--------|
> | 性能 | 高 | 中 |
> | 成本 | 低 | 高 |
> | 维护 | 简单 | 复杂 |

### 11.3 综合复杂文档

# 项目文档

## 概述

本项目是**MD 阅读器**，专为 *HarmonyOS NEXT* 打造。

### 功能列表

1. ✅ **Markdown 渲染**
   - 支持 CommonMark 规范
   - 支持 GFM 扩展
2. 🔊 **智能朗读**
   - 系统级 TTS 集成
   - 后台播放支持
3. 🎨 **主题切换**
   - 浅色/深色模式
   - 跟随系统

### 代码示例

```typescript
class App {
  init(): void {
    console.log('App initialized');
  }
}
```

### 贡献者

> 感谢所有贡献者！
> 
> - [张三](https://github.com/zhangsan)
> - [李四](https://github.com/lisi)

---

**文档结束** - 感谢使用 MD 阅读器！

*最后更新: 2026-03-08*
