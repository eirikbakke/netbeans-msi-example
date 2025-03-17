@echo off

REM Set working directory to that of the BAT file itself, until script ends.
REM https://stackoverflow.com/questions/17063947/get-current-batchfile-directory
setlocal
cd /d "%~dp0"

set NETBEANS_VERSION=0.0.0
REM Randomly generated for testing only. (For real releases, a fresh
REM MSI_PRODUCT_ID must be generated for each new version.)
set MSI_PRODUCT_ID=e8286781-bca8-44d5-95b0-3c4d3b114ae4
set PAYLOAD_DIR=DummyPayload
REM WiX is assumed to be installed here for testing.
set WIX_BIN=C:\Program Files\WiX
REM Must be a temporary folder not created from WSL (due to WIXBUG5809).
set TEMP_DIR=C:\Users\someuser\Deletables\WiXTemp

REM Like in clean.bat, but leave other MSI versions during experiments.
if exist *.wixobj del *.wixobj
if exist *.wixpdb del *.wixpdb
if exist NetBeans-files.wxs del NetBeans-files.wxs
if exist netbeans-%NETBEANS_VERSION%.msi del netbeans-%NETBEANS_VERSION%.msi

if exist "%TEMP_DIR%" rmdir /S /Q "%TEMP_DIR%"
mkdir "%TEMP_DIR%"

REM For testing, copy the real launcher EXE into DummyPayload, so we can see its icon.
mkdir DummyPayload\bin 2>nul
copy netbeans64.exe DummyPayload\bin >nul

REM Copy payload to TEMP_DIR as a workaround for WIXBUG5809.
mkdir "%TEMP_DIR%\payload"
xcopy "%PAYLOAD_DIR%" "%TEMP_DIR%\payload" /Q /H /E >nul
set PAYLOAD_DIR=%TEMP_DIR%\payload

call buildmsi_ci.bat

if exist "%TEMP_DIR%" rmdir /S /Q "%TEMP_DIR%"
