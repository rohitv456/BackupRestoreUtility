#include<stdio.h>
#include<sys/socket.h>
#include<sys/types.h>
#include<netinet/in.h>

void str_echo(int s){

	char buff[5000],buff1[5000];
	puts("Enter the Message...");
	FILE *fp = fopen("/home/sumant/BackupRestore/temp.pub","r");
	fgets(buff,5000,fp);
	//Sending data to server
	send(s,buff,5000,0);
	
}

int main(){
	int ls;
	struct sockaddr_in cli;
	puts("I am Client");
	
	//Creating Socket
	ls = socket(AF_INET,SOCK_STREAM,0);
	puts("Socket Created Successfully...");
	
	//Socket Address Structure
	cli.sin_family = AF_INET;
	cli.sin_addr.s_addr = inet_addr("10.8.18.122");
	cli.sin_port = htons(8080);
	
	//Connecting to Server
	connect(ls , (struct sockaddr*)&cli,sizeof(cli));
	puts("Connected with Server...");
	
	str_echo(ls);
	
	close(ls);
	return 0;
}	
