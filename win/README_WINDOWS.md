# NYT Crossword Getters - Windows Batch Versions

Windows batch file versions of the NYT crossword download scripts.

## Requirements

- **Windows 10 or later** (curl is built-in)
- **PowerShell** (built-in on all modern Windows)
- **Active NYT digital subscription**
- **Cookie file**: `www.nytimes.com_cookies.txt`

## Setup

1. Export your NYT cookies from your browser:
   - Use a browser extension like "Get cookies.txt LOCALLY" or "cookies.txt"
   - Log into nytimes.com in your browser
   - Export cookies for nytimes.com
   - Save as `www.nytimes.com_cookies.txt` in the same directory as these scripts

2. (Optional) Set the `CROSSWORD_DEST_BASE` environment variable:
   ```batch
   set CROSSWORD_DEST_BASE=C:\Users\YourName\Documents\Crosswords
   ```
   If not set, files will be saved relative to the current directory.

## Scripts

### get_latest_puzzle.bat
Downloads the most recent available NYT crossword puzzle.

**Usage:**
```batch
get_latest_puzzle.bat
```

**Output:**
- Saves to: `%CROSSWORD_DEST_BASE%\NewYorkTimes\YYYY\MMM\filename.pdf`
- Example: `C:\Crosswords\NewYorkTimes\2025\Oct\nyt-crossword-2025-10-24.pdf`

### get_latest_puzzle_ids.bat
Queries for the most recent puzzle IDs and print dates.

**Usage:**
```batch
get_latest_puzzle_ids.bat <limit>
```

**Example:**
```batch
get_latest_puzzle_ids.bat 5
```

**Output:**
JSON formatted list of puzzle IDs and their print dates.

### get_puzzle_by_id.bat
Downloads a specific puzzle by its ID.

**Usage:**
```batch
get_puzzle_by_id.bat <puzzle_id>
```

**Example:**
```batch
get_puzzle_by_id.bat 12345
```

**Output:**
- Saves to: `%CROSSWORD_DEST_BASE%\NewYorkTimes\filename.pdf`

## Features

- **Automatic directory creation**: Creates year/month subdirectories automatically
- **Duplicate file handling**: Adds _1, _2, etc. suffix if file already exists
- **Cookie validation**: Checks for cookie file existence before attempting download
- **Southpaw (left-handed) layout**: Default setting (can be changed by removing `?southpaw=true` from URLs)
- **Error handling**: Validates puzzle IDs and provides clear error messages

## Differences from Bash Versions

1. **Date formatting**: Uses Windows date format and converts to 3-letter month abbreviation
2. **JSON parsing**: Uses PowerShell's `ConvertFrom-Json` instead of `jq`
3. **Temporary directory cleanup**: Uses `rd /s /q` instead of `rm -rf`
4. **Path separators**: Uses backslashes `\` instead of forward slashes `/`

## Troubleshooting

### Cookie Issues
If downloads fail silently or you get authentication errors:
- Re-export your cookies from your browser
- Ensure you're logged into nytimes.com when exporting
- Check that the cookie file is in the same directory as the scripts

### Date Format Issues
The script assumes MM/DD/YYYY date format (US). If your Windows uses a different format, you may need to adjust the date parsing section.

### PowerShell Execution Policy
If you get PowerShell errors, you may need to adjust your execution policy:
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

## Notes

- **Southpaw layout**: These scripts request the left-handed version of puzzles by default. To get the traditional layout, edit the scripts and remove `?southpaw=true` from the curl URLs.
- **Special puzzles**: Some puzzles have special layouts that prevent auto-generation; in these cases, you'll get the as-printed version regardless of the southpaw parameter.
- **Cookie expiration**: Cookies will eventually expire, requiring you to re-export them from your browser.

## Example Workflow

```batch
REM Set your preferred base directory
set CROSSWORD_DEST_BASE=C:\Users\Brendan\Documents\Crosswords

REM Download today's puzzle
get_latest_puzzle.bat

REM Check the last 7 puzzle IDs
get_latest_puzzle_ids.bat 7

REM Download a specific puzzle
get_puzzle_by_id.bat 12345
```

## Scheduling Automatic Downloads

To automatically download the daily puzzle, use Windows Task Scheduler:

1. Open Task Scheduler
2. Create Basic Task
3. Set trigger (e.g., Daily at 10:00 PM)
4. Action: Start a program
5. Program: `cmd.exe`
6. Arguments: `/c "C:\path\to\get_latest_puzzle.bat"`
7. Start in: `C:\path\to\scripts\`

This will automatically download each day's puzzle at your scheduled time.
