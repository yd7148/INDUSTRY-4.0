$ErrorActionPreference='SilentlyContinue'

function T($h,$p,$t=5000){
  $c=New-Object Net.Sockets.TcpClient
  $r=$c.BeginConnect($h,$p,$null,$null)
  if($r.AsyncWaitHandle.WaitOne($t,$false)){ try{$c.EndConnect($r);$c.Close();return $true}catch{$c.Close();return $false} }
  $c.Close(); return $false
}

Write-Output "=== RDP (port 3389) OUTBOUND DEEP TEST ===`n"
Write-Output "--- Is RDP service listening on THIS machine? ---"
$rdpListen = Get-NetTCPConnection -State Listen -LocalPort 3389
if ($rdpListen) {
  Write-Output "YES - local RDP listener active:"
  $rdpListen | ForEach-Object { Write-Output ("   {0}:{1}  (state {2})" -f $_.LocalAddress,$_.LocalPort,$_.State) }
} else { Write-Output "NO - nothing listening on 3389 locally (RDP server role not active/reachable)" }
Write-Output ("RDP registry enabled : {0}" -f (Get-ItemProperty 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections).fDenyTSConnections)
Write-Output ("fDenyTSConnections: 0 = RDP ALLOWED, 1 = RDP DISABLED")
Write-Output ("TermService service : {0}" -f (Get-Service TermService -ErrorAction SilentlyContinue).Status)
Write-Output ("RDP firewall rule   : {0}" -f ((Get-NetFirewallRule -DisplayGroup 'Remote Desktop' -ErrorAction SilentlyContinue | Where-Object Enabled -eq True | Measure-Object).Count))

Write-Output "`n--- Outbound 3389 attempts (public + internal candidates) ---"
$rdpTargets = @(
  '13.107.6.1',        # Microsoft RD gateway range (edge)
  '20.36.36.36',       # MS
  '172.16.7.1',        # LAN gateway
  '172.16.7.2',
  '172.16.7.50',
  '192.168.1.1',
  '8.8.8.8',
  '1.1.1.1'
)
$pend = New-Object Collections.ArrayList
foreach($h in $rdpTargets){
  $c=New-Object Net.Sockets.TcpClient
  $c.BeginConnect($h,3389,$null,$null)|Out-Null
  [void]$pend.Add([pscustomobject]@{H=$h;C=$c;W=$c.Client.AsyncWaitHandle})
}
[Threading.WaitHandle]::WaitAll($pend.W,8000)|Out-Null
foreach($i in $pend){
  $open = $i.C.Connected
  Write-Output ("  3389 -> {0,-16} {1}" -f $i.H, $(if($open){'OPEN (RDP reachable)'}else{'BLOCKED/CLOSED'}))
  $i.C.Close()
}

Write-Output "`n--- RDP over HTTPS/TCP-443 gateways (how RDP tunnels through 443) ---"
Write-Output ("  RD Gateway 443 (msrdc-ish) / Azure RD Gateway uses 443. Port 443 generally allowed."
)
foreach($h in @('rdweb.westsus2.microsoft.com','rdbroker.wus2.microsoft.com')){
  Write-Output ("  443 -> {0,-36} {1}" -f $h, $(if(T $h 443 5000){'OPEN'}else{'BLOCKED'}))
}

Write-Output "`n--- SSH (22) & other common tunnels over 443 ---"
$t2 = @(
  @{h='ssh.github.com';p=443;n='GitHub SSH-over-443'},
  @{h='ssh.github.com';p=22; n='GitHub SSH 22'},
  @{h='speed.hetzner.de';p=22;n='Hetzner SSH'},
  @{h='github.com';p=9418;n='git:// protocol'}
)
foreach($t in $t2){
  Write-Output ("  {0,-5} -> {1,-28} {2}" -f $t.p, $t.n, $(if(T $t.h $t.p 5000){'OPEN'}else{'BLOCKED'}))
}
