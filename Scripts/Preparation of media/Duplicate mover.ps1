# ======================================
# Move-Duplicates.ps1 (SAFE VERSION)
# Moves duplicate files by size
# ======================================

$RootFolder = "E:\fam videos"
$Quarantine = Join-Path $RootFolder "_DUPLICATES_REVIEW"

New-Item -ItemType Directory -Path $Quarantine -Force | Out-Null

Get-ChildItem $RootFolder -File |
Group-Object Length |
Where-Object { $_.Count -gt 1 } |
ForEach-Object {
    $_.Group | Select-Object -Skip 1 | ForEach-Object {
        $target = Join-Path $Quarantine $_.Name
        $i = 1
        while (Test-Path $target) {
            $target = Join-Path $Quarantine ("{0} ({1}){2}" -f $_.BaseName, $i, $_.Extension)
            $i++
        }
        Move-Item $_.FullName $target
    }
}

Write-Host "Duplicates moved to $Quarantine" -ForegroundColor Green