@echo off
setlocal

set "ROOT=%~dp0"
set "PYTHON=python"
set "LATEST="

if exist "%ROOT%\.venv\Scripts\python.exe" (
    set "PYTHON=%ROOT%\.venv\Scripts\python.exe"
)

if "%~1"=="" (
    echo Usage: .\dbflow "migration message"
    echo Example: .\dbflow "add coach tables"
    exit /b 1
)

echo [1/3] Generating migration...
"%PYTHON%" -m alembic revision --autogenerate -m %*
if errorlevel 1 exit /b %ERRORLEVEL%

for /f "usebackq delims=" %%F in (`powershell -NoProfile -Command "Get-ChildItem -Path '%ROOT%alembic\versions' -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty FullName"`) do (
    set "LATEST=%%F"
)

echo.
echo [2/3] Review the generated migration before applying it:
echo %LATEST%
echo Press any key to continue with upgrade, or close this window / Ctrl+C to stop.
pause >nul

echo.
echo [3/3] Applying migration...
"%PYTHON%" -m alembic upgrade head
exit /b %ERRORLEVEL%
