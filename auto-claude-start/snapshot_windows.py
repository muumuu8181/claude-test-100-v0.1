#!/usr/bin/env python3
"""Take snapshot of all windows and compare"""

import win32gui
import win32process
import json
from datetime import datetime

def get_all_windows():
    """Get all visible windows"""
    windows = []
    
    def enum_callback(hwnd, results):
        if win32gui.IsWindowVisible(hwnd):
            window_title = win32gui.GetWindowText(hwnd)
            try:
                _, pid = win32process.GetWindowThreadProcessId(hwnd)
                class_name = win32gui.GetClassName(hwnd)
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
    return windows

def save_snapshot(name):
    """Save current window snapshot"""
    windows = get_all_windows()
    
    # Filter to console windows only
    console_windows = [w for w in windows if w['class'] in ['ConsoleWindowClass', 'PseudoConsoleWindow']]
    
    snapshot = {
        'name': name,
        'timestamp': datetime.now().isoformat(),
        'total_windows': len(windows),
        'console_windows': len(console_windows),
        'windows': console_windows
    }
    
    filename = f'window_snapshot_{name}.json'
    with open(filename, 'w') as f:
        json.dump(snapshot, f, indent=2)
    
    print(f"Snapshot '{name}' saved:")
    print(f"  Total windows: {len(windows)}")
    print(f"  Console windows: {len(console_windows)}")
    for w in console_windows:
        print(f"    - HWND: {w['hwnd']}, PID: {w['pid']}, Title: '{w['title']}'")
    
    return filename

def compare_snapshots(before_file, after_file):
    """Compare two snapshots and find differences"""
    with open(before_file, 'r') as f:
        before = json.load(f)
    
    with open(after_file, 'r') as f:
        after = json.load(f)
    
    before_hwnds = {w['hwnd']: w for w in before['windows']}
    after_hwnds = {w['hwnd']: w for w in after['windows']}
    
    # Find new windows
    new_windows = []
    for hwnd, window in after_hwnds.items():
        if hwnd not in before_hwnds:
            new_windows.append(window)
    
    # Find closed windows
    closed_windows = []
    for hwnd, window in before_hwnds.items():
        if hwnd not in after_hwnds:
            closed_windows.append(window)
    
    print(f"\nComparison Results:")
    print(f"Before: {before['console_windows']} console windows")
    print(f"After: {after['console_windows']} console windows")
    
    if new_windows:
        print(f"\nNEW windows ({len(new_windows)}):")
        for w in new_windows:
            print(f"  - HWND: {w['hwnd']}, PID: {w['pid']}, Title: '{w['title']}'")
    
    if closed_windows:
        print(f"\nCLOSED windows ({len(closed_windows)}):")
        for w in closed_windows:
            print(f"  - HWND: {w['hwnd']}, PID: {w['pid']}, Title: '{w['title']}'")
    
    return new_windows, closed_windows

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1:
        if sys.argv[1] == 'snapshot' and len(sys.argv) > 2:
            save_snapshot(sys.argv[2])
        elif sys.argv[1] == 'compare' and len(sys.argv) > 3:
            compare_snapshots(sys.argv[2], sys.argv[3])
    else:
        print("Usage:")
        print("  python snapshot_windows.py snapshot <name>")
        print("  python snapshot_windows.py compare <before.json> <after.json>")