#! /bin/bash

server_folder_name="BackupRestore"
disk_folder_name="BackupRestore"

#MONTHLY BACKUP (LEVEL 0 BACKUP)

clients=`mysql -se "SELECT CLIENTID FROM BackupRestore.Users"`
clients_arr=($clients)
clients_arr_len=${#clients_arr[@]}
for (( j=0; j<clients_arr_len; j++ ))
do
	client_id=${clients_arr[$j]}
	result=`mysql -se "SELECT DISTINCT USERNAME,IP FROM BackupRestore.Storage,BackupRestore.Disks WHERE CLIENTID=\"$client_id\" AND Disks.DISKID=Storage.DiskID;"`
	result_arr=($result)
	result_arr_len=${#result_arr[@]}
	num_of_columns=2
	num_of_rows=$((result_arr_len/num_of_columns))
	month=`date | cut -d ' ' -f 2`
	year=`date | cut -d ' ' -f 6`
	month="${month,,}" 
	for (( i=0; i<num_of_rows; i++ ))
	do
		username=${result_arr[$num_of_columns*$i]}
		ip=${result_arr[$num_of_columns*$i+1]}
		temp=`ssh -n $username@$ip -p22 "mv ~/$disk_folder_name/$client_id/current ~/$disk_folder_name/$client_id/$month$year"`
		temp=`ssh -n $username@$ip -p22 "rm -rf ~/$disk_folder_name/$client_id/$month$((year-1))"`		
	done
done


