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
  SVN_STATUS_RESULT=`svn status`

  # if exists diff, not exicute update
  if [ -n "${SVN_STATUS_RESULT}" ]; then
    SUBJECT="[svn_update_error]${SRC_DIR}"
    BODY="svn error at ${SRC_DIR}: ${SVN_STATUS_RESULT}"
    echo ${BODY} | mail -s ${SUBJECT} ${ADMIN_MAIL}
    #echo $SVN_STATUS_RESULT # for debug
  else
    SVN_UPDATE_RESULT=`svn update --username $SVN_USERNAME --password $SVN_PASSWORD --no-auth-cache --non-interactive | grep "^\(A\|B\|D\|U\|C\|G\|E\)\s"`

    # if updated, send notice mail.
    if [ -n "${SVN_UPDATE_RESULT}" ]; then
      SUBJECT="[svn_updated]${SRC_DIR}"
      BODY="svn updated at ${SRC_DIR}: ${SVN_UPDATE_RESULT}"
      echo ${BODY} | mail -s ${SUBJECT} ${ADMIN_MAIL}
      #echo $SVN_UPDATE_RESULT # for debug
    fi
  fi
done

