$domain = 'lowlifenowife.com'
$www = 'www.lowlifenowife.com'
$expectedNs = @('courtney.ns.cloudflare.com', 'johnny.ns.cloudflare.com')
$expectedCname = 'daoseng33.github.io'
$servers = @('1.1.1.1', '8.8.8.8')

function Test-SameSet($Actual, $Expected) {
  if ($Actual.Count -ne $Expected.Count) {
    return $false
  }

  $actualSorted = @($Actual | Sort-Object)
  $expectedSorted = @($Expected | Sort-Object)

  for ($i = 0; $i -lt $expectedSorted.Count; $i++) {
    if ($actualSorted[$i] -ne $expectedSorted[$i]) {
      return $false
    }
  }

  return $true
}

function Get-Nameservers($Server) {
  try {
    @(Resolve-DnsName $domain -Type NS -Server $Server -ErrorAction Stop |
      Where-Object { $_.Type -eq 'NS' } |
      ForEach-Object { $_.NameHost.TrimEnd('.').ToLowerInvariant() } |
      Sort-Object -Unique)
  } catch {
    @()
  }
}

function Get-WwwCname($Server) {
  try {
    @(Resolve-DnsName $www -Type CNAME -Server $Server -ErrorAction Stop |
      Where-Object { $_.Type -eq 'CNAME' } |
      ForEach-Object { $_.NameHost.TrimEnd('.').ToLowerInvariant() } |
      Select-Object -First 1)
  } catch {
    @()
  }
}

function Test-Url($Url) {
  try {
    $response = Invoke-WebRequest -Uri $Url -Method Head -MaximumRedirection 5 -UseBasicParsing -TimeoutSec 20 -ErrorAction Stop
    [PSCustomObject]@{
      Ok = ($response.StatusCode -ge 200 -and $response.StatusCode -lt 400)
      Status = $response.StatusCode
    }
  } catch {
    [PSCustomObject]@{
      Ok = $false
      Status = $_.Exception.Message
    }
  }
}

function Format-Value($Values) {
  if ($Values.Count -gt 0) {
    return ($Values -join ', ')
  }

  return '(no result)'
}

Write-Host 'DNS propagation watcher started. Checking lowlifenowife.com every 5 minutes.' -ForegroundColor Cyan
Write-Host 'Completion criteria: Cloudflare NS on 1.1.1.1 and 8.8.8.8, www CNAME, and HTTPS root/www reachable.' -ForegroundColor Cyan
Write-Host 'Press Ctrl+C to stop manually.' -ForegroundColor DarkGray

while ($true) {
  $now = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'
  Write-Host "`n[$now] Checking..." -ForegroundColor White

  $allNsOk = $true
  $allCnameOk = $true

  foreach ($server in $servers) {
    $ns = @(Get-Nameservers $server)
    $nsOk = Test-SameSet $ns $expectedNs
    if (-not $nsOk) {
      $allNsOk = $false
    }

    $nsStatus = 'waiting'
    if ($nsOk) {
      $nsStatus = 'OK'
    }
    Write-Host ("NS via {0}: {1} [{2}]" -f $server, (Format-Value $ns), $nsStatus)

    $cname = @(Get-WwwCname $server)
    $cnameOk = ($cname.Count -gt 0 -and $cname[0] -eq $expectedCname)
    if (-not $cnameOk) {
      $allCnameOk = $false
    }

    $cnameStatus = 'waiting'
    if ($cnameOk) {
      $cnameStatus = 'OK'
    }
    Write-Host ("www CNAME via {0}: {1} [{2}]" -f $server, (Format-Value $cname), $cnameStatus)
  }

  $root = Test-Url 'https://lowlifenowife.com/'
  $wwwResult = Test-Url 'https://www.lowlifenowife.com/'

  $rootStatus = 'waiting'
  if ($root.Ok) {
    $rootStatus = 'OK'
  }
  $wwwStatus = 'waiting'
  if ($wwwResult.Ok) {
    $wwwStatus = 'OK'
  }

  Write-Host ("HTTPS root: {0} [{1}]" -f $root.Status, $rootStatus)
  Write-Host ("HTTPS www : {0} [{1}]" -f $wwwResult.Status, $wwwStatus)

  if ($allNsOk -and $allCnameOk -and $root.Ok -and $wwwResult.Ok) {
    Write-Host "`nDNS setup completed. lowlifenowife.com and www.lowlifenowife.com are both reachable." -ForegroundColor Green
    [console]::Beep(880, 500)
    [console]::Beep(988, 500)

    try {
      Add-Type -AssemblyName PresentationFramework -ErrorAction Stop
      [System.Windows.MessageBox]::Show(
        'DNS setup completed. lowlifenowife.com and www.lowlifenowife.com are both reachable.',
        'DNS propagation watcher'
      ) | Out-Null
    } catch {}

    break
  }

  Write-Host 'Not complete yet. Checking again in 5 minutes.' -ForegroundColor Yellow
  Start-Sleep -Seconds 300
}
