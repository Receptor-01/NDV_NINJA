@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Create Case Folder

REM ============================
REM PROMPT FOR SUBJECT INITIALS
REM ============================

set /p SUBJECT=Enter subject initials (F_L): 

if "%SUBJECT%"=="" (
    echo No initials entered. Exiting.
    exit /b 1
)

REM ============================
REM GET DATE (MMDDYYYY)
REM ============================

for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format MMddyyyy"') do (
    set "TODAY=%%i"
)

REM ============================
REM RESOLVE DESKTOP PATH
REM ============================

for /f "usebackq delims=" %%D in (`powershell -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"`) do (
    set "DESKTOP=%%D"
)

REM ============================
REM BUILD & CREATE FOLDER
REM ============================

set "FOLDER_NAME=%SUBJECT%-%TODAY%"
set "DEST=%DESKTOP%\%FOLDER_NAME%"

if exist "%DEST%" (
    echo Folder already exists:
    echo %DEST%
    exit /b 1
)

mkdir "%DEST%"

echo.
echo Created folder:
echo %DEST%
echo.

exit /b 0
