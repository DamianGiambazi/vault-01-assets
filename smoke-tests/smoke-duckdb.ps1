# smoke-duckdb.ps1 — Vault 1 smoke test for the DuckDB CLI.
# Run in PowerShell 7, in a NEW tab after installing DuckDB (the installer changed PATH).
# Install: winget install --id DuckDB.cli --exact --accept-source-agreements --accept-package-agreements
function Step([string]$Name, [scriptblock]$Do) {
    Write-Host "`n--- $Name ---" -ForegroundColor Yellow
    & $Do
    if ($LASTEXITCODE) { throw "FAILED: $Name (exit $LASTEXITCODE)" }
}

Step 'version'      { duckdb --version }                                      # expect: v1.5.6 …
Step 'first query'  { duckdb -c "SELECT 'SMOKE_OK' AS status, 42 AS answer;" } # expect: SMOKE_OK | 42

# A CSV written as a LIST of lines: one line-ending convention. (Typed as a here-string at the
# prompt, the same rows mixed two conventions and DuckDB's strict reader refused the file.)
$fixture = Join-Path $env:TEMP 'duckdb_smoke.csv'
Set-Content $fixture -Encoding utf8NoBOM -Value 'asset,rms,zcr', 'sine_440,0.100,0.092', 'noise_white,0.098,0.497', 'metronome_120,0.101,0.088'
Step 'read a file from disk' { duckdb -c "SELECT asset, zcr, round(zcr/rms,2) AS ratio FROM read_csv_auto('$fixture') ORDER BY zcr DESC;" }
Remove-Item $fixture                                                            # expect above: noise_white first, ratio 5.07

"`nDUCKDB_SMOKE_OK"
