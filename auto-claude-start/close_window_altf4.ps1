# Close window using Alt+F4
param(
    [Parameter(Mandatory=$true)]
    [int]$ProcessId
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    
    public class Win32Window {
        [DllImport("user32.dll")]
        public static extern bool SetForegroundWindow(IntPtr hWnd);
        
        [DllImport("user32.dll")]
        public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
        
        [DllImport("user32.dll")]
        public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
        
        [DllImport("user32.dll")]
        public static extern IntPtr GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
        
        [DllImport("user32.dll")]
        public static extern bool IsWindowVisible(IntPtr hWnd);
        
        public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    }
"@

# Find window by process ID
$targetHwnd = [IntPtr]::Zero

$callback = [Win32Window+EnumWindowsProc]{
    param($hwnd, $lParam)
    
    $windowPid = 0
    [Win32Window]::GetWindowThreadProcessId($hwnd, [ref]$windowPid)
    
    if ($windowPid -eq $ProcessId -and [Win32Window]::IsWindowVisible($hwnd)) {
        $script:targetHwnd = $hwnd
        return $false  # Stop enumeration
    }
    
    return $true
}

[Win32Window]::EnumWindows($callback, [IntPtr]::Zero)

if ($targetHwnd -ne [IntPtr]::Zero) {
    Write-Host "Found window for process $ProcessId, HWND: $targetHwnd"
    
    # Bring window to foreground
    [Win32Window]::SetForegroundWindow($targetHwnd)
    Start-Sleep -Milliseconds 500
    
    # Send Alt+F4
    Write-Host "Sending Alt+F4..."
    [System.Windows.Forms.SendKeys]::SendWait("%{F4}")
    
    Write-Host "Alt+F4 sent"
} else {
    Write-Host "No visible window found for process $ProcessId"
}

# Wait a bit then force kill if still alive
Start-Sleep -Seconds 2
if (Get-Process -Id $ProcessId -ErrorAction SilentlyContinue) {
    Write-Host "Process still alive, force killing..."
    Stop-Process -Id $ProcessId -Force
}