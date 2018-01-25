#!/bin/bash
trap "exit 1" TERM
export SCRIPT_PID=$$ # use 'kill -s TERM $SCRIPT_PID' to pop this from anywhere in the script

######!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!######
#####                                                                                                    #####
#####       DO NOT RUN THIS SCRIPT UNLESS YOU ALREADY RAN AN OPERATING SYSTEM CONFIGURATION SCRIPT       #####
#####          THIS SCRIPT RELIES ON THE PRE-INSTALLATION AND CONFIGURATION OF REQUIRED PACKAGES         #####
#####                                                                                                    #####
######!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!######

#
# These variables SHOULD work for debian and ubuntu - ie: debian base OSes with MySQL/Maria ie: MysQL base DBs
#
declare dbConfig="/usr/bin/mysql_config"
declare dbInc="$(${dbConfig} --variable=pkgincludedir)"
declare dbLib="$(${dbConfig} --variable=pkglibdir)"

#
# Change the following value to whatever you want your game directory to be
#   When you uncomment a desired platform unpacker below, it will automagically unpack into this directory name
#   beneath whatever directory you're in now.
#   * Avoid spaces, backslashes, forwardslashes, question marks, and don't put a dot as the first character.
#     Generally speaking, know the rules and best practices for directory names in Linux
#   * DO NOT ADD ./ TO THIS STRING - the script automatically adds this value
#
#   Only change the part inside quotation marks :-)
#
declare gameDirectory="tinymux210"
#
# Change the following value to the filename of whatever package you downloaded.  This value is whatever immediately precedes the 
# .tar.gz in what you downloaded from the public/anonymous FTP Server at tinymux.org
#
declare packageName="mux-2.10.1.14.unix"

# The if statement is needed to ensure that the directory exists
# yes, Comic Book Guy, I could mkdir -p && tar -xf on one line below, but:
#   1:  At some future point I (or some other consumer) may want to add additional steps if/when the directory doesn't already exist
#   2:  Most folks who want to start up a MUSH are artists and writers, not geeks.
#       As mush platforms update and .tar filenames change, this script needs to be easily updateable and as non-intimidating as possible 
#       so I'm keeping eldritch runes and codey scripture to a minimum
if [[ ! -d "./${gameDirectory}" ]]; then
    mkdir "./${gameDirectory}"
    chmod 700 "./${gameDirectory}"
fi

# I assume that you downloaded the TinyMUX 2.10.1.14 archive from the tinymux.org public/anonymous ftp server
gunzip "./${packageName}.tar.gz"
# The next line untars our archive file
# the .tar is the file in question
# the -C and its following parameter is our target directory
# --strip-components=1 allows renaming of the "default" directory that the platform devs crammed in there when they tarballed it in the first place
tar -xf "./${packageName}.tar" -C "./${gameDirectory}" --strip-components=1
# move our working directory into the game directory
cd "./${gameDirectory}/src"
#
# Install TinyMUX with
#   * Reality Levels, WoD Realms, Inline AND Async SQL Enabled
#
./configure --enable-realitylvls --enable-wodrealms --enable-inlinesql --enable-stubslave --with-mysql-include="${dbInc}" --with-mysql-libs="${dbLib}"
make depend
make
cd ./modules
./configure
make
# return to where this script resides
cd ../../..