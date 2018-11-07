@echo off
setlocal EnableDelayedExpansion

set exe7zip=".\7za.exe"
set exeWget=".\wget.exe"
set tmpWget="%tmp%\wget.tmp"

if not exist ".\.toolbox" (
 rem -= download json =-
 echo Downloading... : latest.json
 %exeWget% -q "https://api.github.com/repos/Nitrage/Cemu_ToolBox/releases/latest" -O %tmpWget%
 rem -= search in json =-
 for /f "tokens=3 delims=:" %%a in ('type %tmpWget% ^| find "browser_download_url"') do (
  set link=https:%%a
  set link=!link:~0,-1!
  rem -= extract browser zip name =-
  for /f "tokens=8 delims=/" %%b in ("!link!") do (
   rem -= download and extract zip =-
   echo Downloading... : %%b
   %exeWget% -q "!link!" -O ".\%%b" --show-progress
   %exe7zip% x -y ".\%%b" >nul
   rem -= delete json an zip =-
   del %tmpWget%
   del %%b
  )
 )
)

call ".toolbox\index.bat"

if exist "%dirCurrent%\%dirScript%" (
 call %batMenu%
)