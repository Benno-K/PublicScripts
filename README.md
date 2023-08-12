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
Script to fetch and store a specific cartoon,
named "Non Sequitur" by Wiley Miller,
from a website. Because the website was redesigned witb some tool, it becsme quite complex and it's HTML
is hard to read and understand. 
Somehow I managed to figure out how 
to retrieve the URL of the cartoon 
image for a specific date and for today.

Intended to run daily. Don't 
run before 08:45 CET, the cartoon isn't available much earlier, otherwise you get yesterdays cartoon.

### Usage
/usr/local/bin/nonsequitur [-M] [-d YYYY/MM/DD ]

-M  do not send mail

-d  specify a specific date to download

-o  once a day (no download, if called repeatedly and file exists)

## zero-out-rootfs-freespace

When using dd piped into gzip
for backing up filesystems that are actually used, it pays to fill the
filesystems with zeroes, because these are compressed down to only a few zeroes.
I do this once a week for thr root 
filesystem of my raspberry pi.
Should run when no one is logged in
because it **really** slows down the system.

## screenify.sh

See "man screen" to learn about the screen command 

Run any interactive session, that is not already running in it, in a screen-session.

If there are disconnected sessions, re-connect instead of creating new.

Meant to be sourced during login
so that every login runs in a 
screen. The advantage is that the screen session will survive 
interruptions of your connection.
If the connection is re-established 
later, you will just get your previous session as if nothing 
happened.
I use this on my raspi. It works
perfectly, my only problem is
that I forgot, where exactly is
invoked from.