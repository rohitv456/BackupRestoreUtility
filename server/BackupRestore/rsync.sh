ssh -n shravan@10.7.9.32 -p22 mkdir -p /home/shravan/BackupRestore/client1/current/home/shravan/TEST/ 
rsync -r /home/shravan/TEST/ shravan@10.7.9.32:~/BackupRestore/client1/current/home/shravan/TEST/
ssh -n shravan@10.7.8.38 -p22 mkdir -p /home/shravan/BackupRestore/client1/current/home/shravan/TEST/ 
rsync -r /home/shravan/TEST/ shravan@10.7.8.38:~/BackupRestore/client1/current/home/shravan/TEST/
ssh -n shravan@10.7.9.32 -p22 mkdir -p /home/shravan/BackupRestore/client1/current/home/shravan/Documents/ 
rsync -r /home/shravan/Documents/ shravan@10.7.9.32:~/BackupRestore/client1/current/home/shravan/Documents/
ssh -n shravan@10.7.9.32 -p22 mkdir -p /home/shravan/BackupRestore/client1/current/home/shravan/TEST2/ 
rsync -r /home/shravan/TEST2/ shravan@10.7.9.32:~/BackupRestore/client1/current/home/shravan/TEST2/
ssh -n shravan@10.7.9.32 -p22 mkdir -p /home2/shravan/BackupRestore/client1/current/home/shravan/TEST/ 
rsync -r /home2/shravan/TEST/ shravan@10.7.9.32:~/BackupRestore/client1/current/home/shravan/TEST/ --checksum
