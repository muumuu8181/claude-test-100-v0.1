# Force close window using PowerShell native methods
param(
    [Parameter(Mandatory=$true)]
    [int]$ProcessId
)

Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    
    public class Win32 {
        [DllImport("user32.dll")]
        public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
        
        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
        
        [DllImport("user32.dll")]
        public static extern bool DestroyWindow(IntPtr hWnd);
        
        [DllImport("user32.dll")]
        public static extern IntPtr GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
        
        [DllImport("user32.dll")]
        public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
        
        public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    }
"@

# Find windows by process ID
$windows = @()
$callback = [Win32+EnumWindowsProc]{
    param($hwnd, $lParam)
    
    $pid = 0
    [Win32]::GetWindowThreadProcessId($hwnd, [ref]$pid)
    
    if ($pid -eq $ProcessId) {
        $script:windows += $hwnd
    }
    
    return $true
}

[Win32]::EnumWindows($callback, [IntPtr]::Zero)

Write-Host "Found $($windows.Count) windows for process $ProcessId"

foreach ($hwnd in $windows) {
    Write-Host "Destroying window handle: $hwnd"
    
    # Hide the window first
    [Win32]::ShowWindow($hwnd, 0)  # SW_HIDE
    
    # Then destroy it
    $result = [Win32]::DestroyWindow($hwnd)
    Write-Host "Destroy result: $result"
}

# Finally kill the process
Write-Host "Killing process $ProcessId"
Stop-Process -Id $ProcessId -Force -ErrorAction SilentlyContinue