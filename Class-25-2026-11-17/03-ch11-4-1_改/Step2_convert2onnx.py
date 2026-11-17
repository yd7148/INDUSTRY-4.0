from ultralytics import YOLO
import torch
import numpy as np
import random
import os

modelPath = "best.pt"   # YOLOv8客製化模型檔的路徑
# -------------------------------------------
# 固定所有隨機性來源
seed = 42
random.seed(seed)
np.random.seed(seed)
torch.manual_seed(seed)
torch.cuda.manual_seed(seed)
torch.cuda.manual_seed_all(seed)
os.environ['PYTHONHASHSEED'] = str(seed)
torch.backends.cudnn.deterministic = True
torch.backends.cudnn.benchmark = False
# Load custom model
model = YOLO(modelPath)      
# Export to ONNX format
model.export(
    format="onnx",           # 指定格式為 ONNX
    imgsz=[640, 640],        # 指定輸入尺寸 (如有需要可調整)
    half=False,              # 是否使用 FP16 精度 (設為 True 可加速但可能降低準確度)
    dynamic=False,           # 啟用動態軸（適應不同的輸入尺寸）
    simplify=False,          # 簡化 ONNX 圖
    opset=12,                # ONNX opset 版本
    verbose=True             # 顯示詳細輸出信息
)  
# Get class names
class_names = model.names
print(class_names)
# Write class names to classes.txt
with open("classes.txt", "w") as f:
    for class_idx in class_names:
        f.write(f"{class_names[class_idx]}\n")

print(f"成功匯出 {modelPath} 成 {modelPath.replace('.pt', '.onnx')} , 並且建立 classes.txt...")
# Python 3.11版需安裝的Python套件:
# =================================
# pip install onnx==1.17.0
# pip install onnxruntime==1.21.0
# pip install onnxslim==0.1.48
# Python 3.10版需安裝的Python套件:
# =================================
# pip install onnx==1.16.0
# pip install onnxruntime==1.21.0
# pip install onnxslim==0.1.48