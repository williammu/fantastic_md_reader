# 语法高亮测试

本文档测试各种编程语言的语法高亮效果。

## TypeScript/JavaScript

```typescript
function calculateSum(a: number, b: number): number {
  // 计算两个数的和
  const result = a + b;
  console.log(`Sum: ${result}`);
  return result;
}

class Calculator {
  private value: number = 0;
  
  public add(n: number): void {
    this.value += n;
  }
  
  public getValue(): number {
    return this.value;
  }
}
```

## Java

```java
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
        
        // 创建一个计算器
        Calculator calc = new Calculator();
        int result = calc.add(5, 3);
        System.out.println("Result: " + result);
    }
}

class Calculator {
    public int add(int a, int b) {
        return a + b;
    }
}
```

## Python

```python
def fibonacci(n):
    """计算斐波那契数列"""
    # 基本情况
    if n <= 1:
        return n
    # 递归调用
    return fibonacci(n-1) + fibonacci(n-2)

class Person:
    def __init__(self, name: str, age: int):
        self.name = name
        self.age = age
    
    def greet(self) -> str:
        return f"Hello, I'm {self.name}"

# 使用示例
person = Person("Alice", 30)
print(person.greet())
```

## C/C++

```c
#include <stdio.h>
#include <stdlib.h>

// 计算阶乘
int factorial(int n) {
    if (n <= 1) {
        return 1;
    }
    return n * factorial(n - 1);
}

int main() {
    int num = 5;
    printf("Factorial of %d is %d\n", num, factorial(num));
    return 0;
}
```

## JSON

```json
{
  "name": "MD Reader",
  "version": "1.0.0",
  "description": "A markdown reader app for HarmonyOS",
  "author": "Developer",
  "license": "MIT",
  "dependencies": {
    "core": "latest"
  },
  "features": [
    "syntax highlighting",
    "tts support",
    "multiple themes"
  ],
  "active": true,
  "stars": 42
}
```

## Go

```go
package main

import (
    "fmt"
    "time"
)

// Person 结构体定义
type Person struct {
    Name string
    Age  int
}

// Greet 方法
func (p Person) Greet() string {
    return fmt.Sprintf("Hello, I'm %s", p.Name)
}

func main() {
    // 创建 Person 实例
    person := Person{
        Name: "Go Developer",
        Age:  25,
    }
    
    fmt.Println(person.Greet())
    
    // 使用 goroutine
    go func() {
        time.Sleep(1 * time.Second)
        fmt.Println("Done!")
    }()
    
    // 通道示例
    ch := make(chan int, 1)
    ch <- 42
    value := <-ch
    fmt.Printf("Received: %d\n", value)
}
```

## Swift

```swift
import Foundation

// 定义协议
protocol Greetable {
    func greet() -> String
}

// Person 类
class Person: Greetable {
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    func greet() -> String {
        return "Hello, I'm \(name) and I'm \(age) years old."
    }
}

// 使用示例
let person = Person(name: "Swift", age: 30)
print(person.greet())

// 可选类型示例
var optionalName: String? = "Optional"
if let name = optionalName {
    print("Name is \(name)")
}

// Guard 语句
func checkAge(age: Int) {
    guard age >= 0 else {
        print("Invalid age")
        return
    }
    print("Valid age: \(age)")
}

// 属性包装器示例
@propertyWrapper
struct Clamped {
    var value: Int
    var range: ClosedRange<Int>
    
    var wrappedValue: Int {
        get { value }
        set { value = min(max(newValue, range.lowerBound), range.upperBound) }
    }
}
```

## Kotlin

```kotlin
package com.example

// 数据类
data class User(
    val id: Long,
    val name: String,
    val email: String
)

// 接口
interface Repository<T> {
    fun findById(id: Long): T?
    fun save(item: T): T
}

// 实现类
class UserRepository : Repository<User> {
    private val users = mutableListOf<User>()
    
    override fun findById(id: Long): User? {
        return users.find { it.id == id }
    }
    
    override fun save(item: User): User {
        users.add(item)
        return item
    }
}

// 扩展函数
fun String.addExclamation(): String {
    return "$this!"
}

// 主函数
fun main() {
    val repository = UserRepository()
    
    // 创建用户
    val user = User(
        id = 1,
        name = "Kotlin Developer",
        email = "kotlin@example.com"
    )
    
    // 保存用户
    repository.save(user)
    
    // 查找用户
    val foundUser = repository.findById(1)
    foundUser?.let {
        println("Found: ${it.name}".addExclamation())
    }
    
    // When 表达式
    val number = 42
    when {
        number < 0 -> println("Negative")
        number == 0 -> println("Zero")
        number > 0 -> println("Positive")
    }
    
    // 协程示例（需要 kotlinx.coroutines）
    // GlobalScope.launch {
    //     delay(1000)
    //     println("Hello from coroutine!")
    // }
}

// 伴生对象
class Config {
    companion object {
        const val VERSION = "1.0.0"
        const val DEBUG = true
    }
}
```

## 内联代码

这是一些内联代码示例：`const x = 42`、`System.out.println()`、`print("Hello")`、`var x = 10`、`let name = "Swift"`、`val user = User()`。

## 没有指定语言的代码块

```
普通文本代码块
没有语法高亮
const x = 42;
```

---

*测试完成*
