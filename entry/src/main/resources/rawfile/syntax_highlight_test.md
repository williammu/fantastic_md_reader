# 语法高亮全面测试

本文档涵盖所有支持语言的语法高亮测试，重点测试关键字识别。

---

## TypeScript / JavaScript

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

declare module "test" {
  global {
    namespace MyNamespace {
      enum MyEnum {
        A = 1,
        B = 2
      }
    }
  }
}

function* generator(): Generator<number> {
  yield 1;
  yield* [2, 3];
}

abstract class AbstractClass {
  abstract method(): void;
}

// Control flow
if (true) {} else if (false) {} else {}
for (let i = 0; i < 10; i++) {}
while (false) {}
do {} while (false);
for (const item of []) {}
for (const key in {}) {}
switch (0) { case 0: break; default: break; }

// Operators and types
typeof x;
instanceof MyClass;
keyof MyInterface;
in "prop";
unique symbol;
infer T;

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

// Conditional types
type T = U extends V ? X : Y;
```

---

## Java

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
    
    // Native and strictfp
    public native void nativeMethod();
    public strictfp void strictfpMethod() {}
    
    // Synchronized
    public synchronized void syncMethod() {}
    
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
        
        // Assert
        assert x > 0 : "Assertion failed";
        
        // Instanceof
        Object obj = null;
        if (obj instanceof String) {
            String str = (String) obj;
        }
    }
    
    // New
    public void create() {
        Object o = new Object();
        int[] arr = new int[10];
    }
    
    // Interface
    public interface InnerInterface {
        void abstractMethod();
        default void defaultMethod() {}
        static void staticMethod() {}
    }
    
    // Enum
    public enum Status {
        ACTIVE, INACTIVE, PENDING
    }
    
    // Annotation
    @Override
    @Deprecated
    @SuppressWarnings("unchecked")
    public void annotatedMethod() {}
    
    // Record (Java 14+)
    public record Point(int x, int y) {}
    
    // Var (Java 10+)
    public void varTest() {
        var list = new ArrayList<String>();
    }
}

// Abstract class
abstract class AbstractClass {
    abstract void abstractMethod();
}

// Final class
final class FinalClass {}

// Strictfp class
strictfp class StrictfpClass {
    strictfp void method() {}
}

// Module (Java 9+)
/*
module com.example {
    requires java.base;
    exports com.example.api;
    opens com.example.internal;
    provides Service with ServiceImpl;
    uses Service;
}
*/

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

---

## Python

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
    
    @property
    def prop(self) -> int:
        return self._prop
    
    @prop.setter
    def prop(self, value: int) -> None:
        self._prop = value

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
    else:
        pass  # Executed if no break
    
    # While loop
    while False:
        break
        continue
    else:
        pass
    
    # Try-except-finally
    try:
        raise Exception()
    except ValueError as e:
        pass
    except TypeError:
        pass
    except Exception:
        pass
    else:
        pass  # Executed if no exception
    finally:
        pass
    
    # With statement
    with open("file") as f:
        pass
    
    # Match statement (Python 3.10+)
    match x:
        case True:
            pass
        case False:
            pass
        case _:
            pass

# Generator
def generator():
    yield 1
    yield from [2, 3, 4]
    return  # In generator, signals StopIteration with value

# Async generator
async def async_generator():
    async for item in async_iter():
        yield item

# Context manager
class ContextManager:
    def __enter__(self):
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        return False

# Global and nonlocal
global_var = 0

def outer():
    x = 0
    def inner():
        nonlocal x
        x = 1
    inner()

def global_test():
    global global_var
    global_var = 1

# Type aliases
def type_test():
    x: int = 0
    y: str = ""
    z: float = 0.0
    b: bool = True
    n: None = None
    lst: List[int] = []
    dct: Dict[str, int] = {}
    opt: Optional[int] = None
    uni: Union[int, str] = 0

# Del
def del_test():
    x = 0
    del x

# Assert
def assert_test():
    assert True, "Message"

# Literals
True
False
None
"string"
'string'
f"f-string"
r"raw string"
b"bytes"
0
0.0
0j
0xFF
0o777
0b1010
1_000_000

# Built-in functions (not keywords but commonly highlighted)
print()
input()
len()
range()
enumerate()
zip()
map()
filter()
sum()
min()
max()
abs()
round()
pow()
divmod()
all()
any()
hasattr()
getattr()
setattr()
delattr()
isinstance()
issubclass()
type()
repr()
str()
int()
float()
bool()
list()
tuple()
dict()
set()
frozenset()
```

