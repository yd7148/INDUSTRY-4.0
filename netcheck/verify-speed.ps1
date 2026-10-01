[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
$ErrorActionPreference='SilentlyContinue'
$ua='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36'

Write-Output "=== VERIFY THE 4 'FAIL' CASES ===`n"
Write-Output "--- DNS resolution ---"
foreach($h in 'azure.microsoft.com','www.facebook.com','abs.twimg.com','rdweb.westsus2.microsoft.com'){
  $ips = (Resolve-DnsName $h -Type A -ErrorAction SilentlyContinue | Where-Object IPAddress | Select-Object -Expand IPAddress)
  if($ips){ Write-Output ("  {0,-38} DNS OK -> {1}" -f $h,($ips -join ',')) }
  else   { Write-Output ("  {0,-38} *** DNS FAIL ***" -f $h) }
}

Write-Output "`n--- Raw TCP 443 handshake (proves reachability independent of HTTP quirks) ---"
function Raw443($h){
  $c=New-Object Net.Sockets.TcpClient
  $r=$c.BeginConnect($h,443,$null,$null)
  if($r.AsyncWaitHandle.WaitOne(8000,$false)){
    try{ $c.EndConnect($r); $c.Close(); return 'TCP-443 CONNECT OK' }catch{ $c.Close(); return 'REFUSED' }
  }
  $c.Close(); return 'TIMEOUT/FILTERED'
}
foreach($h in 'azure.microsoft.com','www.facebook.com','abs.twimg.com','fe2cr.update.microsoft.com'){
  Write-Output ("  {0,-38} {1}" -f $h,(Raw443 $h))
}

Write-Output "`n--- HTTP GET with curl (bypasses PowerShell quirks) ---"
$curl = (Get-Command curl.exe -ErrorAction SilentlyContinue).Source
if(-not $curl){ $curl='C:\Windows\System32\curl.exe' }
foreach($h in 'azure.microsoft.com','www.facebook.com','abs.twimg.com'){
  $o = & $curl -s -o NUL -w "%{http_code} dns=%{time_namelookup}s conn=%{time_connect}s tls=%{time_appconnect}s" --max-time 15 "https://$h/" 2>&1
  Write-Output ("  {0,-30} {1}" -f $h,$o)
}

Write-Output "`n`n=== THROUGHPUT TEST (download 20MB) ===`n"
foreach($t in @(
  @{n='Google (dl.google.com)';u='https://dl.google.com/'},
  @{n='Cloudflare (speed.cloudflare.com)';u='https://speed.cloudflare.com/__down?bytes=20000000'},
  @{n='Hetzner (speed.hetzner.de)';u='https://speed.hetzner.de/20MB.bin'},
  @{n='Microsoft (dl.msft)';u='https://download.microsoft.com/'}
)){
  $sw=[Diagnostics.Stopwatch]::StartNew()
  $o = & $curl -s -o NUL -w "code=%{http_code} size=%{size_download} speed=%{speed_download}B/s dns=%{time_namelookup}s conn=%{time_connect}s ttfb=%{time_starttransfer}s" --max-time 25 $t.u 2>&1
  $sw.Stop()
  $spd = ($o -join ' ') -replace '.*speed=([0-9.]+).*','$1'
  $mb = if($spd -match '^[0-9.]+$'){ [math]::Round(([double]$spd*1MB/1MB),1) } else { 0 }
  Write-Output ("  {0,-36} {1}" -f $t.n, ($o -join ' '))
  if($mb -gt 0){ Write-Output ("       => ~{0} Mbps" -f [math]::Round($mb*8,1)) }
}

Write-Output "`n=== LATENCY (TCP handshake RTT) ==="
foreach($h in 'www.google.com','github.com','www.microsoft.com','tw.yahoo.com','1.1.1.1'){
  $o = & $curl -s -o NUL -w "%{time_connect}" --max-time 10 "https://$h/" 2>&1
  Write-Output ("  {0,-22} TCP connect = {1}s" -f $h,($o -join ''))
}

Write-Output "`n=== DNS RESOLUTION TIMES ==="
foreach($h in 'www.google.com','api.anthropic.com','github.com','registry.npmjs.org'){
  $sw=[Diagnostics.Stopwatch]::StartNew()
  $o = & $curl -s -o NUL -w "%{time_namelookup}" --max-time 10 "https://$h/" 2>&1
  Write-Output ("  {0,-24} {1}s  (via 168.95.1.1 HiNet DNS)" -f $h,($o -join ''))
}
