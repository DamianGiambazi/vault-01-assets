$PhaseStamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'
"Phase 3 stamp: $PhaseStamp"

function Show-Version {
    param([string]$Tool, [scriptblock]$Script)
    Write-Host "`n--- $Tool ---" -ForegroundColor Yellow
    try {
        $out = & $Script 2>&1
        $out | Select-Object -First 5 | ForEach-Object { Write-Host $_ }
    } catch {
        Write-Host "Failed: $_" -ForegroundColor Red
    }
}

Show-Version "git" { git --version }
Show-Version "cmake" { cmake --version }
Show-Version "ninja" { ninja --version }
Show-Version "clang" { clang --version }
Show-Version "clang-tidy" { clang-tidy --version }
Show-Version "vcpkg" { vcpkg version }
Show-Version "rustc" { rustc --version }
Show-Version "cargo" { cargo --version }
Show-Version "rustup" { rustup --version }
Show-Version "python" { python -VV }
Show-Version "uv" { uv --version }
Show-Version "pyenv" { pyenv --version }
Show-Version "node" { node --version }
Show-Version "npm" { npm --version }
Show-Version "nvm" { nvm version }
Show-Version "docker" { docker --version }
Show-Version "docker compose" { docker compose version }
Show-Version "docker buildx" { docker buildx version }
Show-Version "wsl" { wsl --version }
Show-Version "gcloud" { gcloud --version }
Show-Version "bq" { bq version }
Show-Version "gsutil" { gsutil version }
Show-Version "ffmpeg" { ffmpeg -version }
Show-Version "ffprobe" { ffprobe -version }
Show-Version "check-jsonschema" { check-jsonschema --version }
Show-Version "k6" { k6 version }
Show-Version "code" { code --version }
Show-Version "supabase" { supabase --version }
Show-Version "winget" { winget --version }

Write-Host "`n--- Visual Studio / MSVC ---" -ForegroundColor Yellow
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (Test-Path $vswhere) {
    "Display Name: $(& $vswhere -latest -products * -property displayName)"
    "Install Version: $(& $vswhere -latest -products * -property installationVersion)"
    "Catalog Line: $(& $vswhere -latest -products * -property catalog_productLineVersion)"
    $cl = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -find "VC\Tools\MSVC\*\bin\Hostx64\x64\cl.exe" | Select-Object -First 1
    if ($cl) {
        "cl.exe path: $cl"
        & $cl 2>&1 | Select-Object -First 2
    } else {
        "cl.exe: NOT FOUND"
    }
} else {
    "vswhere: NOT FOUND"
}