---

## C / C++

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

#ifndef VERSION
    #define VERSION "1.0"
#endif

#if defined(__GNUC__)
    #define COMPILER "GCC"
#elif defined(__clang__)
    #define COMPILER "Clang"
#else
    #define COMPILER "Unknown"
#endif

#ifdef __cplusplus
extern "C" {
#endif

// Typedef and struct
typedef struct {
    int x;
    int y;
} Point;

typedef struct Node {
    int data;
    struct Node* next;
} Node;

// Enum
typedef enum {
    RED,
    GREEN,
    BLUE
} Color;

// Union
typedef union {
    int i;
    float f;
    char c[4];
} Data;

// Function declarations
void void_function(void);
int int_function(int a, int b);
char* string_function(const char* str);
static void static_function(void);
extern void extern_function(void);
inline void inline_function(void);

// Main function
int main(int argc, char* argv[]) {
    // Basic types
    char c = 'a';
    short s = 0;
    int i = 0;
    long l = 0L;
    long long ll = 0LL;
    unsigned int ui = 0U;
    unsigned long ul = 0UL;
    float f = 0.0f;
    double d = 0.0;
    long double ld = 0.0L;
    
    // Fixed-width types
    int8_t i8 = 0;
    int16_t i16 = 0;
    int32_t i32 = 0;
    int64_t i64 = 0;
    uint8_t u8 = 0;
    uint16_t u16 = 0;
    uint32_t u32 = 0;
    uint64_t u64 = 0;
    size_t sz = 0;
    ptrdiff_t diff = 0;
    
    // Pointers
    int* ptr = NULL;
    const int* const_ptr = &i;
    volatile int vol_var = 0;
    restrict int* restrict_ptr = &i;
    
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
        case 2:
            break;
        default:
            break;
    }
    
    goto end;
    
end:
    // Nothing
    
    // Memory
    int* arr = (int*)malloc(sizeof(int) * 10);
    if (arr != NULL) {
        memset(arr, 0, sizeof(int) * 10);
        free(arr);
    }
    
    // Return
    return 0;
}

// Function definitions
void void_function(void) {
    return;
}

int int_function(int a, int b) {
    return a + b;
}

static void static_function(void) {
    static int count = 0;
    count++;
}

// Complex type declarations
int (*function_pointer)(int, int);
int* array_of_pointers[10];
int (*pointer_to_array)[10];
int (*(*complex_declaration)(int))[10];

// C++ additions (when compiled as C++)
#ifdef __cplusplus

// C++ class
class MyClass : public BaseClass {
public:
    MyClass() : value(0) {}
    ~MyClass() {}
    
    void public_method();
    
protected:
    void protected_method();
    
private:
    int value;
    void private_method();
    
    friend class FriendClass;
    friend void friend_function();
};

// Access specifiers
public:
protected:
private:

// Virtual and override
class Derived : public Base {
public:
    virtual void virtual_method() override;
    virtual void pure_virtual() = 0;
    void final_method() final;
};

// Templates
template<typename T>
class TemplateClass {
public:
    T value;
    TemplateClass(T v) : value(v) {}
};

template<typename T, typename U>
void template_function(T a, U b) {
    auto result = a + b;
    decltype(a) another = a;
}

// Namespaces
namespace MyNamespace {
    int ns_var = 0;
    void ns_function() {}
}

namespace {
    int anonymous_var = 0;
}

// Using declarations
using namespace std;
using MyType = int;

// New and delete
void memory_test() {
    int* p = new int;
    delete p;
    
    int* arr = new int[10];
    delete[] arr;
    
    // Placement new
    char buffer[sizeof(int)];
    int* placed = new (buffer) int;
}

// Exception handling
void exception_test() {
    try {
        throw std::exception();
    } catch (const std::exception& e) {
        // handle
    } catch (...) {
        // catch all
    }
    
    noexcept(true);
}

// Static assertions
static_assert(sizeof(int) == 4, "Int must be 4 bytes");

// Thread local
thread_local int tls_var = 0;

// Alignas and alignof
alignas(64) char aligned_buffer[64];
constexpr size_t alignment = alignof(int);

// Constexpr
constexpr int factorial(int n) {
    return n <= 1 ? 1 : n * factorial(n - 1);
}

// Lambda (C++11)
auto lambda = [](int x) -> int { return x * 2; };
auto capture_lambda = [x, &y](int a) { return a + x; };
auto generic_lambda = [](auto x) { return x; };

