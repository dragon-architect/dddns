#! /bin/bash

# Creator: Calyo Delphi
# digdeep is a script that can dig for multiple DNS zone record types in multiple hostnames
# Syntax: digdeep <record|host> <record(s)> <host(s)> [<server|IP>]
# Example: digdeep record "a mx txt" "google.com amazon.com"

# shopt -s expand_aliases # This line might cause unexpected behavior if dig or sed have weird aliases already

sorting=$1              # Store the sorting method (by record or by host)
records=$2              # Store all the record types to dig for
hosts=$(eval echo $3)   # Store all the hostnames to dig
# ^ This will ensure brace expansion is properly interpreted

# Quick & dirty regex for checking if Server/IP is an IP address
# I know it can match 999.999.999.999 but using bad IPs generates dig errors anyways
ipregex='^@?[0-9]{1,3}(\.[0-9]{1,3}){3}$'

# Dig arguments; makes the script neater
args="+nocomments +nostats +noquestion +noauthority +noadditional +nocmd"

if [ "$records" == "all" ]; then           # If the input value for records is "all"
    records="soa ns a aaaa cname mx txt"   # Then dig for all the basics: soa, ns, a, aaaa, cname, mx, txt
elif [ "$records" == "dns" ]; then         # If the input value for records is "all"
    records="soa ns a aaaa"                # Then dig for the main records for dns: soa, ns, a, aaaa
fi

if [[ -n "$4" ]]; then   # If $4 is not null, then...
    server="@$4"         # Server/IP is optional; digdeep can only dig at one server/IP
    
    # vv If the server/IP DOES NOT match the IP address regex...
    if [[ ! $server =~ $ipregex ]]; then
        servhost=$4    # Need to store the unadulterated server hostname
        
        echo   # Blank line for neatness

        # vv Dig at the server hostname for the server IP...
        serverip=$( dig +short $server a $servhost )
        
        # vv And output that IP address (may not be accurate)
        echo "IP address of $server: @$serverip"
    fi
fi

echo   # output a blank line to make things neat

if [[ $sorting == "record" ]]; then
    for record in $records   # Iterate through all record types...
    do                       # vv Echo the full query for each record
        echo "DIGGING $server FOR $record IN \"$hosts\""
        
        for host in $hosts   # Iterate through all hosts for each record
        do                   # vv Do the needful!!
            dig $args $server $record $host | sed -r 's/([\t ]+)([0-9]+)([\t ]+)/\1\t\2\t/'
            # Output is piped through sed so that longer hostnames don't disrupt the columns
        done
        
        echo   # Blank line after each record section for neatness
    done
elif [[ $sorting == "host" ]]; then
    for host in $hosts           # Iterate through all hostnames...
    do                           # vv Echo the full query for each host
        echo "DIGGING $server FOR \"$records\" IN $host"
        
        for record in $records   # Iterate through all record types for each host
        do                       # vv Do the needful!!
            dig $args $server $record $host | sed -r 's/([\t ]+)([0-9]+)([\t ]+)/\1\t\2\t/'
            # Output is piped through sed so that longer hostnames don't disrupt the columns
        done
        
        echo   # Blank line after each host section for neatness
    done
else   # vv Error catch vv
    echo "Invalid sorting method"
    echo
    exit 1
fi

# vv Hooray for flavor text! :D vv
RANDOM=$$                     # Seed RANDOM
prob=$(( $RANDOM % 8 + 1 ))   # Calculate random chance of text (50% chance)
case $prob in                 # Run chance through case statement for random quote
    2) echo "You require more Vespene gas!" ;;
    4) echo "Keep going! You're almost to the center of the Earth!" ;;
    6) echo "Run! There's a creeper behind you!" ;;
    8) echo "That ain't a gemstone. That's a hypercube you just unearthed." ;;
esac
