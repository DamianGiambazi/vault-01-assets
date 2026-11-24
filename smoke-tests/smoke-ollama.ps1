# smoke-ollama.ps1 — Vault 1 smoke test for Ollama and the Vault 1 model.
# Run in PowerShell 7, in a NEW tab after: winget install --id Ollama.Ollama --exact
# The check is the model's LIFECYCLE (pull, load, answer, unload), not its exact words:
# a language model is probabilistic, so its wording is not a pass/fail signal.
$Model = 'smollm2:360m-instruct-q8_0'
function Step([string]$Name, [scriptblock]$Do) {
    Write-Host "`n--- $Name ---" -ForegroundColor Yellow
    & $Do
    if ($LASTEXITCODE) { throw "FAILED: $Name (exit $LASTEXITCODE)" }
}

Step 'version' { ollama --version }
Write-Host "`n--- service ---" -ForegroundColor Yellow
Get-Process ollama* | Select-Object Name, Id                            # expect: ollama, ollama app
Step 'pull the model (386 MB; instant if already present)' { ollama pull $Model }
Step 'one reply' { 'Say exactly: SMOKE_OK' | ollama run $Model }
Step 'loaded'    { ollama ps }                                          # expect: ~582 MB, 100% CPU
Step 'unload'    { ollama stop $Model }
Step 'unloaded'  { ollama ps }                                          # expect: the header row only

"`nOLLAMA_SMOKE_OK"
