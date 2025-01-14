#!/bin/bash
#!/bin/bash

LOG_FOLDER_NAME="/var/log/expense-logs"
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

dnf install nginx -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing Nginx "

systemctl enable nginx &>>$LOG_FILE_NAME
VALIDATE $? "Enabling nginx "

systemctl start nginx &>>$LOG_FILE_NAME
VALIDATE $? "Starting Nginx "

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE_NAME
VALIDATE $? "Removing all the files related to  Nginx "

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Downloading the front-end project "

cd /usr/share/nginx/html &>>$LOG_FILE_NAME
VALIDATE $? "User navigating to nginx/html directory"

unzip /tmp/frontend.zip &>>$LOG_FILE_NAME
VALIDATE $? "Unzipping frontend project in tmp folder"

cp /home/ec2-user/Expance-Project-Using-Shell/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "Coping expense.conf file"

systemctl restart nginx
VALIDATE $? "Restarting Nginx "