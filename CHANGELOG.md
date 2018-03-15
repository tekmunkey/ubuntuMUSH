# 2017-12-25

* Changelog initiated

* After troubleshooting a Ubu16 install on DreamHost, troubleshooting notes were added in the script comments.  See also TROUBLESHOOTING.md

* After troubleshooting some user-error issues, script functions were commented out and commentation was added for usage by decommentation, if practical conventions are observed (see comments at the bottom of the script file, referring to "enable the next step" operations).

# 2017-12-28

* Added some lib32gcc compiler support installs to ubuConfig script.  Helps with 64-bit operating systems.

* Added some /etc/skel mods to the script, including a by-default .ssh folder and a copy of the doBackups script for all newly created profiles 

# 2018-01-25

* Added installTinyMUX.sh to automate TinyMUX installation for Ubuntu systems with all the really useful options enabled

# 2018-03-10

* Converted MySQL/MariaDB installation to fully automated via debconf and CLI parameters.  User may pass -mrp=YourMySQLRootPassword or --mySQLRootPassword=YourMySQLRootPassword from the commandline to set up a custom root password for MySQL at runtime.  The default value is 'mysqlRoot' - the script will inform the user of exactly what the MySQL Root Password is when complete.

* Replaced mysql_secure_installation with bash/expect routines into the mysql CLI client, sending the relevant queries.  This eliminates automation-breaking user prompts.

* Added MediaWiki v1.30.0 installation w/prerequisites.  Verified functional.  After the script runs users should be able to browse to http://Server.IP.Address.Here/mediawiki 

# 2018-03-15

* Added muDBSchema, muDBUser, and muDBPass variables and corresponding CLI parameters for -mus=SchemaName, -muu=UserName, -mup=UserPassword which creates a MySQL Database and sets up a privileged User with the specified password.  The script will inform the user of exactly what these values are (Schema, Username, Password) when complete.

* Added randPass() function to script, which allows better/more secure default password values.  Default passwords for MySQL Root, MU DB User, and MediaWiki Admin are now randomly generated for each script run.  Values may still be overridden by CLI Parameters and the old (simplified) passwords are still there - you can always comment out the single line values that call on the randPass generator to keep the simple default passwords.