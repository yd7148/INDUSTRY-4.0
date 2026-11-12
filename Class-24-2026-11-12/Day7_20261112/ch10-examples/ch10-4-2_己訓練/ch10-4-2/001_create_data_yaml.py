import os

# 1. 指定 YAML 內容
yaml_content = """path: D:/IIOT/課程資料/Node-RED AI 學習/ch10-examples/ch10-4-2
train: train/images
val: val/images

names:
  0: Millennium Falcon
  1: Tie Fighter
"""

# 2. 指定存檔目錄與檔名
target_dir = r"D:\IIOT\課程資料\Node-RED AI 學習\ch10-examples\ch10-4-2"
file_path = os.path.join(target_dir, "data.yaml")

# 3. 如果目錄不存在則自動建立
os.makedirs(target_dir, exist_ok=True)

# 4. 寫入 data.yaml 檔案
with open(file_path, "w", encoding="utf-8") as f:
    f.write(yaml_content)

print(f"成功建立 YAML 檔！檔案路徑：{file_path}")