$curl='C:\Windows\System32\curl.exe'
Write-Output "=== CORRECTED THROUGHPUT (100MB downloads) ===`n"
$tests=@(
 @{n='Cloudflare'; u='https://speed.cloudflare.com/__down?bytes=100000000'},
 @{n='Hetzner DE'; u='https://speed.hetzner.de/100MB.bin'},
 @{n='Google Cloud'; u='https://storage.googleapis.com/gcp-public-data-landsat/index.csv'},
 @{n='Netflix (fast.com CDN)'; u='https://ipv4-c001-c001-c001.cdn.nflxvideo.net/'}
)
foreach($t in $tests){
  $o = & $curl -s -o NUL -w "%{http_code}|%{size_download}|%{speed_download}|%{time_total}|%{time_starttransfer}" --max-time 40 $t.u 2>&1
  $p = ($o -join '').Split('|')
  if($p[0] -eq '200' -and [double]$p[2] -gt 0){
    $mbps = [math]::Round(([double]$p[2]*8/1000000),2)
    $sizeMB= [math]::Round(([double]$p[1]/1MB),1)
    $tsec = [double]$p[3]
    Write-Output ("  {0,-28} {1,7} MB in {2,5}s => {3} Mbps" -f $t.n,$sizeMB,$tsec,$mbps)
  } else {
    Write-Output ("  {0,-28} FAILED (http={1} size={2})" -f $t.n,$p[0],$p[1])
  }
}

Write-Output "`n=== UPLOAD TEST (Cloudflare 20MB up) ===`n"
$fs = 'C:\Users\USER\AppData\Local\Temp\opencode\upload20.bin'
$buf = New-Object byte[] (20MB); (New-Object Random 42).NextBytes($buf); [IO.File]::WriteAllBytes($fs,$buf)
$o = & $curl -s -o NUL -w "%{http_code}|%{speed_upload}|%{time_total}" --max-time 60 -X POST --data-binary "@$fs" "https://speed.cloudflare.com/__up" 2>&1
$p = ($o -join '').Split('|')
if($p[0] -eq '200' -and [double]$p[1] -gt 0){ Write-Output ("  UPLOAD => {0} Mbps ({1}s)" -f [math]::Round(([double]$p[1]*8/1000000),2), $p[2]) }
else { Write-Output ("  UPLOAD FAILED: {0}" -f ($o -join ' ')) }
Remove-Item $fs -ErrorAction SilentlyContinue

Write-Output "`n=== PING / TRACERT ===`n"
foreach($h in '1.1.1.1','8.8.8.8','www.google.com','github.com'){
  $p = Test-Connection -ComputerName $h -Count 3 -ErrorAction SilentlyContinue
  if($p){ $avg=[math]::Round((($p|Measure-Object -Property ResponseTime -Average).Average),1); Write-Output ("  {0,-18} avg RTT = {1} ms" -f $h,$avg) }
  else { Write-Output ("  {0,-18} ICMP blocked (common; ICMP filter, not a connectivity problem)" -f $h) }
}

Write-Output "`n=== TRACERT to 1.1.1.1 (hop count) ===`n"
$t = tracert -d -h 12 -w 800 1.1.1.1
($t | Select-Object -First 16) | ForEach-Object { Write-Output ("  {0}" -f $_) }
