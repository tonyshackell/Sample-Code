#!/usr/bin/env bash

# This is a script to automate the user device registration process on the AIMS Ghana network.
# It works by editing the bind files on the bind server and the dhcpd.conf file on the dhcp server.
#
# Author: Anthony Shackell - June 1, 2016

usage() {
    echo """
This is a script to automate the user registration process on the AIMS Ghana network.

It works by editing the bind files on the bind server and the dhcpd.conf file on the dhcp server.
Usage:
./register.sh ARGS

required arguments:
    -a : user to add to the files (e.g. ashackell-wireless)
    -g : the group (subnet) to create the user under. Run this script with -o flag for possible options
    -m : mac address assigned to the hardware you are registering
    -u : sudo user for the servers you wish edit the files on. Works best if you have your SSH key installed!

optional arguments:
    -h : display usage of the script, plus all possible subnet options
    -o : run the script with only this option to see the possible subnet options

example usage:
./register.sh -a ashackell-lan -g it_net -m 40:6c:8f:2a:52:5f -u anthony
    """
}

show_options() {
	echo """
The following are options for the subnet to register the device under. Please specify the group properly (exactly as it is
defined here) to avoid causing errors.

Possible options:
srv_net             - Servers and Devices (internal IT)
it_net              - IT subnet
students_net        - AIMS Laptops in Lab
studentswl_net      - AIMS Laptops in Lab (wireless cards)
studentspriv_net    - Student Personal Devices
studentsfriends_net - Student Visitors
tutors_net          - AIMS Laptops for Tutors
tutorspriv_net      - Tutors' Personal Devices
lecturers_net       - AIMS Laptops assigned to Lecturers
lecturerspriv_net   - Lecturers' Personal Devices
staff_net           - AIMS Laptops assigned to staff
staffpriv_net       - Staff Personal Devices
visitors_net        - AIMS Laptops assigned to visitors
visitorspriv_net    - Visitors' Personal Devices
contractors_net     - AIMS Laptops assigned to contractors
contractorspriv_net - Contractors Personal Devices
workshops_net       - AIMS Laptops assigned to Workshop Participants
workshopspriv_net   - Workshop Participants' Personal Devices
testlab_net         - Test Lab Devices
	"""
}

update_serial() {
	NEWSERIAL=$(ssh -t $1@$2 "grep Serial $3 | egrep -o '[0-9]+'" | tr -d '\r')
	((NEWSERIAL++))
	echo "New $4 serial: $NEWSERIAL"
	ssh -t $1@$2 "sed -r -i \"s/[0-9]+\s+; Serial/$NEWSERIAL\	\	; Serial/\" $3" &> /dev/null
}

add_reverse_entry() {
	ssh -t $1@$2 "egrep \"; SCRIPT MARKUP $4\" $3" &> /dev/null
	if [ $? != "0" ]; then
		echo "Could not find subnet in reverse DNS file. Entry not added."
		return 1
	fi
	PREVLINE=$(ssh -t $1@$2 "sed -n '/; SCRIPT MARKUP $4/{x;p;d;}; x' $3")  &> /dev/null
	NETNUMS=$(echo $PREVLINE | egrep -o '[0-9]+\.[0-9]+' | tr -d '\r')	
	SPECIFICID=$(echo ${NETNUMS/./ } | cut -d " " -f1)
	((SPECIFICID++))
	SUPERNET=$(echo ${NETNUMS/./ } | cut -d " " -f2)
	NEWENTRY="$SPECIFICID.$SUPERNET\t\tIN\tPTR\t$5.aims.edu.gh."
	ssh -t $1@$2 "sed -i \"/; SCRIPT MARKUP $4/i $NEWENTRY\" $3" #&> /dev/null
}

add_forward_entry() {
	ssh -t $1@$2 "egrep \"; SCRIPT MARKUP $4\" $3" &> /dev/null
	if [ $? != "0" ]; then
		echo "Could not find subnet in forward DNS file. Entry not added."
		return 1
	fi
	PREVLINE=$(ssh -t $1@$2 "sed -n '/; SCRIPT MARKUP $4/{x;p;d;}; x' $3") &> /dev/null
	NETNUMS=$(echo $PREVLINE | egrep -o '10.3.[0-9]+\.[0-9]+' | tr -d '\r')
	SPECIFICID=$(echo $NETNUMS | cut -d "." -f4)
	((SPECIFICID++))
	SUPERNET=$(echo $NETNUMS | cut -d "." -f3)
	NEWENTRY="$5\tIN\t\tA\t\t10.3.$SUPERNET.$SPECIFICID"
	ssh -t $1@$2 "sed -i '/; SCRIPT MARKUP $4/i $NEWENTRY' $3" &> /dev/null
}

