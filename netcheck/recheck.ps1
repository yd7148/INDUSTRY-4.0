[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = 'SilentlyContinue'

# Re-test ambiguous ones with real GET, and inspect cert chain to detect TLS interception (MITM proxy)
$recheck = @(
  @{ n='Gmail';            u='https://mail.google.com/mail/u/0/' },
  @{ n='OpenAI API';      u='https://api.openai.com/v1/models' },
  @{ n='Anthropic API';   u='https://api.anthropic.com/v1/messages' },
  @{ n='Claude.ai';       u='https://claude.ai/' },
  @{ n='Docker Hub';      u='https://registry-1.docker.io/v2/' },
  @{ n='pypi files';      u='https://files.pythonhosted.org/' },
  @{ n='StackOverflow';   u='https://stackoverflow.com/' },
  @{ n='Speedtest';       u='https://www.speedtest.net/' },
  @{ n='Canva';           u='https://www.canva.com/' },
  @{ n='Anthropic claude-code'; u='https://api.anthropic.com/v1/models?limit=1' }
)

Write-Output "=== RE-TEST WITH GET (any HTTP response = network REACHABLE) ===`n"
foreach ($s in $recheck) {
  $code=''; $note=''; $ms=0
  $sw=[Diagnostics.Stopwatch]::StartNew()
  try {
    $r = Invoke-WebRequest -Uri $s.u -Method Get -TimeoutSec 15 -UserAgent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36' -ErrorAction Stop
    $code = [string]$r.StatusCode
    $note = 'REACHABLE (HTTP ' + $code + ')'
  } catch {
    if ($_.Exception.Response) {
      $code = [string][int]$_.Exception.Response.StatusCode
      $note = "REACHABLE - server answered HTTP $code (auth/path issue, NOT a network block)"
    } else {
      $code='ERR'; $note = 'TRUE NETWORK FAILURE: ' + $_.Exception.Message
    }
  }
  $sw.Stop()
  Write-Output ("{0,-28} {1,-5} {2,6}ms  {3}" -f $s.n, $code, $sw.ElapsedMilliseconds, $note)
}

Write-Output "`n=== TLS CERTIFICATE ISSUER CHECK (MITM / TLS interception detection) ===`n"
$tlsTargets = 'www.google.com','api.anthropic.com','github.com','www.microsoft.com','registry.npmjs.org','huggingface.co'
foreach ($h in $tlsTargets) {
  try {
    $c = New-Object Net.Sockets.TcpClient($h,443)
    $ssl = New-Object Net.Security.SslStream($c.GetStream(), $false, ({$true} -as [Net.Security.RemoteCertificateValidationCallback]))
    $ssl.AuthenticateAsClient($h)
    $cert = $ssl.RemoteCertificate
    $c2 = New-Object Security.Cryptography.X509Certificates.X509Certificate2($cert)
    $selfSigned = -not $c2.Verify()
    Write-Output ("{0,-24} issuer={1,-45} valid={2} selfSigned={3}" -f $h, $c2.Issuer, (-not $c2.NotAfter -lt (Get-Date)), $selfSigned)
    $ssl.Close(); $c.Close()
  } catch { Write-Output ("{0,-24} ERROR {1}" -f $h, $_.Exception.Message) }
}
