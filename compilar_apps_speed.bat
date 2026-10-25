@echo off
set ADB="d:\Projetos Antgravity\projeto 01\platform-tools\adb.exe"

echo Conectando ao dispositivo ADB...
%ADB% shell cmd package compile -m speed -f com.antigravity.darklauncher
%ADB% shell cmd package compile -m speed -f com.google.android.youtube.tv
%ADB% shell cmd package compile -m speed -f com.netflix.mediaclient
%ADB% shell cmd package compile -m speed -f com.android.vending
%ADB% shell cmd package compile -m speed -f com.android.systemui
%ADB% shell cmd package compile -m speed -f com.stremio.one

echo === Verificando status final do Dexopt ===
%ADB% shell "dumpsys package com.antigravity.darklauncher | grep -A 2 'Dexopt state:'"
%ADB% shell "dumpsys package com.google.android.youtube.tv | grep -A 2 'Dexopt state:'"
