# ======================================
# Delete-Duplicates.ps1
# Deletes duplicate files by file size
# Keeps the first file in each group
# ======================================

$RootFolder = "E:\fam photos"

Get-ChildItem $RootFolder -File |
Group-Object Length |
Where-Object { $_.Count -gt 1 } |
ForEach-Object {
    # Keep the first file, delete the rest
    $_.Group | Select-Object -Skip 1 | ForEach-Object {
        Write-Host "Deleting duplicate: $($_.FullName)" -ForegroundColor Red
        Remove-Item $_.FullName -Force
    }
}

Write-Host "`nDuplicate removal complete." -ForegroundColor Green