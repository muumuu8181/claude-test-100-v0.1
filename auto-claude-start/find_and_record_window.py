#!/usr/bin/env python3
"""Find cmd window by PID and record it"""

import win32gui
import win32process
import win32con
import json
import sys
from datetime import datetime

def find_window_by_pid(target_pid):
    """Find window handle by process ID"""
    result = None
    
    def enum_callback(hwnd, pid):
        if win32gui.IsWindowVisible(hwnd):
            _, window_pid = win32process.GetWindowThreadProcessId(hwnd)
            if window_pid == pid:
                title = win32gui.GetWindowText(hwnd)
                print(f"Found window: HWND={hwnd}, Title='{title}'")
                result_list.append({
                    'hwnd': hwnd,
                    'title': title,
                    'pid': window_pid
                })
        return True
    
    result_list = []
    win32gui.EnumWindows(enum_callback, target_pid)
    
    return result_list[0] if result_list else None

def record_window(ai_number, hwnd, pid):
    """Record window information"""
    windows = {}
    
    # Load existing data
    try:
        with open('window_handles.json', 'r') as f:
            windows = json.load(f)
    except:
        pass
    
    # Add new entry
    windows[ai_number] = {
        'hwnd': hwnd,
        'pid': pid,
        'start_time': datetime.now().isoformat(),
        'status': 'active'
    }
    
    # Save
    with open('window_handles.json', 'w') as f:
        json.dump(windows, f, indent=2)
    
    print(f"Recorded window for {ai_number}")

if __name__ == "__main__":
    if len(sys.argv) >= 2:
        pid = int(sys.argv[1])
        ai_number = sys.argv[2] if len(sys.argv) > 2 else f"AI_{pid}"
        
        window = find_window_by_pid(pid)
        if window:
            record_window(ai_number, window['hwnd'], window['pid'])
            print(f"Successfully recorded window for {ai_number}")
        else:
            print(f"No window found for PID {pid}")
    else:
        print("Usage: python find_and_record_window.py <PID> [AI_NUMBER]")