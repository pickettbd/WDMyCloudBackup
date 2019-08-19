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
		"cat ~/.ssh/id_rsa.pub | ssh \"${MYCLOUD}\" 'cat - >> /home/root/.ssh/authorized_keys'" \
		> "~/Desktop/MyCloud_ERROR.txt"
	exit 0
}

# set pipefail
set -o pipefail

# check if the backup job is present
TMP=/tmp/$$
ssh "${MYCLOUD}" 'crontab -l' > "${TMP}" 2> /dev/null

if [ $? -eq 0 ]
then
	grep '/home/root/backup.sh' "${TMP}" &> /dev/null
	EXIT_STATUS=$?

	if [ ${EXIT_STATUS} -eq 1 ]
	then
		ssh "${MYCLOUD}" 'printf "%s\n" "4 */3 * * * /home/root/backup.sh &" >> /var/spool/cron/crontabs/root'
		#printf "it was NOT there\n" 1>&2

	#elif [ ${EXIT_STATUS} -eq 0 ]
	#then
	#	printf "it was there\n" 1>&2
	#else
	#	printf "grep error\n" 1>&2
	fi
else
	printf "hit this error 1"
	mycloud_error
fi

# cleanup
rm -f "${TMP}"

# set pipefail back to normal
set +o pipefail

# exit 
exit 0

