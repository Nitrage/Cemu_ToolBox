@echo off
setlocal EnableDelayedExpansion

set exe7zip=".\7za.exe"
set exeWget=".\wget.exe"
set tmpWget="%tmp%\wget.tmp"
if exist %tmpWget% del %tmpWget%

rem -= download json =-
echo Check for Updates...
rem -= test internet connection =-
for /f "tokens=2 delims=[]" %%a in ('ping "github.com" -n 1') do (
 %exeWget% -q "https://api.github.com/repos/Nitrage/Cemu_ToolBox/releases/latest" -O %tmpWget%
)

:top
if not exist ".toolbox" (
 if exist %tmpWget% (
  rem -= search in json =-
  for /f "tokens=3 delims=:" %%a in ('type %tmpWget% ^| find "browser_download_url"') do (
   set link=https:%%a
   set link=!link:~0,-1!
   rem -= extract browser zip name =-
   for /f "tokens=8 delims=/" %%b in ("!link!") do (
    rem -= download and extract zip =-
    echo Downloading... : %%b
    %exeWget% -q "!link!" -O "%%b" --show-progress
    %exe7zip% x -y "%%b" >nul
    rem -= delete zip =-
    del %%b
   )
  )
 )
 if not exist %tmpWget% (
  echo Error : No Internet Connection
  timeout /t 3 >nul
  exit
 )
)

call ".toolbox\index.bat"

if exist "%dirCurrent%\%dirScript%" (
 if exist %tmpWget% (
  rem -= search in config =-
  for /f "tokens=2 delims= " %%a in ('type %txtConfig% ^| find "tb_version"') do (
   rem -= search in json =-
   for /f "tokens=7 delims=/" %%b in ('type %tmpWget% ^| find "browser_download_url"') do (
    if "%%a" equ "%%b" (
     rem -= delete json =-
     del %tmpWget%
     echo.
     echo Up to date     : ToolBox_%%a
     echo.
     timeout /t 1 >nul
     call %batStart%
    )
    if "%%a" neq "%%b" (
     rem -= delete old .toolbox =-
     echo Uninstall      : ToolBox_%%a
     rmdir /S /Q "%dirCurrent%\%dirScript%"
     goto top
    )
   )
  )
 )
 if not exist %tmpWget% (
  echo Skipped...
  timeout /t 1 >nul
  call %batMenu%
 )
)