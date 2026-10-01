# 對外網路連線測試報告

測試主機：`172.16.7.115/24`（gateway `172.16.7.1`，DNS `168.95.1.1` HiNet）
測試時間：2026-09-29
測試工具：PowerShell + `curl.exe`

---

## 1. 環境

| 項目 | 值 |
|---|---|
| 內網 IP | `172.16.7.115/24` |
| 預設閘道 | `172.16.7.1` |
| DNS | `168.95.1.1` (HiNet) |
| 系統 Proxy | **未設定**（ProxyEnable=0，無 PAC） |
| HTTP Proxy 環境變數 | 無（僅 `NO_PROXY`） |
| 上網路徑 | HiNet → 168.95.210.42 → 220.128.2.105 → 203.75.230.129 → ISP peering |

---

## 2. 對外 PORT 結論

### 只有 3 個 Port 通

| Port | 服務 | 狀態 |
|---|---|---|
| **53** | DNS | 通過 |
| **80** | HTTP | 通過 |
| **443** | HTTPS | 通過 |

### 全部被封鎖（所有目標）

```
21   22    25    110   123   143   389   445   587   636
993  995   1433  1521  3306  3389  5432  5900  5985  6379
8080 8443  8888  27017
```

> 這是典型的 **ACL 白名單型防火牆**：只放行 DNS + Web，資料庫與遠端管理協定全封。
> 注意：區網 `172.16.7.1:22` 反而是開的（SSH on gateway），但對外 22 不通。

---

## 3. RDP (3389) 測試 — **不通**

### 對外 3389 全部封鎖
```
3389 -> 8.8.8.8, 1.1.1.1, 13.107.6.1, 20.36.36.36  = BLOCKED
3389 -> 172.16.7.1 / 172.16.7.2 / 192.168.1.1     = BLOCKED
```

### 本機 RDP Server 狀態
| 項目 | 值 | 意義 |
|---|---|---|
| 3389 listener | **無** | 未監聽 |
| `fDenyTSConnections` | `1` | **RDP 停用** |
| TermService 服務 | `Stopped` | 服務未啟動 |
| 防火牆 RDP 規則 | `0` 條啟用 | 規則不存在 |

> 結論：這台機器**不能當 RDP 主機被連入**（需管理員權限開啟）。

### 替代方案（走 443，都通）
| 服務 | 443 | 用途 |
|---|---|---|
| Tailscale DERP | ✅ | 推薦，可做 RDP 類似遠端桌面 |
| AWS SSM Session Manager | ✅ | 雲端主機免公開 3389 |
| Google Cloud IAP | ✅ | TCP forward 到內部服務 |
| Twingate / ZeroTier / ngrok | ✅ | 零信任通道 |
| Azure Bastion | ❌ | 該 host 無此服務 |

---

## 4. SSH / Git 傳輸

