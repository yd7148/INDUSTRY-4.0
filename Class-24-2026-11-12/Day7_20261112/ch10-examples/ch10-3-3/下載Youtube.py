import yt_dlp

# 將網址替換為 IG、FB 或 X 的公開影片 / 貼文網址
url = "https://youtube.com/xxxxx"
# url = "https://www.facebook.com/watch/?v=YOUR_VIDEO_ID"
# url = "https://x.com/username/status/YOUR_STATUS_ID"

ydl_opts = {
    # 自動選擇最高畫質並儲存為 mp4
    'format': 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best',
    # 儲存檔名格式：[平台名稱]_影片ID.mp4
    'outtmpl': '%(extractor)s_%(id)s.%(ext)s',
}

try:
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        print("開始下載社群平台影片...")
        ydl.download([url])
    print("下載完成！")
except Exception as e:
    print(f"下載失敗: {e}")