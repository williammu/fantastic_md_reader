// 语法高亮测试
import { HTMLGenerator } from '../HTMLGenerator'
import { LightTheme, DarkTheme } from '../../models/Theme'

// 测试语法高亮
export function testSyntaxHighlight(): void {
  console.log('[SyntaxHighlightTest] Starting...')
  
  // TypeScript 测试
  const tsCode = `function greet(name: string): void {
  console.log("Hello, World!");
  // This is a comment
  const x = 42;
}`
  
  const tsResult = HTMLGenerator.highlightCode(tsCode, 'typescript')
  console.log('[TS Result]:', tsResult.substring(0, 200))
  
  if (tsResult.includes('token-keyword') && tsResult.includes('token-string')) {
    console.log('[PASS] TypeScript highlight works')
  } else {
    console.log('[FAIL] TypeScript highlight broken')
  }
  
  // Java 测试
  const javaCode = `public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
        // Comment
        int x = 42;
    }
}`
  
  const javaResult = HTMLGenerator.highlightCode(javaCode, 'java')
  console.log('[Java Result]:', javaResult.substring(0, 200))
  
  if (javaResult.includes('token-keyword')) {
    console.log('[PASS] Java highlight works')
  } else {
    console.log('[FAIL] Java highlight broken')
  }
  
  // Python 测试
  const pyCode = `def fibonacci(n):
    # Calculate fibonacci
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)`
  
  const pyResult = HTMLGenerator.highlightCode(pyCode, 'python')
  console.log('[Python Result]:', pyResult.substring(0, 200))
  
  if (pyResult.includes('token-keyword')) {
    console.log('[PASS] Python highlight works')
  } else {
    console.log('[FAIL] Python highlight broken')
  }
  
  // C 测试
  const cCode = `#include <stdio.h>

int main() {
    printf("Hello, World!\\n");
    // Comment
    int x = 42;
    return 0;
}`
  
  const cResult = HTMLGenerator.highlightCode(cCode, 'c')
  console.log('[C Result]:', cResult.substring(0, 200))
  
  if (cResult.includes('token-keyword')) {
    console.log('[PASS] C highlight works')
  } else {
    console.log('[FAIL] C highlight broken')
  }
  
  // JSON 测试
  const jsonCode = `{
  "name": "MD Reader",
  "version": "1.0.0",
  "count": 42,
  "active": true
}`
  
  const jsonResult = HTMLGenerator.highlightCode(jsonCode, 'json')
  console.log('[JSON Result]:', jsonResult)
  
  if (jsonResult.includes('token-string') && jsonResult.includes('token-keyword')) {
    console.log('[PASS] JSON highlight works')
  } else {
    console.log('[FAIL] JSON highlight broken')
  }
  
  // Go 测试
  const goCode = `package main

import "fmt"

func main() {
    // Hello World
    message := "Hello, Go!"
    fmt.Println(message)
    x := 42
}`
  
  const goResult = HTMLGenerator.highlightCode(goCode, 'go')
  console.log('[Go Result]:', goResult.substring(0, 200))
  
  if (goResult.includes('token-keyword') && goResult.includes('token-string')) {
    console.log('[PASS] Go highlight works')
  } else {
    console.log('[FAIL] Go highlight broken')
  }
  
  // Swift 测试
  const swiftCode = `import Foundation

class Person {
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    func greet() -> String {
        // Greeting
        return "Hello, \\(name)!"
    }
}`
  
  const swiftResult = HTMLGenerator.highlightCode(swiftCode, 'swift')
  console.log('[Swift Result]:', swiftResult.substring(0, 200))
  
  if (swiftResult.includes('token-keyword')) {
    console.log('[PASS] Swift highlight works')
  } else {
    console.log('[FAIL] Swift highlight broken')
  }
  
  // Kotlin 测试
  const kotlinCode = `package com.example

class Person(val name: String) {
    fun greet(): String {
        // Greeting
        return "Hello, $name!"
    }
}

fun main() {
    val person = Person("Kotlin")
    println(person.greet())
}`
  
  const kotlinResult = HTMLGenerator.highlightCode(kotlinCode, 'kotlin')
  console.log('[Kotlin Result]:', kotlinResult.substring(0, 200))
  
  if (kotlinResult.includes('token-keyword')) {
    console.log('[PASS] Kotlin highlight works')
  } else {
    console.log('[FAIL] Kotlin highlight broken')
  }
  
  console.log('[SyntaxHighlightTest] Completed')
}

// 测试完整 HTML 生成
export function testFullHTML(): void {
  console.log('[FullHTMLTest] Starting...')
  
  const markdownContent = `
<h1>Code Examples</h1>
<pre><code class="language-typescript">function hello() {
  console.log("Hello");
  // Comment
  return 42;
}</code></pre>
<pre><code class="language-go">package main
import "fmt"
func main() {
    fmt.Println("Hello, Go!")
}</code></pre>
<pre><code class="language-swift">import Foundation
print("Hello, Swift!")</code></pre>
<pre><code class="language-kotlin">fun main() {
    println("Hello, Kotlin!")
}</code></pre>
<p>Some text with <code>inline code</code>.</p>
`
  
  const html = HTMLGenerator.generate(markdownContent, LightTheme, 54)
  
  // 检查 CSS 中包含语法高亮定义
  if (html.includes('token-keyword') && html.includes('syntaxKeyword')) {
    console.log('[PASS] HTML includes syntax highlighting CSS')
  } else {
    console.log('[FAIL] HTML missing syntax highlighting CSS')
  }
  
  console.log('[FullHTMLTest] Completed')
}
