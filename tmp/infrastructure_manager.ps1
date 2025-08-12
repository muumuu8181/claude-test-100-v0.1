# Infrastructure Management Script for AI Test Launcher
# Handles environment setup, monitoring, and maintenance

param(
    [string]$Action = "setup",  # setup, monitor, cleanup, health-check
    [string]$ConfigFile = "config.json"
)

# Infrastructure Management Class
class InfrastructureManager {
    [hashtable]$Config
    [string]$ProjectPath
    [object]$Logger
    
    InfrastructureManager([hashtable]$config, [object]$logger) {
        $this.Config = $config
        $this.ProjectPath = $config.PROJECT_PATH
        $this.Logger = $logger
    }
    
    # Environment Setup
    [void] SetupEnvironment() {
        $this.Logger.Log("Setting up test environment", "INFO")
        
        # Create necessary directories
        $directories = @(
            "logs",
            "temp", 
            "test-answers",
            "backup",
            "monitoring"
        )
        
        foreach ($dir in $directories) {
            $fullPath = Join-Path $this.ProjectPath $dir
            if (-not (Test-Path $fullPath)) {
                New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
                $this.Logger.Log("Created directory: $dir", "INFO")
            }
        }
        
        # Setup log rotation
        $this.SetupLogRotation()
        
        # Create monitoring baseline
        $this.CreateMonitoringBaseline()
        
        # Verify WSL connectivity
        $this.VerifyWSLConnectivity()
        
        # Setup PowerShell execution policy
        $this.ConfigurePowerShell()
    }
    
    # Log Rotation Setup
    [void] SetupLogRotation() {
        $rotationScript = @"
# Log Rotation Script
`$LogDirectory = "$($this.ProjectPath)\logs"
`$RetentionDays = $($this.Config.SECURITY.LOG_ROTATION_DAYS)
`$CutoffDate = (Get-Date).AddDays(-`$RetentionDays)

Get-ChildItem -Path `$LogDirectory -Filter "*.log" | 
    Where-Object { `$_.LastWriteTime -lt `$CutoffDate } | 
    Remove-Item -Force

Write-Host "Log rotation completed - removed files older than `$RetentionDays days"
"@
        
        $rotationPath = Join-Path $this.ProjectPath "scripts\log_rotation.ps1"
        $scriptsDir = Split-Path $rotationPath -Parent
        
        if (-not (Test-Path $scriptsDir)) {
            New-Item -ItemType Directory -Path $scriptsDir -Force | Out-Null
        }
        
