# Win10-Setup-Script
 
## Intro

 Start-Windows10InitialSetup.ps1, a Powershell script to automate and standardise the basic configuration of a PC.

 This script is intended to be used where traditional deployment & build methods such as MEMCM (MEM, SCCM, etc), Intune, MDT & others are too much overhead for the time required. Specifically within the MSP community where there are many varying clients with different hardware, software and device requirements.

 This script is intended to be run from an RMM platform. I've tested with N-Central but would welcome feedback from other platforms. To simplify deployment for those completing the device builds who may be new to scripting or the world of IT, all components are in a single script file. One file to run, no other external dependencies.

 In the original environment we had multiple build processes for each of our clients, but all of them required a similar core process. So this script was born to consolidate these core needs and provide a consistent output across the client base. Each environment has further scripts or processes which are run after this initial build, but at least we know that every box leaving our workshop is suitably configured to our basic minimum spec.

 The process for the bench tech is simple and usually takes under 5 minutes to complete:
 - Unbox the device
 - Run through OOBE
 - Install the RMM agent
 - Trigger the setup script from the RMM
 - Go and do other more interesting things while this runs

 Comments, corrections or improvements welcome

## Notes


## Examples

## Script Actions

### Preflight
- Enable Powershell transcription
- Enable Powershell module logging
- Create a checkpoint
- Create a registry backup

### Core & Security
- Enable UAC High
- Enable Windows Firewall
- Enable .NET Framework strong cryptography
- Enable the Meltdown compatibility flag
- Enable DEP opt in
- Disable Remote Assistance
- Disable auto sign-in on restart
- Disable AutoPlay
- Disable AutoRun
- Disable sharing of mapped network drives
- Disable the Windows Script Host
- Create a custom company administrator account

### Windows Defender
- Enable Windows Defender
- Enable sample submissions to Windows Defender cloud
- Enable controlled folder access
- Enable Core Isolation Memory Integrity
- Enable Windows Defender Application Guard
- Disable Microsoft account protection warnings (nag to log in with a Microsoft account)

### Privacy
- Disable Telemetry
- Disable Wi-Fi Sense
- Enable Defender SmartScreen
- Disable location services
- Disable maps updates
- Disable Microsoft Feedback
- Disable tailored experiences
- Disable the advertising ID
- Disable the Web Lang List
- Disable Error Reporting
- Disable Diagnostics Tracking

### Cortana
- Disable Cortana
- Disable web search from the Start Menu search box
- Disable online application suggestions from the Start Menu search

### Windows Update
- Set update peer-to-peer communication to internal subnet only
- Enable updating the Malicious Software Removal Tool
- Enable updating all Microsoft products
- Disable automatic restart with logged on users (we control through our RMM)
- Disable maintenance wakeup for updates (we control through our RMM)
- Disable create of Edge desktop shortcuts on update

### Online Services & Installations
(Anything that requires an internet connection to complete)
- Apply custom OEM branding
- Install 7-Zip
- Install Google Chrome Enterprise
- Install Mozilla Firefox ESR
- Install Microsoft LAPS
- Install .NET 2 & 3
- Install Dell Command Update (if the device is Dell)
- Install Microsoft Security Baselines
- Install Raccine

### Power Settings
- Enable the "ultimate" power plan (desktops)
- Disable NIC power saving (desktops)

### Network
- Set current network as private (isolated build VLAN)
- Disable internet connection sharing
- Enable auto-install of networking devices

### App Cleanup
- Uninstall Powershell v2
- Uninstall Math Recognizer
- Uninstall Hyper-V
- Uninstall OpenSSH Client
- Uninstall OpenSSH Server
- Uninstall preloaded Office UWP app
- Disable Adobe Flash
- Disable Microsoft Edge tab preload

### Miscellaneous
- Apply company asset tag as device name
- Enable WAP Push Service (required for Intune/MEM)
- Enable System Restore
- Enable NTFS long file paths
- Enable NTFS last access timestamps
- Enable Shadow Copies for OS drive
- Disable the Modern UI swap file

### User Experience
- Disable shared experiences
- Disable the Action Center
- Remove network selection from lock screen
- Remove shutdown option from lock screen
- Disable lock screen blur
- Disable search bar in taskbar
- Disable option to search for Store applications to open unknown extensions
- Disable adding "- Shortcut" to new shortcut names
- Disable full screen game optimizations
- Disable IE first run wizard
- Disable Windows First Logon animation 
- Disable media sharing
- Disable tips & tricks animations
- Enable Photo Viewer file associations
- Enable Photo Viewer open with associations
- Enable taskbar icon combine when full
- Enable Task Manager opening in detail view
- Enable showing file copy operation detail view
- Enable clipboard history
- Enable Storage Sense
- Enable NumLock on boot
- Enable enhanced pointer precision
- Enable highly detailed logon status messages
- Control Panel to open in small icon view
- Set default search engine in IE to Google
- Set visual effects for best performance

### Windows Explorer
- Disable 3D Objects folder
- Hide 3D Objects folder from "This PC"
- Disable thumbnail cache
- Disable thumbnail cache for network folders
- Show encrypted file names in colour
- Show Explorer expanded navigation pane
- Show folder merge conflicts
- Show full title path
- Show hidden files (but not protected files)
- Show known file extensions
- Open "This PC" by default

### Sounds
- Disable Windows startup sound
- Set active sound scheme to "No Sounds"

### CIS Benchmarks
- Apply CIS Benchmark configuration for:
    - Windows 10 1909
    - Microsoft Office (To Do)
    - Microsoft Edge (To Do)
    - Google Chrome (To Do)
    - Mozilla Firefox (To Do)

### More Powershell
- Set execution policy to "RemoteSigned"

### Updates & Firmware
- Apply all available Dell drivers and firmware updates
- Install Windows Updates

### Debloat
- Remove the People icon
- Disable certain scheduled tasks
    - XBox Game Save
    - XBox Logon
    - Consolidator
    - USB CEIP
    - DMClient
    - DMClient On Scenario Download
- Remove certain Start Menu pinned tiles
- Remove AppX bloatware
    - Bing News
    - Get Help
    - Get Started
    - Messaging
    - 3D Viewer
    - Office Hub
    - Solitaire Collection
    - Network Speed Test
    - Office Sway
    - OneConnect
    - People
    - Print 3D
    - Skype
    - Windows Alarms
    - Windows Camera
    - Windows Communication Apps
    - Windows Feedback Hub
    - Windows Maps
    - Windows Sound Recorder
    - Xbox App
    - Xbox TCUI
    - Xbox Game Overlay
    - Xbox Identity Provider
    - Xbox Speech to Text Overlay
    - Zune Music
    - Zune Video
    - Eclipse Manager
    - Adobe Photoshop Express
    - Duolingo
    - Pandora Media Inc
    - Candy Crush
    - Wunderlist
    - Flipboard
    - Twitter
    - Facebook
    - Spotify
- Repair necessary AppX apps
    - Paint 3D
    - Windows Calculator
    - Windows Store
    - Windows Photos
- Prevent removed AppX bloat from returning post update
- Remove registry bloat
- Clean up event logs
- Make the OS sparkle before deployment
    - Run cleanmgr
    - Purge Windows Update cache
    - Clean hidden installation files
    - Clean the prefetch
    - Flush DNS
    - Run DISM Component Cleanup
    - Delete temp files
    - Clean Google Chrome
        - Cache
        - Journal cookies
        - Entries
        - Media Cache
        - Top Sites
        - Font Cache
        - Visited links
        - Web data

### End Actions
- Remove any created variables
- Create post-script checkpoint
- Restart the device