add_dhcp_entry() {
	ssh -t $1@$2 "egrep \"# SCRIPT MARKUP $4\" $3" &> /dev/null
	if [ $? != "0" ]; then
		echo "Could not find subnet in DHCP file. Entry not added."
		return 1
	fi
	NEWENTRY="\	host $5 {\n\t\thardware ethernet $6 ;\n\t\tfixed-address $5.aims.edu.gh ;\n\t}"
	ssh -t $1@$2 "sed -i '/# SCRIPT MARKUP $4/i $NEWENTRY' $3"
}

restart_bind_service() {
	ssh -t $1@$2 "service bind9 restart"
}

restart_dhcp_service() {
	ssh -t $1@$2 "service isc-dhcp-server restart"
}

if [ "$EUID" -ne 0 ]; then
	echo "This script must be run as root."
	exit 3
fi

# Initialize static variables
	# name of servers
BINDSERVER="<Insert server here>"
DHCPSERVER="<Insert server here>"
	# name of files on bind server
REVERSEFILENAME="<Insert filename here>"
FORWARDFILENAME="<Insert filename here>"
DHCPDCONFFILENAME="<Insert filename here>"
	# path to files on servers
REVERSEDNSPATH="/etc/bind/zones/$REVERSEFILENAME"
FORWARDDNSPATH="/etc/bind/zones/$FORWARDFILENAME"
DHCPDCONFPATH="/etc/dhcp/$DHCPDCONFFILENAME"

# Initialize user defined variables to null/false
HARDWAREUSER=""
USERSUBNET=""
HARDWAREMAC=""
SERVERUSER=""

# Parse cli arguments
while getopts ":a:m:u:g:ho" opt; do
    	case $opt in
        	a)
	            	HARDWAREUSER="$OPTARG"
	            	;;
	        m)
	            	HARDWAREMAC="$OPTARG"
	            	;;
	        u)
	            	SERVERUSER="$OPTARG"
	            	;;
	        g)
	            	USERSUBNET="$OPTARG"
	            	;;
	        h)
	            	usage
	            	show_options
	            	exit 1
	            	;;
	        o)
	            	show_options
	            	exit 1
	            	;;
	        :)
	            	echo "Please specified required option arguments. Rerun with \"-h\" for usage."
	            	exit 1
	            	;;
	        \?)
	            	echo  "Unknown argument provided! Review your call and try again."
	            	echo "Run the script with \"-h\" for usage."
	            	exit 1
	            	;;
    	esac
done

# null check!
if [[ -z "$HARDWAREUSER" || -z "$HARDWAREMAC" || -z "$SERVERUSER" || -z "$USERSUBNET" ]]; then
	echo """You have not provided the necessary arguments for this script to properly execute. Please review and retry.
	Run the script with \"-h\" for usage."""
    	exit 1
fi

# MAC check!
if ! [[ $HARDWAREMAC =~ [0-9a-zA-Z]{2}:[0-9a-zA-Z]{2}:[0-9a-zA-Z]{2}:[0-9a-zA-Z]{2}:[0-9a-zA-Z]{2}:[0-9a-zA-Z]{2} ]]; then
	echo "You have not provided a correctly formatted MAC address. Please review and retry."
	exit 1
fi

# print summary of actions and sleep for 10 seconds to allow user to verify
echo -e """\nRegistering $HARDWAREUSER
Under group $USERSUBNET
Using MAC Address $HARDWAREMAC
Using server user $SERVERUSER\n"""
echo "Sleeping for 10 seconds. Ctrl-C to exit if parameters are not correct."
sleep 10
echo "Running..."

# Edit the reverse DNS record file.
add_reverse_entry $SERVERUSER $BINDSERVER $REVERSEDNSPATH $USERSUBNET $HARDWAREUSER
update_serial $SERVERUSER $BINDSERVER $REVERSEDNSPATH $REVERSEFILENAME

# Edit the forward DNS record file.
add_forward_entry $SERVERUSER $BINDSERVER $FORWARDDNSPATH $USERSUBNET $HARDWAREUSER
update_serial $SERVERUSER $BINDSERVER $FORWARDDNSPATH $FORWARDFILENAME

#restart the bind service
restart_bind_service $SERVERUSER $BINDSERVER

# add the DHCP entry and restart service
add_dhcp_entry $SERVERUSER $DHCPSERVER $DHCPDCONFPATH $USERSUBNET $HARDWAREUSER $HARDWAREMAC
restart_dhcp_service $SERVERUSER $DHCPSERVER

echo -e "\nUser is now registered! Disconnect the device from the WiFi and reconnect for internet access."
