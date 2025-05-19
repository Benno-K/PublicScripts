# Find your IP-address <br/>myip, myip4, myip6
A script to determine and print the first global
IP address (IPv4 or Ipv6) of the computer.

The script/command is named `myip`. For convenience it should also have these symlinks
- `myip4`
- `myip6`

So to get the IP-address you can call
- `myip -4` or `myip4` for IPv4
- `myip -6` or `myip6` for IPv6

## Behind a FRITZ!Box
If your computer is behind a FRITZ!Box you may also want the external IP-address of it. See [`fritzip`](fritzip.md) for this purpose.

## Creating the links
For your convenience there is an (otherwise) undocumented feature
`--makelinks` which will create the symlinks. It will use/request sudo permission, if
the user has no write-permission for the directory
where myip resides (no sudo, no links).

## Examples
```
# myip -4
192.168.178.28
# myip4
192.168.178.28
# myip -6
2003:cc:9f26:9900:ba27:ebff:fe06:849
# myip6
2003:cc:9f26:9900:ba27:ebff:fe06:849
```

## Remark
Because not explicitly handled/forbidden in the code, you might even call
 
  - `myip4 -4`
  - `myip4 -6`
  - `myip6 -4`
  - `myip6 -6`
  
if you are a weirdo.
