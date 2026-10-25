$ErrorActionPreference = "Stop"

$BASE_DIR = "d:\Projetos Antgravity\projeto 01"
$JAVA_HOME = "$BASE_DIR\build-tools\jdk-17.0.20.1+1"
$JAVA = "$JAVA_HOME\bin\java.exe"
$JAR_CMD = "$JAVA_HOME\bin\jar.exe"
$KEYTOOL = "$JAVA_HOME\bin\keytool.exe"

$AAPT2 = "$BASE_DIR\build-tools\android-13\aapt2.exe"
$D8_JAR = "$BASE_DIR\build-tools\android-13\lib\d8.jar"
$ZIPALIGN = "$BASE_DIR\build-tools\android-13\zipalign.exe"
$APKSIGNER_JAR = "$BASE_DIR\build-tools\android-13\lib\apksigner.jar"
$ANDROID_JAR = "$BASE_DIR\build-tools\android-12\android.jar"
$KOTLINC_JAR = "$BASE_DIR\build-tools\kotlinc\lib\kotlin-compiler.jar"
$KOTLIN_STDLIB = "$BASE_DIR\build-tools\kotlinc\lib\kotlin-stdlib.jar"

$SRC_DIR = "$BASE_DIR\DarkLauncher\src\main"
$BUILD_DIR = "$BASE_DIR\DarkLauncher\build"
$GEN_DIR = "$BUILD_DIR\gen"
$CLASSES_DIR = "$BUILD_DIR\classes"
$OUTPUT_APK = "$BASE_DIR\DarkLauncher.apk"

Write-Host "=== 1. Limpando pastas de build ===" -ForegroundColor Cyan
if (Test-Path $BUILD_DIR) { Remove-Item -Recurse -Force $BUILD_DIR }
New-Item -ItemType Directory -Force -Path $GEN_DIR | Out-Null
New-Item -ItemType Directory -Force -Path $CLASSES_DIR | Out-Null

Write-Host "=== 2. Compilando recursos com AAPT2 ===" -ForegroundColor Cyan
& $AAPT2 compile --dir "$SRC_DIR\res" -o "$BUILD_DIR\resources.zip"

Write-Host "=== 3. Vinculando recursos e gerando R.java ===" -ForegroundColor Cyan
& $AAPT2 link -I $ANDROID_JAR --min-sdk-version 26 --target-sdk-version 32 --manifest "$SRC_DIR\AndroidManifest.xml" --java $GEN_DIR -o "$BUILD_DIR\unaligned.apk" "$BUILD_DIR\resources.zip" --auto-add-overlay

Write-Host "=== 4. Compilando codigo Kotlin ===" -ForegroundColor Cyan
$ktFiles = (Get-ChildItem -Recurse "$SRC_DIR\java\*.kt").FullName
$rFiles = (Get-ChildItem -Recurse "$GEN_DIR\*.java").FullName

$compileArgs = @(
    "-cp", $KOTLINC_JAR,
    "org.jetbrains.kotlin.cli.jvm.K2JVMCompiler",
    "-cp", "$ANDROID_JAR;$GEN_DIR;$KOTLIN_STDLIB",
    "-d", $CLASSES_DIR,
    "-jvm-target", "1.8"
) + $ktFiles + $rFiles

& $JAVA @compileArgs

Write-Host "=== 5. Gerando classes.dex com D8 ===" -ForegroundColor Cyan
$classFiles = (Get-ChildItem -Recurse "$CLASSES_DIR\*.class").FullName
$d8Args = @(
    "-cp", $D8_JAR,
    "com.android.tools.r8.D8",
    "--min-api", "26",
    "--output", $BUILD_DIR
) + $classFiles + @($KOTLIN_STDLIB)

& $JAVA @d8Args

Write-Host "=== 6. Inserindo classes.dex no APK ===" -ForegroundColor Cyan
Push-Location $BUILD_DIR
& $JAR_CMD uf "$BUILD_DIR\unaligned.apk" "classes.dex"
Pop-Location

Write-Host "=== 7. Alinhando APK com zipalign ===" -ForegroundColor Cyan
$alignedApk = "$BUILD_DIR\aligned.apk"
& $ZIPALIGN -f -p 4 "$BUILD_DIR\unaligned.apk" $alignedApk

Write-Host "=== 8. Assinando APK com apksigner ===" -ForegroundColor Cyan
$keystore = "$BASE_DIR\debug.keystore"
if (-not (Test-Path $keystore)) {
    Write-Host "Criando debug keystore..."
    & $KEYTOOL -genkeypair -v -keystore $keystore -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 -storepass android -keypass android -dname "CN=Android Debug,O=Android,C=US"
}

& $JAVA -jar $APKSIGNER_JAR sign --ks $keystore --ks-pass pass:android --key-pass pass:android --out $OUTPUT_APK $alignedApk

Write-Host "=== SUCESSO! APK compilado e assinado em: $OUTPUT_APK ===" -ForegroundColor Green
Get-Item $OUTPUT_APK | Select-Object Name, Length, LastWriteTime
