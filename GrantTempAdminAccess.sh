#!/bin/bash

####
# Copies grantAdminAccess.plist and removeAdminAccess.plist files to
# ~/Library/Launchagents/, and then loads the grantAdminAcess.plist into the system
####
# version 1.2
# Created by Nathan Beranger, August 2018
####

## Echo all commands and results as they run
set -x

## Variable for storing the current users name
currentuser=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

## Variable for storing current user's UID
currentUID=$(id -u "$currentuser")

## Copy plist files to the ~/Library/LaunchAgents/ folder, ensure current user is owner, and that permissions are rw-r-r
cp /usr/local/.Privileges/Agents/.com.globeandmail.grantAdminAccess.plist /Users/"$currentuser"/Library/LaunchAgents/com.globeandmail.grantAdminAccess.plist
chown "$currentuser":staff /Users/"$currentuser"/Library/LaunchAgents/com.globeandmail.grantAdminAccess.plist
chmod 644 /Users/"$currentuser"/Library/LaunchAgents/com.globeandmail.grantAdminAccess.plist

cp /usr/local/.Privileges/Agents/.com.globeandmail.loginRemoveAdminAccess.plist /Users/"$currentuser"/Library/LaunchAgents/com.globeandmail.loginRemoveAdminAccess.plist
chown "$currentuser":staff /Users/"$currentuser"/Library/LaunchAgents/com.globeandmail.loginRemoveAdminAccess.plist
chmod 644 /Users/"$currentuser"/Library/LaunchAgents/com.globeandmail.loginRemoveAdminAccess.plis

echo "pausing for 2 seconds to ensure files have copied over"

sleep 2

## Load grantAdminAccess launch agent to system
launchctl bootstrap gui/"$currentUID" /Users/"$currentuser"/Library/LaunchAgents/com.globeandmail.grantAdminAccess.plist

exit