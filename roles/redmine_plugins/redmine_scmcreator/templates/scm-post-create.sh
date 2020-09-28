#!/bin/sh
# $1 : repository path

case "$2" in

  git)
    git --git-dir=$1 update-server-info
    git --git-dir=$1 config http.receivepack true
    mv $1/hooks/update.sample $1/hooks/update
    mv $1/hooks/post-update.sample $1/hooks/post-update
    echo $1 | sed 's/.*\///' > $1/description
    git --git-dir=$1 config --bool hooks.allowunannotated true
    git --git-dir=$1 config --bool receive.denyNonFastforwards true
    git --git-dir=$1 config --bool receive.denyDeletes true
    git --git-dir=$1 config --bool core.quotepath false
  ;;

  svn)
  ;;

  *)
  ;;

esac
