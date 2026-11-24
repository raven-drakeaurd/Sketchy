# Removes Sketchy and its shortcuts. Your saved .skw files are not touched.
$dest = Join-Path $env:LOCALAPPDATA 'Programs\Sketchy'
Get-Process Sketchy -ErrorAction SilentlyContinue | Stop-Process -Force
foreach ($dir in @([Environment]::GetFolderPath('Desktop'), [Environment]::GetFolderPath('Programs'))) {
  Remove-Item (Join-Path $dir 'Sketchy.lnk') -ErrorAction SilentlyContinue
}
Set-Location $env:TEMP
Remove-Item $dest -Recurse -Force -ErrorAction SilentlyContinue
Write-Host 'Sketchy was removed.'
