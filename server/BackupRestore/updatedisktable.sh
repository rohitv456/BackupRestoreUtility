#! /bin/bash

row=$(mysql -se "SELECT * FROM BackupRestore.Disks");
arr=($row)
arr_len=${#arr[@]}
num_of_columns=4
num_of_rows=$((arr_len/num_of_columns))

for (( i=0; i<num_of_rows; i++ ))
do
	id=${arr[4*$i]}
	username=${arr[4*$i+1]}
	ip=${arr[4*$i+2]}
	available_space=`ssh -n $username@$ip "df ~ | tail -1 " | awk '{print $4}'`
	#echo $id $username $ip $available_space
	`mysql -se "UPDATE BackupRestore.Disks SET AVAILABLE_SPACE = $available_space WHERE DISKID = \"$id\" "`
done