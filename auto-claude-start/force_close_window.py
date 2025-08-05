#!/usr/bin/env python3
"""Force close window using various methods"""

import win32gui
import win32con
import win32api
import win32process
import json
import sys
import time

def force_close_window(hwnd):
    """Try multiple methods to close a window"""
    print(f"Attempting to close window HWND={hwnd}")
    
    # Method 1: WM_CLOSE (polite request)
    print("1. Sending WM_CLOSE...")
    win32gui.SendMessage(hwnd, win32con.WM_CLOSE, 0, 0)
    time.sleep(2)
    
    if not win32gui.IsWindow(hwnd):
        print("Window closed successfully with WM_CLOSE")
        return True
    
    # Method 2: WM_DESTROY (more forceful)
    print("2. Sending WM_DESTROY...")
    win32gui.SendMessage(hwnd, win32con.WM_DESTROY, 0, 0)
    time.sleep(2)
    
    if not win32gui.IsWindow(hwnd):
        print("Window closed successfully with WM_DESTROY")
        return True
    
    # Method 3: Kill the process
    print("3. Killing process...")
    try:
        _, pid = win32process.GetWindowThreadProcessId(hwnd)
        print(f"   Process ID: {pid}")
        
        # Open process with terminate rights
        handle = win32api.OpenProcess(win32con.PROCESS_TERMINATE, False, pid)
        win32api.TerminateProcess(handle, 0)
        win32api.CloseHandle(handle)
        
        print("Process terminated successfully")
        return True
    except Exception as e:
        print(f"   Error killing process: {e}")
    
    # Method 4: Use PostMessage instead of SendMessage
    print("4. Using PostMessage with WM_QUIT...")
    win32gui.PostMessage(hwnd, win32con.WM_QUIT, 0, 0)
    time.sleep(2)
    
    if not win32gui.IsWindow(hwnd):
        print("Window closed successfully with WM_QUIT")
        return True
    
    print("Failed to close window with all methods")
    return False

def close_by_ai_number(ai_number):
    """Close window for specific AI number"""
    try:
        with open('window_handles.json', 'r') as f:
            windows = json.load(f)
        
        if ai_number in windows:
            hwnd = windows[ai_number]['hwnd']
            return force_close_window(hwnd)
        else:
            print(f"No window record found for {ai_number}")
            return False
    except Exception as e:
        print(f"Error: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) > 1:
        ai_number = sys.argv[1]
        close_by_ai_number(ai_number)