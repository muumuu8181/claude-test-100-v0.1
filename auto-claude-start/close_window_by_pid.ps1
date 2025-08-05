# Close window and all child processes by parent PID
param(
    [Parameter(Mandatory=$true)]
    [int]$ProcessId
)

try {
    # Get the process and all its children
    $process = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
    
    if ($process) {
        Write-Host "Found process: $($process.ProcessName) (PID: $ProcessId)" -ForegroundColor Yellow
        
        # Get all child processes using WMI
        $children = Get-WmiObject Win32_Process | Where-Object { $_.ParentProcessId -eq $ProcessId }
        
        # Kill children first
        foreach ($child in $children) {
            Write-Host "Killing child process: $($child.Name) (PID: $($child.ProcessId))" -ForegroundColor Cyan
            Stop-Process -Id $child.ProcessId -Force -ErrorAction SilentlyContinue
        }
        
        # Then kill parent
        Write-Host "Killing parent process: $($process.ProcessName) (PID: $ProcessId)" -ForegroundColor Green
        Stop-Process -Id $ProcessId -Force
        
        Write-Host "Process tree terminated successfully" -ForegroundColor Green
    } else {
        Write-Host "Process $ProcessId not found" -ForegroundColor Red
    }
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}