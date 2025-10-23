@echo off
setlocal ENABLEDELAYEDEXPANSION
pushd "%~dp0"

set "TITLE=Gainium"
set "COMPOSE_FILE_URL=https://raw.githubusercontent.com/Gainium/docker-sh/main/docker-compose.yml"
set "COMPOSE_FILE=docker-compose.yml"
set "VOLUMES=mongo redis rabbitmq backtest-candles backtest-files"

echo ==============================================
echo %TITLE% - Docker controls
echo ==============================================
echo [U] Backup + Update/Start (no downtime)
echo [D] Shut Down (graceful + down)
echo [Q] Quit
echo(
set /p "CHOICE=Choose an option [U/D/Q]: "
if /i "%CHOICE%"=="Q" popd & exit /b 0

rem === Lock file to prevent double execution ===
set "LOCK=%TEMP%\gainium.lock"
if exist "%LOCK%" (
    echo [!] Another Gainium session appears active. Please close it first.
    pause
    popd
    exit /b 1
)
echo >"%LOCK%"

rem === Ensure Docker is running ===
docker info >nul 2>&1
if errorlevel 1 (
    echo Docker not ready. Starting Docker Desktop...
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe" 2>nul
    echo Waiting for Docker Engine to be ready...
    set /a retries=0
    :wait_engine_gainium
    timeout /t 2 /nobreak >nul
    docker info >nul 2>&1
    if errorlevel 1 (
        set /a retries+=1
        if !retries! GEQ 150 (
            echo [ERROR] Docker Engine did not become ready within ~5 minutes. Exiting.
            del "%LOCK%" >nul 2>&1
            pause & popd & exit /b 1
        )
        goto :wait_engine_gainium
    )
)

if /i "%CHOICE%"=="U" goto :update_start
if /i "%CHOICE%"=="D" goto :down_all

echo Invalid choice.
del "%LOCK%" >nul 2>&1
popd
pause
exit /b 1


:update_start
for /f %%i in ('powershell -NoProfile -Command "(Get-Date).ToString(\"yyyyMMdd_HHmm\")"') do set stamp=%%i

echo(
echo === %TITLE%: Creating volume backups before update ===
for %%V in (%VOLUMES%) do (
    echo -> Backing up volume %%V ...
    docker run --rm -v %%V:/data -v "%CD%:/backup" busybox sh -c "tar czf /backup/%%V_backup_%stamp%.tar.gz /data"
    if not exist "%%V_backup_%stamp%.tar.gz" (
        echo [ERROR] Backup for %%V missing! Aborting.
        del "%LOCK%" >nul 2>&1
        pause & popd & exit /b 1
    )
    tar -tzf "%%V_backup_%stamp%.tar.gz" >nul 2>&1 || (
        echo [ERROR] Backup for %%V appears corrupted! Aborting.
        del "%LOCK%" >nul 2>&1
        pause & popd & exit /b 1
    )
)

echo -> Cleaning old backups (keeping 7 most recent)...
for %%V in (%VOLUMES%) do (
    for /f "skip=7 delims=" %%F in ('dir /b /o-d %%V_backup_*.tar.gz 2^>nul') do del "%%F"
)

echo(
echo === %TITLE%: Fetching latest docker-compose.yml ===
powershell -Command "Invoke-WebRequest -Uri '%COMPOSE_FILE_URL%' -OutFile '%COMPOSE_FILE%'" || (
    echo [ERROR] Failed to download docker-compose.yml
    del "%LOCK%" >nul 2>&1
    pause & popd & exit /b 1
)

echo(
echo === %TITLE%: Pulling latest images ===
docker compose --env-file .env pull --ignore-pull-failures || (
    echo [ERROR] pull failed
    del "%LOCK%" >nul 2>&1
    pause & popd & exit /b 1
)

echo(
echo === %TITLE%: Starting/updating containers ===
docker compose --env-file .env up -d || (
    echo [ERROR] up failed
    del "%LOCK%" >nul 2>&1
    pause & popd & exit /b 1
)

echo(
echo -> Pruning unused images...
docker image prune -f >nul 2>&1

echo(
echo === %TITLE%: Done! Opening dashboard... ===
docker compose ps
start "" "http://localhost:7500/"

del "%LOCK%" >nul 2>&1
popd
pause
exit /b 0


:down_all
echo(
echo === %TITLE%: Gracefully stopping containers ===
docker compose stop -t 30

echo === %TITLE%: Shutting down compose project ===
docker compose down --remove-orphans || (
    echo [ERROR] down failed
    del "%LOCK%" >nul 2>&1
    pause & popd & exit /b 1
)

echo(
echo NOTE: Volumes/images are kept. To remove volumes too, run:
echo   docker compose down -v
del "%LOCK%" >nul 2>&1
popd
pause
exit /b 0
