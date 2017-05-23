#! /bin/bash

client_folder_name="BackupRestore"

touch ~/$client_folder_name/conf

flag=1 
while read line;
do
{
  if [ $flag -eq 1 ]
  then
  {
    echo $line > ~/$client_folder_name/conf
    flag=2
  }
  else
  {
  arr=($line)
  path=${arr[0]}
  space=`du -sb $path | cut -f1` 
  space=$((space/1024))
  echo $line $space >> ~/$client_folder_name/conf
  }
  fi
}
done <~/$client_folder_name/preconf


