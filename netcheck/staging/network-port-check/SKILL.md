---
name: network-port-check
description: 檢查本機對外網路連線狀態：哪些 TCP port 通、哪些被防火牆擋、遠端服務（RDP/SSH/VNC）能否接通、有哪些網站被擋、TLS 是否被中間人攔截、以及上下載頻寬與延遲。產出繁體中文 Markdown 報告。Use when asked to "測試對外PORT", "哪些 port 通", "哪些服務可以接通", "如RDP", "哪些網站會被擋", "網路被擋", "防火牆", "連不到外部", "SSH 連不上", "遠端桌面", "ping 測試", "網速測試", "test outbound ports", "is RDP reachable", "which sites are blocked", "check network restrictions", "test bandwidth", or to diagnose an outbound connection issue.
license: MIT
compatibility: opencode
metadata:
  audience: opencode agents
  workflow: network-port-check
  languages: zh-TW
  platform: Windows
  requires: PowerShell 5.1+
---

# network-port-check — 對外網路連線檢查

盤點本機**對外**（outbound）網路環境：哪些 TCP port 可連、哪些服務（尤其 RDP/SSH）
能否接通、哪些網站被擋、TLS 是否遭中間人破解、以及頻寬延遲。產出繁中 Markdown 報告。

**無需安裝任何套件** — 純 PowerShell 內建功能 + Windows 內建 `curl.exe`。

---

## 快速開始

```powershell
# 全部檢查 + 產生報告（一鍵）
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\run-all.ps1

# 只跑單項
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\test-ports.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\test-services.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\test-websites.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\test-tls.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\test-bandwidth.ps1
```

常用參數：

```powershell
# 自訂要測的 port 與額外主機
.\scripts\test-ports.ps1 -Ports 22,80,443,3389,8080 -ExtraHosts "example.com,10.0.0.5"

# 只測指定網站（自訂清單）
.\scripts\test-websites.ps1 -File .\sites.json     # [{"n":"名稱","u":"https://..."}]

# 指定 TLS 主機
.\scripts\test-tls.ps1 -Hosts "www.google.com,github.com"

# 報告指定輸出路徑 / 跳過頻寬測試
.\scripts\run-all.ps1 -OutFile D:\報告.md -SkipBandwidth
```

> ⚠️ 透過 `powershell -File` 傳入逗號分隔的陣列時，PowerShell 會把整串當成**單一元素**。
> 本 skill 的腳本已自行再切一次，直接用逗號即可。

---

## 五項檢查

| 腳本 | 檢查內容 | 產出 |
|------|----------|------|
| `test-ports.ps1` | 27 個常用 port × 7 個目標的連通性矩陣 | 開/封 port 清單 |
| `test-services.ps1` | 本機 RDP Server 狀態、3389/22/5900/9418、443 替代通道 | 可用通道清單 |
| `test-websites.ps1` | 51 個網站，**正確區分「有回應」與「真封鎖」** | 封鎖網站清單 |
| `test-tls.ps1` | 憑證簽發者 → 偵測企業 MITM / SSL inspection | 是否遭攔截 |
| `test-bandwidth.ps1` | 上/下載頻寬、TCP 延遲、ICMP ping、tracert | 頻寬與路由 |

---

## 最重要的判讀原則

> **HTTP 4xx／5xx ≠ 被封鎖。**

伺服器回 `401` / `403` / `404` / `405` / `429` 代表**它確實有回應**，
TCP 連線與 TLS 握手都成功了，這是「網路可達」，只是 HTTP 層面需要認證、
被 Cloudflare 擋機器人、或路徑不存在。**只有完全沒有 HTTP 回應才可能是網路封鎖。**

`test-websites.ps1` 對此做兩層驗證：

1. 先用 `Invoke-WebRequest` 取得 HTTP 回應；
2. 若**完全沒有** HTTP 回應，再用**裸 TCP 443 握手**複驗，
   排除 PowerShell 語意（HEAD 不支援、UA 被擋、憑證問題）造成的**假陽性**。

輸出分四級：

| 標記 | 意義 |
|------|------|
| `[ OK ]` | 2xx，完全正常 |
| `[REACH]` | 伺服器有回應（4xx/5xx），**網路可達，非封鎖** |
| `[BLOCK]` | 真的連不上（裸 TCP 443 也失敗） |
| `[DNS!!]` | 網域無法解析（可能網域本來就不存在，不是被擋） |

完整判讀流程見 [reference/interpretation.md](reference/interpretation.md)。

---

## 典型結論與解方

當矩陣顯示只有 `53/80/443` 通、而 `22/3389/5900` 全封時，這是
**白名單型 ACL 防火牆**。此時：

