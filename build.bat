@echo off
chcp 65001 >nul
title MD Reader Build Script

:: 设置 PowerShell 执行策略并运行脚本
powershell -ExecutionPolicy Bypass -File "%~dp0build.ps1" %*

if %ERRORLEVEL% neq 0 (
    echo.
    echo Build failed with error code: %ERRORLEVEL%
    pause
)

exit /b %ERRORLEVEL%
