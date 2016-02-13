#! /bin/bash

# Mechanisms: ALL|A|IP4|IP6|MX|PTR|EXISTS|INCLUDE
# Qualifiesrs: [+?~-]?
# Modifiers: EXP|REDIRECT
# 
# IP4:([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]{1,3})?
# IP6:Ugh gods kill me now...
# 
# a|A|mx|MX|ptr|PTR|(IP4|ip4):(([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]{1,3})?))|(IP6|ip6):(_____)|(INCLUDE|include):(______)|(EXISTS|exists):(_____)
# 

ipv4regex="^(ip4|IP4):(([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]{1,3})?)$"
ipv6regex="^(ip6|IP6):(([0-9a-fA-f]{1,4}:){7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}(:[0-9a-fA-F]{1,4}){0,6})?::(([0-9a-fA-F]{1,4}:){0,6}[0-9a-fA-F])?)|((([0-9a-fA-F]{1,4}:){6}|([0-9a-fA-F]{1,4}(:[0-9a-fA-F]{1,4}){0,5})?::(([0-9a-fA-F]{1,4}:){0,5}[0-9a-fA-F]:)?)([0-9]{1,3}\.){3}[0-9]{1,3})(/[0-9]{1,3})?$"


for rule in $policy; do
    if [[ $rule =~ ([+?~-]?)(.*) ]]; then
        qualifier=${BASH_REMATCH[1]}
        mechanism=${BASH_REMATCH[2]}
    else
        continue
    fi
    
    case $qualifier in
      -)
        status="FAIL"     ;;
      ~)
        status="SOFTFAIL" ;;
      \?)
        status="NEUTRAL"  ;;
      *)
        status="PASS"     ;;
    esac
    
    case $mechanism in
      a|A)
        data=$(( dig +short $server a $host )) ;;
      mx|MX)
        data=$(( dig +short $server mx $host )) ;;
      ptr|PTR)
        
      ;;
      (IP4|ip4):.*)
        
      ;;
      (IP6|ip6):.*)
        
      ;;
      (INCLUDE|include):.*)
        
      ;;
      (EXISTS|exists):.*)
        
      ;;
      (EXP|exp)=.*)
        
      ;;
      (REDIRECT|redirect)=.*)
        
      ;;
    esac
done
