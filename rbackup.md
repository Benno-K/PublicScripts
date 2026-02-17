# rbackup

**Automated Rsync-based System Backup Utility**

This script creates a full backup of the root filesystem to another device partition labeled `rootfs` (except the current root).  
It checks for sufficient space, supports both interactive and batch/cron modes, and enforces manual approval of backup options for safety.  
It uses `rsync` with safe options and logs all operations.  
Ideal for SD card or disk cloning on Linux systems.

**Note:**  
You do **not** need to run this script with `sudo`—if not started as root, it will re-invoke itself using `sudo` automatically.


## Options
# Author: HimbeerToni
# Email: Toni.Himbeer@fn.de
# Repos: https://codeberg.org/Himbeertoni/PublicScripts
# 
# This script is available for
# public use under GPL V3 (see
# file LICENSE)
## Options

- `-c`, `--cleanup`  
  List previous approvals and offer to delete
  them
- `--dry-run`  
  Perform a trial run. Exits silently on success. To see what files are processed use `--dry-run -- -i' and look at the note above.


- `-h`, `--help`  
  Show help text.

- `--`  
  All following options are passed directly to `rsync`.



```sh
./rbackup --dry-run
# or
./rbackup
```
You will be prompted with source and target device information, and asked to choose:
- `r` to run and approve this command for cron use.
- `a` to approve for cron but NOT run now.
- `q` to quit.


First, approve desired options interactively:
```sh
./rbackup --dry-run   # choose 'a' to approve for cron only
```
Then, schedule via cron. The script will only run with previously approved options:
```sh
# In crontab:
0 2 * * * /path/to/rbackup --dry-run
```
If no approval file exists for the chosen options, the cron run will be blocked and logged.


- The script requires root privileges, but will automatically use `sudo` if you do not have them.
- All operations are logged in `/var/log/rbackup.log`.
- Approval mechanism prevents accidental or malicious use in cron jobs.


Interactive run:
```sh
./rbackup --dry-run

Source: /dev/mmcblk0p2 (SD/MMC, ModelX, VendorY, PARTUUID=xxxx)
Target: /dev/sda1 (USB, ModelZ, VendorQ, PARTUUID=yyyy)
Your choice (run/approve/quit) [r/a/q]:
```

Cron run (after prior approval):
```sh
./rbackup --dry-run
# (No prompt; runs automatically if previously approved.)
```


GPLv3
