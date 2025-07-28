@echo off
REM ------------------------------------------------------------
REM Instala/Reinstala o serviço IMWAMService usando o PowerShell
REM ------------------------------------------------------------
SETLOCAL

REM SCRIPT_DIR = path to .bat
SET "SCRIPT_DIR=%~dp0"

REM caminhos dos parâmetros
SET "EXE_PATH=%SCRIPT_DIR%imwam_exec.exe"
SET "LOGS_DIR=%SCRIPT_DIR%logs"

REM chama o PowerShell passando o script e os parâmetros
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%install-imwam.ps1" ^
  -ExePath "%EXE_PATH%" ^
  -LogsDir "%LOGS_DIR%"

ENDLOCAL
pause
