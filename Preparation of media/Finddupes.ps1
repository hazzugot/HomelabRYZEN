# ================================
# Find-Duplicates.ps1 (DRY RUN)
# Lists duplicate files by size
# ================================

$RootFolder = "E:\fam photos"

Get-ChildItem $RootFolder -File |
Group-Object Length |
Where-Object { $_.Count -gt 1 } |
ForEach-Object {
    Write-Host "`nDuplicate group (Size: $($_.Name) bytes)" -ForegroundColor Yellow
    $_.Group | ForEach-Object {
        Write-Host "  $($_.Name)"
    }
}

Write-Host "`nDry run complete. No files were deleted." -ForegroundColor Green
