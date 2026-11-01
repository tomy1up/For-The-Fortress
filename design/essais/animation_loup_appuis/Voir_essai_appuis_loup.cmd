@echo off
setlocal DisableDelayedExpansion
"C:\Projet\.tools\Godot-4.7.2\Godot_v4.7.2-stable_win64.exe" --main-pack "C:\Projet\For the Fortress!\dist\For_the_Fortress_v0.106_Windows_x64\For_the_Fortress.exe" --screen 1 --script "%~dp0workshop.gd"
if errorlevel 1 pause
