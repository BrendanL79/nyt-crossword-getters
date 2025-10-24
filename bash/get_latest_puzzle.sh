#!/usr/bin/env bash

cookies=$PWD/www.nytimes.com_cookies.txt

if [ -z "$CROSSWORD_DEST_BASE" ]
then
    CROSSWORD_DEST_BASE=$PWD
fi

dest=${CROSSWORD_DEST_BASE}/NewYorkTimes/`date +%Y`/`date +%b`/
mkdir -p "$dest"
cd "$dest"

mkdir tmp
cd tmp

puzzid=`curl -b "$cookies" "https://www.nytimes.com/svc/crosswords/v3//puzzles.json?publish_type=daily&sort_order=asc&sort_by=print_date&limit=1" | jq '.results[0].puzzle_id'`

if [ ${puzzid} == "null" ]
then
  echo "no puzzle id found; aborting"
  exit -1
fi

curl -b "$cookies" -OJ "https://www.nytimes.com/svc/crosswords/v2/puzzle/$puzzid.pdf?southpaw=true"

file=`ls -1rt ./*.pdf | tail -n1`

suffix=0

while [ -e "$dest/$file" ]; do
  prefix=${file:0:-4}
  if [ ${suffix} -gt 0 ]
  then
    prefix=${prefix:0:-2}
  fi
  let "suffix++"
  newfile=${prefix}_${suffix}.pdf
  mv ${file} ${newfile}
  file=${newfile}
done

mv ${file} ../
cd ..
rm -rf ./tmp

echo "Saved as ${dest}${file}."
