client_folder_name="BackupRestore"
client_id="temp" 

#Checking whether temp.pub is already generated
if [ "`ls ~/$client_folder_name/ | grep $client_id.pub`" != "$client_id.pub" ]
then
	#echo "not present"
	ssh-keygen -t rsa   
	sudo chmod 600 ~/.ssh/id_rsa
	sudo chmod 600 ~/.ssh/id_rsa.pub
	sudo chmod 644 ~/.ssh/known_hosts
	sudo chmod 755 ~/.ssh
	#Press Enters 
	#eval `ssh-agent -s`

	#adds private key identities to the authentication agent
	ssh-add ~/.ssh/id_rsa
	
	cp ~/.ssh/id_rsa.pub ~/$client_folder_name/temp.pub 
fi

#gcc -w -o sendkey sendkey.c
#./sendkey

