#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU() {
    if [[ $1 ]]
    then echo -e "\n$1"
    fi

SERVICES_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
echo "$SERVICES_LIST" | while read SERVICE_ID BAR SERVICE_NAME
do
echo -e "$SERVICE_ID) $SERVICE_NAME"
done

read SERVICE_ID_SELECTED
SELECTED_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" | sed 's/ //g')

case $SERVICE_ID_SELECTED in
    [1-4]) NEXT ;;
        *) MAIN_MENU "I could not find that service. What would you like today?" ;;
esac
}


NEXT() {
    #get phone
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    
    CUSTOMER_PHONE_CHECK=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE';")

    #if doesn't exist
        if [[ -z $CUSTOMER_PHONE_CHECK ]]
        then #register customer
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        fi

    #create customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
        CUSTOMER_NAME_FORMATTED=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';" | sed 's/ //g')

    #make appointment
    echo -e "\nWhat time would you like your $SELECTED_SERVICE_NAME, $CUSTOMER_NAME_FORMATTED?"
    read SERVICE_TIME
    #register appointment
    INSERT_SERVICE_TIME_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME');")
    echo -e "\nI have put you down for a $SELECTED_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED." 
}
 



MAIN_MENU
