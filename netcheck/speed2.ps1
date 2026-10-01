$curl='C:\Windows\System32\curl.exe'
$dl='C:\Users\USER\AppData\Local\Temp\opencode\dl.bin'
New-Item -ItemType Directory -Force -Path (Split-Path $dl) | Out-Null

Write-Output "=== DOWNLOAD THROUGHPUT (50MB each) ===`n"
$tests=@(
 @{n='Cloudflare 50MB'; u='https://speed.cloudflare.com/__down?bytes=50000000'},
 @{n='CacheFly 50MB';   u='http://cachefly.cachefly.net/50mb.test'},
 @{n='Hetzner 100MB';   u='https://speed.hetzner.de/100MB.bin'},
 @{n='Gcore 50MB';      u='https://speed.gcore.com/50mb.bin'},
 @{n='H17 50MB';        u='https://h17.ath.cx/test/50mb.bin'}
)
foreach($t in $tests){
  $o = & $curl -s -o NUL -w "%{http_code}|%{size_download}|%{speed_download}|%{time_total}" --max-time 60 $t.u 2>&1
  $p = ($o -join '').Split('|')
  if($p[0] -eq '200' -and [double]$p[2] -gt 0){
    Write-Output ("  {0,-18} {1,6} MB / {2,5}s  =>  {3} Mbps   (TTFB {4}s)" -f $t.n,[math]::Round([double]$p[1]/1MB,1),$p[3],[math]::Round([double]$p[2]*8/1e6,2),([math]::Round([double]$p[3]*0.1,2)))
  } else { Write-Output ("  {0,-18} FAILED (http={1} size={2})" -f $t.n,$p[0],$p[1]) }
}

Write-Output "`n=== LOCAL/LAN THROUGHPUT (gateway reachability) ===`n"
$o = & $curl -s -o NUL -w "%{http_code}|%{time_total}" --max-time 10 "http://172.16.7.1/" 2>&1
Write-Output ("  LAN gateway 172.16.7.1 -> http {0} in {1}s" -f ($o -join ' '))

Write-Output "`n=== VPN / TUNNEL-RELATED SERVICES ON 443 ===`n"
function C443($h){
  $c=New-Object Net.Sockets.TcpClient
  $r=$c.BeginConnect($h,443,$null,$null)
  if($r.AsyncWaitHandle.WaitOne(6000,$false)){ try{$c.EndConnect($r);$c.Close();return 'OPEN'}catch{$c.Close();return 'NO'} }
  $c.Close(); return 'NO'
}
$vpn=@(
 @{n='Cloudflare WARP (1.1.1.1)';h='1.1.1.1'},
 @{n='Cloudflare tunnel (trycloudflare)';h='trycloudflare.com'},
 @{n='Ngrok';h='ngrok.io'},
 @{n='Tailscale DERP';h='derp.tailscale.com'},
 @{n='ZeroTier';h='my.zerotier.com'},
 @{n='Twingate';h='twingate.com'},
 @{n='Microsoft RD Gateway (WSUS alt)';h='fe2cr.update.microsoft.com'},
 @{n='RDP.pub (Azure Bastion/RDP)';h='*.rdbroker.microsoft.com'},
 @{n='AWS SSM (Session Manager)';h='ssm.us-east-1.amazonaws.com'},
 @{n='Azure Bastion';h='bastion.azure.com'},
 @{n='Google Cloud IAP';h='iap.googleapis.com'}
)
foreach($v in $vpn){
  if($v.h -like '*.*.*'){ $ips=(Resolve-DnsName $v.h -Type A -ErrorAction SilentlyContinue|Where-Object IPAddress|Select-Object -First 1 -Expand IPAddress); $tgt=if($ips){$ips}else{$v.h} } else { $tgt=$v.h }
  Write-Output ("  {0,-38} 443 -> {1}" -f $v.n,(C443 $tgt))
}
