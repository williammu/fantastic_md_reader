# Script to get logs from MD Reader via Socket

$port = 8080
$outputFile = "./logs/socket_logs_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# Create output directory if it doesn't exist
if (-not (Test-Path "./logs")) {
    New-Item -ItemType Directory -Path "./logs" -Force
    Write-Host "Created logs directory"
}

# Set up port forwarding using HDC
Write-Host "Setting up port forwarding..."
try {
    # First, remove any existing port forwarding
    hdc fport rm "tcp:$port" 2>$null
    
    # Set up new port forwarding
    $forwardingResult = hdc fport "tcp:$port" "tcp:$port"
    
    # Give it a moment to start
    Start-Sleep -Seconds 2
    
    # Check if port forwarding is working
    $forwardingStatus = hdc fport ls
    if ($forwardingStatus -match "tcp:$port") {
        Write-Host "Port forwarding established"
    } else {
        Write-Error "Failed to establish port forwarding"
        exit 1
    }
} catch {
    Write-Error "Failed to set up port forwarding: $($_.Exception.Message)"
    exit 1
}

# Connect to the socket and get logs
Write-Host "Connecting to MD Reader socket..."
try {
    # Create TCP client
    $client = New-Object System.Net.Sockets.TcpClient
    $client.Connect("localhost", $port)
    
    # Get stream
    $stream = $client.GetStream()
    $reader = New-Object System.IO.StreamReader($stream)
    
    # Read all data
    $logs = $reader.ReadToEnd()
    
    # Save to file
    $logs | Out-File -FilePath $outputFile -Encoding utf8
    
    # Close connections
    $reader.Close()
    $stream.Close()
    $client.Close()
    
    # Stop port forwarding
    hdc fport rm "tcp:$port" 2>$null
    
    Write-Host "✓ Logs retrieved successfully"
    Write-Host "✓ Logs saved to: $outputFile"
    
    # Display the logs
    Write-Host "\n=== MD Reader Logs ==="
    Write-Host $logs
    Write-Host "======================"
    
} catch {
    Write-Error "Failed to get logs: $($_.Exception.Message)"
    # Stop port forwarding if it's running
    hdc fport rm "tcp:$port" 2>$null
    exit 1
}
