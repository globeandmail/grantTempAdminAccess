#!/bin/bash

####
# This will remove local administrator for the current user on their Mac. It uses the
# CLI for the macOS-Enterprise-Privileges app to do so. The app can be found here:
# https://github.com/SAP/macOS-enterprise-privileges
####
# version 1.2
# Created by Nathan Beranger, August, 2018
####

## Echo all commands
set -x

## Send all output to the file 'removeLoginAdmin.log'
#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3
#exec 1> /Users/Shared/removeLoginAdmin.log 2>&1

## Variable for storing the current users name
currentuser=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

/Applications/Utilities/Privileges.app/Contents/Resources/PrivilegesCLI --remove

## Stop, remove, and delete grantAdminAccess Launchagent from system
rm -rf /Users/"$currentuser"/Library/LaunchAgents/com.globeandmail.grantAdminAccess.plist
launchctl stop com.globeandmail.grantAdminAccess
launchctl remove com.globeandmail.grantAdminAccess

## Stop, remove, and delete removeAdminAccess and logineRemoveAdminAccess Launchagents from system
rm -rf /Users/"$currentuser"/Library/LaunchAgents/com.globeandmail.logineRemoveAdminAccess.plist
rm -rf /Users/"$currentuser"/Library/LaunchAgents/com.globeandmail.removeAdminAccess.plist
launchctl stop com.globeandmail.removeAdminAccess
launchctl remove com.globeandmail.removeAdminAccess

exit