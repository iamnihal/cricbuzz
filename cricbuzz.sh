#!/bin/bash

FILE=./matchFile.txt
if [ -f "$FILE" ]
then
    rm matchFile.txt
fi

clear
RED='\033[0;31m'
NC='\033[0m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
end=$'\e[0m'


echo -e "${RED}[+] Fetching Current Matches [+]\n${NC}"

currentMatches=$(curl -sL https://www.cricbuzz.com/cricket-match/live-scores | grep -Po 'live-cricket-scores\/\d{5}/(\w+)' | sort -ur | sed 's|^|https://cricbuzz.com/|g')

for i in "$currentMatches"
do
    matchHeading=$(curl -sL $i | grep -Po '<h1[^>]?(.+?)<\/h1>' | grep -Po '(?<=\>)(?!\<)(.*)(?=\<)(?<!\>)' | cut -d',' -f 1)
done

i=1
while IFS= read -r line ; do printf '%s\n' "${yel} $i) $line ${end}" ; i=$((i + 1)) ; done <<< "$matchHeading"

    i=1
    while IFS= read -r line ; do printf '%s\n' "$i) $line" >> matchFile.txt ; i=$((i + 1)) ; done <<< "$currentMatches"
        echo -e "\n"
        while (true)
        do
            read -rp "${grn}Score you want to know:-${end} " choice
            score=$(cat matchFile.txt | grep -Pw "^$choice" | cut -d' ' -f 2)
            curl -Ls $score 2>/dev/null 2>/dev/null | grep -Eo '([A-Z]){2,4}([0-9]+)?\s([0-9]){1,3}(,|/)(\s|[0-9]+)(\s|[0-9]+)[/(]([0-9]+)(\s|.)[(0-9]+([.0-9)]+)?'
            if [ "$?" -ne 0 ]
            then
                echo -e "${RED}I think match is not started yet.${NC}"
            fi
        done
