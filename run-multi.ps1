# run-multi.ps1 — Start multiple weeks + shared Kali attacker (Windows PowerShell)
# Usage: .\run-multi.ps1 week1 week3
# Usage: .\run-multi.ps1 week1 week3 week4

param([Parameter(ValueFromRemainingArguments)][string[]]$Weeks)

if ($Weeks.Count -eq 0) {
    Write-Host "Usage: .\run-multi.ps1 week1 week3 [week4 ...]"
    exit 1
}

$WeekNetworks = @{
    week1  = "week1_custom_network"
    week3  = "week3_traffic_net"
    week4  = "week4_week4-scannet"
    week5  = "week5_week5-enumnet"
    week6  = "week6_week6-labnet"
    week7  = "week7_security_net"
    week8  = "week8_lab_network"
    week9  = "week9_week9-external"
    week10 = "week10_week10-exploitnet"
}

# Start each week stack
foreach ($week in $Weeks) {
    Write-Host "▶  Starting $week..." -ForegroundColor Cyan
    Push-Location "labs\$week"
    docker compose up -d
    Pop-Location
}

# Remove old kali-multi if running
docker rm -f kali-multi 2>$null

# Start Kali on first week's network
$firstNet = $WeekNetworks[$Weeks[0]]
Write-Host "`n▶  Starting Kali attacker on $firstNet..." -ForegroundColor Cyan
docker run -d --rm `
    --name kali-multi `
    --hostname kali `
    --network $firstNet `
    --cap-add=NET_RAW `
    --cap-add=NET_ADMIN `
    ethical-base tail -f /dev/null

# Connect Kali to remaining networks
foreach ($week in $Weeks | Select-Object -Skip 1) {
    $net = $WeekNetworks[$week]
    Write-Host "▶  Connecting Kali to $net..." -ForegroundColor Cyan
    docker network connect $net kali-multi
}

Write-Host "`n✓  All started. Enter Kali with:" -ForegroundColor Green
Write-Host "     docker exec -it kali-multi bash"
Write-Host "`nNetworks available inside Kali:"
foreach ($week in $Weeks) {
    Write-Host "     $week — $($WeekNetworks[$week])"
}
