#/bin/bash
if [ "$(which java)" ]; then
  echo "java is installed, so note that Java applications often bundle their libraries inside jar/war/ear files, so there still could be log4j in such applications.";
fi;
echo "Java version"
if type -p java; then
    echo found java executable in PATH
    _java=java
elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
    echo found java executable in JAVA_HOME
    _java="$JAVA_HOME/bin/java"
else
    echo "no java"
fi

if [[ "$_java" ]]; then
    version=$("$_java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
    echo version "$version"
fi
echo "checking for log4j vulnerability...";
if [ "$(find / -name 'log4j*' 2>/dev/null)" ]; then
  echo "### maybe vulnerable, those files contain the name:";
  find / -name 'log4j*' 2>/dev/null
fi;
#if [ "$(dpkg -l|grep log4j|grep -v log4js)" ]; then
#  echo "### maybe vulnerable, installed packages:";
#  dpkg -l|grep log4j;
#fi;
echo "If you see no output above this line, you are safe. Otherwise check the listed files and packages.";
