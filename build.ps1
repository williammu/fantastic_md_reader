#!/usr/bin/env powershell
# MD Reader 构建脚本
# 用法: .\build.ps1 [target]
#   target: hap (默认) | clean | install | debug

param(
    [Parameter(Position=0)]
    [ValidateSet("hap", "clean", "install", "debug", "stop")]
    [string]$Target = "hap"
)

# 配置
$DevEcoHome = "E:\dev\DevEco Studio"
$ProjectRoot = $PSScriptRoot
$HvigorPath = "$DevEcoHome\tools\hvigor\bin\hvigorw.bat"
$OhpmPath = "$DevEcoHome\tools\ohpm\bin\ohpm.bat"
$HdcPath = "$DevEcoHome\sdk\default\openharmony\toolchains\hdc.exe"
$JavaHome = "$DevEcoHome\jbr"              # DevEco Studio 自带的 Java
$NodeHome = "$DevEcoHome\tools\node"       # DevEco Studio 自带的 Node.js

# 设置环境变量（使用 DevEco Studio 内置的工具，避免版本不兼容）
$env:DEVECO_SDK_HOME = $DevEcoHome
$env:JAVA_HOME = $JavaHome
$env:NODE_HOME = $NodeHome
# 将 DevEco 工具路径放在 PATH 最前面，优先使用
$env:PATH = "$NodeHome;$JavaHome\bin;$env:PATH"

# 颜色定义
$Red = "`e[91m"
$Green = "`e[92m"
$Yellow = "`e[93m"
$Blue = "`e[94m"
$Reset = "`e[0m"

function Write-Info($msg) { Write-Host "$Blue[INFO]$Reset $msg" }
function Write-Success($msg) { Write-Host "$Green[SUCCESS]$Reset $msg" }
function Write-Warning($msg) { Write-Host "$Yellow[WARN]$Reset $msg" }
function Write-Error($msg) { Write-Host "$Red[ERROR]$Reset $msg" }

# 检查工具
function Check-Tools {
    if (-not (Test-Path $HvigorPath)) {
        Write-Error "hvigorw not found at: $HvigorPath"
        exit 1
    }
    if (-not (Test-Path $OhpmPath)) {
        Write-Error "ohpm not found at: $OhpmPath"
        exit 1
    }
    Write-Success "Tools check passed"
}

# Sync 依赖
function Sync-Dependencies {
    Write-Info "Syncing dependencies..."
    & $OhpmPath install 2>&1 | ForEach-Object {
        if ($_ -match "ERROR") { Write-Error $_ }
        elseif ($_ -match "WARN") { Write-Warning $_ }
        else { Write-Host $_ }
    }
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Dependencies synced"
    } else {
        Write-Warning "Sync completed with warnings"
    }
}

# 构建 HAP
function Build-Hap {
    Write-Info "Building HAP..."
    Write-Info "Target: entry@default"
    
    Push-Location $ProjectRoot
    & $HvigorPath assembleHap --mode module -p entry@default 2>&1 | ForEach-Object {
        if ($_ -match "ERROR") { Write-Error $_ }
        elseif ($_ -match "WARN") { Write-Warning $_ }
        elseif ($_ -match "Finished.*CompileArkTS") { Write-Success "ArkTS compilation completed" }
        elseif ($_ -match "BUILD FAILED") { Write-Error $_ }
        elseif ($_ -match "BUILD SUCCESSFUL") { Write-Success $_ }
        else { Write-Host $_ }
    }
    $exitCode = $LASTEXITCODE
    Pop-Location
    
    if ($exitCode -eq 0) {
        Write-Success "Build successful!"
        
        # 查找生成的 HAP 文件
        $hapFiles = Get-ChildItem -Path "$ProjectRoot\entry\build\default\outputs\default" -Filter "*.hap" -ErrorAction SilentlyContinue
        if ($hapFiles) {
            Write-Info "Generated HAP files:"
            $hapFiles | ForEach-Object { Write-Host "  - $($_.FullName) ($([math]::Round($_.Length/1KB, 2)) KB)" }
        }
    } else {
        Write-Error "Build failed!"
        exit 1
    }
}

