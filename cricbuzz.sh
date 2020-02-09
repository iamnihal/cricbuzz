#!/bin/bash

FILE=./matchFileqwxert.txt
if [ -f "$FILE" ]
then
    rm matchFileqwxert.txt
fi

clear
RED='\033[0;31m'
NC='\033[0m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
end=$'\e[0m'

echo -e "${RED}[+] Fetching Current Matches [+]${NC}"
echo -e "${RED}--------------------------------\n${NC}"

#To grab the list of URLs of current cricket matches
currentMatches=$(curl -sL https://www.cricbuzz.com/cricket-match/live-scores | grep -Po 'live-cricket-scores\/\d{5}/(\w+)' | sort -ur | sed 's|^|https://cricbuzz.com/|g')

for i in "$currentMatches"
do
    #To extract the Match Name
    matchHeading=$(curl -sL $i | grep -Po '<h1[^>]?(.+?)<\/h1>' | grep -Po '(?<=\>)(?!\<)(.*)(?=\<)(?<!\>)' | cut -d',' -f 1)
done

i=1
#To print list of all the current cricket matches
while IFS= read -r line
do
    printf '%s\n' "${yel}$i) $line ${end}"
    i=$((i + 1))
done <<< "$matchHeading"

i=1
while IFS= read -r line
do
    #Storing list of cricket match's URL in a file with numeric id which can be used for selecting individual matches.
    printf '%s\n' "$i) $line" >> matchFileqwxert.txt
    i=$((i + 1))
done <<< "$currentMatches"


while (true)
do
    echo -e "\n"
    echo -e "${RED}Choose:-${NC}"
    echo "1) Print all"
    echo "2) Print individually"
    echo -e "3) Exit\n"
    echo -e "${RED}What you want to do?${NC}"
    read choice
    if [ $choice == 1 ]
    then
        i=1
        echo -e "\n"
        echo -e "${grn}[+] Printing current report of all matches [+]${end}"
        echo -e "${grn}----------------------------------------------\n${end}"
        while IFS= read -r line
        do
            printf '%s\n' "${yel}$i) $line ${end}"
            #Extracting URL from the file according to the numeric id.
            score=$(grep -Pw "^$i" matchFileqwxert.txt | cut -d' ' -f 2)
            curl -Ls $score 2>/dev/null | grep -Eo '([A-Z]){2,4}([0-9]+)?\s([0-9]){1,3}(,|/)(\s|[0-9]+)(\s|[0-9]+)[/(]([0-9]+)(\s|.)[(0-9]+([.0-9)]+)?'
            if [ "$?" -ne 0 ]
            then
                echo -e "${RED}I think match is not started yet.${NC}"
            fi
            i=$((i + 1 ))
        done <<< "$matchHeading"
    fi

    if [ $choice == 2 ]
    then
        read -rp "${grn}Score you want to know:-${end} " subChoice
        matchName=$(echo "$matchHeading" | sed -n "$subChoice p")
        echo -e "\n"
        printf '%s\n' "${yel}$subChoice)$matchName${end}"
        #Extracting URL from the file according to the numeric id given by user and saving it to score variable.
        score=$(grep -Pw "^$subChoice" matchFileqwxert.txt | cut -d' ' -f 2)
        #Doing curl to the URL and extracting RUNS from the page using RegEx.
        curl -Ls $score 2>/dev/null | grep -Eo '([A-Z]){2,4}([0-9]+)?\s([0-9]){1,3}(,|/)(\s|[0-9]+)(\s|[0-9]+)[/(]([0-9]+)(\s|.)[(0-9]+([.0-9)]+)?'
        if [ "$?" -ne 0 ]
        then
            echo -e "${RED}I think match is not started yet.${NC}"
        fi
    fi

    if [ $choice == 3 ]
    then
        rm matchFileqwxert.txt
        exit
    fi
done
