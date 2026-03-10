# MD 阅读器测试方式文档

## 核心思想
**自动化生成 + 手动检查**：通过应用自动渲染测试文档，生成HTML输出，然后通过检查HTML结构和样式来验证功能正确性。

---

## 完整工作流程

### 1. 测试文档准备
- **test_case.md**：包含50+个测试项的测试检查清单
- **complete_test.md**：包含完整Markdown语法的测试文档，用于实际渲染

### 2. 应用自动打开文档
修改 `Index.ets`，让应用启动后1秒自动打开 `complete_test.md`：
```typescript
setTimeout(() => {
  this.openRawFile('complete_test.md')
}, 1000)
```

### 3. HTML 生成与输出
- `HTMLGenerator.ets` 解析 Markdown 并生成 HTML
- 同时将 HTML 保存到应用沙盒中的 `/data/storage/el2/base/haps/entry/files/shared/debug_output.html`

### 4. Socket 通信获取 HTML
- `LogSocketService.ets` 在 8080 端口监听 TCP 连接
- 连接建立后发送 `debug_output.html` 的原始二进制数据

### 5. 本地 Python 脚本获取
`get_html.py` 连接到本地端口 8080，接收并保存 HTML：
```python
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect(('localhost', 8080))
with open('debug_output.html', 'wb') as f:
    f.write(data)
```

### 6. 端口转发（hdc fport）
将设备端口映射到本地端口：
```bash
hdc fport tcp:8080 tcp:8080
```

---

## 检查内容
通过 `debug_output.html` 检查：
1. **基础文本**：粗体、斜体、删除线、转义字符
2. **标题**：H1-H6、替代语法、锚点
3. **代码块**：语法高亮（TypeScript/JS/Java/Python/C/C++/Swift/Kotlin/Go）
4. **列表**：有序/无序/任务列表、嵌套
5. **引用块**：普通/嵌套、引用内的列表/粗体/代码块
6. **表格**：对齐、样式
7. **链接与图片**：锚点跳转、自动链接
8. **混合内容**：各种元素组合

---

## 优点
- 无需在设备上逐页翻查，通过 HTML 文件直接检查
- 支持完整的样式和结构验证
- 可以反复运行，快速验证修复
- 自动化流程，减少手动操作

---

## 测试执行命令

### 构建和安装
```bash
hvigorw clean assembleHap --no-daemon
hdc install entry/build/default/outputs/default/entry-default-signed.hap
```

### 启动应用
```bash
hdc shell aa start -a EntryAbility -b com.ms.md_reader
```

### 获取 HTML
```bash
hdc fport tcp:8080 tcp:8080
python3 get_html.py
```

---

## 快速开始
1. 确保所有代码修改完成
2. 运行构建和安装命令
3. 启动应用
4. 运行 `python3 get_html.py` 获取 HTML
5. 检查 `debug_output.html` 验证功能正确性
