#!/usr/bin/env pwsh

param (
	[switch] $Force = $false
)

$ErrorActionPreference = 'Stop'

# GitHub requires TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($Force || (Get-Command "nu.exe" -errorAction SilentlyContinue) -eq $false)
{
	winget install nushell
}

$BinDirectory = "$Home\.local\bin"

New-Item -ItemType Directory -Force -Path $BinDirectory | Out-Null

$User = [EnvironmentVariableTarget]::User
$Path = [Environment]::GetEnvironmentVariable('Path', $User)
if (!(";$Path;".ToLower() -like "*;$BinDirectory;*".ToLower()))
{
	Write-Output "Adding bin directory ($BinDirectory) to Environment path..."
	[Environment]::SetEnvironmentVariable('Path', "$Path;$BinDirectory", $User)
	$Env:Path += ";$BinDirectory"
}

function Get-GitHubReleaseFile
{
	Param ($Org, $Repo, $File, $OutFile)
	gh -R "$Org/$Repo" release download -p $File -O $OutFile --clobber
}

if ($Force || (Get-Command "bazel.exe" -errorAction SilentlyContinue) -eq $false)
{
	Get-GitHubReleaseFile -Org "bazelbuild" -Repo "bazelisk" -File "bazelisk-windows-amd64.exe" -OutFile "$BinDirectory\bazel.exe"
}

if ($Force || (Get-Command "buildifier.exe" -errorAction SilentlyContinue) -eq $false)
{
	Get-GitHubReleaseFile -Org "bazelbuild" -Repo "buildtools" -File "buildifier-windows-amd64.exe" -OutFile "$BinDirectory\buildifier.exe"
}

if ($Force || (Get-Command "jq.exe" -errorAction SilentlyContinue) -eq $false)
{
	Get-GitHubReleaseFile -Org "stedolan" -Repo "jq" -File "jq-win64.exe" -OutFile "$BinDirectory\jq.exe"
}

if ($Force || (Get-Command "nvim.exe" -errorAction SilentlyContinue) -eq $false)
{
	winget install Neovim.Neovim
}

$NeovimConfigDir = "$env:LOCALAPPDATA\nvim"
mkdir $NeovimConfigDir -Force | Out-Null
Copy-Item -Path ".\nvim-config\*" -Destination "$NeovimConfigDir" -Recurse -Force

$AlacrittyConfigDir = "$env:APPDATA\alacritty"
mkdir $AlacrittyConfigDir -Force | Out-Null
Copy-Item -Path ".\alacritty\*" -Destination "$AlacrittyConfigDir" -Recurse -Force

$NushellConfigDir = "$env:APPDATA\nushell"
mkdir $NushellConfigDir -Force | Out-Null
Copy-Item -Path ".\nushell\*" -Destination "$NushellConfigDir" -Recurse -Force

$HelixConfigDir = "$env:APPDATA\helix"
mkdir $HelixConfigDir -Force | Out-Null
Copy-Item -Path ".\helix\*" -Destination "$HelixConfigDir" -Recurse -Force

$WindowsStartupDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
mkdir $WindowsStartupDir -Force | Out-Null
Copy-Item -Path ".\windows\startup\*" -Destination "$WindowsStartupDir" -Recurse -Force

if ((Get-Command "cargo.exe" -errorAction SilentlyContinue) -eq $false)
{
	# Get rust + cargo
	Invoke-WebRequest -Uri "https://win.rustup.rs/" -UseBasicParsing -OutFile rustup-init.exe
	.\rustup-init.exe -y
} elseif ($Force)
{
	rustup update
}

# Refreshing PATH environment variable
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

if ((Get-Command "scoop.exe" -errorAction SilentlyContinue) -eq $false)
{
	Invoke-RestMethod get.scoop.sh | Invoke-Expression
} elseif ($Force)
{
	scoop update
}

if ((Get-Command "fd.exe" -errorAction SilentlyContinue) -eq $false)
{
	scoop install fd
} elseif ($Force)
{
	scoop update fd
}

if ((Get-Command "rg.exe" -errorAction SilentlyContinue) -eq $false)
{
	scoop install ripgrep
} elseif ($Force)
{
	scoop update ripgrep
}

# TODO(zaucy): init WSL + WSLg