| 需求 | 能否直接做 | 解方（皆走 443） |
|------|-----------|------------------|
| 遠端桌面連**入**本機 | ❌ | 需 IT 開啟 RDP；或用 Tailscale |
| 遠端桌面連**出**到別台 | ❌ | Tailscale / ZeroTier / AWS SSM / Google IAP |
| SSH 到外部主機 | ❌ | `ssh -p 443 user@host`（若該主機支援） |
| Git push over SSH | ❌ | 改 HTTPS，或用 `insteadOf` 轉 443：<br>`git config --global url."https://ssh.github.com:443".insteadOf "git@github.com:"` |
| 裝套件 / 拉 image | ✅ | npm / PyPI / Docker Hub 通常都走 443 |
| 對外開放本機服務 | ❌ | ngrok / Cloudflare Tunnel / Twingate |

`test-services.ps1` 會**實際探測**上述通道工具的 443 是否可用，並列出可行的清單，
不要憑記憶推薦——同一台機器上 A 通 B 不通是常見的。

---

## 環境陷阱（實測踩過，請勿重蹈）

### 1. 絕對不要用 `Test-NetConnection` 跑 port 矩陣
它逐一同步等待，27 port × 7 主機 × 4 秒 ≈ **12.5 分鐘**，必然超時。
正確做法是一次 `BeginConnect` 開全部連線，再用 `WaitHandle::WaitAll` 批次等待
（本 skill 分批 60 個，相容 .NET 句柄數上限），全數約 5 秒完成。

### 2. `Resolve-DnsName` 對 IP 文字會失敗
`Resolve-DnsName 8.8.8.8` 直接回錯，會被誤判成「DNS 解析失敗」。
必須先 `[Net.IPAddress]::TryParse()` 判斷是否已是 IP。

### 3. `$ips[0]` 會取到「第一個字元」
```powershell
$ips = Resolve-DnsName h -Type A | ... | Select -Expand IPAddress   # 單一結果
return $ips[0]        # ❌ "20.1.2.3"[0] => "2"  ← 拿到字元，不是 IP！
return $ips | Select -First 1     # ✅
```
PowerShell 會把單一結果 unroll 成**字串**，字串的 `[0]` 是字元索引。
這個 bug 會讓所有 443 探測**全部誤判為 BLOCKED**。

### 4. `.ps1` 含中文必須存成 UTF-8 **with BOM**
PowerShell 5.1 讀 `.ps1` 時，**沒有 BOM 就用系統 ANSI 編碼（CP950）解讀**，
中文會變成亂碼甚至導致語法錯誤（括號、字串被截斷）。
存檔務必用 `UTF8Encoding($true)`（帶 BOM）。

### 5. 單設 `[Console]::OutputEncoding` 無效
PowerShell 5.1 在 stdout 被 **redirect** 時，仍以系統 ANSI 編碼輸出，
`[Console]::OutputEncoding = [Text.Encoding]::UTF8` 對被擷取的輸出**不生效**。
必須改寫 `Console.Out`：

```powershell
$e = New-Object System.Text.UTF8Encoding $false
$w = New-Object System.IO.StreamWriter([Console]::OpenStandardOutput(), $e)
$w.AutoFlush = $true
[Console]::SetOut($w)
```
本 skill 每個腳本開頭都放了這段 bootstrap。

### 6. 擷取輸出時不要加 `| Out-String`
外層 shell 會把子行程輸出重新編碼，中文又會壞掉。
直接讓輸出過來，或在外層先設 `$OutputEncoding`。

### 7. 上傳測速要用 `%{speed_upload}` / `%{size_upload}`
`curl -w` 的 download 與 upload 指標是不同欄位，
拿 `%{speed_download}` 量上傳會得到 `0`，誤判為上傳失敗。

### 8. 部分歐洲／測速主機不回應
`speed.hetzner.de`、`speed.gcore.com` 偶爾零回應（對特定地區封鎖連線），
這**不代表**整體網路有問題。至少要有一個測速站成功才好下結論。

---

## 判讀速查

| 觀察到的現象 | 真正的意思 |
|---|---|
| 只有 53/80/443 通 | 白名單 ACL 防火牆 |
| 3389 不通但本機 listener 也沒開 | 雙重問題：對外封鎖 + 本機 RDP 未啟用 |
| 網站回 401/403 | 正常，伺服器有回應 |
| `rdweb.*.microsoft.com` 無 A 記錄 | 該網域本來就不存在，不是被擋 |
| 憑證 Issuer 出現公司名稱 | 有 SSL inspection，TLS 已被解密 |
| ICMP 不回應但 TCP 443 通 | 正常，ICMP 常被過濾 |

---

## 檔案

| 檔案 | 說明 |
|------|------|
| `scripts/run-all.ps1` | 一鍵跑完五項並產生 Markdown 報告 |
| `scripts/test-ports.ps1` | 對外 port 矩陣（並行） |
| `scripts/test-services.ps1` | RDP／SSH／VNC／443 通道 |
| `scripts/test-websites.ps1` | 網站可達性 + 封鎖判定 |
| `scripts/test-tls.ps1` | TLS 憑證 / MITM 偵測 |
| `scripts/test-bandwidth.ps1` | 頻寬 / 延遲 / tracert |
| `reference/interpretation.md` | 完整判讀流程與決策樹 |
| `reference/sample-report.md` | 實測報告範例 |
