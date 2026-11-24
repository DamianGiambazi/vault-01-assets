# windows-11-gap-scan.ps1 v2.1 — Phase 5: AI Layer Gap Probe (SPOOKY)
# Read-only. Non-elevated. Changes nothing. Safe to run before and after installs.
# v2.1 (2026-10-15): section 3b reports AI packages already in the GLOBAL Python (rehearsal finding R9).
# They pre-date V1 (vector-snake's experiments) and are outside its scope: reported, never removed.

$PhaseStamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'
"Phase 5 stamp: $PhaseStamp"

function Probe-Command {
    param([string]$Name)
    $c = @(Get-Command $Name -All -ErrorAction SilentlyContinue)
    if ($c.Count -gt 0) {
        "{0,-8}: FOUND  ({1} shadow(s)) {2}" -f $Name, $c.Count, $c[0].Source
    } else {
        "{0,-8}: NOT FOUND" -f $Name
    }
}

$Lab    = 'C:\Dev\smoke-lab'
$LabPy  = Join-Path $Lab '.venv\Scripts\python.exe'
$OllDir = Join-Path $env:LOCALAPPDATA 'Programs\Ollama'
$OllHome = Join-Path $env:USERPROFILE '.ollama'

Write-Host "`n--- 1. Ambient AI CLIs ---" -ForegroundColor Yellow
Probe-Command 'duckdb'
Probe-Command 'hf'
$uvTools = uv tool list 2>$null | Select-String -Pattern 'duckdb|huggingface|polars|jupyter|onnx'
if ($uvTools) { "uv tools (AI-related):"; $uvTools } else { "uv tools (AI-related): none" }

Write-Host "`n--- 2. Local Inference ---" -ForegroundColor Yellow
Probe-Command 'ollama'
"Ollama install dir : $(Test-Path $OllDir)"
"Ollama model store : $(Test-Path $OllHome)"

Write-Host "`n--- 3. Project-Scoped Vector Store ---" -ForegroundColor Yellow
if (Test-Path $LabPy) {
    $v = & $LabPy -c "import lancedb; print(lancedb.__version__)" 2>$null
    if ($LASTEXITCODE -eq 0) { "lancedb : FOUND  (smoke-lab venv) $v" }
    else { "lancedb : NOT FOUND (smoke-lab venv exists, package absent)" }
} else {
    "lancedb : NOT FOUND (no smoke-lab venv)"
}

Write-Host "`n--- 3b. Ambient Python (global interpreter, pre-existing) ---" -ForegroundColor Yellow
$GlobalPy = $null
if (Get-Command python -ErrorAction SilentlyContinue) {
    $GlobalPy = & python -c "import sys; print(sys.executable)" 2>$null      # resolve the pyenv shim once
}
if ($GlobalPy) {
    "python  : $GlobalPy"
    $Probe = "import importlib.metadata as m; d={x.metadata['Name'].lower().replace('_','-'): x.version for x in m.distributions()}; w=['lancedb','duckdb','huggingface-hub','torch','sentence-transformers','openai']; print(' | '.join(k+' '+d[k] for k in w if k in d) or 'none')"
    $Found = & $GlobalPy -c $Probe 2>$null
    "AI packages: $Found"
    if ($Found -and $Found -ne 'none') { "NOTE: ambient AI packages outside V1 (policy exception, logged in V1-REHEARSAL-01 R9)" }
} else {
    "python  : NOT FOUND"
}

Write-Host "`n--- 4. WSL Memory Governance ---" -ForegroundColor Yellow
$WslCfg = Join-Path $env:USERPROFILE '.wslconfig'
if (Test-Path $WslCfg) { "WSL config FOUND:"; Get-Content $WslCfg }
else { 
    "WSL config: NOT FOUND"
}

Write-Host "`n--- 5. Memory Headroom ---" -ForegroundColor Yellow
$os = Get-CimInstance Win32_OperatingSystem
"Free physical memory: {0:N0} KB of {1:N0} KB" -f $os.FreePhysicalMemory, $os.TotalVisibleMemorySize
"uv cache dir: $(uv cache dir 2>$null)"
