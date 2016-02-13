# Dig Deep DNS Toolkit

This is a collection of shell scripts that I wrote back when I was working in tech support for a reptilian web host. Although I don't use these scripts actively anymore, I still intend to maintain them and eventually finish some of them and add feature sets as I can think of them.

However, since I do not actively provide web hosting tech support anymore, I have had little motivation to work on these scripts, myself.

## What is the Dig Deep DNS Toolkit?

**It is small set of simple shell scripts for DNS troubleshooting!**

The explanation can't possibly get any simpler than that. DIG (Domain Information Groper) is a very convenient tool to have if you have any sort of Unix, Linux, or Cygwin environment and you do a lot of troubleshooting of domains, web hosting, or DNS. I first learned about DIG some months after I started working for HostGator as a Junior Admin (a.k.a. customer support technician) when a fellow Jr. Admin taught me about it.

I instantly took to using DIG a lot during my own troubleshooting. But DIG has a few shortcomings when used on its own: it couldn't provide all of the information that I needed in an informative and structured manner. In an effort to make my own workflow smoother and more efficient, I sought to create a simple shell script that could use DIG in a much more constructive and informative way, and thus was the genesis of my digdeep script.

Digdeep's usefulness immediately made itself apparent when I started using it at work. Several supervisors to whom I distributed found it useful on occasion as well! However, digdeep had a few shortcomings of its own. This necessity for a toolkit of scripts that each use dig in various ways to query for useful DNS information led to the creation of exactly that toolkit! Each script in the toolkit was developed whenever I needed DIG to do something different that it couldn't do on its own.



## Installation

This toolkit does not have any sort of easy-installer to go with it! What you will need to do is this:

1.  Download the files, or clone the repo to your own system. I would recommend cloning into your home directory.
2.  Add this line into your .bashrc somewhere: `source ~/dddns/.dddnsrc` and save
3.  Then run this command in your terminal to reload your own bash configuration with the Dig Deep DNS Toolkit added in: `source ~/.bashrc`

