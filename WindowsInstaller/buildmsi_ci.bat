@echo off

REM This script requires the following environment variables to be set:
REM   NETBEANS_VERSION NetBeans version in 0.0.0 format.
REM   MSI_PRODUCT_ID   UUID associated with the given NETBEANS_VERSION
REM   PAYLOAD_DIR      NetBeans binaries (containing %PAYLOAD_DIR%\bin\netbeans64.exe)
REM   WIX_BIN          Folder containing WiX binaries (heat.exe, candle.exe, light.exe)
REM   TEMP_DIR         Empty temporary folder not created from WSL (due to WIXBUG5809).

REM Set working directory to that of the BAT file itself, until script ends.
REM https://stackoverflow.com/questions/17063947/get-current-batchfile-directory
setlocal
cd /d "%~dp0"

REM Use heat.exe to enumerate the payload files. Exclude the netbeans64.exe executable, so we can
REM configure that one manually (with shortcuts etc.) in NetBeans.wxs

move "%PAYLOAD_DIR%\bin\netbeans64.exe" "%TEMP_DIR%\netbeans64.exe" >nul

REM See https://wixtoolset.org/docs/v3/overview/heat/
REM Use "-ag" rather than "-gg". See:
REM   https://stackoverflow.com/questions/1405100/change-my-component-guid-in-wix/1422121
REM   https://github.com/dotnet/runtime/issues/703
REM   http://lists.wixtoolset.org/pipermail/wix-users-wixtoolset.org/2016-November/003734.html
REM Omit "-ke" so that the empty "bin" directory isn't included.
"%WIX_BIN%\heat.exe" dir "%PAYLOAD_DIR%" -cg netbeansFiles -ag -scom -sfrag -srd -sreg -suid ^
    -dr NetBeansDirWithVersion -var var.buildSourceDir -out "NetBeans-files.wxs" -nologo -indent 2

REM Move the executable back into place. Do this even in case of errors, before exiting.
set ERRORLEVEL_HEAT=%ERRORLEVEL%
move "%TEMP_DIR%\netbeans64.exe" "%PAYLOAD_DIR%\bin\netbeans64.exe" >nul
if %ERRORLEVEL_HEAT% NEQ 0 exit /B

REM Setting "buildSourceDir=." makes paths relative to the "-b" parameter to light.exe
"%WIX_BIN%\candle.exe" NetBeans.wxs NetBeans-files.wxs -nologo -arch x64 ^
    "-dnetbeansVersion=%NETBEANS_VERSION%" ^
    "-dproductID=%MSI_PRODUCT_ID%" ^
    "-dbuildSourceDir=."

if %ERRORLEVEL% NEQ 0 exit /B

"%WIX_BIN%\light.exe" -ext WixUIExtension -b "%PAYLOAD_DIR%" ^
    NetBeans.wixobj NetBeans-files.wixobj ^
    -o "netbeans-%NETBEANS_VERSION%-win_x64.msi" -nologo ^
    -cultures:en-us -loc NetBeans-en-us.wxl
