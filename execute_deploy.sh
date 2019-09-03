#!/bin/sh

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
  GIT_STATUS_RESULT="`git status | grep -e modified -e added -e deleted -e renamed -e copied -e updated`"

  if [ -n "${GIT_BRANCH}" -a -z "${GIT_STATUS_RESULT}" ]; then
    GIT_UPDATE_RESULT="`git pull --rebase $GIT_REMOTE $GIT_BRANCH`"

    # if updated, send notice mail.
    if [ `echo "${GIT_UPDATE_RESULT}" | grep -E '^Updating [a-z0-9]{7}\.\.[a-z0-9]{7}'` ]; then
      if "${IS_SEND_MAIL_UPDATED}"; then
        SUBJECT="[git_updated]${SRC_DIR}"
        BODY="git updated at ${SRC_DIR}: ${GIT_UPDATE_RESULT}"
        echo "${BODY}" | mail -s ${SUBJECT} ${ADMIN_MAIL}
      fi
    fi
  elif "${IS_SEND_MAIL_ERROR}"; then
    if [ -z "${GIT_BRANCH}" ]; then
      BODY="branch is not selected"
    elif [ -n "${GIT_STATUS_RESULT}" ]; then
      BODY="git error at ${SRC_DIR}:\n${GIT_STATUS_RESULT}"
    fi

    SUBJECT="[git_update_error]${SRC_DIR}"
    echo "${BODY}" | mail -s ${SUBJECT} ${ADMIN_MAIL}
  fi
done

