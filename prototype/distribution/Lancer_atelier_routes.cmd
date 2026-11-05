@echo off
if /i "%~1"=="col" (
    start "" "%~dp0For_the_Fortress.exe" --screen 1 -- --atelier-col
    exit /b
)
start "" "%~dp0For_the_Fortress.exe" --screen 1 -- --atelier-routes
