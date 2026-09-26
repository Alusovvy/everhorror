<#
.SYNOPSIS
  Checks the design spec (../specification) and starts the agent when there is work.

.DESCRIPTION
  Cheap check first (git fetch + the spec CLI); Claude is started only when:
    - a spec/* deployment branch was merged into the game master  -> /spec-sync finalize
    - the spec master moved and has changes for the game or 📥 tickets -> /spec-tasks (writes
      docs/ai-tasks/task_NN.md files only; implementing is /ai-task implement NN, started by a person)
  A branch waiting for review does not stop task planning. Nothing starts while the spec working copy
  has uncommitted edits, or while another run holds the lock. Logs: reports/spec-sync/.

.EXAMPLE
  pwsh -File tools/spec_poll.ps1 -DryRun     # say what would happen, start nothing
  pwsh -File tools/spec_poll.ps1             # one check (what the scheduled task runs)
  pwsh -File tools/spec_poll.ps1 -Register   # Windows Task Scheduler, every 15 min while logged on
  pwsh -File tools/spec_poll.ps1 -Unregister
#>
param(
	[switch]$DryRun,
	[switch]$Register,
	[switch]$Unregister,
	# Testing only (with -DryRun): check even when the spec working copy has uncommitted edits.
	[switch]$IgnoreDirty,
	[int]$Minutes = 15
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Unattended: git must fail instead of waiting for a credential prompt nobody sees.
$env:GIT_TERMINAL_PROMPT = '0'
$env:GCM_INTERACTIVE = 'never'
$TaskName = 'Everhorror spec-sync'
$Game = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Root = Split-Path -Parent $Game
$Spec = Join-Path $Root 'specification'
$Worktree = Join-Path $Root 'everhorror-wdrozenie'
$StateDir = Join-Path $Game 'reports/spec-sync'
$LastFile = Join-Path $StateDir 'last-head.txt'
$LockFile = Join-Path $StateDir 'lock'
$LogFile = Join-Path $StateDir 'poll.log'

if ($Register) {
	$action = New-ScheduledTaskAction -Execute 'pwsh.exe' -Argument "-NoProfile -WindowStyle Hidden -File `"$PSCommandPath`"" -WorkingDirectory $Game
	$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes $Minutes)
	$settings = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Hours 3) -StartWhenAvailable
	Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Description 'Sprawdza specyfikację Everhorror; nowe zmiany zamienia w zadania (spec-tasks), scalone gałęzie domyka (spec-sync finalize).' -Force | Out-Null
	Write-Output "Zarejestrowano zadanie '$TaskName' (co $Minutes min, tylko gdy jesteś zalogowany)."
	exit 0
}
if ($Unregister) {
	Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
	Write-Output "Usunięto zadanie '$TaskName'."
	exit 0
}

New-Item -ItemType Directory -Force $StateDir | Out-Null

function Log([string]$msg) {
	$line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $msg"
	Add-Content -Path $LogFile -Value $line -Encoding utf8
	Write-Output $line
}

function Invoke-Git([string]$repo) {
	$out = & git -C $repo @args 2>&1
	if ($LASTEXITCODE -ne 0) { throw "git -C $repo $($args -join ' '): $out" }
	return $out
}

# One run at a time; a lock older than 3 h is stale (crashed run).
if (Test-Path $LockFile) {
	$age = (Get-Date) - (Get-Item $LockFile).LastWriteTime
	if ($age.TotalHours -lt 3) { Log "pomijam: trwa inne uruchomienie ($(Get-Content $LockFile -Raw))"; exit 0 }
	Log 'stara blokada (ponad 3 h), usuwam'
	Remove-Item $LockFile -Force
}

try {
	Invoke-Git $Spec fetch --quiet | Out-Null
	$remoteHead = (Invoke-Git $Spec rev-parse '@{u}').Trim()
	$last = if (Test-Path $LastFile) { (Get-Content $LastFile -Raw).Trim() } else { '' }

	if ((Invoke-Git $Spec status --porcelain) -and -not ($DryRun -and $IgnoreDirty)) {
		Log 'pomijam: w kopii specyfikacji są niezacommitowane zmiany (ktoś ją edytuje ręcznie)'
		exit 0
	}

	$status = (& node (Join-Path $Spec 'dashboard/cli.ts') status --json --rev $remoteHead 2>&1) -join "`n"
	if ($LASTEXITCODE -ne 0) { throw "cli status: $status" }
	$st = $status | ConvertFrom-Json

	# Deployment branches waiting in WDROZENIA.md → merged into the game master?
	$merged = @(& git -C $Game branch --merged master --list 'spec/*' 2>$null | ForEach-Object { $_.Trim(' ', '*', '+') })
	$waiting = @()
	$toFinalize = @()
	foreach ($b in $st.branches) {
		$name = ($b.PSObject.Properties | Select-Object -First 1).Value -replace '`', ''
		$state = ($b.PSObject.Properties | Select-Object -Last 1).Value
		if ($state -match '🔧|🧪') {
			if ($merged -contains $name) { $toFinalize += $name } else { $waiting += $name }
		}
	}

	$mode = $null
	if ($toFinalize.Count) {
		$mode = 'finalize'
		Log "scalone gałęzie do domknięcia: $($toFinalize -join ', ')"
	}
	elseif ($remoteHead -ne $last) {
		if ($waiting.Count) { Log "czeka na sprawdzenie: $($waiting -join ', ') (zadania i tak powstaną)" }
		$newTickets = @($st.openTickets | Where-Object { $_.status -eq '📥' })
		if ($st.changes.actionable -gt 0 -or $newTickets.Count) {
			$mode = 'tasks'
			Log "spec $($remoteHead.Substring(0,7)): $($st.changes.actionable) zmian do wdrożenia, $($newTickets.Count) nowych zgłoszeń"
		}
		else {
			Log "spec $($remoteHead.Substring(0,7)): tylko zmiany redakcyjne, nic do wdrożenia"
			if (-not $DryRun) { Set-Content -Path $LastFile -Value $remoteHead -Encoding utf8 }
			exit 0
		}
	}
	elseif ($waiting.Count) {
		Log "czeka na sprawdzenie: $($waiting -join ', ')"
		exit 0
	}
	else {
		exit 0
	}

	# 'tasks' plans new spec changes as task files; 'finalize' closes merged branches.
	$command = if ($mode -eq 'tasks') { '/spec-tasks unattended' } else { "/spec-sync $mode unattended" }
	if ($DryRun) { Log "DryRun: uruchomiłbym $command"; exit 0 }

	Set-Content -Path $LockFile -Value "$mode $remoteHead pid $PID" -Encoding utf8
	$runLog = Join-Path $StateDir "run-$(Get-Date -Format 'yyyyMMdd-HHmmss')-$mode.log"
	Log "start $command → $runLog"
	Push-Location $Game
	try {
		& claude -p $command --permission-mode acceptEdits --add-dir $Spec --add-dir $Worktree *> $runLog
		$code = $LASTEXITCODE
	}
	finally { Pop-Location }
	Log "koniec $command (kod $code)"
	if ($code -eq 0 -and $mode -eq 'tasks') { Set-Content -Path $LastFile -Value $remoteHead -Encoding utf8 }
}
catch {
	Log "błąd: $($_.Exception.Message)"
	exit 1
}
finally {
	if (-not $DryRun -and (Test-Path $LockFile) -and ((Get-Content $LockFile -Raw) -match "pid $PID")) { Remove-Item $LockFile -Force }
}
