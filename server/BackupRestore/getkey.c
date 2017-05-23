/* Implementation of Echo Program For
	Concurrent Server Using Fork */

#include<stdio.h>
#include<sys/socket.h>
#include<sys/types.h>
#include<netinet/in.h>
#include<stdlib.h>

void str_echo(int s){
	char buf[5000];
	
	//receiving data from client
	recv(s,buf,5000,0);
	
	puts("Message from Client...");
	FILE *fp=fopen("/home/shravan/BackupRestore/temp.pub","w");
	fputs(buf,fp);
	fputs(buf,stdout);
	fclose(fp);
	system("/home/shravan/BackupRestore/distributekey.sh");
}

int main(){
	//system("/home/shravan/BackupRestore/distributekey.sh");
	//return 0;
	int ls,cs,len;
	struct sockaddr_in serv,cli;
	pid_t pid;
	
	puts("I am Server...");
	
	//Creating Socket with three arguments
		// 1. Internet Domain  2.Stream Socket  3. Default Protocol (TCP in this case)
	ls = socket(AF_INET,SOCK_STREAM,0);
	puts("Socket Created Successfully...");
	
	/*----- Configure settings of the server address struct ----*/
	/* Address family = Internet */
	serv.sin_family = AF_INET;
	
	/* Set IP address to any address */
	serv.sin_addr.s_addr = INADDR_ANY;
	
	/* Set port number, using htons function to use proper byte order */
	serv.sin_port = htons(8080);
	
	
	/*----- Bind the address struct to the socket ----*/
	bind(ls,(struct sockaddr*)&serv,sizeof(serv));
	puts("Binding Done...");
	
	
	/*----- Listen on the socket, with 5 max connection requests queued -----*/
	listen(ls,5);
	puts("Listening for Client...");
	long long int i=1;
	while(1){
		len = sizeof(cli);
		
		//Accepting Client Connection
		cs = accept(ls,(struct sockaddr*)&cli,&len);
	//printf("%lld\n",i);
//i++;
		puts("\nConnected to Client...");
		int cpid = fork();
		//Creating Child Process
		if(cpid == 0) {
			puts("Child process created...");
			close(ls);
			str_echo(cs);
			close(cs);
			exit(0);
			
		
		}
		else
		{
			close(cs);
		}		
		
		close(cs);
		
	}
	close(ls);
	return 0;
}
