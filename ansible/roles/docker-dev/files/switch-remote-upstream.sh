#! /bin/bash
# set -e

usage()
{
    echo "USAGE: ./swtich-remote.sh  [boucher|docker]"
}

if [ $# -eq 0 ]
then
    usage
    exit
fi

UPSTREAM=""

case "$1" in
    "boucher")
	UPSTREAM="https://github.com/boucher/docker";;
    "docker")
	UPSTREAM="https://github.com/docker/docker";;
    *)
        echo "$1 is an invalid upstream!!"
	usage
        exit;;
esac

echo "Switch to remote branch ${UPSTREAM}"
#git remote remove upstream
#git remote add upstream $UPSTREAM
git remote set-url upstream ${UPSTREAM}
