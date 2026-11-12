import os
from ultralytics import YOLO

if __name__ == "__main__":
    # 1. 切換工作目錄至資料集資料夾
    dataset_dir = r"D:\IIOT\課程資料\Node-RED AI 學習\ch10-examples\ch10-4-2"
    os.chdir(dataset_dir)
    print(f"目前工作目錄已切換至: {os.getcwd()}")

    # 2. 載入 YOLOv8 微型模型 (YOLOv8n)
    model = YOLO("yolov8n.pt")

    # 3. 開始訓練星際大戰辨識模型
    print("開始訓練星際大戰飛船模型...")
    results = model.train(
        data="data.yaml",
        epochs=50,
        imgsz=640,
        workers=2,
        batch=16
    )

    print("\n訓練完成！")
    save_path = os.path.join(results.save_dir, "weights", "best.pt")
    print(f"最佳模型權重檔路徑為: {save_path}")