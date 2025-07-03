# diskmon

**diskmon** is a compact Bash script for monitoring disk usage on specified filesystems, reporting changes, and tracking thresholds over time. It is designed to be efficient for cron or manual use, providing concise, aligned output and persistent state across runs.

## Purpose

- Watch disk usage for one or more filesystems.
- Persistently record previous usage statistics and compare on each run.
- Alert if the usage changes by more than a user-defined threshold.
- Display both the current and previous usage values, as well as timestamps.
- Support minimal output mode for scripting or cron integration.
- Automatically recall last-used filesystems and threshold if invoked without arguments.

## Usage

```shell
diskmon [options] fs1 [fs2 ...]
```

### Options

- `-t N`  
  Set threshold percentage (default: 5). If the usage of any filesystem changes by more than this value since the last recorded value, a notification is output.

- `-q`  
  Quiet mode (minimal output). Only threshold-exceeded events are reported.

- `-h`, `--help`  
  Show built-in help and exit.

### Behavior

- On the first run for a filesystem, the script records its usage and prints the values.
- On subsequent runs, it compares the current usage to the saved value:
  - If the change exceeds the threshold, a message is displayed.
  - All relevant information is shown in compact, aligned form.
- If called without arguments, the script uses the last-used filesystems and threshold.
- The script persists state in a hidden file in the user's home directory.

### Example

```shell
diskmon -t 10 /home /var
```

Checks `/home` and `/var` for a change in usage of more than 10% since last run.

```shell
diskmon -q
```

Runs quietly, reporting only threshold events, using the last saved filesystems and threshold.

### Output Example

```
/home:
 80% f:123456 u:654321
 rec:03.07.25/12.40 trg:03.07.25/12.40
/var:
 now 75% was 73% f:234567 u:876543
 rec:02.07.25/11.07 trg:03.07.25/12.40
```

- Each filesystem starts in column 1; secondary lines are indented.
- `now` shows the current usage, `was` the recorded value.
- `f:` and `u:` indicate free and used space.
- `rec:` is the recorded (previous) timestamp; `trg:` is when the check was triggered.

## State File

- The state is saved in `$HOME/.diskmon.state` (or similar, depending on the script's filename).
- It remembers:
  - The last-used filesystems.
  - The threshold.
  - Previous usage values and timestamps for each filesystem.

---

**Author:**  
Benno-K and GitHub Copilot  
2025
