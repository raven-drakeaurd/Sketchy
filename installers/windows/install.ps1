# Sketchy installer: downloads the Electron runtime from GitHub, verifies it, and installs the app for the current user.
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$ver  = '33.2.1'
$sha  = 'c325a6d905c67107e166267813ea2151ae7fd316c0a88de0081db0b9851a9946'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$dest = Join-Path $env:LOCALAPPDATA 'Programs\Sketchy'
$zip  = Join-Path $env:TEMP "electron-v$ver-win32-x64.zip"

Write-Host 'Sketchy setup' -ForegroundColor Cyan
Get-Process Sketchy -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "$dest*" } | Stop-Process -Force
if (-not ((Test-Path $zip) -and ((Get-FileHash $zip -Algorithm SHA256).Hash -eq $sha.ToUpper()))) {
  Write-Host "Downloading Electron $ver runtime (about 110 MB)..."
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Invoke-WebRequest -UseBasicParsing "https://github.com/electron/electron/releases/download/v$ver/electron-v$ver-win32-x64.zip" -OutFile $zip
}
Write-Host 'Verifying download...'
if ((Get-FileHash $zip -Algorithm SHA256).Hash -ne $sha.ToUpper()) { Remove-Item $zip -Force; throw 'The downloaded file did not match the expected checksum. Run setup again.' }

# Remove the earlier "Sketchwork 2017" install, if present
$old = Join-Path $env:LOCALAPPDATA 'Programs\Sketchwork 2017'
if (Test-Path $old) {
  Write-Host 'Removing the previous "Sketchwork 2017" install...'
  Get-Process Sketchwork -ErrorAction SilentlyContinue | Stop-Process -Force
  Remove-Item $old -Recurse -Force -ErrorAction SilentlyContinue
  foreach ($dir in @([Environment]::GetFolderPath('Desktop'), [Environment]::GetFolderPath('Programs'))) { Remove-Item (Join-Path $dir 'Sketchwork 2017.lnk') -ErrorAction SilentlyContinue }
}

Write-Host "Installing to $dest ..."
if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
Expand-Archive -Path $zip -DestinationPath $dest -Force
Rename-Item (Join-Path $dest 'electron.exe') 'Sketchy.exe'
Remove-Item (Join-Path $dest 'resources\default_app.asar') -ErrorAction SilentlyContinue
Copy-Item (Join-Path $here 'app') (Join-Path $dest 'resources\app') -Recurse
Copy-Item (Join-Path $here 'uninstall.ps1') $dest

$exe  = Join-Path $dest 'Sketchy.exe'
$icon = Join-Path $dest 'resources\app\icon.ico'
$ws = New-Object -ComObject WScript.Shell
foreach ($dir in @([Environment]::GetFolderPath('Desktop'), [Environment]::GetFolderPath('Programs'))) {
  $lnk = $ws.CreateShortcut((Join-Path $dir 'Sketchy.lnk'))
  $lnk.TargetPath = $exe; $lnk.IconLocation = $icon; $lnk.WorkingDirectory = $dest
  $lnk.Description = 'Sketchy 3D modeler'; $lnk.Save()
}
Remove-Item $zip -Force
Write-Host 'Done. Sketchy is on your desktop and in the Start menu.' -ForegroundColor Green
Start-Process $exe
