#!/usr/bin/env python3
"""
Window Manager for Einstein Quiz Workers
Uses pywin32 to manage windows by handle instead of process ID
"""

import win32gui
import win32con
import win32process
import win32api
import time
import json
from datetime import datetime

class WindowManager:
    def __init__(self):
        self.windows = {}
        
    def find_windows_by_title(self, title_pattern):
        """Find all windows matching title pattern"""
        windows = []
        
        def enum_callback(hwnd, results):
            if win32gui.IsWindowVisible(hwnd):
                window_title = win32gui.GetWindowText(hwnd)
                if title_pattern.lower() in window_title.lower():
                    _, pid = win32process.GetWindowThreadProcessId(hwnd)
                    windows.append({
                        'hwnd': hwnd,
                        'title': window_title,
                        'pid': pid
                    })
            return True
            
        win32gui.EnumWindows(enum_callback, windows)
        return windows
    
    def get_new_cmd_window(self, before_snapshot):
        """Find newly created cmd window by comparing snapshots"""
        after_snapshot = self.find_windows_by_title('cmd.exe')
        
        # Find windows that exist in after but not in before
        before_hwnds = {w['hwnd'] for w in before_snapshot}
        new_windows = [w for w in after_snapshot if w['hwnd'] not in before_hwnds]
        
        return new_windows[0] if new_windows else None
    
    def record_window(self, ai_number, hwnd, pid):
        """Record window information"""
        self.windows[ai_number] = {
            'hwnd': hwnd,
            'pid': pid,
            'start_time': datetime.now().isoformat(),
            'status': 'active'
        }
        
        # Save to file
        with open('window_handles.json', 'w') as f:
            json.dump(self.windows, f, indent=2)
    
    def close_window_by_ai_number(self, ai_number):
        """Close window for specific AI number"""
        if ai_number in self.windows:
            window_info = self.windows[ai_number]
            hwnd = window_info['hwnd']
            
            try:
                # Send WM_CLOSE message to window
                win32gui.SendMessage(hwnd, win32con.WM_CLOSE, 0, 0)
                
                # Update status
                window_info['status'] = 'closed'
                window_info['end_time'] = datetime.now().isoformat()
                
                # Save updated info
                with open('window_handles.json', 'w') as f:
                    json.dump(self.windows, f, indent=2)
                    
                print(f"Successfully closed window for AI{ai_number}")
                return True
            except Exception as e:
                print(f"Error closing window: {e}")
                return False
        else:
            print(f"No window record found for AI{ai_number}")
            return False
    
    def list_active_windows(self):
        """List all active AI windows"""
        active = [(num, info) for num, info in self.windows.items() 
                  if info['status'] == 'active']
        
        if active:
            print("Active AI Windows:")
            for ai_num, info in active:
                print(f"  AI{ai_num}: HWND={info['hwnd']}, PID={info['pid']}")
        else:
            print("No active AI windows")

# Example usage functions
def monitor_new_window():
    """Monitor for new cmd window and return its info"""
    wm = WindowManager()
    
    # Take snapshot before
    before = wm.find_windows_by_title('cmd.exe')
    print(f"Found {len(before)} cmd windows before")
    
    # Wait for new window
    print("Waiting for new window...")
    for i in range(30):  # Wait up to 30 seconds
        time.sleep(1)
        new_window = wm.get_new_cmd_window(before)
        if new_window:
            print(f"New window detected: HWND={new_window['hwnd']}, PID={new_window['pid']}")
            return new_window
    
    print("No new window detected")
    return None

def close_ai_window(ai_number):
    """Close window for specific AI"""
    wm = WindowManager()
    
    # Load existing records
    try:
        with open('window_handles.json', 'r') as f:
            wm.windows = json.load(f)
    except:
        pass
    
    return wm.close_window_by_ai_number(ai_number)

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1:
        if sys.argv[1] == 'monitor':
            monitor_new_window()
        elif sys.argv[1] == 'close' and len(sys.argv) > 2:
            close_ai_window(sys.argv[2])
        elif sys.argv[1] == 'list':
            wm = WindowManager()
            try:
                with open('window_handles.json', 'r') as f:
                    wm.windows = json.load(f)
            except:
                pass
            wm.list_active_windows()
    else:
        print("Usage:")
        print("  python window_manager.py monitor     # Monitor for new window")
        print("  python window_manager.py close AI18  # Close specific AI window")
        print("  python window_manager.py list        # List active windows")