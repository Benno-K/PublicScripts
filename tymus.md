# tymus

tymus is a small wrapper script to send test/diagnostic email messages from the command line. It reads defaults from a per-mailserver profile (config) file, constructs a swaks command for the SMTP transaction and runs it.

Important points kept concise:
- tymus invokes swaks <br/> swaks must be installed and in PATH. 
- Profiles are one file per mailserver and are stored in the tymus subdirectory of the user's XDG config directory: `~/.config/tymus/<profile>`.

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
  -l    list config files in config directory
  -v    be verbose
  -h    display this text
```

### Notes on options
- [configfile] required except with -a<br/> profile filename to use (resolved relative to `~/.config/tymus/`)
- -4 / -6 <br/> force IPv4 or IPv6 respectively
- -a <br/> process ALL config files found (useful for running the same check/send against all profiles). It is not a bad idea using `-l` before using `-a`.
- -ci <br/> show config-file syntax help (prints the exact permitted keys and examples)
- -c <br/> prompt to create a config file (interactive helper).
- -e <br/> override the `ehlo` value from the config on the command line
- -l <br/> list all the configuration files in the configuration directory
- -v <br/> verbose mode for swaks. Will display the conversation with the mailserver including (**not encrypted**,  base64-encoded) credentials in **cleartext**.[^b64enc]
[^b64enc]:This means you will probably not even recognize the credentials in the log, but surely possible attackers will. So keep an eye on the lines following `AUTH LOGIN`! The string `VXNlcm5hbWU6` is just base64 for the server requesting `Username`.
- -h <br/> display help (the usage text above)
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
The ehlo can be blank (or the ehlo-line omitted.

## Credentials and ~/.netrc
swaks reads SMTP credentials from `~/.netrc` (and otherwise prompts). Because of that, tymus profile files do not contain sensitive passwords. Put authentication credentials in `~/.netrc` for non-interactive use.


### Requirements
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
- Each profile file is one mailserver profile. The script requires a profile filename as argument (except when using -a option).
- Do not include blank lines or comments in profile files: the parser treats every line as a VAR=VALUE assignment and will error on non-conforming lines.
- Keys are case-sensitive and must match exactly the permitted variable names listed below.

### Permitted profile variables (case-sensitive)
The script documents these exact names in its config-info output. Use these names exactly:

- `mailer`<br/>hostname of mailserver)
- `port` <br/>port number; common: 465 for TLS, 587 for StartTLS, rarely 25
- `from`<br/>originator's mail address
- `to`<br/>recipient's mail address
- `mode`<br/>valid values: `tls` for StartTLS, `tlsc` for implicit TLS
- `ehlo`<br/>local hostname to use in EHLO[^ehlo]
[^ehlo]:A note on EHLO. Most of mailservers seem to pretty ignore what host is in the EHLO message, so it doesn't matter what you put here in
most cases.
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
- Blank lines or comment lines are not accepted <br/> they will cause an error.
- Unknown keys or malformed lines will cause an error and abort processing.
- If you want the definitive key list, refer to the output of `./tymus -ci` on your system (it prints the exact valid keys and short descriptions).


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

## License & contributing
- Follow the repository license (see LICENSE in the repo).
- Contributions: open a PR with changes or improvements to docs or example profiles.

## Sample output
Usually tymus does not produce any output. But if you need to
troubleshoot a connection you can use the -v option.

### Example for -v
```
tymus -v myprovider
```
could deliver the following output.
```log
=== Trying mx.mydomain.eu:465...
=== Connected to mx.mydomain.eu.
=== TLS started with cipher TLSv1.3:TLS_AES_256_GCM_SHA384:256
=== TLS client certificate not requested and not sent
=== TLS no client certificate set
=== TLS peer[0]   subject=[/CN=mydomain.eu]
===               commonName=[mydomain.eu], subjectAltName=[DNS:a.mydomain.eu, DNS:b.mydomain.eu, DNS:myotherdomain.de, DNS:c.mydomain.eu, DNS:mydomain.eu, DNS:mx.mydomain.eu, DNS:mymailer.mydomain.eu, DNS:www.myotherdomain.de, DNS:www.mydomain.eu] notAfter=[2025-11-23T00:03:15Z]
=== TLS peer certificate failed CA verification (unable to get local issuer certificate), passed host verification (using host mx.mydomain.eu to verify)
<~  220 mymailer ESMTP Postfix
 ~> EHLO mx.mydomain.eu
<~  250-mymailer
<~  250-PIPELINING
<~  250-SIZE 104857600
<~  250-VRFY
<~  250-ETRN
<~  250-AUTH PLAIN LOGIN
<~  250-ENHANCEDSTATUSCODES
<~  250-8BITMIME
<~  250-DSN
<~  250 SMTPUTF8
 ~> AUTH LOGIN
<~  334 VXNlcm5hbWU6
 ~> ( left out in example)
<~  334 UGFzc3dvcmQ6
 ~> ( left out in example)
<~  235 2.7.0 Authentication successful
 ~> MAIL FROM:<myself@mydomain.eu>
<~  250 2.1.0 Ok
 ~> RCPT TO:<myself@provider.de>
<~  250 2.1.5 Ok
 ~> DATA
<~  354 End data with <CR><LF>.<CR><LF>
 ~> Date: Fri, 24 Oct 2025 14:34:02 +0200
 ~> To: myself@provider.de
 ~> From: myself@mydomain.eu
 ~> Subject: myself@mydomain.eu→myself@provider.de via IPv6:mx.mydomain.eu:465/TLS
 ~> Message-Id: <20251024143402.013671@mymailer.mynet.home>
 ~> X-Mailer: swaks v20240103.0 jetmore.org/john/code/swaks/
 ~> Content-Type: text/plain;charset=utf-8
 ~> 
 ~> This test message was sent using the following parameters
 ~> IP version: 6
 ~> From:       myself@mydomain.eu
 ~> To:         myself@provider.de
 ~> Mailer:     mx.mydomain.eu
 ~> Port:       465
 ~> Mode:       TLS
 ~> EHLO:       mx.mydomain.eu
 ~> at 14:34:01 on 10/24, 2025
 ~> 
 ~> ©2025 tymus on mymailer running Raspbian GNU/Linux (trixie)
 ~> 
 ~> .
<~  250 2.0.0 Ok: queued as 6E3A0A0E9D
 ~> QUIT
<~  221 2.0.0 Bye
=== Connection closed with remote host.
```
