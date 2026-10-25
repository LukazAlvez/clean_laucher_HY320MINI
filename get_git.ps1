$url = "https://github.com/git-for-windows/git/releases/download/v2.47.1.windows.1/MinGit-2.47.1-64-bit.zip"
$zip = "d:\Projetos Antgravity\projeto 01\build-tools\mingit.zip"
$dest = "d:\Projetos Antgravity\projeto 01\build-tools\git"

if (-not (Test-Path $dest)) {
    Write-Host "Baixando MinGit de $url..."
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($url, $zip)
    Write-Host "Extraindo MinGit..."
    Expand-Archive -Path $zip -DestinationPath $dest -Force
    Remove-Item $zip -Force
}

& "$dest\cmd\git.exe" --version
