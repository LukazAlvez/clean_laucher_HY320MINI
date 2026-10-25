@echo off
set ADB=platform-tools\adb.exe
set OUT=backup_hy320_mini
set IP=192.168.5.113:5555

echo Connecting...
%ADB% connect %IP%

for %%P in (uboot trust misc vbmeta security cust logo recovery) do (
    echo Dumping %%P...
    %ADB% exec-out dd if=/dev/block/by-name/%%P 2>nul > %OUT%\%%P.img
    echo %%P done.
)
echo All vital firmware partitions dumped!