#endif // __cplusplus

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
nullptr; // C++11
NULL;
0xFF;
0b1010; // C++14
0o777; // Not standard C
```

---

## JSON

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
  "special_chars": "Quotes: \" \ Backslash: \\ ",
  "empty_string": "",
  "zero": 0,
  "negative_zero": -0,
  "large_number": 9007199254740991,
  "deeply": {
    "nested": {
      "structure": {
        "with": {
          "many": {
            "levels": {
              "test": "value"
            }
          }
        }
      }
    }
  }
}
```

---

## Go

```go
// Go Keywords Test
package main

import (
	"fmt"
	"os"
	_ "unsafe" // Blank import
	. "math"   // Dot import
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

// Function types
type BinaryOp func(int, int) int
type Predicate func(int) bool

// Channel types
type IntChan chan int
type SendChan chan<- int
type RecvChan <-chan int

// Map types
type StringMap map[string]string
type IntSlice []int

// Array types
type FixedArray [10]int

// Pointer receiver
func (p *Person) Birthday() {
	p.Age++
}

// Value receiver
func (p Person) IsAdult() bool {
	return p.Age >= 18
}

// Generic function (Go 1.18+)
func Min[T comparable](a, b T) T {
	if a < b {
		return a
	}
	return b
}

// Generic type
type Stack[T any] struct {
	items []T
}

func (s *Stack[T]) Push(item T) {
	s.items = append(s.items, item)
}

func (s *Stack[T]) Pop() T {
	var zero T
	if len(s.items) == 0 {
		return zero
	}
	item := s.items[len(s.items)-1]
	s.items = s.items[:len(s.items)-1]
	return item
}

// Main function
func main() {
	// Variables
	var a int
	var b string = "hello"
	var c, d = 1, 2
	
	e := 42           // Short variable declaration
	f := "short decl" // Type inference
	
	// Multiple variables
	x, y, z := 1, 2, 3
	_, _, _ = x, y, z // Use blank identifier
	
	// Constants
	const localConst = 100
	
	// Type conversion
	i := int(3.14)
	_ = i
	
	// Control flow
	if a > 0 {
		fmt.Println("Positive")
	} else if a < 0 {
		fmt.Println("Negative")
	} else {
		fmt.Println("Zero")
	}
	
	// For loop (C-style)
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
	
	// For-range over slice
	arr := []int{1, 2, 3}
	for index, value := range arr {
		_, _ = index, value
	}
	
	// For-range over map
	m := map[string]int{"a": 1, "b": 2}
	for key, value := range m {
		_, _ = key, value
	}
	
	// For-range over string
	for pos, char := range "hello" {
		_, _ = pos, char
	}
	
	// For-range over channel
	ch := make(chan int)
	go func() {
		ch <- 1
		close(ch)
	}()
	for v := range ch {
		_ = v
	}
	
	// Switch
	switch a {
	case 0:
		fmt.Println("Zero")
	case 1, 2, 3:
		fmt.Println("Small")
	case 10:
		fallthrough
	case 11:
		fmt.Println("Ten or Eleven")
	default:
		fmt.Println("Other")
	}
	
	// Switch with no condition
	switch {
	case a > 0:
		fmt.Println("Positive")
	case a < 0:
		fmt.Println("Negative")
	default:
		fmt.Println("Zero")
	}
	
	// Type switch
	var empty interface{} = 42
	switch v := empty.(type) {
	case int:
		_ = v
	case string:
		_ = v
	default:
		_ = v
	}
	
	// Select
	ch1 := make(chan int)
	ch2 := make(chan string)
	go func() {
		ch1 <- 1
	}()
	go func() {
		ch2 <- "hello"
	}()
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
	
	// Panic and recover
	func() {
		defer func() {
			if r := recover(); r != nil {
				fmt.Println("Recovered:", r)
			}
		}()
		panic("Something went wrong")
	}()
	
	// Goto
	goto skip
	fmt.Println("This won't print")
skip:
	fmt.Println("Skipped")
	
	// Return
	return
}

// Function with named return values
func split(sum int) (x, y int) {
	x = sum * 4 / 9
	y = sum - x
	return // naked return
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

// Higher-order function
func apply(f func(int) int, x int) int {
	return f(x)
}

// Closure
func makeMultiplier(factor int) func(int) int {
	return func(x int) int {
		return x * factor
	}
}

// Method with pointer receiver
func (p *Person) SetName(name string) {
	p.Name = name
}

// Make and new
func makeNewTest() {
	// Make for slices, maps, channels
	s := make([]int, 0, 10)
	m := make(map[string]int)
	c := make(chan int, 10)
	
	// New for pointers
	p := new(int)
	person := new(Person)
	
	_, _, _, _, _ = s, m, c, p, person
}

// Copy and append
func sliceOps() {
	s := []int{1, 2, 3}
	s = append(s, 4, 5, 6)
	
	dst := make([]int, len(s))
	copy(dst, s)
}

// Delete from map
func mapOps() {
	m := map[string]int{"a": 1, "b": 2}
	delete(m, "a")
	v, ok := m["b"] // Comma ok idiom
	_, _ = v, ok
}

// Len and cap
func lenCap() {
	s := []int{1, 2, 3}
	_ = len(s)
	_ = cap(s)
	
	arr := [10]int{}
	_ = len(arr)
	
	str := "hello"
	_ = len(str)
	
	m := map[string]int{"a": 1}
	_ = len(m)
}

// Complex numbers
func complexOps() {
	c1 := complex(1, 2)
	c2 := 1 + 2i
	
	_ = real(c1)
	_ = imag(c1)
	_, _ = c1, c2
}

// Unsafe operations
import "unsafe"

func unsafeOps() {
	i := 10
	ptr := unsafe.Pointer(&i)
	size := unsafe.Sizeof(i)
	offset := unsafe.Offsetof(struct{ x, y int }{}.y)
	align := unsafe.Alignof(i)
	
	_, _, _, _ = ptr, size, offset, align
}

// Build constraints
//go:build linux && amd64
// +build linux amd64

//go:generate go run gen.go
```

