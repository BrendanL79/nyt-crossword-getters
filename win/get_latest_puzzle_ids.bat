@echo off
setlocal

REM Get latest puzzle IDs from NYT crossword API
REM Usage: get_latest_puzzle_ids.bat <limit>
REM Example: get_latest_puzzle_ids.bat 5
REM Requires: curl (built into Windows 10+) and PowerShell

if "%1"=="" (
    echo Usage: %~nx0 ^<limit^>
    echo Example: %~nx0 5
    exit /b 1
)

set "LIMIT=%1"
set "COOKIE_FILE=%CD%\www.nytimes.com_cookies.txt"

if not exist "%COOKIE_FILE%" (
    echo ERROR: Cookie file not found: %COOKIE_FILE%
    echo Please save your NYT cookies to this file.
    exit /b 1
)

REM Query API and parse with PowerShell
curl -s -b "%COOKIE_FILE%" "https://www.nytimes.com/svc/crosswords/v3//puzzles.json?publish_type=daily&sort_order=asc&sort_by=print_date&limit=%LIMIT%" | powershell -command "$input | ConvertFrom-Json | Select-Object -ExpandProperty results | Select-Object puzzle_id, print_date | ConvertTo-Json"

endlocal
