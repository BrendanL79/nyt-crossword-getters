Set of scripts to facilitate automatic retrieval of New York Times daily crossword PDF's.

You need an active NYT digital subscription, and to download your cookies for nytimes.com from an active desktop browser session.
Save the resulting cookies text file as www.nytimes.com_cookies.txt alongside these scripts.

At some point your cookies will expire and any puzzle download attempts will fail silently until you update the cookie file.

I am left-handed, so these scripts request the "southpaw" version of the puzzles.
If you prefer the traditional layout, simply remove "?southpaw=true" from the end of the URL that is passed to curl in the scripts.
Occasionally, the puzzle has special layout features that preclude auto-generation, so you will get the as-printed version regardless.

