@echo off
setlocal enabledelayedexpansion

REM Get NYT crossword puzzle by ID
REM Usage: get_puzzle_by_id.bat <puzzle_id>
REM Example: get_puzzle_by_id.bat 12345
REM Requires: curl (built into Windows 10+)

if "%1"=="" (
    echo Usage: %~nx0 ^<puzzle_id^>
    echo Example: %~nx0 12345
    exit /b 1
)

set "PUZZID=%1"
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

set "DEST=%CROSSWORD_DEST_BASE%\NewYorkTimes"
if not exist "%DEST%" mkdir "%DEST%"

REM Create temporary directory
set "TMP_DIR=%DEST%\tmp"
if exist "%TMP_DIR%" rd /s /q "%TMP_DIR%"
mkdir "%TMP_DIR%"

REM Validate puzzle ID
if "%PUZZID%"=="null" (
    echo ERROR: No puzzle ID found; aborting
    rd /s /q "%TMP_DIR%"
    exit /b 1
)

set "PUZZ_URL=https://www.nytimes.com/svc/crosswords/v2/puzzle/%PUZZID%.pdf?southpaw=true"
echo %PUZZ_URL%

echo Downloading puzzle ID: %PUZZID%
curl -b "%COOKIE_FILE%" -OJ "%PUZZ_URL%" --output-dir "%TMP_DIR%"

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
