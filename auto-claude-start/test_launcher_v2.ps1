# Claude Code Test Launcher v2 - Parameterized Version
# Scalable test launcher for AI evaluation

# === Parameters ===
param(
    [Parameter(Mandatory=$false)]
    [string]$TaskType = "all",  # addition/subtraction/multiplication/division/all
    
    [Parameter(Mandatory=$false)]
    [string]$AIName = "AI",     # AI1, AI2, AI3, AI4...
    
    [Parameter(Mandatory=$false)]
    [string]$CustomInstruction = ""  # カスタム指示（オプション）
)

# === Configuration - Load from external config file ===
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configPath = Join-Path $scriptDir "config.json"

if (Test-Path $configPath) {
    $config = Get-Content $configPath | ConvertFrom-Json
    $CURRENT_TEST = $config.current_test
    $PROJECT_PATH = Join-Path $config.project_base $CURRENT_TEST
    $TEST_FILE_PATH = "$($config.wsl_base)/$CURRENT_TEST/sample-test.txt"
    
    Write-Host "Current test folder: $CURRENT_TEST" -ForegroundColor Cyan
} else {
    Write-Host "ERROR: config.json not found. Please create config.json with current_test, project_base, and wsl_base" -ForegroundColor Red
    exit 1
}
# === End Configuration ===

# Win32 API for IME control
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class IMEControl {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
    
    [DllImport("imm32.dll")]
    public static extern IntPtr ImmGetDefaultIMEWnd(IntPtr hWnd);
    
    [DllImport("user32.dll")]
    public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
    
    public const uint WM_IME_CONTROL = 0x0283;
    public const uint IMC_SETOPENSTATUS = 0x0006;
}
"@

Add-Type -AssemblyName System.Windows.Forms

Write-Host "Test Launcher v2 Starting..." -ForegroundColor Green
Write-Host "AI Name: $AIName" -ForegroundColor Cyan
Write-Host "Task Type: $TaskType" -ForegroundColor Cyan

try {
    # 1. Start new command prompt window
    Write-Host "1. Starting new command prompt for $AIName..." -ForegroundColor Yellow
    $cmdProcess = Start-Process -FilePath "cmd.exe" -PassThru
    
    # Log process ID
    $processId = $cmdProcess.Id
    Write-Host "$AIName Process ID: $processId" -ForegroundColor Cyan
    
    # Write to log file with AI name and task type
    $logPath = "$PROJECT_PATH\window_process_log.txt"
    $timestamp = Get-Date -Format 'yyyy-MM-dd_HH:mm:ss'
    $logEntry = "$AIName, $processId, $timestamp, Started, TaskType: $TaskType"
    Add-Content -Path $logPath -Value $logEntry
    
    Start-Sleep -Seconds 3

    Write-Host "2. Preparing to send keys..." -ForegroundColor Yellow
    Write-Host "IMPORTANT: Click on the new command prompt window to make it active!" -ForegroundColor Red
    Write-Host "Commands will be sent in 3 seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds 3

    # IME control - disable IME to ensure English input
    Write-Host "2.1. Disabling IME..." -ForegroundColor Yellow
    try {
        $foregroundWindow = [IMEControl]::GetForegroundWindow()
        $imeWindow = [IMEControl]::ImmGetDefaultIMEWnd($foregroundWindow)
        if ($imeWindow -ne [IntPtr]::Zero) {
            [IMEControl]::SendMessage($imeWindow, [IMEControl]::WM_IME_CONTROL, [IMEControl]::IMC_SETOPENSTATUS, [IntPtr]::Zero)
            Write-Host "IME disabled successfully" -ForegroundColor Green
        }
    } catch {
        Write-Host "IME control failed, proceeding anyway..." -ForegroundColor Yellow
    }
    Start-Sleep -Seconds 1

    # 3. Send wsl command
    Write-Host "3. Entering WSL environment..." -ForegroundColor Yellow
    [System.Windows.Forms.SendKeys]::SendWait("wsl{ENTER}")
    Start-Sleep -Seconds 4

    # 4. Send claude command
    Write-Host "4. Starting Claude Code for $AIName..." -ForegroundColor Yellow
    [System.Windows.Forms.SendKeys]::SendWait("claude{ENTER}")
    Start-Sleep -Seconds 6

    # 5. Send test instruction with dynamic task type
    Write-Host "5. Sending test instruction for $AIName ($TaskType)..." -ForegroundColor Yellow
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    
    # Generate task-specific instruction
    switch ($TaskType) {
        "addition" {
            $taskInstruction = "I am $AIName. Please solve ONLY the addition problems (questions with + sign) from"
        }
        "subtraction" {
            $taskInstruction = "I am $AIName. Please solve ONLY the subtraction problems (questions with - sign) from"
        }
        "multiplication" {
            $taskInstruction = "I am $AIName. Please solve ONLY the multiplication problems (questions with * or × sign) from"
        }
        "division" {
            $taskInstruction = "I am $AIName. Please solve ONLY the division problems (questions with / or ÷ sign) from"
        }
        default {
            $taskInstruction = "I am $AIName. Please solve all the test problems from"
        }
    }
    
    # Use custom instruction if provided, otherwise use generated instruction
    if ($CustomInstruction) {
        $instruction = "$CustomInstruction. Test file: $TEST_FILE_PATH. Save to: $PROJECT_PATH/test-answers/${AIName}_answer_$timestamp.txt"
    } else {
        $instruction = "$taskInstruction $TEST_FILE_PATH and save your answers with detailed calculation process to $PROJECT_PATH/test-answers/${AIName}_answer_$timestamp.txt"
    }
    
    # Send the instruction
    [System.Windows.Forms.SendKeys]::SendWait($instruction)
    Start-Sleep -Seconds 2  # Wait for text to be fully entered
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

    Write-Host "$AIName test instruction sent!" -ForegroundColor Green
    Write-Host "$AIName is now working on $TaskType problems." -ForegroundColor Cyan
    Write-Host "Answer will be saved to: test-answers/${AIName}_answer_$timestamp.txt" -ForegroundColor Yellow
    Write-Host "Process ID for window management: $processId" -ForegroundColor Magenta

} catch {
    Write-Host "Error occurred: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "$AIName script finished. Press Enter to exit..." -ForegroundColor Gray
Read-Host