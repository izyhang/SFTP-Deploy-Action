#!/bin/sh -l

#set -e at the top of your script will make the script exit with an error whenever an error occurs (and is not explicitly handled)
set -eu

echo 'deploy start'

SFTP_USER_NAME=$1
SFTP_SERVER=$2
SFTP_PORT=$3
SSH_PRIVATE_KEY=$4
SFTP_SRC=$5
SFTP_DEST_SRC=$6
SFTP_ARGS=$7
SSH_COMMAND=$8

TEMP_SSH_PRIVATE_KEY_FILE='../private_key.pem'
TEMP_SFTP_FILE='../sftp'

# keep string format
printf "%s" "$SSH_PRIVATE_KEY" >$TEMP_SSH_PRIVATE_KEY_FILE
# avoid Permissions too open
chmod 600 $TEMP_SSH_PRIVATE_KEY_FILE

echo 'sftp start'

# create a temporary file containing sftp commands
printf "%s" "put -r $SFTP_SRC $SFTP_DEST_SRC" >$TEMP_SFTP_FILE
#-o StrictHostKeyChecking=no avoid Host key verification failed.
sftp -b $TEMP_SFTP_FILE -P $SFTP_PORT $SFTP_ARGS -o StrictHostKeyChecking=no -i $TEMP_SSH_PRIVATE_KEY_FILE $SFTP_USER_NAME@$SFTP_SERVER

echo 'sftp success'

echo 'checking ssh command'

if [ -z "$SSH_COMMAND" ]
then
    echo 'no ssh command'
else
    echo 'ssh command start'
    ssh -p $SFTP_PORT -o StrictHostKeyChecking=no -i $TEMP_SSH_PRIVATE_KEY_FILE $SFTP_USER_NAME@$SFTP_SERVER "cd $SFTP_DEST_SRC;$SSH_COMMAND"
    echo 'ssh command success'
fi

echo 'deploy success'

exit 0
