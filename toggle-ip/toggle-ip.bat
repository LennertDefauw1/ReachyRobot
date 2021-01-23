@echo off
rem echo %0
rem echo %~dp0
powershell.exe -executionpolicy remotesigned -File %~dp0toggle-ip.ps1
pause
