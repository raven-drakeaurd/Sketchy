@echo off
title Sketchy setup
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
if errorlevel 1 echo Setup did not finish. See the message above.
pause