| Port | 目標 | 狀態 |
|---|---|---|
| 22 | github.com | ❌ 封鎖 |
| 22 | speed.hetzner.de | ❌ 封鎖 |
| **443** | **ssh.github.com** | ✅ **通** |
| 9418 | github.com (git://) | ❌ 封鎖 |

> **可行解**：`git config --global url."https://ssh.github.com:443".insteadOf "git@github.com:"`
> HTTPS clone（`https://github.com/...`）本來就可用。

---

## 5. 網站封鎖狀況

### ✅ 完全正常（53 個站全數 HTTP 200 級回應）

**開發 / 程式**
GitHub、GitLab、Bitbucket、npm registry、PyPI、HuggingFace、Docker Hub、OpenCode、MS Learn

**Google 全家桶**
Google、YouTube、Gmail、Drive、Translate、Maps

**AI**
OpenAI (chatgpt.com)、Anthropic (claude.ai)、Perplexity

**生產力 / 社交**
Notion、Figma、Slack、Zoom、Teams、Line、Telegram、Discord、TikTok、Instagram、X、LinkedIn、Reddit、Wikipedia

**其他**
Microsoft 365、OneDrive、Cloudflare、Yahoo TW/JP、Naver、Baidu、163、ITRI、Steam、Spotify、Binance

### ⚠️ 回應非 200，但**網路可達**（伺服器正常回應，非封鎖）

| 站 | Code | 說明 |
|---|---|---|
| chatgpt.com | 403 | 需登入 / Cloudflare 保護 |
| claude.ai | 403 | 同上 |
| perplexity.ai | 403 | 同上 |
| canva.com | 403 | 同上 |
| stackoverflow.com | 403 | Cloudflare 機器人阻擋 |
| coinbase.com | 403 | 地區 / 機器人限制 |
| store.epicgames.com | 403 | Cloudflare |
| anaconda.org | 403 | Cloudflare |
| api.openai.com | 401 | **正常**（缺 API key） |
| api.anthropic.com | 405 | **正常**（HTTP method 不對） |
| registry-1.docker.io | 401 | **正常**（Docker auth token 流程） |

> 這些都完成了 TCP + TLS 握手，**不是網路層封鎖**。瀏覽器開啟通常正常。

### ❌ 唯一真正有問題的

| 項目 | 狀態 | 影響 |
|---|---|---|
| `rdweb.westsus2.microsoft.com` | **DNS 解析失敗** | 該網域 HiNet DNS 不存在此記錄，非封鎖 |
| Hetzner / Gcore 測速主機 | TCP 無回應 | 部分歐洲主機選擇性不回應，非全面封鎖 |

> **結論：沒有任何網站被政策性封鎖。** 含成人網站（Binance 交易所、Pornhub 皆 200）。

---

## 6. TLS / 中間人檢測

無 TLS interception，憑證簽發者皆為原廠 CA：

| 主機 | 簽發者 |
|---|---|
| www.google.com | Google Trust Services (WR2) |
| api.anthropic.com | Google Trust Services (WE1) |
| github.com | Sectigo DV E36 |
| www.microsoft.com | Microsoft TLS G2 RSA CA OCSP 04 |
| registry.npmjs.org | Google Trust Services (WE1) |
| huggingface.co | Amazon RSA 2048 M01 |

> 無企業級 MITM 根憑證安裝 → **端到端加密未被監控**。

---

## 7. 頻寬 / 延遲

### 傳輸量
| 方向 | 速率 |
|---|---|
| **下載** | **~400–420 Mbps** |
| **上傳** | **~168 Mbps** |

### 延遲
| 目標 | RTT |
|---|---|
| 1.1.1.1 | **1.3 ms** |
| 8.8.8.8 | 3.7 ms |
| www.google.com | 2.3 ms |
| github.com | 31.7 ms |

> 下載 400 Mbps = 商業光纖水準。延遲極低，ISP peering 正常。

---

## 8. 實務建議

| 需求 | 狀態 | 解方 |
|---|---|---|
| 遠端桌面連入本機 | ❌ 不行 | 需 IT 開啟 RDP；或用 Tailscale（443 已通） |
| 遠端桌面連出到別台 | ❌ 22/3389 封 | 用 Tailscale / ZeroTier / AWS SSM / IAP 走 443 |
| SSH 到外部主機 | ❌ 22 封 | 走 443：`ssh -p 443 user@ssh.github.com` |
| Git push over SSH | ❌ 22 封 | 改 HTTPS，或用 `insteadOf` 轉 443 |
| 裝套件 / 拉 image | ✅ 可以 | npm / PyPI / Docker Hub 全通 |
| 對外開放本機服務 | ❌ 不行 | 用 ngrok / Cloudflare Tunnel / Twingate（443 已通） |

---

## 附：測試腳本

| 檔案 | 用途 |
|---|---|
| `netcheck/port-test.ps1` | 對外 Port 矩陣 |
| `netcheck/web-test.ps1` | 網站可用性初篩 |
| `netcheck/recheck.ps1` | GET 重驗 + TLS 憑證 |
| `netcheck/rdp-test.ps1` | RDP 深度測試 |
| `netcheck/site-sweep.ps1` | 擴充網站掃描（56 站） |
| `netcheck/verify-speed.ps1` | 驗證 + 初速測 |
| `netcheck/speed.ps1` | 頻寬 / ping / tracert |
| `netcheck/speed2.ps1` | 修正頻寬 + VPN 通道可達性 |
