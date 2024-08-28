#!/bin/sh

dirname="$(date +'Backup-%Y%m%d')"

function init () {
    az login
    az extension add --name azure-devops
    mkdir $dirname && cd $_
}

function getRepoList () {
    list=$(az repos list --org $1 --project $2 | jq -r '.[] | select(.name | contains ("smp")) | .sshUrl')
}

function replace () {
    echo "replaces token and secrets"    
}

function acr_login () {
    az acr login --name $1
}

function cloneRepos () {
    for url in $list; do
        git clone $url &
    done
    echo "Cloning repos..."
    wait
    clear
    echo "all done"
}

function menu(){
	clear
	while [ true ]
	do
		echo "1 - Clone all 'SMP' prefixed repos"
        echo "(q)uit"
        
        echo $list
        list=''

		read question

		if [ $question == '1' ]
		then
			init
			acr_login
			getRepoList
			cloneRepos
			exit 0
		elif [ $question == 'q' ]
		then
			clear
			exit 0
		fi
	done
}

clear
menu
