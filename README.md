# SafeCode-Box 🛡️

**Version:** 1.1.0  
**License:** [MIT](LICENSE)

SafeCode-Box is a containerized AI development environment built on top of [OpenCode](https://opencode.ai). It reduces host exposure by running the agent inside Docker and mounting only the workspace you choose.

## Features

- **Isolated AI Agent:** Runs OpenCode inside a Docker container.
- **Default-Deny Policy:** All AI providers are disabled by default for maximum corporate safety.
- **Pre-configured Tooling:** Includes .NET 10.0 SDK and Node.js 20.x.
- **Log-Watcher Utility:** Automatically analyzes host-side build logs for legacy .NET 4.x projects.
- **Enterprise-Ready Security:**
  - Public sharing of conversations is hard-locked to disabled.
  - No OpenCode installation required on the host machine.
  - Persistent AI identity stored in a dedicated Docker volume.
- **Dual Modes:** Switch between strict `Corporate` and flexible `Personal` modes.

## Project Structure

- `Dockerfile`: The main recipe for the isolated agent.
- `box.ps1`: A portable launcher script for Windows.
- `configs/`: Governance templates used by the entrypoint.
- `scripts/`: Internal management and initialization scripts.
- `mcp/`: Custom "Model Context Protocol" servers (e.g., the build log analyzer).
- `samples/`: Example projects (.NET 10 & Angular) to test the agent's capabilities.

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
    param([switch]$Personal, [Parameter(ValueFromRemainingArguments = $true)] [string[]]$RemainingArgs)
    $winPath = (Get-Location).Path.Replace('\', '/')
    $wslPath = (wsl wslpath -u "$winPath").Trim()
    if ([string]::IsNullOrWhiteSpace($wslPath)) { return }
    
    docker network create safecode-net 2>$null | Out-Null
    docker volume create safecode-data | Out-Null
    $mode = if ($Personal) { "PERSONAL" } else { "CORPORATE" }

    docker run -it --rm `
        --network safecode-net `
        --add-host host.docker.internal:host-gateway `
        -p 4200:4200 -p 5000:5000 `
        -e TERM=xterm-256color -e "BOX_MODE=$mode" `
        -v "$($wslPath):/app" `
        -v "safecode-data:/root/.local/share/opencode" `
        safecode-box:latest $RemainingArgs
}
```

### 3. Enable an AI Provider
By default, all providers are disabled. To enable your corporate-approved provider (e.g., OpenAI), run:
```powershell
.\box.ps1 allow openai
```

### 4. Log in
```powershell
safecode-box auth login --provider openai
```

## Security & Governance

### Corporate Mode (Default)
In Corporate mode, SafeCode-Box reapplies a "Default Deny" policy on launch. The `enabled_providers` list is cleared, and the free `opencode` (Zen) provider is explicitly blacklisted.

### Personal Mode
For local experimentation, you can launch in Personal mode:
```powershell
safecode-box -Personal
```
This allows access to all providers, including the free models, while still keeping public sharing disabled.

## Working with Legacy Projects (.NET 4.x)

Use the **Log-Watcher** workflow:
1. Run your build on Windows: `msbuild /v:m > build.log`
2. Ask the agent: *"I just ran a build on my host. Can you check build.log and fix the errors?"*

## Authors
- Jason Figueroa & OpenCode AI
