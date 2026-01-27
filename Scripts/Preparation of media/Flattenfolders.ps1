# ================================
# Flatten-Folders.ps1
# Moves all files from subfolders
# into the root folder safely
# ================================

$RootFolder = "E:\fam videos"

Get-ChildItem $RootFolder -Recurse -File | ForEach-Object {
    $dest = $RootFolder
    $target = Join-Path $dest $_.Name
    $i = 1

    while (Test-Path $target) {
        $target = Join-Path $dest ("{0} ({1}){2}" -f $_.BaseName, $i, $_.Extension)
        $i++
    }

    Move-Item $_.FullName $target
}

Write-Host "Done! All files have been flattened." -ForegroundColor Green
