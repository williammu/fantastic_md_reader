# Script to get MD Reader sandbox files from HarmonyOS device using HDC

$packageName = "com.example.mdreader"
$localOutputDir = "./sandbox_files"
$deviceSandboxPath = "/data/storage/el2/base/haps/$packageName/files/shared"

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

# Check if sandbox directory exists
Write-Host "Checking if sandbox directory exists..."
try {
    hdc shell "ls $deviceSandboxPath" > $null 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Sandbox directory does not exist. App may not have run or created sandbox yet."
        exit 0
    }
    Write-Host "Sandbox directory exists: $deviceSandboxPath"
} catch {
    Write-Error "Failed to check sandbox directory: $($_.Exception.Message)"
    exit 1
}

# List files in sandbox
Write-Host "Listing files in sandbox..."
try {
    $files = hdc shell "ls $deviceSandboxPath"
    Write-Host "Files in sandbox:"
    Write-Host $files
    
    # Copy files to local
    $filesArray = $files -split "\r?\n"
    foreach ($file in $filesArray) {
        if ($file.Trim() -and $file.Trim() -ne "." -and $file.Trim() -ne "..") {
            $remoteFilePath = "$deviceSandboxPath/$file"
            $localFilePath = "$localOutputDir/$file"
            
            Write-Host "Copying file: $file"
            hdc file send $remoteFilePath $localFilePath
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✓ Successfully copied: $file"
            } else {
                Write-Warning "✗ Failed to copy: $file"
            }
        }
    }
    
    Write-Host "\nFiles have been copied to: $localOutputDir"
    Write-Host "Task completed!"
    
} catch {
    Write-Error "Failed to copy files: $($_.Exception.Message)"
    exit 1
}
