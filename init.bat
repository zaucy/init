@echo off

@REM init.bat tries to get pwsh.exe installed on the machine and run .\init.ps1

where /q pwsh.exe
if %ErrorLevel% neq 0 (goto download_pwsh) else (goto init_pwsh)


:download_pwsh
@REM =====================================================
where /q winget
if %ErrorLevel% neq 0 goto no_winget

winget install Microsoft.PowerShell
if %ErrorLevel% neq 0 (goto winget_install_pwsh_fail) else (goto init_pwsh)


:init_pwsh
@REM =====================================================
start pwsh.exe .\init.ps1
exit 0


:winget_install_pwsh_fail
@REM =====================================================
echo winget failed to install PowerShell
exit 1


:no_winget
@REM =====================================================
echo winget not found. Your Windows installation must at least have winget. 
exit 1

@REM =====================================================
:end

echo Done
exit 0
