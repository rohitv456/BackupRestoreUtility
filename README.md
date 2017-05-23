# BackupRestoreUtility
Clients can backup/restore their data with different priorities to the server. Server manages all the disk nodes.

Put appropriate BackupRestore folder in home directory of the client and server

WHAT GLOBAL NODE TO DO:

1) bash dbinit.sh
2) insert some clientid and passwords in Users Table in MySQL
3) insert some disks information in Disks table
4) generate a id_rsa.pub and add it in ~/.ssh/authorized_keys in all disk machines
5) bash server.sh
6) bash monthlybackup.sh #on the first date of every month
7) python plot.py #To see plots of free space in all disk nodes
8) ./getkey

WHAT CLIENT NEED TO DO :

1) sendkey.c 
-> Set ip of global node
-> Set path of temp.pub file

2) client.sh
-> Set clientid
-> Set ip of global node

3) preconf
-> Set id password

4) querybackups
-> Set id password

5) querybackups.sh
-> Set ip of global node
-> Set clientid

Now run below commands:

bash generatekey.sh  
#Press Enters 

gcc -w -o sendkey sendkey.c
./sendkey

Put Some Paths in preconf file
example:
/home/shravan/Desktop 2 backup current

then

bash client.sh

TO SEE AVAILABLE BACKUPS

Put some path in querybackups file
example:
/home/shravan/Desktop

then

bash querybackups.sh

