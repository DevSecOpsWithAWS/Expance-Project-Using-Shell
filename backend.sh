#!/bin/bash

LOG_FOLDER_NAME="/var/log/expance-logs"
LOG_FILE=$(echo $0 | cut -d '.' -f1)
TIMESTAMP=$(date +%Y-%m-%d:%H:%M:%S)
LOG_FILE_NAME="$LOG_FOLDER_NAME/$LOG_FILE/$TIMESTAMP"
USERID=$(id -u)
mkdir -p $LOG_FOLDER_NAME
echo "Scripting is executing at --> : $TIMESTAMP" &>>$LOG_FILE_NAME
echo "$USERID"
if [ $USERID -ne 0 ]
then
  echo "You don't have access to execute this script"
  exit 1
fi

VALIDATE(){
  if [ $1 -ne 0 ]
  then
    echo "$2 --> FAILURE" 
    exit 1
  else
    echo "$2 --> SUCCESS" 
  fi
}

dnf module disable nodejs -y
VALIDATE $? "Disabling NodeJS"

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling NodeJS"

dnf install nodejs -y
VALIDATE $? "Installing NodeJS"

useradd expense
VALIDATE $? "Adding a User"