#!/bin/bash
trap "exit 1" TERM
export SCRIPT_PID=$$ # use 'kill -s TERM $SCRIPT_PID' to pop this from anywhere in the script

#
# You will probably need to run the following from the commandline before this script will run
#   * Do that for THIS SCRIPT ONLY!
#
# chmod 770 your_shell_script.sh
#

#####
# HOPEFULLY THIS IS THE FIRST THING YOU DO AFTER GETTING YOUR NEWLY HOSTED SERVER ONLINE, OTHERWISE IT MAY BORK SOME SETTINGS YOU SET UP
#####

#
# This particular script is tweaked for ubuntu 16 server.
# 
# BEFORE YOU BEGIN:
#   * Ensure that your network is fully and properly configured, especially your DNS.
#   * Pre-testing sudo apt-get update && sudo apt-get upgrade to see if there are any errors may be one way of doing this
#
#   * This script will pull everything you need to successfully compile PennMUSH v1.8.6rc1p1 with MySQL support enabled.
#   * This script will pull everything you need to have a lAMP (linux-based Apache MySQL Preprocessor server running
#     ** This script will install both PHP and Python as well as run the Apache Mod configurations needed to run both 
#        PHP and Python scripts as CGI Preprocessor pages.
#     ** Successfully configuring individual sites via sites-available, sites-enabled, .htaccess, and PHP or Python scripts 
#        is still up to you.
#

#
# The next line ensures that things like the mysql-server installation don't interrupt the script
# with annoying user-interactive selection menus
#
export DEBIAN_FRONTEND=noninteractive

#
# If at any time your machine gives you errors (typically on any sudo callout) "unable to resolve host <insert your machine name here>" 
# then you must edit your /etc/hosts file and add your machine name after localhost
#
# ALWAYS MAKE DAMN SURE YOU KEEP LOCALHOST AS AN ALIAS FOR 127.0.0.1
#
# The tippy-top first line of your /etc/hosts file should look something like:
# ie:  127.0.0.1 localhost myMachineName someAdditionalAlias
#

#
# If ubu16 sticks on apt-get update while trying to connect to security.ubuntu.com, then your server has a problem connecting 
# over IPv6.  This is an issue with your host or ISP so all you can really do is fix up your linux box.
#
# To do that you must:
#     sudo nano /etc/gai.conf
#   * (or whatever your favorite/installed editor is, if not nano)
#
# Under the line:  
#     # For sites which prefer IPv4 connections change the last line to
#
# Uncomment what follows by removing its # (don't remove the # in THIS file - remove the # in gai.conf)
# Change from:
#     # precedence ::ffff:0:0/96 100
# to:
#     precedence ::ffff:0:0/96 100
#
# This script will NOT attempt to auto-correct this problem for you because it does not generate any error code and that means 
# the script would have to run the "fix" up front and in all events, and it simply isn't needed in most cases.
#

#
# Run this with sudo, never as root
#
# Run this BEFORE you compile or install any MUSH/MUX platform
#

