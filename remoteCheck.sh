#! /bin/bash

# this script is supposed to be run by crontab
#2 3 * * * /path/to/remoteCheck.sh 'sshd@yourmycloud' &

# handle input
if [ $# -ne 1 ]
then
	exit 1
fi

MYCLOUD="${1}"

mycloud_error()
{
	printf "%s\t%s\n%s\n" \
		`date '+%Y%m%d-%H:%M:%S'` \
		"Could not SSH (presumabely the key was de-authorized and we were prompted for a password instead)." \
		"cat ~/.ssh/id_rsa.pub | ssh "${MYCLOUD}" 'cat - >> /home/root/.ssh/authorized_keys'" \
		> "~/Desktop/MyCloud_ERROR.txt"
	exit 0
}

# set pipefail
set -o pipefail

# check if we can ssh in
ssh "${MYCLOUD}" 'crontab -l'

if [ $? -ne 0 ]
then
	mycloud_error
fi

# presumabely we can successfully ssh in,
# now check if the backup job is present
ENTRY_PRESENT=`ssh "${MYCLOUD}" 'crontab -l' | grep -c '/home/root/backup.sh'`

if [ $? -eq 0 ]
then
	if [ ${ENTRY_PRESENT} -eq 0 ]
	then
		ssh "${MYCLOUD}" 'printf "%s\n" "4 */3 * * * /home/root/backup.sh &" >> /var/spool/cron/crontabs/root'
	fi
else
	mycloud_error
fi

# set pipefail back to normal
set +o pipefail

# exit 
exit 0

