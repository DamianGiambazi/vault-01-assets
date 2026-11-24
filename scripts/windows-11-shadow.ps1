$tools = @(
  'git','cmake','ninja','clang','clang-tidy','vcpkg',
  'rustc','cargo','rustup','python','uv','pyenv',
  'node','npm','nvm','docker','wsl','gcloud','bq','gsutil',
  'ffmpeg','ffprobe','check-jsonschema','k6','code','supabase','winget'
)

$tools | ForEach-Object {
  # -All is the critical fix here
  $cmds = @(Get-Command $_ -All -ErrorAction SilentlyContinue)
  [PSCustomObject]@{
    Tool        = $_
    ShadowCount = $cmds.Count
    Winner      = if ($cmds) { $cmds[0].Source } else { $null }
    All         = ($cmds.Source -join ' | ')
  }
} | Format-Table -AutoSize