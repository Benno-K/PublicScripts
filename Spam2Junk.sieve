##
# Author: HimbeerToni
# Email: Toni.Himbeer@fn.de
# Repos: https://codeberg.org/Himbeertoni/PublicScripts
# 
# This script is available for
# public use under GPL V3 (see
# file LICENSE)
##

require ["vnd.dovecot.pipe", "copy", "imapsieve", "environment", "variables", "fileinto", "regex"];

# File spam marked by rspamd into Junk-folder
if header :regex "X-Spam" "^[Yy][Ee][Ss]$" {
    fileinto "Junk";
    stop;
}

