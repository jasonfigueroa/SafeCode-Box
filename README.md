# SafeCode-Box 🛡️

**Version:** 1.0.0  
**License:** [MIT](LICENSE)

SafeCode-Box is a secure, isolated AI development environment built on top of [OpenCode](https://opencode.ai). It provides a "clean room" for AI agents to work on your code without having full access to your host machine's filesystem or sensitive data.

## Features

- **Isolated AI Agent:** Runs OpenCode entirely within a Docker container.
- **Pre-configured Tooling:** Includes .NET 10.0 SDK and Node.js 20.x.
- **Enterprise-Ready Security:** 
  - Public sharing of conversations is disabled by default.
  - No OpenCode installation required on the host machine.
  - Persistent AI identity stored in a dedicated Docker volume.
- **Full-Stack Demo Included:** Contains a sample .NET 10 Web API, Angular frontend, and SQL Server setup.
- **Oh My Posh Support:** Pre-configured for a beautiful, high-information terminal experience.

## Prerequisites

- **Windows 10/11** with **WSL 2** enabled.
- **Docker** installed and running (using the WSL 2 backend).
- **PowerShell 7** (recommended).
- A **Nerd Font** (e.g., CaskaydiaCove Nerd Font) for terminal icons.

## Quick Start

### 1. Build the Image
```powershell
docker build -t safecode-box:latest .
```

### 2. Configure the Launcher
Add the following function to your PowerShell profile (`$PROFILE`):

```powershell
function safecode-box {
    $winPath = (Get-Location).Path.Replace('\', '/')
    $wslPath = (wsl wslpath -u "$winPath").Trim()
    
    docker network create safecode-net 2>$null | Out-Null
    docker volume create safecode-data | Out-Null

    docker run -it --rm `
        --entrypoint "/usr/local/lib/node_modules/opencode-ai/bin/.opencode" `
        --network safecode-net `
        --add-host host.docker.internal:host-gateway `
        -p 4200:4200 -p 5000:5000 `
        -e TERM=xterm-256color `
        -v "$($wslPath):/app" `
        -v "safecode-data:/root/.local/share/opencode" `
        safecode-box:latest $args
}
```

### 3. Log in to your AI Provider
```powershell
safecode-box auth login --provider openai
```

## Working with Legacy Projects (.NET 4.x)

Since the container runs on Linux, it cannot compile .NET 4.x code directly. Use the **Log-Watcher** workflow:

1. Run your build on the Windows host and redirect output to a file:
   ```powershell
   msbuild /v:m > build.log
   ```
2. Ask the agent in the box to check the log:
   *"I just ran a build on my host. Can you check build.log and fix the errors?"*

The agent will read the log, identify the errors, and apply fixes to the code inside the box.

## Database Setup (Docker)

This project is configured to work with a SQL Server container named `mssql_stable`.

**Start SQL Server:**
```powershell
docker run --name mssql_stable -e 'ACCEPT_EULA=Y' -e 'MSSQL_SA_PASSWORD=YourPassword' -p 1433:1433 --network safecode-net --restart always -d mcr.microsoft.com/mssql/server:2022-latest
```

## Authors
- Jason & OpenCode AI
