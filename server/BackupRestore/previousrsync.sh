ssh -n shravan@10.7.9.32 -p22 mkdir -p /home2/shravan/BackupRestore/client1/current/home/shravan/TEST/
rsync -r /home2/shravan/TEST/ shravan@10.7.9.32:~/BackupRestore/client1/current/home/shravan/TEST/ --checksum
