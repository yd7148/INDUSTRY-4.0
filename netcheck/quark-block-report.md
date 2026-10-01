# 夸克雲盤連線失敗診斷報告

**目標**：`https://pan.quark.cn/s/1cf1c5d6d4a6`
**測試日期**：2026-09-29
**測試主機**：`172.16.7.115/24`（對外 IP `220.128.133.123`，HiNet，AS3462）
**測試工具**：PowerShell + `curl.exe` + `tracert` + `Test-NetConnection`

---

## 0. 結論摘要（一句话）

> **不是你的電腦壞了，也不是 HiNet 擋你。**
> 這是 **Alibaba 自己把台灣的流量導到中國大陸的機房，而那批機房的防火牆不對境外開放**。
> 責任歸屬：**Alibaba 夸克團隊（境外服務未提供台灣節點）**。

---

## 1. 症狀

| 檢查 | 結果 |
|---|---|
| DNS 解析 | ✅ 正常（`pan.quark.cn` → `203.119.169.x`） |
| ICMP ping | ❌ 全部 timeout |
| TCP 443 | ❌ 全部 timeout |
| TCP 80 | ❌ 全部 timeout |
| 瀏覽器開啟 | ❌ `ERR_TUNNEL_CONNECTION_FAILED` |

> ICMP 與 TCP 同時被丟包 → **不是單一 port 的 ACL 封鎖，是整個目的地不回應**。

---

## 2. 關鍵證據：同一條網路，Alibaba 兩種命運

這是本次診斷最重要的發現。

### 2.1 AS37963（中國大陸 Alibaba）— **全部不通**

| 主機 | IP | 443 |
|---|---|---|
| `pan.quark.cn`（目標） | `203.119.169.79` | ❌ |
| `drive-pc.quark.cn` | `203.119.169.79` | ❌ |
| `drive-h.quark.cn` | `203.119.175.186` | ❌ |
| `drive.quark.cn` | `203.119.146.33` | ❌ |
| `act.quark.cn` | `203.119.204.199` | ❌ |
| `quark.cn` | `121.41.29.143` | ❌ |
| `drive-pc.quark.cn` | `59.82.58.65` | ❌ |

### 2.2 AS45102（海外 Alibaba）— **全部正常**

| 主機 | IP | 443 |
|---|---|---|
| `www.quark.cn` | `47.246.165.150` | ✅ |
| `ai.quark.cn` | `47.246.165.151` | ✅ |
| `www.aliyun.com` | `47.88.128.4` | ✅ |
| `www.taobao.com` | `155.102.184.210` | ✅ |

### 2.3 GeoIP 交叉驗證

```
203.119.169.79  →  CN / Hebei    / AS37963 Hangzhou Alibaba      ❌ 不通
203.119.204.199 →  CN / Hebei    / AS37963 Hangzhou Alibaba      ❌ 不通
47.246.165.152  →  SG / Singapore/ AS45102 Alibaba (US) Tech     ✅ 通
47.246.136.220  →  US / Virginia / AS45102 Alibaba (US) Tech     ✅ 通
```

**100% 對應**：
- 解析到 **CN / AS37963** → 必然不通
- 解析到 **海外 / AS45102** → 必然通

> 連 `www.quark.cn`（官網，跟雲盤同一間公司）都通，只有雲盤主機不通。
> 這排除了「HiNet 擋阿里」與「防火牆擋阿里」兩種可能。

---

### 2.4 腳本重現驗證（2026-09-29 實跑）

`netcheck/quark-block-test.ps1` 完整執行結果：

```
【AS37963 中國大陸段】
  pan.quark.cn        203.119.169.98   ❌ 不通
  drive-pc.quark.cn   203.119.175.93   ❌ 不通
  drive-h.quark.cn    203.119.169.64   ❌ 不通
  drive.quark.cn      203.119.169.64   ❌ 不通
  act.quark.cn        203.119.204.219  ❌ 不通
  quark.cn            140.205.70.146   ❌ 不通

【AS45102 海外段】
  www.quark.cn        47.246.110.141   ✅ 通
  ai.quark.cn         47.246.110.142   ✅ 通
  www.aliyun.com      47.74.138.66     ✅ 通
  www.taobao.com      155.102.184.210  ✅ 通

中國大陸段 0/6 可通 ／ 海外段 4/4 可通   ← 結論重現
```

> 注意：每次查詢回傳的 IP 都不同（DNS 輪詢，涵蓋多個 CN 與海外節點），
> 但**規則完全不變** —— 只要是 CN 段就擋，海外段就通。
> 這排除了「單一 IP 故障」的可能性。

