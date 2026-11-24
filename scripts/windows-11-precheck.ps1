# windows-11-precheck.ps1 — V1 rehearsal pre-checks P1–P3 (SPOOKY)
# Non-elevated. Changes nothing permanent: the LanceDB canary lives in %TEMP% and is deleted,
# and it installs with --no-cache so the rehearsal's on-camera install timing stays honest.
#
#   pwsh -File .\windows-11-precheck.ps1
#   pwsh -File .\windows-11-precheck.ps1 -SkipLanceCanary      # P2/P3 only

param(
    [switch]$SkipLanceCanary,
    [string]$VectorSnakeDir = 'C:\Dev\vector-snake'
)

"Precheck stamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"
function Step { param([string]$Title) Write-Host "`n--- $Title ---" -ForegroundColor Yellow }

# ---------------------------------------------------------------- P1
Step 'P1. LanceDB canary (CPU without AVX)'
if ($SkipLanceCanary) {
    'Skipped (-SkipLanceCanary)'
} else {
    $t = Join-Path $env:TEMP "lance-canary-$(Get-Random)"
    New-Item -ItemType Directory -Force -Path $t | Out-Null
    uv venv "$t\.venv" --python 3.11 -q
    uv pip install --no-cache -q --python "$t\.venv\Scripts\python.exe" lancedb
    @'
import os, shutil, tempfile, lancedb
d = os.path.join(tempfile.gettempdir(), "lancedb_canary")
shutil.rmtree(d, ignore_errors=True)
t = lancedb.connect(d).create_table("c", data=[{"vector": [1.0, 0.0], "id": "a"}, {"vector": [0.0, 1.0], "id": "b"}])
print("lancedb", lancedb.__version__, "nearest:", t.search([0.9, 0.1]).limit(1).to_list()[0]["id"])
shutil.rmtree(d, ignore_errors=True)
'@ | Set-Content "$t\canary.py"
    & "$t\.venv\Scripts\python.exe" "$t\canary.py"
    $code = $LASTEXITCODE
    if ($code -eq 0) { 'P1 VERDICT: PASS (lancedb imports and searches on this CPU)' }
    elseif ($code -eq -1073741795) { 'P1 VERDICT: FAIL — 0xC000001D ILLEGAL INSTRUCTION. Stop: V1 §6B and V3–V5 need a new plan.' }
    else { "P1 VERDICT: FAIL — exit $code. Read the error above and classify it." }
    Remove-Item -Recurse -Force $t -ErrorAction SilentlyContinue
}

# ---------------------------------------------------------------- P2
Step 'P2. vector-snake inventory'
$vs = Join-Path $VectorSnakeDir 'vector_snake_v2.py'
"vector_snake_v2.py present : $(Test-Path $vs)"
$candidates = @(
    (Join-Path $VectorSnakeDir '.venv\Scripts\python.exe'),
    (Join-Path $VectorSnakeDir 'venv\Scripts\python.exe')
)
$VsPy = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $VsPy) {
    $VsPy = (Get-Command python -ErrorAction SilentlyContinue | Select-Object -First 1).Source
    "No project venv found; falling back to PATH python: $VsPy"
}
if ($VsPy -and $VsPy -like '*.bat') {
    # A pyenv shim resolves per directory (.python-version) and wraps exit codes in cmd.exe.
    # Pin the real interpreter so vector-snake runs the same Python from any folder.
    $real = & $VsPy -c "import sys; print(sys.executable)"
    "Resolved shim $VsPy -> $real"
    $VsPy = $real
}
"VS_PY (the interpreter that will run vector-snake): $VsPy"
if ($VsPy) {
    & $VsPy -c "import sys; print('sys.prefix          :', sys.prefix); print('is a venv           :', sys.prefix != sys.base_prefix)"
    & $VsPy -c "import sentence_transformers, torch, transformers; print('sentence-transformers', sentence_transformers.__version__, '| torch', torch.__version__, '| transformers', transformers.__version__)"
    if (Test-Path $vs) { & $VsPy $vs --version }
    # Freeze snapshot: compared after the capstone to prove nothing was installed into this env.
    New-Item -ItemType Directory -Force -Path (Join-Path $env:USERPROFILE 'vault-1\rehearsal') | Out-Null
    $freeze = Join-Path $env:USERPROFILE 'vault-1\vs-freeze-before.txt'
    & $VsPy -m pip freeze 2>$null | Set-Content $freeze
    "pip freeze saved     : $freeze ($((Get-Content $freeze | Measure-Object).Count) packages)"
}
$MiniLM = Join-Path $env:USERPROFILE '.cache\huggingface\hub\models--sentence-transformers--all-MiniLM-L6-v2'
"MiniLM in HF hub cache: $(Test-Path $MiniLM)   ($MiniLM)"
"  -> True means: hf cache ls will NOT error before H2, and lists TWO repos after H2."
"  -> True also means: never delete the HF hub cache as a whole in a restore."

# ---------------------------------------------------------------- P3
Step 'P3. Disk and memory headroom'
Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'" |
    Select-Object DeviceID, @{n='FreeGB';e={[math]::Round($_.FreeSpace/1GB,1)}}, @{n='SizeGB';e={[math]::Round($_.Size/1GB,1)}}
$os = Get-CimInstance Win32_OperatingSystem
"Free physical memory: {0:N0} KB of {1:N0} KB" -f $os.FreePhysicalMemory, $os.TotalVisibleMemorySize
"`nNext: set `$VS_PY in every new tab before the capstone:  `$VS_PY = '$VsPy'"
