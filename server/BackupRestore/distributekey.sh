#! /bin/bash

server_folder_name="BackupRestore"
disk_folder_name="BackupRestore"


#MySQL Query to get all the available disks
result=`mysql -se "SELECT * FROM BackupRestore.Disks "`

result_arr=($result)
result_arr_len=${#result_arr[@]}
num_of_columns=4
num_of_rows=$((result_arr_len/num_of_columns))

#Add Client Public rsa key to authorized keys 
cat ~/$server_folder_name/temp.pub >> ~/.ssh/authorized_keys

for (( i=0; i<num_of_rows; i++ ))
do
	diskid=${result_arr[$num_of_columns*$i]}
	username=${result_arr[$num_of_columns*$i+1]}
	ip=${result_arr[$num_of_columns*$i+2]}
	space=${result_arr[$num_of_columns*$i+3]}
	echo $username $ip

	#sends public rsa key to all the available disks
	`rsync -r ~/$server_folder_name/temp.pub $username@$ip:~/$disk_folder_name`

	#Add Client Public rsa key to authorized keys on the disk machine 
	`ssh -n $username@$ip -p22 "cat ~/$disk_folder_name/temp.pub >> ~/.ssh/authorized_keys"`
done
