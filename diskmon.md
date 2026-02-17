# diskmon

**diskmon** is a compact Bash script for monitoring disk usage on specified filesystems, reporting changes, and tracking thresholds over time. It is designed to be efficient for cron or manual use, providing concise, aligned output and persistent state across runs.

## Usage
# Author: HimbeerToni
# Email: Toni.Himbeer@fn.de
# Repos: https://codeberg.org/Himbeertoni/PublicScripts
# 
# This script is available for
# public use under GPL V3 (see
# file LICENSE)
## Usage

```shell
diskmon [options] fs1 [fs2 ...]
```


- `-t N`  
  Set threshold percentage (default: 5). If the usage of any filesystem changes by more than this value since the last recorded value, a notification is output.

- `-q`  
  Quiet mode (minimal output). Only threshold-exceeded events are reported.

- `-h`, `--help`  
  Show built-in help and exit.


- On the first run for a filesystem, the script records its usage and prints the values.
- On subsequent runs, it compares the current usage to the saved value:
  - If the change exceeds the threshold, a message is displayed.
  - All relevant information is shown in compact, aligned form.
- If called without arguments, the script uses the last-used filesystems and threshold.
- The script persists state in a hidden file in the user's home directory.


```shell
diskmon -t 10 /home /var
```

Checks `/home` and `/var` for a change in usage of more than 10% since last run.

```shell
diskmon -q
```

Runs quietly, reporting only threshold events, using the last saved filesystems and threshold.


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


- The state is saved in `$HOME/.diskmon.state` (or similar, depending on the script's filename).
- It remembers:
  - The last-used filesystems.
  - The threshold.
  - Previous usage values and timestamps for each filesystem.




Due to an article on how AI will change programming and programmers, I stumbled on Github's Copilot and wanted to give it a try. So what you see here is completely computer generated code, but I did have to prompt a lot.

I feel the result is good code. I had programmed similar functunality some time ago manually. 
I prefer the generated code, it looks like I would have written it, I made it look like that by prompting.

I created a bash version first, then a perl-version andmost weird as being a former VMS/DCL junky a DCL version. It took some time, but I would never have achieved
this result in this time by programming it myself.
To tempt the AI a bit, I also asked for a version in PERL and good old DCL (as some IT-veterans may remember, the scripting language of good old and still alive VMS operating system).
I will not continue to work on the DCL version, it is just used for demonstration. The same is true for Perl.
Currently I'm asking myself, whether I should try a C++ or even ancient FORTRAN version.

While testing it, I didn't think of taking notes, so I would have no figures. But I asked my copilot and she/he/it gave me a detailed report, 
which you can find [here](diskmon-ai-session-report.md).




---

**Author:**  
Benno-K and GitHub Copilot  
2025
