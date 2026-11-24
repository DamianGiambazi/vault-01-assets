# windows-11-restore.ps1 v2.2 — Return SPOOKY to its pre-Vault-1 state (rehearsal reset)
# Non-elevated. Reverse install order. Each step reports; nothing fails silently.
#
# WARNING: After the REAL recording, run with -KeepSmokeLab.
# Videos 3 and 4 depend on C:\Dev\smoke-lab\.venv (LanceDB).
#
#   pwsh -File .\windows-11-restore.ps1                 # full reset (rehearsal)
#   pwsh -File .\windows-11-restore.ps1 -KeepSmokeLab   # keep the venv (and the capstone folder inside it)
#
# v2.1 (2026-10-15): removes Ollama leftovers the uninstaller can leave (the gap scan tests
# Programs\Ollama), the bert lock folder, and the capstone's temp table. Never touches the rest
# of the Hugging Face hub cache: vector-snake's all-MiniLM-L6-v2 lives there.
#
# v2.2 (2026-10-15, after rehearsal 1 on SPOOKY): neither uninstaller removes the User PATH entry
# its installer added (DuckDB.cli package folder, Programs\Ollama). Section E removes exactly those
# two, reading and writing the RAW registry value so %VARIABLES% and the value type are preserved.
# The per-model ollama stop/rm loop is gone: it only printed noise, and the model store is deleted
# whole anyway.

param([switch]$KeepSmokeLab)

$Stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'
"Restore stamp: $Stamp"

function Step { param([string]$Title) Write-Host "`n--- $Title ---" -ForegroundColor Yellow }
function Remove-IfPresent {
    param([string]$Path)
    if (Test-Path $Path) { Remove-Item -Recurse -Force $Path; "Removed $Path" }
    else { "Absent  $Path" }
}

# D. Ollama: unload, stop, uninstall, remove model store and leftovers
Step 'D. Ollama'
if (Get-Command ollama -ErrorAction SilentlyContinue) { ollama list }   # record what is about to go
Get-Process -Name 'ollama*' -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2
winget uninstall --id Ollama.Ollama --exact --silent --accept-source-agreements
Remove-IfPresent (Join-Path $env:USERPROFILE '.ollama')
Remove-IfPresent (Join-Path $env:LOCALAPPDATA 'Programs\Ollama')
Remove-IfPresent (Join-Path $env:LOCALAPPDATA 'Ollama')

# C. Hugging Face CLI + the one cache entry H2 created
Step 'C. Hugging Face Hub CLI'
uv tool uninstall huggingface-hub
$Hub = Join-Path $env:USERPROFILE '.cache\huggingface\hub'
Remove-IfPresent (Join-Path $Hub 'models--bert-base-uncased')
Remove-IfPresent (Join-Path $Hub '.locks\models--bert-base-uncased')
"Kept    $Hub (other entries, e.g. vector-snake's all-MiniLM-L6-v2, are not V1's to remove)"

# B. LanceDB smoke lab (contains the capstone folder) + temp tables
Step 'B. LanceDB (smoke-lab)'
if ($KeepSmokeLab) {
    "Kept C:\Dev\smoke-lab (-KeepSmokeLab)"
} else {
    Remove-IfPresent 'C:\Dev\smoke-lab'
}
Remove-IfPresent (Join-Path $env:TEMP 'lancedb_smoke')
Remove-IfPresent (Join-Path $env:TEMP 'lancedb_capstone')

# A. DuckDB CLI + fixture
Step 'A. DuckDB CLI'
winget uninstall --id DuckDB.cli --exact --silent --accept-source-agreements
Remove-IfPresent (Join-Path $env:TEMP 'duckdb_smoke.csv')

# E. User PATH entries the installers added and the uninstallers leave behind
Step 'E. User PATH'
$EnvKey   = 'HKCU:\Environment'
$Item     = Get-Item $EnvKey
$Kind     = $Item.GetValueKind('Path')                                        # usually ExpandString
$Raw      = $Item.GetValue('Path', '', 'DoNotExpandEnvironmentNames')          # keep %VARS% as typed
$Patterns = '*\Microsoft\WinGet\Packages\DuckDB.cli_*', '*\Programs\Ollama', '*\Programs\Ollama\'
$Keep = [System.Collections.Generic.List[string]]::new()
$Gone = [System.Collections.Generic.List[string]]::new()
foreach ($Entry in ($Raw -split ';')) {
    $Hit = $false
    foreach ($Pattern in $Patterns) { if ($Entry -like $Pattern) { $Hit = $true } }
    if ($Hit) { $Gone.Add($Entry) } else { $Keep.Add($Entry) }
}
if ($Gone.Count) {
    Set-ItemProperty -Path $EnvKey -Name Path -Value ($Keep -join ';') -Type $Kind
    $Gone | ForEach-Object { "Removed PATH entry $_" }
} else {
    "No V1 PATH entries present"
}

# Verify: the gap scan must show four NOT FOUND again.
Step 'Verification'
"Open a NEW terminal (PATH refresh), then run:"
"  .\windows-11-gap-scan.ps1    -> duckdb, hf, ollama, lancedb: NOT FOUND; Ollama dir/store False"
"  .\windows-11-shadow.ps1      -> must match the pre-flight shadow capture"
"  Compare User PATH with the pre-flight snapshot -> no differences (outline Appendix R)."
