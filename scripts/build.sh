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

mkdir xars
cd repos 

for ((i=0;i<${#repos[@]};++i));
do
  if cd ${repos[i]};
    then echo "Building" ${repos[i]}; /usr/local/bin/bower install; /usr/local/bin/ant; cp build/* ../../xars/; cd ..;
    else echo "Not found:" ${repos[i]}". Please run pull.sh";
  fi
done

