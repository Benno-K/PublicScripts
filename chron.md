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
