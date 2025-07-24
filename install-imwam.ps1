<#
.SYNOPSIS
  Instala (ou reinstala) o serviço Windows para o IMWAM Connector.
.PARAMETER ExePath
  Caminho completo para o executável imwam_exec.exe.
.PARAMETER ServiceName
  Nome do serviço Windows (default: IMWAMService).
.PARAMETER LogsDir
  Diretório onde ficarão out.log e err.log.
.EXAMPLE
  .\install‑imwam.ps1 -ExePath "C:\IMWAMService\imwam_exec.exe" -LogsDir "C:\IMWAMService\logs"
#>

param(
  [Parameter(Mandatory=$true)] [string] $ExePath,
  [string] $ServiceName = 'IMWAMService',
  [Parameter(Mandatory=$true)] [string] $LogsDir
)

# Garante execução como Admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent() `
      ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Write‑Error "Execute este script como Administrador."
  exit 1
}

# Detecta NSSM correto (x86/x64)
$arch   = (Get-Process -Id $PID).StartInfo.EnvironmentVariables['PROCESSOR_ARCHITECTURE']
$nssmExe = if ($arch -match '64') {
  Join-Path $PSScriptRoot 'nssm-2.24\win64\nssm.exe'
} else {
  Join-Path $PSScriptRoot 'nssm-2.24\win32\nssm.exe'
}

if (-not (Test-Path $nssmExe)) {
  Write‑Error "Não achei o nssm.exe em $nssmExe"
  exit 1
}

# Cria pastas de log, se preciso
if (-not (Test-Path $LogsDir)) { New-Item -ItemType Directory -Path $LogsDir -Force }

# Remove serviço antigo (se existir)
& $nssmExe status  $ServiceName 2>$null
if ($LASTEXITCODE -eq 0) {
  Write-Host "Serviço $ServiceName existe: removendo..."
  & $nssmExe remove  $ServiceName  confirm
}

# Instala
Write-Host "Instalando serviço $ServiceName..."
& $nssmExe install `
    $ServiceName `
    $ExePath

# Configurações
& $nssmExe set $ServiceName AppDirectory     (Split-Path $ExePath)
& $nssmExe set $ServiceName AppStdout        (Join-Path $LogsDir 'out.log')
& $nssmExe set $ServiceName AppStderr        (Join-Path $LogsDir 'err.log')
& $nssmExe set $ServiceName AppRotateFiles   1
& $nssmExe set $ServiceName Start            SERVICE_AUTO_START

# Inicia
Write-Host "Iniciando serviço..."
& $nssmExe start  $ServiceName

Write-Host "`nServiço '$ServiceName' instalado e iniciado com sucesso!"
