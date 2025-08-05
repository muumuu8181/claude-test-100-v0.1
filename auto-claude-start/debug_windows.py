#!/usr/bin/env python3
"""Debug window detection"""

import win32gui
import win32process

def debug_all_windows():
    """List all windows with detailed info"""
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
    
    # Check for our specific PID
    target_pid = 13436  # AI21's PID
    
    print(f"Looking for PID {target_pid}...")
    for w in windows:
        if w['pid'] == target_pid:
            print(f"FOUND: HWND={w['hwnd']}, Class='{w['class']}', Title='{w['title']}'")
    
    # Also list all unique window classes
    classes = set(w['class'] for w in windows)
    print(f"\nAll window classes ({len(classes)}):")
    for cls in sorted(classes):
        count = sum(1 for w in windows if w['class'] == cls)
        print(f"  {cls}: {count} windows")

if __name__ == "__main__":
    debug_all_windows()