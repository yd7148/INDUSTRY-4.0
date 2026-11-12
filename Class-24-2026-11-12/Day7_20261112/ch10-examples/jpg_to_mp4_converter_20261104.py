import cv2
import numpy as np
import os

# 設定圖檔資料夾和輸出影片檔案名稱 (在字串前加上 r 可防止 \N 轉義錯誤)
image_folder = r"D:\IIOT\課程資料\Node-RED AI 學習\ch10-examples\Custom-Object-Detection-master\images"
output_video = "starwars2026.mp4"

def cv_imread_unicode(file_path):
    """解決 OpenCV 無法直接讀取中文路徑圖片的問題"""
    cv_img = cv2.imdecode(np.fromfile(file_path, dtype=np.uint8), cv2.IMREAD_COLOR)
    return cv_img

def images_to_video(image_folder, output_video, fps=30):
    # 取得所有圖檔名稱
    images = [img for img in os.listdir(image_folder) if img.endswith(".jpg")]
    
    if not images:
        print("警告：在該資料夾中找不到任何 .jpg 圖片！")
        return
        
    images.sort()  # 確保圖片按名稱排序
    
    # 讀取第一張圖檔以取得影像尺寸 (改用支援中文路徑的讀取函式)
    first_image_path = os.path.join(image_folder, images[0])
    frame = cv_imread_unicode(first_image_path)
    
    if frame is None:
        print(f"錯誤：無法讀取圖片 {first_image_path}")
        return

    height, width, layers = frame.shape

    # 設定影片編碼 (使用 mp4v 格式)
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    video = cv2.VideoWriter(output_video, fourcc, fps, (width, height))

    print(f"開始轉換圖片，共 {len(images)} 張...")
    for image in images:
        image_path = os.path.join(image_folder, image)
        frame = cv_imread_unicode(image_path)
        if frame is not None:
            video.write(frame)

    video.release()
    print(f"✅ 影片已成功儲存為 {output_video}")

# 將圖片轉換成影片 (fps=10)
images_to_video(image_folder, output_video, fps=10)