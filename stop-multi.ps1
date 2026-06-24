# stop-multi.ps1 — Stop multi-week lab and Kali attacker (Windows PowerShell)
# Usage: .\stop-multi.ps1 week1 week3

param([Parameter(ValueFromRemainingArguments)][string[]]$Weeks)

docker rm -f kali-multi 2>$null
foreach ($week in $Weeks) {
    Write-Host "▶  Stopping $week..." -ForegroundColor Cyan
    Push-Location "labs\$week"
    docker compose down
    Pop-Location
}
Write-Host "✓  Done." -ForegroundColor Green
