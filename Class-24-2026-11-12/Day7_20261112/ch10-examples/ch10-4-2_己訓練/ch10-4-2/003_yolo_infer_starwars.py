import os
import sys
import json
import contextlib

os.environ["PYTHONIOENCODING"] = "utf-8"
os.environ["YOLO_CONFIG_DIR"] = r"D:\IIOT\課程資料\Node-RED AI 學習\ch10-examples\ch10-4-2"

with open(os.devnull, "w", encoding="utf-8") as fnull:
    with contextlib.redirect_stdout(fnull), contextlib.redirect_stderr(fnull):
        try:
            from ultralytics import YOLO
        except Exception as e:
            sys.stdout = sys.__stdout__
            print(json.dumps({"error": str(e), "annotations": []}))
            sys.exit(0)

def find_image_path(raw_path):
    r"""Search image in val/train/frames folders"""
    clean_name = os.path.basename(raw_path)
    base_dir = r"D:\IIOT\課程資料\Node-RED AI 學習\ch10-examples\ch10-4-2"
    
    candidates = [
        raw_path,
        os.path.join(base_dir, "val", "images", clean_name),
        os.path.join(base_dir, "train", "images", clean_name),
        os.path.join(base_dir, "frames", clean_name)
    ]
    for path in candidates:
        if os.path.exists(path) and os.path.isfile(path):
            return path
    return None

def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "No image argument", "annotations": [], "detected": []}))
        return

    raw_path = sys.argv[1].strip('"').strip("'")
    img_path = find_image_path(raw_path)
    model_path = r"D:\IIOT\課程資料\Node-RED AI 學習\ch10-examples\ch10-4-2\runs\detect\train\weights\best.pt"

    if not os.path.exists(model_path):
        print(json.dumps({"error": "Model not found", "annotations": []}))
        return

    if not img_path:
        print(json.dumps({"error": "Image not found", "annotations": []}))
        return

    with open(os.devnull, "w", encoding="utf-8") as fnull:
        with contextlib.redirect_stdout(fnull), contextlib.redirect_stderr(fnull):
            model = YOLO(model_path)
            # 先用 conf=0.01 觀察模型的原始預測能力
            results = model(img_path, conf=0.01, verbose=False)

    annotations = []
    if len(results) > 0 and results[0].boxes is not None:
        boxes = results[0].boxes
        names = results[0].names
        
        for box in boxes:
            cls_id = int(box.cls[0].item())
            conf = float(box.conf[0].item())
            x1, y1, x2, y2 = box.xyxy[0].tolist()
            
            annotations.append({
                "className": names.get(cls_id, f"class_{cls_id}"),
                "probability": round(conf, 3),
                "bbox": [round(x1), round(y1), round(x2 - x1), round(y2 - y1)]
            })

    output = {
        "annotations": annotations,
        "detected": annotations
    }
    print(json.dumps(output, ensure_ascii=False))

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(json.dumps({"error": str(e), "annotations": []}))