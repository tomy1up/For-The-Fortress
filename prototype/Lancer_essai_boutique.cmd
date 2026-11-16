@echo off
rem Essai de la boutique depuis les sources : toutes les unites sont possedees, profil separe.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Lancer_le_prototype.ps1" -Trial
if errorlevel 1 pause
