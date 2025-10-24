@echo off
setlocal enabledelayedexpansion

REM Get the latest NYT crossword puzzle PDF
REM Requires: curl (built into Windows 10+) and PowerShell

set "COOKIE_FILE=%CD%\www.nytimes.com_cookies.txt"

if not exist "%COOKIE_FILE%" (
    echo ERROR: Cookie file not found: %COOKIE_FILE%
    echo Please save your NYT cookies to this file.
    exit /b 1
)

REM Set destination base directory
if "%CROSSWORD_DEST_BASE%"=="" (
    set "CROSSWORD_DEST_BASE=%CD%"
)

REM Get current year and month using PowerShell (locale-independent)
for /f %%i in ('powershell -command "Get-Date -Format yyyy"') do set "YEAR=%%i"
for /f %%i in ('powershell -command "Get-Date -Format MMM"') do set "MONTH_ABBR=%%i"

set "DEST=%CROSSWORD_DEST_BASE%\NewYorkTimes\%YEAR%\%MONTH_ABBR%"
if not exist "%DEST%" mkdir "%DEST%"

REM Create temporary directory
set "TMP_DIR=%DEST%\tmp"
if exist "%TMP_DIR%" rd /s /q "%TMP_DIR%"
mkdir "%TMP_DIR%"

REM Query API for latest puzzle ID
echo Fetching latest puzzle ID...
curl -s -b "%COOKIE_FILE%" "https://www.nytimes.com/svc/crosswords/v3//puzzles.json?publish_type=daily&sort_order=asc&sort_by=print_date&limit=1" > "%TMP_DIR%\response.json"

REM Parse puzzle_id using PowerShell
for /f "delims=" %%i in ('powershell -command "(Get-Content '%TMP_DIR%\response.json' | ConvertFrom-Json).results[0].puzzle_id"') do set "PUZZID=%%i"

if "%PUZZID%"=="" (
    echo ERROR: No puzzle ID found; aborting
    rd /s /q "%TMP_DIR%"
    exit /b 1
)

if "%PUZZID%"=="null" (
    echo ERROR: No puzzle ID found; aborting
    rd /s /q "%TMP_DIR%"
    exit /b 1
)

echo Downloading puzzle ID: %PUZZID%
curl -b "%COOKIE_FILE%" -OJ "https://www.nytimes.com/svc/crosswords/v2/puzzle/%PUZZID%.pdf?southpaw=true" --output-dir "%TMP_DIR%"

REM Find the downloaded PDF file
for /f "delims=" %%f in ('dir /b /o:d "%TMP_DIR%\*.pdf" 2^>nul') do set "FILE=%%f"

if "%FILE%"=="" (
    echo ERROR: No PDF file downloaded
    rd /s /q "%TMP_DIR%"
    exit /b 1
)

REM Handle duplicate filenames
set "SUFFIX=0"
set "FINALFILE=%FILE%"

:check_exists
if exist "%DEST%\%FINALFILE%" (
    REM Extract filename without extension
    set "PREFIX=%FILE:~0,-4%"
    
    REM Remove previous suffix if exists
    if !SUFFIX! gtr 0 (
        set "PREFIX=!PREFIX:~0,-2!"
    )
    
    set /a SUFFIX+=1
    set "FINALFILE=!PREFIX!_!SUFFIX!.pdf"
    goto check_exists
)

REM Move file from tmp to destination
move "%TMP_DIR%\%FILE%" "%DEST%\%FINALFILE%" >nul

REM Clean up tmp directory
rd /s /q "%TMP_DIR%"

echo Saved as %DEST%\%FINALFILE%

endlocal
