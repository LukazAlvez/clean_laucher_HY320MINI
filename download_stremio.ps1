$url = "https://dl.strem.io/android/v1.10.4-androidTV/com.stremio.one-1.10.4-31048580-armeabi-v7a.apk"
$out = "d:\Projetos Antgravity\projeto 01\stremio_tv_arm.apk"
Write-Host "Baixando Stremio Android TV ARM de $url..."
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $out)
Get-Item $out | Select-Object Name, Length, LastWriteTime
