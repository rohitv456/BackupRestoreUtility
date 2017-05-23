client_folder_name="BackupRestore"
client_id="client1"

if [ "`ls ~/$client_folder_name/ | grep $client_id.pub`" != "$client_id.pub" ]
then
	echo "not present"
	ssh-keygen -t rsa   
	#Press Enters 
	#eval `ssh-agent -s`
	ssh-add ~/.ssh/id_rsa
	cp ~/.ssh/id_rsa.pub ~/$client_folder_name/$client_id.pub 
fi