        $rotationScript | Out-File -FilePath $rotationPath -Encoding UTF8
        $this.Logger.Log("Log rotation script created", "INFO")
    }
    
    # Monitoring Baseline
    [void] CreateMonitoringBaseline() {
        $baseline = @{
            Timestamp = Get-Date
            SystemInfo = @{
                OS = (Get-WmiObject Win32_OperatingSystem).Caption
                TotalMemory = [math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
                ProcessorCount = (Get-WmiObject Win32_ComputerSystem).NumberOfProcessors
            }
            WSLStatus = $this.TestWSLConnectivity()
            PowerShellVersion = $PSVersionTable.PSVersion.ToString()
        }
        
        $baselinePath = Join-Path $this.ProjectPath "monitoring\system_baseline.json"
        $baseline | ConvertTo-Json -Depth 3 | Out-File -FilePath $baselinePath -Encoding UTF8
        $this.Logger.Log("System baseline created", "INFO")
    }
    
    # WSL Connectivity Test
    [bool] TestWSLConnectivity() {
        try {
            $result = & wsl echo "WSL_TEST_OK" 2>$null
            return $result -eq "WSL_TEST_OK"
        }
        catch {
            return $false
        }
    }
    
    # Verify WSL Connectivity
    [void] VerifyWSLConnectivity() {
        if ($this.TestWSLConnectivity()) {
            $this.Logger.Log("WSL connectivity verified", "INFO")
        }
        else {
            $this.Logger.Log("WSL connectivity failed - please ensure WSL is installed and configured", "ERROR")
            throw "WSL not available"
        }
    }
    
    # Configure PowerShell
    [void] ConfigurePowerShell() {
        $currentPolicy = Get-ExecutionPolicy
        if ($currentPolicy -eq "Restricted") {
            $this.Logger.Log("PowerShell execution policy is Restricted. Manual intervention required.", "WARN")
            $this.Logger.Log("Run as Administrator: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser", "WARN")
        }
        else {
            $this.Logger.Log("PowerShell execution policy is acceptable: $currentPolicy", "INFO")
        }
    }
    
    # Health Check
    [hashtable] PerformHealthCheck() {
        $this.Logger.Log("Performing system health check", "INFO")
        
        $health = @{
            Timestamp = Get-Date
            WSL = $this.TestWSLConnectivity()
            Directories = $true
            DiskSpace = $this.CheckDiskSpace()
            Memory = $this.CheckMemoryUsage()
            CPU = $this.CheckCPUUsage()
            Processes = $this.CheckRunningProcesses()
            LogFiles = $this.CheckLogFiles()
        }
        
        # Overall health status
        $criticalIssues = @()
        if (-not $health.WSL) { $criticalIssues += "WSL connectivity" }
        if ($health.DiskSpace.PercentUsed -gt $this.Config.MONITORING.DISK_THRESHOLD) { $criticalIssues += "Disk space" }
        if ($health.Memory.PercentUsed -gt $this.Config.MONITORING.MEMORY_THRESHOLD) { $criticalIssues += "Memory usage" }
        
        $health.Status = if ($criticalIssues.Count -eq 0) { "Healthy" } else { "Warning" }
        $health.Issues = $criticalIssues
        
        return $health
    }
    
    # Disk Space Check
    [hashtable] CheckDiskSpace() {
        $drive = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" | Where-Object { $_.DeviceID -eq "C:" }
        $percentUsed = [math]::Round((($drive.Size - $drive.FreeSpace) / $drive.Size) * 100, 2)
        
        return @{
            TotalGB = [math]::Round($drive.Size / 1GB, 2)
            FreeGB = [math]::Round($drive.FreeSpace / 1GB, 2)
            PercentUsed = $percentUsed
            Status = if ($percentUsed -gt $this.Config.MONITORING.DISK_THRESHOLD) { "Warning" } else { "OK" }
        }
    }
    
    # Memory Usage Check
    [hashtable] CheckMemoryUsage() {
        $memory = Get-WmiObject -Class Win32_OperatingSystem
        $percentUsed = [math]::Round(($memory.TotalVisibleMemorySize - $memory.FreePhysicalMemory) / $memory.TotalVisibleMemorySize * 100, 2)
        
        return @{
            TotalGB = [math]::Round($memory.TotalVisibleMemorySize / 1024 / 1024, 2)
            FreeGB = [math]::Round($memory.FreePhysicalMemory / 1024 / 1024, 2)
            PercentUsed = $percentUsed
            Status = if ($percentUsed -gt $this.Config.MONITORING.MEMORY_THRESHOLD) { "Warning" } else { "OK" }
        }
    }
    
    # CPU Usage Check  
    [hashtable] CheckCPUUsage() {
        $cpu = Get-WmiObject -Class Win32_Processor | Measure-Object -Property LoadPercentage -Average
        $averageLoad = $cpu.Average
        
        return @{
            AverageLoad = $averageLoad
            Status = if ($averageLoad -gt $this.Config.MONITORING.CPU_THRESHOLD) { "Warning" } else { "OK" }
        }
    }
    
    # Running Processes Check
    [array] CheckRunningProcesses() {
        $processes = Get-Process | Where-Object { 
            $_.ProcessName -in @("cmd", "wsl", "claude") -or 
            $_.MainWindowTitle -like "*Claude*" 
        }
        
        return $processes | ForEach-Object {
            @{
                Name = $_.ProcessName
                PID = $_.Id
                StartTime = $_.StartTime
                WorkingSet = [math]::Round($_.WorkingSet / 1MB, 2)
            }
        }
    }
    
    # Log Files Check
    [hashtable] CheckLogFiles() {
        $logDir = Join-Path $this.ProjectPath "logs"
        if (Test-Path $logDir) {
            $logFiles = Get-ChildItem -Path $logDir -Filter "*.log"
            $totalSize = ($logFiles | Measure-Object -Property Length -Sum).Sum
            
            return @{
                Count = $logFiles.Count
                TotalSizeMB = [math]::Round($totalSize / 1MB, 2)
                OldestFile = if ($logFiles) { ($logFiles | Sort-Object LastWriteTime)[0].LastWriteTime } else { $null }
                NewestFile = if ($logFiles) { ($logFiles | Sort-Object LastWriteTime -Descending)[0].LastWriteTime } else { $null }
            }
        }
        else {
            return @{ Count = 0; TotalSizeMB = 0; OldestFile = $null; NewestFile = $null }
        }
    }
    
    # Cleanup Operations
    [void] PerformCleanup() {
        $this.Logger.Log("Performing cleanup operations", "INFO")
        
        # Clean temp files
        $this.CleanTempFiles()
        
        # Rotate logs
        $this.RotateLogs()
        
        # Clean old test results
        $this.CleanOldTestResults()
        
        # Terminate orphaned processes
        $this.CleanOrphanedProcesses()
    }
    
    # Clean Temporary Files
    [void] CleanTempFiles() {
        $tempPaths = @(
            "/tmp/test_answer_*.txt",
            "$($this.ProjectPath)\temp\*",
            "$($this.ProjectPath)\window_process_log.txt"
        )
        
        foreach ($path in $tempPaths) {
            try {
                if ($path.StartsWith("/tmp/")) {
                    # WSL cleanup
                    & wsl rm -f $path 2>$null
                }
                else {
                    # Windows cleanup
                    if (Test-Path $path) {
                        Remove-Item -Path $path -Force -Recurse
                    }
                }
                $this.Logger.Log("Cleaned: $path", "INFO")
            }
            catch {
                $this.Logger.Log("Failed to clean: $path - $($_.Exception.Message)", "WARN")
            }
        }
    }
    
    # Rotate Logs
    [void] RotateLogs() {
        $rotationScript = Join-Path $this.ProjectPath "scripts\log_rotation.ps1"
        if (Test-Path $rotationScript) {
            try {
                & powershell.exe -ExecutionPolicy Bypass -File $rotationScript
                $this.Logger.Log("Log rotation completed", "INFO")
            }
            catch {
                $this.Logger.Log("Log rotation failed: $($_.Exception.Message)", "ERROR")
            }
        }
    }
    
    # Clean Old Test Results
    [void] CleanOldTestResults() {
        $testAnswersDir = Join-Path $this.ProjectPath "test-answers"
        if (Test-Path $testAnswersDir) {
            $backupDir = Join-Path $this.ProjectPath "backup"
            $archiveDate = Get-Date -Format "yyyyMMdd_HHmmss"
            $archivePath = Join-Path $backupDir "test_results_archive_$archiveDate.zip"
            
            try {
                # Archive old results
                Compress-Archive -Path "$testAnswersDir\*" -DestinationPath $archivePath -Force
                
                # Keep only recent files (last 10)
                $testFiles = Get-ChildItem -Path $testAnswersDir -Filter "test*-answer.txt" | Sort-Object LastWriteTime -Descending
                if ($testFiles.Count -gt 10) {
                    $filesToRemove = $testFiles | Select-Object -Skip 10
                    $filesToRemove | Remove-Item -Force
                    $this.Logger.Log("Archived and cleaned old test results", "INFO")
                }
            }
            catch {
                $this.Logger.Log("Test results cleanup failed: $($_.Exception.Message)", "ERROR")
            }
        }
    }
    
    # Clean Orphaned Processes
    [void] CleanOrphanedProcesses() {
        # Find processes older than timeout threshold
        $timeoutMinutes = $this.Config.SECURITY.PROCESS_TIMEOUT_MINUTES
        $cutoffTime = (Get-Date).AddMinutes(-$timeoutMinutes)
        
        $orphanedProcesses = Get-Process | Where-Object {
            $_.ProcessName -in @("cmd", "wsl") -and
            $_.StartTime -lt $cutoffTime -and
            $_.MainWindowTitle -eq ""  # Likely background/orphaned
        }
        
        foreach ($process in $orphanedProcesses) {
            try {
                $this.Logger.Log("Terminating orphaned process: $($process.ProcessName) (PID: $($process.Id))", "WARN")
                $process.Kill()
            }
            catch {
                $this.Logger.Log("Failed to terminate process $($process.Id): $($_.Exception.Message)", "ERROR")
            }
        }
    }
}

