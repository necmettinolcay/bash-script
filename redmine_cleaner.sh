#!/bin/bash

#set -x

USER="redmine"
PASSWORD="redmine123"
HOST="localhost"
DB_NAME="redmine"
BACKUP_FILE="/srv/redmine.sql"
PLUGIN_FILE="/opt/redmine/plugins/"
MYSQL=$(which mysql)
AWK=$(which awk)
GREP=$(which grep)

function checkDatabase {
  $MYSQL -u $USER -p$PASSWORD -h $HOST -e "use $DB_NAME"  &>/dev/null
  if [ $? -ne 0 ]
  then
     echo "Cannot connect to mysql server using given username, password or database does not exits!"
     exit 2
  fi
}
 
function dropTables {  
  TABLES=$($MYSQL -u $USER -p$PASSWORD -h $HOST $DB_NAME -e 'show tables' | $AWK '{ print $1}' | $GREP -v '^Tables' )
  if [ "$TABLES" == "" ]
  then
     echo "Error - No table found in $DB_NAME database!"
     exit 3
  fi
 
  for t in $TABLES
  do
     echo "Deleting $t table from $DB_NAME database..."  
     $MYSQL -u $USER -p$PASSWORD -h $HOST $DB_NAME -e "drop table $t"
  done
}

function pressDump {
  echo "redmine service stopping"
  service redmine stop
  echo "Restoring clean sql dump"
  $MYSQL -u $USER -p$PASSWORD -h $HOST $DB_NAME  < $BACKUP_FILE
  echo "redmine service starting"
  service redmine start
}

checkDatabase
dropTables
pressDump
echo "Removing redmine plugins"
shopt -s extglob
rm -rf $PLUGIN_FILE!(README) 



