@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Import SD Stream Files (Date-Aware)

REM ============================
REM CONFIG
REM ============================

set "SD_STREAM=D:\PRIVATE\AVCHD\BDMV\STREAM"

REM ============================
REM VERIFY SD CARD PATH
REM ============================

if not exist "%SD_STREAM%" (
    echo SD card path not found:
    echo %SD_STREAM%
    exit /b 1
)

REM ============================
REM GET TODAY (MMDDYYYY)
REM ============================

for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format MMddyyyy"') do (
    set "TODAY=%%i"
)

REM ============================
REM RESOLVE DESKTOP PATH
REM ============================

for /f "usebackq delims=" %%D in (`
    powershell -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"
`) do set "DESKTOP=%%D"

REM ============================
REM FIND TODAY'S CASE FOLDER
REM ============================

set "CASE_DIR="

for /d %%F in ("%DESKTOP%\*-!TODAY!") do (
    set "CASE_DIR=%%F"
    goto :FOUND
)

:FOUND

if "%CASE_DIR%"=="" (
    echo No case folder found for today (%TODAY%).
    exit /b 1
)

REM ============================
REM CREATE LEFTOVERS FOLDER
REM ============================

set "LEFTOVERS=%CASE_DIR%\LEFTOVERS"

if not exist "%LEFTOVERS%" (
    mkdir "%LEFTOVERS%"
)

REM ============================
REM OPEN SD CARD FOLDER
REM ============================

explorer "%SD_STREAM%"

REM ============================
REM PROCESS FILES
REM ============================

echo.
echo Processing files by recorded date...
echo.

for %%F in ("%SD_STREAM%\*") do (

    for /f %%D in ('
        powershell -NoProfile -Command ^
        "(Get-Item \"%%F\").CreationTime.ToString(\"MMddyyyy\")"
    ') do set "FILEDATE=%%D"

    if "!FILEDATE!"=="%TODAY%" (
        copy "%%F" "%CASE_DIR%\" >nul
    ) else (
        copy "%%F" "%LEFTOVERS%\" >nul
    )
)

echo.
echo Import complete.
echo Today's clips -> %CASE_DIR%
echo Older clips   -> %LEFTOVERS%
echo.

exit /b 0
