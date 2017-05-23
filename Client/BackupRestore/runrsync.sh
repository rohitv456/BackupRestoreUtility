#! /bin/bash

client_folder_name="BackupRestore"

cat ~/$client_folder_name/previousrsync.sh >> ~/$client_folder_name/rsync.sh
> ~/$client_folder_name/previousrsync.sh

count=0

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
		$line2

		if [ $? -gt 0 ]
		then
			echo $line1 >> ~/$client_folder_name/previousrsync.sh
			echo $line2 >> ~/$client_folder_name/previousrsync.sh
			echo "Failed : \"$line2\""
		fi
	fi
	count=$((1-count))
}
done <~/$client_folder_name/rsync.sh
