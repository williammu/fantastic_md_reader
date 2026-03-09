# Script to get logs from HarmonyOS device using HDC

$packageName = "com.example.mdreader"
$localOutputDir = "./logs"

# Create local output directory
if (-not (Test-Path $localOutputDir)) {
    New-Item -ItemType Directory -Path $localOutputDir -Force
    Write-Host "Created local output directory: $localOutputDir"
}

# Check device connection
Write-Host "Checking device connection..."
try {
    $hdcOutput = hdc shell "echo connected"
    if (-not $hdcOutput) {
        Write-Error "No connected device detected. Please ensure device is connected and HDC is properly set up."
        exit 1
    }
    Write-Host "Device connected successfully"
} catch {
    Write-Error "Failed to execute hdc command: $($_.Exception.Message)"
    exit 1
}

# Get device logs
Write-Host "Getting device logs..."
try {
    $logFile = "$localOutputDir\device_logs_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    
    # Capture logs with timestamp
    hdc shell "logcat -v time" | Out-File -FilePath $logFile -Encoding utf8
    
    Write-Host "✓ Logs captured to: $logFile"
    
    # Filter MD Reader logs
    $mdReaderLogFile = "$localOutputDir\md_reader_logs_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    Get-Content $logFile | Select-String -Pattern "MDReader|FileService|MDRender|ReaderPage" | Out-File -FilePath $mdReaderLogFile -Encoding utf8
    
    Write-Host "✓ MD Reader logs filtered to: $mdReaderLogFile"
    
    # Get sandbox files info
    $sandboxInfoFile = "$localOutputDir\sandbox_info_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    
    try {
        $sandboxInfo = hdc shell "ls -la /data/storage/el2/base/haps/$packageName/files/"
        $sandboxInfo | Out-File -FilePath $sandboxInfoFile -Encoding utf8
        Write-Host "✓ Sandbox info saved to: $sandboxInfoFile"
    } catch {
        Write-Warning "Failed to get sandbox info: $($_.Exception.Message)"
    }
    
    Write-Host "\nLog collection completed!"
    Write-Host "Files saved to: $localOutputDir"
    
} catch {
    Write-Error "Failed to get logs: $($_.Exception.Message)"
    exit 1
}