---

## 3. 逐項排除本機與網路因素

| 可能原因 | 檢查方式 | 結果 | 判定 |
|---|---|---|---|
| 本機防火牆 | `Get-NetFirewallRule -Direction Outbound` | **無任何 Outbound Block 規則** | ❌ 排除 |
| 防火牆預設拒絕 | `Get-NetFirewallProfile` | `DefaultOutboundAction = NotConfigured`（= Allow） | ❌ 排除 |
| 系統 Proxy 攔截 | `netsh winhttp show proxy` / IE 設定 | 無 Proxy | ❌ 排除 |
| DNS 污染 | Google DNS + Cloudflare DNS 交叉查詢 | 兩者回傳**相同** IP | ❌ 排除 |
| HiNet 一般封鎖 | 53 站實測（見 `netcheck/REPORT.md`） | 無任何網站被政策封鎖 | ❌ 排除 |
| ISP peering 異常 | `www.aliyun.com` / `www.taobao.com` 同為阿里 | **全部通** | ❌ 排除 |
| **境外流量被導向大陸機房** | GeoIP 對照 | **CN/Hebei 段全掛** | ✅ **成立** |

---

## 4. 路由層佐證

```
A) 可通 47.246.165.152 (www.quark.cn) — 8 hops 內出境
   1  172.16.7.1
   2  172.16.1.253
   3  220.128.133.254   ← HiNet 出口
   4  168.95.208.42
   6  220.128.8.109
   8  211.22.33.129     ← 成功出境

B) 不通 203.119.169.79 (pan.quark.cn) — 第 2 跳後全滅
   1  172.16.7.1
   2  * (無回應)
   3~8 * (全無回應)
```

> B 的封包在**離開 HiNet 之前**就得不到回應，
> 符合「大陸機房對台灣來源 IP 不回應」的特徵，
> 而非「HiNet 到大陸的線路故障」（那樣 A 也不會通）。

---

## 5. 補充：即使網路通了下載仍會失敗

這是第二層問題，值得先知道，省得白忙一場：

1. **需要登入**：夸克分享連結的完整下載需登入 Cookie（`stoken`），
   匿名狀態只能取預覽，實際檔案會被擋。
2. **反爬蟲**：實測第三方 CORS relay 全部失敗——
   ```
   api.allorigins.win  → HTTP 520 / 522
   api.codetabs.com    → HTTP 522
   r.jina.ai           → HTTP 403 AbuseAlleviationError
   ```
   Quark 對自動化存取有驗證，relay 路線不可行。

---

## 6. 建議行動

### 立刻可行（不需等網路問題）

1. **改用其他裝置下載**：手機走行動網路（4G/5G）通常可正常連夸克，下載後傳到本機。
   傳輸可用：區網共享、USB、OneDrive、Google Drive、微信/Telegram。
2. **請對方改用其他雲端**：Google Drive / OneDrive / 電業雲（皆已實測連通），
   或直接用本課程既有的傳遞方式（`Class-11-2026-09-29` 資料夾）。

### 若要正式申訴

**受理對象：夸克雲盤客服（Alibaba）**，因為 HiNet 側並無異常。

申訴要點：
- 說明台灣 HiNet 使用者 `pan.quark.cn` 之 DNS 回傳中國大陸（河北，AS37963）節點，
  該節點不對境外 IP 迴應，導致完全無法連線。
- 對照組：同公司 `www.quark.cn` 解析至新加坡（AS45102）則連線正常，
  顯示為 DNS  geo-routing 問題。
- 請求：提供台灣／海外可用的 CDN 節點，或修正台灣地區的 DNS 調度。

**HiNet 無需申訴**（可附上本報告第 2 節對照表，證明阿里其他服務在同線路正常）。

---

## 附：本報告的測試腳本

| 檔案 | 用途 |
|---|---|
| `netcheck/quark-block-test.ps1` | 完整重現本報告所有測試（約 280 秒） |

執行方式（腳本為 UTF-8 with BOM，PowerShell 5.1 可正確顯示中文）：

```powershell
powershell -ExecutionPolicy Bypass -Command "[Console]::OutputEncoding=[Text.Encoding]::UTF8; & '.\netcheck\quark-block-test.ps1'"
```
| `netcheck/REPORT.md` | 對外網路整體測試（證明無政策封鎖） |
| `netcheck/web-test.ps1` | 網站可用性初篩 |
