# Claude Code Einstein Quiz Launcher V2 - With Window Handle Tracking
# Uses Python window manager for precise window control

param(
    [string]$AINumber = "AI_NEW"
)

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

Write-Host "Einstein Quiz Launcher V2 Starting for $AINumber..." -ForegroundColor Green

try {
    # 0. Start Python window monitor in background
    Write-Host "0. Starting window monitor..." -ForegroundColor Yellow
    $monitorJob = Start-Job -ScriptBlock {
        Set-Location "C:\Users\user\claude-test-100-v0.2\auto-claude-start"
        python window_manager.py monitor
    }
    
    Start-Sleep -Seconds 2
    
    # 1. Start new command prompt window
    Write-Host "1. Starting new command prompt..." -ForegroundColor Yellow
    $cmdProcess = Start-Process -FilePath "cmd.exe" -PassThru
    
    # Log process ID
    $processId = $cmdProcess.Id
    Write-Host "Process ID: $processId" -ForegroundColor Cyan
    
    # Write to log file
    $logPath = "C:\Users\user\claude-test-100-v0.2\window_process_log.txt"
    $timestamp = Get-Date -Format 'yyyy-MM-dd_HH:mm:ss'
    $logEntry = "$AINumber, $processId, $timestamp, Started"
    Add-Content -Path $logPath -Value $logEntry
    
    Start-Sleep -Seconds 3
    
    # Get window handle from monitor
    $monitorResult = Receive-Job -Job $monitorJob -Wait
    Remove-Job -Job $monitorJob
    
    if ($monitorResult -match "HWND=(\d+)") {
        $hwnd = $matches[1]
        Write-Host "Window Handle captured: $hwnd" -ForegroundColor Magenta
        
        # Record in Python manager
        python -c "import window_manager; wm = window_manager.WindowManager(); wm.record_window('$AINumber', $hwnd, $processId)"
    }

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

    # 5. Send Einstein Quiz instruction
    Write-Host "5. Sending Einstein Quiz instruction..." -ForegroundColor Yellow
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    
    # Send instruction in English to avoid encoding issues
    $instruction = "Please solve the Einstein puzzle located at /mnt/c/Users/user/claude-test-100-v0.2/アインシュタインクイズ.txt and save your answer to /tmp/einstein_answer_$timestamp.txt - The file is in Japanese, please read it carefully and solve who owns the fish. Write your reasoning process and final answer in the output file."
    
    [System.Windows.Forms.SendKeys]::SendWait($instruction)
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

    Write-Host "Einstein Quiz instruction sent!" -ForegroundColor Green
    Write-Host "Claude Code is now working on the Einstein Quiz." -ForegroundColor Cyan
    Write-Host "Answer will be saved to: /tmp/einstein_answer_$timestamp.txt" -ForegroundColor Yellow
    Write-Host "Process ID for window management: $processId" -ForegroundColor Magenta
    Write-Host "AI Number: $AINumber" -ForegroundColor Cyan

} catch {
    Write-Host "Error occurred: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Script finished. Press Enter to exit..." -ForegroundColor Gray
Read-Host