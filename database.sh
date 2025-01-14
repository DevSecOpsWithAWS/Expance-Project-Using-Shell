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

dnf install mysql-server -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>>$LOG_FILE_NAME
VALIDATE $? "Enabling MySQL Server"

systemctl start mysqld &>>$LOG_FILE_NAME
VALIDATE $? "Starting MySQL Server"

mysql -h database.sridevsecops.store -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE_NAME

if [ $? -ne 0 ]
then
  echo "MySQL Root password not setup" &>>$LOG_FILE_NAME
  mysql_secure_installation --set-root-pass ExpenseApp@1
  VALIDATE $? "Setting Root Password"
else
  echo "MySQL Root Password already setup --> SKIPPING"
fi