#! /bin/bash

# Creator: Calyo Delphi
# Just quickly echoes the MX records for Google or GoDaddy
# Useful for those support chats that involve setting mx records to them
# Syntax: echomx <google|godaddy>

host=$1   # Store input

echo      # Blank line for neatness

# vv Error catch vv
if [[ ! $host =~ google|godaddy ]]; then
    echo "Invalid input"
    echo
    exit 1
fi # I put it here so the script's output wouldn't look goofy

# vv Output the MX records list header vv
echo "Pri.  Hostname"

# I think these if statements are self-explanatory
# vv Google MX records vv
if [[ $host == "google" ]]; then
    echo "   1  aspmx.l.google.com"
    echo "   5  alt1.aspmx.l.google.com"
    echo "   5  alt2.aspmx.l.google.com"
    echo "  10  aspmx2.googlemail.com"
    echo "  10  aspmx3.googlemail.com"
fi

# vv GoDaddy MX records vv
if [[ $host == "godaddy" ]]; then
    echo "   0  smtp.secureserver.net"
    echo "  10  mailstore1.secureserver.net"
fi

echo   # Blank line for neatness

