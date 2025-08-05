# Claude Code Auto Start Script v2.0
# Automatically starts Claude Code in Windows environment

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

Write-Host "Claude Code Auto Start Script v2.0 Starting..." -ForegroundColor Green

try {
    # 1. Start new command prompt window
    Write-Host "1. Starting new command prompt..." -ForegroundColor Yellow
    $cmdProcess = Start-Process -FilePath "cmd.exe" -PassThru
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

    # 5. Send hello test command
    Write-Host "5. Running initial test..." -ForegroundColor Yellow
    [System.Windows.Forms.SendKeys]::SendWait("hello{ENTER}")

    Write-Host "Claude Code auto start completed!" -ForegroundColor Green
    Write-Host "Claude Code is now running in the new command prompt window." -ForegroundColor Cyan

} catch {
    Write-Host "Error occurred: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please manually open command prompt and run:" -ForegroundColor Yellow
    Write-Host "1. wsl" -ForegroundColor White
    Write-Host "2. claude" -ForegroundColor White
    Write-Host "3. hello" -ForegroundColor White
}

Write-Host "Script finished. Press Enter to exit..." -ForegroundColor Gray
Read-Host