@echo off
setlocal

set "ROOT=%~dp0"
set "PYTHON=python"

if exist "%ROOT%\.venv\Scripts\python.exe" (
    set "PYTHON=%ROOT%\.venv\Scripts\python.exe"
)

if "%~1"=="" (
    echo Usage: .\mig "migration message"
    echo Example: .\mig "add chat session table"
    exit /b 1
)

"%PYTHON%" -m alembic revision --autogenerate -m %*
exit /b %ERRORLEVEL%
