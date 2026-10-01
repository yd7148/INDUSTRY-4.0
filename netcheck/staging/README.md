# OpenCode_skill

OpenCode 本機 Skills 收藏庫。所有 skill 皆為 MIT 授權，適用於 opencode agents。

> 📖 每支 skill 的完整功能、適用時機、運作流程與產出，請參閱 **[SKILLS.md](SKILLS.md)**。

## 功能分類

所有 36 個 skill 資料夾直接放在 Repo 根目錄；下方依功能分成 8 類，可直接點選。

| 分類代號 | 分類 | 數量 |
|---|---|---:|
| [engineering](#工程模擬與-cad) | 工程模擬與 CAD | 6 |
| [documents](#文件與會議紀錄) | 文件與會議紀錄 | 4 |
| [exams](#考試與解題) | 考試與解題 | 3 |
| [media](#影音下載、處理與分析) | 影音下載、處理與分析 | 9 |
| [automation](#瀏覽器與桌面自動化) | 瀏覽器與桌面自動化 | 4 |
| [business](#辦公、求職與商務) | 辦公、求職與商務 | 4 |
| [development](#開發工具與-skill-管理) | 開發工具與 Skill 管理 | 3 |
| [graphics](#圖像生成與桌寵) | 圖像生成與桌寵 | 3 |

### 工程模擬與 CAD

| Skill | 用途 | 依賴／平台 |
|---|---|---|
| [comsol-analyzer](comsol-analyzer/SKILL.md) | 分析 COMSOL Multiphysics .mph 模型檔案 | 無額外依賴（`.mph` 為 ZIP，免裝 COMSOL） |
| [comsol-celsius-export](comsol-celsius-export/SKILL.md) | COMSOL 熱場另存攝氏版本並匯出完整時間動畫 | COMSOL；保留原始 MPH 與媒體檔 |
| [comsol-gpu-env](comsol-gpu-env/SKILL.md) | COMSOL 6.4 GPU/系統 CUDA 環境設定與驗證（RTX 5080 Blackwell，切換系統 CUDA 12.9.1、comsol.prefs、Computer Use GUI 操作與無 GUI 驗證） | COMSOL 6.4 + 系統 CUDA 12.9.1（Windows）；GUI 操作用 opencode Computer Use |
| [comsol-linsolver-benchmark](comsol-linsolver-benchmark/SKILL.md) | COMSOL 線性求解器 A/B 基準測試（MUMPS vs cuDSS vs PARDISO）：改 `.mph` 內嵌 `dmodel.xml` 求解器節點 + comsolbatch 固定預算求解 + nvidia-smi GPU 監控 | Python（zipfile）+ COMSOL 6.4 comsolbatch（Windows） |
| [comsol-mcp](comsol-mcp/SKILL.md) | 透過 opencode 操作 COMSOL 6.4（啟動規則、建模→求解→評估序列與 API 陷阱） | Python venv（mph + jpype1）+ COMSOL MCP server（Windows） |
| [dwg-to-dxf](dwg-to-dxf/SKILL.md) | 將 DWG 轉成 DXF 並進行幾何/圖層分析 | ODA File Converter + Python `ezdxf`（Windows） |

### 文件與會議紀錄

| Skill | 用途 | 依賴／平台 |
|---|---|---|
| [image-to-pdf](image-to-pdf/SKILL.md) | 將資料夾內圖片合併成單一 PDF（每頁一張、依檔名排序） | Python + Pillow |
| [md-to-pdf](md-to-pdf/SKILL.md) | 將繁體中文 Markdown 渲染成排版精美的 A4 PDF | Python + Pillow + 中文字體（macOS/Windows 自動偵測） |
| [meeting-transcript-summary](meeting-transcript-summary/SKILL.md) | 原始時間戳會議逐字稿彙總成詳盡繁中主管會議紀錄 | 無（opencode 內建工具） |
| [pdf-reader](pdf-reader/SKILL.md) | 讀取 PDF（文字抽取 / 掃描 OCR）輸出繁中 Markdown 摘要 | Python venv：PyMuPDF、RapidOCR、opencc |

### 考試與解題

| Skill | 用途 | 依賴／平台 |
|---|---|---|
| [pdf-exam-extractor](pdf-exam-extractor/SKILL.md) | 考題 PDF 逐題裁剪成圖 + EasyOCR 轉 Markdown | Python：pymupdf、pdfplumber、easyocr、opencv-python |
| [taipower-exam-report](taipower-exam-report/SKILL.md) | 國營事業/台電考題整份詳細解答（VLM 元件抽取 + SPICE 模擬 + 官方答案比對） | Python venv：Qwen2.5-VL（CUDA）+ ngspice/PySpice（Windows） |
| [taipower-exam-solver](taipower-exam-solver/SKILL.md) | 國營事業招考 PDF 考題、官方解答與逐步解題 | Python `pymupdf` + 台電官網解答 PDF |

### 影音下載、處理與分析

| Skill | 用途 | 依賴／平台 |
|---|---|---|
| [on24-video-download](on24-video-download/SKILL.md) | 下載 ON24 研討會影片、投影片與字幕 | curl + ffmpeg + Python |
| [takeout-exif-merge](takeout-exif-merge/SKILL.md) | 將 Google 相簿 Takeout JSON EXIF 合併回同名媒體檔 | Python 3 + ExifTool |
| [tts](tts/SKILL.md) | 用 edge-tts 將文字轉成繁體中文等語音檔（mp3） | Python + `edge-tts` |
| [v2t-report-summary](v2t-report-summary/SKILL.md) | 彙總影片分析報告（OCR × Whisper × GitHub）成繁體中文摘要 | 無（opencode 內建工具） |
| [video-2x-speed](video-2x-speed/SKILL.md) | 倍速影片處理（時間軸慣例） | ffmpeg + `yt-dlp` |
| [video-class-pipeline](video-class-pipeline/SKILL.md) | 課程影片批式分析（OCR × Whisper × 關鍵幀 PDF）與裁切/2倍速 | Python venv：paddleocr（PP-OCRv5，cu129）、whisper、opencv + ffmpeg（NVENC） |
| [video2text](video2text/SKILL.md) | 分析錄影影片 → 雙語 Markdown 報告 + 關鍵幀 PDF | Python venv：optimum-intel、faster-whisper、rapidocr-onnxruntime 等 |
| [yt-batch-download](yt-batch-download/SKILL.md) | 批次下載 YouTube 影片（1080p） | Python 3.13+、`yt-dlp`、`browser_cookie3`、ffmpeg、deno |
| [yt-upload](yt-upload/SKILL.md) | 透過 Playwright 上傳並公開發布 YouTube 影片 | Playwright |

### 瀏覽器與桌面自動化

| Skill | 用途 | 依賴／平台 |
|---|---|---|
| [browser-control](browser-control/SKILL.md) | Drive 使用者既有的 Chromium 瀏覽器（確定性 Playwright：inspect/act/verify、handoff 2FA/CAPTCHA、錄影、驗證過的 network capture） | `browser-control` CLI / MCP server |
| [open-computer-use](open-computer-use/SKILL.md) | Open Computer Use（macOS/Linux/Windows 的開源 Computer Use MCP）安裝、設定與操作 | `open-computer-use` / `ocu` CLI（npm，macOS 14+） |
| [web-tools](web-tools/SKILL.md) | 本機網頁工具環境筆記（Crawl4AI / Webwright） | 參考用 |
| [webwright](webwright/SKILL.md) | 瀏覽器 agent（code-as-action，Playwright 開 Firefox） | Python playwright + Firefox（無 API key） |

### 辦公、求職與商務

| Skill | 用途 | 依賴／平台 |
|---|---|---|
| [cv-job-application](cv-job-application/SKILL.md) | 中華電信／台積電線上履歷自動投遞（rmis.cht.com.tw 報名表填寫、附件上傳、狀態檢核、沿用保存的 Chrome 登入） | Playwright CDP + ddddocr + EasyOCR + pymupdf + fpdf2 + python-pptx（Windows） |
| [hcl-notes-forward](hcl-notes-forward/SKILL.md) | HCL Notes 公布函自動轉寄＋成功後刪除原信；也支援信箱匯出分析／讀取加密信件 | Windows + HCL Notes client + Python/Pillow；可用 PyInstaller 打包 exe |
| [taobao-cost-fill](taobao-cost-fill/SKILL.md) | 依訂單卡片填寫「淘寶費用計算明細」R0 樣板並存成 R1 | Python + `openpyxl` |
| [taobao-order-extract](taobao-order-extract/SKILL.md) | 從淘寶訂單 Excel 提取訂單資料並比對物流重量 | Python + `openpyxl` |

### 開發工具與 Skill 管理

| Skill | 用途 | 依賴／平台 |
|---|---|---|
| [github-skill-sync](github-skill-sync/SKILL.md) | 同步本機 skills 與本 GitHub 收藏庫（雙向） | git + robocopy（Windows 同步範例） |
| [network-port-check](network-port-check/SKILL.md) | 對外網路連線檢查：port 矩陣、RDP/SSH 可否接通、哪些網站被擋、TLS 是否 MITM、上下載頻寬 | 無依賴（PowerShell 5.1 + 內建 `curl.exe`） |
| [opencode-session-auto-name](opencode-session-auto-name/SKILL.md) | 讓 opencode session 標題自動以「第一個 prompt 的總結」命名（plugin 已裝全域） | 無（純規則式，0 Token） |

### 圖像生成與桌寵

| Skill | 用途 | 依賴／平台 |
|---|---|---|
| [mate-engine](mate-engine/SKILL.md) | Mate Engine（免費輕量桌面寵物 / Desktop Mate 替代品）資訊與檔案下載（唯一來源：https://github.com/shinyflvre/Mate-Engine） | 無（下載 GitHub Release ZIP 後執行 `MateEngineX.exe`） |
| [mate-engine-anim-patch](mate-engine-anim-patch/SKILL.md) | 擴充已編譯 Unity 的 Mate Engine X 動作數量（改寫 DLL 中 Idle/Dance 輪播常數，讓 BlendTree 全部動畫啟用） | Python（dnfile/dncil + UnityPy）+ Mono.Cecil + 內建 csc（Windows） |
| [sd-webui-vae-fix](sd-webui-vae-fix/SKILL.md) | 修復 A1111 檢查點/VAE「無法切換」（diffusers→LDM VAE 格式修復） | WebUI 內建 python（torch + safetensors） |

## 安裝

Repo 路徑為 `<skill-name>/`。例如根目錄的 `pdf-reader/` 安裝成 `skills/pdf-reader/`。

將任一 skill 資料夾複製到 `~/.config/opencode/skills/<skill-name>/`（或 `.opencode/skills/<skill-name>/`）即可使用。

各 skill 的 Python 依賴建議安裝於**各 skill 資料夾專用 venv**（`<skill>/.venv`），不會影響系統全域 Python：

```bash
cd ~/.config/opencode/skills/<skill-name>
python3 -m venv .venv
.venv/bin/pip install <所需套件>
```

> 註：repo 內容同時適用 Windows（PowerShell 5.1，`py` launcher）與 macOS。`md-to-pdf` 已內建中文字體自動偵測，macOS 使用 STHeiti、Windows 使用微軟正黑體（msjh.ttc）。

> **HCL Notes 公布函自動轉寄**：`hcl-notes-forward` 已整理成可移植 skill。其他已安裝 HCL Notes 的 Windows 電腦可安裝此 skill 後使用；首次執行請先跑 `scripts\run_hcl_notes_forwarder.cmd --dry-run --debug`，確認 Notes 視窗/DPI/通訊錄群組位置一致。正式執行預設會在成功轉寄後刪除原信。

## 依賴／平台總覽

- **無依賴**：`comsol-analyzer`、`v2t-report-summary`、`meeting-transcript-summary`、`mate-engine`、`opencode-session-auto-name`、`network-port-check`（PowerShell 5.1 + 內建 `curl.exe`）
- **純 Python（跨平台）**：`taobao-order-extract`（openpyxl）、`taobao-cost-fill`（openpyxl）、`md-to-pdf`（Pillow）、`image-to-pdf`（Pillow）、`tts`（edge-tts）、`taipower-exam-solver`（pymupdf）、`pdf-reader`（PyMuPDF + RapidOCR + opencc）
- **需額外系統工具**：`dwg-to-dxf`（ODA Converter）、`video-2x-speed`（ffmpeg）、`yt-batch-download`（ffmpeg + deno）、`yt-upload`（Playwright）、`takeout-exif-merge`（ExifTool）
- **需 COMSOL 環境**：`comsol-mcp`（本機 COMSOL 6.4 + COMSOL MCP server，Windows）、`comsol-linsolver-benchmark`（COMSOL 6.4 comsolbatch + nvidia-smi，Windows）、`comsol-gpu-env`（COMSOL 6.4 + 系統 CUDA 12.9.1，RTX 5080；GUI 操作用 opencode Computer Use）
- **重型機器學習（每個 skill 有專用 venv）**：`video2text`、`pdf-exam-extractor`、`video-class-pipeline`、`taipower-exam-report`
- **需 WebUI 環境**：`sd-webui-vae-fix`（用 webui 內建 Python：torch + safetensors，抽取本機大檢查點的 VAE 並以 `/sdapi/v1` API 驗證）
- **需 npm 全域工具**：`open-computer-use`（`npm i -g open-computer-use`，macOS 14+ 需授權 Accessibility + Screen Recording）
- **瀏覽器自動化 + OCR**：`cv-job-application`（Playwright CDP + ddddocr + EasyOCR，沿用 Chromium 設定檔保存登入，Windows）
- **HCL Notes UI 自動化**：`hcl-notes-forward`（HCL Notes client + Pillow 截圖；可選 RapidOCR；成功轉寄後刪原信；可 PyInstaller 打包 exe）
- **瀏覽器自動化**：`browser-control`（browser-control CLI / MCP，驅動使用者既有的 Chromium 瀏覽器，支援 handoff、錄影與 network capture）
- **已編譯 Unity 修改**：`mate-engine-anim-patch`（以 dnfile/dncil 反組譯 + UnityPy 驗證 BlendTree，Mono.Cecil 重寫 IL 常數，Windows）

## OpenCode 本機環境設定

本收藏庫對應的 opencode 環境（Desktop App）已做以下設定：

1. **LSP 精準開啟（方案 2）** — `opencode.jsonc` 啟用 `typescript`、`pyright`、`yaml-ls`、`bash` 四個語言伺服器；以使用者環境變數 `OPENCODE_EXPERIMENTAL_LSP_TOOL=true` 開啟 `lsp` 工具（定義跳轉／找參考／診斷回饋）。安裝：`npm i -g pyright`；TS 專案需各自 `npm i -D typescript`。
2. **TUI 外掛 oc-plugin-rainbow** — `tui.json` 啟用彩虹特效，套件已裝進 `~/.cache/opencode/node_modules`（v0.1.1）。微調：`Ctrl+P → Rainbow settings`。
3. **瀏覽器 MCP 固定 profile** — Playwright MCP 指定 `--user-data-dir=~/.cache/opencode-browser-profiles/playwright`，所有專案共用登入（解決「空帳號／未登入」）；chrome-devtools 維持 `--autoConnect` 沿用日常 Chrome 登入。
4. **Session 標題自動命名（opencode-auto-name）** — `opencode.jsonc` 加入 plugin 陣列 `["opencode-auto-name", { "template": "{firstMessage}", "maxLength": 50 }]`，新 session 標題自動取第一個 prompt 的首句總結；純規則式、0 Token。原理與替代方案比較見 skill `opencode-session-auto-name`。

> 三項修改後皆需**完全重啟** OpenCode。詳細設定、選項與驗證方式：見 **[SKILLS.md 附錄](SKILLS.md)**。

## 個人履歷網站維護

- [resume-cloudflare-maintenance](resume-cloudflare-maintenance/SKILL.md)：Resume 01 中英內容維護、保留舊版與 Cloudflare 靜態部署。

