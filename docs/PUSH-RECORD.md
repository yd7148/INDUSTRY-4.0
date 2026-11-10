# 推送紀錄與檢核報告（Push Record）

本文件記錄 `D:\INDUSTRY-4.0` 推送至 GitHub 的完整過程、驗證結果與後續維護注意事項。
每次重大推送請在文末「推送歷史」追加一列。

---

## 1. 本次推送摘要

| 項目 | 內容 |
|---|---|
| 執行時間 | 2026-11-10 18:51（UTC+08:00） |
| 來源路徑 | `D:\INDUSTRY-4.0` |
| 遠端倉庫 | <https://github.com/yd7148/INDUSTRY-4.0> |
| 分支 | `main` → `origin/main` |
| 推送前遠端 | `cc06860`（2026-11-05） |
| 推送後遠端 | `097b06c`；本文件修訂後以 `git ls-remote` 為準 |
| 推送範圍 | `cc06860..097b06c`（4 個 commit，Class-24 教材與文件） |
| 本次新增 | Class-24-2026-11-10（27 檔：授課筆記、`Day6_20261110.zip` 與解壓內容、`ch09-examples/` 7 個範例流程、`dog.jpg` 測試影像）、Class-23 `20261105-2.gx3` 更新、根 README／COURSE-MAP／SVG 更新 |
| 傳輸結果 | **成功**；GitHub 回報 `cc06860..097b06c  main -> main` |
| 遠端驗證 | `git ls-remote origin main` 回傳 `097b06c`，與本機 HEAD 一致 |
| 工作區狀態 | clean，`main` 與 `origin/main` 同點 |

```mermaid
flowchart LR
    A["推送前<br/>origin/main = cc06860"] --> B["本機提交 4 個 commit"]
    B --> C["git push origin main"]
    C --> D{"遠端回應"}
    D -->|成功| E["origin/main = 097b06c"]
    D -->|失敗| F["保留本機 commit<br/>排除後重試"]
    E --> G["ls-remote / 網頁雙重驗證"]
```

---

## 2. 提交歷史

```mermaid
gitGraph
    commit id: "456e770 10-09"
    commit id: "81a8823 10-13"
    commit id: "d44cba9 10-20"
    commit id: "7221366 10-22"
    commit id: "5809cc2 10-29 docs+Class20"
    commit id: "1461a53 10-29 Class21"
    commit id: "aaac432 10-29 push record"
    commit id: "463e28f 11-05 Class22"
    commit id: "d6cf742 11-05 Class23"
    commit id: "4ff1985 11-05 push record"
    commit id: "11daff8 11-05 SVG fix"
    commit id: "cc06860 11-05 timeline restyle"
    commit id: "0a186f8 11-10 Class24"
    commit id: "fd7fb8a 11-10 docs"
    commit id: "038b622 11-10 push record"
    commit id: "097b06c 11-10 dog.jpg"
```

| Commit | 日期時間 | 說明 |
|---|---|---|
| `456e770` | 2026-10-09 12:56 | 推送前遠端最新（Class-14） |
| `81a8823` | 2026-10-13 19:37 | 課程重新編號、新增 Class-16 |
| `d44cba9` | 2026-10-20 21:39 | 新增 Class-17、Class-18 |
| `7221366` | 2026-10-22 21:24 | 新增 Class-19（Node-RED、MQTT） |
| `5809cc2` | 2026-10-29 18:47 | 新增 Class-20、`README.md`、`docs/COURSE-MAP.md` |
| `1461a53` | 2026-10-29 21:24 | 新增 Class-21（Node-RED Flow、M2M） |
| `aaac432` | 2026-10-29 21:40 | 新增 `docs/PUSH-RECORD.md` |
| `463e28f` | 2026-11-05 | 新增 Class-22 Day5 壓縮包 |
| `d6cf742` | 2026-11-05 | 新增 Class-23 教材、各堂 README、SVG 圖表 |
| `4ff1985` | 2026-11-05 | 推送紀錄補上 Class-23 該列 |
| `11daff8` | 2026-11-05 | 修正 SVG 文字溢出、改為兩列版面 |
| `cc06860` | 2026-11-05 | 播放清單時間軸拆成上下半兩段 |
| `0a186f8` | 2026-11-10 18:51 | **新增 Class-24-2026-11-10（Node-RED AI／Teachable Machine）**，更新 Class-23 `20261105-2.gx3` |
| `fd7fb8a` | 2026-11-10 18:51 | 更新根 README、`docs/COURSE-MAP.md`、`docs/img/course-timeline.svg`（23 → 24 堂，播放清單 19 → 23 段） |
| `038b622` | 2026-11-10 18:53 | 推送紀錄補上 2026-11-10 該列與新的環境準備／檢核流程 |
| `097b06c` | 2026-11-10 18:59 | 補上 Class-24 測試影像 `dog.jpg`，同步更新該資料夾檔案清單 |

