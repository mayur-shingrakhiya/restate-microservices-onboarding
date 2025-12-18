@echo off
REM =====================================
REM Configuration - Change this to your project name
REM =====================================
set PROJECT_NAME=restate-tutorial
set CONTAINER_NAME=%PROJECT_NAME%_restate_dev
set IMAGE_NAME=docker.restate.dev/restatedev/restate:latest

echo =====================================
echo STEP 1: Starting Restate Docker
echo =====================================
echo Project: %PROJECT_NAME%
echo Container: %CONTAINER_NAME%
echo.

REM Cleanup first
echo Cleaning up previous runs...
docker stop %CONTAINER_NAME% >nul 2>&1
docker rm -f %CONTAINER_NAME% >nul 2>&1

REM Kill any process using port 9080
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :9080 ^| findstr LISTENING') do (
    echo Killing process on port 9080 (PID: %%a)
    taskkill /F /PID %%a >nul 2>&1
)

echo Cleanup complete!
echo.

REM Start Restate Docker
echo Starting Docker container: %CONTAINER_NAME%...
docker run ^
  --name %CONTAINER_NAME% ^
  --rm ^
  -d ^
  -p 8080:8080 ^
  -p 9070:9070 ^
  -p 9071:9071 ^
  --add-host=host.docker.internal:host-gateway ^
  %IMAGE_NAME%

if %errorlevel% neq 0 (
    echo ERROR: Failed to start Docker container
    pause
    exit /b 1
)

echo Docker container started successfully!
echo Waiting 5 seconds for Restate to initialize...
timeout /t 5 /nobreak >nul

echo.
echo =====================================
echo STEP 2: Starting Project Dev Server
echo =====================================
echo.


pause