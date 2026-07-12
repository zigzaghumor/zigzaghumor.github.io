param(
    [switch]$Fetch
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $root '_data/upstream.yml'
$config = Get-Content $configPath
$repository = (($config | Select-String '^repository:\s*(.+)$').Matches.Groups[1].Value).Trim()
$branch = (($config | Select-String '^branch:\s*(.+)$').Matches.Groups[1].Value).Trim()
$baseline = (($config | Select-String '^baseline:\s*(.+)$').Matches.Groups[1].Value).Trim()
$paths = @()
$readingPaths = $false

foreach ($line in $config) {
    if ($line -match '^paths:\s*$') {
        $readingPaths = $true
        continue
    }
    if ($readingPaths -and $line -match '^\s+-\s+(.+)$') {
        $paths += $Matches[1].Trim()
    }
}

Push-Location $root
try {
    $upstreamUrl = "https://github.com/$repository.git"
    $existingRemote = git remote get-url upstream 2>$null
    if ($LASTEXITCODE -ne 0) {
        git remote add upstream $upstreamUrl
    } elseif ($existingRemote -ne $upstreamUrl) {
        git remote set-url upstream $upstreamUrl
    }

    if ($Fetch) {
        git fetch upstream $branch
        if ($LASTEXITCODE -ne 0) { throw 'Unable to fetch upstream.' }
    }

    git cat-file -e "$baseline^{commit}" 2>$null
    if ($LASTEXITCODE -ne 0) { throw "Baseline commit $baseline is unavailable." }

    $latest = (git rev-parse "upstream/$branch").Trim()
    if ($latest -eq $baseline) {
        Write-Host "Upstream is unchanged at $baseline."
        exit 0
    }

    git merge-base --is-ancestor $baseline $latest
    if ($LASTEXITCODE -ne 0) { throw 'Upstream history no longer contains the recorded baseline.' }

    $upstreamChanged = @(git diff --name-only "$baseline..$latest" -- $paths | Where-Object { $_ })
    $localChanged = @(git diff --name-only $baseline HEAD -- $paths | Where-Object { $_ })
    $overlap = @($upstreamChanged | Where-Object { $localChanged -contains $_ } | Sort-Object -Unique)

    Write-Host "New upstream commits:"
    git log --oneline "$baseline..$latest"
    Write-Host "Changed tracked paths:"
    $upstreamChanged | ForEach-Object { Write-Host "  $_" }

    if ($overlap.Count -gt 0) {
        Write-Error ("Potential integration overlap:`n  " + ($overlap -join "`n  "))
    }

    Write-Host 'Upstream changes do not overlap locally modified tracked files.'
}
finally {
    Pop-Location
}
