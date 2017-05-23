import matplotlib.pyplot as plt
import datetime
import MySQLdb
import subprocess

plt.axis([0, 1000, 0, 1000000])
plt.ion()

time = datetime.datetime.time(datetime.datetime.now())
arr = str(time).split(':',2);
start = int(arr[0])*3600 + int(arr[1])*60 + float(arr[2]) 

while True:
		#Update Disk Table
		subprocess.call("bash ~/BackupRestore/updatedisktable.sh", shell=True)

		#PLOT THE NEW POINT
		db = MySQLdb.connect("localhost","root","8584","BackupRestore" )
		cursor = db.cursor()

		time = datetime.datetime.time(datetime.datetime.now())
		arr = str(time).split(':',2);
		curr = int(arr[0])*3600 + int(arr[1])*60 + float(arr[2])

		cursor.execute("SELECT COUNT(*) FROM Disks")
		data = cursor.fetchone()
		num_of_row=int(data[0])

		cursor.execute("SELECT * FROM Disks")

		for i in range(0,num_of_row):
			data = cursor.fetchone()
			#print data[3]
			plt.scatter(curr-start,int(data[3])%1000000)

		plt.pause(1.0000000000001)
		db.close()