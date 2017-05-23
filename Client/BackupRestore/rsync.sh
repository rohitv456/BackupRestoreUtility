ssh -n shravan@192.168.43.127 -p22 mkdir -p /home/shravan/BackupRestore/client2/current/home/umang/Documents/ 
rsync -c -r /home/umang/Documents/ shravan@192.168.43.127:~/BackupRestore/client2/current/home/umang/Documents/
ssh -n shravan@192.168.43.83 -p22 mkdir -p /home/shravan/BackupRestore/client2/current/home/umang/Documents/ 
rsync -c -r /home/umang/Documents/ shravan@192.168.43.83:~/BackupRestore/client2/current/home/umang/Documents/
ssh -n shravan@192.168.43.127 -p22 mkdir -p /home/shravan/BackupRestore/client2/current/home/umang/Documents/
rsync -c -r /home/umang/Documents/ shravan@192.168.43.127:~/BackupRestore/client2/current/home/umang/Documents/
