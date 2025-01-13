#!/bin/bash

LOG_FOLDER_NAME="/var/log/expance-logs"
LOG_FILE=$(echo $0 | cut -d '.' -f1)
TIMESTAMP=$(date +%Y-%m-%d:%H:%M:%S)
LOG_FILE_NAME="$LOG_FOLDER_NAME/$LOG_FILE-$TIMESTAMP"
USERID=$(id -u)

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

dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Disabling NodeJS"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "Enabling NodeJS"

dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing NodeJS"

id expense &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
then
  useradd expense &>>$LOG_FILE_NAME
  VALIDATE $? "Adding a User"
else
  echo "User is already Created --> SKIPPING"
fi

mkdir /app
VALIDATE $? "app directory is created"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "Downloaded the backend project file"

cd /app
VALIDATE $? "User is moved to app directory"

unzip /tmp/backend.zip
VALIDATE $? "Unziped the backend code"