> 本次推送前本機已領先遠端 0 個 commit（`cc06860` 為雙方共同點），
> 推送範圍為本次新增的 2 個 commit。

---

## 3. 執行流程

```mermaid
sequenceDiagram
    autonumber
    participant U as 操作者
    participant G as 本機 Git
    participant H as GitHub
    U->>G: 檢查工作區與遠端差異
    G-->>U: origin/main = cc06860、工作區僅 Class-23 .gx3 修改與 Class-24 新增
    U->>G: git add（分兩批：教材 / 文件）
    U->>G: git commit（Class-24 教材 + .gx3）
    U->>G: git commit（README / COURSE-MAP / SVG）
    U->>H: 裝置碼授權（device flow，gh auth login --web）
    H-->>U: access token（scope: repo）
    U->>G: git push origin main
    G->>H: 上傳 2 個 commit
    H-->>G: cc06860..fd7fb8a main -> main
    U->>H: git ls-remote / 網頁驗證
    H-->>U: fd7fb8a（一致）
```

### 3.1 環境準備

本機未安裝 Git（`git` 不在 PATH），因此使用可攜版：

| 元件 | 版本 | 位置 |
|---|---|---|
| MinGit（可攜） | 2.56.0.4 64-bit | `%LOCALAPPDATA%\Temp\opencode\mingit` |
| GitHub CLI | 2.103.3 | `%LOCALAPPDATA%\Temp\opencode\gh` |
| 授權方式 | OAuth Device Flow（`gh auth login --web`） | scope `repo`，token 存放於 Windows 憑證管理員 |

> 本機 `git` 不在 PATH，`cmdkey` 無 GitHub 憑證，也沒有 SSH key；一律走 HTTPS。
> MinGit 自帶 `git-credential-manager`，但本機改用 `gh auth setup-git` 讓 git 透過 `gh` 取用 token。

### 3.2 實際指令

```powershell
# 0. 準備可攜版 git / gh（解壓即用）
$env:PATH = "$env:LOCALAPPDATA\Temp\opencode\mingit\cmd;$env:LOCALAPPDATA\Temp\opencode\gh\bin;$env:PATH"

# 1. 檢視狀態（含被忽略的大型檔案）
git -C D:\INDUSTRY-4.0 -c core.quotepath=false status --short --branch
git -C D:\INDUSTRY-4.0 rev-list --left-right --count origin/main...HEAD

# 2. 授權（裝置碼；token 進 Windows 憑證管理員，不落地到 repo）
gh auth login --web --hostname github.com --git-protocol https
gh auth setup-git

# 3. 加入與提交（教材與文件分兩批）
git -C D:\INDUSTRY-4.0 add -- "Class-24-2026-11-10" "Class-23-2026-11-05/20261105-2.gx3"
git -C D:\INDUSTRY-4.0 -c user.name="yd7148" -c user.email="yd7148@users.noreply.github.com" commit -m "..."
git -C D:\INDUSTRY-4.0 add -- "README.md" "docs/COURSE-MAP.md" "docs/img/course-timeline.svg"
git -C D:\INDUSTRY-4.0 -c user.name="yd7148" -c user.email="yd7148@users.noreply.github.com" commit -m "..."

# 4. 推送
$env:GIT_TERMINAL_PROMPT = "0"
git -C D:\INDUSTRY-4.0 push origin main

# 5. 驗證
git -C D:\INDUSTRY-4.0 ls-remote origin main
git -C D:\INDUSTRY-4.0 status --short --branch
```

---

## 4. 檢核清單

| # | 檢核項目 | 方法 | 結果 |
|:--:|---|---|:--:|
| 1 | 提交內容完整 | `git status --short` 無殘留未追蹤教材 | ✅ |
| 2 | 暫存檔未入庫 | `git status --ignored` 確認 `~$*.doc`、`desktop.ini` 被排除 | ✅（`~$ass-24-2026-11-10.doc` 未入庫） |
| 3 | 超過 100 MB 的檔案未入庫 | `git ls-tree -r -l` 檢查，最大為 96.02 MB | ✅ |
| 4 | 大型安裝包已排除 | 兩個 1.69 GB 的 GX Works3 更新包被 `.gitignore` 排除 | ✅ |
| 5 | Mermaid 語法可渲染 | 以 Mermaid 11 實際渲染 `README.md`、`COURSE-MAP.md`、`PUSH-RECORD.md`、Class-24 README | ✅ 15/15 |
| 6 | 文件無 TODO／佔位符 | 關鍵字掃描 `TODO`、`FIXME`、`待補` | ✅ |
| 7 | 遠端 HEAD 與本機一致 | `git ls-remote origin main` vs `git rev-parse HEAD` | ✅（皆為 `fd7fb8a`） |
| 8 | GitHub 網頁可見新 commit | 讀取 `/commits/main` 頁面 | ✅ |
| 9 | 推送後工作區乾淨 | `git status` | ✅ clean |
| 10 | 憑證未寫入版控 | 檢查 `.git/config`、`.git-credentials` | ✅（token 存於 Windows 憑證管理員） |
| 11 | 上課影片清單與實況一致 | 解析 YouTube 播放清單 `ytInitialData` 取得 23 段影片，逐支以 oEmbed 驗證可存取 | ✅ |
| 12 | 新增檔案已附說明 | 每個 `Class-XX` 資料夾均有 `README.md` | ✅（Class-24 已補） |

