#!/bin/bash

if [ $# -lt 2 ]; then
    echo usage : $0 \<JoplinNote.md\> \<JekyllPostDir\>
    exit 1
fi

CURPWD=`pwd`
echo -n "JOPLINBASE search... "
cd "`dirname "$1"`"
while [ ! -d "./_resources" ]; do
    if [ "`pwd`" == "/" ]; then
        echo " export root with '_resources' folder not found !"
        exit 2
    fi
    cd ..
done
JOPLINBASE="`pwd`/"
cd ${CURPWD}
echo ${JOPLINBASE}

echo -n "Relative JOPLINPATH search... "
JOPLINPATH=`dirname "$1"`
JOPLINPATH=`readlink -e "${JOPLINPATH}"`/
JOPLINPATH=`echo "${JOPLINPATH}" | sed "s~${JOPLINBASE}~~"`
if [ ! -d "${JOPLINBASE}${JOPLINPATH}" ]; then
    echo "${JOPLINBASE}${JOPLINPATH} not found !" 
    exit 3
fi
echo ${JOPLINPATH}

echo -n "JOPLINFILE search... "
JOPLINFILE=`basename "$1"`
if [ ! -f "${JOPLINBASE}${JOPLINPATH}${JOPLINFILE}" ]; then
    echo "${JOPLINBASE}${JOPLINPATH}${JOPLINFILE} not found !" 
    exit 4
fi
echo ${JOPLINFILE}

echo -n "Page UID generation (Francois specific)..."
JEKYLLUID=`echo "${JOPLINPATH}${JOPLINFILE}" | sed 's~ ~~g;s~/\([[:digit:]]*\)[- ]*~\1~g;s~^\([-[:alnum:]]\+\).*~\1~'`
JEKYLLUID=`echo "${JEKYLLUID}" | sed 's~^Installation~Debian11~'`
echo "${JEKYLLUID}"

echo -n "Page title generation (Francois specific)..."
JEKYLLTITLE=`echo "${JOPLINPATH} ${JOPLINFILE}" | sed 's~[-/ [:digit:]]]*~ ~g;s~^\([- [:alnum:]]\+\).*~\1~;s~^ *~~;s~ \+~ ~g'`
JEKYLLTITLE=`echo "${JEKYLLTITLE}" | sed 's~^Installation~Debian11~'`
echo "${JEKYLLTITLE}"

echo -n "JEKYLLBASE search... "
cd $CURPWD
pwd
cd "$2"
while [ ! -f "./_config.yml" ]; do
    if [ "`pwd`" == "/" ]; then
        echo " root with '_config.yml' file not found !"
        exit 5
    fi
    cd ..
done
JEKYLLBASE="`pwd`/"
cd ${CURPWD}
echo ${JEKYLLBASE}

echo -n "Relative JEKYLLPATH search... "
JEKYLLPATH="$2"
JEKYLLPATH=`readlink -e "${JEKYLLPATH}"`/
JEKYLLPATH=`echo "${JEKYLLPATH}" | sed "s~${JEKYLLBASE}~~"`
if [ ! -d "${JEKYLLBASE}${JEKYLLPATH}" ]; then
    echo "${JEKYLLBASE}${JEKYLLPATH} not found !" 
    exit 6
fi
echo ${JEKYLLPATH}

echo -n "Jekyll post filename generation... "
JEKYLLFILE="`date +"%Y-%m-%d"`-${JEKYLLUID}.md"
echo "${JEKYLLFILE}"

echo -n "Jekyll assets dirname generation... "
JEKYLLASSETS="assets/${JEKYLLPATH}${JEKYLLUID}/"
JEKYLLASSETS=`echo ${JEKYLLASSETS} | sed 's~/_~/~g'`
echo "${JEKYLLASSETS}"

echo -n "Converting ${JOPLINBASE}${JOPLINPATH}${JOPLINFILE} to ${JEKYLLBASE}${JEKYLLPATH}${JEKYLLFILE}... "
cat << EOF > "${JEKYLLBASE}${JEKYLLPATH}${JEKYLLFILE}"
---
uid: ${JEKYLLUID}
title: ${JEKYLLTITLE}
description: 
category: Debian
tags: [ Debian, Debian 10, Debian 11, Buster, Bullseye, Server, Installation ]
published: false
---
EOF
tail -n +2 "${JOPLINBASE}${JOPLINPATH}${JOPLINFILE}" | sed 's~^\[toc\]~* TOC\n{:toc}~;s~{{~{% raw %}{{{% endraw %}~g' >> "${JEKYLLBASE}${JEKYLLPATH}${JEKYLLFILE}"
echo OK

echo -n "Migrating resources from ${JOPLINBASE}/_resources to ${JEKYLLBASE}${JEKYLLASSETS} and updating the post links"
mkdir -p ${JEKYLLBASE}${JEKYLLASSETS}
for i in `grep '../../_resources/' "${JEKYLLBASE}${JEKYLLPATH}${JEKYLLFILE}"`; do
    res=`echo "$i" | sed 's~!\?\[.*\](\([^)]\+\))~\1~'`
    res=`basename "${res}"`
    cp "${JOPLINBASE}_resources/$res" "${JEKYLLBASE}${JEKYLLASSETS}"
    sed -i "s~../../_resources/$res~{{ \"/${JEKYLLASSETS}$res\" | relative_url }}~g" "${JEKYLLBASE}${JEKYLLPATH}${JEKYLLFILE}"
done

exit

basepath=`dirname "$0"`
basepath=`readlink -e $basepath`
filepath=`dirname "$1"`
filepath=`readlink -e "$filepath"`
filepath=`echo "$filepath" | sed "s~$basepath~~"`
filename=`basename "$1"`
uid=`echo "$filepath/$filename" | sed 's~ ~~g;s~/\([[:digit:]]*\)-\?~\1~g;s~^\([-[:alnum:]]\+\).*~\1~'`
uid=`echo "$uid" | sed 's~^Installation~Debian11~'`
title=`echo "$filepath $filename" | sed 's~[-/ [:digit:]]]*~ ~g;s~^\([- [:alnum:]]\+\).*~\1~;s~^ *~~;s~ \+~ ~g'`
title=`echo "$title" | sed 's~^Installation~Debian11~'`
blogpost=$2"`date +"%Y-%m-%d"`-${uid}.md"
#echo basepath = $basepath
#echo filepath = $filepath
#echo filename = $filename
echo Converting "$1" to "$blogpost"...
cat << EOF > $blogpost
---
uid: $uid
title: $title
description: 
category: Debian
tags: [ Debian, Debian 10, Debian 11, Buster, Bullseye, Server, Installation ]
published: false
---
EOF
tail -n +2 "$1" | sed 's~^\[toc\]~* TOC\n{:toc}~;s~{{~{% raw %}{{{% endraw %}~g' >> $blogpost

for i in `grep '../../_resources/' $blogpost`; do
    res=`echo "$i" | sed 's~!\?\[.*\](\([^)]\+\))~\1~'`
    mkdir -p assets/posts/$uid/
    cp "$basepath/$filepath/$res" "assets/posts/$uid/"
    baseres=`basename "$res"`
    sed -i "s~$res~{{ \"/assets/posts/$uid/$baseres\" | relative_url }}~g" $blogpost
done

