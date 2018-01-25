# 2017-12-25

* Changelog initiated

* After troubleshooting a Ubu16 install on DreamHost, troubleshooting notes were added in the script comments.  See also TROUBLESHOOTING.md

* After troubleshooting some user-error issues, script functions were commented out and commentation was added for usage by decommentation, if practical conventions are observed (see comments at the bottom of the script file, referring to "enable the next step" operations).

# 2017-12-28

* Added some lib32gcc compiler support installs to ubuConfig script.  Helps with 64-bit operating systems.

* Added some /etc/skel mods to the script, including a by-default .ssh folder and a copy of the doBackups script for all newly created profiles 

#2018-01-25

* Added installTinyMUX.sh to automate TinyMUX installation for Ubuntu systems with all the really useful options enabled