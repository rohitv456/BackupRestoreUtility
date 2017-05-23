#! /bin/bash

server_folder_name="BackupRestore"
disk_folder_name="BackupRestore"

while [ 1 ]
do
	alldir=`ls -d client*/`
	arr=($alldir)
	for index in "${!arr[@]}"; 
	do 
		client_path=${arr[$index]}
		client_id=`echo $client_path | cut -d '/' -f 1`

		if [ "`ls ~/$server_folder_name/${arr[$index]} | grep querybackups`" == "querybackups" ]
		then
			#Initializing answerbackups file
			echo `date` > ~/$server_folder_name/${arr[$index]}.answerbackups
			echo "" >> ~/$server_folder_name/${arr[$index]}.answerbackups

			flag=1
			while read line;
			do
			{	
				path=$line
				#IF PATH DOESN'T END WITH '/' THEN ADD '/'
				if [ "$(echo $path | rev | cut -c 1)" != "/" ]
				then
					path=$path/
				fi

				if [ $flag -eq 1 ]
				then
				{
					client_account_id=`echo $line | cut -d ' ' -f 1`
					client_account_password=`echo $line | cut -d ' ' -f 2`
					count=`mysql -se "SELECT COUNT(*) FROM BackupRestore.Users WHERE CLIENTID=\"$client_id\" and PASSWORD=AES_ENCRYPT(\"$client_account_password\",\"$client_account_password\") "`
					if [ "$client_account_id" != "$client_id" ] || [ "$count" == "0" ]
					then
						echo "echo ID OR PASSWORD IS INCORRECT " >> ~/$server_folder_name/$client_id/.answerbackups
						break
					fi	
				 	flag=2
				}
				else
				{
					count=`mysql -se "SELECT COUNT(*) FROM BackupRestore.Storage WHERE CLIENTID=\"$client_id\" and PATH=\"$path\" "`
					if [ $count -eq 0 ]
					then
						#IF PATH IS NOT PRESENT IN DATABASE
						echo "$path is not present in database" >> ~/$server_folder_name/$client_id/.answerbackups
					else
						#IF PATH IS ALREADY PRESENT IN DATABASE	
						result=`mysql -se "select USERNAME,IP from BackupRestore.Storage, BackupRestore.Disks where Storage.DISKID = Disks.DISKID and CLIENTID=\"$client_id\" and PATH=\"$path\" ORDER BY AVAILABLE_SPACE LIMIT 1"`
						result_arr=($result)
						username=${result_arr[0]}
						ip=${result_arr[1]}
						answer=`ssh -n $username@$ip -p22 "find ~/BackupRestore/$client_id/*$path | cut -d '/' -f 6 | sort -u" `
						echo $path : $answer >> ~/$server_folder_name/$client_id/.answerbackups					
					fi
				}
				fi
			}
			done <~/$server_folder_name/${arr[$index]}/querybackups
			
			rm ~/$server_folder_name/${arr[$index]}querybackups

			#client is waiting for answerbackups
			mv ~/$server_folder_name/${arr[$index]}.answerbackups ~/$server_folder_name/${arr[$index]}answerbackups
		fi

		#DAILY BACKUP (LEVEL 1 BACKUP)

		#echo "reading ~/$server_folder_name/${arr[$index]}"
		if [ "`ls ~/$server_folder_name/${arr[$index]} | grep conf`" == "conf" ]
		then
			
			#Initializing .rsync.sh file
			> ~/$server_folder_name/${arr[$index]}.rsync.sh
			> ~/$server_folder_name/${arr[$index]}log

			flag=1
			while read line;
			do
			{
				if [ $flag -eq 1 ]
				then
				{
					client_account_id=`echo $line | cut -d ' ' -f 1`
					client_account_password=`echo $line | cut -d ' ' -f 2`
					count=`mysql -se "SELECT COUNT(*) FROM BackupRestore.Users WHERE CLIENTID=\"$client_id\" and PASSWORD=AES_ENCRYPT(\"$client_account_password\",\"$client_account_password\") "`
					if [ "$client_account_id" != "$client_id" ] || [ "$count" == "0" ]
					then
						echo "ID OR PASSWORD IS INCORRECT" >> ~/$server_folder_name/$client_id/log
						break
					fi	
				 	flag=2
				}
				else
				{
					arr2=($line)
					path=${arr2[0]}
					priority=${arr2[1]}
					backupOrRestore=${arr2[2]}
					restore_folder=${arr2[3]}
					required_space=${arr2[4]}
					
					#IF PATH DOESN'T END WITH '/' THEN ADD '/'
					if [ "$(echo $path | rev | cut -c 1)" != "/" ]
					then
						path=$path/
					fi

					#converting  to lower case
					backupOrRestore="${backupOrRestore,,}" 
					restore_folder="${restore_folder,,}" 

					if [ "$backupOrRestore" == "backup" ]
					then
						#IF CLIENT WANT TO BACKUP
						count=`mysql -se "SELECT COUNT(*) FROM BackupRestore.Storage WHERE CLIENTID=\"$client_id\" and PATH=\"$path\" "`
						if [ $count -eq 0 ]
						then
							#IF PATH IS NOT PRESENT IN DATABASE

							#UPDATE AVAILABLE SPACE OF DISKS
							`bash updatedisktable.sh`	
							result=`mysql -se "SELECT * FROM BackupRestore.Disks ORDER BY AVAILABLE_SPACE DESC LIMIT $priority "`
							result_arr=($result)
							result_arr_len=${#result_arr[@]}
							num_of_columns=4
							num_of_rows=$((result_arr_len/num_of_columns))
							if [ ${result_arr[$result_arr_len-1]} -lt $required_space ]
							then
								echo "Not enough space for $path. You may reduce the priority of $path " >> ~/$server_folder_name/$client_id/log
								for (( i=0; i<num_of_rows; i++ ))
								do
									diskid=${result_arr[$num_of_columns*$i]}
									username=${result_arr[$num_of_columns*$i+1]}
									ip=${result_arr[$num_of_columns*$i+2]}
									space=${result_arr[$num_of_columns*$i+3]}
									if [ $space -lt $required_space ]
									then
										echo "`date` => Not Enough Space in $diskid $username $ip. Required_space = $required_space" >> ~/$server_folder_name/log 
									fi
								done
							else
								for (( i=0; i<num_of_rows; i++ ))
								do
									diskid=${result_arr[$num_of_columns*$i]}
									username=${result_arr[$num_of_columns*$i+1]}
									ip=${result_arr[$num_of_columns*$i+2]}
									space=${result_arr[$num_of_columns*$i+3]}
									echo "ssh -n $username@$ip -p22 "mkdir -p ~/$disk_folder_name/$client_id/current$path" " >> ~/$server_folder_name/$client_id/.rsync.sh
									echo "rsync -c -r $path $username@$ip:~/$disk_folder_name/$client_id/current$path" >> ~/$server_folder_name/$client_id/.rsync.sh
									`mysql -se "INSERT INTO BackupRestore.Storage VALUES(\"$client_id\",\"$path\",\"$diskid\")"`
								done
							fi
						else
							#IF PATH IS ALREADY PRESENT IN DATABASE	
							result=`mysql -se "select Disks.DISKID,USERNAME,IP,AVAILABLE_SPACE from BackupRestore.Storage, BackupRestore.Disks where Storage.DISKID = Disks.DISKID and CLIENTID=\"$client_id\" and PATH=\"$path\" ORDER BY AVAILABLE_SPACE DESC"`
							result_arr=($result)
							result_arr_len=${#result_arr[@]}
							num_of_columns=4
							num_of_rows=$((result_arr_len/num_of_columns))
							if [ ${result_arr[$result_arr_len-1]} -lt $required_space ]
							then
								echo "Not enough space for $path " >> ~/$server_folder_name/$client_id/log
								for (( i=0; i<num_of_rows; i++ ))
								do
									diskid=${result_arr[$num_of_columns*$i]}
									username=${result_arr[$num_of_columns*$i+1]}
									ip=${result_arr[$num_of_columns*$i+2]}
									space=${result_arr[$num_of_columns*$i+3]}
									if [ $space -lt $required_space ]
									then
										echo "`date` => Not Enough Space in $diskid $username $ip. Required_space = $required_space" >> ~/$server_folder_name/log
									fi
								done
							else
								for (( i=0; i<num_of_rows; i++ ))
								do
									diskid=${result_arr[$num_of_columns*$i]}
									username=${result_arr[$num_of_columns*$i+1]}
									ip=${result_arr[$num_of_columns*$i+2]}
									space=${result_arr[$num_of_columns*$i+3]}
									echo "ssh -n $username@$ip -p22 "mkdir -p ~/$disk_folder_name/$client_id/current$path" " >> ~/$server_folder_name/$client_id/.rsync.sh
									echo "rsync -c -r $path $username@$ip:~/$disk_folder_name/$client_id/current$path" >> ~/$server_folder_name/$client_id/.rsync.sh
								done
							fi
						fi
					elif [ "$backupOrRestore" == "restore" ]
					then
						count=`mysql -se "SELECT COUNT(*) FROM BackupRestore.Storage WHERE CLIENTID=\"$client_id\" and PATH=\"$path\" "`
						if [ $count -eq 0 ]
						then
							#IF PATH IS NOT PRESENT IN DATABASE
							echo "$path is not present in database " >> ~/$server_folder_name/$client_id/log
						else
							#IF PATH IS ALREADY PRESENT IN DATABASE	
							result=`mysql -se "select USERNAME,IP,AVAILABLE_SPACE from BackupRestore.Storage, BackupRestore.Disks where Storage.DISKID = Disks.DISKID and CLIENTID=\"$client_id\" and PATH=\"$path\" ORDER BY AVAILABLE_SPACE"`
							result_arr=($result)
							username=${result_arr[0]}
							ip=${result_arr[1]}
							if [ "$restore_folder" == "current" ]
							then
								present=`ssh -n $username@$ip -p22 "if [ -d "/home/$username/$disk_folder_name/$client_id/$restore_folder$path" ]; then echo "1"; else echo "0"; fi"`
								if [ $present -eq "1" ]
								then
									echo "mkdir -p $path" >> ~/$server_folder_name/$client_id/.rsync.sh
									echo "rsync -c -r $username@$ip:~/$disk_folder_name/$client_id/$restore_folder$path $path" >> ~/$server_folder_name/$client_id/.rsync.sh
								else
									month=`date | cut -d ' ' -f 2`
									year=`date | cut -d ' ' -f 6`
									month="${month,,}" 
									present=`ssh -n $username@$ip -p22 "if [ -d "/home/$username/$disk_folder_name/$client_id/$month$year$path" ]; then echo "1"; else echo "0"; fi"`
									if [ $present -eq "1" ]
									then
										echo "$restore_folder$path is not present in database. Try $month$year instead of current " >> ~/$server_folder_name/$client_id/log
									else
										echo "$restore_folder$path is not present in database " >> ~/$server_folder_name/$client_id/log
									fi
								fi
							else
								present=`ssh -n $username@$ip -p22 "if [ -d "/home/$username/$disk_folder_name/$client_id/$restore_folder$path" ]; then echo "1"; else echo "0"; fi"`
								if [ $present -eq "1" ]
								then
									echo "mkdir -p $path" >> ~/$server_folder_name/$client_id/.rsync.sh
									echo "rsync -c -r $username@$ip:~/$disk_folder_name/$client_id/$restore_folder$path $path" >> ~/$server_folder_name/$client_id/.rsync.sh
								else
									echo "$restore_folder$path is not present in database " >> ~/$server_folder_name/$client_id/log
								fi
							fi
						fi
					fi				
				}
				fi
			}
			done <~/$server_folder_name/${arr[$index]}/conf

			rm ~/$server_folder_name/${arr[$index]}conf

			#client is waiting for .rsync.sh
			mv ~/$server_folder_name/${arr[$index]}.rsync.sh ~/$server_folder_name/${arr[$index]}rsync.sh
		fi

	done
done


