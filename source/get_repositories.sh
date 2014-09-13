#!/bin/bash

FILE=${1:-community.csv}

# SET WORKING DIRECTORY TO SCRIPT DIRECTORY
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

mkdir -p base
mkdir -p libraries
mkdir -p modules
mkdir -p sites
mkdir -p themes

while IFS=, read FOLDER NAME URL BRANCH
do
  mkdir -p $FOLDER
  SOURCE="$DIR/$FOLDER/$NAME"
  echo "CHECKING $SOURCE"

  if [ -d "$SOURCE" ]
  then
      cd $SOURCE
      git checkout $BRANCH
      echo "GIT PULLING $BRANCH FOR $NAME"
      git pull origin $BRANCH
      cd $DIR
  else
      echo "GIT CLONING $NAME AND CHECKING OUT $BRANCH"
      cd $FOLDER
      git clone $URL $NAME
      cd $SOURCE
      git checkout $BRANCH
      cd $DIR
  fi
done < $FILE
