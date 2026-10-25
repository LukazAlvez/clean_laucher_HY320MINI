@echo off
set ADB=platform-tools\adb.exe
set OUT=backup_hy320_mini
if "%1"=="" (
    set /p IP="Digite o IP do projetor (ex: 192.168.1.50): "
) else (
    set IP=%1
)
set TARGET=%IP%:5555

echo Connecting to %TARGET%...
%ADB% connect %TARGET%

for %%P in (uboot trust misc vbmeta security cust logo recovery) do (
    echo Dumping %%P...
    %ADB% exec-out dd if=/dev/block/by-name/%%P 2>nul > %OUT%\%%P.img
    echo %%P done.
)
echo All vital firmware partitions dumped!
