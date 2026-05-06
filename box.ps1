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

if ($RemainingArgs.Count -ge 1 -and $RemainingArgs[0] -eq 'allow') {
    if ($RemainingArgs.Count -lt 2) {
        Write-Error "Usage: .\box.ps1 allow <provider-id>"
        exit 1
    }

    $provider = $RemainingArgs[1]
    $mode = if ($Personal) { "PERSONAL" } else { "CORPORATE" }
    $winPath = $PWD.Path.Replace('\', '/')
    $wslPath = (wsl wslpath -u "$winPath").Trim()

    docker network create safecode-net 2>$null | Out-Null
    docker volume create safecode-data | Out-Null

    docker run --rm `
        --network safecode-net `
        --add-host host.docker.internal:host-gateway `
        -e "BOX_MODE=$mode" `
        -v "safecode-data:/root/.local/share/opencode" `
        safecode-box:latest safecode-box-allow $provider
    exit $LASTEXITCODE
}

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

docker run -it --rm `
    --network safecode-net `
    --add-host host.docker.internal:host-gateway `
    -p 4200:4200 -p 5000:5000 `
    -e TERM=xterm-256color `
    -e "BOX_MODE=$mode" `
    -v "$($wslPath):/app" `
    -v "safecode-data:/root/.local/share/opencode" `
    safecode-box:latest $RemainingArgs
