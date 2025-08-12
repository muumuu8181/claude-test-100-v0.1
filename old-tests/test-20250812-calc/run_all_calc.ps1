# Run All AIs - Batch Execution Script
# This script launches multiple AIs with different task types

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   AI Batch Launcher - Starting All AIs " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Define AI configurations
$aiConfigs = @(
    @{Name="AI1"; TaskType="addition"},
    @{Name="AI2"; TaskType="subtraction"},
    @{Name="AI3"; TaskType="multiplication"},
    @{Name="AI4"; TaskType="division"}
)

# Optional: Ask for confirmation
Write-Host "This will launch the following AIs:" -ForegroundColor Yellow
foreach ($config in $aiConfigs) {
    Write-Host "  - $($config.Name): $($config.TaskType)" -ForegroundColor White
}
Write-Host ""
Write-Host "Continue? (Y/N): " -NoNewline -ForegroundColor Green
$response = Read-Host
if ($response -ne 'Y' -and $response -ne 'y') {
    Write-Host "Launch cancelled." -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "Starting AI launch sequence..." -ForegroundColor Cyan
Write-Host ""

# Launch each AI with proper delay
$count = 1
foreach ($config in $aiConfigs) {
    Write-Host "[$count/$($aiConfigs.Count)] Launching $($config.Name) for $($config.TaskType)..." -ForegroundColor Yellow
    
    # Start the AI process
    Start-Process powershell -ArgumentList "-ExecutionPolicy", "Bypass", "-File", "test_launcher_v2.ps1", "-TaskType", $config.TaskType, "-AIName", $config.Name -WindowStyle Normal
    
    Write-Host "$($config.Name) launched successfully!" -ForegroundColor Green
    
    # Wait before launching next AI (to avoid window focus issues)
    if ($count -lt $aiConfigs.Count) {
        Write-Host "Waiting 10 seconds before launching next AI..." -ForegroundColor Gray
        Start-Sleep -Seconds 10
    }
    
    $count++
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   All AIs have been launched!         " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Each AI is working on their assigned task type." -ForegroundColor Yellow
Write-Host "Results will be saved in test-20250812/test-answers/" -ForegroundColor Yellow
Write-Host ""

# Log the batch execution
$timestamp = Get-Date -Format 'yyyy-MM-dd_HH:mm:ss'
$logPath = ".\batch_execution.log"
$logEntry = "Batch execution at $timestamp - Launched $($aiConfigs.Count) AIs"
Add-Content -Path $logPath -Value $logEntry

Write-Host "Batch execution logged to: batch_execution.log" -ForegroundColor Gray
Write-Host ""
Write-Host "Press Enter to exit..." -ForegroundColor Gray
Read-Host