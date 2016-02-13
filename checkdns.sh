#! /bin/bash

# Creator: Calyo Delphi
# checkdns is a script that digs for DNS configuration records in a DNS zone
# Syntax: checkdns <host> [<server|IP>]
# Example: checkdns google.com

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

echo   # Blank line for neatness

# This block of stuff fetches the nameservers as reported by the registrar and DNS zone
# First the output of dig +trace is piped into sed so that longer hostnames don't disrupt columns
# Then it gets piped into awk to work some more formatting magic...
# The following is a step-for-step description since I can't put comments inside the awk block:
# BEGIN:
#     Set the record separator to a blank line
#     Set the input/output field separators to newlines
# FNR == 3:
#     The third block of dig's output is the nameservers reported by the registrar
#     Also blanks the last field & strips it since it's just a useless dig comment
dig +trace +additional $host | \
sed -r 's/([\t ]+)([0-9]+)([\t ]+)/\1\t\2\t/' | \
awk -v host="$host" '
    BEGIN {
        RS = "";
        FS = "\n"
    }
    FNR == 3 {
        print "Nameservers of",host,"reported by the registrar:";
        OFS = "\n";
        $NF = ""; sub( /[[:space:]]+$/, "" );
        print
    }
'
# And now you're at the end of the ugliest monstrosity of code I'll probably ever have in here
# Kudos to the folks at StackOverflow for giving me what I needed to make this work with awk! :D

echo   # Blank line for neatness

# Dig for the nameservers as reported by the DNS zone of the domain
echo "Nameservers of $host in the DNS zone:"
dig $args $server ns $host | sort | sed -r 's/([\t ]+)([0-9]+)([\t ]+)/\1\t\2\t/'
# Output is piped through sed so that longer hostnames don't disrupt the columns

# Get a list of the nameservers in the DNS zone of the hostname
nameservers=$(dig +short $server ns $host | sort)

# Get the IP addresses of the nameservers in the list
for ns in $nameservers; do
    dig $args $server a $ns | sed -r 's/([\t ]+)([0-9]+)([\t ]+)/\1\t\2\t/'
    # Output is piped through sed so that longer hostnames don't disrupt the columns
done

echo   # Blank line for neatness

# Dig at the server for the SOA for the host
echo "Start of Authority $server for $host:"
# Extra multiline argument for dig so the SOA is displayed in human readable format
dig $args +multiline $server soa $host

echo   # Blank line for neatness

# Dig for the IP address of hostname.tld and www.hostname.tld
# Useful to track if www.hostname.tld is pointed elsewhere
echo "IP addresses $server for (www.)$host:"
for h in {,www.}$host; do
    dig $args $server a $h | sed -r 's/([\t ]+)([0-9]+)([\t ]+)/\1\t\2\t/'
    # Output is piped through sed so that longer hostnames don't disrupt the columns
done

echo   # Blank line for neatness
