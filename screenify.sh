# Run any interactive session, that is not already running in it, in screen
# If there are disconnected sessions, re-connect instead of creating new
type screen >/dev/null 2>&1
if [ $? = 0 ] && [ "$(tty)" != "not a tty" ]; then
  if  [[ !("$TERM" =~ "screen") ]]; then
    # Check for existing detached sessions
    sessname=$(screen -ls | awk '/(Detached)/{print $1;exit}')
    if [ "$sessname" != "" ]; then
      screen -xr "$sessname"
      exit
    else
      screen
      exit
    fi
  fi
fi
