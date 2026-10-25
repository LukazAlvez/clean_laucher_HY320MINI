@echo off
set ADB="d:\Projetos Antgravity\projeto 01\platform-tools\adb.exe"

echo Conectando ao projetor...
%ADB% connect 192.168.5.113:5555 >nul

echo === 1/5 Compilando DarkLauncher (speed) ===
%ADB% -s 192.168.5.113:5555 shell cmd package compile -m speed -f com.antigravity.darklauncher

echo === 2/5 Compilando YouTube TV (speed) ===
%ADB% -s 192.168.5.113:5555 shell cmd package compile -m speed -f com.google.android.youtube.tv

echo === 3/5 Compilando Netflix (speed) ===
%ADB% -s 192.168.5.113:5555 shell cmd package compile -m speed -f com.netflix.mediaclient

echo === 4/5 Compilando Google Play Store (speed) ===
%ADB% -s 192.168.5.113:5555 shell cmd package compile -m speed -f com.android.vending

echo === 5/5 Compilando SystemUI (speed) ===
%ADB% -s 192.168.5.113:5555 shell cmd package compile -m speed -f com.android.systemui

echo === Verificando status final do Dexopt ===
%ADB% -s 192.168.5.113:5555 shell "dumpsys package com.antigravity.darklauncher | grep -A 2 'Dexopt state:'"
%ADB% -s 192.168.5.113:5555 shell "dumpsys package com.google.android.youtube.tv | grep -A 2 'Dexopt state:'"
