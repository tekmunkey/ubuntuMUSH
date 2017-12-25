# ubuntuMUSH Script Troubleshooting

## Linux error:  unable to resolve host *<machineNameHere>*

If at any time your machine gives you errors (typically on any sudo callout) "unable to resolve host <insert your machine name here>" then you must edit your /etc/hosts file and add your machine name after localhost

ALWAYS MAKE DAMN SURE YOU KEEP LOCALHOST AS AN ALIAS FOR 127.0.0.1

The tippy-top first line of your /etc/hosts file should look something like:

```
    127.0.0.1 localhost myMachineName someAdditionalAlias
```

## sudo apt-get update hangs at 0%


If ubu16 sticks on apt-get update while trying to connect to security.ubuntu.com, then your server has a problem connecting over IPv6.  This is an issue with your host or ISP so all you can really do is fix up your linux box.

To do that you must:

```
sudo nano /etc/gai.conf
  * (or whatever your favorite/installed editor is, if not nano)

Under the line:  
  # For sites which prefer IPv4 connections change the last line to

Uncomment what follows by removing its #
  From:
    # precedence ::ffff:0:0/96 100
  To:
    precedence ::ffff:0:0/96 100

This script will NOT attempt to auto-correct this problem for you because it does not generate any error code and that means the script would have to run the "fix" up front and in all events, and it simply isn't needed in MOST cases.  IPv4 is already obsolete as of this writing (and frankly was at the point where they realized IPv6 was needed, in the first place).
```