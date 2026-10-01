[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11
$ErrorActionPreference = 'SilentlyContinue'

$sites = @(
  @{ n='Google';            u='https://www.google.com/' },
  @{ n='YouTube';           u='https://www.youtube.com/' },
  @{ n='Gmail';             u='https://mail.google.com/' },
  @{ n='Google Drive';      u='https://drive.google.com/' },
  @{ n='GitHub';            u='https://github.com/' },
  @{ n='GitHub API';        u='https://api.github.com/' },
  @{ n='raw.githubusercontent'; u='https://raw.githubusercontent.com/' },
  @{ n='Microsoft';         u='https://www.microsoft.com/' },
  @{ n='Azure Portal';      u='https://portal.azure.com/' },
  @{ n='MS Learn';          u='https://learn.microsoft.com/' },
  @{ n='Yahoo TW';          u='https://tw.yahoo.com/' },
  @{ n='Facebook';          u='https://www.facebook.com/' },
  @{ n='Instagram';         u='https://www.instagram.com/' },
  @{ n='X (Twitter)';       u='https://x.com/' },
  @{ n='LinkedIn';          u='https://www.linkedin.com/' },
  @{ n='Wikipedia';         u='https://zh.wikipedia.org/' },
  @{ n='OpenAI';            u='https://api.openai.com/v1/models' },
  @{ n='Anthropic';         u='https://api.anthropic.com/' },
  @{ n='Claude.ai';         u='https://claude.ai/' },
  @{ n='OpenCode';          u='https://opencode.ai/' },
  @{ n='npm';               u='https://registry.npmjs.org/' },
  @{ n='PyPI';              u='https://pypi.org/simple/' },
  @{ n='Docker Hub';        u='https://registry-1.docker.io/v2/' },
  @{ n='pypi files';        u='https://files.pythonhosted.org/' },
  @{ n='Conda';             u='https://repo.anaconda.com/' },
  @{ n='HuggingFace';       u='https://huggingface.co/' },
  @{ n='Cloudflare';        u='https://www.cloudflare.com/' },
  @{ n='StackOverflow';     u='https://stackoverflow.com/' },
  @{ n='Reddit';            u='https://www.reddit.com/' },
  @{ n='X11 no-www test';   u='https://x.com/robots.txt' },
  @{ n='LINE';              u='https://www.line.me/' },
  @{ n='Yahoo Japan';       u='https://www.yahoo.co.jp/' },
  @{ n='Naver (KR)';        u='https://www.naver.com/' },
  @{ n='Baidu (CN)';        u='https://www.baidu.com/' },
  @{ n='163 (CN)';          u='https://www.163.com/' },
  @{ n='ITRI (gov)';        u='https://www.itri.org.tw/' },
  @{ n='NTP pool';          u='https://pool.ntp.org/' },
  @{ n='Speedtest';         u='https://www.speedtest.net/' },
  @{ n='Canva';             u='https://www.canva.com/' },
  @{ n='Figma';             u='https://www.figma.com/' },
  @{ n='Notion';            u='https://www.notion.so/' },
  @{ n='Slack';             u='https://app.slack.com/' },
  @{ n='Zoom';              u='https://zoom.us/' },
  @{ n='Teams';             u='https://teams.microsoft.com/' }
)

$results = @()
foreach ($s in $sites) {
  $sw = [Diagnostics.Stopwatch]::StartNew()
  $status = ''; $verdict = ''; $err = ''
  try {
    $r = Invoke-WebRequest -Uri $s.u -Method Head -TimeoutSec 12 -MaximumRedirection 3 -UserAgent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)' -ErrorAction Stop
    $status = [string]$r.StatusCode
    $verdict = if ($r.StatusCode -lt 400) { 'PASS' } else { 'BLOCKED' }
  } catch {
    $ex = $_.Exception
    if ($ex.Response) {
      try { $status = [string][int]$ex.Response.StatusCode } catch { $status = '?' }
      $verdict = 'BLOCKED'
      $err = $ex.Message
    } else {
      $status = 'ERR'
      $verdict = 'BLOCKED'
      $err = $ex.Message
    }
  }
  $sw.Stop()
  $results += [pscustomobject]@{ Site = $s.n; Url = $s.u; Code = $status; Verdict = $verdict; Ms = $sw.ElapsedMilliseconds; Err = $err }
}

Write-Output "=== WEBSITE REACHABILITY (HEAD request) ===`n"
foreach ($r in $results) {
  $flag = if ($r.Verdict -eq 'PASS') { '[PASS]  ' } else { '[BLOCK]' }
  Write-Output ("{0} {1,-24} {2,-6} {3,6}ms  {4}" -f $flag, $r.Site, $r.Code, $r.Ms, $r.Url)
  if ($r.Err) { Write-Output ("        └─ {0}" -f $r.Err) }
}

Write-Output "`n=== TOTALS ==="
$pass = ($results | Where-Object {$_.Verdict -eq 'PASS'}).Count
$blk  = ($results | Where-Object {$_.Verdict -eq 'BLOCKED'}).Count
Write-Output ("PASS: $pass    BLOCKED: $blk    TOTAL: $($results.Count)")
Write-Output "`n=== BLOCKED LIST ==="
$results | Where-Object {$_.Verdict -eq 'BLOCKED'} | ForEach-Object { Write-Output ("{0,-24} code={1,-5} {2}" -f $_.Site, $_.Code, $_.Err) }
