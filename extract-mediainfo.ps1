$mediaInfoPath = "MediaInfo\MediaInfo.exe"
Write-Host "Emplacement du dossier principal contenant vos films à extraire"
$FilmsPath = Read-host "exemple (d:\films\)"

$results = @()
Get-ChildItem $FilmsPath -Recurse -Include "*.mkv","*.mp4","*.avi" | ForEach-Object {
    $json = & $mediaInfoPath --Output=JSON "$($_.FullName)" | ConvertFrom-Json
    $results += $json
    Write-Host "✓ $($_.Name)"
}
$results | ConvertTo-Json -Depth 20 | Out-File -Encoding UTF8 "$FilmsPath\mediainfo-batch.json"
Write-Host "✅ Terminé : $($results.Count) fichiers → mediainfo-batch.json"