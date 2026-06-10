# Start the full ImagineXI / LandSandBoat server stack in dependency order.
# Run from an elevated or normal PowerShell:  .\start-servers.ps1

$ErrorActionPreference = "Stop"
$ServerDir = $PSScriptRoot
$LogDir = Join-Path $ServerDir "log"

if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir | Out-Null
}

function Test-ServerRunning([string]$Name) {
    return $null -ne (Get-Process -Name $Name -ErrorAction SilentlyContinue)
}

function Start-ServerExe([string]$Name, [string]$LogFile) {
    if (Test-ServerRunning $Name) {
        Write-Host "[skip] $Name already running"
        return
    }

    $exe = Join-Path $ServerDir "$Name.exe"
    if (-not (Test-Path $exe)) {
        throw "Missing $exe"
    }

    Write-Host "[start] $Name"
    Start-Process -FilePath $exe -ArgumentList @("--log", $LogFile) -WorkingDirectory $ServerDir | Out-Null
}

function Wait-MapReady([int]$TimeoutSeconds = 120) {
    $logFile = Join-Path $LogDir "map-server.log"
    $startedAt = Get-Date
    $deadline = $startedAt.AddSeconds($TimeoutSeconds)

    while ((Get-Date) -lt $deadline) {
        if (Test-Path $logFile) {
            $recent = Get-Content $logFile -Tail 40 -ErrorAction SilentlyContinue |
                Where-Object { $_ -match "\[(\d{2}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}):" } |
                ForEach-Object {
                    if ($_ -match "\[(\d{2}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}):") {
                        $stamp = [datetime]::ParseExact($Matches[1], "MM/dd/yy HH:mm:ss", $null)
                        [pscustomobject]@{ Line = $_; Stamp = $stamp }
                    }
                } |
                Where-Object { $_.Stamp -ge $startedAt.AddSeconds(-5) }

            if ($recent.Line -match "The map-server is ready to work") {
                Write-Host "[ready] xi_map"
                return
            }
        }
        Start-Sleep -Seconds 2
    }

    throw "xi_map did not report ready within ${TimeoutSeconds}s. Check log\map-server.log"
}

Write-Host "Starting ImagineXI servers from $ServerDir"

# World must be up before connect/map IPC works reliably.
Start-ServerExe "xi_world" "log/world-server.log"
Start-Sleep -Seconds 2

Start-ServerExe "xi_search" "log/search-server.log"
Start-ServerExe "xi_map" "log/map-server.log"

Wait-MapReady

# Connect last so its ZMQ link to world is alive when you log in.
Start-ServerExe "xi_connect" "log/connect-server.log"
Start-Sleep -Seconds 1

Write-Host ""
Write-Host "All servers started. Wait for map ready before logging in."
Get-Process -Name xi_* -ErrorAction SilentlyContinue | Format-Table Name, Id, StartTime -AutoSize
