#!/usr/bin/env python3
"""Close window by HWND directly"""

import win32gui
import win32con
import win32api
import win32process
import sys

def close_window_by_hwnd(hwnd):
    """Close window by its handle"""
    hwnd = int(hwnd)
    
    print(f"Attempting to close window HWND={hwnd}")
    
    # Check if window exists
    if not win32gui.IsWindow(hwnd):
        print("Window does not exist!")
        return False
    
    # Get window info
    try:
        _, pid = win32process.GetWindowThreadProcessId(hwnd)
        print(f"Window PID: {pid}")
    except:
        print("Could not get PID")
    
    # Try WM_CLOSE first
    print("Sending WM_CLOSE...")
    win32gui.PostMessage(hwnd, win32con.WM_CLOSE, 0, 0)
    
    print("Window close message sent")
    return True

if __name__ == "__main__":
    if len(sys.argv) > 1:
        hwnd = sys.argv[1]
        close_window_by_hwnd(hwnd)
    else:
        print("Usage: python close_window_by_hwnd.py <HWND>")