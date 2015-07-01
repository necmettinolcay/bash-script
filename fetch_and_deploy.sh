#!/bin/bash

 
GIT_REPO="git@lab.ozguryazilim.com.tr:redmine_plugins"
REDMINE_ROOT='/opt/redmine'
PLUGIN_DIR="${REDMINE_ROOT}/plugins"
PLUGIN=$1
source $HOME/.bashrc


if [ "$(id -u )" != "$(id -u redmine)" ]; then
   echo "script will only work with redmine user " 1>&2
   exit
fi

function clonePlugin {
  if [[ ! -d "$PLUGIN_DIR/$PLUGIN" ]]; then
     echo "$PLUGIN is clonning from repo  "
     cd $PLUGIN_DIR; git clone $GIT_REPO/$PLUGIN
  else
     echo "$PLUGIN is exist in plugin directory"
     exit 1
  fi
}

function addPlugin {
  service redmine stop
  echo "Updating redmine"
  cd $REDMINE_ROOT
  bundle install --without postgresql development test sqlite
  rake redmine:plugins:migrate RAILS_ENV=production
  service redmine start
}

clonePlugin
addPlugin
