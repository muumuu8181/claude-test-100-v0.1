# Claude Code Test Launcher
# Generic test launcher for AI evaluation

# === Configuration - Adjust these paths for your environment ===
$PROJECT_PATH = "C:\Users\user\Desktop\work\90_cc\20250812\claude-test-100\test-20250812"
$TEST_FILE_PATH = "/mnt/c/Users/user/Desktop/work/90_cc/20250812/claude-test-100/test-20250812/sample-test.txt"
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

Write-Host "Test Launcher Starting..." -ForegroundColor Green

try {
    # 1. Start new command prompt window
    Write-Host "1. Starting new command prompt..." -ForegroundColor Yellow
    $cmdProcess = Start-Process -FilePath "cmd.exe" -PassThru
    
    # Log process ID
    $processId = $cmdProcess.Id
    Write-Host "Process ID: $processId" -ForegroundColor Cyan
    
    # Write to log file
    $logPath = "$PROJECT_PATH\window_process_log.txt"
    $timestamp = Get-Date -Format 'yyyy-MM-dd_HH:mm:ss'
    $logEntry = "AI_NEW, $processId, $timestamp, Started"
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
    Write-Host "4. Starting Claude Code..." -ForegroundColor Yellow
    [System.Windows.Forms.SendKeys]::SendWait("claude{ENTER}")
    Start-Sleep -Seconds 6

    # 5. Send test instruction
    Write-Host "5. Sending test instruction..." -ForegroundColor Yellow
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    
    # Send instruction to solve test problems
    $instruction = "Please solve the test problems located at $TEST_FILE_PATH and save your answers to /tmp/test_answer_$timestamp.txt. Write your reasoning process and final answer for each problem in the output file."
    
    [System.Windows.Forms.SendKeys]::SendWait($instruction)
    Start-Sleep -Seconds 2  # Wait for text to be fully entered
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

    Write-Host "Test instruction sent!" -ForegroundColor Green
    Write-Host "Claude Code is now working on the test." -ForegroundColor Cyan
    Write-Host "Answer will be saved to: /tmp/test_answer_$timestamp.txt" -ForegroundColor Yellow
    Write-Host "Process ID for window management: $processId" -ForegroundColor Magenta

} catch {
    Write-Host "Error occurred: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Script finished. Press Enter to exit..." -ForegroundColor Gray
Read-Host