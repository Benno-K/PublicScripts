# Get your FRITZ!Box's external IP-address<br/>fritzip

You can simple use `fritzip` to get the external IP-address of your FRITZ!Box. It must be configured to answer UPNP requests, which is the default,  but may have been disabled by some paranoid FRITZ!Box admin.

## Commands to use

Use `fritzip -4` to get the IPv4 address. Use `fritzip -6` to get the IPv6 address.

## Possible sources of confusion
If you only have the good old IP Version 4 running on your system you *can stop to read* at this point.

When running a dual-IP-stack[^1] computer behind a dual-stack FRITZ!Box, one might get confused about the external addresses.
[^1]: Dual stack means the device runs both internet protocol stacks at the same time and is therefore reachable by it's IPv4 address as well as by it's IPv6 address.

For **IPv4** the external address of *any internal server* is **identical** to *the fritzbox''s IP*.
The reason for this is that one only gets **one single** IPv4 address per connection, so network address translation (NAT) is done by the router forwarding the traffic to the internal servers. [^2].
[^2]:This kind of stuff must be configured in the router. A more detailed explanation is out of scope here.

For **IPv6** the external address(es) of *your internal servers* do **differ** from *the fritzbox's IP*.
The reason for that is that one gets **a range of** IPv6 per connection, so the router can forward the traffic directly to the internal server(s). [^3].
[^3]:This kind of stuff also must be configured in the router. A more detailed explanation is out of scope here.

It also can  be challenging to configure (dynamic) DNS-names for your devices.

E. g. to reach one and the same webserver via both  protocol versions, you need to have the name pointing to the IPv4 of the **fritzbox** while at the same  time pointing to the IPv6 of your **server**[^4].

[^4]:Assume the DNS-name is `mysrv.dunno.com`, the <br/>**fritzbox** has <br/>IPv4 of `79.xxx.xx.186` and the <br/>IPv6 `2003:...:fe1f:5704` and your <br/>**server** has <br/>IPv6  `2003:...:fe06:1849`. <br/>Your name `mysrv.dunno.com` then needs to point to `79.xxx.xx.186` and `2003:...:fe06:1849`.
And if this is not already confusing enough, if you want to use `fritzbox.dunno.com` at the same time, you'd need to point that to `79.xxx.xx.186` and `2003:...:fe06:5704` (of course IPv4 requires the services on fritzbox and server to use different ports).<br/>
To give you another headache, you could try to obtain a SSL-certificate for `fritzbox.dunno.com` using the computer hosting `mysrv.dunno.com` where the challenge-response mechanism fails to  upload the challenge-file to `fritzbox.dunno.com` (which does not serve any files).


### Conclusion
To reach IPv4 servers use the address of the fritzbox.
To reach Ipv6 servers use their global (non-ULA) IPv6 address. To get this address, I suggest to use  [`myip`](myip.md).

Of course you still may need to know the **external IPv6 of your FRITZ!Box** when wanting to connect to your box itself (e. g. for remote accessing the GUI).
