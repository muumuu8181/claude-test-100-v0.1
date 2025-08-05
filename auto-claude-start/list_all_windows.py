#!/usr/bin/env python3
"""List all visible windows with their handles and titles"""

import win32gui
import win32process

def list_all_windows():
    """List all visible windows"""
    windows = []
    
    def enum_callback(hwnd, results):
        if win32gui.IsWindowVisible(hwnd):
            window_title = win32gui.GetWindowText(hwnd)
            try:
                _, pid = win32process.GetWindowThreadProcessId(hwnd)
                class_name = win32gui.GetClassName(hwnd)
                
                # Filter to show only meaningful windows
                if window_title or class_name in ['ConsoleWindowClass', 'CabinetWClass']:
                    windows.append({
                        'hwnd': hwnd,
                        'title': window_title,
                        'pid': pid,
                        'class': class_name
                    })
            except:
                pass
        return True
    
    win32gui.EnumWindows(enum_callback, windows)
    
    # Sort by title for easier reading
    windows.sort(key=lambda x: x['title'])
    
    print(f"\nFound {len(windows)} visible windows:")
    print("-" * 80)
    
    # Group by window class
    console_windows = [w for w in windows if w['class'] == 'ConsoleWindowClass']
    other_windows = [w for w in windows if w['class'] != 'ConsoleWindowClass']
    
    if console_windows:
        print("\nCONSOLE WINDOWS (cmd.exe, PowerShell, etc.):")
        print("-" * 80)
        for w in console_windows:
            print(f"HWND: {w['hwnd']:10} | PID: {w['pid']:6} | Title: '{w['title']}'")
    
    print(f"\nOTHER WINDOWS (showing first 10):")
    print("-" * 80)
    for w in other_windows[:10]:
        if w['title']:  # Only show windows with titles
            print(f"HWND: {w['hwnd']:10} | PID: {w['pid']:6} | Class: {w['class']:20} | Title: '{w['title']}'")
    
    return console_windows

def check_hwnd_exists(hwnd):
    """Check if a specific window handle still exists"""
    try:
        return win32gui.IsWindow(hwnd)
    except:
        return False

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == 'check':
        # Check specific HWND
        if len(sys.argv) > 2:
            hwnd = int(sys.argv[2])
            exists = check_hwnd_exists(hwnd)
            print(f"Window HWND {hwnd}: {'EXISTS' if exists else 'GONE'}")
    else:
        # List all windows
        list_all_windows()