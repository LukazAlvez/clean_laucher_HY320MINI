@echo off
set ADB=platform-tools\adb.exe
if "%1"=="" (
    set /p IP="Digite o IP do projetor (ex: 192.168.1.50): "
) else (
    set IP=%1
)
set TARGET=%IP%:5555

echo Aplicando otimizacoes seguras no HY320 Mini em %TARGET%...
%ADB% connect %TARGET%

echo 1. Desativando bloatware chines sem remover APKs...
%ADB% shell "pm disable-user --user 0 com.aispeech.tvui"
%ADB% shell "pm disable-user --user 0 com.huawei.qx"
%ADB% shell "pm disable-user --user 0 com.rockchip.itvbox"
%ADB% shell "pm disable-user --user 0 com.android.mgstv"
%ADB% shell "pm disable-user --user 0 com.shzhtxcz.txcz.test"
%ADB% shell "pm disable-user --user 0 com.rockchip.devicetest"
%ADB% shell "pm disable-user --user 0 com.bozee.usbdisplay"
%ADB% shell "pm disable-user --user 0 com.sszztxr.oott"

echo 2. Otimizando escala de animacoes para 0.5x (resposta rapida)...
%ADB% shell "settings put global window_animation_scale 0.5"
%ADB% shell "settings put global transition_animation_scale 0.5"
%ADB% shell "settings put global animator_duration_scale 0.5"

echo 3. Limpando caches em memoria...
%ADB% shell "sync; echo 3 > /proc/sys/vm/drop_caches"

echo Otimizacoes aplicadas com sucesso!
