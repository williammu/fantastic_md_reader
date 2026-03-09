# Agent 协作规则

> 本文档记录与 AI Agent 协作的约定和规则

## 构建工程规则

### 规则 1：构建必须沉淀为脚本

**要求**：任何时候让我构建一个工程，需要沉淀为一个构建脚本。

**原因**：
- 可重复执行，避免手动步骤遗漏
- 方便 CI/CD 集成
- 知识沉淀，下次可直接使用
- 减少环境配置错误

**执行标准**：
1. 创建 `build.ps1` (PowerShell) 作为主要脚本
2. 创建 `build.bat` 作为 Windows 入口
3. 创建 `BUILD.md` 记录使用说明
4. 脚本需包含：环境检查、依赖同步、构建、清理、安装等功能
5. 脚本使用项目自带工具链（如 DevEco Studio 自带的 Java/Node），避免依赖系统环境

---

### 规则 2：做不到时要说明根本原因

**要求**：如果做不到我的要求，需要告诉我为什么，不要只告诉"需要安装 Java"这类表面原因。

**错误示例**：
```
❌ "构建失败，需要安装 Java"
❌ "缺少 Java 环境"
```

**正确示例**：
```
✅ "构建失败，原因分析：
   1. HAP 打包阶段调用 jar 工具时需要 Java 运行时
   2. 签名阶段需要 Java 的 keytool/apksigner
   3. 当前系统 PATH 中找不到 java.exe
   4. 解决方案：使用 DevEco Studio 自带的 Java (jbr/bin/java.exe)
   5. 已更新 build.ps1 自动配置 JAVA_HOME"
```

**根本原因分析维度**：
1. **技术原因**：什么步骤失败？依赖什么技术？
2. **环境原因**：为什么当前环境不满足？
3. **配置原因**：哪个配置缺失或错误？
4. **解决方案**：有哪些解决方式？为什么选择某种方式？
5. **预防措施**：如何避免类似问题？

---

## 本次实践记录

### 场景：构建 MD Reader 项目

**问题 1**：构建失败，提示 "spawn java ENOENT"

**表面原因**：缺少 Java

**根本原因**：
- HAP 打包流程：`CompileArkTS` → `PackageHap` → `SignHap`
- `PackageHap` 使用 Java 的 `jar` 命令创建 ZIP 归档
- `SignHap` 使用 Java 的 `keytool` 和 `apksigner` 进行签名
- 系统 PATH 中没有 java.exe，且 `$JAVA_HOME` 未设置
- hvigor daemon 启动时未继承正确的 Java 环境

**解决方案**：
1. 发现 DevEco Studio 自带 Java (jbr/bin/java.exe, OpenJDK 21)
2. 在 build.ps1 中设置 `$env:JAVA_HOME = "$DevEcoHome\jbr"`
3. 将 Java bin 目录加入 PATH
4. 同时发现系统 Node.js v24 与 hvigor 不兼容，一并使用 DevEco 自带 Node v18

**沉淀产物**：
- `build.ps1` - 完整构建脚本
- `build.bat` - Windows 入口
- `BUILD.md` - 构建文档

---

### 规则 3：每次修改后自动构建并安装

**要求**：每次代码修改完成后，需要自动执行构建并安装到设备，方便用户立即验证修改效果。

**执行标准**：
1. 修改完成后立即执行 `build.ps1 hap` 进行构建
2. 构建成功后执行 `build.ps1 install` 安装到设备
3. 安装成功后启动应用
4. 向用户报告构建和安装结果

**禁止行为**：
- ❌ 只修改代码不构建
- ❌ 只构建不安装
- ❌ 只安装不启动

**正确示例**：
```
✅ "已修复 xxx 问题，正在构建并安装..."
✅ "构建成功，应用已安装并启动，请验证"
```

---

### 规则 4：日志排查与远程日志获取

