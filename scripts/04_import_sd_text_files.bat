@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Import SD Text Files (Module 04)

REM ============================
REM CONFIG
REM ============================

set "SD_TEXT_ROOT=D:\INTEL"

REM ============================
REM VERIFY SD PATH
REM ============================

if not exist "%SD_TEXT_ROOT%" (
    echo SD text path not found:
    echo %SD_TEXT_ROOT%
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
REM COPY TEXT FILES
REM ============================

echo.
echo Copying text files from:
echo %SD_TEXT_ROOT%
echo To:
echo %CASE_DIR%
echo.

xcopy "%SD_TEXT_ROOT%\*.txt" "%CASE_DIR%\" /I /Y >nul

echo Import complete.
echo.

exit /b 0
