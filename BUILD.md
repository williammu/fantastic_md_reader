# MD Reader 构建指南

## 快速开始

### 方式一：使用批处理脚本（推荐）

```bash
# 构建 HAP
.\build.bat

# 或指定目标
.\build.bat hap      # 构建 HAP（默认）
.\build.bat clean    # 清理构建
.\build.bat install  # 安装到设备
.\build.bat debug    # 调试构建
.\build.bat stop     # 停止 daemon
```

### 方式二：使用 PowerShell 脚本

```powershell
# 构建 HAP
.\build.ps1

# 或指定目标
.\build.ps1 hap      # 构建 HAP（默认）
.\build.ps1 clean    # 清理构建
.\build.ps1 install  # 安装到设备
.\build.ps1 debug    # 调试构建
.\build.ps1 stop     # 停止 daemon
```

## 构建步骤

### 1. 同步依赖

```bash
.\build.bat
```

这会执行：
- `ohpm install` - 安装依赖
- `hvigor assembleHap` - 构建 HAP

### 2. 清理构建

```bash
.\build.bat clean
```

这会：
- 执行 `hvigor clean`
- 删除 `entry/build` 目录
- 删除 `.hvigor/outputs` 目录

### 3. 安装到设备

```bash
.\build.bat install
```

要求：
- 设备已连接
- hdc 工具可用
- 已构建 HAP 文件

### 4. 调试构建

```bash
.\build.bat debug
```

这会显示详细的构建日志，用于排查问题。

## 环境要求

- **DevEco Studio**: 安装路径 `E:\dev\DevEco Studio`
- **Node.js**: 用于运行 hvigor
- **Java**: 用于打包 HAP（如果需要）
- **hdc**: 用于安装到设备

## 模拟器与真机构建

### 模拟器构建（无需签名）

模拟器不需要签名，直接构建即可：

```bash
# 确保 build-profile.json5 中签名配置被注释
.\build.bat hap

# 安装到模拟器
hdc -t 127.0.0.1:5555 install entry\build\default\outputs\default\entry-default-unsigned.hap
```

### 真机构建（需要签名）

真机安装必须有签名，配置方法如下：

#### 方法1：DevEco Studio 自动签名（推荐）

1. 打开 DevEco Studio
2. 连接真机设备
3. 点击 `File` -> `Project Structure` -> `Project` -> `Signing Configs`
4. 勾选 `Automatically generate signature`
5. 点击 `Apply` 和 `OK`
6. 签名文件会自动生成到 `~/.ohos/config/` 目录

#### 方法2：手动配置签名

在 `build-profile.json5` 中配置签名：

```json5
{
  "app": {
    "signingConfigs": [
      {
        "name": "default",
        "type": "HarmonyOS",
        "material": {
          "certpath": "/Users/xxx/.ohos/config/xxx.cer",
          "keyAlias": "debugKey",
          "keyPassword": "xxx",
          "profile": "/Users/xxx/.ohos/config/xxx.p7b",
          "signAlg": "SHA256withECDSA",
          "storeFile": "/Users/xxx/.ohos/config/xxx.p12",
          "storePassword": "xxx"
        }
      }
    ],
    "products": [
      {
        "name": "default",
        "signingConfig": "default",  // 启用签名
        "targetSdkVersion": "6.0.2(22)",
        "compatibleSdkVersion": "6.0.2(22)",
        "runtimeOS": "HarmonyOS"
      }
    ]
  }
}
```

#### 快速切换

| 场景 | signingConfigs | signingConfig |
|------|----------------|---------------|
| 模拟器 | 注释掉 | 注释掉或设为 null |
| 真机 | 配置签名文件 | "default" |

#### 安装到真机

```bash
# 构建签名 HAP
.\build.bat hap

# 安装到真机（替换为实际设备ID）
hdc -t 2SX0224417010945 install entry\build\default\outputs\default\entry-default-signed.hap
```

## 常见问题

### 1. 找不到 DevEco Studio

编辑 `build.ps1`，修改以下行：

```powershell
$DevEcoHome = "你的DevEco Studio安装路径"
```

### 2. 权限错误

以管理员身份运行 PowerShell 或 CMD。

### 3. 构建失败

尝试清理后重新构建：

```bash
.\build.bat clean
.\build.bat
```

### 4. 签名验证失败

错误信息：`Signature material verification failed`

解决方法：
- 在 DevEco Studio 中重新生成签名
- 确保 `build-profile.json5` 中的密码正确
- 真机必须使用签名，模拟器不需要

### 5. 停止 Daemon

如果构建卡住，可以停止 daemon：

```bash
.\build.bat stop
```

## 输出目录

构建成功后，HAP 文件位于：

```
entry\build\default\outputs\default\entry-default-unsigned.hap
```

## 测试语法高亮

构建完成后，可以使用测试文件验证语法高亮：

1. 将 `syntax_highlight_test.md` 复制到设备
2. 在应用中打开该文件
3. 检查各代码块的高亮效果

## 支持的构建目标

| 目标 | 说明 |
|------|------|
| `hap` | 构建 HAP 文件（默认） |
| `clean` | 清理构建产物 |
| `install` | 安装 HAP 到设备 |
| `debug` | 调试模式构建 |
| `stop` | 停止 hvigor daemon |

## 颜色配置

语法高亮颜色定义在 `entry/src/main/ets/models/Theme.ets`：

| Token | 浅色主题 | 深色主题 | 护眼主题 |
|-------|----------|----------|----------|
| `syntaxKeyword` | #0000FF | #569CD6 | #4A6CD4 |
| `syntaxString` | #A31515 | #CE9178 | #B45309 |
| `syntaxNumber` | #098658 | #B5CEA8 | #2D6A4F |
| `syntaxFunction` | #795E26 | #DCDCAA | #7C6F0E |
| `syntaxComment` | #008000 | #6A9955 | #5B8A4E |

## CI/CD 集成

在 CI/CD 环境中使用：

```yaml
# GitLab CI example
build:
  script:
    - powershell -ExecutionPolicy Bypass -File build.ps1 hap
  artifacts:
    paths:
      - entry/build/default/outputs/default/*.hap
```
