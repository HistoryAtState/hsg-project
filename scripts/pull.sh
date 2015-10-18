#!/bin/bash

# Adapted from:
#   https://gist.github.com/robolson/75456
#   http://stackoverflow.com/questions/15602059/git-shortcut-to-pull-with-clone-if-no-local-there-yet/15602111#15602111

repos=( 
  "tei-simple-pm"
  "hsg-shell"
  "frus"
  "pocom"
  "travels"
  "visits"
  "rdcr"
  "wwdai"
  "s3"
  "gsh"
)

remotes=(
  "https://github.com/wolfgangmm/tei-simple-pm.git"
  "https://github.com/eXistSolutions/hsg-shell.git"
  "https://github.com/HistoryAtState/frus.git"
  "https://github.com/HistoryAtState/pocom.git"
  "https://github.com/HistoryAtState/travels.git"
  "https://github.com/HistoryAtState/visits.git"
  "https://github.com/HistoryAtState/rdcr.git"
  "https://github.com/HistoryAtState/wwdai.git"
  "https://github.com/joewiz/s3.git"
  "https://github.com/joewiz/gsh.git"
)

echo "Checking" ${#repos[@]} "repositories for updates"

if [ ! -d "repos" ]; then
  mkdir repos
fi

cd repos

for ((i=0;i<${#repos[@]};++i));
do
  echo "Starting check of" ${repos[i]}
  if cd ${repos[i]};
    then echo "Pulling" ${repos[i]}; git pull; cd ..;
    else echo "Cloning" ${repos[i]} "from" ${remotes[i]}; git clone ${remotes[i]};
  fi
done

cd ..
