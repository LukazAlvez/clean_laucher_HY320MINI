$wc = New-Object System.Net.WebClient
$html = $wc.DownloadString("https://www.stremio.com/downloads")
[regex]::Matches($html, "https://[a-zA-Z0-9\./_\-]+stremio[a-zA-Z0-9\._\-]+\.apk") | ForEach-Object { $_.Value } | Select-Object -Unique
