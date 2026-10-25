@echo off
set ADB="d:\Projetos Antgravity\projeto 01\platform-tools\adb.exe"
set OUT=d:\Projetos Antgravity\projeto 01\screens
echo === Abrir favorito (OK no 1o item) ===
%ADB% shell am start -n com.antigravity.darklauncher/.MainActivity >nul
ping -n 3 127.0.0.1 >nul
%ADB% shell input keyevent 23
ping -n 4 127.0.0.1 >nul
%ADB% shell dumpsys activity activities | findstr /i "topResumedActivity"
echo === Botao HOME ===
%ADB% shell input keyevent 3
ping -n 3 127.0.0.1 >nul
%ADB% shell dumpsys activity activities | findstr /i "topResumedActivity"
echo === Tempo de abertura a frio (3x) ===
for /L %%i in (1,1,3) do (
  %ADB% shell am force-stop com.antigravity.darklauncher
  %ADB% shell am start -W -n com.antigravity.darklauncher/.MainActivity | findstr TotalTime
  ping -n 3 127.0.0.1 >nul
)
echo === Memoria DarkLauncher ===
%ADB% shell dumpsys meminfo com.antigravity.darklauncher | findstr /i "TOTAL PSS Private"
echo === Memoria launcher original ===
%ADB% shell am start -n com.shzhtxcz.txbox.launcher/com.shzhtxcz.txbox.MainActivity >nul
ping -n 8 127.0.0.1 >nul
%ADB% exec-out screencap -p > "%OUT%\stock.png"
%ADB% shell dumpsys meminfo com.shzhtxcz.txbox.launcher | findstr /i "TOTAL PSS Private"
echo === Tempo de abertura a frio original (3x) ===
for /L %%i in (1,1,3) do (
  %ADB% shell am force-stop com.shzhtxcz.txbox.launcher
  %ADB% shell am start -W -n com.shzhtxcz.txbox.launcher/com.shzhtxcz.txbox.MainActivity | findstr TotalTime
  ping -n 3 127.0.0.1 >nul
)
%ADB% shell am start -n com.antigravity.darklauncher/.MainActivity >nul
ping -n 3 127.0.0.1 >nul
%ADB% exec-out screencap -p > "%OUT%\v2_final.png"