---

## Swift

```swift
// Swift Keywords Test
import Foundation
import UIKit

// MARK: - Declarations

// Variables and constants
var variable: Int = 0
let constant: String = "constant"

// Type aliases
typealias MyInt = Int
typealias StringDict = [String: String]

// Associated type (in protocol)
protocol Container {
    associatedtype Item
    mutating func append(_ item: Item)
    var count: Int { get }
    subscript(i: Int) -> Item { get }
}

// MARK: - Functions

// Function declaration
func functionName() {}
func functionWithParams(param: Int) {}
func functionWithReturn() -> Int { return 0 }
func functionWithThrows() throws {}
func functionWithRethrows(_ f: () throws -> Void) rethrows {}
func functionWithAsync() async {}
func functionWithAwait() async {
    await Task.sleep(1_000_000_000)
}

// Function with defer
deferTest()

func deferTest() {
    defer { print("Deferred 1") }
    defer { print("Deferred 2") }
    print("Normal execution")
}

// MARK: - Types

// Class
open class OpenClass {}
public class PublicClass {}
internal class InternalClass {}
fileprivate class FilePrivateClass {}
private class PrivateClass {}

// Final class
final class FinalClass {}

// Abstract-like class (using unavailable)
class AbstractClass {
    func mustOverride() -> String {
        fatalError("Must override")
    }
}

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
    
    var readOnlyComputed: Int {
        return storedProperty * 2
    }
    
    lazy var lazyProperty: String = {
        return "Lazy"
    }()
    
    // Property wrapper
    @Clamped(range: 0...100)
    var percentage: Int = 50
    
    // Method
    mutating func mutate() {
        storedProperty += 1
    }
    
    static func staticMethod() {}
}

// Property wrapper definition
@propertyWrapper
struct Clamped {
    var value: Int
    let range: ClosedRange<Int>
    
    var wrappedValue: Int {
        get { value }
        set { value = min(max(newValue, range.lowerBound), range.upperBound) }
    }
    
    init(wrappedValue: Int, range: ClosedRange<Int>) {
        self.range = range
        self.value = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }
}

// Enum
enum Direction {
    case north
    case south
    case east
    case west
}

enum Compass: String, CaseIterable {
    case north = "N"
    case south = "S"
    case east = "E"
    case west = "W"
}

// Enum with associated values
enum Result<T, E: Error> {
    case success(T)
    case failure(E)
}

// Indirect enum (recursive)
indirect enum Expression {
    case number(Int)
    case addition(Expression, Expression)
    case multiplication(Expression, Expression)
}

// Protocol
protocol Greetable {
    func greet() -> String
}

protocol Printable: CustomStringConvertible {
    func print()
}

// Protocol extension
extension Greetable {
    func greet() -> String {
        return "Hello"
    }
}

// MARK: - Control Flow

func controlFlow() {
    // If-else
    let x = 10
    if x > 0 {
        print("Positive")
    } else if x < 0 {
        print("Negative")
    } else {
        print("Zero")
    }
    
    // Guard
    guard x > 0 else {
        print("Not positive")
        return
    }
    
    // Switch
    switch x {
    case 0:
        print("Zero")
    case 1...9:
        print("Single digit")
    case 10, 20, 30:
        print("Multiple of 10")
    case let n where n > 100:
        print("Large: \(n)")
    default:
        print("Other")
    }
    
    // For-in
    for i in 0..<10 {
        if i == 5 {
            continue
        }
        if i == 8 {
            break
        }
        print(i)
    }
    
    // For-in with where
    for i in 0...100 where i % 2 == 0 {
        _ = i
    }
    
    // While
    var count = 0
    while count < 5 {
        count += 1
    }
    
    // Repeat-while
    repeat {
        count -= 1
    } while count > 0
    
    // ForEach
    [1, 2, 3].forEach { item in
        print(item)
    }
}

// MARK: - Error Handling

enum MyError: Error {
    case invalidInput
    case notFound
    case unknown
}

func throwingFunction() throws {
    throw MyError.invalidInput
}

func errorHandling() {
    do {
        try throwingFunction()
    } catch MyError.invalidInput {
        print("Invalid input")
    } catch MyError.notFound {
        print("Not found")
    } catch {
        print("Unknown error: \(error)")
    }
    
    // Try variants
    let result = try? throwingFunction()
    let forced = try! throwingFunction() // Dangerous!
}

// MARK: - Closures

func closures() {
    // Basic closure
    let simpleClosure = { () -> Void in
        print("Hello")
    }
    
    // Closure with parameters
    let addClosure = { (a: Int, b: Int) -> Int in
        return a + b
    }
    
    // Trailing closure
    [1, 2, 3].map { $0 * 2 }
    
    // Autoclosure
    func assert(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String) {
        if !condition() {
            print(message())
        }
    }
    
    // Escaping closure
    var handlers: [() -> Void] = []
    func register(handler: @escaping () -> Void) {
        handlers.append(handler)
    }
    
    // Capturing
    var counter = 0
    let incrementer = { [counter] in
        // counter captured by value
        print(counter)
    }
    
    _ = simpleClosure
    _ = addClosure
}

// MARK: - Generics

// Generic function
func swap<T>(_ a: inout T, _ b: inout T) {
    let temp = a
    a = b
    b = temp
}

// Generic type
struct Stack<Element> {
    private var items: [Element] = []
    
    mutating func push(_ item: Element) {
        items.append(item)
    }
    
    mutating func pop() -> Element? {
        return items.popLast()
    }
}

// Generic with constraints
func findIndex<T: Equatable>(of valueToFind: T, in array: [T]) -> Int? {
    for (index, value) in array.enumerated() {
        if value == valueToFind {
            return index
        }
    }
    return nil
}

// MARK: - Access Control

open var openVar = 0
public var publicVar = 0
internal var internalVar = 0
fileprivate var filePrivateVar = 0
private var privateVar = 0

// MARK: - Memory Management

class Resource {
    init() {
        print("Resource initialized")
    }
    
    deinit {
        print("Resource deinitialized")
    }
}

func memoryManagement() {
    // Strong reference
    var strong: Resource? = Resource()
    
    // Weak reference
    weak var weak = strong
    
    // Unowned reference
    unowned var unowned = strong!
    
    strong = nil
}

// MARK: - Operators

// Custom operator
prefix operator +++
prefix func +++(value: Int) -> Int {
    return value + 3
}

infix operator **: MultiplicationPrecedence
func **(left: Double, right: Double) -> Double {
    return pow(left, right)
}

// MARK: - Attributes

@available(iOS 14, *)
func newFeature() {}

@discardableResult
func calculate() -> Int { return 0 }

@inlinable
func fastFunction() {}

@objc
class ObjectiveCClass: NSObject {
    @objc dynamic var dynamicProperty = 0
}

@frozen
enum FrozenEnum {
    case a, b, c
}

@main
struct MyApp {
    static func main() {
        print("App started")
    }
}

// MARK: - Literals

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
#"raw string"#;
#"raw string with "quotes""#;
'c';
true;
false;
nil;
\u{1F600}; // Emoji

// MARK: - Other

// KeyPath
let nameKeyPath = \Person.name

// Result builder
@resultBuilder
struct StringBuilder {
    static func buildBlock(_ components: String...) -> String {
        return components.joined()
    }
}

// #selector
let selector = #selector(ObjectiveCClass.dynamicProperty)

// #keyPath
let keyPath = #keyPath(ObjectiveCClass.dynamicProperty)

// #file, #function, #line, #column
func debugInfo() {
    print(#file)
    print(#function)
    print(#line)
    print(#column)
}

// #available
if #available(iOS 14, macOS 11, *) {
    print("Available")
}

// @unchecked Sendable
struct SendableStruct: @unchecked Sendable {}
```

