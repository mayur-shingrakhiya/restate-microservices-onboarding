@echo off
REM =====================================
REM Configuration - Change this to your project name
REM =====================================
set PROJECT_NAME=restate-tutorial
set CONTAINER_NAME=%PROJECT_NAME%_restate_dev
set IMAGE_NAME=docker.restate.dev/restatedev/restate:latest
set CLI_IMAGE=docker.restate.dev/restatedev/restate-cli:latest

echo =====================================
echo Cleaning up Restate Project
echo =====================================
echo Project: %PROJECT_NAME%
echo.

REM =====================================
REM STEP 1: Stop and Remove Containers
REM =====================================
echo STEP 1: Stopping and removing containers...
echo.

REM Stop main project container
echo Stopping main container: %CONTAINER_NAME%
docker stop %CONTAINER_NAME% >nul 2>&1
if %errorlevel% equ 0 (
    echo   ^(Stopped^)
) else (
    echo   ^(Not running^)
)
docker rm -f %CONTAINER_NAME% >nul 2>&1

REM Stop old container names for backward compatibility
echo Stopping legacy containers...
docker stop restate_dev >nul 2>&1
docker rm -f restate_dev >nul 2>&1
docker stop restate_tutorial_dev >nul 2>&1
docker rm -f restate_tutorial_dev >nul 2>&1
docker rm -f %PROJECT_NAME%_register >nul 2>&1

REM Remove all containers with project prefix
echo Removing all project-related containers...
set FOUND_CONTAINERS=0
for /f "tokens=*" %%i in ('docker ps -a -q --filter "name=%PROJECT_NAME%" 2^>nul') do (
    echo   Removing container: %%i
    docker rm -f %%i >nul 2>&1
    set FOUND_CONTAINERS=1
)
if %FOUND_CONTAINERS% equ 0 (
    echo   ^(No project containers found^)
)

echo Container cleanup complete!
echo.

REM =====================================
REM STEP 2: Kill Processes on Ports
REM =====================================
echo STEP 2: Killing processes on project ports...
echo.

REM Kill process on port 9080 (dev server)
set FOUND_9080=0
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :9080 ^| findstr LISTENING 2^>nul') do (
    echo Killing process on port 9080 ^(PID: %%a^)
    taskkill /F /PID %%a >nul 2>&1
    set FOUND_9080=1
)
if %FOUND_9080% equ 0 (
    echo Port 9080: ^(No process found^)
)

REM Kill process on port 8080 (Restate API)
set FOUND_8080=0
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8080 ^| findstr LISTENING 2^>nul') do (
    echo Killing process on port 8080 ^(PID: %%a^)
    taskkill /F /PID %%a >nul 2>&1
    set FOUND_8080=1
)
if %FOUND_8080% equ 0 (
    echo Port 8080: ^(No process found^)
)

REM Kill process on port 9070 (Restate Dashboard)
set FOUND_9070=0
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :9070 ^| findstr LISTENING 2^>nul') do (
    echo Killing process on port 9070 ^(PID: %%a^)
    taskkill /F /PID %%a >nul 2>&1
    set FOUND_9070=1
)
if %FOUND_9070% equ 0 (
    echo Port 9070: ^(No process found^)
)

REM Kill process on port 9071 (Restate Admin)
set FOUND_9071=0
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :9071 ^| findstr LISTENING 2^>nul') do (
    echo Killing process on port 9071 ^(PID: %%a^)
    taskkill /F /PID %%a >nul 2>&1
    set FOUND_9071=1
)
if %FOUND_9071% equ 0 (
    echo Port 9071: ^(No process found^)
)

echo Port cleanup complete!
echo.

REM =====================================
REM STEP 3: Kill Node.js Dev Server
REM =====================================
echo STEP 3: Stopping Node.js dev server...
echo.

REM Find and kill npm/node processes for this project
set FOUND_NODE=0
for /f "tokens=2" %%a in ('tasklist /FI "IMAGENAME eq node.exe" /FO LIST ^| findstr /C:"PID:" 2^>nul') do (
    REM Get the command line for this PID
    for /f "tokens=*" %%b in ('wmic process where "ProcessId=%%a" get CommandLine 2^>nul ^| findstr "dev"') do (
        echo Killing Node.js dev server ^(PID: %%a^)
        taskkill /F /PID %%a >nul 2>&1
        set FOUND_NODE=1
    )
)
if %FOUND_NODE% equ 0 (
    echo ^(No Node.js dev server found^)
)

echo.

REM =====================================
REM STEP 4: Remove Docker Images (Optional)
REM =====================================
echo STEP 4: Docker image cleanup
echo.
echo Do you want to remove Docker images? ^(Y/N^)
echo This will delete:
echo   - %IMAGE_NAME%
echo   - %CLI_IMAGE%
echo.
echo These images will be re-downloaded when you run the setup script again.
echo.
set /p REMOVE_IMAGES="Remove images? (Y/N): "

if /i "%REMOVE_IMAGES%"=="Y" (
    echo.
    echo Removing Restate image...
    docker rmi %IMAGE_NAME% >nul 2>&1
    if %errorlevel% equ 0 (
        echo   ^[REMOVED^] %IMAGE_NAME%
    ) else (
        echo   ^[SKIPPED^] Image not found or in use
    )
    
    echo Removing Restate CLI image...
    docker rmi %CLI_IMAGE% >nul 2>&1
    if %errorlevel% equ 0 (
        echo   ^[REMOVED^] %CLI_IMAGE%
    ) else (
        echo   ^[SKIPPED^] Image not found or in use
    )
    
    echo Image cleanup complete!
) else (
    echo Skipping image removal.
)

echo.

REM =====================================
REM STEP 5: Clean Docker System (Optional)
REM =====================================
echo STEP 5: Docker system cleanup
echo.
echo Do you want to prune unused Docker resources? ^(Y/N^)
echo This will remove:
echo   - All stopped containers
echo   - All dangling images
echo   - All unused networks
echo   - All build cache
echo.
echo WARNING: This affects ALL Docker projects, not just %PROJECT_NAME%
echo.
set /p PRUNE_DOCKER="Prune Docker system? (Y/N): "

if /i "%PRUNE_DOCKER%"=="Y" (
    echo.
    echo Pruning Docker system...
    docker system prune -f
    echo Docker prune complete!
) else (
    echo Skipping Docker prune.
)

echo.
echo =====================================
echo Cleanup Summary
echo =====================================
echo Project: %PROJECT_NAME%
echo.
echo Completed:
echo   [x] Stopped and removed all project containers
echo   [x] Killed processes on ports 8080, 9070, 9071, 9080
echo   [x] Stopped Node.js dev server
if /i "%REMOVE_IMAGES%"=="Y" (
    echo   [x] Removed Docker images
) else (
    echo   [ ] Skipped image removal
)
if /i "%PRUNE_DOCKER%"=="Y" (
    echo   [x] Pruned Docker system
) else (
    echo   [ ] Skipped Docker prune
)
echo.
echo All cleanup operations complete!
echo You can now run the setup script to start fresh.
echo.

pause