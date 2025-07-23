# IMWAMService
Um conector Python para leitura de dados de PLCs Siemens (via snap7), armazenamento em SQLite e envio de métricas para servidor remoto. Ideal para integração de linhas de produção com sistemas de supervisão.


Este guia descreve como configurar e gerenciar o serviço **IMWAMService** no Windows utilizando o NSSM (Non-Sucking Service Manager).

---

## Sumário

- [Pré-requisitos](#pré-requisitos)
- [Estrutura de Pastas](#estrutura-de-pastas)
- [1. Garantir Pasta de Logs](#1-garantir-pasta-de-logs)
- [2. (Re)Instalar o Serviço com NSSM](#2-reinstalar-o-serviço-com-nssm)
  - [Remover Instância Anterior](#remover-instância-anterior)
  - [Instalar o Serviço](#instalar-o-serviço)
  - [Configurar Diretório de Trabalho](#configurar-diretório-de-trabalho)
  - [Configurar Logs (stdout/stderr)](#configurar-logs-stdoutstderr)
  - [Definir Auto‑start](#definir-auto-start)
  - [Iniciar Serviço](#iniciar-serviço)
- [3. Verificar Status do Serviço](#3-verificar-status-do-serviço)
- [Contato](#contato)

---

## Pré-requisitos

- Windows 10 / 11 ou Windows Server
- NSSM instalado e disponível no `PATH`
- Permissões de administrador para executar comandos PowerShell
- Executável do serviço: `imwam_exec.exe`

## Estrutura de Pastas

```text
C:\path\to\IMWAMService\
├── imwam_exec.exe
├── .env
├── config.json
├── snap7.dll
└── logs\

```

> **Nota:** A pasta `logs` será criada automaticamente se não existir.

## 1. Garantir Pasta de Logs

Abra o PowerShell como **Administrador** e execute:

```powershell
mkdir "C:\path\to\IMWAMService\logs"
```

Isso evita erros de “pasta não encontrada” ao redirecionar `stdout`/`stderr`.

## 2. (Re)Instalar o Serviço com NSSM

### Remover Instância Anterior

Se já existir uma instância do serviço, remova-a:

```powershell
nssm remove IMWAMService confirm
```

### Instalar o Serviço

Aponte para o executável principal do serviço:

```powershell
nssm install IMWAMService "C:\path\to\IMWAMService\imwam_exec.exe"
```

### Configurar Diretório de Trabalho

Defina o diretório onde o serviço será executado:

```powershell
nssm set IMWAMService AppDirectory "C:\path\to\IMWAMService"
```

### Configurar Logs (stdout/stderr)

Redirecione a saída padrão e de erro para arquivos de log:

```powershell
nssm set IMWAMService AppStdout "C:\path\to\IMWAMService\logs\out.log"
nssm set IMWAMService AppStderr "C:\path\to\IMWAMService\logs\err.log"
```

### Definir Auto‑start

Faça o serviço iniciar automaticamente com o Windows:

```powershell
nssm set IMWAMService Start SERVICE_AUTO_START
```

### Iniciar Serviço

Por fim, inicie o serviço:

```powershell
nssm start IMWAMService
```

## 3. Verificar Status do Serviço

Verifique se o serviço está **Running**:

```powershell
Get-Service IMWAMService
```

Ou usando o próprio NSSM:

```powershell
nssm status IMWAMService
```

---

## Contato

Em caso de dúvidas ou problemas, abra uma [issue](https://github.com/seu-usuario/IMWAMService/issues) no repositório.

## Aproveite este projeto!

Criado por **João Igor**.

[![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/ignizxl)
---