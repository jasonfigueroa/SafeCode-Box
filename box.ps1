<#
.SYNOPSIS
    Launches the SafeCode-Box isolated AI agent.

.DESCRIPTION
    This script maps the current directory into the safecode-box Docker container
    and connects it to the shared 'safecode-net' network and 'safecode-data' volume.

.PARAMETER Personal
    Launches the agent in Personal Mode, which allows free models but still disables sharing.
    Default is Corporate Mode (Strictly Locked).

.EXAMPLE
    .\box.ps1
    .\box.ps1 -Personal
    .\box.ps1 run "Summarize this project"
#>

param(
    [switch]$Personal,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$RemainingArgs
)

$winPath = $PWD.Path.Replace('\', '/')
$wslPath = (wsl wslpath -u "$winPath").Trim()

if ([string]::IsNullOrWhiteSpace($wslPath)) {
    Write-Error "Failed to translate Windows path to WSL path."
    exit 1
}

# Ensure networking and volumes exist
docker network create safecode-net 2>$null | Out-Null
docker volume create safecode-data | Out-Null

$mode = if ($Personal) { "PERSONAL" } else { "CORPORATE" }
$color = if ($Personal) { "Yellow" } else { "Cyan" }

Write-Host "📦 Launching SafeCode-Box in $mode mode..." -ForegroundColor $color

$dockerArgs = @(
        'run'
        '-it'
        '--rm'
        '--network', 'safecode-net'
        # For connecting to SQL Server in another container, maybe better solution out there
        # '--add-host', 'host.docker.internal:host-gateway'
        # Forwarding port 1455 is a ChatGPT Plus browser-based authentication workaround
        # '-p', '1455:1455'
        # Forward port for Angular frontend
        # '-p', '4200:4200'
        # Forward port for dotnet backend
        # '-p', '5000:5000'
        '-e', 'TERM=xterm-256color'
        '-e', "BOX_MODE=$mode"
        '-v', "$($wslPath):/app"
        '-v', 'safecode-data:/root/.local/share/opencode'
        'safecode-box:latest'
    )
    docker @dockerArgs $RemainingArgs
