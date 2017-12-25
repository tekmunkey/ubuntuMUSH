#!/bin/bash
trap "exit 1" TERM
export SCRIPT_PID=$$ # use 'kill -s TERM $SCRIPT_PID' to pop this from anywhere in the script

#
# You will probably need to run the following from the commandline before this script will run
#   * Do that for THIS SCRIPT ONLY!
#
# chmod ug+x your_shell_script.sh
#

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
# Run this BEFORE you compile or install PennMUSH 1.8.6p1rc1
#
sudo apt-get --assume-yes update
sudo apt-get --assume-yes upgrade
# if you don't have these by default, WTF?!
sudo apt-get --assume-yes install build-essential libc6-dev
# these are not typically installed by default on debian, maybe on some flavors of ubuntu, but are always useful
sudo apt-get --assume-yes install net-tools debconf-utils
# if you're installing on a remote host and connected via SSH then, pretty obviously, you don't need the next line
# so you can safely comment it out.  you actively WANT to comment it out if you're using an SSH server other than openSSH,
# unless you want to install openSSH and remove whatever default you have installed
# if you're running debian or ubuntu then openssh is your default and the next line shouldn't hurt in either event
sudo apt-get --assume-yes install openssh-server openssh-client
# You need these for PennMUSH
sudo apt-get --assume-yes install openssl libssl-dev
# You need these for PennMUSH
sudo apt-get --assume-yes install libpcre3 libpcre3-dev libevent-dev
# You want sendmail for website fu
sudo apt-get --assume-yes install sendmail
# You want python with these addons at a bare minimum
sudo apt-get --assume-yes install python python-pip virtualenv
# You want apache with these addons at a bare minimum
sudo apt-get --assume-yes install apache2 libapache2-mod-python
# You want git
sudo apt-get --assume-yes install git
# does mysql server need to be installed before the clients?  i suspect not
sudo apt-get --assume-yes install mysql-client libmysqlclient-dev python-mysqldb php7.0 php-pear php7.0-mysql
#
# Apache2 config
#
sudo a2dismod mpm_event
sudo a2enmod mpm_prefork
sudo a2enmod headers # enable headers mod
sudo a2enmod rewrite # enable rewrite mod
sudo a2enmod cgi # enable cgi mod
sudo a2enmod python

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
mysql_secure_installation

if [[ ! -d "/var/log/php" ]]; then
    sudo mkdir /var/log/php
    sudo chown www-data /var/log/php
fi

# restart apache2
sudo systemctl restart apache2

#
# Finally, set any other scripts in this directory executable - assuming you didn't jump the gun and do this manually, this is a sort of "enable the next step" operation 
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
#    chmod ug+x ${f}
#    echo "set +x for ${f}"
# done