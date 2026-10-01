[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
$ErrorActionPreference='SilentlyContinue'
$ua='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36'

$sites=@(
 @{n='Google';u='https://www.google.com/'},@{n='YouTube';u='https://www.youtube.com/'},
 @{n='Gmail';u='https://mail.google.com/'},@{n='Drive';u='https://drive.google.com/'},
 @{n='Google Translate';u='https://translate.google.com/'},@{n='Google Maps';u='https://www.google.com/maps'},
 @{n='GitHub';u='https://github.com/'},@{n='GitLab';u='https://gitlab.com/'},
 @{n='Bitbucket';u='https://bitbucket.org/'},@{n='npm';u='https://registry.npmjs.org/'},
 @{n='PyPI';u='https://pypi.org/'},@{n='Anaconda';u='https://anaconda.org/'},
 @{n='HuggingFace';u='https://huggingface.co/'},@{n='Docker Hub';u='https://hub.docker.com/'},
 @{n='MS Learn';u='https://learn.microsoft.com/'},@{n='Azure';u='https://azure.microsoft.com/'},
 @{n='M365';u='https://www.office.com/'},@{n='OneDrive';u='https://onedrive.live.com/'},
 @{n='Yahoo TW';u='https://tw.yahoo.com/'},@{n='Yahoo JP';u='https://www.yahoo.co.jp/'},
 @{n='Facebook';u='https://www.facebook.com/'},@{n='Instagram';u='https://www.instagram.com/'},
 @{n='X/Twitter';u='https://x.com/'},@{n='LinkedIn';u='https://www.linkedin.com/'},
 @{n='Reddit';u='https://www.reddit.com/'},@{n='Wikipedia';u='https://zh.wikipedia.org/'},
 @{n='LINE';u='https://www.line.me/'},@{n='TikTok';u='https://www.tiktok.com/'},
 @{n='Threads';u='https://www.threads.net/'},@{n='Discord';u='https://discord.com/'},
 @{n='Telegram';u='https://web.telegram.org/'},
 @{n='OpenAI';u='https://chatgpt.com/'},@{n='Anthropic';u='https://claude.ai/'},
 @{n='OpenCode';u='https://opencode.ai/'},@{n='Perplexity';u='https://www.perplexity.ai/'},
 @{n='Notion';u='https://www.notion.so/'},@{n='Figma';u='https://www.figma.com/'},
 @{n='Canva';u='https://www.canva.com/'},@{n='Slack';u='https://app.slack.com/'},
 @{n='Zoom';u='https://zoom.us/'},@{n='Teams';u='https://teams.microsoft.com/'},
 @{n='Cloudflare';u='https://www.cloudflare.com/'},@{n='StackOverflow';u='https://stackoverflow.com/'},
 @{n='ITRI';u='https://www.itri.org.tw/'},@{n='Google CN';u='https://www.google.com.hk/'},
 @{n='Naver KR';u='https://www.naver.com/'},@{n='Baidu CN';u='https://www.baidu.com/'},
 @{n='163 CN';u='https://www.163.com/'},
 # commonly filtered categories
 @{n='Pornhub';u='https://www.pornhub.com/'},@{n='XVideos';u='https://www.xvideos.com/'},
 @{n='Binance';u='https://www.binance.com/'},@{n='Coinbase';u='https://www.coinbase.com/'},
 @{n='Twitter CDN(abs)';u='https://abs.twimg.com/'},
 @{n='Steam';u='https://store.steampowered.com/'},@{n='Epic Games';u='https://store.epicgames.com/'},
 @{n='Spotify';u='https://www.spotify.com/'},
 @{n='RDP Gateway 443';u='https://rdweb.westsus2.microsoft.com/'},
 @{n='WSUS/Microsoft Update';u='https://fe2cr.update.microsoft.com/'}
)

$out=@()
foreach($s in $sites){
  $sw=[Diagnostics.Stopwatch]::StartNew(); $code=''; $v=''; $err=''
  try{
    $r=Invoke-WebRequest -Uri $s.u -TimeoutSec 12 -UserAgent $ua -MaximumRedirection 5 -ErrorAction Stop
    $code=[string]$r.StatusCode; $v='PASS'
  }catch{
    if($_.Exception.Response){
      $c=[int]$_.Exception.Response.StatusCode
      $code=[string]$c
      # 401/403/404/405/302 still means the server was reached
      $v = if($c -in 301,302,401,403,404,405){'REACH'}else{'BLOCK'}
      if($c -in 401,403,404,405){$v='REACH'}
      $err=''
    } else { $code='ERR'; $v='BLOCK'; $err=$_.Exception.Message }
  }
  $sw.Stop()
  $out+=[pscustomobject]@{N=$s.n;U=$s.u;C=$code;V=$v;Ms=$sw.ElapsedMilliseconds;E=$err}
}

Write-Output "=== EXTENDED SITE SWEEP ==="
foreach($o in $out){
  $tag = switch($o.V){'PASS'{'[ OK ] '}'REACH'{'[REACH]'}default{'[FAIL] '}}
  Write-Output ("{0} {1,-22} {2,-5} {3,6}ms {4}" -f $tag,$o.N,$o.C,$o.Ms,$o.U)
}
Write-Output "`n=== SUMMARY ==="
Write-Output ("FULL PASS (2xx)  : {0}" -f ($out|Where-Object{$_.V -eq 'PASS'}).Count)
Write-Output ("REACHABLE (4xx/5xx from server, i.e. NOT blocked): {0}" -f ($out|Where-Object{$_.V -eq 'REACH'}).Count)
Write-Output ("TRUE BLOCKED (no TCP/HTTP response at all)        : {0}" -f ($out|Where-Object{$_.V -eq 'BLOCK'}).Count)
Write-Output "`n--- TRUE BLOCKS ---"
$out|Where-Object{$_.V -eq 'BLOCK'}|ForEach-Object{Write-Output ("  {0,-22} {1}  {2}" -f $_.N,$_.C,$_.E)}
