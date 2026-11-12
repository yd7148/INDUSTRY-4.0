import cv2
import os
import re
import numpy as np

# 1. 路徑與類別設定
image_folder = "train/images"     # 圖檔路徑
label_folder = "train/labels"     # 標註檔路徑
class_names = ["Millennium Falcon", "Tie Fighter"]  # 類別名稱清單

# 定義顏色庫 (BGR 格式)，不同類別套用不同顏色
COLORS = [
    (0, 255, 0),    # 類別 0: 綠色
    (0, 165, 255),  # 類別 1: 橘色
    (255, 0, 0),    # 類別 2: 藍色
    (0, 255, 255)   # 類別 3: 黃色
]

# 2. 自然排序 key 函式（解析數字轉成 integer 比對，解決 28 排在 280 後面的問題）
def natural_sort_key(s):
    return [int(text) if text.isdigit() else text.lower() for text in re.split(r'(\d+)', s)]

# 3. 支援中文路徑的 OpenCV 圖檔讀取函式
def cv_imread(file_path):
    try:
        img_array = np.fromfile(file_path, dtype=np.uint8)
        return cv2.imdecode(img_array, cv2.IMREAD_COLOR)
    except Exception as e:
        print(f"無法讀取圖檔 {file_path}: {e}")
        return None

# 4. 讀取目錄下的所有圖檔並進行自然排序
image_files = sorted(os.listdir(image_folder), key=natural_sort_key)
# 過濾出影像檔
image_files = [f for f in image_files if f.lower().endswith((".jpg", ".jpeg", ".png", ".bmp"))]

print(f"找到 {len(image_files)} 個圖檔。")
print("操作說明：【向下鍵 ↓ / 向右鍵 → / 空格鍵】下一張 | 【向上鍵 ↑ / 向左鍵 ←】上一張 | 【Esc / Q】離開\n")

if len(image_files) == 0:
    print("錯誤：指定目錄內找不到任何圖片！")
    exit()

current_idx = 0

# 5. 透過索引循環走訪
while 0 <= current_idx < len(image_files):
    image_file = image_files[current_idx]
    image_path = os.path.join(image_folder, image_file)
    label_path = os.path.join(label_folder, os.path.splitext(image_file)[0] + ".txt")

    img = cv_imread(image_path)
    if img is None:
        current_idx += 1
        continue

    img_h, img_w = img.shape[:2]

    # 如果對應的標註檔存在，則讀取標註並繪製 Bounding Box
    if os.path.exists(label_path):
        with open(label_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        for line in lines:
            parts = line.strip().split()
            if len(parts) < 5:
                continue

            class_id = int(parts[0])
            x_center = float(parts[1])
            y_center = float(parts[2])
            box_w = float(parts[3])
            box_h = float(parts[4])

            # 將 YOLO 歸一化座標 (0~1) 轉換回像素座標
            x1 = int((x_center - box_w / 2) * img_w)
            y1 = int((y_center - box_h / 2) * img_h)
            x2 = int((x_center + box_w / 2) * img_w)
            y2 = int((y_center + box_h / 2) * img_h)

            # 限制座標在圖片範圍內
            x1, y1 = max(0, x1), max(0, y1)
            x2, y2 = min(img_w - 1, x2), min(img_h - 1, y2)

            # 取得類別名稱與色彩
            label_name = class_names[class_id] if class_id < len(class_names) else f"Class {class_id}"
            color = COLORS[class_id % len(COLORS)]

            # 畫出 Bounding Box
            cv2.rectangle(img, (x1, y1), (x2, y2), color, 2)

            # 畫出標籤背景與文字
            text = f"{label_name}"
            (font_w, font_h), baseline = cv2.getTextSize(text, cv2.FONT_HERSHEY_SIMPLEX, 0.6, 2)
            cv2.rectangle(img, (x1, y1 - font_h - 10), (x1 + font_w + 6, y1), color, -1)
            cv2.putText(img, text, (x1 + 3, y1 - 5), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)

    # 顯示視窗標題與圖片資訊
    window_title = f"[{current_idx + 1}/{len(image_files)}] {image_file} (Up/Down Arrow to Switch, Esc/Q to Quit)"
    cv2.imshow("YOLO Annotation Viewer", img)
    cv2.setWindowTitle("YOLO Annotation Viewer", window_title)

    # 監聽按鍵 (cv2.waitKeyEx 支援方向鍵 keyCode 讀取)
    key = cv2.waitKeyEx(0)

    # 判斷鍵盤動作
    # 27: Esc, ord('q') / ord('Q'): 離開
    if key == 27 or key == ord('q') or key == ord('Q'):
        print("已終止檢視。")
        break
    # 向上鍵 ↑ (Windows 2490368 / 82) 或 向左鍵 ← (2424832 / 81)
    elif key in [2490368, 82, 2424832, 81]:
        if current_idx > 0:
            current_idx -= 1
        else:
            print("已是第一張圖片！")
    # 向下鍵 ↓ (Windows 2621440 / 84) 或 向右鍵 → (2555904 / 83) 或 Space (32)
    elif key in [2621440, 84, 2555904, 83, 32]:
        if current_idx < len(image_files) - 1:
            current_idx += 1
        else:
            print("已是最後一張圖片！")

cv2.destroyAllWindows()