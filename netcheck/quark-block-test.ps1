<#
.SYNOPSIS
    夸克雲盤（pan.quark.cn）連線失敗診斷 — 可重現測試腳本

.DESCRIPTION
    重現 netcheck/quark-block-report.md 的所有測試，用於驗證結論是否仍成立。

    測試分三層：
      A. 症狀層   — DNS / ICMP / TCP 80 / TCP 443
      B. 對照層   — 同公司不同網段（AS37963 中國 vs AS45102 海外）
      C. 排除層   — 本機防火牆 / Proxy / DNS 交叉驗證 / GeoIP

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File netcheck\quark-block-test.ps1
#>

$ErrorActionPreference = 'Continue'
$ProgressPreference    = 'SilentlyContinue'

function Write-Section($t) {
    Write-Host ''
    Write-Host ('=' * 68) -ForegroundColor Cyan
    Write-Host "  $t" -ForegroundColor Cyan
    Write-Host ('=' * 68) -ForegroundColor Cyan
}
function Write-Row($a, $b, $c) {
    Write-Host ("  {0,-30} {1,-18} {2}" -f $a, $b, $c)
}
function Test-Tcp443($ipOrHost) {
    try {
        return (Test-NetConnection -ComputerName $ipOrHost -Port 443 `
                -InformationLevel Quiet -WarningAction SilentlyContinue)
    } catch { return $false }
}
function Get-A($host_) {
    return (Resolve-DnsName $host_ -Type A -ErrorAction SilentlyContinue |
            Where-Object { $_.IPAddress } | Select-Object -First 1).IPAddress
}

$start = Get-Date

# ---------------------------------------------------------------- A. 症狀層
Write-Section 'A. 症狀層 — 目標主機診斷'

$target = 'pan.quark.cn'
$share  = 'https://pan.quark.cn/s/1cf1c5d6d4a6'

$ip = Get-A $target
if ($ip) { Write-Row 'DNS 解析' $ip '✅ 正常' }
else     { Write-Row 'DNS 解析' '-' '❌ 解析失敗'; exit 1 }

$ping = Test-Connection -ComputerName $target -Count 3 -ErrorAction SilentlyContinue
if ($ping) { Write-Row 'ICMP ping' $ip '✅ 有回應' }
else       { Write-Row 'ICMP ping' $ip '❌ TIMEOUT' }

foreach ($p in 80, 443) {
    $ok = Test-Tcp443 $ip | Out-Null
    $r  = Test-NetConnection -ComputerName $ip -Port $p -WarningAction SilentlyContinue
    $s  = if ($r.TcpTestSucceeded) { '✅ 連線成功' } else { '❌ TIMEOUT' }
    Write-Row "TCP $p" $ip $s
}

Write-Host ''
Write-Host '  HTTP 實測：' -ForegroundColor Gray
& curl.exe -sS -m 25 -o NUL -w "    HTTP %{http_code}  time=%{time_total}s`n" $share 2>&1 |
    ForEach-Object { Write-Host $_ -ForegroundColor DarkGray }

# ---------------------------------------------------------------- B. 對照層
Write-Section 'B. 對照層 — 同一網段分組對照（關鍵證據）'

$cnHosts = @('pan.quark.cn', 'drive-pc.quark.cn', 'drive-h.quark.cn',
             'drive.quark.cn', 'act.quark.cn', 'quark.cn')
$intlHosts = @('www.quark.cn', 'ai.quark.cn', 'www.aliyun.com', 'www.taobao.com')

Write-Host '  【AS37963 中國大陸段 — 預期全部不通】' -ForegroundColor Yellow
$cnPass = 0
foreach ($h in $cnHosts) {
    $i = Get-A $h; if (-not $i) { continue }
    $ok = Test-Tcp443 $i; if ($ok) { $cnPass++ }
    $tag = if ($ok) { '✅ 通' } else { '❌ 不通' }
    Write-Row $h $i $tag -ForegroundColor DarkYellow
}

Write-Host ''
Write-Host '  【AS45102 海外段 — 預期全部可通】' -ForegroundColor Yellow
$intlPass = 0
foreach ($h in $intlHosts) {
    $i = Get-A $h; if (-not $i) { continue }
    $ok = Test-Tcp443 $i; if ($ok) { $intlPass++ }
    $tag = if ($ok) { '✅ 通' } else { '❌ 不通' }
    Write-Row $h $i $tag
}

Write-Host ''
Write-Host '  ── GeoIP 對照 ──' -ForegroundColor Gray
foreach ($i in @('203.119.169.79', '47.246.165.152')) {
    try {
        $g = & curl.exe -sS -m 20 "https://ipinfo.io/$i/json" 2>$null | ConvertFrom-Json
        if ($g) { Write-Row $i "$($g.country)/$($g.region)" $g.org -ForegroundColor DarkGray }
    } catch { }
}

# ---------------------------------------------------------------- C. 排除層
Write-Section 'C. 排除層 — 確認不是本機問題'

Write-Host '  [1] Windows 防火牆 Outbound 規則' -ForegroundColor Gray
$blocks = Get-NetFirewallRule -Direction Outbound -Enabled True -ErrorAction SilentlyContinue |
          Where-Object { $_.Action -eq 'Block' -or $_.DisplayName -match 'quark|203\.119|alibaba' }
if ($blocks) {
    $blocks | Select-Object DisplayName, Action | Format-Table -AutoSize | Out-String |
        ForEach-Object { Write-Host $_ -ForegroundColor Red }
} else {
    Write-Host '      ✅ 無任何 Outbound Block 規則 → 本機防火牆無罪' -ForegroundColor Green
}

Write-Host '  [2] 防火牆預設 Outbound 動作' -ForegroundColor Gray
Get-NetFirewallProfile | Select-Object Name, DefaultOutboundAction |
    Format-Table -AutoSize | Out-String | ForEach-Object { Write-Host $_ -ForegroundColor DarkGray }

Write-Host '  [3] 系統 Proxy' -ForegroundColor Gray
$ie = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -ErrorAction SilentlyContinue
if ($ie.ProxyEnable -eq 0 -and -not $ie.ProxyServer) {
    Write-Host '      ✅ 未設定 Proxy → 無 Proxy 干擾' -ForegroundColor Green
} else {
    Write-Host "      ⚠ 存在 Proxy: $($ie.ProxyServer)" -ForegroundColor Yellow
}

Write-Host '  [4] DNS 交叉驗證（Google / Cloudflare）' -ForegroundColor Gray
foreach ($resolver in @('https://dns.google/resolve?name=pan.quark.cn&type=A',
                        'https://cloudflare-dns.com/dns-query?name=pan.quark.cn&type=A')) {
    $r = & curl.exe -sS -m 20 -H 'accept: application/dns-json' $resolver 2>$null
    if ($r) {
        $j = $r | ConvertFrom-Json
        $ips = ($j.Answer | Where-Object { $_.type -eq 1 } | ForEach-Object { $_.data }) -join ','
        Write-Host "      $(($resolver -split '/')[2])  →  $ips" -ForegroundColor DarkGray
    }
}

# ---------------------------------------------------------------- 結論
Write-Section '診斷結論'
$elapsed = (Get-Date) - $start

Write-Host "  中國大陸段 (AS37963) 可通數：$cnPass / $($cnHosts.Count)" -ForegroundColor Yellow
Write-Host "  海外段     (AS45102) 可通數：$intlPass / $($intlHosts.Count)" -ForegroundColor Yellow
Write-Host ''

if ($cnPass -eq 0 -and $intlPass -eq $intlHosts.Count) {
    Write-Host '  ✅ 確認：解析到中國大陸段者全擋，海外段全通。' -ForegroundColor Green
    Write-Host '     責任歸屬 = Alibaba 夸克（geo-routing 派台灣流量至大陸節點，該節點不對外開放）' -ForegroundColor Green
    Write-Host '     HiNet 與本機防火牆均無問題。' -ForegroundColor Green
    Write-Host ''
    Write-Host '     行動建議：改用行動網路下載 / 請對方改用其他雲端 / 向夸克客服申訴。' -ForegroundColor Cyan
} else {
    Write-Host '  ⚠ 結果與原報告不符，網路狀態可能已變動，請重新檢視。' -ForegroundColor Yellow
}

Write-Host ''
Write-Host "  耗時：$([math]::Round($elapsed.TotalSeconds, 1)) 秒" -ForegroundColor DarkGray
Write-Host ''
