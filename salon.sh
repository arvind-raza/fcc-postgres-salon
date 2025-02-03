#!/bin/bash

# Salon Scheduler Script

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"
echo -e "Here are the services we offer:\n"

CUSTOMER_NAME=""
CUSTOMER_PHONE=""
SERVICES=$($PSQL "select service_id, name from services order by service_id")

ADD_APPOINTMENT(){
  SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
  CUST_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
  CUST_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
  SERVICE_NAME_NEW=$(echo $SERVICE_NAME | sed 's/\s//g' -E)
  CUSTOMER_NAME_NEW=$(echo $CUST_NAME | sed 's/\s//g' -E)
  echo -e "\nWhat time would you like your $SERVICE_NAME_NEW, $CUSTOMER_NAME_NEW?"
  read SERVICE_TIME
  INSERT_APPT=$($PSQL "insert into appointments (time, customer_id, service_id) values ('$SERVICE_TIME',$CUST_ID, $SERVICE_ID_SELECTED)")
  echo -e "\nI have put you down for a $SERVICE_NAME_NEW at $SERVICE_TIME, $CUSTOMER_NAME_NEW."
}

SCHEDULE_APPOINTMENT() {
  
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  PHONE_EXISTS=$($PSQL "select customer_id, name from customers where phone='$CUSTOMER_PHONE'")
  if [[ -z $PHONE_EXISTS ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    CUSTOMER_INSERT=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    ADD_APPOINTMENT
  else
    ADD_APPOINTMENT
  fi
}

LIST_SERVICES() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    LIST_SERVICES "I could not find that service. What would you like today?"
  else
    SERVICE_EXISTS=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")
    
    if [[ -z $SERVICE_EXISTS ]]
    then
      LIST_SERVICES "I could not find that service. What would you like today?"
    else
      SCHEDULE_APPOINTMENT
    fi
  fi
}

LIST_SERVICES
