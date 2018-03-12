# ssmon
A simple shell script to check status of ss-rule and ss-redir

WARNING: This script only tested on openwrt. DO NOT USE THIS SCRIPT ON ANOTHER LINUX SYSTEM DIRECTLY!

The script shadowsocks-ipv6 can help shadowsocks redirect ipv6 stream to ipv4 server on openwrt. The ipv4 server must have ipv6 address(like bwh1.net vps).

The shadowsocks script written by aa65535, will kill all ss-redir process when turned off without any check. I rewrite the stop script into kill by pidfile, which created when the process start.

The ssmon script is a monitor of the ss-redir and ss-rule. It will monitor the rules of shadowsocks and restore the rules when it wrong.



Copyright (C) 1996-2018 tony-cloud project <tonylu@tony-cloud.com>
