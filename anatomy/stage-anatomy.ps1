# stage-anatomy.ps1 — pre-flight P14 for V1 §6E Beat 0 ("anatomy of a vector").
# Copies the finished 13 Oct vector-snake run of the Native AI Newsletter into vault-1\anatomy
# under plain names, and proves the copies are the originals (SHA-256 against vector-snake's own
# manifest). Read-only on the source. Run once, off camera:
#     Set-Location "$HOME\vault-1"
#     .\anatomy\stage-anatomy.ps1
param(
    [string]$VsRoot = 'C:\Dev\vector-snake',
    [string]$RunId  = '20261013_194027',
    [string]$Doc    = '51c2c11c',
    [string]$Dest   = (Join-Path $PSScriptRoot '.')
)
$ErrorActionPreference = 'Stop'

$src = @{
    txt      = Join-Path $VsRoot "TXT_input\$Doc.txt"
    csv      = Join-Path $VsRoot "vectors_output\${RunId}_${Doc}_vectors.csv"
    manifest = Join-Path $VsRoot "vectors_output\${RunId}_${Doc}_manifest.json"
}
foreach ($k in 'txt', 'csv', 'manifest') {
    if (-not (Test-Path -LiteralPath $src[$k])) { throw "ANATOMY_FAIL  missing $k : $($src[$k])" }
}

$m = Get-Content -LiteralPath $src.manifest -Raw | ConvertFrom-Json
$want = @{ txt = $m.source.sha256; csv = $m.output.csv_sha256 }
$have = @{
    txt = (Get-FileHash -LiteralPath $src.txt -Algorithm SHA256).Hash.ToLower()
    csv = (Get-FileHash -LiteralPath $src.csv -Algorithm SHA256).Hash.ToLower()
}
foreach ($k in 'txt', 'csv') {
    if ($have[$k] -ne $want[$k]) {
        throw "ANATOMY_FAIL  $k hash $($have[$k]) does not match the manifest's $($want[$k]). Re-run vector-snake on the newsletter and update -RunId."
    }
}

New-Item -ItemType Directory -Force -Path $Dest | Out-Null
Copy-Item -LiteralPath $src.txt      (Join-Path $Dest 'newsletter.txt')           -Force
Copy-Item -LiteralPath $src.csv      (Join-Path $Dest 'newsletter_vectors.csv')   -Force
Copy-Item -LiteralPath $src.manifest (Join-Path $Dest 'newsletter_manifest.json') -Force

"ANATOMY_STAGED  doc=$Doc  run=$RunId  chunks=$($m.chunking.chunk_count)  txt=$($have.txt.Substring(0,12))…  csv=$($have.csv.Substring(0,12))…"
