## updfblog
Script to maintain a local copy of all events logged on your FRITZ!Box.
This script downloads the event messages from a
FRITZ!Box and maintains a local file containing all
events. It creates one such file per year.

### How it works
It connects to your FRITZ!Box and asks for the log messages. Then it stores them in a local logfile. When called the next time, it checks which messages are already contained in the logfile and appends any new messages to the logfile.
It is a good idea to run this script at regular intervals. Cron could do that for you.


### Getting started

- You need an account on the box with the permission
to read (and unfortunately change) the box's configuration. This requirement comes from FRITZ!OS, I cannot change that
- Create a directory where the logs should go. The default directory is "`fblogs`" in your home directory (`mkdir ~/fblogs` does that). If you prefer another name, go ahead, create it and use the `-d` option.

 
 ### Command options (use -h to list)
 ```
 Usage: (Version: 1.0-005)
  updfblog [option[,option...]]
  -b --box <hostname or IP of FRITZ!Box>
  -c --creds <storefile> containg the credentials
          by default ~/.updfblog.data is checked
          overrides -u
  -C --save-credentials [<storefile>]
          store credentials in file
          can be used together with -c
          default storefile is ~/.updfblog.data
          storing passwords in a file is potentially
          unsafe!
  -d --dir <directory-to-hold-logfiles>
  -h --help (shows this text)
  -n --name <file-basename> (of logfile, default:fblog)
  -p --pass <name> can be
          a) environment variable
          b) a named pipe
          c) an executable file
          that holds or delivers the password
          of the FRITZ!Box user
  -u --user <username> (of FRITZ!Box-user)
 ```

Tested and developed on Raspbian GNU/Linux 12 (bookworm) using a FRITZ!Box 7590 running FRITZ!OS 8.02.
