#!/bin/bash
# chmod ug+x your_shell_script.sh


# To compress:    tar -zcvf archive-name.tar.gz directory-name
# To uncompress:  tar -zxvf prog-1-jan-2005.tar.gz -C /tmp

#
# backupTargets is an array of directory names that will be backed up.  Each directory and its subdirectories will be 
# tarred and gzipped daily.
#
declare -a backupTargets=("$@")
## ie:  backupTargets+=("~/mydirectory")
## ie:  backupTargets+=("~/mydirectory/subdir")

#
# backupDirectory is the storage directory where all backup files will be dumped
# I recommend you put this script in your ~/ (home) directory or else 
# at the root of your directory where all your MUSH directories live, rather than 
# inside any particular MUSH directory.
#
# It's a good backup script script.
#
declare backupDirectory="./Backups"

#
# compilationFile is the backup compilation where all backup files are compiled, for a quick and easy offsite dump at a later time
# !!! DO NOT STORE THIS INSIDE THE backupDirectory !!!
#
declare compilationFile="./Backups.tar"

if [[ ! -d "${backupDirectory}" ]]; then
    mkdir "${backupDirectory}"
fi

if [[ ! -f "${compilationFile}" ]]; then
    tar -cf "${compilationFile}"
fi

#
# It's a good idea to back up your .ssh directory.  If you store this script at ~/ (your home)
# then you can just uncomment the next backupTargets line and it will automatically add 
# your .ssh dir to the backups.  If you store this script anywhere else you need to 
# modify the path value accordingly.  Just leave it inside parentheses because this is a bash 
# array value.
#
# backupTargets+=("./.ssh")
#
# The next backupTargets line should be uncommented and the path modified appropriately to target 
# the top level directory where your particular top level MUSH resident directory is.
#
# This should be the directory where, for example, your MUSH tar files are, your config files, 
# and whatever director/y/ies you untarred and compiled into.
#
# backupTargets+=("./your-mush-top-level-directory")
for bt in "${backupTargets[@]}"; do
    #
    # archFile is a timestamp followed by the directory name only of the entry from backupTargets that we're about to archive
    # This is a full chronoligical backup of the directory on that particular date
    #
    declare archFile="${backupDirectory}"/"$(date +%Y%m%d-%H%M).${bt##*/}.tar.gz"
    tar -zcf "${archFile}" "${bt}"
    #
    # archComp is a compilation of all the archives for that particular directory, provided for a quick and easy offsite dump at a later time
    #
    declare archComp="${backupDirectory}"/"compilation-${bt##*/}.tar"
    if [[ ! -f "${archComp}" ]]; then
        tar -cf "${archComp}"
    fi
    tar -uf "${archComp}" "${archFile}"    
done

tar -uf "${compilationFile}" "${backupDirectory}"