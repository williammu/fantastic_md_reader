# Markdown 完整能力测试文档

> **文档说明**: 本文档全面测试 MD 阅读器的所有 Markdown 语法支持能力，包括基础格式、代码高亮、锚点跳转等。

---

## 目录

### 自动生成锚点测试
1. [基础文本元素](#基础文本元素)
2. [标题元素](#标题元素)
3. [代码块与语法高亮](#代码块与语法高亮)
4. [列表元素](#列表元素)
5. [引用块](#引用块)
6. [表格元素](#表格元素)
7. [链接与图片](#链接与图片)
8. [分隔线与混合内容](#分隔线与混合内容)

### 自定义锚点测试
9. [自定义锚点第一节](#section-1-custom)
10. [自定义锚点第二节](#section-2-custom)
11. [自定义锚点第三节](#section-3-custom)

---

## 基础文本元素

### 普通段落

这是一个普通段落。它包含多行文本，用于测试段落的自动换行和行间距。Markdown 中的段落由一个或多个空行分隔。

这是另一个段落。好的段落间距对于阅读体验至关重要，特别是在移动设备上。

### 文本样式

**粗体文字**: 这是使用双星号的**粗体**，这是使用双下划线的__粗体__。

*斜体文字*: 这是使用单星号的*斜体*，这是使用单下划线的_斜体_。

***粗斜体***: 这是同时包含粗体和斜体的***粗斜体文字***。

~~删除线~~: 这是带~~删除线~~的文字，用于表示过时或删除的内容。

**混合样式**: 可以同时使用**粗体、*斜体*和~~删除线~~**。

### 行内代码

在行内使用 `console.log()` 输出信息。变量 `count` 的值为 `10`。

多个代码片段：`function`、`class`、`interface`、`type`。

### 转义字符

显示 Markdown 语法字符：\*星号\*、\_下划线\*、\`反引号\`、\# 井号、\[方括号\]。

特殊字符：\\ 反斜杠、\<尖括号\>、\& 与号。

---

## 标题元素

# 一级标题 (H1)

## 二级标题 (H2)

### 三级标题 (H3)

#### 四级标题 (H4)

##### 五级标题 (H5)

###### 六级标题 (H6)

替代语法 H1
==============

替代语法 H2
--------------

---

## 代码块与语法高亮

### TypeScript / JavaScript

```typescript
// TypeScript Keywords Test
import { Type } from "module";
export { Type };

const x: number = 0;
let y: string = "";
var z: boolean = false;

async function test(): Promise<void> {
  await new Promise((resolve) => setTimeout(resolve, 0));
}

class MyClass extends Base implements Interface {
  public prop: number;
  private _value: string;
  protected parent: any;
  
  constructor() {
    super();
    this.prop = 0;
  }
  
  get value(): string {
    return this._value;
  }
  
  set value(v: string) {
    this._value = v;
  }
  
  async method(): Promise<void> {
    try {
      const result = await fetch();
    } catch (e) {
      throw e;
    } finally {
      return;
    }
  }
}

interface MyInterface {
  readonly prop: number;
}

type MyType = string | number | boolean | null | undefined | object | symbol | bigint;

// Control flow
if (true) {} else if (false) {} else {}
for (let i = 0; i < 10; i++) {}
while (false) {}
do {} while (false);
for (const item of []) {}
for (const key in {}) {}
switch (0) { case 0: break; default: break; }

// Literals
true;
false;
null;
undefined;
0;
0xFF;
0b1010;
0o777;
"string";
'string';
`template`;
/regex/g;
```

### Java

```java
// Java Keywords Test
package com.example.test;

import java.util.*;
import static java.lang.System.*;

public class TestClass extends BaseClass implements InterfaceA, InterfaceB {
    // Access modifiers
    public int publicField;
    private int privateField;
    protected int protectedField;
    
    // Other modifiers
    static int staticField;
    final int finalField = 0;
    transient int transientField;
    volatile int volatileField;
    
    // Constructor
    public TestClass() {
        super();
        this.publicField = 0;
    }
    
    // Methods
    public void voidMethod() {
        return;
    }
    
    public int returnMethod() {
        byte b = 0;
        short s = 0;
        int i = 0;
        long l = 0L;
        float f = 0.0f;
        double d = 0.0;
        char c = 'a';
        boolean bool = true;
        
        return i;
    }
    
    // Control flow
    public void controlFlow(int x) {
        if (x > 0) {
            // true branch
        } else if (x < 0) {
            // false branch
        } else {
            // default
        }
        
        for (int i = 0; i < 10; i++) {
            continue;
        }
        
        while (false) {
            break;
        }
        
        do {
            break;
        } while (false);
        
        switch (x) {
            case 0:
                break;
            case 1:
                break;
            default:
                break;
        }
        
        // Try-catch-finally
        try {
            throw new Exception();
        } catch (Exception e) {
            // handle
        } finally {
            // cleanup
        }
    }
    
    // Enum
    public enum Status {
        ACTIVE, INACTIVE, PENDING
    }
    
    // Annotation
    @Override
    @Deprecated
    public void annotatedMethod() {}
}

// Constants
class Constants {
    public static final int MAX = 100;
    public static final String NAME = "Test";
}

// Literals
true;
false;
null;
"string";
's';
0;
0L;
0.0f;
0.0;
0xFF;
0b1010;
```

### Python

```python
# Python Keywords Test
# Comments start with #

# Import statements
import os
import sys as system
from collections import defaultdict
from typing import List, Dict, Optional, Union

# Function definition
def test_function(param: int) -> None:
    """Docstring"""
    pass

# Async function
async def async_function() -> None:
    await asyncio.sleep(0)

# Lambda
square = lambda x: x ** 2

# Class definition
class MyClass(BaseClass):
    """Class docstring"""
    
    # Class variables
    class_var: int = 0
    
    def __init__(self, value: int) -> None:
        self.value = value
    
    def method(self) -> int:
        return self.value
    
    @classmethod
    def class_method(cls) -> None:
        pass
    
    @staticmethod
    def static_method() -> None:
        pass

# Control flow
def control_flow():
    x = True
    
    # If-elif-else
    if x:
        pass
    elif not x:
        pass
    else:
        pass
    
    # For loop
    for i in range(10):
        continue
        break
    
    # While loop
    while False:
        break
        continue
    
    # Try-except-finally
    try:
        raise Exception()
    except ValueError as e:
        pass
    except Exception:
        pass
    else:
        pass
    finally:
        pass
    
    # With statement
    with open("file") as f:
        pass

# Generator
def generator():
    yield 1
    yield from [2, 3, 4]

# Global and nonlocal
global_var = 0

def outer():
    x = 0
    def inner():
        nonlocal x
        x = 1
    inner()

# Literals
True
False
None
"string"
'string'
f"f-string"
0
0.0
0j
0xFF
0o777
0b1010
1_000_000
```

### C / C++

```c
// C Keywords Test
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>

// Preprocessor directives
#define MAX_SIZE 100
#define MIN(a, b) ((a) < (b) ? (a) : (b))
#define DEBUG

#ifdef DEBUG
    #define LOG(msg) printf("%s\n", msg)
#else
    #define LOG(msg)
#endif

// Typedef and struct
typedef struct {
    int x;
    int y;
} Point;

// Enum
typedef enum {
    RED,
    GREEN,
    BLUE
} Color;

// Function declarations
void void_function(void);
int int_function(int a, int b);
static void static_function(void);

// Main function
int main(int argc, char* argv[]) {
    // Basic types
    char c = 'a';
    short s = 0;
    int i = 0;
    long l = 0L;
    float f = 0.0f;
    double d = 0.0;
    
    // Control flow
    if (i > 0) {
        // true
    } else if (i < 0) {
        // else if
    } else {
        // else
    }
    
    for (int j = 0; j < 10; j++) {
        if (j == 5) continue;
        if (j == 8) break;
    }
    
    while (false) {
        break;
    }
    
    do {
        break;
    } while (false);
    
    switch (i) {
        case 0:
            break;
        case 1:
            break;
        default:
            break;
    }
    
    // Memory
    int* arr = (int*)malloc(sizeof(int) * 10);
    if (arr != NULL) {
        memset(arr, 0, sizeof(int) * 10);
        free(arr);
    }
    
    return 0;
}

// Literals
0;
0L;
0LL;
0U;
0UL;
0ULL;
0.0f;
0.0;
0.0L;
"string";
'c';
true;
false;
nullptr;
NULL;
0xFF;
0b1010;
```

### Swift

```swift
// Swift Keywords Test
import Foundation
import UIKit

// Variables and constants
var variable: Int = 0
let constant: String = "constant"

// Function declaration
func functionName() {}
func functionWithParams(param: Int) {}
func functionWithReturn() -> Int { return 0 }
func functionWithThrows() throws {}
func functionWithAsync() async {}

// Class
open class OpenClass {}
public class PublicClass {}
internal class InternalClass {}
fileprivate class FilePrivateClass {}
private class PrivateClass {}

// Class with inheritance
class BaseClass {
    required init() {}
    func method() {}
}

class DerivedClass: BaseClass {
    override init() {
        super.init()
    }
    
    override func method() {
        super.method()
    }
}

// Struct
struct MyStruct {
    var storedProperty: Int
    let constantProperty: String
    
    var computedProperty: Int {
        get { return storedProperty }
        set { storedProperty = newValue }
    }
    
    mutating func mutate() {
        storedProperty += 1
    }
    
    static func staticMethod() {}
}

// Enum
enum Direction {
    case north
    case south
    case east
    case west
}

// Protocol
protocol Greetable {
    func greet() -> String
}

// Control Flow
func controlFlow() {
    let x = 10
    
    if x > 0 {
        print("Positive")
    } else if x < 0 {
        print("Negative")
    } else {
        print("Zero")
    }
    
    guard x > 0 else {
        print("Not positive")
        return
    }
    
    switch x {
    case 0:
        print("Zero")
    case 1...9:
        print("Single digit")
    default:
        print("Other")
    }
    
    for i in 0..<10 {
        if i == 5 { continue }
        if i == 8 { break }
        print(i)
    }
    
    var count = 0
    while count < 5 {
        count += 1
    }
    
    repeat {
        count -= 1
    } while count > 0
}

// Literals
0;
0.0;
0xFF;
0o777;
0b1010;
"string";
"""
multiline
string
""";
'c';
true;
false;
nil;
```

### Kotlin

```kotlin
// Kotlin Keywords Test

// Package and imports
package com.example.test

import kotlin.math.*
import kotlin.collections.*
import kotlinx.coroutines.*

// Constants
const val MAX_COUNT = 100
const val APP_NAME = "Test App"

// Open class (can be inherited)
open class BaseClass {
    open fun openMethod() {}
    fun finalMethod() {}
}

// Final class (default)
class FinalClass : BaseClass() {
    override fun openMethod() {
        super.openMethod()
    }
}

// Abstract class
abstract class AbstractClass {
    abstract fun abstractMethod()
    fun concreteMethod() {}
}

// Data class
data class User(
    val id: Long,
    val name: String,
    val email: String = ""
)

// Enum class
enum class Status {
    PENDING,
    ACTIVE,
    SUSPENDED,
    DELETED
}

// Interface
interface Printable {
    fun print()
    fun printWithPrefix(prefix: String) {
        println("$prefix: ")
        print()
    }
}

// Object (singleton)
object Singleton {
    val name = "Singleton"
    fun doSomething() {}
}

// Companion object
class MyClass {
    companion object Factory {
        fun create(): MyClass = MyClass()
        const val VERSION = "1.0"
    }
}

// Functions
fun topLevelFunction() {}

fun add(a: Int, b: Int): Int {
    return a + b
}

// Single expression function
fun multiply(a: Int, b: Int) = a * b

// Function with default parameters
fun greet(name: String, greeting: String = "Hello"): String {
    return "$greeting, $name!"
}

// Extension function
fun String.addExclamation(): String = this + "!"

// Generic function
fun <T> singletonList(item: T): List<T> {
    return listOf(item)
}

// Inline function
inline fun <T> measureTime(block: () -> T): T {
    val start = System.currentTimeMillis()
    return block().also {
        println("Time: ${System.currentTimeMillis() - start}ms")
    }
}

// Suspend function
suspend fun suspendFunction() {
    delay(1000)
}

// Control Flow
fun controlFlow() {
    // If as expression
    val max = if (a > b) a else b
    
    // When expression
    val result = when (x) {
        0 -> "zero"
        1, 2, 3 -> "small"
        in 4..10 -> "medium"
        else -> "other"
    }
    
    // For loop
    for (i in 1..10) {
        println(i)
    }
    
    // While
    while (condition) {
        // loop body
    }
    
    // Do-while
    do {
        // loop body
    } while (condition)
}

// Null Safety
fun nullSafety() {
    var nullable: String? = null
    var nonNull: String = "value"
    
    // Safe call
    val length = nullable?.length
    
    // Elvis operator
    val len = nullable?.length ?: 0
    
    // Non-null assertion
    val forced = nullable!!.length
}

// Literals
0;
0L;
0.0;
0.0f;
0xFF;
0b1010;
"string";
"""
multiline
string
""";
't';
true;
false;
null;
```

### Go

```go
// Go Keywords Test
package main

import (
	"fmt"
	"os"
	"strings"
)

// Constants
const (
	Pi     = 3.14159
	MaxInt = int(^uint(0) >> 1)
)

const (
	Sunday = iota
	Monday
	Tuesday
	Wednesday
	Thursday
	Friday
	Saturday
)

// Variables
var (
	globalVar int
	GlobalVar int // Exported
)

// Type definitions
type MyInt int
type String string

// Struct
type Person struct {
	Name    string
	Age     int
	Address *Address
}

type Address struct {
	Street string
	City   string
}

// Interface
type Greeter interface {
	Greet() string
}

// Embedding
type Employee struct {
	Person    // Anonymous field (embedding)
	EmployeeID int
}

func (e Employee) Greet() string {
	return "Hello, I'm " + e.Name
}

// Generic function (Go 1.18+)
func Min[T comparable](a, b T) T {
	if a < b {
		return a
	}
	return b
}

// Main function
func main() {
	// Variables
	var a int
	var b string = "hello"
	
	e := 42           // Short variable declaration
	f := "short decl" // Type inference
	
	// Control flow
	if a > 0 {
		fmt.Println("Positive")
	} else if a < 0 {
		fmt.Println("Negative")
	} else {
		fmt.Println("Zero")
	}
	
	// For loop
	for i := 0; i < 10; i++ {
		if i == 5 {
			continue
		}
		if i == 8 {
			break
		}
	}
	
	// For as while
	n := 0
	for n < 5 {
		n++
	}
	
	// Infinite loop
	for {
		break
	}
	
	// For-range
	arr := []int{1, 2, 3}
	for index, value := range arr {
		_, _ = index, value
	}
	
	// Switch
	switch a {
	case 0:
		fmt.Println("Zero")
	case 1, 2, 3:
		fmt.Println("Small")
	default:
		fmt.Println("Other")
	}
	
	// Select
	ch1 := make(chan int)
	ch2 := make(chan string)
	select {
	case v := <-ch1:
		_ = v
	case v := <-ch2:
		_ = v
	default:
		fmt.Println("No channel ready")
	}
	
	// Goroutine
	go func() {
		fmt.Println("In goroutine")
	}()
	
	// Defer
	defer fmt.Println("Deferred")
	
	// Return
	return
}

// Variadic function
func sum(nums ...int) int {
	total := 0
	for _, num := range nums {
		total += num
	}
	return total
}

// Function with multiple return values
func swap(a, b string) (string, string) {
	return b, a
}
```

### JSON

```json
{
  "_comment": "JSON has very limited keywords - only literals",
  "string_value": "This is a string",
  "number_integer": 42,
  "number_negative": -123,
  "number_float": 3.14159,
  "number_scientific": 1.23e-4,
  "boolean_true": true,
  "boolean_false": false,
  "null_value": null,
  "array_empty": [],
  "array_numbers": [1, 2, 3, 4, 5],
  "array_mixed": [1, "two", true, null, {"nested": "object"}],
  "object_empty": {},
  "object_nested": {
    "level": 2,
    "child": {
      "level": 3,
      "grandchild": {
        "level": 4,
        "deep_value": "Found me!"
      }
    }
  },
  "unicode_string": "Hello, 世界! 🌍",
  "escaped_string": "Line 1\nLine 2\tTabbed",
  "special_chars": "Quotes: \" \\ Backslash: \\ ",
  "empty_string": "",
  "zero": 0,
  "negative_zero": -0,
  "large_number": 9007199254740991
}
```

### 无语言标识代码块

```
这是一个没有指定语言的纯文本代码块。
它应该被渲染为默认样式的代码块。

可以包含特殊字符: < > & "
```

### 缩进代码块

    这是使用 4 个空格缩进的代码块。
    它应该被识别为代码。
    
    function test() {
        return "indented";
    }

---

## 列表元素

### 无序列表（短横线）

- 苹果
- 香蕉
- 橙子
- 葡萄

### 无序列表（星号）

* 项目一
* 项目二
* 项目三

### 无序列表（加号）

+ 选项 A
+ 选项 B
+ 选项 C

### 有序列表

1. 第一步：准备工作
2. 第二步：执行操作
3. 第三步：检查结果
4. 第四步：完成

### 嵌套列表

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

### 混合列表（有序嵌套无序）

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

### 任务列表

- [x] 项目初始化
- [x] 基础架构搭建
- [x] Markdown 渲染实现
- [ ] 语法高亮优化
- [ ] TTS 朗读功能
- [ ] 主题切换完善

### 复杂任务列表

- [ ] 第一阶段
  - [x] 需求分析
  - [x] 技术选型
  - [ ] 原型设计
- [ ] 第二阶段
  - [ ] 核心功能开发
  - [ ] 单元测试
  - [ ] 集成测试

---

## 引用块

### 单行引用

> 这是一段引用文字，用于强调或引用他人的观点。

### 多行引用

> 这是多行引用的第一行。
> 这是多行引用的第二行。
> 这是多行引用的第三行。

### 嵌套引用

> 外层引用内容
>
> > 内层引用内容
> >
> > > 最内层引用内容
>
> 回到外层引用

### 引用中的列表

> 引用段落说明：
>
> - 列表项一
> - 列表项二
> - 列表项三
>
> **重点提示**: 引用中可以包含粗体文字。

### 引用中的代码

> 以下是引用中的代码示例：
>
> ```typescript
> const greeting = "Hello World";
> console.log(greeting);
> ```

---

## 表格元素

### 基础表格

| 姓名 | 年龄 | 城市 | 职业 |
|------|------|------|------|
| 张三 | 25   | 北京 | 工程师 |
| 李四 | 30   | 上海 | 设计师 |
| 王五 | 28   | 深圳 | 产品经理 |
| 赵六 | 35   | 杭州 | 架构师 |

### 对齐表格

| 左对齐 | 居中对齐 | 右对齐 |
|:-------|:--------:|-------:|
| 文本1  |  文本2   |   文本3 |
| A      |    B     |       C |
| 长文本 |  中等    |     短 |

### 表格中包含行内元素

| 功能 | 描述 | 状态 |
|------|------|------|
| **粗体** | 支持 `**text**` | ✅ |
| *斜体* | 支持 `*text*` | ✅ |
| `代码` | 行内代码 | ✅ |
| ~~删除~~ | 删除线 | ✅ |

### 宽表格（测试横向滚动）

| 姓名 | 年龄 | 城市 | 职业 | 邮箱 | 电话 | 部门 | 入职日期 |
|------|------|------|------|------|------|------|----------|
| 张三 | 25   | 北京 | 工程师 | zhangsan@example.com | 13800138001 | 技术部 | 2020-01-15 |
| 李四 | 30   | 上海 | 设计师 | lisi@example.com | 13800138002 | 设计部 | 2019-06-20 |
| 王五 | 28   | 深圳 | 产品经理 | wangwu@example.com | 13800138003 | 产品部 | 2021-03-10 |

---

## 链接与图片

### 行内链接

访问 [华为开发者网站](https://developer.huawei.com) 获取更多信息。

### 带标题的链接

[MDN Web 文档](https://developer.mozilla.org "Web 技术文档")

### 引用式链接

[华为开发者]: https://developer.huawei.com
[Markdown 指南]: https://www.markdownguide.org

这是一个 [引用式链接][华为开发者]。

这是另一个 [Markdown 指南][Markdown 指南]。

### 自动链接

<https://www.example.com>

<email@example.com>

### 图片引用

![HarmonyOS Logo](https://developer.harmonyos.com/resource/image/logo.png)

### 带替代文字的图片

![图片](https://upload.wikimedia.org/wikipedia/commons/4/47/PNG_transparency_demonstration_1.png "wiki的图片")

### 图片链接

[![点击访问华为开发者](https://www.w3.org/assets/logos/w3c-2025-transitional/w3c-2008-public-large.png)](https://www.w3.org/)

---

## 分隔线与混合内容

### 分隔线

下面是三种不同语法的分隔线：

***

---

___

### HTML 混合

<div style="background-color: #f0f0f0; padding: 10px; border-radius: 5px;">
  <p>这是一个 HTML div 块</p>
  <p>包含多个段落</p>
</div>

### 细节折叠

<details>
  <summary>点击展开详情</summary>
  
  这是隐藏的详细内容。
  
  - 可以包含列表
  - 可以包含**粗体**
  
</details>

### 特殊字符与表情

版权符号：©
注册商标：®
商标：™
欧元符号：€
英镑符号：£
日元符号：¥
摄氏度：°C

Emoji 表情：🎉 庆祝 🔥 火热 ✨ 闪亮 🚀 火箭 💡 灵感 📱 手机 🎨 艺术 ⚡ 闪电 ✅ 完成 ❌ 错误

---

## 自定义锚点第一节 {#section-1-custom}

这是使用自定义锚点的第一节内容。

自定义锚点语法：`## 标题 {#custom-anchor-id}`

目录链接：`[链接文本](#custom-anchor-id)`

**测试要点**：
- 自定义锚点 ID 应该直接使用，不经过 generateAnchorId 处理
- 目录链接应该指向 `#section-1-custom`
- 标题 ID 应该是 `section-1-custom`

---

## 自定义锚点第二节 {#section-2-custom}

这是使用自定义锚点的第二节内容。

自定义锚点可以包含连字符、数字和字母：
- `section-2-custom` ✅
- `my-anchor-123` ✅
- `feature-x-y-z` ✅

**注意**：自定义锚点中的连字符会被保留，不会被移除。

---

## 自定义锚点第三节 {#section-3-custom}

这是使用自定义锚点的第三节内容。

### 自动生成 vs 自定义锚点对比

| 类型 | 语法 | 生成 ID | 说明 |
|------|------|---------|------|
| 自动生成 | `## 一、核心结论` | `一核心结论` | 移除中文标点 |
| 自定义 | `## 标题 {#custom-id}` | `custom-id` | 直接使用 |
| 自定义 | `## 标题 {#section-1}` | `section-1` | 保留连字符 |

**重要提示**：
- 使用自定义锚点时，目录链接必须完全匹配自定义 ID
- 自动生成锚点时，目录链接应该与处理后的 ID 匹配

---

## 复杂嵌套场景

### 列表中的代码

- 使用 `npm install` 安装依赖
- 运行 `npm run build` 构建项目
- 执行 `npm start` 启动服务

### 引用中的表格

> 产品对比表：
>
> | 特性 | 方案 A | 方案 B |
> |------|--------|--------|
> | 性能 | 高 | 中 |
> | 成本 | 低 | 高 |
> | 维护 | 简单 | 复杂 |

### 综合复杂文档

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

## 测试总结

### 已测试功能

- ✅ 基础文本格式（粗体、斜体、删除线）
- ✅ 行内代码
- ✅ 各级标题（H1-H6）
- ✅ 代码块与语法高亮（9种语言）
- ✅ 无序列表、有序列表、嵌套列表
- ✅ 任务列表
- ✅ 引用块（单层、嵌套）
- ✅ 表格（基础、对齐、宽表格）
- ✅ 链接（行内、引用式、自动）
- ✅ 图片
- ✅ 分隔线
- ✅ HTML 混合
- ✅ 自动生成锚点
- ✅ 自定义锚点

### 锚点跳转测试

**自动生成锚点**：
- [基础文本元素](#基础文本元素)
- [代码块与语法高亮](#代码块与语法高亮)
- [列表元素](#列表元素)

**自定义锚点**：
- [自定义锚点第一节](#section-1-custom)
- [自定义锚点第二节](#section-2-custom)
- [自定义锚点第三节](#section-3-custom)

---

## 锚点 ID 生成规则测试

> **测试目的**: 验证各种复杂标题的锚点 ID 生成是否符合预期规则

### 目录 - 锚点测试

#### 中文标点测试
- [测试一、顿号](#测试一顿号)
- [测试二：冒号](#测试二冒号)
- [测试三；分号](#测试三分号)
- [测试四！感叹号](#测试四感叹号)
- [测试五？问号](#测试五问号)
- [测试六"引号](#测试六引号)
- [测试七'单引号](#测试七单引号)
- [测试八（括号）](#测试八括号)
- [测试九【方括号】](#测试九方括号)
- [测试十《书名号》](#测试十书名号)

#### 英文标点测试
- [Test 1: Colon](#test-1-colon)
- [Test 2; Semicolon](#test-2-semicolon)
- [Test 3! Exclamation](#test-3-exclamation)
- [Test 4? Question](#test-4-question)
- [Test 5 "Quotes"](#test-5-quotes)
- [Test 6 'Apostrophe'](#test-6-apostrophe)
- [Test 7 (Parentheses)](#test-7-parentheses)
- [Test 8 [Brackets]](#test-8-brackets)
- [Test 9 {Braces}](#test-9-braces)
- [Test 10 <Angle>](#test-10-angle)

#### 空格与连字符测试
- [Test Space Between Words](#test-space-between-words)
- [Test-Multiple-Hyphens](#test-multiple-hyphens)
- [Test_underscore_style](#testunderscorestyle)
- [Test   Multiple   Spaces](#test-multiple-spaces)
- [Test--Double--Hyphens](#test-double-hyphens)

#### 数字与符号测试
- [1. First Item](#1-first-item)
- [2.2 Second Item](#22-second-item)
- [3) Third Item](#3-third-item)
- [Item #4](#item-4)
- [Item $5](#item-5)
- [Item %6](#item-6)
- [Item &7](#item-7)
- [Item *8](#item-8)
- [Item +9](#item-9)
- [Item =10](#item-10)

#### 混合内容测试
- [Mix 中文、English、123](#mix-中文english123)
- [API v2.0 (Beta)](#api-v20-beta)
- [GET /api/v1/users](#get-apiv1users)
- [C++ vs C# vs F#](#c-vs-c-vs-f)
- [Node.js & React.js](#nodejs--reactjs)
- [AI/ML/DL](#aimldl)
- [Q1'2024 Results](#q12024-results)
- [Price: $100.50](#price-10050)
- [Temp: 25°C](#temp-25c)
- [Email: user@example.com](#email-userexamplecom)

#### 自定义锚点测试
- [Custom Anchor 1](#my-custom-anchor-1)
- [Custom Anchor 2](#section_2_custom)
- [Custom Anchor 3](#anchor.with.dots)
- [Custom Anchor 4](#anchor:with:colons)

---

### 中文标点测试

#### 测试一、顿号

测试顿号 `、` 的处理。预期 ID: `测试一顿号`

#### 测试二：冒号

测试冒号 `：` 的处理。预期 ID: `测试二冒号`

#### 测试三；分号

测试分号 `；` 的处理。预期 ID: `测试三分号`

#### 测试四！感叹号

测试感叹号 `！` 的处理。预期 ID: `测试四感叹号`

#### 测试五？问号

测试问号 `？` 的处理。预期 ID: `测试五问号`

#### 测试六"引号

测试引号 `"` 的处理。预期 ID: `测试六引号`

#### 测试七'单引号

测试单引号 `'` 的处理。预期 ID: `测试七单引号`

#### 测试八（括号）

测试括号 `（）` 的处理。预期 ID: `测试八括号`

#### 测试九【方括号】

测试方括号 `【】` 的处理。预期 ID: `测试九方括号`

#### 测试十《书名号》

测试书名号 `《》` 的处理。预期 ID: `测试十书名号`

---

### 英文标点测试

#### Test 1: Colon

测试英文冒号 `:` 的处理。预期 ID: `test-1-colon`

#### Test 2; Semicolon

测试英文分号 `;` 的处理。预期 ID: `test-2-semicolon`

#### Test 3! Exclamation

测试英文感叹号 `!` 的处理。预期 ID: `test-3-exclamation`

#### Test 4? Question

测试英文问号 `?` 的处理。预期 ID: `test-4-question`

#### Test 5 "Quotes"

测试英文引号 `"` 的处理。预期 ID: `test-5-quotes`

#### Test 6 'Apostrophe'

测试英文单引号 `'` 的处理。预期 ID: `test-6-apostrophe`

#### Test 7 (Parentheses)

测试英文括号 `()` 的处理。预期 ID: `test-7-parentheses`

#### Test 8 [Brackets]

测试英文方括号 `[]` 的处理。预期 ID: `test-8-brackets`

#### Test 9 {Braces}

测试英文花括号 `{}` 的处理。预期 ID: `test-9-braces`

#### Test 10 <Angle>

测试英文尖括号 `<>` 的处理。预期 ID: `test-10-angle`

---

### 空格与连字符测试

#### Test Space Between Words

测试空格的处理。预期 ID: `test-space-between-words`

#### Test-Multiple-Hyphens

测试多个连字符的处理。预期 ID: `test-multiple-hyphens`

#### Test_underscore_style

测试下划线的处理。预期 ID: `testunderscorestyle`

#### Test   Multiple   Spaces

测试多个连续空格的处理。预期 ID: `test-multiple-spaces`

#### Test--Double--Hyphens

测试连续连字符的处理。预期 ID: `test-double-hyphens`

---

### 数字与符号测试

#### 1. First Item

测试数字开头的标题。预期 ID: `1-first-item`

#### 2.2 Second Item

测试数字和小数点。预期 ID: `22-second-item`

#### 3) Third Item

测试数字和右括号。预期 ID: `3-third-item`

#### Item #4

测试井号。预期 ID: `item-4`

#### Item $5

测试美元符号。预期 ID: `item-5`

#### Item %6

测试百分号。预期 ID: `item-6`

#### Item &7

测试与号。预期 ID: `item-7`

#### Item *8

测试星号。预期 ID: `item-8`

#### Item +9

测试加号。预期 ID: `item-9`

#### Item =10

测试等号。预期 ID: `item-10`

---

### 混合内容测试

#### Mix 中文、English、123

测试中英数字混合。预期 ID: `mix-中文english123`

#### API v2.0 (Beta)

测试版本号。预期 ID: `api-v20-beta`

#### GET /api/v1/users

测试 API 路径。预期 ID: `get-apiv1users`

#### C++ vs C# vs F#

测试编程语言。预期 ID: `c-vs-c-vs-f`

#### Node.js & React.js

测试技术栈。预期 ID: `nodejs--reactjs`

#### AI/ML/DL

测试缩写。预期 ID: `aimldl`

#### Q1'2024 Results

测试季度报告。预期 ID: `q12024-results`

#### Price: $100.50

测试价格。预期 ID: `price-10050`

#### Temp: 25°C

测试温度。预期 ID: `temp-25c`

#### Email: user@example.com

测试邮箱。预期 ID: `email-userexamplecom`

---

### 自定义锚点测试

#### 自定义锚点 1 {#my-custom-anchor-1}

使用自定义锚点 `{#my-custom-anchor-1}`。预期 ID: `my-custom-anchor-1`

#### 自定义锚点 2 {#section_2_custom}

使用自定义锚点 `{#section_2_custom}`。预期 ID: `section_2_custom`

#### 自定义锚点 3 {#anchor.with.dots}

使用自定义锚点 `{#anchor.with.dots}`。预期 ID: `anchor.with.dots`

#### 自定义锚点 4 {#anchor:with:colons}

使用自定义锚点 `{#anchor:with:colons}`。预期 ID: `anchor:with:colons`

---

### 锚点 ID 生成规则总结

| 输入 | 处理规则 | 输出 ID |
|------|----------|---------|
| `一、核心结论` | 移除中文标点 | `一核心结论` |
| `Hello World` | 空格变连字符 | `hello-world` |
| `Test: Colon` | 英文标点变连字符 | `test-colon` |
| `Test_Underscore` | 下划线移除 | `testunderscore` |
| `1. First Item` | 数字保留，标点变连字符 | `1-first-item` |
| `C++ vs C#` | 特殊符号移除 | `c-vs-c` |
| `标题 {#custom-id}` | 使用自定义 ID | `custom-id` |

---

**文档结束** - 感谢使用 MD 阅读器！

*最后更新: 2026-03-10*
