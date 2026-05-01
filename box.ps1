<#
.SYNOPSIS
    Launches the SafeCode-Box isolated AI agent.

.DESCRIPTION
    This script maps the current directory into the safecode-box Docker container
    and connects it to the shared 'opencode-net' network and 'opencode-data' volume.

.EXAMPLE
    .\box.ps1 run "Summarize this project"
#>

$winPath = $PWD.Path.Replace('\', '/')
$wslPath = (wsl wslpath -u "$winPath").Trim()

if ([string]::IsNullOrWhiteSpace($wslPath)) {
    Write-Error "Failed to translate Windows path to WSL path."
    exit 1
}

# Ensure networking and volumes exist
docker network create safecode-net 2>$null | Out-Null
docker volume create safecode-data | Out-Null

Write-Host "📦 Launching SafeCode-Box..." -ForegroundColor Cyan

docker run -it --rm `
    --entrypoint "/usr/local/lib/node_modules/opencode-ai/bin/.opencode" `
    --network safecode-net `
    --add-host host.docker.internal:host-gateway `
    -p 4200:4200 -p 5000:5000 `
    -e TERM=xterm-256color `
    -v "$($wslPath):/app" `
    -v "safecode-data:/root/.local/share/opencode" `
    safecode-box:latest $args