**要求**：当需要排查问题时，需要能够方便地获取应用日志。由于 HarmonyOS 沙盒限制，无法直接通过 HDC 访问应用内部文件，需要使用 Socket 方式远程获取日志。

**问题背景**：
1. HarmonyOS 应用沙盒目录无法通过 HDC 直接访问
2. logcat 命令在某些设备上不可用
3. 需要在应用内实现日志服务，通过网络端口暴露日志

**解决方案**：
1. 在应用内实现 `LogSocketService`（TCP Socket 服务器）
2. 监听固定端口（8080），接受客户端连接
3. 客户端连接时，自动读取并返回日志文件内容
4. 开发 PC 端使用 PowerShell 脚本通过端口转发获取日志

---

### 场景：MD Reader 日志排查实践

#### 问题现象
应用显示"未找到 Markdown 文件"，但通过日志 Socket 发现沙盒中确实有文件。

#### 根本原因分析
1. `FileService` 和 `LogSocketService` 使用相对路径 `files/shared/`
2. HarmonyOS 应用需要使用 `context.filesDir` 获取正确的沙盒目录
3. 相对路径无法访问到正确的沙盒目录

#### 解决方案
1. 在 `EntryAbility` 中获取 `context.filesDir` 并保存
2. 使用 `SharedFileStorage` 类存储沙盒目录路径
3. 所有文件操作使用正确的沙盒目录路径

#### 沉淀产物
- `entry/src/main/ets/services/LogSocketService.ets` - Socket 日志服务
- `entry/src/main/ets/services/FileService.ets` - 文件服务（已修复路径问题）
- `entry/src/main/ets/entryability/EntryAbility.ets` - 添加了沙盒路径存储
- `get_logs_via_socket.ps1` - PowerShell 日志获取脚本
- `./logs/socket_logs_*.log` - 日志文件存储目录

---

### 使用说明

#### 1. 启动应用
应用启动时会自动启动 Socket 日志服务，监听 8080 端口。

#### 2. 获取日志
在开发 PC 上运行：
```powershell
.\get_logs_via_socket.ps1
```

脚本会自动：
1. 使用 HDC 设置端口转发（`hdc fport tcp:8080 tcp:8080`）
2. 通过 TCP 连接到应用的 8080 端口
3. 获取日志内容并保存到 `./logs/socket_logs_*.log`
4. 显示日志内容
5. 清理端口转发

#### 3. 查看日志文件
日志文件保存在 `./logs/` 目录下，文件名格式为 `socket_logs_YYYYMMDD_HHmmss.log`。

#### 4. 日志内容
日志包含：
- 应用日志（`app.log`）
- 系统日志（Socket 服务状态）
- 沙盒文件列表

---

### 技术实现细节

#### LogSocketService.ets
- 使用 `socket.constructTCPSocketServerInstance()` 创建 TCP 服务器
- 监听 `connect` 事件处理客户端连接
- 使用 `fileIo` 模块读写日志文件
- 通过 `SharedFileStorage` 获取正确的沙盒目录路径

#### get_logs_via_socket.ps1
- 使用 `hdc fport` 设置端口转发
- 使用 `.NET` 的 `TcpClient` 连接 Socket
- 使用 `StreamReader` 读取响应内容
- 自动保存日志到文件并显示

---

## 规则应用检查清单

- [ ] 是否创建了可重复执行的构建脚本？
- [ ] 脚本是否处理了环境配置？
- [ ] 脚本是否使用项目自带工具链而非系统环境？
- [ ] 失败时是否分析了技术根因？
- [ ] 失败时是否说明了环境/配置问题？
- [ ] 失败时是否提供了多种解决方案？
- [ ] 是否沉淀了文档说明？
- [ ] 是否创建了日志获取脚本？
- [ ] 是否解决了沙盒文件访问问题？

---

*记录时间：2026-03-09*
*记录位置：项目根目录 AGENTS.md*
