# Public-Scripts
Why call it public scripts?
They are designated to be 
available to all users on 
a multi-user system. On Linux systems they are typically located
in a directory that is contained 
in the execution PATH of all users,
like /usr/local/bin.
Some of the scripts may need 
to be run under specific
accounts to access some files.

## clean
Very simple wrapper around
a grep command that removes
all comment lines (starting
with a hash-sign (#)) and
all empty lines. Specify
zero or more filenames as
parameters as of you would
do with grep.

## crondtab
Easily edit or list files in
/etc/cron.d which usually
come with some software that
needs to run frequently, e.
g. can be used for the 
**diskusage** script.

## extip
Script to determine the external IP
address of your FRITZ!box, which is your hosts IP as well in most cases

## myip
Simple script using curl and ipify.org
to determine own external IP address
If you are connected to the Internet
using a FRITZ!box I would recommend the extip script over this script as 
it does not depend on remote servers

## nonsequitur

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

### Why is this script public?
It could reside in the user's
~/bin as well, it needs no
permissions. I just put it 
to /usr/local/bin so that
every authorized user can
invoke it.

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
I use this on all my computers. 
I have included it in the 
~/.profile of the user root and
of my personal account.
It has been working perfectly for about a decade now.

## diskusage

Checks the usage of some file-systems
for changes. Actually it does 
mainly a "df -h" stores the
reuslt. Sends mail if result
of check id dofferent from 
last run. Should be used to
get alarmed for filesystems
where you do not expect 
changes. To be run as cron-job
but not too frequently (you
may not want to get an email
just because some program 
creates 1% growth per minute
while it runs for ten.

Just because it suits my needs,
the default filesystems checked
when you don't pass any as arguments,

are: / /boot /ssd /data"


## testmail
Sends a timestamped test
email. 

### Parameters:
- Recipient
If not specified it will be
prompted.
