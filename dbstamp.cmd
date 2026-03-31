@echo off
setlocal

set "ROOT=%~dp0"
set "PYTHON=python"
set "TARGET=%~1"

if exist "%ROOT%\.venv\Scripts\python.exe" (
    set "PYTHON=%ROOT%\.venv\Scripts\python.exe"
)

if "%TARGET%"=="" (
    set "TARGET=head"
)

"%PYTHON%" -m alembic stamp %TARGET%
exit /b %ERRORLEVEL%
