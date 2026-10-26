<#
.SYNOPSIS
  Reports pending specification work. Never starts a model or changes work items.
.DESCRIPTION
  Normal run fetches the specification upstream, reads CLI status and reports changes,
  tickets and merged deployment branches. State is only the last reported notification.
  DryRun reads locally known refs without fetch, logging, state files or registration.
.EXAMPLE
  pwsh -File tools/spec_poll.ps1 -DryRun
.EXAMPLE
  pwsh -File tools/spec_poll.ps1 -LocalOnly
#>
[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Register,
    [switch]$Unregister,
    [switch]$LocalOnly,
    # Retained for old callers; read-only notifications also work with a dirty spec.
    [switch]$IgnoreDirty,
    [ValidateRange(1, 1440)][int]$Minutes = 15,
    # Optional isolated repository paths for tests; defaults are the project layout.
    [string]$GamePath,
    [string]$SpecPath,
    [string]$StateDirectory
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$env:GIT_TERMINAL_PROMPT = '0'
$env:GCM_INTERACTIVE = 'never'
$taskName = 'Everhorror spec-sync'
if (($DryRun -and ($Register -or $Unregister)) -or ($Register -and $Unregister)) {
    Write-Error 'DryRun nie może rejestrować ani usuwać zadania; wybierz jedną operację.'
    exit 1
}
if (-not $GamePath) { $GamePath = Join-Path $PSScriptRoot '..' }
$GamePath = [IO.Path]::GetFullPath($GamePath)
if (-not $SpecPath) { $SpecPath = Join-Path (Split-Path -Parent $GamePath) 'specification' }
$SpecPath = [IO.Path]::GetFullPath($SpecPath)
if (-not $StateDirectory) { $StateDirectory = Join-Path $GamePath 'reports/spec-sync' }
$StateDirectory = [IO.Path]::GetFullPath($StateDirectory)

if ($Register) {
    $argument = [string]::Format('-NoProfile -WindowStyle Hidden -File "{0}"', $PSCommandPath)
    $action = New-ScheduledTaskAction -Execute 'pwsh.exe' -Argument $argument -WorkingDirectory $GamePath
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes $Minutes)
    $settings = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Description 'Everhorror: tylko powiadomienia o zmianach specyfikacji i scalonych gałęziach; pracę rozpoczyna osoba.' -Force | Out-Null
    Write-Output "Zarejestrowano powiadomienia '$taskName' (co $Minutes min)."
    exit 0
}
if ($Unregister) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    Write-Output "Usunięto zadanie '$taskName'."
    exit 0
}

function Invoke-ProjectGit([string]$repository, [string[]]$arguments) {
    $output = & git -C $repository @arguments 2>&1
    if ($LASTEXITCODE -ne 0) { throw "git: $($output -join ' ')" }
    return ($output -join [Environment]::NewLine).Trim()
}

try {
    $scope = if ($DryRun -or $LocalOnly) { 'lokalnie znane refy, bez fetch' } else { 'upstream po fetch' }
    if (-not $DryRun -and -not $LocalOnly) {
        Invoke-ProjectGit $SpecPath @('fetch', '--quiet') | Out-Null
        $head = Invoke-ProjectGit $SpecPath @('rev-parse', '@{u}')
    } else {
        $head = Invoke-ProjectGit $SpecPath @('rev-parse', 'HEAD')
    }
    $statusText = (& node (Join-Path $SpecPath 'dashboard/cli.ts') status --json --rev $head 2>&1) -join [Environment]::NewLine
    if ($LASTEXITCODE -ne 0) { throw "cli status: $statusText" }
    $status = $statusText | ConvertFrom-Json
    if ($null -eq $status.changes -or $null -eq $status.changes.actionable) { throw 'cli status: brak pola changes.actionable' }
    $mergedText = Invoke-ProjectGit $GamePath @('branch', '--merged', 'master', '--list', 'spec/*')
    $merged = @($mergedText -split '[\r\n]+' | ForEach-Object { $_.Trim(' ', '*', '+') } | Where-Object { $_ })
    $toFinalize = @()
    foreach ($branch in $status.branches) {
        $values = @($branch.PSObject.Properties | ForEach-Object { $_.Value })
        if ($values.Count -lt 2) { continue }
        $name = @($values | ForEach-Object { ([string]$_ -replace [char]96, '').Trim() } | Where-Object { $_ -match '^spec/' }) | Select-Object -First 1
        $waiting = @($values | Where-Object { [string]$_ -match '🔧|🧪' }).Count -gt 0
        if ($name -and $waiting -and $merged -contains $name) { $toFinalize += $name }
    }
    $toFinalize = @($toFinalize | Sort-Object -Unique)
    $newTickets = @($status.openTickets | Where-Object { $_.status -eq '📥' })
    # Include merged-branch changes even when the spec commit has not changed.
    $notificationKey = "$scope|$head|$($status.changes.actionable)|$($newTickets.file -join ',')|$($toFinalize -join ',')"
    $stateFile = Join-Path $StateDirectory 'last-notification.txt'
    $previous = if (Test-Path -LiteralPath $stateFile) { (Get-Content -LiteralPath $stateFile -Raw).Trim() } else { '' }
    $messages = @(
        "specyfikacja $($head.Substring(0,7)): $($status.changes.actionable) zmian do zaplanowania",
        "zgłoszenia 📥: $($newTickets.Count)"
    )
    if ($toFinalize.Count) { $messages += "scalone gałęzie do domknięcia (finalize): $($toFinalize -join ', ')" }
    $message = $messages -join '; '
    if ($DryRun) {
        Write-Output "DryRun ($scope): $message"
        Write-Output 'Pracę rozpoczyna osoba: spec-tasks / ai-task / spec-sync. Bez zmian plików i refów.'
        exit 0
    }
    if ($notificationKey -eq $previous) { Write-Output "Bez nowych powiadomień ($scope)."; exit 0 }
    New-Item -ItemType Directory -Path $StateDirectory -Force | Out-Null
    Add-Content -LiteralPath (Join-Path $StateDirectory 'powiadomienia.log') -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $message ($scope)" -Encoding utf8
    Set-Content -LiteralPath $stateFile -Value $notificationKey -Encoding utf8
    Write-Output "$message ($scope). Pracę rozpoczyna osoba."
}
catch {
    Write-Error "Powiadomienie nie powstało: $($_.Exception.Message)"
    exit 1
}
