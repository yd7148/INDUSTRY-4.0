# 對外網路連線檢查報告

產生時間：2026-09-29 20:04:18  
產生工具：network-port-check skill（opencode agent）

| 項目 | 值 |
|------|-----|
| 本機 IP | `172.16.7.115` |
| 預設閘道 | `172.16.7.1` |
| DNS | `168.95.1.1` |

## 對外 Port 連通性矩陣

```
本機 IP : 172.16.7.115
Gateway : 172.16.7.1
目標數  : 7   Port 數: 27   Timeout: 5000ms

=== OUTBOUND PORT MATRIX  (OK = 可連線, X = 被封鎖/拒絕/逾時) ===

TARGET                         21    22    25    53    80    110   123   143   389   443   445   587   636   993   995   1433  1521  3306  3389  5432  5900  5985  6379  8080  8443  8888  27017 
8.8.8.8 (Google DNS)           X     X     X     OK    X     X     X     X     X     OK    X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     
1.1.1.1 (Cloudflare)           X     X     X     OK    OK    X     X     X     X     OK    X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     
8.9.9.9 (Quad9)                X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     
github.com                     X     X     X     X     OK    X     X     X     X     OK    X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     
www.microsoft.com              X     X     X     X     OK    X     X     X     X     OK    X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     
tw.yahoo.com                   X     X     X     X     OK    X     X     X     X     OK    X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     
gw 172.16.7.1 (LAN)            X     OK    X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     X     

=== 可連線的 Port ===
22  53  80  443

=== 被封鎖的 Port ===
21  25  110  123  143  389  445  587  636  993  995  1433  1521  3306  3389  5432  5900  5985  6379  8080  8443  8888  27017

=== 結論 ===
開放 Port 數：4 / 27
```

## 遠端服務（RDP / SSH / 通道）

```
=== 1. 本機 Remote Desktop 狀態 ===

  [未監聽] 3389 沒有本機 listener
  fDenyTSConnections : 1 = 已停用
  TermService 服務   : Stopped
  防火牆 RDP 規則     : 0 條啟用（遠端連入會被擋）

  => 本機可當 RDP 主機被連入：不行（需管理員權限開啟）

=== 2. 遠端管理協定 對外連線 ===

  3389   -> 8.8.8.8                BLOCKED
  3389   -> 1.1.1.1                BLOCKED
  3389   -> 13.107.6.1             BLOCKED
  22     -> github.com             BLOCKED
  22     -> ssh.github.com         BLOCKED
  5900   -> 8.8.8.8                BLOCKED
  9418   -> github.com             BLOCKED

=== 3. 走 HTTPS 443 的替代通道（白名單環境的唯一生路）===

  GitHub SSH-over-443      443 -> OPEN
  Tailscale DERP           443 -> OPEN
  ZeroTier                 443 -> OPEN
  Twingate                 443 -> OPEN
  ngrok                    443 -> OPEN
  Cloudflare Tunnel        443 -> OPEN
  AWS SSM (Session Mgr)    443 -> OPEN
  Google Cloud IAP         443 -> OPEN
  Microsoft Update         443 -> OPEN

  可用替代方案（走 443 即可繞過 22/3389 封鎖）：
      - GitHub SSH-over-443
      - Tailscale DERP
      - ZeroTier
      - Twingate
      - ngrok
      - Cloudflare Tunnel
      - AWS SSM (Session Mgr)
      - Google Cloud IAP
      - Microsoft Update

=== 4. 結論 ===

  * SSH(22) 封鎖但 ssh.github.com:443 開放，可改走 443：
      ssh -p 443 git@ssh.github.com
    git config --global url."https://ssh.github.com:443".insteadOf "git@github.com:"
  * RDP(3389) 封鎖，遠端桌面請改用 443 通道工具（上表 OPEN 者）。
  * 本機 RDP Server 也未啟用（listener / 登錄機碼 / 防火牆規則 三者缺一），無法被連入。
```

## 網站可達性

