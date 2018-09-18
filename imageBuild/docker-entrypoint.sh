#!/bin/bash
#
#   Initialize DB2 instance in a Docker container
#   author: gaerfield
#   original: https://github.com/lresende/docker-db2express-c/blob/master/docker-entrypoint.sh
pid=0
INITIALIZATION_COMPLETED_FILE=$DB2_DATA/.initialized
function log_info {
  echo -e $(date '+%Y-%m-%d %T')"\e[1;32m $@\e[0m"
}

function log_error {
  echo -e >&2 $(date +"%Y-%m-%d %T")"\e[1;31m $@\e[0m"
}

function log_file_prefix {
  echo $(date '+%F_%H-%M-%S')
}

function user_not_exists {
  [ -z $(getent passwd $@) ]
}

function ensure_Db2Users {
  log_info "check existence of Db2-System-Users"
  if user_not_exists db2inst1; then
    log_info "Creating Db2-System-Groups db2iadm1 db2fadm1 dasadm1"
    groupadd -g 999 db2iadm1
    groupadd -g 998 db2fadm1
    groupadd -g 997 dasadm1
    log_info "Creating Db2-System-Users db2iadm1 db2fadm1 dasadm1"
    useradd -u 1009 -g db2iadm1 -m -d /home/db2inst1 db2inst1 && echo db2inst1:db2inst1 | chpasswd
    useradd -u 1008 -g db2fadm1 -m -d /home/db2fenc1 db2fenc1 && echo db2fenc1:db2fenc1 | chpasswd
    useradd -u 1007 -g dasadm1  -m -d /home/dasusr1  dasusr1  && echo dasusr1:dasusr1 | chpasswd
    log_info "creating $DB2_DATA/databases and $DB2_DATA/tablespaces"
    mkdir -p $DB2_DATA/databases
    mkdir -p $DB2_DATA/tablespaces
  fi
}

function init_Db2 {
  log_info "initialize DB2"
  log_info "Creating DB2 Administration Server"
  $DB2_HOME/instance/dascrt -u dasusr1
  log_info "Creating DB2-Instance 'db2inst1'"
  $DB2_HOME/instance/db2icrt -a server -p 50000 -u db2fenc1 db2inst1
  log_info "setting permissions"
  chown -R db2inst1.db2iadm1 $DB2_DATA
}

function stop_db2 {
  log_info "stopping the DB-Engine"
  su - db2inst1 -c "db2stop force"
}

function start_db2 {
  log_info "starting the DB-Engine"
  su - db2inst1 -c "db2start"
}

function restart_db2 {
  # if you just need to restart db2 and not to kill this container
  # use docker kill -s USR1 <container name>
  kill ${spid}
  log_info "Restarting DB-Engine ..."
  stop_db2
  start_db2
  log_info "DB-Engine successfully restarted"
}

function terminate_db2 {
  kill ${spid}
  stop_db2
  if [ $pid -ne 0 ]; then
    kill -SIGTERM "$pid"
    wait "$pid"
  fi
  log_info "DB-Engine has shut down"
  exit 0 # finally exit main handler script
}

function create_db {
  log_info "Creating Database using /data/$@"
  log_info "This could take very long, so be patient - enjoy a good black coffee"
  LOG_FILE="/data/$(log_file_prefix)_installDb.log"
  su - db2inst1 -c "db2 -tvsf /data/$@" >> $LOG_FILE
  log_info "done (or failed?) - please check the Log-File: $LOG_FILE"
}

function exists_db {
  # means: if is [ not empty $(list Dbs | grep DBNAME=$@) ]
  [ ! -z "$(su - db2inst1 -c "db2 LIST DATABASE DIRECTORY | grep \"^[[:space:]]*Database name[[:space:]]*=[[:space:]]*$@$\"")" ]
}

##### Main-Block
trap "terminate_db2"  SIGTERM
trap "restart_db2"   SIGUSR1
ensure_Db2Users
if user_not_exists $DB_USER; then
  log_info "Creating DB-User $DB_USER"
  groupadd -g 996 $DB_USER
  useradd -u 1006 -g $DB_USER -m -d /home/$DB_USER $DB_USER && echo "$DB_USER:$DB_PASSWORD" | chpasswd
fi
if [ ! -e $INITIALIZATION_COMPLETED_FILE ]; then
  init_Db2
  touch $INITIALIZATION_COMPLETED_FILE
fi
start_db2

if exists_db $DB_NAME; then
  log_info "found database $DB_NAME"
else
  log_info "no database $DB_NAME where found"
  case $STARTUP_MODE in
    restoreIfNotExists)
      log_info "executing restore"
      restoreDb $DB_BACKUP
      ;;
    createIfNotExists)
      log_info "no database $DB_NAME where found"
      create_db $DB_CREATE_SCRIPT
      ;;
    *)
      echo "The value of the STARTUP_MODE - environment-variable is not known. Valid Values are 'createIfNotExists, 'restore', 'restoreIfNotExists'"
      echo "exiting"
      exit 1
      ;;
  esac
fi

# TODO Wouldn't `tail -F` be sufficient?
log_info "watching db2diag.log"
tail -f ~db2inst1/sqllib/db2dump/db2diag.log &
touch file
tail -f file
