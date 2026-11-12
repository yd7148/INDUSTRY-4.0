import os
import subprocess
import sys

# 1. 直接鎖定 PyQt5 模組的實際安裝位置，動態設定環境變數
try:
    import PyQt5
    qt_plugin_path = os.path.join(os.path.dirname(PyQt5.__file__), "Qt5", "plugins", "platforms")
    os.environ['QT_QPA_PLATFORM_PLUGIN_PATH'] = qt_plugin_path
except ImportError:
    print("❌ 找不到 PyQt5 模組，請先在 Shell 執行 %pip install PyQt5")

def run_labelImg_script():
    # 建立執行 Python 腳本的路徑
    script_path = os.path.join("labelImg", "labelImg.py")    
    
    # 確認 Python 腳本存在
    if not os.path.exists(script_path):
        print(f"❌ {script_path} 不存在，請確認資料夾結構...")
        return    
        
    # 執行 Python 腳本
    try:
        # 2. 關鍵修改：把 "python" 換成 sys.executable
        # 這能保證 100% 使用目前 Thonny 的 Python 環境來開啟 LabelImg
        subprocess.run([sys.executable, script_path], check=True)
        print(f"✅ 成功執行 {script_path}")
    except subprocess.CalledProcessError as e:
        print(f"❌ 錯誤: 執行 {script_path}: {e} 發生錯誤...")

# 執行LabelImg
run_labelImg_script()