# Simple Logger for Infrastructure Manager
class SimpleLogger {
    [string]$LogPath
    
    SimpleLogger([string]$path) {
        $this.LogPath = $path
        
        # Ensure directory exists
        $logDir = Split-Path $path -Parent
        if (-not (Test-Path $logDir)) {
            New-Item -ItemType Directory -Path $logDir -Force | Out-Null
        }
    }
    
    [void] Log([string]$message, [string]$severity = "INFO") {
        $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $logEntry = "[$timestamp] [$severity] $message"
        
        switch ($severity) {
            "ERROR" { Write-Host $logEntry -ForegroundColor Red }
            "WARN"  { Write-Host $logEntry -ForegroundColor Yellow }
            "INFO"  { Write-Host $logEntry -ForegroundColor Green }
        }
        
        Add-Content -Path $this.LogPath -Value $logEntry
    }
}

# Main Execution
try {
    # Load configuration
    if (-not (Test-Path $ConfigFile)) {
        Write-Host "Configuration file not found: $ConfigFile" -ForegroundColor Red
        exit 1
    }
    
    $config = Get-Content $ConfigFile | ConvertFrom-Json
    $logPath = Join-Path $config.PROJECT_PATH "logs\infrastructure_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    $logger = [SimpleLogger]::new($logPath)
    
    $infraManager = [InfrastructureManager]::new($config, $logger)
    
    switch ($Action.ToLower()) {
        "setup" {
            $logger.Log("Starting infrastructure setup", "INFO")
            $infraManager.SetupEnvironment()
            $logger.Log("Infrastructure setup completed", "INFO")
        }
        
        "health-check" {
            $logger.Log("Starting health check", "INFO")
            $health = $infraManager.PerformHealthCheck()
            
            Write-Host "=== System Health Report ===" -ForegroundColor Cyan
            Write-Host "Status: $($health.Status)" -ForegroundColor $(if ($health.Status -eq "Healthy") { "Green" } else { "Yellow" })
            Write-Host "WSL: $($health.WSL)" -ForegroundColor $(if ($health.WSL) { "Green" } else { "Red" })
            Write-Host "Disk Usage: $($health.DiskSpace.PercentUsed)%" -ForegroundColor $(if ($health.DiskSpace.Status -eq "OK") { "Green" } else { "Yellow" })
            Write-Host "Memory Usage: $($health.Memory.PercentUsed)%" -ForegroundColor $(if ($health.Memory.Status -eq "OK") { "Green" } else { "Yellow" })
            Write-Host "CPU Load: $($health.CPU.AverageLoad)%" -ForegroundColor $(if ($health.CPU.Status -eq "OK") { "Green" } else { "Yellow" })
            
            if ($health.Issues.Count -gt 0) {
                Write-Host "Issues:" -ForegroundColor Yellow
                $health.Issues | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
            }
            
            # Save detailed report
            $reportPath = Join-Path $config.PROJECT_PATH "monitoring\health_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
            $health | ConvertTo-Json -Depth 3 | Out-File -FilePath $reportPath -Encoding UTF8
            Write-Host "Detailed report saved to: $reportPath" -ForegroundColor Cyan
        }
        
        "cleanup" {
            $logger.Log("Starting cleanup operations", "INFO")
            $infraManager.PerformCleanup()
            $logger.Log("Cleanup completed", "INFO")
        }
        
        "monitor" {
            $logger.Log("Starting monitoring mode", "INFO")
            Write-Host "Monitoring system health (Press Ctrl+C to stop)..." -ForegroundColor Cyan
            
            while ($true) {
                $health = $infraManager.PerformHealthCheck()
                $timestamp = Get-Date -Format 'HH:mm:ss'
                
                Write-Host "[$timestamp] Status: $($health.Status) | CPU: $($health.CPU.AverageLoad)% | Memory: $($health.Memory.PercentUsed)% | WSL: $($health.WSL)" -ForegroundColor Green
                
                if ($health.Issues.Count -gt 0) {
                    Write-Host "  Issues: $($health.Issues -join ', ')" -ForegroundColor Yellow
                }
                
                Start-Sleep -Seconds 30
            }
        }
        
        default {
            Write-Host "Unknown action: $Action" -ForegroundColor Red
            Write-Host "Available actions: setup, health-check, cleanup, monitor" -ForegroundColor Yellow
            exit 1
        }
    }
}
catch {
    if ($logger) {
        $logger.Log("Infrastructure management failed: $($_.Exception.Message)", "ERROR")
    }
    else {
        Write-Host "Infrastructure management failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    exit 1
}