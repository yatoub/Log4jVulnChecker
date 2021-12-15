#!/bin/bash

#set -x
#trap read debug
RED="\033[0;31m"; GREEN="\033[32m"; YELLOW="\033[1;33m"; ENDCOLOR="\033[0m"

read -p "This script need unzip installed on the server. Do you want to continue ? (Y/N) " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

echo -e ${YELLOW}"### locate files containing log4j ..."${ENDCOLOR1}
OUTPUT="$(find / -name 'log4j*' 2>/dev/null|grep -v log4js|grep -v log4j_checker_beta)"
if [ "$OUTPUT" ]; then
  echo -e ${RED}"[WARNING] maybe vulnerable, those files contain the name:"${ENDCOLOR}
  echo "$OUTPUT"
fi;
if [ "$(command -v yum)" ]; then
  echo -e ${YELLOW}"### check installed yum packages ..."${ENDCOLOR1}
  OUTPUT="$(yum list installed|grep log4j|grep -v log4js)"
  if [ "$OUTPUT" ]; then
    echo -e ${RED}"[WARNING] maybe vulnerable, yum installed packages:"${ENDCOLOR}
    echo "$OUTPUT"
  fi;
fi;
if [ "$(command -v dpkg)" ]; then
  echo -e ${YELLOW}"### check installed dpkg packages ..."${ENDCOLOR1}
  OUTPUT="$(dpkg -l|grep log4j|grep -v log4js)"
  if [ "$OUTPUT" ]; then
    echo -e ${RED}"[WARNING] maybe vulnerable, dpkg installed packages:"${ENDCOLOR}
    echo "$OUTPUT"
  fi;
fi;
echo -e ${YELLOW}"### check if Java is installed ..."${ENDCOLOR1}
JAVA="$(command -v java)"
if [ "$JAVA" ]; then
  version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
  echo -e ${RED}"[WARNING] Java is installed with version "$version${ENDCOLOR}
  echo "Java applications often bundle their libraries inside jar/war/ear files, so there still could be log4j in such applications.";
else
  echo -e ${GREEN}"[OK]"${ENDCOLOR}" Java is not installed"
fi;
echo -e ${YELLOW}"### locate the files to look in more depth ..."${ENDCOLOR1}
OUTPUT="$(find / -name '*.war' 2>/dev/null|grep -v log4js|grep -v log4j_checker_beta)"
if [ "$OUTPUT" ]; then
  echo -e ${RED}"[WARNING] .war detected :"${ENDCOLOR}
  echo "$OUTPUT"
  for file in $(find / -name '*.war' -type f 2>/dev/null)
  do
      OUTPUT="$(unzip -l ${file} |grep log4j* |awk -F '   ' '{print $3}')"
      if [ "$OUTPUT" ]; then
        echo -e ${RED}"[WARNING] maybe vulnerable, those files in war "${file}" contain the name:"${ENDCOLOR}
        echo "$OUTPUT"
      fi;
  done
else
  echo -e ${GREEN}"[OK]"${ENDCOLOR}" No .war detected"
fi;
echo -e ${YELLOW}"_________________________________________________"${ENDCOLOR}
echo "If you see no uncommented output above this line, you are safe. Otherwise check the listed files and packages.";
if [ "$JAVA" == "" ]; then
  echo "Some apps bundle the vulnerable library in their own compiled package, so 'java' might not be installed but one such apps could still be vulnerable."
fi
echo
echo "Note, this is not 100% proof you are not vulnerable, but a strong hint!"
