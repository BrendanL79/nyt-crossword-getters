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

REM Get current year and month
for /f "tokens=1-3 delims=/ " %%a in ('date /t') do (
    set "MONTH=%%a"
    set "DAY=%%b"
    set "YEAR=%%c"
)

REM Convert numeric month to 3-letter abbreviation
if "%MONTH%"=="01" set "MONTH_ABBR=Jan"
if "%MONTH%"=="02" set "MONTH_ABBR=Feb"
if "%MONTH%"=="03" set "MONTH_ABBR=Mar"
if "%MONTH%"=="04" set "MONTH_ABBR=Apr"
if "%MONTH%"=="05" set "MONTH_ABBR=May"
if "%MONTH%"=="06" set "MONTH_ABBR=Jun"
if "%MONTH%"=="07" set "MONTH_ABBR=Jul"
if "%MONTH%"=="08" set "MONTH_ABBR=Aug"
if "%MONTH%"=="09" set "MONTH_ABBR=Sep"
if "%MONTH%"=="10" set "MONTH_ABBR=Oct"
if "%MONTH%"=="11" set "MONTH_ABBR=Nov"
if "%MONTH%"=="12" set "MONTH_ABBR=Dec"

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
