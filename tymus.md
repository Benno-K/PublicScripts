# tymus

tymus is a small wrapper script to send test/diagnostic email messages from the command line. It reads defaults from a per-mailserver profile (config) file, constructs a swaks command for the SMTP transaction and runs it.

Important points kept concise:
- tymus invokes swaks — swaks must be installed and in PATH. The swaks documentation on the web is linked below; no separate swaks-doc package is required.
- Profiles are one file per mailserver and are stored in the tymus subdirectory of the user's XDG config directory: `~/.config/tymus/<profile>`.
- Profile parsing is strict: keys are case-sensitive and must be exactly the permitted names. Unknown or malformed lines (including blank lines or comment lines) will cause an error.

## Links / cross-reference
- swaks project and documentation: https://www.jetmore.org/john/code/swaks/
- swaks man page (example): https://manpages.debian.org/testing/swaks/swaks.1.en.html

## Requirements
- swaks (must be installed and available in PATH).
- POSIX shell (bash/sh).
- Typical unix utilities (cat, chmod, etc.).

Installing swaks on Debian/Ubuntu
```sh
sudo apt update
sudo apt install swaks
```

## Note about swaks and Perl dependencies
swaks is a Perl program that depends on a number of CPAN modules. Some distribution packages do not pull in every dependency and you may see Perl error messages after installing swaks. Prefer your distribution package manager over cpan/cpanm to install these dependencies.

### Helpful Debian/Ubuntu packages to satisfy swaks' dependencies:
```sh
sudo apt update
sudo apt install \
  libdigest-hmac-perl \
  libsub-exporter-perl \
  libmodule-runtime-conflicts-perl \
  libencode-imaputf7-perl \
  libfile-copy-recursive-perl \
  libnet-ssleay-perl \
  libsocket6-perl \
  libio-tee-perl \
  libparse-recdescent-perl \
  libterm-readkey-perl \
  libunicode-string-perl \
  libreadonly-perl \
  libsys-meminfo-perl \
  libregexp-common-perl \
  libfile-tail-perl \
  libdevel-mat-dumper-perl \
  libgetargs-long-perl \
  libperl5.40 \
  libfilesys-df-perl
```
You may have to adjust package names for your distribution/release.

## Credentials and ~/.netrc
swaks reads SMTP credentials from `~/.netrc` (and otherwise prompts). Because of that, tymus profile files do not contain sensitive passwords. Put authentication credentials in `~/.netrc` for non-interactive use.

### Example `~/.netrc` entry:
```
machine smtp.example.com
  login myusername
  password mysecretpassword
```
Secure your netrc file:
```sh
chmod 600 ~/.netrc
```

## Installation of tymus
1. Copy the `tymus` script into a directory on your PATH (e.g., `/usr/local/bin`) or run it from the repository.
2. Make it executable:
```sh
chmod +x /path/to/tymus
```

## Configuration: per-mailserver profiles
- Profiles live in `~/.config/tymus/<profile>`.
- Each profile file is one mailserver profile. The script accepts a profile filename/path as the optional positional `configfile` argument.
- Do not include blank lines or comments in profile files: the parser treats every line as a VAR=VALUE assignment and will error on non-conforming lines.
- Keys are case-sensitive and must match exactly the permitted variable names listed below.

### Permitted profile variables (case-sensitive)
The script documents these exact names in its config-info output. Use these names exactly:

- `mailer`<br/>hostname of mailserver)
- `port` <br/>port number; common: 465 for TLS, 587 for StartTLS, rarely 25
- `from`<br/>originator's mail address
- `to`<br/>recipient's mail address
- `mode`<br/>valid values: `tls` for StartTLS, `tlsc` for implicit TLS
- `ehlo`<br/>local hostname to use in EHLO)
- `ip`<br/>IP protocol preference; influences IPv4/IPv
- `noauth`<br/>if present SMTP-session will not try to log on

### Example profile file `~/.config/tymus/my-mailserver1`:
```
mailer=mx.freenet.de
port=465
from=itsme@freenet.de
to=you@somewhere.org
mode=tlsc
ehlo=mymailer.mydomain.net
ip=4
```
### Profile parsing rules (summary)
- Each line must be a single VAR=VALUE assignment.
- Keys are case-sensitive; `from` is not the same as `From`.
- Blank lines or comment lines are not accepted — they will cause an error.
- Unknown keys or malformed lines will cause an error and abort processing.
- If you want the definitive key list, refer to the output of `./tymus -ci` on your system (it prints the exact valid keys and short descriptions).

## Command-line usage
See below - output of  `tymus -h`
```
Usage: tymus [option..] [configfile]
  tymus takes defs from config file to send a
  test message through an SMTP-mailer
 Options:
  -4    use IPv4 for connection
  -6    use IPv6 for connection
  -a    process ALL config files
  -ci   display info for config file syntax
  -c    config - prompt for creating a config file
  -e    override EHLO from config
  -v    be verbose
  -h    display this text
```

### Notes on options
- [configfile] (optional positional) — path or profile filename to use (resolved relative to `~/.config/tymus/` if you pass a profile name).
- -4 / -6 — force IPv4 or IPv6 respectively.
- -a — process ALL config files found (useful for running the same check/send against all profiles).
- -ci — show config-file syntax help (prints the exact permitted keys and examples).
- -c — prompt to create a config file (interactive helper).
- -e — override the `ehlo` value from the config on the command line.
- -v — verbose mode.
- -h — display help (the usage text above).

### Configuration options info
#### Example: the `-ci` output as shown by the script
```
Configuration variables and their values
 mailer   hostname of mailserver
 port     port number (usual: 465 for TLS
          587 for StartTLS, rarely 25)
 from     the originator's mail address
 to       the recipient's mail address
 mode     valid: tls (=StartTLS), tlsc (=TLS)
 ehlo     the own hostname used to begin the
          conversation
 ip       the IP protocol
 noauth   if present, SMTP-session will not
          try to authenticate
Example:
mailer=mx.freenet.de
port=465
from=itsme@freenet.de
to=you@somewhere.org
mode=tlsc
ehlo=mymailer.mydomain.net
```
### Examples
1) Use a profile named `my-mailserver1`:
```sh
./tymus my-mailserver1
# or if you prefer a full path:
./tymus ~/.config/tymus/my-mailserver1
```

2) Override EHLO on the command line:
```sh
./tymus -e my-other-ehlo my-mailserver1
```

3) Force IPv4 and be verbose:
```sh
./tymus -4 -v my-mailserver1
```

4) Process all profiles:
```sh
./tymus -a
```

5) Show config-file syntax help:
```sh
./tymus -ci
```

## Troubleshooting
- swaks not found<br/>ensure `swaks` is installed and in PATH (`which swaks` or `swaks --version`).
- swaks shows Perl errors about missing modules<br/> install missing Perl packages from your distribution (see list above).
- Profile parse errors<br/> ensure every line in the profile is a valid VAR=VALUE using one of the permitted case-sensitive keys; remove blank lines and comments.
- Authentication failures:<br/> ensure `~/.netrc` contains the correct `machine`/`login`/`password` and has permissions `600`. When in doubt, remove the machine/mailserver from netrc. Then you will be prompted for credentials.

## Security recommendations
- Do not put secrets in profile files; keep credentials in `~/.netrc` and restrict `~/.netrc` with `chmod 600`.
- Be careful when running `-a` (all profiles) to avoid sending accidental messages to many recipients.

# License & contributing
- Follow the repository license (see LICENSE in the repo).
- Contributions: open a PR with changes or improvements to docs or example profiles.
