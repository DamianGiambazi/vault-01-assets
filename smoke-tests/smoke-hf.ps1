# smoke-hf.ps1 — Vault 1 smoke test for the Hugging Face CLI (hub 2.2.0).
# Run in PowerShell 7, in a NEW tab after: uv tool install huggingface-hub==2.2.0
# Two warnings are expected and are not errors: no token (anonymous on purpose) and
# no symlinks (Windows needs Developer Mode for them, so files are copied instead).
function Step([string]$Name, [scriptblock]$Do) {
    Write-Host "`n--- $Name ---" -ForegroundColor Yellow
    & $Do
    if ($LASTEXITCODE) { throw "FAILED: $Name (exit $LASTEXITCODE)" }
}

Step 'version' { hf --version }                                       # expect: 2.2.0
Step 'environment, no token' { hf env }                                # expect: Has saved token ?: False

# A tiny, pinned download: a fixed commit can never change under you.
$p = hf download bert-base-uncased config.json --revision 86b5e0934494bd15c9632b12f734a8a67f723594 --quiet
if ($LASTEXITCODE -or -not (Test-Path $p)) { throw 'FAILED: pinned download' }
"path : $p"
"bytes: $((Get-Item $p).Length)"                                       # expect: 570
Get-Content $p | Select-Object -First 3                                # expect: { / "architectures": [ / "BertForMaskedLM"

Step 'cache, before clean-up' { hf cache ls }
Remove-Item -Recurse -Force (Join-Path $env:USERPROFILE '.cache\huggingface\hub\models--bert-base-uncased')
Step 'cache, after clean-up' { hf cache ls }                           # the test file is gone again

"`nHF_SMOKE_OK"
