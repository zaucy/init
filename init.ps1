#!/usr/bin/env pwsh

$ErrorActionPreference = 'Stop'

# GitHub requires TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$BinDirectory = "$Home\.local\bin"

$User = [EnvironmentVariableTarget]::User
$Path = [Environment]::GetEnvironmentVariable('Path', $User)
if (!(";$Path;".ToLower() -like "*;$BinDirectory;*".ToLower())) {
  Write-Output "Adding bin directory ($BinDirectory) to Environment path..."
  [Environment]::SetEnvironmentVariable('Path', "$Path;$BinDirectory", $User)
  $Env:Path += ";$BinDirectory"
}

function Get-GitHubReleaseFile {
  Param ($Org, $Repo, $File, $OutFile)
  $Response = Invoke-WebRequest "https://github.com/$Org/$Repo/releases" -UseBasicParsing

  $FileUri = $Response.Links |
  Where-Object { $_.href -like "/$Org/$Repo/releases/download/*/$File" } |
  ForEach-Object { 'https://github.com' + $_.href } |
  Select-Object -First 1
  if ($FileUri) {
    Invoke-WebRequest $FileUri -OutFile $OutFile -UseBasicParsing
  }
  else {
    Write-Output "Cannot find $File from $Org/$Repo releases on GitHub"
    Exit 1
  }
}

if ((Get-Command "bazel.exe" -errorAction SilentlyContinue) -eq $false) {
  Get-GitHubReleaseFile -Org "bazelbuild" -Repo "bazelisk" -File "bazelisk-windows-amd64.exe" -OutFile "$BinDirectory\bazel.exe"
}

if ((Get-Command "buildifier.exe" -errorAction SilentlyContinue) -eq $false) {
  Get-GitHubReleaseFile -Org "bazelbuild" -Repo "buildtools" -File "buildifier-windows-amd64.exe" -OutFile "$BinDirectory\buildifier.exe"
}

if ((Get-Command "jq.exe" -errorAction SilentlyContinue) -eq $false) {
  Get-GitHubReleaseFile -Org "stedolan" -Repo "jq" -File "jq-win64.exe" -OutFile "$BinDirectory\jq.exe"
}


if ((Get-Command "cargo.exe" -errorAction SilentlyContinue) -eq $false) {
  # Get rust + cargo
  Invoke-WebRequest -Uri "https://win.rustup.rs/" -UseBasicParsing -OutFile rustup-init.exe
  .\rustup-init.exe -y
}

# Refreshing PATH environment variable
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

if ((Get-Command "nu.exe" -errorAction SilentlyContinue) -eq $false) {
  cargo install nu --features=extra
}

# TODO(zaucy): init WSL + WSLg

Write-Output Done
Pause
