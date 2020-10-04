##!/bin/bash

RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
RESET=`tput sgr0`
QUOTES=("Earphones On!!")


printf "${RED}

  _____ _    ____  _   _    _    ____      _    _   
 |_   _| |_ |__ / /_\ | |__| |_ |__ /_ __ (_)__| |_ 
   | | | ' \ |_ \/ _ \| / _| ' \ |_ \ '  \| (_-<  _|
   |_| |_||_|___/_/ \_\_\__|_||_|___/_|_|_|_/__/\__|
                                                    

                      

${RESET}"
cd /home/debian/bb/   #My hunting folder
mkdir $1
cd $1
#Starting sublist3r
sublist3r -d $1 -o domains.txt

#Starting assetfinder
assetfinder -subs-only $1 | tee -a domains.txt

#Starting findomain
findomain -t $1 | tee -a domains.txt

#Starting subfinder
subfinder -d $1 -o domains.txt

#Starting amass
amass enum -d $1 -o domains.txt

#Starting CRT.sh
curl -s https://crt.sh/\?q\=\%.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee -a crt.txt

#Running httpx for csp subdomain enum

cat domains.txt | httpx -csp-probe | tee -a alive.txt

#Putting it in domains.txt !! 
cat crt.txt | rev | cut -d "."  -f 1,2,3 | sort -u | rev | tee -a domains.txt

#Removing duplicate entries
sort -u domains.txt -o domains.txt

#Checking for alive domains
echo "**************[+] Checking for alive domains***********"
cat domains.txt | fprobe -c 40 | tee -a alive.txt


#running aquatone 
mkdir aquatone; cd aquatone ;cat /home/debian/bb/$1/alive.txt | aquatone 

#Running wayback

cd /home/debian/$1 ; cat alive.txt | waybackurls | tee wayback.txt

#Running gau 

cd /home/debian/$1 ; cat alive.txt | gau | tee gau.txt

prompt_confirm "${BLUE}[+] ${YELLOW}Want to Run dirsearch on each url? (it'll take 30min-1hours)"


prompt_confirm() {
  while true; do
    read -r -n 1 -p "${1:-Continue?} [y/n]: " REPLY
    case $REPLY in
      [yY])  while read line; do dirsearch -u "$line"  -b -s 0.5 -e .* -x 500,502,400 --plain-text-report dirs.txt;done <alive.txt
        ;;
      [nN]) echo ; return 1 ;;
      *) printf " \033[31m %s \n\033[0m" "Only  {Y/N}"
    esac
  done
}

printf "${RED}
#GOOD LUCK !!! 
${RESET}"
