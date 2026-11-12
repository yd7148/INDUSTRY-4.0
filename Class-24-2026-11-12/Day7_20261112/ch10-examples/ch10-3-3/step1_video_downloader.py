import requests

# 影片檔的 URL 網址
url = "https://github.com/fchart/test/raw/refs/heads/master/media/starwars.mp4"
# 下載的檔名
output_file = "starwars.mp4"

# 模擬瀏覽器 User-Agent，避免被伺服器阻擋
headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
}

try:
    # 使用 stream=True 進行串流傳輸，allow_redirects=True 自動處理重導向
    response = requests.get(url, headers=headers, stream=True, allow_redirects=True, timeout=15)
    response.raise_for_status()  # 若 HTTP 狀態碼非 200 (如 404, 500) 則丟出異常

    # 以 chunk 區塊方式寫入檔案，節省記憶體並確保完整下載
    with open(output_file, "wb") as file:
        for chunk in response.iter_content(chunk_size=8192):
            if chunk:
                file.write(chunk)

    print(f"影片已順利下載並儲存為: {output_file}")

except requests.exceptions.RequestException as e:
    print(f"下載失敗，錯誤訊息: {e}")