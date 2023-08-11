# PublicScripts

## myip
Simple script using curl and ipify.org
to determine own external IP address
If you are connected to the Internet
using a FRITZ!box I would recommend the extip script over this script as 
it does not depend on remote servers

## extip
Script to determine the external IP
address of your FRITZ!box, which is your hosts IP as well in most cases

## nonseqitur
Script to fetch a specific cartoon,
named "Non Sequitur" by Wiley Miller,
from a website. Because the website was redesigned witb some tool, it becsme quite complex and it's HTML
is hard to read and understand. 
Somehow I managed to figure out how 
to retrieve the URL of the cartoon 
image for a specific date and for today.

Intended to run daily. Don't 
run before 08:45 CET, the cartoon isn't available much earlier, otherwise you get yesterdays cartoon.

> 
Usage: /usr/local/bin/nonsequitur [-M] [-d YYYY/MM/DD ]
-M  do not send mail
-d  specify a specific date to download
-o  once a day (no download, if called repeatedly and file exists)