#!/bin/bash
PROJECT=$@
resetColour=`echo -e '\033[0m'`
colours=('\033[1;31m' '\033[1;32m' '\033[1;33m' '\033[1;34m' '\033[1;35m' '\033[1;36m' '\033[1;37m' '\033[1;38m' '\033[1;39m' '\033[0;31m' '\033[0;32m' '\033[2;33m' '\033[2;34m' '\033[2;35m' '\033[2;36m' '\033[2;37m' '\033[2;38m' '\033[2;39m')

function prepend_output () {
    local streamTitle=$1
    local streamColour=$2
    streamTitle=$(awk '{x=$0;for(i=length;i<40;i++)x=x " ";}END{print x}' <<< "$streamTitle")
    sed -e "s/^/${streamColour}${streamTitle}${resetColour}| /"
}

function getRepoList() {
    az repos list --org 'https://dev.azure.com/ajgre' --project "$PROJECT" --query [].[name,sshUrl] --output tsv
}

function cloneRepos() {
  echo "Cloning repos..."
  getRepoList | while read line
  do
    local streamColour=`echo -e "${colours[RANDOM%${#colours[@]}]}"`
    local name=$(echo $line | awk '{print $1}')
    local sshUrl=$(echo $line | awk '{print $2}')
    git clone $sshUrl | prepend_output $name $streamColour &
    echo $sshUrl | prepend_output $name $streamColour &
  done
  wait
}

function menu(){
  clear
  while [ true ]
  do
    echo "1 - login to ADO (if not already)"
    echo "2 - install azure-devops extension for az-cli"
    echo "3 - Clone all repos in ${PROJECT}"
    echo ""
    echo "   (q)uit"
    read question
   
    if [ $question == '1' ]
    then
      az login
      clear
    elif [ $question == '2' ]
    then
      az extension add --name azure-devops
      clear
    elif [ $question == '3' ]
    then
      cloneRepos
      exit 0
    elif [ $question == 'q' ]
    then
      clear
      exit 0
    fi
  done
}

menu