### 4.1 檔案規模

| 指標 | 數值 |
|---|---:|
| 追蹤檔案數 | 712 |
| 追蹤內容合計 | 2,584.6 MB |
| `.git` 目錄 | 555.9 MB |
| commit 總數 | 32 |
| 單檔最大 | 96.02 MB（`Class-22／23/Day5_20261103.zip`） |
| 本次推送檔案數 | 29（26 新增 + 3 修改） |

---

## 5. 已知警告與限制

| 項目 | 說明 | 建議 |
|---|---|---|
| 大檔案警告 `GH001` | GitHub 建議單檔 ≤ 50 MB；`Day5_20261103.zip` 為 96.02 MB（仍低於硬性上限 100 MB） | 後續同類工具改用 Releases 或 Git LFS |
| 倉庫總量 | 約 2.58 GB，已超出 GitHub 建議的 1 GB～5 GB 區間中段 | 定期清除重複 PDF，或改以文件索引取代複本 |
| 重複教材 | 多堂課各存一份相同 PDF／工具 | 見 [COURSE-MAP.md](COURSE-MAP.md) 第 5 節 |
| 憑證 | 本次使用 `gh` 裝置碼授權，token 存放於 Windows 憑證管理員 | 如需長期免互動，改用 Git Credential Manager 持久化 |
| Class-24 講義 PDF 重複 | `Node-RED AI_ch9.pdf`、`Node-RED AI應用_ch9_20261110.pdf` 同時存在於 `Class-24-2026-11-10/` 根目錄與 `Day6_20261110/` 內 | 根目錄副本當時被 PDF-XChange Viewer 鎖定無法刪除；檢視器關閉後可刪除根目錄副本 |

> 本次 `git push` 在 PowerShell 中因遠端進度輸出到 stderr 而顯示為錯誤物件，
> 但實際傳輸成功（`cc06860..fd7fb8a`），已用 `ls-remote` 與 GitHub 網頁雙重確認。

---

## 6. 推送歷史

| 日期 | 範圍 | 結果 | 備註 |
|---|---|---|---|
| 2026-10-29 | `456e770..1461a53` | 成功 | 新增 Class-20、Class-21、README 與 docs |
| 2026-10-29 | `1461a53..aaac432` | 成功 | 新增 `docs/PUSH-RECORD.md` |
| 2026-10-29 | `aaac432..`（本文件修訂） | 成功 | 更新最終 HEAD 與推送歷史 |
| 2026-11-05 | `463e28f..d6cf742` | 成功 | 上傳 Class-23-2026-11-05 完整教材（Modbus TCP／M2M）、Class-22 遺漏流程檔、23 份 Class README、根 README／COURSE-MAP 更新、docs/img 兩張 SVG 圖表（共 108 檔） |
| 2026-11-10 | `cc06860..fd7fb8a` | 成功 | 新增 Class-24-2026-11-10（Node-RED AI／Teachable Machine，26 檔）、更新 Class-23 `20261105-2.gx3`、根 README／COURSE-MAP／SVG 同步更新（29 檔） |
| 2026-11-10 | `fd7fb8a..097b06c` | 成功 | 補上推送紀錄更新與 Class-24 測試影像 `dog.jpg`（2 個 commit） |

---

## 7. 後續維護

```mermaid
flowchart TD
    A["新增一堂課教材"] --> B["放入 Class-NN-YYYY-MM-DD/"]
    B --> C["更新 README 課程索引"]
    C --> D["更新 docs/COURSE-MAP.md 清單"]
    D --> E["git add -A 並 commit"]
    E --> F{"單檔 > 100MB?"}
    F -->|是| G["改用 Releases／LFS<br/>或加入 .gitignore"]
    F -->|否| H["git push origin main"]
    G --> H
    H --> I["ls-remote 驗證"]
    I --> J["於本文件追加推送歷史"]
```

- 每次推送前後各執行一次 `git status --short --branch`。
- 新增教材後同步更新 `README.md` 的課程表與 `docs/COURSE-MAP.md`。
- 若加入 `.exe`、`.zip`，先確認大小；超過 100 MB 一律不進 Git。

---

*紀錄建立：2026-10-29｜最近更新：2026-11-10*
