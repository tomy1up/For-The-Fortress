@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Lancer_le_prototype.ps1"
if errorlevel 1 pause
