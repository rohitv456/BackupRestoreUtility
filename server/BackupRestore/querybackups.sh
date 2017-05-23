#! /bin/bash

server_username="shravan"
server_ip="10.8.18.122"
client_folder_name="BackupRestore"
server_folder_name="BackupRestore"
client_id="client1"

#sending querybackups file to global node
rsync -avz -e ssh ~/$client_folder_name/querybackups $server_username@$server_ip:~/$server_folder_name/$client_id/

#waiting for answerbackups
while ! rsync -avz -e ssh $server_username@$server_ip:~/$server_folder_name/$client_id/answerbackups ~/$client_folder_name/ 
do
	echo "waiting for answerbackups" 		
done
#answerbackups received

#delete answerbackups
ssh $server_username@$server_ip -p22 "rm -rf ~/$server_folder_name/$client_id/answerbackups"  