# 清理构建
function Clean-Build {
    Write-Info "Cleaning build..."
    Push-Location $ProjectRoot
    & $HvigorPath clean 2>&1 | ForEach-Object { Write-Host $_ }
    Pop-Location
    
    # 删除构建目录
    $buildDirs = @(
        "$ProjectRoot\entry\build",
        "$ProjectRoot\.hvigor\outputs"
    )
    foreach ($dir in $buildDirs) {
        if (Test-Path $dir) {
            Remove-Item -Path $dir -Recurse -Force
            Write-Info "Removed: $dir"
        }
    }
    Write-Success "Clean completed"
}

# 安装到设备
function Install-Hap {
    Write-Info "Installing HAP to device..."
    
    if (-not (Test-Path $HdcPath)) {
        Write-Error "hdc not found at: $HdcPath"
        exit 1
    }
    
    # 查找 HAP 文件（优先使用 signed）
    $hapFile = Get-ChildItem -Path "$ProjectRoot\entry\build\default\outputs\default" -Filter "*signed.hap" | Select-Object -First 1
    if (-not $hapFile) {
        $hapFile = Get-ChildItem -Path "$ProjectRoot\entry\build\default\outputs\default" -Filter "*.hap" | Select-Object -First 1
    }
    if (-not $hapFile) {
        Write-Error "No HAP file found. Please build first."
        exit 1
    }
    
    # 检查设备
    Write-Info "Checking device..."
    $devices = & $HdcPath list targets 2>&1
    if ($devices -match "Empty|error") {
        Write-Error "No device connected"
        exit 1
    }
    Write-Host $devices
    
    # 先推送到设备临时目录，再安装
    $remotePath = "/data/local/tmp/$($hapFile.Name)"
    Write-Info "Pushing to device: $remotePath"
    & $HdcPath file send $hapFile.FullName $remotePath 2>&1 | ForEach-Object {
        if ($_ -match "error|fail") { Write-Error $_ }
        else { Write-Host $_ }
    }
    
    # 安装
    Write-Info "Installing: $($hapFile.Name)"
    & $HdcPath shell bm install -p $remotePath 2>&1 | ForEach-Object {
        if ($_ -match "fail|error") { Write-Error $_ }
        else { Write-Host $_ }
    }
    
    # 清理临时文件
    & $HdcPath shell rm -f $remotePath 2>&1 | Out-Null
    
    Write-Success "Install completed"
    
    # 启动应用
    Write-Info "Starting application..."
    & $HdcPath shell aa start -a EntryAbility -b com.ms.md_reader 2>&1 | ForEach-Object {
        if ($_ -match "fail|error") { Write-Error $_ }
        else { Write-Host $_ }
    }
}

# 调试构建
function Build-Debug {
    Write-Info "Building with debug info..."
    Push-Location $ProjectRoot
    & $HvigorPath assembleHap --mode module -p entry@default --stacktrace --debug 2>&1 | ForEach-Object { Write-Host $_ }
    Pop-Location
}

# 停止 Daemon
function Stop-Daemon {
    Write-Info "Stopping hvigor daemon..."
    & $HvigorPath --stop-daemon 2>&1 | ForEach-Object { Write-Host $_ }
    Write-Success "Daemon stopped"
}

# 主逻辑
Write-Host ""
Write-Host "========================================"
Write-Host "  MD Reader Build Script"
Write-Host "========================================"
Write-Host ""

Check-Tools

switch ($Target) {
    "hap" { 
        Sync-Dependencies
        Build-Hap 
    }
    "clean" { 
        Clean-Build 
    }
    "install" { 
        Install-Hap 
    }
    "debug" { 
        Sync-Dependencies
        Build-Debug 
    }
    "stop" { 
        Stop-Daemon 
    }
    default { 
        Write-Error "Unknown target: $Target"
        exit 1
    }
}

Write-Host ""
Write-Host "========================================"
Write-Success "Done!"
Write-Host "========================================"
