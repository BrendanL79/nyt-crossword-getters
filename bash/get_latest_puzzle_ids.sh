#!/usr/bin/env bash

limit=$1

cookies=$PWD/www.nytimes.com_cookies.txt

curl -b "$cookies" "https://www.nytimes.com/svc/crosswords/v3//puzzles.json?publish_type=daily&sort_order=asc&sort_by=print_date&limit=${limit}" | jq ".results[] | {puzzle_id, print_date}"
