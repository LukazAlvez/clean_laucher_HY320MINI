$urls = @(
    "https://stremio-addons.net/addons/fenixflix",
    "https://stremio-addons.net/addons/meu-futebol",
    "https://stremio-addons.net/addons/bestcine"
)

$wc = New-Object System.Net.WebClient
foreach ($u in $urls) {
    try {
        $html = $wc.DownloadString($u)
        $m = [regex]::Matches($html, "https?://[^\s""'<>]*/manifest\.json") | ForEach-Object { $_.Value } | Select-Object -Unique
        Write-Host "$u -> $m"
    } catch {
        Write-Host "Error: $($_.Exception.Message)"
    }
}
