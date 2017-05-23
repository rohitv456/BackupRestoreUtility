#! /bin/bash

server_username="shravan"
server_ip="10.8.18.122"
client_folder_name="BackupRestore"
server_folder_name="BackupRestore"
client_id="client1"


#invoking makeconf file to create conf file from preconf file
`bash makeconf.sh`

#sending conf file to global node
rsync -avz -e ssh ~/$client_folder_name/conf $server_username@$server_ip:~/$server_folder_name/$client_id/

#receiving rsync.sh from global node
while ! rsync -avz -e ssh $server_username@$server_ip:~/$server_folder_name/$client_id/rsync.sh ~/$client_folder_name/ 
do
	echo "waiting for rsync.sh" 		
done

rsync -avz -e ssh $server_username@$server_ip:~/$server_folder_name/$client_id/log ~/$client_folder_name/ 

ssh $server_username@$server_ip -p22 "rm -rf ~/$server_folder_name/$client_id/rsync.sh"

#Now client can run rsync.sh
`sh runrsync.sh`