These are the aliases contained in .dddnsrc (just in case Github doesn't show dot-files):

```bash
# These aliases are optional, but are useful shortcuts of common dig uses
alias digs='dig +short' # General terse dig
alias digx='dig -x' # rDNS dig
# Here's an alias to run a dig without all of the excess comments and other output
alias cleandig='dig +nocomments +nostats +noquestion +noauthority +noadditional +nocmd'

# These aliases are for the actual scripts:
alias checkdns='bash ~/dddns/checkdns.sh'
alias checkmx='bash ~/dddns/checkmx.sh'
alias digdeep='bash ~/dddns/digdeep.sh'
alias digmail='bash ~/dddns/digmail.sh'
alias echomx='bash ~/dddns/echomx.sh'
alias rdns='bash ~/dddns/rdns.sh'
```



## Codex

### checkdns

checkdns runs a series of digs to query for general DNS configuration information of a given domain. checkdns retrieves the nameservers as reported by the queried domain's registrar, the following information from the queried domain's DNS zone: IP address of the queried server (if a server is provided), NS records, nameserver IP addresses, Start of Authority with SOA comments, and IP addresses of domain.tld and www.domain.tld. checkdns is **NOT** a replacement for online DNS checking tools such as [Leaf DNS](http://leafdns.com) or [Into DNS](http://intodns.com); however, checkdns is faster to provide preliminary information to start from compared to Leaf DNS or Into DNS.

Syntax: `checkdns <domain> [<server|IP>]`

```
~ $ checkdns digdeepdns.net web4042.websitewelcome.com

IP address of @web4042.websitewelcome.com: @192.185.2.65

Nameservers of digdeepdns.net reported by the registrar:
digdeepdns.net.			172800	IN	NS	ns1.digdeepdns.net.
digdeepdns.net.			172800	IN	NS	ns2.digdeepdns.net.
ns1.digdeepdns.net.		172800	IN	A	192.185.57.22
ns2.digdeepdns.net.		172800	IN	A	192.185.57.216

Nameservers of digdeepdns.net in the DNS zone:
digdeepdns.net.			86400	IN	NS	ns2.digdeepdns.net.
digdeepdns.net.			86400	IN	NS	ns1.digdeepdns.net.
ns2.digdeepdns.net.		14400	IN	A	192.185.57.22
ns1.digdeepdns.net.		14400	IN	A	192.185.57.216

Start of Authority @web4042.websitewelcome.com for digdeepdns.net:
digdeepdns.net.		86400 IN SOA ns1.digdeepdns.net. slucas.digdeepdns.net. (
				2013100200 ; serial
				14400      ; refresh (4 hours)
				7200       ; retry (2 hours)
				3600000    ; expire (5 weeks 6 days 16 hours)
				14400      ; minimum (4 hours)
				)

IP addresses @web4042.websitewelcome.com for (www.)digdeepdns.net:
digdeepdns.net.			14400	IN	A	192.185.57.22
www.digdeepdns.net.		14400	IN	CNAME	digdeepdns.net.
digdeepdns.net.			14400	IN	A	192.185.57.22
```


### checkmx

checkmx retrieves the IP address of the provided hostname, a list of the provided hostname's MX records, and the IP addresses of each MX record. The IP address of the hostname can be used to compare the IP addresses that the MX record(s) resolve to to determine if the MX records point to the same server. This script has been deprecated by [digmail](digmail), but it remains as a part of the tool kit for specialty uses.

Syntax: `checkmx <domain> [<server|IP>]`

```
~ $ checkmx digdeepdns.net web4042.websitewelcome.com

IP address of @web4042.websitewelcome.com: @192.185.2.65

DIGGING @web4042.websitewelcome.com FOR a IN digdeepdns.net
digdeepdns.net.		14400	IN	A	192.185.57.22

DIGGING @web4042.websitewelcome.com FOR mx IN digdeepdns.net
digdeepdns.net.		14400	IN	MX	0 digdeepdns.net.

DIGGING @web4042.websitewelcome.com FOR a IN...
----------------------------------------------------------------
digdeepdns.net.		14400	IN	A	192.185.57.22
```


### digdeep

digdeep was the first script written for this toolkit. digdeep can dig across multiple hostnames for multiple DNS zone record types, and sort its output by record type or by hostname. If multiple record types and/or hostnames are provided, each list must be enclosed in "double quotes". Digdeep also supports {brace,expansion}, and the hostname must be "double quoted" as if it were a list, otherwise you'll get weird output. An optional server or IP address can be provided to query (the output examples provided below omit this additional argument). digdeep has an additional easter egg: 50% of the time, digdeep will output an additional humorous geeky quote at the end.

Syntax: `digdeep <host|record> <record(s)> <hostname(s)> [<server|IP>]`

```
~ $ digdeep host "ns a" "digdeepdns.net hostgator.com"

DIGGING  FOR "ns a" IN digdeepdns.net
digdeepdns.net.			86400	IN	NS	ns1.digdeepdns.net.
digdeepdns.net.			86400	IN	NS	ns2.digdeepdns.net.
digdeepdns.net.			14400	IN	A	70.84.243.131

DIGGING  FOR "ns a" IN hostgator.com
hostgator.com.			45275	IN	NS	ns4.p13.dynect.net.
hostgator.com.			45275	IN	NS	ns3.p13.dynect.net.
hostgator.com.			45275	IN	NS	ns2.p13.dynect.net.
hostgator.com.			45275	IN	NS	ns1.p13.dynect.net.
hostgator.com.			11	IN	A	173.192.226.44

Run! There's a creeper behind you!
```
```
~ $ digdeep record "ns a" "digdeepdns.net hostgator.com"

DIGGING  FOR ns IN "digdeepdns.net hostgator.com"
digdeepdns.net.			21573	IN	NS	ns2.digdeepdns.net.
digdeepdns.net.			21573	IN	NS	ns1.digdeepdns.net.
hostgator.com.			44938	IN	NS	ns4.p13.dynect.net.
hostgator.com.			44938	IN	NS	ns3.p13.dynect.net.
hostgator.com.			44938	IN	NS	ns2.p13.dynect.net.
hostgator.com.			44938	IN	NS	ns1.p13.dynect.net.

DIGGING  FOR a IN "digdeepdns.net hostgator.com"
digdeepdns.net.			14373	IN	A	70.84.243.131
hostgator.com.			7	IN	A	173.192.226.44

Keep going! You're almost to the center of the Earth!
```
```
~ $ digdeep record a "ns{1..6}.hostgator.com"

DIGGING  FOR a IN "ns1.hostgator.com ns2.hostgator.com ns3.hostgator.com ns4.hostgator.com ns5.hostgator.com ns6.hostgator.com"
ns1.hostgator.com.		2467	IN	A	67.18.54.2
ns2.hostgator.com.		14400	IN	A	67.18.54.3
ns3.hostgator.com.		3244	IN	A	184.172.176.21
ns4.hostgator.com.		21600	IN	A	184.172.179.128
ns5.hostgator.com.		21600	IN	A	184.172.165.14
ns6.hostgator.com.		21600	IN	A	184.172.161.32
```

**Note for OS X users:** If you are sentimentally attached to your neutered OS X version of sed, then this script is going to behave very awkwardly for you without modification. The easiest fix is to just delete the pipes through sed that are in the main loops of this script that do all the dirty work. I had to manually install GNU sed (as gsed) using either MacBrew or MacPorts (for MacPorts, I had to create a symlink as `/opt/local/bin/sed => /opt/local/bin/gsed`) to fix this myself without removing the pipes to sed. (My primary system is a MacBook Pro. I have every right to rip on the very operating system that I develop on. :P)


### digmail

digmail can be considered an "evolution" of checkmx. checkmx only retrieves the MX records of a given hostname and their IP addresses. digmail however retrieves a much larger set of mail DNS configuration information: IP address of the provided domain, the domain's MX records, IP addresses of the MX records, the SPF record of the provided domain, and the IP addresses of the following subdomains: mail, email, webmail, smtp, pop, & imap.

Syntax: `digmail <domain> [<server|IP>]`

```
~ $ digmail digdeepdns.net web4042.websitewelcome.com

IP address of @web4042.websitewelcome.com: @192.185.2.65

DIGGING @web4042.websitewelcome.com FOR a IN digdeepdns.net
digdeepdns.net.			14400	IN	A	192.185.57.22

DIGGING @web4042.websitewelcome.com FOR mx IN digdeepdns.net
digdeepdns.net.			14400	IN	MX	0 digdeepdns.net.

IP addresses @web4042.websitewelcome.com of the MX records of digdeepdns.net:
digdeepdns.net.			14400	IN	A	192.185.57.22

PTR records (rDNS) for the IP addresses of the MX records of digdeepdns.net:

SPF record @web4042.websitewelcome.com for digdeepdns.net...
"v=spf1 ip4:70.84.243.130 a mx ip4:192.185.57.216 include:websitewelcome.com ~all"

DIGGING @web4042.websitewelcome.com FOR a IN (mail email webmail smtp pop imap).digdeepdns.net
mail.digdeepdns.net.		14400	IN	CNAME	digdeepdns.net.
digdeepdns.net.			14400	IN	A	192.185.57.22
webmail.digdeepdns.net.		14400	IN	A	192.185.57.22
```


### echomx

echomx is a simple script that can echo the MX records of Google Apps Mail and GoDaddy Email. This script is only useful for recalling the MX records of these two services without looking them up online.

Syntax: `echomx <google|godaddy>`

```
~$ echomx google

Pri.  Hostname
   1  aspmx.l.google.com
   5  alt1.aspmx.l.google.com
   5  alt2.aspmx.l.google.com
  10  aspmx2.googlemail.com
  10  aspmx3.googlemail.com
```


### rdns

Dig has a built-in flag for an rDNS lookup as `dig -x ip.ad.dr.ess`. However, this lookup will only accept an IP address for its input. It is possible to use `dig -x $(dig host.name.tld)` as a workaround, but this does not work at all if host.name.tld returns a CNAME first before an A record (IP address). rdns solves this issue. It can take any hostname as its input, get the IP address that the hostname resolves to (and filter out any CNAMEs), and then perform an rDNS lookup on the resultant IP address.

Syntax: `rdns <hostname> [<server|IP>]`

```
~ $ dig +short www.hostgator.com
hostgator.com.
50.97.99.189
~ $ rdns hostgator.com

IP address of hostgator.com : 50.97.99.189
rDNS of 50.97.99.189: 50.97.99.189-static.reverse.softlayer.com.
```


### spfinfo

spfinfo is currently still in development. However, this script will be capable of retrieving a given domain's SPF record (if it has one) and provide a detailed breakdown of the policy defined in the SPF record.