#
# The mysqlRootPass value will be injected into the MySQL/MariaDB installation at runtime.
#
# To set this value when invoking the script from commandline, call:
#   scriptName.sh -mrp=YourPass
#     OR
#   scriptName.sh --mysqlRootPass=YourPass
#
declare mysqlRootPass="mysqlRoot"
#
# The mediaWikiPass value will be injected into the MediaWiki installation at runtime.
# 
# To set this value when invoking the script from commandline, call:
#   scriptName.sh -mwp=YourPass
#     OR
#   scriptname.sh --mediaWikiPass=YourPass
#
declare mediaWikiPass="mwikiRoot"
#
# Process the CLI Parameters
#
for cliParam in "$@"; do
    #
    # $(cliParam,,) syntax converts the variable value to all lowercase
    # $(cliParam^^) syntax converts the variable value to all uppercase
    #
    #   * In this fashion parameter matching is case-insensitive
    #
    case ${cliParam,,} in
        -mrp=*|--mysqlrootpass=*)
            #
            # Need to pick parameter apart using string match specifications in your consuming function.
            #  ** Bash' native string matching/manipulation functions are quite simple:
            #      # removes the shortest match from the beginning of a string
            #      ## removes the longest match from the beginning
            #      % removes the shortest match from the end of a string
            #      %% removes the longest match from the end
            #  ***  As of 2017-08-27, https://spin.atomicobject.com/2014/02/16/bash-string-maniuplation/
            #       had some great information on Bash-native string manipulation
            #
            mysqlRootPass="${cliParam#*=}"
            shift 1
        ;;
        -mwp=*|--mediawikipass=*)
            mediaWikiPass="${cliParam#*=}"
            shift 1
        ;;
        *)
            #
            # Default case is when the CLI parameter matches no defined script parameters.
            #
            # Shift CLI Parameters array left by 1 to eliminate this value
            #
            shift 1
            echo "Invalid command line parameter:  ${cliParam%%=*}"
            exit 1
        ;;
    esac
done

# testing OS (not processor) architecture
declare osArch=$(uname -p)
if [ "${osArch##*_}" == "64" ]
then
    sudo dpkg --add-architecture i386
fi

sudo apt-get --assume-yes update
sudo apt-get --assume-yes upgrade
# if you don't have these by default, WTF?!
sudo apt-get --assume-yes install build-essential libc6-dev lib32gcc1 lib32stdc++6 
#
# the next round of installs are required for SteamCMD and some specific Steam games - they will probably be handy whether 
# you plan to host Steam games from your server or not
#
sudo apt-get --assume-yes install libvorbisfile3
#
# these are not typically installed by default on debian, maybe on some flavors of ubuntu, but are always useful
#
sudo apt-get --assume-yes install net-tools debconf-utils whois dig nmap inetutils-traceroute unzip expect curl
#
# if you're installing on a remote host and connected via SSH then, pretty obviously, you don't need the next line
# so you can safely comment it out.  you actively WANT to comment it out if you're using an SSH server other than openSSH,
# unless you want to install openSSH and remove whatever default you have installed
# if you're running debian or ubuntu then openssh is your default and the next line shouldn't hurt in either event
#
sudo apt-get --assume-yes install openssh-server openssh-client
#
# You need these for PennMUSH
#
sudo apt-get --assume-yes install openssl libssl-dev
#
# You need these for PennMUSH
#
sudo apt-get --assume-yes install libpcre3 libpcre3-dev libevent-dev
#
# Install email services
#   * You want sendmail for website fu - a LOT of pre-chewed website garbage you'll want to download and puke up on people uses it
#   * postfix is a dropin replacement for sendmail.  A LOT of discerning (smart, handsome, charming, talented) people prefer it over sendmail
#     for lots of reasons
#   * both postfix and sendmail are SMTP which is for MAIL-SENDING ONLY
#   * dovecot is for POP-3/IMAP which is for MAIL-RECEIVING
#
sudo apt-get --assume-yes install sendmail postfix postfix-mysql dovecot-core dovecot-imapd dovecot-lmtpd dovecot-mysql
    # When Postfix configuration is prompted choose Internet Site:
    # Postfix configuration will ask about System mail name – you could use your FDQN or main domain.
#
# You want python with these addons at a bare minimum
#
sudo apt-get --assume-yes install python python-pip virtualenv 
#
# Upgrade pip
#
sudo -H pip install --upgrade pip
#
# You want to be able to convert things to PDF on the server-side
#
sudo -H pip install pdfkit
sudo apt-get --assume-yes install wkhtmltopdf
#
# You want apache with these addons at a bare minimum
#
sudo apt-get --assume-yes install apache2 libapache2-mod-python libapache2-mod-php
#
# You want php with these addons at a bare minimum
#
sudo apt-get --assume-yes install php7.0 php-pear php7.0-mysql php7.0-curl php-xml
#
# You want git
#
sudo apt-get --assume-yes install git
#
# You'll want all the mysql libs to go along with these packages
#   * libmysqlclient-dev is default-libmysqlclient-dev under debian 9
#
sudo apt-get --assume-yes install mysql-client libmysqlclient-dev python-mysqldb 

