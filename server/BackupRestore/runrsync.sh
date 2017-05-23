#! /bin/bash

client_folder_name="BackupRestore"
client_id="client1"

cat ~/$client_folder_name/previousrsync.sh >> ~/$client_folder_name/rsync.sh
> ~/$client_folder_name/previousrsync.sh

MAX_TRY=3
count=0
try=0
while read line;
do
{	
	if [ $count -eq 0 ]
	then
		line1=$line
		`$line1`
	else
		line2=$line
		#echo $line1
		#echo $line2
		while ! $line2
		do
			if [ $try -eq $MAX_TRY ]
			then
				echo $line1 >> ~/$client_folder_name/previousrsync.sh
				echo $line2 >> ~/$client_folder_name/previousrsync.sh
				break
			fi
			echo "tring again"
			try=$((try+1))
		done

	fi
	count=$((1-count))
}
done <~/$client_folder_name/rsync.sh
