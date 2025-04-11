@echo off

setlocal enabledelayedexpansion

echo Windows용 GraalVM 설치 스크립트

net session >nul 2>&1

if %errorLevel% neq 0 (
    echo 관리자 권한이 필요합니다.
    echo 관리자 권한으로 실행하세요.
    pause
    exit /b 1
)

echo 설치할 GraalVM JDK 버전을 선택합니다:
echo 1. GraalVM JDK 21
echo 2. GraalVM JDK 24
echo.

set /p choice="버전(1-2)를 선택합니다: "

if "%choice%"=="1" (
    set "java_version=21"
) else if "%choice%"=="2" (
    set "java_version=24"
) else (
    echo 잘못된 선택입니다. 종료...
    exit /b 1
)

set "install_dir=C:\Program Files\GraalVM"
set "graalvm_filename=graalvm-jdk-%java_version%_windows-x64_bin.zip"
set "download_dir=%USERPROFILE%\Downloads"
set "download_path=%download_dir%\%graalvm_filename%"

if not exist "%download_dir%" mkdir "%download_dir%"

echo GraalVM JDK %java_version% 다운로드 하는 중...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://download.oracle.com/graalvm/%java_version%/latest/graalvm-jdk-%java_version%_windows-x64_bin.zip' -OutFile '%download_path%'}"

if not exist "%download_path%" (
    echo 다운로드에 실패했습니다. 다음에서 수동으로 다운로드하세요:
    echo https://www.graalvm.org/downloads/
    exit /b 1
)

if not exist "%install_dir%" mkdir "%install_dir%"

echo Extracting GraalVM...
powershell -command "Expand-Archive -Path '%download_path%' -DestinationPath '%install_dir%' -Force"

for /d %%i in ("%install_dir%\graalvm*", "%install_dir%\jdk*") do (
    if exist "%%i\bin\java.exe" (
        set "graalvm_path=%%i"
        goto :found_graalvm
    )
)

echo Could not find GraalVM directory.
exit /b 1

:found_graalvm
echo GraalVM found at: %graalvm_path%

echo Setting environment variables...
setx /M JAVA_HOME "%graalvm_path%"

for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH ^| find "PATH"') do (
    set "current_path=%%b"
)

setx /M PATH "%graalvm_path%\bin;%current_path%"

call "%graalvm_path%\bin\java.exe" -version

echo GraalVM installation complete.
echo JAVA_HOME: %graalvm_path%