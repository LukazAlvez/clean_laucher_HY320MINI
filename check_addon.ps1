$wc = New-Object System.Net.WebClient
try {
    $html = $wc.DownloadString("https://stremio-addons.net/addons/froststream")
    Write-Host "Success, length: $($html.Length)"
    [regex]::Matches($html, "https?://[^\s""'<>]*(?:manifest\.json|frost[^\s""'<>]*)") | ForEach-Object { $_.Value } | Select-Object -Unique
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