#
# Apache2 config
#
sudo a2dismod mpm_event
sudo a2enmod mpm_prefork
sudo a2enmod ssl     # enable ssl security mod
sudo a2enmod headers # enable headers mod
sudo a2enmod rewrite # enable rewrite mod
sudo a2enmod cgi # enable cgi mod
sudo a2enmod python
sudo a2enmod php7.0
#
# PHP config
#
sudo phpenmod mbstring
sudo phpenmod xml

#
# Set up MySQL Server Password
#
debconf-set-selections <<< 'mariadb-server-5.5 mysql-server/root_password password ${mysqlRootPass}'
debconf-set-selections <<< 'mariadb-server-5.5 mysql-server/root_password_again password ${mysqlRootPass}'
# the next 2 lines will interrupt the hands-off installation process, prompting the user
# for a MySQL root password (twice) and then several more times
sudo apt-get --assume-yes install mysql-server


#
# script writer's recommendations for mysql_secure_installation's prompt answers:
#   First (obviously) enter your root password from when you installed mysql server
#   press N to NOT setup the VALIDATE PASSWORD plugin
#   press N to NOT change the root password (the one you already set is fine)
#   press Y to DO remove anonymous users
#   press Y to DO disallow root login remotely (you can only login from localhost, ie from the mysql app/shell, from PHP/Python/MUSH apps 
#     [not that you should ever log in as root from any app but the mysql shell app]) but the point is that the root username can only be used 
#     to log into mysql on the local system (yes you can still log in as root through SSH terminal connections - that's localhost as far as mysql 
#     is concerned - also be aware that mysql's root user and your linux box's root user are 2 different things)
#   press Y to DO remove test database and access to it (unless you're brand spanking new to MySQL and you really want or need the study material)
#   press Y to DO reload privilege tables and therefore make your changes effective as of now
#   * I'm pretty sure there's no platform where keystroke alone invokes the option - it's always Y or N followed by ENTER
#
# mysql_secure_installation

function doMySQLQuery
{
    expect -c "
    
    set timeout 10
    spawn mysql --user="root" -p -e \"$1\"

    expect \"Enter password: \"
    send \"${mysqlRootPass}\r\"

    expect eof
    "
}

echo -e '\033[1m\nRemoving root access from anywhere but localhost\n\033[0m'
doMySQLQuery "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"

echo -e '\033[1m\nDeleting anonymous user(s)\n\033[0m'
doMySQLQuery "DELETE FROM mysql.user WHERE User='';"

echo -e '\033[1m\nRemoving test/sample database\n\033[0m'
doMySQLQuery "DROP DATABASE IF EXISTS test;"

echo -e '\033[1m\nRemoving access to test/sample database\n\033[0m'
doMySQLQuery "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"

echo -e '\033[1m\nUpdating privilege tables\n\033[0m'
doMySQLQuery "FLUSH PRIVILEGES;"

#
# Create directory for PHP logs
#
if [[ ! -d "/var/log/php" ]]; then
    sudo mkdir /var/log/php
    sudo chown www-data /var/log/php
fi

#
# These packages are required by MediaWiki
#
sudo apt-get --assume-yes install imagemagick php7.0-intl php7.0-gd php7.0-mbstring php-apcu
#
# This var contains a target URL for the current (or desired) release of mediawiki
#
declare mediaWikiURL="https://releases.wikimedia.org/mediawiki/1.30/mediawiki-1.30.0.tar.gz"
#
# The path to the local directory you intend to serve your MediaWiki site/content from
#
declare localWebSiteDir="/var/www/html/mediawiki"
if [[ ! -d "${localWebSiteDir}" ]]; then
    mkdir -p "${localWebSiteDir}"
    #
    # set website directory to RWX (OWNER) RX (GROUP) RX (OTHER)
    #
    chmod 755 "${localWebSiteDir}"
