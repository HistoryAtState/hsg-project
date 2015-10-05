#!/bin/bash

repos=( 
  "tei-simple-pm"
  "hsg-shell"
  "frus"
  "pocom"
  "travels"
  "visits"
  "rdcr"
  "gsh"
)

if [ ! -d "xars" ]; then
  mkdir xars
fi

if [ ! -d "repos" ]; then
  mkdir repos
fi

cd repos 

for ((i=0;i<${#repos[@]};++i));
do
  if [ -d "${repos[i]}" ];
    then 
      echo "Building" ${repos[i]}; 
      cd ${repos[i]};
      if [ -f "bower.info" ]; then
        /usr/local/bin/bower install
      fi;
      /usr/local/bin/ant; cp build/* ../../xars/; cd ..;
    else echo "Repository directory not found:" ${repos[i]}". Please run pull.sh";
  fi
done

