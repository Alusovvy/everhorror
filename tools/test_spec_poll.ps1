# Integration checks in owned temporary Git repositories; never uses project remotes.
$ErrorActionPreference = 'Stop'
# Output of the child pwsh is decoded with the console code page (852 by default on Windows),
# which breaks Polish diacritics; force UTF-8 for the duration of the test and restore afterwards.
$previousConsoleEncoding = [Console]::OutputEncoding
$previousOutputEncoding = $OutputEncoding
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
$OutputEncoding = [Text.UTF8Encoding]::new($false)
$poller = Join-Path $PSScriptRoot 'spec_poll.ps1'
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ('everhorror-poller-' + [guid]::NewGuid().ToString('N'))
$specTest = Join-Path $testRoot 'specification'
$gameTest = Join-Path $testRoot 'game'
$stateTest = Join-Path $testRoot 'notification-state'
$shellPath = (Get-Process -Id $PID).Path

function Assert-True([bool]$condition, [string]$message) {
    if (-not $condition) { throw "FAILED: $message; poller exit=$script:pollCode; output=$script:pollOutput" }
}
function Git-Test([string]$repo, [string[]]$gitArguments) {
    $output = & git -C $repo @gitArguments 2>&1
    if ($LASTEXITCODE -ne 0) { throw "fixture git: $output" }
    return ($output -join [Environment]::NewLine)
}
function Poll-Test([string[]]$extra) {
    $script:pollOutput = (& $shellPath -NoProfile -File $poller -GamePath $gameTest -SpecPath $specTest -StateDirectory $stateTest @extra 2>&1) -join [Environment]::NewLine
    $script:pollCode = $LASTEXITCODE
}

try {
    New-Item -ItemType Directory -Path (Join-Path $specTest 'dashboard'), $gameTest -Force | Out-Null
    foreach ($repo in @($specTest, $gameTest)) {
        & git init -q -b master $repo
        if ($LASTEXITCODE -ne 0) { throw 'git init fixture failed' }
        Git-Test $repo @('config', 'user.name', 'Poller Test') | Out-Null
        Git-Test $repo @('config', 'user.email', 'test@everhorror.invalid') | Out-Null
        Set-Content -LiteralPath (Join-Path $repo 'README.md') -Value '# Fixture'
        Git-Test $repo @('add', '.') | Out-Null
        Git-Test $repo @('commit', '-qm', 'fixture') | Out-Null
    }
    @'
import { existsSync, readFileSync } from 'node:fs';
if (existsSync(new URL('../fail', import.meta.url))) { console.error('fixture CLI failure'); process.exit(1); }
process.stdout.write(readFileSync(new URL('../status.json', import.meta.url), 'utf8'));
'@ | Set-Content -LiteralPath (Join-Path $specTest 'dashboard/cli.ts') -Encoding utf8
    $fixture = @{changes=@{actionable=2};branches=@(@{branch='spec/test';state='🧪'});openTickets=@(@{file='ticket.md';status='📥'})}
    $fixture | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $specTest 'status.json') -Encoding utf8
    Git-Test $gameTest @('branch', 'spec/test') | Out-Null
    $refs = Git-Test $specTest @('show-ref')

    Poll-Test @('-DryRun')
    Assert-True ($pollCode -eq 0 -and $pollOutput -match '2 zmian' -and $pollOutput -match 'spec/test') 'DryRun reports pending changes and merged branch'
    Assert-True (-not (Test-Path -LiteralPath $stateTest)) 'DryRun creates no state directory'
    Assert-True ((Git-Test $specTest @('show-ref')) -eq $refs) 'DryRun leaves refs unchanged'
    Poll-Test @('-DryRun', '-Register')
    Assert-True ($pollCode -ne 0 -and -not (Test-Path -LiteralPath $stateTest)) 'conflicting registration flags fail without side effects'

    Poll-Test @('-LocalOnly')
    Assert-True ($pollCode -eq 0 -and $pollOutput -match 'Pracę rozpoczyna osoba') 'normal local notification succeeds'
    $stateFile = Join-Path $stateTest 'last-notification.txt'
    $state = Get-Content -LiteralPath $stateFile -Raw
    $logFile = Join-Path $stateTest 'powiadomienia.log'
    $log = Get-Content -LiteralPath $logFile -Raw
    Poll-Test @('-LocalOnly')
    Assert-True ($pollCode -eq 0 -and $pollOutput -match 'Bez nowych') 'same state is deduplicated'
    Assert-True ((Get-Content -LiteralPath $logFile -Raw) -eq $log) 'deduplicated run does not append log'

    Set-Content -LiteralPath (Join-Path $specTest 'fail') -Value 'fail'
    Poll-Test @('-LocalOnly')
    Assert-True ($pollCode -ne 0) 'CLI error is not an empty queue'
    Assert-True ((Get-Content -LiteralPath $stateFile -Raw) -eq $state) 'CLI error preserves last reported state'
    Remove-Item -LiteralPath (Join-Path $specTest 'fail')
    Git-Test $gameTest @('branch', '-d', 'spec/test') | Out-Null
    Poll-Test @('-LocalOnly')
    Assert-True ($pollCode -eq 0 -and $pollOutput -notmatch 'Bez nowych') 'merged branch change notifies even with same spec commit'
    Write-Output 'RESULT: ALL PASSED (poller: DryRun, flags, notification, deduplication, CLI failure, merged-state change)'
}
finally {
    [Console]::OutputEncoding = $previousConsoleEncoding
    $OutputEncoding = $previousOutputEncoding
    # Resolve and verify the entire recursive cleanup target before deleting it.
    $resolvedTest = [IO.Path]::GetFullPath($testRoot)
    $resolvedTemp = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd([IO.Path]::DirectorySeparatorChar)
    if ($resolvedTest.StartsWith($resolvedTemp + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase) -and (Split-Path $resolvedTest -Leaf) -match '^everhorror-poller-[0-9a-f]{32}$') {
        if (Test-Path -LiteralPath $resolvedTest) { Remove-Item -LiteralPath $resolvedTest -Recurse -Force }
    } else { throw "Unsafe cleanup target: $resolvedTest" }
}
