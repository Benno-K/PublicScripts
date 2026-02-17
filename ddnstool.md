# ddnstool
## "abuse" responses from your DDNS server
# Author: HimbeerToni
# Email: Toni.Himbeer@fn.de
# Repos: https://codeberg.org/Himbeertoni/PublicScripts
# 
# This script is available for
# public use under GPL V3 (see
# file LICENSE)
## "abuse" responses from your DDNS server
To prevent overloading through senseless or potential harmful requests, most DDNS server take some precaution. If your script is bothering the server somehow (let's say with 10 requests per second to set a name to the IP it already has), the server may detect this and respond with the response "abuse". Moreover your account will be put on some blacklist, and even valid requests will be blocked. The only thing you can do about this, is to **stop sending any request** to the server and **wait**. Maybe for minutes, maybe for hours, only the provider knows.
To avoid this kind of trouble as early as possible
`ddnstool` tracks abuse responses, and stops sending requests (**silently!**, use -l or -hl to find out). It will  then no longer send any requests
until you invoke `ddnstool -ra` to reset the abuse
count.



``` 
  Usage: ddnstool [options] [name ..]
   Options:
    -1|-once
      For use withis is -w: do not loop
    -a|-abuse-limit <integer value>
      for information about "abuse" responses
      and options use -ha or -help-abuse
      default is 3
    -c|-crinit
      Initialize ~/.ddnscr, the creditals file.
      It holds the name or IP of your
       - fritzbox
       - dns-server
       - DynDNS-server
      and of that DynDNS-server
       - the username and
       - the password
      For all this you will be prompted.``
    -i|-interval
      For use with -w: seconds to wait before re-checking
     Default: 5
    -dry|-3
      Dry run. Only print what was detected and what
      would be done.
    -f|-force
      Send a request to the DDNS server, even if
      the name already points to requested IP.
      Normally no update is requested if the IP is
      unchanged. Ignored with -w.
    -l|-log
      Be a bit verbose, otherwise script will not produce
      any output in normal operation.
    -la|--log-attempts
      Log all attempts too, implies -lh
      Ignored with -w to avoid huge history-logs
    -lh|-log-history [log-history-file]
      Log all requests and their results in a history
      file. You can specify a filename directly after
      the option. If you don't, the default name
      is ~/ddnstool-history.log
    -ra|-reset-abuse-counter
      for information about "abuse" responses
      and options use -ha or -help-abuse
    -w|-watchip
     Check whether the IPv4 or IPv6 has changed, if so
     update DDNS
```

```
DDNS response "abuse"
 DynDNS servers usually monitor their usage
 and reject requests they categorize as
 abuse with the response "abuse". If - for
 whatever reason - you get this response,
 it is usually a very good idea to stop
 all further requests and analyze the cause,
 as all requests including correct ones 
 from your address will be counted as abuse.
 The remedy is to stop sending requests as
 the server will remove you from the abusers
 list after a while when you do not send any
 more requests.
 By default ddnstool stops sending requests
 to a particular DDNS-account, after the 3rd abuse
 response.
  Usage: ddnstool [options] [name ..]
    -a|-abuse-limit <integer value>
      Set limit after how many abuse responses
      no more requests are sent.
      If this limit is reached, manual 
      intervention is required. ddnstool will
      no longer send requests until manually
      reset by -ra
    -ra|-reset-abuse-counter
     reset the abuse counter to zero
```
