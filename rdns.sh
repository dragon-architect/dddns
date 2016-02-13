#! /bin/bash

# Creator: Calyo Delphi
# rdig is a script that can do an rDNS lookup of a hostname
# Syntax: rdig <host> [<server|IP>]
# Example: rdig google.com

host=$1   # Store the hostname to dig

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
        serverip=$( dig +short $server a $servhost )
        
        # vv And output that IP address (may not be accurate)
        echo "IP address of $server: @$serverip"
    fi
fi

# Dig for the hostname's A record first
firstdig=$( dig +short $server a $host )

# Hostnames as CNAMEs will return multiple lines
# This loop matches the IP address in the answer and assigns it
for answer in $firstdig; do
    if [[ $answer =~ $ipregex ]]; then
        hostip=$answer
    fi
done

# Perform the rDNS lookup
rdns=$( dig +short -x $hostip )

# Echo all of the information back to the user
echo   # Blank line for neatness
echo "IP address of $host $server: $hostip"
echo "rDNS of $hostip: $rdns"
echo   # Blank line for neatness

