#!/bin/bash

WDIR=/usr/local/thisweek
MEMO=$WDIR/memo

function pause(){
local message="$@"
[ -z $message ] && message="Press Enter to continue"
read -p "$message" readEnterKey
}

function show_menu(){
echo " |-------------------------------------------|"
echo " |::. Weekly Plan ::.                        |"
echo " |-------------------------------------------|"
echo " | 1- Add a Plan    | 11-Show Monday    Plan |"
echo " | 2- Delete a Plan | 12-Show Tuesday   Plan |"
echo " | 3- Show Plan     | 13-Show Wednesday Plan |"
echo " |                  | 14-Show Thursday  Plan |"
echo " |                  | 15-Show Friday    Plan |"
echo " |                  | 16-Show Weekend   Plan |"
echo " |                  | ---------------------- |"
echo " |                  | 17-Show This Week      |"
echo " |-------------------------------------------|"
echo " | 99-exit                                   |"
echo " |-------------------------------------------|"
echo " |::.  Show Memo     ::.                     |"
echo " |-------------------------------------------|"
}

function add_plan(){
    CHOICE=$(whiptail --title "Select the day you want to add a plan" --radiolist "Choose:" 15 40 6 \
        "Monday" "" "Monday" \
        "Tuesday" "" "Tuesday" \
        "Wednesday" "" "Wednesday" \
        "Thursday" "" "Thursday" \
        "Friday" "" "Friday" \
        "Weekend" "" "Weekend" \
        "Next Week" "" "Next Week" 3>&1 1>&2 2>&3)
            case $CHOICE in
                "Monday")
                    WDAY="Monday"
                    PLANMSG=$(whiptail --title "Plan Message" --inputbox "Please Enter Message for Plan" 10 60  3>&1 1>&2 2>&3)
                    echo "$WDAY: $PLANMSG" >> $MEMO/memo
                    echo "$PLANMSG added in $WDAY"
                    ;;
                "Tuesday")
                    WDAY="Tuesday"
                    PLANMSG=$(whiptail --title "Plan Message" --inputbox "Please Enter Message for Plan" 10 60  3>&1 1>&2 2>&3)
                    echo "$WDAY: $PLANMSG" >> $MEMO/memo
                    echo "$PLANMSG added in $WDAY"
                    ;;
                "Wednesday")
                    WDAY="Wednesday"
                    PLANMSG=$(whiptail --title "Plan Message" --inputbox "Please Enter Message for Plan" 10 60  3>&1 1>&2 2>&3)
                    echo "$WDAY: $PLANMSG" >> $MEMO/memo
                    echo "$PLANMSG added in $WDAY"
                    ;;
                "Thursday")
                    WDAY="Thursday"
                    PLANMSG=$(whiptail --title "Plan Message" --inputbox "Please Enter Message for Plan" 10 60  3>&1 1>&2 2>&3)
                    echo "$WDAY: $PLANMSG" >> $MEMO/memo
                    echo "$PLANMSG added in $WDAY"
                    ;;
                "Friday")
                    WDAY="Friday"
                    PLANMSG=$(whiptail --title "Plan Message" --inputbox "Please Enter Message for Plan" 10 60  3>&1 1>&2 2>&3)
                    echo "4WDAY: $PLANMSG" >> $MEMO/memo
                    echo "$PLANMSG added in $WDAY"
                    ;;
                "Weekend")
                    WDAY="Weekend"PLANMSG=$(whiptail --title "Plan Message" --inputbox "Please Enter Message for Plan" 10 60  3>&1 1>&2 2>&3)
                    echo "$WDAY: $PLANMSG" >> $MEMO/memo
                    echo "$PLANMSG added in $WDAY"
                    ;;
                "Next Week")
                    WDAY="Next Week"
                    PLANMSG=$(whiptail --title "Plan Message" --inputbox "Please Enter Message for Plan" 10 60  3>&1 1>&2 2>&3)
                    echo "$WDAY: $PLANMSG" >> $MEMO/memo
                    echo "$PLANMSG added in $WDAY"
                    ;;
                *)
                    ;;
            esac
pause
}

function show_plan(){
    CHOICE=$(whiptail --title "Select the day you want to add a plan" --radiolist "Choose:" 15 40 6 \
        "Monday" "" "Monday" \
        "Tuesday" "" "Tuesday" \
        "Wednesday" "" "Wednesday" \
        "Thursday" "" "Thursday" \
        "Friday" "" "Friday" \
        "Weekend" "" "Weekend" \
        "Next Week" "" "Next Week" 3>&1 1>&2 2>&3)
            case $CHOICE in
                "Monday")
                    WDAY="Monday"
                    tput setaf 9
                    echo ""
                    echo "-----------"
                    echo "$WDAY Plans"
                    echo "-----------"
                    echo ""
                    tput setaf 3
                    cat /home/erkan/thisweek/memo |grep "$WDAY" | cut -d "|" -f2
                    echo ""
                    tput sgr0
                    ;;
                "Tuesday")
                    WDAY="Tuesday"
                    tput setaf 9
                    echo "-----------"
                    echo "$WDAY Plans"
                    echo "-----------"
                    echo ""
                    tput setaf 7
                    cat /home/erkan/thisweek/memo |grep "$WDAY" | cut -d "|" -f2
                    echo ""
                    tput sgr0
                    ;;
                "Wednesday")
                    WDAY="Wednesday"
                    echo "$WDAY Plans" && cat /home/erkan/thisweek/memo |grep "$WDAY" | cut -d "|" -f2
                    ;;
                "Thursday")
                    WDAY="Thursday"
                    echo "$WDAY Plans" && cat /home/erkan/thisweek/memo |grep "$WDAY" | cut -d "|" -f2
                    ;;
                "Friday")
                    WDAY="Friday"
                    echo "$WDAY Plans" && cat /home/erkan/thisweek/memo |grep "$WDAY" | cut -d "|" -f2
                    ;;
                "Weekend")
                    WDAY="Weekend"
                    echo "$WDAY Plans" && cat /home/erkan/thisweek/memo |grep "$WDAY" | cut -d "|" -f2
                    ;;
                "Next Week")
                    WDAY="Next Week"
                    echo "$WDAY Plans" && cat /home/erkan/thisweek/memo |grep "$WDAY" | cut -d "|" -f2
                    ;;
                *)
                    ;;
            esac
pause
}

function read_input(){
local c
read -p "You can choose from the menu numbers " c
case $c in
#0)about_of ;;
3)show_plan;;
#-----------------------------
99)exit 0 ;;
*)
echo "Please select from the menu numbers"
pause
esac
}

# CTRL+C, CTRL+Z
trap '' SIGINT SIGQUIT SIGTSTP

while true
do
clear
show_menu
read_input
done
