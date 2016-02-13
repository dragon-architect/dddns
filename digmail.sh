#! /bin/bash

# Creator: Calyo Delphi
# digmail is a script that can dig for a bunch of different mail-related dns zone records
# Syntax: digmail <host> [<server|IP>]
# Example: digmail google.com

# Get the variables declared first:
host=$1   # Hostname to check

# Arguments for digs to be run later (makes the script neater)
args="+nocomments +nostats +noquestion +noauthority +noadditional +nocmd"
# Possible subdomains of the hostname to dig for any A records
subdoms="mail email webmail smtp pop imap"

# Quick & dirty regex for checking if Server/IP is an IP address
# I know it can match 999.999.999.999 but using bad IPs generates dig errors anyways
ipregex='^@?[0-9]{1,3}(\.[0-9]{1,3}){3}$'

# Quick & dirty regex to match SPF records
# It basically just rejects txt records that don't match the beginning and end of an SPF
# Those are the important parts of an SPF record anyways
spfregex='^\"[vV]=(spf|SPF)1?'

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

echo   # Blank line for neatness

echo "DIGGING $server FOR a IN $host"
dig $args $server a $host | sed -r 's/([\t ]+)([0-9]+)([\t ]+)/\1\t\2\t/'
# Output is piped through sed so that longer hostnames don't disrupt the columns

echo   # Blank line for neatness

# First, let's just fetch all the MX records for the hostname
echo "DIGGING $server FOR mx IN $host"
dig $args $server mx $host | sed -r 's/([\t ]+)([0-9]+)([\t ]+)/\1\t\2\t/'
# Output is piped through sed so that longer hostnames don't disrupt the columns

echo   # Blank line for neatness

# Get a list of MX records for the next few steps:
# Grabbing their IP addresses as well as looking up the rDNS of them
for item in $( dig +short $server mx $host ); do
    # Only save the hostnames in the MX records--not the priorities
    if [[ ! $item =~ ^[0-9]$ ]]; then
        mxrecs="$mxrecs $item"
    fi
done

# Look up the IP addresses of the MX records:
echo "IP addresses $server of the MX records of $host:"
for mxrec in $mxrecs; do
    dig $args $server a $mxrec | sed -r 's/([\t ]+)([0-9]+)([\t ]+)/\1\t\2\t/'
    # Output is piped through sed so that longer hostnames don't disrupt the columns
done

echo   # Blank line for neatness

# Get a list of the IP addresses of the MX records
# Haven't yet figured out how to do this without nesting digs
mxips=$( dig +short $server $mxrecs )

echo "PTR records (rDNS) for the IP addresses of the MX records of $host:"
# Loop through all of the MX records fetched earlier and dig for rDNS
for mxip in $mxips; do
    if [[ $mxip =~ $ipregex ]]; then
        dig $args -x $mxip
    fi
done

echo   # Blank line for neatness

# vv Get all txt records for the hostname first
txtrecords=$( dig +short $server txt $host )

echo "SPF record $server for $host..."

IFS="$(printf '\n')"      # Set the Internal Field Separator to newlines only temporarily

# vv Time to loop through all the txt records...
for txtrecord in $txtrecords; do
    # vv If the txt record matches the spf regex defined above...
    if [[ $txtrecord =~ $spfregex ]]; then
        echo $txtrecord   # Echo the spf record
    fi
done

IFS="$(printf ' \t\n')"   # Reset the IFS back to all whitespace

echo   # Blank line for neatness

echo "DIGGING $server FOR a IN ($subdoms).$host"
# Next, let's loop through all of the possible subdomains to see which ones exist in the DNS zone
for subdom in $subdoms; do
    dig $args $server a $subdom.$host | sed -r 's/([\t ]+)([0-9]+)([\t ]+)/\1\t\2\t/'
    # Output is piped through sed so that longer hostnames don't disrupt the columns
done

echo   # Blank line for neatness

