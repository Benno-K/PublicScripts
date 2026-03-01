##
# Author: HimbeerToni
# Email: Toni.Himbeer@fn.de
# Repos: https://codeberg.org/Himbeertoni/PublicScripts
# 
# This script is available for
# public use under GPL V3 (see
# file LICENSE)
##
require ["vnd.dovecot.pipe", "copy", "imapsieve", "environment", "variables"];

# Define variables
#  set mailbox for later use (destination)
if environment :matches "imap.mailbox" "*" {
  set "mailbox" "${1}";
}
#  set username (used only for.log message)
if environment :matches "imap.user" "*" {
  set "username" "${1}";
}

# No action if putting to Trash, so stop then
if string "${mailbox}" "Trash" {
  stop;
}

# Learn spam if putting TO Junk, then stop
if string "${mailbox}" "Junk" {
  pipe :copy "sievespamlearn" ["spam", "${username}"];
  stop;
}

# as dovecot.conf invokes this script only
# when messages are moved TO or FROM Junk,
# at this stage we know it is being moved
# OUT of Junk, so learn ham
pipe :copy "sievespamlearn" ["ham", "${username}"];
