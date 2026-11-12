import cv2
import numpy as np
import os
import shutil
import urllib.request
import tempfile

# 1. 您的原始路徑與資料夾設定
base_dir = r"D:\INDUSTRY-4.0\Class-24-2026-11-12\Day7_20261112\ch10-examples\ch10-3-3"
video_file = os.path.join(base_dir, "starwars.mp4")
output_dir = os.path.join(base_dir, "frames")

# 確保輸出目錄存在
os.makedirs(output_dir, exist_ok=True)

# 2. 自動攔截假影片與重新下載
# 真正的影片大小通常大於 1MB (1024*1024 bytes)。如果太小，代表下載到網頁原始碼了。
if not os.path.exists(video_file) or os.path.getsize(video_file) < 1000000:
    print("⚠️ 發現 starwars.mp4 為無效空殼檔 (可能是下載到 GitHub 網頁代碼)！")
    print("⏳ 正在從正確的 Raw 節點重新下載真正的影片二進位檔，請稍候...")
    
    # 使用正確的 GitHub Raw 下載網址
    real_url = "https://raw.githubusercontent.com/fchart/test/master/media/starwars.mp4"
    try:
        urllib.request.urlretrieve(real_url, video_file)
        print("✅ 真正的高清影片重新下載完成！")
    except Exception as e:
        print(f"❌ 下載失敗，請檢查網路連線：{e}")
        exit()

def cv_imwrite_unicode(file_path, img):
    """解決 OpenCV 寫入中文路徑圖片的 Bug"""
    ext = os.path.splitext(file_path)[1]
    result, encoded_img = cv2.imencode(ext, img)
    if result:
        with open(file_path, 'wb') as f:
            encoded_img.tofile(f)

# 3. 複製影片到系統純英文暫存資料夾 (徹底避開 OpenCV VideoCapture 中文路徑 Bug)
temp_video_path = os.path.join(tempfile.gettempdir(), "temp_starwars_valid.mp4")
shutil.copy2(video_file, temp_video_path)

# 4. 讀取並切割影格
cap = cv2.VideoCapture(temp_video_path)
frame_count = 0

if not cap.isOpened():
    print("❌ 嚴重錯誤：OpenCV 無法解碼影片。請確認 OpenCV 套件是否安裝完整。")
else:
    print("🎬 開始擷取影格，這會花費幾秒鐘...")
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        
        output_path = os.path.join(output_dir, f"frame{frame_count}.jpg")
        cv_imwrite_unicode(output_path, frame)
        frame_count += 1
        
        # 每處理 100 張印出一次進度，避免畫面卡死
        if frame_count % 100 == 0:
            print(f"  ...已抽出 {frame_count} 張圖片")

    cap.release()
    print(f"🎉 大功告成！總共 {frame_count} 個影格已成功抽出並儲存至 '{output_dir}'")

# 5. 結束後自動清理系統暫存影片檔
if os.path.exists(temp_video_path):
    os.remove(temp_video_path)