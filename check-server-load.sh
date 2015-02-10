#!/usr/bin/env bash

#
# Date: 5 December, 2014
# Author: Aman Hanjrah and Peeyush Budhia
# URI: http://techlinux.net and http://phpnmysql.com
# License: GNU GPL v2.0
# Description: The script is used to check the load on the server, if the load is greater than 3.00 then the script will send an email on the specified email address.
#

init() {
    EMAIL="peeyush.budhia@gmail.com"
}

chkMutt() {
CHECK_MUTT=$(rpm -qa | grep mutt)
    if [[ -z "$CHECK_MUTT" ]]; then
    INSTALL_MUTT=$(yum install mutt -y 2> /tmp/muttlog.log)
        if [[ -n $(cat /tmp/muttlog.log) ]]; then
            echo "Mutt not installed, exiting!"
            sleep 1
        else
	    return 0	
        fi
    fi
}


chkCurrentLoad() {
TEMP_FILE=$(mktemp)
sar -u 1 5 | grep -i average | tr -s ' ' | cut -d' ' -f5 > $TEMP_FILE
	if [[ $(cat "$TEMP_FILE") > 3.00 ]]; then
        chkLastEmail
    else
        return 0
    fi
}

chkLastEmail() {
    CHK_DIFF=$(expr $(date "+%s") - $(cat muttlog.log))
	if [[ "$CHK_DIFF" -gt 600 ]]; then
		sendEmail
	else
		return 0
	fi
}

chkMuttLog() {
	if [[ -z muttlog.log ]]; then
		echo $(date "+%s") > muttlog.log
	else
		return 0
	fi
}


sendEmail() {
	{ date "+%s"; echo "Server is under load greater than 3, current load is: $(sar -u 1 1 | grep -i average | tr -s ' ' | cut -d' ' -f5)" | mutt -s "[Critical!] Server Under High Load" -- $EMAIL; } > muttlog.log
}


 main() {
    init
    chkMutt
    chkMuttLog
    chkCurrentLoad
 }

main
