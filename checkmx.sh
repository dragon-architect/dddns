#! /bin/bash

# Creator: Calyo Delphi
# checkmx does a quick & dirty mx configuration check
# Syntax: checkmx <host> [<server|IP>]

# Get the variables declared first:
host=$1   # Hostname to check

# Arguments for digs to be run later (makes the script neater)
args="+nocomments +nostats +noquestion +noauthority +noadditional +nocmd"
# Quick & dirty regex for checking if Server/IP is an IP address
# I know it can match 999.999.999.999 but using bad IPs generates dig errors anyways
ipregex='^@?[0-9]{1,3}(\.[0-9]{1,3}){3}$'

if [[ -n $2 ]]; then   # If $2 is not null, then...
    server="@$2"       # Optional Server/IP to check at
    
    # vv If the server/IP DOES NOT match the IP address regex...
    if [[ ! $server =~ $ipregex ]]; then
        servhost=$2    # Need to store the unadulterated server hostname
        
        echo   # Blank line for neatness
    
        # vv Dig at the server hostname for the server IP...
        serverip=$( dig +short a $servhost )
        
        # vv And output that IP address (may not be accurate)
        echo "IP address of $server: @$serverip"
    fi
fi

mxhosts=$( dig +short $server mx $host )    # Get a list of mx records; nothing fancy yet

echo   # Blank line for neatness

echo "DIGGING $server FOR a IN $host"
dig $args $server a $host

echo   # Blank line for neatness

# First, let's just fetch all the MX records for the hostname
echo "DIGGING $server FOR mx IN $host"
dig $args $server mx $host

echo   # Blank line for neatness

echo "DIGGING $server FOR a IN..."
# The next step is to loop through all of the entries in the list fetched earlier
for mxhost in $mxhosts; do
    if [[ $mxhost =~ ^[0-9]*$ ]]; then
        continue   # This should output nothing if $mxhost is a priority (a number)
    else
        # Dig for the A record associated with each $mxhost
        # If the $mxhost is a CNAME, then dig will return the CNAME and its A record
        echo "----------------------------------------------------------------"
        dig $args $server a $mxhost
    fi
done

echo   # Blank line for neatness

