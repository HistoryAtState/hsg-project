#!/bin/bash

repos=( 
  "tei-simple-pm"
  "hsg-shell"
  "frus"
  "pocom"
  "travels"
  "visits"
  "gsh"
)

cd repos 

for ((i=0;i<${#repos[@]};++i));
do
  echo "building" ${repos[i]}
  if cd ${repos[i]};
    then echo "Pulling" ${repos[i]}; /usr/local/bin/ant; cp build/* ../../xars/; cd ..;
    else echo "Not found:" ${repos[i]}". Please run pull.sh";
  fi
done

