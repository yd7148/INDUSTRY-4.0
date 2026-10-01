# Outbound port connectivity matrix - fully concurrent
$ErrorActionPreference = 'SilentlyContinue'
$Timeout = 5000

$targets = @(
  @{ Name = '8.8.8.8 (Google DNS)';     Host = '8.8.8.8' },
  @{ Name = '1.1.1.1 (Cloudflare)';    Host = '1.1.1.1' },
  @{ Name = 'google.com (443)';        Host = '142.251.153.119' },
  @{ Name = 'github.com (22/443)';     Host = '20.27.177.113' },
  @{ Name = 'tw.yahoo.com (443)';      Host = '180.222.109.252' },
  @{ Name = 'gw 172.16.7.1 (LAN)';     Host = '172.16.7.1' }
)
$ports = 21, 22, 25, 53, 80, 110, 123, 143, 389, 443, 445, 587, 636, 993, 995, 1433, 1521, 3306, 3389, 5432, 5900, 5985, 6379, 8080, 8443, 8888, 27017

$pending = New-Object System.Collections.ArrayList
foreach ($t in $targets) {
  foreach ($p in $ports) {
    $c = New-Object System.Net.Sockets.TcpClient
    $c.BeginConnect($t.Host, $p, $null, $null) | Out-Null
    [void]$pending.Add([pscustomobject]@{ Target = $t.Name; Host = $t.Host; Port = $p; Client = $c; Wait = $c.Client.AsyncWaitHandle })
  }
}

# wait for all simultaneously
[System.Threading.WaitHandle]::WaitAll($pending.Wait, $Timeout) | Out-Null

$results = @()
foreach ($i in $pending) {
  $open = $false
  try { if ($i.Client.Connected) { $i.Client.EndConnect($i.Client.Client.GetSocketOption([System.Net.Sockets.SocketOptionLevel]::Socket,[System.Net.Sockets.SocketOptionName]::State,$null)) ; $open = $true } } catch { $open = $false }
  if ($i.Client.Connected) { $open = $true }
  $results += [pscustomobject]@{ Target = $i.Target; Port = $i.Port; Open = $open }
  $i.Client.Close()
}

Write-Output "=== OUTBOUND PORT MATRIX  (OK = reachable, X = blocked/refused/timeout) ===`n"
$hdr = ($ports | ForEach-Object { "{0,-6}" -f $_ }) -join ''
Write-Output ("{0,-26} {1}" -f 'TARGET', $hdr)
foreach ($t in $targets) {
  $line = "{0,-26} " -f $t.Name
  foreach ($p in $ports) {
    $row = $results | Where-Object { $_.Target -eq $t.Name -and $_.Port -eq $p }
    if ($row.Open) { $line += "{0,-6}" -f 'OK' } else { $line += "{0,-6}" -f 'X' }
  }
  Write-Output $line
}

Write-Output "`n=== REACHABLE ports (>=1 target) ==="
foreach ($p in $ports) {
  $open = ($results | Where-Object { $_.Port -eq $p -and $_.Open }).Count
  if ($open -gt 0) {
    $tg = ($results | Where-Object { $_.Port -eq $p -and $_.Open } | ForEach-Object { $_.Target }) -join ', '
    Write-Output ("port {0,-6} OK  <- {1}" -f $p, $tg)
  }
}
Write-Output "`n=== BLOCKED ports (all targets) ==="
foreach ($p in $ports) {
  $open = ($results | Where-Object { $_.Port -eq $p -and $_.Open }).Count
  if ($open -eq 0) { Write-Output ("port {0,-6} BLOCKED everywhere" -f $p) }
}