fi
#
# Download the target file to /opt/filename
#
sudo wget ${mediaWikiURL} --directory-prefix=/opt/
#
# Untar the target file into the website directory
#
sudo tar -xvzf /opt/${mediaWikiURL##*/} -C ${localWebSiteDir} --strip-components=1
#
# Set directory ownership for the mediawiki directory - don't ever modify this unless Apache decides to change its user/group from www-data
#
sudo chown www-data:www-data -R ${localWebSiteDir}
#
# Create databases for mediawiki
#
doMySQLQuery "SET GLOBAL sql_mode=''"
doMySQLQuery "CREATE DATABASE IF NOT EXISTS wikidb;"
doMySQLQuery "CREATE USER IF NOT EXISTS 'wikiuser'@'localhost' IDENTIFIED BY '${mediaWikiPass}';"
doMySQLQuery "GRANT ALL PRIVILEGES ON wikidb.* TO 'wikiuser'@'localhost';"
doMySQLQuery "FLUSH PRIVILEGES;"

# restart apache2
sudo systemctl restart apache2

#
# Set any other scripts in this directory executable - assuming you didn't jump the gun and do this manually, this is a sort of "enable the next step" operation 
# that helps alert you that it's now the appropriate time to do your MU installation
#
# These lines were commented out when it was discovered that some users (even highly experienced ones) were placing these scripts in bad locations - namely at the root of 
# their home directories - or that they were running this script repeatedly, even AFTER unpacking/installing MUSH/MUX platforms in subdirectories.  Bad mojo, y'all.
#
# So only uncomment these lines before running this script if you've quite cleverly placed this script in a CONTAINED directory such as /home/myUser/MUSH and it sits 
# alongside the other scripts that were distributed with this package, !!! AND NOTHING ELSE !!!
#
# FILES=$(find ./ -name '*.sh')
# for f in ${FILES}; do
#    chmod 700 ${f}
#    echo "set +x for ${f}"
# done

#
# There are certain things some hosts don't do for you.  We need to be sure those things are done for you.
#
if [[ ! -d "/etc/skel/.ssh" ]]; then
    sudo mkdir /etc/skel/.ssh
    sudo chmod 700 /etc/skel/.ssh
fi

if [[ ! -f "/etc/skel/.ssh/authorized_keys" ]]; then
    sudo touch /etc/skel/.ssh/authorized_keys
    sudo chmod 600 /etc/skel/.ssh/authorized_keys
fi

#
# Hopefully you were wise enough to copy the doBackups.sh script into the home directory where it belongs
#
sudo cp ~/doBackups.sh /etc/skel/doBackups.sh
sudo chmod 770 /etc/skel/doBackups.sh
#
# If you use nano, and I use nano, then you need line and column numbering and it's just plain stupid to have to toggle it.  Ever.
#
if [[ ! -f "~/.nanorc" ]]; then
    echo "set constantshow" > ~/.nanorc
fi
chmod 660 ~/.nanorc
#
# And do yourself a favor since, if you're brilliant, you're probably going to run multiple user accounts for yourself to use
#
sudo cp ~/.nanorc /etc/skel/.nanorc
sudo chmod 660 /etc/skel/.nanorc

echo ""
echo -e "\033[1m${BASH_SOURCE[0]##*/} Finished!\033[0m"
echo -e "\033[1m    Your MySQL/MariaDB root password is:  ${mysqlRootPass}\033[0m"
echo -e "\033[1m    Your MediaWiki username is wikiuser and the MediaWiki password is:  ${mediaWikiPass}\033[0m"
echo ""