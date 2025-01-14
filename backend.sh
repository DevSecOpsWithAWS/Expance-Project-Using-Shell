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



mkdir -p /app &>>$LOG_FILE_NAME
VALIDATE $? "app directory is created" 

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Downloaded the backend project file"

cd /app &>>$LOG_FILE_NAME
VALIDATE $? "User is moved to app directory"

rm -rf /app/* &>>$LOG_FILE_NAME
VALIDATE $? "app directory is Removed"


unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? "Unziped the backend code"

npm install &>>$LOG_FILE_NAME
VALIDATE $? "Installing npm"

#vim /etc/systemd/system/backend.service
#C:\Users\choud\DevSecOps\Expance-Project-Using-Shell
cp /home/ec2-user/Expance-Project-Using-Shell/backend.service /etc/systemd/system/backend.service &>>$LOG_FILE_NAME
VALIDATE $? "Coping backend.service file is"

dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "MySQL Installing"

mysql -h database.sridevsecops.store -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? "Loading Schema"

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "daemon-reloading"

systemctl start backend &>>$LOG_FILE_NAME
VALIDATE $? "backend starting"

systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE $? "backend enabling"

systemctl restart backend &>>$LOG_FILE_NAME
VALIDATE $? "Restarting backend"