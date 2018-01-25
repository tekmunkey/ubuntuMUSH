# Support tekmunkey via Patreon

If you'd like to support my free software developments, my patreon can be found at:

https://www.patreon.com/tekmunkey

# ubuntuMUSH

The documentation on this product is best viewed inside the scripts themselves, though it is a bit sparse.

Create a directory such as ~/MUSH

Put this repo in that directory along with your .tar.gz distro file(s).  Make sure whatever MUSH/MUX platforms you downloaded from github or FTP sites match the filenames in these scripts (as defined on line 34 of each script, after the = and between double quotes).  If they don't match, then change the value between the double quotes to match the filename.

At the commandline:

run:  chmod ug+x ubuConfig.sh

run:  ./ubuConfig.sh

The script should install all needed packages and set the other scripts +x

run:  chmod ug+x ubuConfig.sh

run:  ./installPennMUSH.sh

Rename the myPenn-186 directory to whatever you want it to be.

Edit ~/doBackups.sh - READ THE DOCUMENTATION IN THAT FILE CAREFULLY - and add your ~/MUSH and maybe your ~/.ssh directories to the backupTargets array.

run:  cron -e

Add ~/doBackups.sh to a weekly backup (or however often you want to back up).

Add @reboot ~/MUSH/myMUSHDir/game/restart anywhere on its own line to start your MUSH when the server starts up

That's it!

At some point I may have time to go in and document each package installation but honestly it's pretty murky water.  PennMUSH's documentation really sucks.  They vaguely hint at what's required, their hints are outdated where they aren't outright wrong or completely missing, and several of the installed packages were determined by troubleshooting actual compile-time errors as opposed to translating Penn documentation into modernized Ubuntu 16 package names.  By the time I had figured out what package was required, in some cases, I had already forgotten exactly why.

