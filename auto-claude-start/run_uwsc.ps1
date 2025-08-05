# PowerShell script to run UWSC
param(
    [Parameter(Mandatory=$true)]
    [int]$ProcessId
)

$uwscPath = "C:\Users\user\Downloads\uwsc5302 (1)\UWSC.exe"
$scriptPath = "C:\Users\user\claude-test-100-v0.2\auto-claude-start\close_cmd_window.uws"

if (Test-Path $uwscPath) {
    Write-Host "Running UWSC to close window for PID: $ProcessId"
    & $uwscPath $scriptPath $ProcessId
} else {
    Write-Host "UWSC.exe not found at: $uwscPath"
}