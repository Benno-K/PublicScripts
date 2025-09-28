# chron

`chron` is a helper script that lists crontab entries in **chronological order**.  
It’s name combines **cron** and **chronologic** – the script is all about putting your cron jobs on a clear, time-sorted timeline.

---

## Why?

When a cron job sends you an error mail, you usually only know the **time** of the failure from the header of the mail, but not necessarily which cronjob triggered it.  
With `chron`, you can immediately locate the failing job in its chronological context, making troubleshooting much easier and faster.

---

## Features

- **Chronological listing** of all cron jobs (primary feature).
- Reads user crontabs (`crontab -l`) or system-wide cron files (`/etc/cron.d/`).
- Displays output in a clean, time-sorted table:
  - **Time**: First executable time (`HH:MM`), `??:??` if indeterminate.
    - Normalized values (derived from ranges, steps, or lists) are marked with `!` (e.g. `!01:00`).
  - **User**: The user field (for system cron jobs).
  - **Command**: The exact command to be executed.
- Handles wildcards (`*`), ranges (`N-M`), steps (`*/N`), and lists (`N,M,...`).
- Keeps the original cron line visible so nothing gets lost in translation.

---

## Usage

```bash
chron <user-or-cronfile>
```

## Example
### Unordered Crontab

Below is an unordered crontab example with comments:

```cron
# System update every Sunday at 04:00
0 4 * * 0 sudo apt update

# Clean tmp every day at 01:30
30 1 * * * rm -rf /tmp/*

# Backup home every weekday at 03:00
0 3 * * 1-5 tar -czf /backup/home.tgz /home

# Disk check on the 1st of every month at 02:15
15 2 1 * * fsck -AR

# Run hourly script
0 * * * * /usr/local/bin/hourly-job.sh
```

---

### Example Output (`chron' $`USER`)

When run through `chron` $`USER`, the above entries would be listed in chronological order:

```text
 01:30  30 1 * * * rm -rf /tmp/*
 02:15  15 2 1 * * fsck -AR
 03:00  0 3 * * 1-5 tar -czf /backup/home.tgz /home
 04:00  0 4 * * 0 sudo apt update
!XX:00  0 * * * * /usr/local/bin/hourly-job.sh
```

- Entries with normalized time (like the hourly job) are marked with a `!` prefix (e.g. `!XX:00`) to show that it repeats at every hour.
- The output is sorted by the time the job first runs within a typical day.
