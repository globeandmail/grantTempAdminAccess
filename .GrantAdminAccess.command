#!/bin/bash

####
# This will elevate the current user to a local administrator on their Mac. It uses the
# CLI for the macOS-Enterprise-Privileges app to do so. The app can be found here:
# https://github.com/SAP/macOS-enterprise-privileges
####
# version 1.2
# Created by Nathan Beranger, August, 2018
####

## Echo all commands
set -x

## Send all output to the file 'grantAdmin.log'
#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3
#exec 1> /Users/Shared/grantAdmin.log 2>&1

## Command to grant admin privileges to current user
/Applications/Utilities/Privileges.app/Contents/Resources/PrivilegesCLI --add

confirmation=$( osascript -e "display dialog \"You have now been granted local admin privileges on your Mac.

These privileges will be revoked in 10 minutes, or if you log out of your account.\" buttons {\"OK\"} default button {\"OK\"}" )

theButton2=$( echo "$confirmation" | awk -F "button returned:|," '{print $2}' )
echo "$theButton2"

## Variable for storing the current users name
currentuser=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

## Variable for storing current user's UID
currentUID=$(id -u "$currentuser")

## Copy removeAdminAccess.plist to ~/Library/LaunchAgents, ensure current user is owner, that permissions are rw-r-r, and then load agent
cp /usr/local/.Privileges/Agents/.com.globeandmail.removeAdminAccess.plist /Users/"$currentuser"/Library/LaunchAgents/com.globeandmail.removeAdminAccess.plist
chown "$currentuser":staff /Users/"$currentuser"/Library/LaunchAgents/com.globeandmail.removeAdminAccess.plist
chmod 644 /Users/"$currentuser"/Library/LaunchAgents/com.globeandmail.removeAdminAccess.plist

## Load removeAdminAccess launch agent into system
launchctl bootstrap gui/"$currentUID" /Users/"$currentuser"/Library/LaunchAgents/com.globeandmail.removeAdminAccess.plist

rm -rf /Users/"$currentuser"/Library/LaunchAgents/com.globeandmail.grantAdminAccess.plist

exit