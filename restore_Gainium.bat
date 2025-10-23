@echo off
setlocal ENABLEDELAYEDEXPANSION
pushd "%~dp0"

set "TITLE=Gainium Restore"
set "VOLUMES=mongo redis rabbitmq backtest-candles backtest-files"

echo ==============================================
echo %TITLE%
echo ==============================================
echo Available backups in this folder:
echo.

dir /b /o-d *_backup_*.tar.gz
if errorlevel 1 (
    echo No backup archives found in this folder.
    pause & popd & exit /b 1
)

echo(
echo You can restore one or more of the following volumes:
echo     mongo, redis, rabbitmq, backtest-candles, backtest-files
echo(
set /p "vols=Enter comma-separated list of volumes to restore (or Q to cancel): "
if /i "%vols%"=="Q" popd & exit /b 0

for %%V in (%vols%) do (
    echo(
    set "PATTERN=%%~V_backup_*.tar.gz"
    for /f "delims=" %%F in ('dir /b /o-d "!PATTERN!" 2^>nul') do (
        set "latest=%%F"
        goto :found_%%V
    )
    echo [WARN] No backups found for volume %%V
    goto :next_%%V
    :found_%%V
    echo Latest backup for %%V: !latest!
    :next_%%V
)

echo(
set /p "confirm=Type YES to continue and overwrite existing data: "
if /i not "%confirm%"=="YES" (
    echo Restore cancelled.
    pause & popd & exit /b 0
)

echo(
echo === %TITLE%: Stopping containers ===
docker compose down || (echo [ERROR] Failed to stop containers & pause & popd & exit /b 1)

for %%V in (%vols%) do (
    set "PATTERN=%%~V_backup_*.tar.gz"
    for /f "delims=" %%F in ('dir /b /o-d "!PATTERN!" 2^>nul') do (
        set "backupfile=%%F"
        goto :restore_%%V
    )
    echo [WARN] No backup found for %%V, skipping.
    goto :continue_%%V
    :restore_%%V
    echo(
    echo === Restoring %%V from !backupfile! ===
    echo -> Verifying archive integrity...
    tar -tzf "!backupfile!" >nul 2>&1 || (
        echo [ERROR] Backup for %%V appears corrupted. Skipping.
        goto :continue_%%V
    )

    docker volume inspect %%V >nul 2>&1 || (
        echo -> Creating missing volume %%V ...
        docker volume create %%V >nul
    )

    docker run --rm -v %%V:/data -v "%CD%:/backup" busybox sh -c "rm -rf /data/* && tar xzf /backup/!backupfile! -C /"
    :continue_%%V
)

echo(
echo === %TITLE%: Restarting containers ===
docker compose up -d || (echo [ERROR] Failed to start containers & pause & popd & exit /b 1)

echo -> Cleaning up dangling resources...
docker system prune -f >nul 2>&1

echo(
echo === %TITLE%: Done! Opening dashboard... ===
start "" "http://localhost:7500/"
docker compose ps

popd
endlocal
pause
exit /b 0
