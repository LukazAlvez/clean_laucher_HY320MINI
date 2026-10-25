@echo off
set ADB=platform-tools\adb.exe
set OUT=backup_hy320_mini
set IP=192.168.5.113:5555

echo Connecting...
%ADB% connect %IP%

echo Dumping super (2.4 GB - Android 12)...
%ADB% exec-out dd if=/dev/block/by-name/super 2>nul > %OUT%\super.img
echo super done.

echo Dumping factory backup partition (372 MB)...
%ADB% exec-out dd if=/dev/block/by-name/backup 2>nul > %OUT%\backup.img
echo backup done.

echo Dumping metadata (16 MB)...
%ADB% exec-out dd if=/dev/block/by-name/metadata 2>nul > %OUT%\metadata.img
echo metadata done.

echo COMPLETE_BACKUP_FINISHED
