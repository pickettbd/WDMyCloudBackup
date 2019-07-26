#! /bin/bash

# this script is supposed to be run by crontab
#4 */3 * * * /home/root/backup.sh &

# set pipefail
set -o pipefail

# check if backup job is already running
BK_PROC=`ps -u root | grep 'usb_backup -a mycloud2easyshar -c jobrun' | grep -v 'grep'`

EXIT_CODE=$?

# check if backup process is running
if [ $EXIT_CODE -eq 0 ]
then
	unset EXIT_CODE

	# it  was running, now report and quit

	# get the pid
	BK_PROC=`printf "%s" "${BK_PROC}" | sed -r 's/ +/ /g' | sed -r 's/^ //' | cut -d ' ' -f 1`

	# display a message
	printf "%s\t%s\n" `date '+%Y%m%d-%H:%M:%S'` "Backup was already running (pid: ${BK_PROC})." >> "~/backups.log"

else
	unset EXIT_CODE

	# It wasn't running, now report and run
	printf "%s\t%s\n" `date '+%Y%m%d-%H:%M:%S'` "Backup started." >> "~/backups.log"

	# run the backup
	(usb_backup -a mycloud2easyshar -c jobrun &)

fi

# set pipefail back to normal
set +o pipefail

# exit 
exit 0

