@echo off
set ADB=platform-tools\adb.exe
set IP=192.168.5.113:5555

echo Revertendo todas as otimizacoes...
%ADB% connect %IP%

%ADB% shell "pm enable com.aispeech.tvui"
%ADB% shell "pm enable com.huawei.qx"
%ADB% shell "pm enable com.rockchip.itvbox"
%ADB% shell "pm enable com.android.mgstv"
%ADB% shell "pm enable com.shzhtxcz.txcz.test"
%ADB% shell "pm enable com.rockchip.devicetest"
%ADB% shell "pm enable com.bozee.usbdisplay"
%ADB% shell "pm enable com.sszztxr.oott"

%ADB% shell "settings put global window_animation_scale 1.0"
%ADB% shell "settings put global transition_animation_scale 1.0"
%ADB% shell "settings put global animator_duration_scale 1.0"

echo Todas as alteracoes foram revertidas para o padrao de fabrica original!
