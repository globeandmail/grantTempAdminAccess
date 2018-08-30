# grantTempAdminAccess
Leveraging rtrouton's Privileges app, this Jamf Self Service workflow will give user local admin access on their Mac for a limited amount of time.

Currently the time limit is set to 10 minutes. Admin access will be removed when either the time expires, or if the user logs out/reboots.

There are four scripts, and 3 launch agents required, along with rtrouton's Privileges app:
https://github.com/SAP/macOS-enterprise-privileges
There are also two policies that need to be configured in Jamf Pro, and a custom PKG that needs to be created.

The first policy in Jamf Pro is called "Install Admin Privileges App". This will do the following:
- Install the Privileges app and place the launch agents and scripts on the end user's Mac
- Call the policy "Grant Temp Admin Access"

The seoncd policy in Jamf Pro is called "Grant Temp Admin Access", which runs the script "GrantTempAdminAccess.sh".
This script will do the following:
 - Determine the current local user
 - Copy the grantAdminAccess and loginRemoveAdminAccess launch agents to ~/Library/LaunchAgents/
 - Load the grantAdminAccess launch agent to the system

When the grantAdminLaunch agent is loaded, it will do the following:
- Using the CLI of the Privileges app, gives the current user temporary local administrator access
- Display an onscreen pop-up telling the users that their account has been elevated to an admin account for 10 minutes, or until they log out
- Copy the removeAdminAccess launch agent to ~/Library/LaunchAgents/
- Load the removeAdminAccess launch agent to the system
- Deletes the grantAdminAccess launch agent from ~/Library/LaunchAgents/

Once the grantAdminLaunch agent is loaded, it performs the following:
- Stops, and removes from the system, the grantAdminAccess launch agent
- Using the CLI of the Privileges app, removes local administrator access from the user
- Display an onscreen pop-up informing the user that the time limit for their administrator access has been removed
- Deletes, stops, and removes from the system the loginRemoveAdminAccess and removeAdminAccess launch agents

If the user tries logging out / rebotting their system while they have admin access, the loginRemoveAdminAccess launch agent will run on their next login. This will execute the removeLoginAdminAccess script, which does the following:
- Using the CLI of the Privileges app, removes local administrator access from the user
- Deletes, stops, and removes from the system the grantAdminAccess, loginRemoveAdminAccess, and removeAdminAccess launch agents

**Unlike the RemoveAdminAccess script, there is no pop-up for the end user informing them that admin privileges have been revoked by the removeLoginAdminAcess script**

Creating your AdminPrivileges.pkg
(I like to use Packages by WhiteBox: http://s.sudre.free.fr/Software/Packages/about.html)
You will need to create a custom PKG, which will place these files into the following directories:
- /Applications/Utilities/Privileges.app
- /Usr/Local/.Privileges/Agents/.com.globeandmail.grantAdminAccess.plist
- /Usr/Local/.Privileges/Agents/.com.globeandmail.loginRemoveAdminAccess.plist
- /Usr/Local/.Privileges/Agents/.com.globeandmail.removeAdminAccess.plist
- /Usr/Local/.Privileges/Scripts/.GrantAdminAccess.command
- /Usr/Local/.Privileges/Scripts/.RemoveAdminAccess.command
- /Usr/Local/.Privileges/Scripts/.removeLoginAdminAccess.command
You will also want to have your PKG run the privilegesPostInstall.sh script

Jamf Pro Workflow
Script:
- Copy the GrantTempAdminAccess script into Jamf Pro

Smart Computer Group:
- Create a smart computer group that checks to see if the "Privileges.app" is installed

There are two policies you need to configure in Jamf Pro

First policy, "Install Admin Privileges App":
- Under "General" payload, enter the policy name and set the execution frequency to once per computer
- Add the AdminPrivileges.pkg that you created earlier to the "Packages" payload
- Set the "Maintenance" payload to update inventory
- Set the "Files and Processes" payload to run the command: /usr/local/bin/jamf policy -event RunGrantTempAdminAccessScript
- Scope the policy how you would like it
- Make the policy available in Self Service

Second policy, "Grant Temp Admin Access":
- Under "General" payload, enter the policy name, set the execution frequency to ongoing, and set the trigger to custom. The custom event will be: RunGrantTempAdminAccessScript (I also have set this policy to "Make Available Offline", but this is optional)
- Under the "Scripts" payload, select the GrantTempAdminAccess script and set the priority to after
- Scope this policy to the smart group you created earlier (the one that looks for the Privileges.app)
- Make the policy available in Self Service