---

## Kotlin

```kotlin
// Kotlin Keywords Test

// Package and imports
package com.example.test

import kotlin.math.*
import kotlin.collections.*
import kotlin.coroutines.*
import kotlinx.coroutines.*

// Type aliases
typealias IntPredicate = (Int) -> Boolean
typealias UserMap = Map<String, User>

// Constants
const val MAX_COUNT = 100
const val APP_NAME = "Test App"

// Annotation targets
@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
annotation class MyAnnotation(val value: String)

// File-level variables
val globalVal = 0
var globalVar = 0

// lateinit
lateinit var lateInitVar: String

// by lazy
val lazyValue: String by lazy {
    println("Computed!")
    "Hello"
}

// MARK: - Classes and Objects

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

// Sealed class
sealed class Result<out T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error(val exception: Exception) : Result<Nothing>()
    object Loading : Result<Nothing>()
}

// Data class
data class User(
    val id: Long,
    val name: String,
    val email: String = ""
) {
    // Properties declared in body are not in generated methods
    var age: Int = 0
}

// Inline class (value class)
@JvmInline
value class Password(val value: String)

// Enum class
enum class Status {
    PENDING,
    ACTIVE,
    SUSPENDED,
    DELETED;
    
    fun isActive() = this == ACTIVE
}

enum class Color(val rgb: Int) {
    RED(0xFF0000),
    GREEN(0x00FF00),
    BLUE(0x0000FF)
}

// Interface
interface Printable {
    fun print()
    fun printWithPrefix(prefix: String) {
        println("$prefix: ")
        print()
    }
}

interface Serializable {
    fun serialize(): String
}

// Class implementing interfaces
class Document : Printable, Serializable {
    override fun print() {
        println("Printing document")
    }
    
    override fun serialize(): String {
        return "serialized"
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

// Anonymous object
val anonymousObject = object {
    val x = 1
    val y = 2
}

// MARK: - Functions

// Top-level function
fun topLevelFunction() {}

// Function with parameters and return type
fun add(a: Int, b: Int): Int {
    return a + b
}

// Single expression function
fun multiply(a: Int, b: Int) = a * b

// Function with default parameters
fun greet(name: String, greeting: String = "Hello"): String {
    return "$greeting, $name!"
}

// Function with named parameters
fun call() {
    greet(greeting = "Hi", name = "World")
}

// Function with varargs
fun sum(vararg numbers: Int): Int {
    return numbers.sum()
}

// Infix function
infix fun Int.plus(other: Int): Int = this + other

// Usage: 1 plus 2

// Operator function
operator fun Point.plus(other: Point): Point {
    return Point(x + other.x, y + other.y)
}

// Extension function
fun String.addExclamation(): String = this + "!"

// Extension property
val String.wordCount: Int
    get() = split(" ").size

// Generic function
fun <T> singletonList(item: T): List<T> {
    return listOf(item)
}

// Generic function with constraints
fun <T : Comparable<T>> max(a: T, b: T): T {
    return if (a > b) a else b
}

// Multiple constraints
fun <T> copyWhenGreater(list: List<T>, threshold: T): List<String>
        where T : CharSequence,
              T : Comparable<T> {
    return list.filter { it > threshold }.map { it.toString() }
}

// Inline function
inline fun <T> measureTime(block: () -> T): T {
    val start = System.currentTimeMillis()
    return block().also {
        println("Time: ${System.currentTimeMillis() - start}ms")
    }
}

// Inline with reified type
inline fun <reified T> isInstance(value: Any): Boolean {
    return value is T
}

// Noinline
inline fun foo(inlined: () -> Unit, noinline notInlined: () -> Unit) {
    inlined()
    notInlined()
}

// Crossinline
inline fun crossinlineExample(crossinline block: () -> Unit) {
    val f = Runnable { block() }
}

// Suspend function
suspend fun suspendFunction() {
    delay(1000)
}

// Tail recursive
tailrec fun factorial(n: Int, acc: Int = 1): Int {
    return if (n <= 1) acc else factorial(n - 1, n * acc)
}

// MARK: - Properties

// Mutable property
var mutableProperty: Int = 0
    get() = field
    set(value) {
        field = value
    }

// Read-only property
val readOnlyProperty: Int
    get() = 42

// Backing field example
class PropertyDemo {
    var counter = 0
        set(value) {
            if (value >= 0) field = value
        }
}

// MARK: - Control Flow

fun controlFlow() {
    // If as expression
    val max = if (a > b) a else b
    
    // When expression
    val result = when (x) {
        0 -> "zero"
        1, 2, 3 -> "small"
        in 4..10 -> "medium"
        !in 0..100 -> "out of range"
        is String -> "string"
        else -> "other"
    }
    
    // When without argument
    when {
        x < 0 -> println("negative")
        x > 0 -> println("positive")
        else -> println("zero")
    }
    
    // For loop
    for (i in 1..10) {
        println(i)
    }
    
    // For with step
    for (i in 1..10 step 2) {
        println(i)
    }
    
    // For downTo
    for (i in 10 downTo 1) {
        println(i)
    }
    
    // For until
    for (i in 1 until 10) {
        println(i) // 1 to 9
    }
    
    // For over collection
    val list = listOf(1, 2, 3)
    for (item in list) {
        println(item)
    }
    
    // For with index
    for ((index, value) in list.withIndex()) {
        println("$index: $value")
    }
    
    // While
    while (condition) {
        // loop body
    }
    
    // Do-while
    do {
        // loop body
    } while (condition)
    
    // Break and continue
    for (i in 1..10) {
        if (i == 3) continue
        if (i == 7) break
        println(i)
    }
    
    // Labels
    outer@ for (i in 1..10) {
        for (j in 1..10) {
            if (i * j > 50) break@outer
        }
    }
    
    // Return to label
    listOf(1, 2, 3, 4, 5).forEach {
        if (it == 3) return@forEach // local return
        print(it)
    }
    
    // Anonymous function for non-local return
    listOf(1, 2, 3, 4, 5).forEach(fun(value: Int) {
        if (value == 3) return // non-local return
        print(value)
    })
}

// MARK: - Exception Handling

fun exceptionHandling() {
    try {
        riskyOperation()
    } catch (e: SpecificException) {
        // handle specific
    } catch (e: Exception) {
        // handle general
    } finally {
        // always executed
    }
    
    // Try as expression
    val result = try {
        parseInt("123")
    } catch (e: NumberFormatException) {
        null
    }
    
    // Throw
    throw IllegalArgumentException("Invalid argument")
    
    // Nothing type
    fun fail(message: String): Nothing {
        throw IllegalStateException(message)
    }
}

// MARK: - Null Safety

fun nullSafety() {
    var nullable: String? = null
    var nonNull: String = "value"
    
    // Safe call
    val length = nullable?.length
    
    // Elvis operator
    val len = nullable?.length ?: 0
    
    // Non-null assertion
    val forced = nullable!!.length
    
    // Safe cast
    val intOrNull: Int? = value as? Int
    
    // if not null
    nullable?.let {
        // it is not null here
        println(it.length)
    }
    
    // if not null and else
    val value = nullable?.takeIf { it.length > 0 } ?: "default"
}

// MARK: - Smart Casts

fun smartCasts(x: Any) {
    if (x is String) {
        // x automatically cast to String
        println(x.length)
    }
    
    when (x) {
        is Int -> println(x + 1)
        is String -> println(x.length)
        is IntArray -> println(x.sum())
    }
}

// MARK: - Collections

fun collections() {
    // List
    val readOnlyList = listOf(1, 2, 3)
    val mutableList = mutableListOf(1, 2, 3)
    
    // Set
    val readOnlySet = setOf(1, 2, 3)
    val mutableSet = mutableSetOf(1, 2, 3)
    
    // Map
    val readOnlyMap = mapOf("a" to 1, "b" to 2)
    val mutableMap = mutableMapOf("a" to 1, "b" to 2)
    
    // Build collections
    val builtList = buildList {
        add(1)
        add(2)
        addAll(listOf(3, 4))
    }
    
    // Sequences (lazy)
    val sequence = sequenceOf(1, 2, 3)
    val generated = generateSequence(1) { it + 1 }
    
    // Operations
    readOnlyList.filter { it > 1 }
        .map { it * 2 }
        .sortedDescending()
        .take(10)
        .toList()
}

// MARK: - Coroutines

suspend fun coroutines() {
    // Launch
    val job = GlobalScope.launch {
        delay(1000)
        println("Launched")
    }
    
    // Async
    val deferred = GlobalScope.async {
        delay(1000)
        "Result"
    }
    val result = deferred.await()
    
    // WithContext
    withContext(Dispatchers.IO) {
        // IO-bound work
    }
    
    // Flow
    flow {
        for (i in 1..5) {
            delay(100)
            emit(i)
        }
    }.collect { value ->
        println(value)
    }
    
    // Suspend function reference
    val ref: suspend () -> Unit = ::suspendFunction
}

// MARK: - Delegation

// Class delegation
class Derived(b: Base) : Base by b

// Property delegation
var delegated by lazy { "value" }
var observable by Delegates.observable(0) { _, old, new ->
    println("$old -> $new")
}
var vetoable by Delegates.vetoable(0) { _, _, new ->
    new >= 0
}

// MARK: - Destructuring

data class Person(val name: String, val age: Int)

fun destructuring() {
    val person = Person("John", 30)
    val (name, age) = person
    
    for ((key, value) in mapOf("a" to 1)) {
        println("$key: $value")
    }
    
    // Underscore for unused
    val (first, _, third) = listOf(1, 2, 3)
}

// MARK: - Type Checks and Casts

fun typeChecks(obj: Any) {
    // Type check
    if (obj is String) {
        println(obj.length)
    }
    
    // Negated type check
    if (obj !is String) {
        return
    }
    
    // Cast
    val str = obj as String
    
    // Safe cast
    val maybeStr = obj as? String
    
    // Unchecked cast
    @Suppress("UNCHECKED_CAST")
    val list = obj as List<String>
}

// MARK: - Literals

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

// String templates
val name = "World"
val greeting = "Hello, $name!"
val length = "Length: ${name.length}"

// MARK: - Other

// Nothing type
fun neverReturns(): Nothing {
    throw Exception()
}

// Unit type
fun returnsUnit(): Unit {
    println("Returns unit implicitly")
}

// Contracts (experimental)
@OptIn(ExperimentalContracts::class)
fun requireNotEmpty(s: String?) {
    contract {
        returns() implies (s != null)
    }
    if (s.isNullOrEmpty()) throw IllegalArgumentException()
}

// Platform types
// String! - platform type from Java

// SAM conversions
val runnable = Runnable {
    println("Running")
}

// Function literals with receiver
val sum: Int.(Int) -> Int = { other -> plus(other) }

// Usage
// 1.sum(2)

// Invoke operator
class Greeter(val greeting: String) {
    operator fun invoke(name: String) {
        println("$greeting, $name!")
    }
}

// Component functions for destructuring
operator fun Person.component1() = name
operator fun Person.component2() = age

// Range operators
val range = 1..10
val until = 1 until 10
downTo 10 downTo 1
val charRange = 'a'..'z'

// In operator
val inRange = 5 in range
val notInRange = 5 !in range

// This expression
class Outer {
    inner class Inner {
        fun foo() {
            this@Outer // outer this
            this@Inner // inner this
        }
    }
}

// Super
class Child : Parent() {
    override fun foo() {
        super.foo()
        super<Parent>.foo()
    }
}

// Init block
class WithInit(name: String) {
    val firstProperty = "First property: $name".also(::println)
    
    init {
        println("First initializer block")
    }
    
    val secondProperty = "Second property: ${name.length}".also(::println)
    
    init {
        println("Second initializer block")
    }
}
```

---

## 测试说明

### 颜色定义

所有主题使用统一的 CSS 类：

- `token-keyword` - 关键字（紫色/蓝色）
- `token-string` - 字符串（橙色/棕色）
- `token-number` - 数字（绿色）
- `token-function` - 函数名（黄色）
- `token-comment` - 注释（绿色）
- `token-operator` - 运算符（默认文本色）

### 各主题配色

| Token | 浅色主题 | 深色主题 | 护眼主题 |
|-------|----------|----------|----------|
| keyword | #0000FF | #569CD6 | #4A6CD4 |
| string | #A31515 | #CE9178 | #B45309 |
| number | #098658 | #B5CEA8 | #2D6A4F |
| function | #795E26 | #DCDCAA | #7C6F0E |
| comment | #008000 | #6A9955 | #5B8A4E |

---

*文件结束*
