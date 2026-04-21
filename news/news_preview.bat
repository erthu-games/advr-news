@echo off
REM Launches a tiny local HTTP server and opens the news preview in your default browser.
REM Close this window (Ctrl+C or just close it) to stop the server.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0news_preview_server.ps1"
pause
