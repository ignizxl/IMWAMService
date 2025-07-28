<#
.SYNOPSIS
  Instala (ou reinstala) o servico Windows para o IMWAM Connector.
.PARAMETER ExePath
  Caminho completo para o executavel imwam_exec.exe.
.PARAMETER ServiceName
  Nome do servico Windows (default: IMWAMService).
.PARAMETER LogsDir
  Diretorio onde ficarao out.log e err.log.
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $ExePath,

    [Parameter(Mandatory=$false)]
    [string] $ServiceName = 'IMWAMService',

    [Parameter(Mandatory=$true)]
    [string] $LogsDir
)

# verifica privilegios de Admin
$principal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Execute este script como Administrador."
    exit 1
}

# detecta NSSM (x86/x64)
$arch = $Env:PROCESSOR_ARCHITECTURE
if ($arch -match '64') {
    $nssmExe = Join-Path $PSScriptRoot 'nssm-2.24\win64\nssm.exe'
} else {
    $nssmExe = Join-Path $PSScriptRoot 'nssm-2.24\win32\nssm.exe'
}
if (-not (Test-Path $nssmExe)) {
    Write-Error "Nao encontrei o nssm.exe em $nssmExe"
    exit 1
}

# garante pasta de logs
if (-not (Test-Path $LogsDir)) {
    New-Item -ItemType Directory -Path $LogsDir -Force | Out-Null
}

# remove servico antigo, se existir
& $nssmExe status $ServiceName 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "Servico '$ServiceName' existe - removendo..."
    & $nssmExe remove $ServiceName confirm
}

# instala o servico
Write-Host "Instalando servico '$ServiceName'..."
& $nssmExe install $ServiceName $ExePath

# 6) Configura parametros
& $nssmExe set $ServiceName AppDirectory   (Split-Path $ExePath)
& $nssmExe set $ServiceName AppStdout      (Join-Path $LogsDir 'out.log')
& $nssmExe set $ServiceName AppStderr      (Join-Path $LogsDir 'err.log')
& $nssmExe set $ServiceName AppRotateFiles 1
& $nssmExe set $ServiceName Start          SERVICE_AUTO_START

# inicia o servico
Write-Host "Iniciando servico..."
& $nssmExe start $ServiceName

Write-Host ""
Write-Host "Servico '$ServiceName' instalado e iniciado com sucesso!"