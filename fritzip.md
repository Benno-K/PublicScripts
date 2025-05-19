# Get your FRITZ!Box's external IP-address<br/>fritzip

You can simple use `fritzip` to get the external IP-address of your FRITZ!Box. It must be configured to answer UPNP requests, which is the default  but may have been disabled by some paranoid FRITZ!Box admin.

## Commands to use

Use `fritzip -4` to get the IPv4 address. Use `fritzip -6` to get the IPv6 address.

## Possible sources of confusion
If you only have the good old IP Version 4 running on your system you *can stop to read* at this point.

Running a dual-IP-stack[^1] computer behind a dual-stack FRITZ!Box one might get confused about the external addresses.
[^1]: Dual stack means the device runs both internet protocol stacks at the same time and is therefore reachable by it's IPv4 address as well as by it's IPv6 address.

For **IPv4** the external address of *any internal server* is **identical** to *the fritzbox*.
The reason for this is that one only gets **one single** IPv4 per connection, so network address translation (NAT) is done by the router forwarding the traffic to the internal servers.

For **IPv6** the external address(es) of *your internal servers* do **differ** from *the fritzbox*.
The reason for that is that one gets **a range of** IPv6 per connection, so the router can forward the traffic directly to the internal server(s).
### Conclusion
To reach IPv4 servers use the address of the box.
To reach Ipv6 servers use their global (non-ULA) IPv6 address. To get this address, I suggest to use  [`myip`](myip.md).

Of course you still may need to know the **external IPv6 of your FRITZ!Box** when wanting to connect to your box itself (e. g. for remote accessing the GUI).
