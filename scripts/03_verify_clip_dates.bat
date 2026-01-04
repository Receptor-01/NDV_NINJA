@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Verify Clip Dates & Durations (Module 03)

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
REM REPORT FILE
REM ============================

set "REPORT=%DESKTOP%\CLIP_TRANSFER_REPORT_%TODAY%.txt"

REM ============================
REM POWERSHELL ANALYSIS
REM ============================

powershell -NoProfile -Command ^
"$files = Get-ChildItem -Path '%CASE_DIR%' -File | Where-Object { $_.Extension -match '\.(mp4|mts|mov)$' } | Sort-Object Name; ^
$totalFiles = $files.Count; ^
$totalSeconds = 0; ^
$details = @(); ^
$simple = @(); ^
$index = 1; ^
foreach ($f in $files) { ^
  try { ^
    $shell = New-Object -ComObject Shell.Application; ^
    $folder = $shell.Namespace($f.DirectoryName); ^
    $item = $folder.ParseName($f.Name); ^
    $dur = $folder.GetDetailsOf($item, 27); ^
    if ($dur) { ^
      $ts = [TimeSpan]::Parse($dur); ^
      $totalSeconds += $ts.TotalSeconds; ^
      $details += '{0} - {1}' -f $f.Name, $ts; ^
      $simple += ('{0:D4} - {1}:{2:D2}' -f $index, $ts.Minutes, $ts.Seconds); ^
    } else { ^
      $details += '{0} - duration unavailable' -f $f.Name; ^
      $simple += ('{0:D4} - ??:??' -f $index); ^
    } ^
  } catch { ^
    $details += '{0} - error reading duration' -f $f.Name; ^
    $simple += ('{0:D4} - error' -f $index); ^
  } ^
  $index++; ^
} ^
$totalMinutes = [Math]::Floor($totalSeconds / 60); ^
$remainingSeconds = [Math]::Round($totalSeconds %% 60); ^
'CLIP TRANSFER VERIFICATION REPORT' | Out-File '%REPORT%'; ^
'Date: %TODAY%' | Out-File '%REPORT%' -Append; ^
'Case Folder: %CASE_DIR%' | Out-File '%REPORT%' -Append; ^
'' | Out-File '%REPORT%' -Append; ^
'Total Files: ' + $totalFiles | Out-File '%REPORT%' -Append; ^
'Total Duration: ' + $totalMinutes + ' min ' + $remainingSeconds + ' sec' | Out-File '%REPORT%' -Append; ^
'' | Out-File '%REPORT%' -Append; ^
'Clip Summary (Index - Duration):' | Out-File '%REPORT%' -Append; ^
$simple | Out-File '%REPORT%' -Append; ^
'' | Out-File '%REPORT%' -Append; ^
'Detailed File Breakdown:' | Out-File '%REPORT%' -Append; ^
$details | Out-File '%REPORT%' -Append"

REM ============================
REM DONE
REM ============================

echo.
echo Verification report created:
echo %REPORT%
echo.

exit /b 0
