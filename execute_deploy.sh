#!/bin/bash

# include config file
CONFIG_FILE="`dirname $0`/setup.conf"
if [ ! -f $CONFIG_FILE ]; then
  echo "Not found config file : ${CONFIG_FILE}" ; exit 1
fi
. $CONFIG_FILE

# include common file
COMMON_FILE="`dirname $0`/common.sh"
if [ ! -f $COMMON_FILE ]; then
  echo "Not found common file : ${COMMON_FILE}" ; exit 1
fi
. $COMMON_FILE

# execute main
for SRC_DIR in ${SRC_DIRS}; do
  cd $SRC_DIR
  GIT_BRANCH=`git branch | grep \*| awk '{print $2}'`
  GIT_STATUS_RESULT="`git status | grep -e modified -e added -e deleted -e renamed -e copied -e updated -e untracked`"
  ERROR=""

  if [ -z "${GIT_BRANCH}" ]; then
    ERROR="branch is not selected at ${SRC_DIR}"
  elif [ -n "${GIT_STATUS_RESULT}" ]; then
    ERROR="Repository is not clean at ${SRC_DIR}:\n${GIT_STATUS_RESULT}"
  fi


  if [ -n "${ERROR}" ]; then
    if "${IS_SEND_MAIL_ERROR}"; then
      SUBJECT="[git_update_error]${SRC_DIR}"
      echo "${ERROR}" | mail -s ${SUBJECT} ${ADMIN_MAIL}
    fi

  else
    GIT_UPDATE_RESULT="`git pull --rebase $GIT_REMOTE $GIT_BRANCH`"
    if [ `echo "${GIT_UPDATE_RESULT}" | grep -E '^Updating [a-z0-9]{7}\.\.[a-z0-9]{7}'` ]; then
      if "${IS_SEND_MAIL_UPDATED}"; then
        SUBJECT="[git_updated]${SRC_DIR}"
        BODY="git updated at ${SRC_DIR}: ${GIT_UPDATE_RESULT}"
        echo "${BODY}" | mail -s ${SUBJECT} ${ADMIN_MAIL}
      fi
    fi
  fi

done

