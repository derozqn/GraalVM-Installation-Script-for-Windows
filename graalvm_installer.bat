@echo off

setlocal enabledelayedexpansion

echo GraalVM Installation Script for Windows

net session >nul 2>&1

if %errorLevel% neq 0 (
    echo Administrator privileges required.
    echo Please run as administrator.
    pause
    exit /b 1
)

echo Select GraalVM JDK version to install:
echo 1. GraalVM JDK 21
echo 2. GraalVM JDK 24
echo.

set /p choice="Choose an option (1-3): "

if "%choice%"=="1" (
    set "java_version=21"
) else if "%choice%"=="2" (
    set "java_version=24"
) else (
    echo Invalid selection. Exiting...
    exit /b 1
)

set "install_dir=C:\Program Files\GraalVM"
set "graalvm_filename=graalvm-jdk-%java_version%_windows-x64_bin.zip"
set "download_dir=%USERPROFILE%\Downloads"
set "download_path=%download_dir%\%graalvm_filename%"

if not exist "%download_dir%" mkdir "%download_dir%"

echo Downloading GraalVM JDK %java_version%...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://download.oracle.com/graalvm/%java_version%/latest/graalvm-jdk-%java_version%_windows-x64_bin.zip' -OutFile '%download_path%'}"

if not exist "%download_path%" (
    echo Download failed. Please download manually from:
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