```
=== 網站可達性掃描（51 個站）===

[OK]      = 2xx，完全正常
[REACH]   = 伺服器有回應（4xx/5xx），網路可達，非封鎖
[BLOCK]   = 真的連不上（裸 TCP 443 也失敗）
[DNS-FAIL]= 網域無法解析

[ OK ]  Google                   200         710ms  https://www.google.com/
[ OK ]  YouTube                  200        2247ms  https://www.youtube.com/
[ OK ]  Gmail                    200        4203ms  https://mail.google.com/
[ OK ]  Google Drive             200        1580ms  https://drive.google.com/
[ OK ]  Google Translate         200        4036ms  https://translate.google.com/
[ OK ]  GitHub                   200         477ms  https://github.com/
[ OK ]  GitHub API               200         178ms  https://api.github.com/
[ OK ]  raw.githubusercontent    200         569ms  https://raw.githubusercontent.com/
[ OK ]  GitLab                   200         655ms  https://gitlab.com/
[ OK ]  Bitbucket                200        1996ms  https://bitbucket.org/
[ OK ]  npm registry             200          74ms  https://registry.npmjs.org/
[ OK ]  PyPI                     200       17887ms  https://pypi.org/simple/
[ OK ]  Conda / Anaconda         200          84ms  https://repo.anaconda.com/
[ OK ]  Hugging Face             200         171ms  https://huggingface.co/
[ OK ]  Docker Hub               200         684ms  https://hub.docker.com/
[REACH] Docker Registry          401         863ms  https://registry-1.docker.io/v2/
         └─ 需要認證（正常）
[ OK ]  Microsoft                200         178ms  https://www.microsoft.com/
[ OK ]  MS Learn                 200         499ms  https://learn.microsoft.com/
[ OK ]  Microsoft 365            200         532ms  https://www.office.com/
[ OK ]  Azure Portal             200         108ms  https://portal.azure.com/
[REACH] OpenAI API               401         287ms  https://api.openai.com/v1/models
         └─ 需要認證（正常）
[REACH] Anthropic API            405          47ms  https://api.anthropic.com/v1/messages
         └─ HTTP method 不符（正常）
[REACH] Claude.ai                403          46ms  https://claude.ai/
         └─ Cloudflare / 需要登入（正常）
[REACH] ChatGPT                  403          35ms  https://chatgpt.com/
         └─ Cloudflare / 需要登入（正常）
[ OK ]  OpenCode                 200         793ms  https://opencode.ai/
[ OK ]  Notion                   200         387ms  https://www.notion.so/
[ OK ]  Figma                    200         742ms  https://www.figma.com/
[REACH] Canva                    403          76ms  https://www.canva.com/
         └─ Cloudflare / 需要登入（正常）
[ OK ]  Slack                    200         610ms  https://app.slack.com/
[ OK ]  Zoom                     200         496ms  https://zoom.us/
[ OK ]  Teams                    200         328ms  https://teams.microsoft.com/
[REACH] Facebook                 400         192ms  https://www.facebook.com/
         └─ 伺服器有回應
[ OK ]  Instagram                200        1014ms  https://www.instagram.com/
[ OK ]  X (Twitter)              200         368ms  https://x.com/
[ OK ]  LinkedIn                 200         765ms  https://www.linkedin.com/
[ OK ]  Reddit                   200         313ms  https://www.reddit.com/
[ OK ]  TikTok                   200         371ms  https://www.tiktok.com/
[ OK ]  LINE                     200         193ms  https://www.line.me/
[ OK ]  Telegram                 200         995ms  https://web.telegram.org/
[ OK ]  Discord                  200         320ms  https://discord.com/
[ OK ]  Steam                    200         785ms  https://store.steampowered.com/
[ OK ]  Spotify                  200         948ms  https://www.spotify.com/
[ OK ]  Yahoo TW                 200        2264ms  https://tw.yahoo.com/
[ OK ]  Yahoo JP                 200         464ms  https://www.yahoo.co.jp/
[ OK ]  Baidu (CN)               200         577ms  https://www.baidu.com/
[ OK ]  Naver (KR)               200         635ms  https://www.naver.com/
[ OK ]  Wikipedia                200         560ms  https://zh.wikipedia.org/
[REACH] Stack Overflow           403          64ms  https://stackoverflow.com/
         └─ Cloudflare / 需要登入（正常）
[ OK ]  Cloudflare               200        1063ms  https://www.cloudflare.com/
[ OK ]  Binance                  202          79ms  https://www.binance.com/
[REACH] Coinbase                 403          66ms  https://www.coinbase.com/
         └─ Cloudflare / 需要登入（正常）

=== 統計 ===
  正常 (2xx)                : 42
  可達（伺服器有回應，非封鎖）: 9
  DNS 無法解析               : 0
  真正被封鎖                 : 0
  合計                       : 51

=== 結論 ===
  沒有任何網站遭到網路層封鎖。
  （[REACH] 的 401/403/404 是伺服器正常回應，瀏覽器開啟通常沒問題。）
```

## TLS 憑證 / MITM 檢查

```
=== TLS 憑證簽發者檢查（MITM / 攔截偵測）===

     www.google.com                   CN=WR2, O=Google Trust Services, C=US                      到期 2026-12-04
     api.openai.com                   CN=WE1, O=Google Trust Services, C=US                      到期 2026-12-04
     api.anthropic.com                CN=WE1, O=Google Trust Services, C=US                      到期 2026-12-21
     claude.ai                        CN=YE2, O=Let's Encrypt, C=US                              到期 2026-12-09
     github.com                       CN=Sectigo Public Server Authentication CA DV E36, O=Sectigo Limited, C=GB 到期 2026-11-30
     raw.githubusercontent.com        CN=YR1, O=Let's Encrypt, C=US                              到期 2026-11-01
     registry.npmjs.org               CN=WE1, O=Google Trust Services, C=US                      到期 2026-11-22
     www.microsoft.com                CN=Microsoft TLS G2 RSA CA OCSP 04, O=Microsoft Corporation, C=US 到期 2027-01-18
     fe2cr.update.microsoft.com       CN=Microsoft ECC Update Secure Server CA 2.1, O=Microsoft Corporation, L=Redmond, S=Washington, C=US 到期 2027-01-23
     huggingface.co                   CN=Amazon RSA 2048 M01, O=Amazon, C=US                     到期 2027-02-28
     pypi.org                         CN=GlobalSign Atlas R3 DV TLS CA 2025 Q4, O=GlobalSign nv-sa, C=BE 到期 2027-01-29
     www.facebook.com                 CN=DigiCert Global G2 TLS RSA SHA256 2020 CA1, O=DigiCert Inc, C=US 到期 2026-10-05

=== 結論 ===

  所有憑證皆由已知第三方 CA 簽發，沒有企業 MITM 根憑證。
  => 端對端加密未被攔截，可正常使用。
```


---

> 本報告由 `test-ports` / `test-services` / `test-websites` / `test-tls` / `test-bandwidth` 原始輸出組成。
> 判讀方式請見 skill 的 `reference/interpretation.md`。
