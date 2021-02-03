<#
    .SYNOPSIS
    Standardised setup script to ensure all new computers are identical on build. 

    .SYNTAX
    Start-Windows10InitialSetup.ps1 [-logFile <String>] [-assetId <String>]

    .DESCRIPTION
    Configures a Windows 10 installation to a set of standard build requirements.
    Includes CIS benchmark level 1 compliance, application installs, MSP OEM branding.

    .PARAMETER logFile
    Optional. System.String.
    Path for the output logfile.
    If not specified, output path will default to C:\Windows\Temp\

    .PARAMETER assetID
    Optional. System.String
    If specified, this asset ID will be used to name and brand the device

    .EXAMPLE
    Start-Windows10InitialSetup.ps1 -assetId "00123"
    Starts the setup process and names the device as 00123

    .LINK
    https://github.com/Sycnex/Windows10Debloater (some inspiration from)

    .NOTES
    Author:               		Joe Howard (https://github.com/LinealJoe)
    Date:                  		22/12/2020

    This script is my own work, and heavily includes or references the work of others.
    Where the work of others is either used or reference, attribution is included where the source is known.

    To Do:
        Swap out the repeated functions for custom classes and reduce function calls with a big foreach.
        HTML report output options to show success/failures

    Changes:
        Anonymised and removed custom branding from employer for pulic sharing
        Added file system cleanup, registry backup stages
        Added checkpoint creation prior to starting & post completion
        Added all Windows 10 debloater script functions 
        Added Windows Updates, Start Menu Tile unpinning
        Initial version
#>

#Requires -RunAsAdministrator

[CmdletBinding(SupportsShouldProcess)]
Param (
    [STRING]$logFile,
    [STRING]$assetID
)



#
# DEFINE FUNCTIONS
#


#
# BASIC FUNCTION TEMPLATE
#

Function New-TemplateFunction {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = ""
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName"
    }
    Process {
        try {
            # Workload here 
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : $stepName"
        Write-Host "END STEP: $global:stepNumber : $stepName" 
        $global:stepNumber++
        Remove-Variable -Name $stepName
    }
}










# GENERAL FUNCTIONS

Function Write-Log {
    <# 
    .Synopsis 
    Write-Log writes a message to a specified log file with the current time stamp. 

    .DESCRIPTION 
    The Write-Log function is designed to add logging capability to other scripts. 
    In addition to writing output and/or verbose you can write to a log file for 
    later debugging. 

    .NOTES 
    Created by: Jason Wasser @wasserja 
    Modified: 11/24/2015 09:30:19 AM   
    
    Changelog: 
        * Code simplification and clarification - thanks to @juneb_get_help 
        * Added documentation. 
        * Renamed LogPath parameter to Path to keep it standard - thanks to @JeffHicks 
        * Revised the Force switch to work as it should - thanks to @JeffHicks 
    
    To Do: 
        * Add error handling if trying to create a log file in a inaccessible location. 
        * Add ability to write $Message to $Verbose or $Error pipelines to eliminate 
        duplicates. 

    .PARAMETER Message 
    Message is the content that you wish to add to the log file.  

    .PARAMETER Path 
    The path to the log file to which you would like to write. By default the function will  
    create the path and file if it does not exist.  

    .PARAMETER Level 
    Specify the criticality of the log information being written to the log (i.e. Error, Warning, Informational) 

    .PARAMETER NoClobber 
    Use NoClobber if you do not wish to overwrite an existing file. 

    .EXAMPLE 
    Write-Log -Message 'Log message'  
    Writes the message to c:\Logs\PowerShellLog.log. 

    .EXAMPLE 
    Write-Log -Message 'Restarting Server.' -Path c:\Logs\Scriptoutput.log 
    Writes the content to the specified log file and creates the path and file specified.  

    .EXAMPLE 
    Write-Log -Message 'Folder does not exist.' -Path c:\Logs\Script.log -Level Error 
    Writes the message to the specified log file as an error message, and writes the message to the error pipeline. 

    .LINK 
    https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0 

    #>

    [CmdletBinding()]
    Param ( 
        [Parameter(Mandatory=$true, 
                   ValueFromPipelineByPropertyName=$true)] 
        [ValidateNotNullOrEmpty()] 
        [Alias("LogContent")] 
        [string]$Message, 
 
        [Parameter(Mandatory=$false)] 
        [Alias('LogPath')] 
        [string]$Path='C:\Logs\PowerShellLog.log', 
         
        [Parameter(Mandatory=$false)] 
        [ValidateSet("Error","Warn","Info")] 
        [string]$Level="Info", 
         
        [Parameter(Mandatory=$false)] 
        [switch]$NoClobber 
    ) 
 
    Begin { 
        # Set VerbosePreference to Continue so that verbose messages are displayed. 
        $VerbosePreference = 'Continue' 
    } 
    Process { 
         
        # If the file already exists and NoClobber was specified, do not write to the log. 
        if ((Test-Path $Path) -AND $NoClobber) { 
            Write-Error "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name." 
            Return 
            } 
 
        # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path. 
        elseif (!(Test-Path $Path)) { 
            Write-Verbose "Creating $Path." 
            $NewLogFile = New-Item $Path -Force -ItemType File 
            } 
 
        else { 
            # Nothing to see here yet. 
            } 
 
        # Format Date for our Log File 
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss" 
 
        # Write message to error, warning, or verbose pipeline and specify $LevelText 
        switch ($Level) { 
            'Error' { 
                Write-Error $Message 
                $LevelText = 'ERROR:' 
                } 
            'Warn' { 
                Write-Warning $Message 
                $LevelText = 'WARNING:' 
                } 
            'Info' { 
                Write-Verbose $Message 
                $LevelText = 'INFO:' 
                } 
            } 
         
        # Write log entry to $Path 
        "$FormattedDate $LevelText $Message" | Out-File -FilePath $Path -Append 
    } 
    End { 

    } 
}

Function Set-ConsoleWindowSize {
    [CmdletBinding()]
    Param ()
    Begin {

    }
    Process {
        # Make the window wide enough the our lovely ASCII logo
        # https://www.nsoftware.com/kb/articles/powershell-server-changing-terminal-width.rst
        $pshost = Get-Host              # Get the PowerShell Host.
        $pswindow = $pshost.UI.RawUI    # Get the PowerShell Host's UI.

        $newsize = $pswindow.BufferSize # Get the UI's current Buffer Size.
        $newsize.width = 200            # Set the new buffer's width to 200 columns.
        $pswindow.buffersize = $newsize # Set the new Buffer Size as active.

        $newsize = $pswindow.windowsize # Get the UI's current Window Size.
        $newsize.width = 200            # Set the new Window Width to 200 columns.
        $pswindow.windowsize = $newsize # Set the new Window Size as active.
    }
    End {

    }
}

Function New-Hashline {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True)][INT]$lineLength
    )
    # Set hashline to empty
    [STRING]$hashLine = ""
    [INT]$i = 0
    [STRING]$hashChar = "`#"

    for ($i = 0; $i -le $lineLength; $i++){
        $hashLine += $hashChar
    }

    return $hashLine
}

# Customise to your own brandin if desired
Function Set-DisplayHeader {
    [CmdletBinding()]
    Param ()
    Begin {
        $logoAscii = @'
        
'@

        [STRING]$scriptTitle = "WINDOWS 10: (COMPANYNAME) INITIAL SETUP SCRIPT"
        [STRING]$date = Get-Date -UFormat "%A %m/%d/%Y %R"
        [STRING]$computer = $env:Hostname
        [IPADDRESS]$start
        [STRING]$hashline
    }
    Process {
        # First, write it all to screen
        Write-Host $logoAscii -ForegroundColor DarkBlue
        Write-Host "`n"
        Write-Host $(New-Hashline -LineLength $scriptTitle.Length) -ForegroundColor Green
        Write-Host $scriptTitle -ForegroundColor Green
        Write-Host "`n"
        Write-Host "Script Start Time:" -ForegroundColor Green
        Write-Host "`t`t $date" -ForegroundColor Yellow
        Write-Host "`n"
        Write-Host "Computer Name:" -ForegroundColor Green
        Write-Host "`t`t $computer" -ForegroundColor Yellow
        Write-Host "`n"
        Write-Host "Log File:" -ForegroundColor Green
        Write-Host "`t`t $global:logFile" -ForegroundColor Yellow
        Write-Host "`n"
        Write-Host "Contact Information:" -ForegroundColor Green
        Write-Host "`t`t Phone: `t 11111 111 111" -ForegroundColor Yellow
        Write-Host "`t`t E-Mail: `t help@companyname.tld" -ForegroundColor Yellow
        Write-Host "`t`t Web: `t www.companyname.tld" -ForegroundColour Yellow
        Write-Host "`n"
        Write-Host "Author:" -ForegroundColour Green
        Write-Host "`t`t Joe Howard" -ForegroundColor Yellow
        Write-Host "`n"
        Write-Host $(New-Hashline -LineLength $scriptTitle.Length) -ForegroundColor Green

        # Then, write it all to the log file
        Write-Log -Path $global:logFile -Level Info -Message $logoAscii
        Write-Log -Path $global:logFile -Level Info -Message "`n"
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength $scriptTitle.Length)
        Write-Log -Path $global:logFile -Level Info -Message $scriptTitle
        Write-Log -Path $global:logFile -Level Info -Message "`n"
        Write-Log -Path $global:logFile -Level Info -Message "Script Start Time: $date"
        Write-Log -Path $global:logFile -Level Info -Message "Computer Name: $computer"
        Write-Log -Path $global:logFile -Level Info -Message "`n"
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength $scriptTitle.Length)
        Write-Log -Path $global:logFile -Level Info -Message "`n"
        Write-Log -Path $global:logFile -Level Info -Message "`n"
    }
    End {
        # Nothing to do here
    }
}

Function Remove-Variables {
    [CmdletBinding()]
    Param ()
    try {
        # Try the thing
            # Cleanup time! 
            # Dirty, dirty method to cleanup all created non-system variables 
            # First, create a new Powershell session
            $posh = [PowerShell]::Create()
            # Then get all the variables which are present by default
            $posh.AddScript('Get-Variable | Select-Object -ExpandProperty Name') | Out-Null
            # Grab those values
            $builtIn = $posh.Invoke()
            # More cleanup
            $posh.Dispose()
            # If running this script from the (deprecated) Powershell ISE, this won't ruin your day
            $builtIn += "profile","psISE","psUnsupportedConsoleApplications" 
            # Remove everything that doesn't match the collected defaults
            Remove-Variable (Get-Variable | Select-Object -ExpandProperty Name | Where-Object {$builtIn -NotContains $_})
    }
    catch {
        Write-Host $PSItem.Exception.Message
        Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
    }
    finally {
        $Error.Clear | Out-Null
    }
}

Function Update-KeyForAllUsers {
    # Source: https://www.checkyourlogs.net/powershell-updating-the-default-and-all-user-profiles-registry/
    # Applies a registry based HKCU change to all users, including the default user for future logonss
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [STRING]$registryKeyPath,
        [STRING]$registryKeyName,
        $registryKeyValue,
        [STRING]$registryKeyType,
        [ValidateSet("Add","Update","Remove")][STRING]$action
    )
    Begin {
    }
    Process {
        try {
            Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 20)
            # Get each user profile SID and Path to the profile
            $UserProfiles = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*" | Where-Object {$_.PSChildName -match "S-1-5-21-(\d+-?){4}$" } | Select-Object @{Name="SID"; Expression={$_.PSChildName}}, @{Name="UserHive";Expression={"$($_.ProfileImagePath)\NTuser.dat"}}
            Write-Log -Path $global:logFile -Level Info -Message "Enumerating user profile SIDs: $UserProfiles"
            
            # Add in the .DEFAULT User Profile
            Write-Log -Path $global:logFile -Level Info -Message "Enumerating .Default user profile"
            $DefaultProfile = "" | Select-Object SID, UserHive
            $DefaultProfile.SID = ".DEFAULT"
            $DefaultProfile.Userhive = "C:\Users\Public\NTuser.dat"
            $UserProfiles += $DefaultProfile
            

            # Loop through each profile on the machine
            foreach ($UserProfile in $UserProfiles) {
                # Load User ntuser.dat if it's not already loaded
                if (($ProfileWasLoaded = Test-Path Registry::HKEY_USERS\$($UserProfile.SID)) -eq $false){
                    Start-Process -FilePath "CMD.EXE" -ArgumentList "/C REG.EXE LOAD HKU\$($UserProfile.SID) $($UserProfile.UserHive)" -Wait -WindowStyle Hidden
                    Write-Log -Path $global:logFile -Level Info -Message "LOADING HIVE for USER: $($UserProfile.SID)"
                }

                # Manipulate the registry
                if ($action -eq "Add"){
                    Write-Log -Path $global:logFile -Level Info -Message "PROFILE ACTION: ADD"
                    if (!(Test-Path -Path $registryKeyPath)){
                        New-Item -Path $registryKeyPath -Force | Out-Null
                        Write-Log -Path $global:logFile -Level Info -Message "CREATED: $registryKeyPath"
                    }
                    Set-ItemProperty -Path $registryKeyPath -Name $registryKeyName -Type $registryKeyType -Value $registryKeyValue
                    Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: $registryKeyPath\$registryKeyName, $registryKeyValue"
                    
                } elseif ($action -eq "Update"){
                    Write-Log -Path $global:logFile -Level Info -Message "PROFILE ACTION: UPDATE"
                    if (!(Test-Path -Path $registryKeyPath)){
                        New-Item -Path $registryKeyPath -Force | Out-Null
                        Write-Log -Path $global:logFile -Level Info -Message "CREATED: $registryKeyPath"
                    }
                    Set-ItemProperty -Path $registryKeyPath -Name $registryKeyName -Type $registryKeyType -Value $registryKeyValue
                    Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: $registryKeyPath\$registryKeyName, $registryKeyValue"

                } elseif ($action -eq "Remove"){
                    Write-Log -Path $global:logFile -Level Info -Message "PROFILE ACTION: REMOVE"
                    if (!(Test-Path -Path $registryKeyPath)){
                        Write-Log -Path $global:logFile -Level Warning -Message "ERROR: Registry Key $registryKeyPath could not be found. Nothing to remove."
                        Break
                    }
                    Remove-ItemProperty -Path $registryKeyPath -Name $registryKeyName
                    Write-Log -Path $global:logFile -Level Warning -Message "REMOVED: $registryKeyPath\$registryKeyName"
            
                }

                # Unload NTuser.dat        
                if ($ProfileWasLoaded -eq $false){
                    [gc]::Collect()
                    Start-Sleep 1
                    Start-Process -FilePath "CMD.EXE" -ArgumentList "/C REG.EXE UNLOAD HKU\$($UserProfile.SID)" -Wait -WindowStyle Hidden | Out-Null
                    Write-Log -Path $global:logFile -Level Info -Message "UNLOADING HIVE for USER: $($UserProfile.SID)"
                }
            }
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
    }
}

Function Reboot-ThisPc {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = "Restart this PC"
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName"
    }
    Process {
        try {
            Write-Log "RESTART: This PC will restart in 30 seconds...."
            for ($i = 0; $i -le 30; $i++){
                [INT]$maxTime = 30
                [INT]$countdown = $maxTime - $i
                Write-Host "$countdown..." -ForegroundColor Green
                Start-Sleep -Seconds 1
            }
            Restart-Computer -Force
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : $stepName"
        Write-Host "END STEP: $global:stepNumber : $stepName" 
        $global:stepNumber++
        Remove-Variable -Name $stepName
    }
}

Function Test-InternetConnectivity {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = "Test Internet Connectivity"
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName"
    }
    Process {
        try {
            # If a device has a route to 0.0.0.0 then it has proper internet access
            $deviceOnline = Get-NetRoute | Where-Object DestinationPrefix -eq '0.0.0.0/0' | Get-NetIPInterface | Where-Object ConnectionState -eq "Connected"
            if ($null -ne $deviceOnline){
                return $True
            } else {
                return $False
            }
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : $stepName"
        Write-Host "END STEP: $global:stepNumber : $stepName" 
        $global:stepNumber++
        Remove-Variable -Name $stepName
    }
}

Function Resize-Image {
   <#
    .SYNOPSIS
        Resize-Image resizes an image file

    .DESCRIPTION
        This function uses the native .NET API to resize an image file, and optionally save it to a file or display it on the screen. You can specify a scale or a new resolution for the new image.
        
        It supports the following image formats: BMP, GIF, JPEG, PNG, TIFF 
 
    .EXAMPLE
        Resize-Image -InputFile "C:\kitten.jpg" -Display

        Resize the image by 50% and display it on the screen.

    .EXAMPLE
        Resize-Image -InputFile "C:\kitten.jpg" -Width 200 -Height 400 -Display

        Resize the image to a specific size and display it on the screen.

    .EXAMPLE
        Resize-Image -InputFile "C:\kitten.jpg" -Scale 30 -OutputFile "C:\kitten2.jpg"

        Resize the image to 30% of its original size and save it to a new file.

    .LINK
        Author: Patrick Lambert - http://dendory.net
        Technet: https://gallery.technet.microsoft.com/scriptcenter/Resize-Image-A-PowerShell-3d26ef68
    #>
    Param([Parameter(Mandatory=$true)][string]$InputFile, [string]$OutputFile, [int32]$Width, [int32]$Height, [int32]$Scale, [Switch]$Display)

    # Add System.Drawing assembly
    Add-Type -AssemblyName System.Drawing

    # Open image file
    $img = [System.Drawing.Image]::FromFile((Get-Item $InputFile))

    # Define new resolution
    if($Width -gt 0) { [int32]$new_width = $Width }
    elseif($Scale -gt 0) { [int32]$new_width = $img.Width * ($Scale / 100) }
    else { [int32]$new_width = $img.Width / 2 }
    if($Height -gt 0) { [int32]$new_height = $Height }
    elseif($Scale -gt 0) { [int32]$new_height = $img.Height * ($Scale / 100) }
    else { [int32]$new_height = $img.Height / 2 }

    # Create empty canvas for the new image
    $img2 = New-Object System.Drawing.Bitmap($new_width, $new_height)

    # Draw new image on the empty canvas
    $graph = [System.Drawing.Graphics]::FromImage($img2)
    $graph.DrawImage($img, 0, 0, $new_width, $new_height)

    # Create window to display the new image
    if($Display)
    {
        Add-Type -AssemblyName System.Windows.Forms
        $win = New-Object Windows.Forms.Form
        $box = New-Object Windows.Forms.PictureBox
        $box.Width = $new_width
        $box.Height = $new_height
        $box.Image = $img2
        $win.Controls.Add($box)
        $win.AutoSize = $true
        $win.ShowDialog()
    }

    # Save the image
    if($OutputFile -ne "")
    {
        $img2.Save($OutputFile);
    }
}

Function Export-RegistryBackup {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = "Backup the registry"
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName"
    }
    Process {
        try {
            $registryLocations = "HKLM\Software","HKLM\Security","HKLM\System","HKU\.Default","HKLM\SAM","HKCU","HKCU\Software\Classes","HKLM\BCD00000000","HKLM\COMPONENTS"
            $registryBackupFile = Join-Path -Path $global:generalOutputFolder -ChildPath "RegistryBackup"
            foreach ($regLoc in $registryLocations){
                try {
                    Write-Log -Path $global:logFile -Level Info -Message "Backing up registry hive $regLoc."
                    REG SAVE $regLoc $(Join-Path -Path $registryBackupFile -ChildPath $regLoc.Replace("\","-")) /y
                }
                catch {
                    Write-Host $PSItem.Exception.Message -ForegroundColor Red
                    Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
                }
                finally {
                    $Error.Clear | Out-Null
                }
            }
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : $stepName"
        Write-Host "END STEP: $global:stepNumber : $stepName" 
        $global:stepNumber++
        Remove-Variable -Name $stepName
    }
}

# Currently in progress. Ignore.
Function New-OutputReportHtml {
    [CmdletBinding(SupportsShouldProcess)]
    # Helpful: https://adamtheautomator.com/powershell-convertto-html/
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = "Create output HTML report"
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName"
    }
    Process {
        try {
            # HTML TABLE COLUMNS
            # Step Number - Step Name - Success (yes or blank) - Failure (no or blank) - Error output (if failure)

            #
            # EACH FUNCTION WILL NEED UPDATING TO OUTPUT RESULTS IN THE FORM OF A CUSTOM OBJECT, THAT WILL BE IMPORTED HERE
            #

            # EXAMPLE (needs declaring elsewhere)
            class reportLine {
                [INT]StepNumber
                [STRING]StepName
                [BOOL]Success
                [BOOL]Failure
                [STRING]ErrorOutput
            }
            
            # Define the table CSS
            $reportHeader = @"
            <style>
            h1 {
                font-family: Arial, Helvetica, sans-serif;
                color: #e68a00;
                font-size: 28px;
            }
        
            h2 {
                font-family: Arial, Helvetica, sans-serif;
                color: #000099;
                font-size: 16px;
        
            }
            
           table {
                font-size: 12px;
                border: 0px; 
                font-family: Arial, Helvetica, sans-serif;
            } 
            
            td {
                padding: 4px;
                margin: 0px;
                border: 0;
            }
            
            th {
                background: #395870;
                background: linear-gradient(#49708f, #293f50);
                color: #fff;
                font-size: 11px;
                text-transform: uppercase;
                padding: 10px 15px;
                vertical-align: middle;
            }
        
            tbody tr:nth-child(even) {
                background: #f0f0f2;
            }
            
            #CreationDate {
                font-family: Arial, Helvetica, sans-serif;
                color: #ff3300;
                font-size: 12px;
            }

            </style>
"@



        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : $stepName"
        Write-Host "END STEP: $global:stepNumber : $stepName" 
        $global:stepNumber++
        Remove-Variable -Name $stepName
    }
}


# PRIVACY FUNCTIONS

Function Disable-Telemetry {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    
    # Values from Disassemblers script

    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Host "`n BEGIN STEP: Disable Telemetry"
        Write-Log -Path $global:logFile -Level Info -Message "BEGIN STEP: Disable Telemetry"
    }
    Process {
        try {
            if (!(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection")){
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection\AllowTelemetry, 0"
            
            if (!(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection")){
                New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: KLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection\AllowTelemetry, 0"

            if (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection")){
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection\AllowTelemetry, 0"

            if (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds")){
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" -Name "AllowBuildPreview" -Type DWord -Value 0
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds\AllowPreviewBuilds, 0"

            if (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform")){
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" -Name "NoGenTicket" -Type DWord -Value 1
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform\Software Protection Platform, 1"

            if (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows")){
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" -Name "CEIPEnable" -Type DWord -Value 0
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows\CEIPEnable, 0"

            if (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat")){
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "AITEnable" -Type DWord -Value 0
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat, 0"

            if (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat")){
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "DisableInventory" -Type DWord -Value 1
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat\DisableInventory, 1"

            if (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\AppV\CEIP")){
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\AppV\CEIP" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Policies\Microsoft\AppV\CEIP"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\AppV\CEIP" -Name "CEIPEnable" -Type DWord -Value 0
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Policies\Microsoft\AppV\CEIP\CEIPEnable, 0"

            if (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC")){
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC" -Name "PreventHandwritingDataSharing" -Type DWord -Value 1
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC\PreventHandwritingDataSharing, 1"

            if (!(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput")){
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput" -Name "AllowLinguisticDataCollection" -Type DWord -Value 0
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput\AllowLinguisticDataCollection, 0"

            Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" | Out-Null
            Write-Log -Path $global:logFile -Level Info -Message "SCHEDULED TASK DISABLED: Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"

            Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\ProgramDataUpdater" | Out-Null
            Write-Log -Path $global:logFile -Level Info -Message "SCHEDULED TASK DISABLED: Microsoft\Windows\Application Experience\ProgramDataUpdater"

            Disable-ScheduledTask -TaskName "Microsoft\Windows\Autochk\Proxy" | Out-Null
            Write-Log -Path $global:logFile -Level Info -Message "SCHEDULED TASK DISABLED: Microsoft\Windows\Autochk\Proxy"

            Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" | Out-Null
            Write-Log -Path $global:logFile -Level Info -Message "SCHEDULED TASK DISABLED: Microsoft\Windows\Customer Experience Improvement Program\Consolidator"

            Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" | Out-Null
            Write-Log -Path $global:logFile -Level Info -Message "SCHEDULED TASK DISABLED: Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"

            Disable-ScheduledTask -TaskName "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" | Out-Null
            Write-Log -Path $global:logFile -Level Info -Message "SCHEDULED TASK DISABLED: Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Telemetry"
        Write-Host "END STEP: $global:stepNumber : Disable Telemetry"
        $global:stepNumber++
    }
}

Function Disable-WifiSense {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Wi-Fi Sense"
        Write-Host "START STEP: $global:stepNumber : Disable Wi-Fi Sense" 
    }
    Process {
        try {
            if (!(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting"
	        }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 0
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting\Value, 0"

            if (!(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots")) {
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots"
		    }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 0
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots\Value, 0"
            

            if (!(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config")) {
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "AutoConnectAllowedOEM" -Type DWord -Value 0
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config\AutoConnectAllowedOEM, 0"
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "WiFISenseAllowed" -Type DWord -Value 0
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config\WiFiSenseAllowed, 0"

        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }

    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Wi-Fi Sense"
        Write-Host "END STEP: $global:stepNumber : Disable Wi-Fi Sense" 
        $global:stepNumber++
    }
}

Function Enable-SmartScreen {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable Smart Screen"
        Write-Host "START STEP: $global:stepNumber : Enable Smart Screen" 
    }
    Process {
        try {
            if (Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\EnableSmartScreen"){
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableSmartScreen" -ErrorAction SilentlyContinue
                Write-Log -Path $global:logFile -Level Info -Message "REMOVING: HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\EnableSmartScreen"
            }
            if (Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter\EnabledV9"){
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" -Name "EnabledV9" -ErrorAction SilentlyContinue
                Write-Log -Path $global:logFile -Level Info -Message "REMOVING: HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter\EnabledV9\PhishingFilter"
            }
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable Smart Screen"
        Write-Host "END STEP: $global:stepNumber : Enable Smart Screen" 
        $global:stepNumber++
    }
}

Function Disable-Location {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Location"
        Write-Host "START STEP: $global:stepNumber : Disable Location" 
    } 
    Process {
        try {
            If (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors")){
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocation" -Type DWord -Value 1
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors\DisableLocation, 1"
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocationScripting" -Type DWord -Value 1
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors\DisableLocationScripting, 1"
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Location"
        Write-Host "END STEP: $global:stepNumber : Disable Location" 
        $global:stepNumber++
    }
}

Function Disable-MapsUpdates {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Maps Update"
        Write-Host "START STEP: $global:stepNumber : Disable Maps Update" 
    }
    Process {
        try {
            if (Test-Path -Path "HKLM:\SYSTEM\Maps\AutoUpdateEnabled"){
                Set-ItemProperty -Path "HKLM:\SYSTEM\Maps" -Name "AutoUpdateEnabled" -Type DWord -Value 0
                Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SYSTEM\Maps\AutoUpdateEnabled, 0"
            }
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Maps Update"
        Write-Host "END STEP: $global:stepNumber : Disable Maps Update" 
        $global:stepNumber++
    }
}

Function Disable-Feedback {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Feedback"
        Write-Host "START STEP: $global:stepNumber : Disable Feedback" 
    }
    Process {
        try {

            Update-KeyForAllUsers -Action Update -registryKeyPath "HKCU:\Software\Microsoft\Siuf\Rules" -registryKeyName "NumberOfSIUFInPeriod" -registryKeyType "DWord" -registryKeyValue 0
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Type DWord -Value 1
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection\DoNotShowFeedbackNotifications, 1"

            Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient" -ErrorAction SilentlyContinue | Out-Null
            Write-Log -Path $global:logFile -Level Info -Message "SCHEDULED TASK DISABLED: Microsoft\Windows\Feedback\Siuf\DmClient"
            Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" -ErrorAction SilentlyContinue | Out-Null
            Write-Log -Path $global:logFile -Level Info -Message "SCHEDULED TASK DISABLED: Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload"
        
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Feedback"
        Write-Host "END STEP: $global:stepNumber : Disable Feedback" 
        $global:stepNumber++
    }
}

Function Disable-TailoredExperiences {
    # TESSTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Tailored Experiences"
        Write-Host "START STEP: $global:stepNumber : Disable Tailored Experiences" 
    }
    Process {
        try {
            Update-KeyForAllUsers -Action Update -registryKeyPath "HKCU:\Software\Policies\Microsoft\Windows\CloudContent" -registryKeyName "DisableTailoredExperiencesWithDiagnosticData" -registryKeyType "DWord" -registryKeyValue 1
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }

    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Tailored Experiences"
        Write-Host "END STEP: $global:stepNumber : Disable Tailored Experiences" 
        $global:stepNumber++
    }
}

Function Disable-AdvertisingId {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Advertising ID"
        Write-Host "START STEP: $global:stepNumber : Disable Advertising ID" 
    }
    Process {
        try {
            if (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo")){
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Type DWord -Value 1
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo\DisabledByGroupPolicy, 1"
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Advertising ID"
        Write-Host "END STEP: $global:stepNumber : Disable Advertising ID"
        $global:stepNumber++ 
    }
}

Function Disable-WebLangList {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable WebLangList"
        Write-Host "START STEP: $global:stepNumber : Disable WebLangList" 
    }
    Process {
        try {
            $disableWebLangList = @{
                registryKeyPath = "HKCU:\Control Panel\International\User Profile"
                registryKeyName = "HttpAcceptLanguageOptOut"
                registryKeyType = "DWord"
                registryKeyValue = 1
                action = "Update"
            }
            Update-KeyForAllUsers @$disableWebLangList
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable WebLangList"
        Write-Host "END STEP: $global:stepNumber : Disable WebLangList" 
        $global:stepNumber++
    }
}

Function Disable-ErrorReporting {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Error Reporting"
        Write-Host "START STEP: $global:stepNumber : Disable Error Reporting" 
    }
    Process {
        try {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Type DWord -Value 1
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting\Disabled, 1"
            Disable-ScheduledTask -TaskName "Microsoft\Windows\Windows Error Reporting\QueueReporting" | Out-Null
            Write-Log -Path $global:logFile -Level Info -Message "SCHEDULED TASK DISABLED: Microsoft\Windows\Windows Error Reporting\QueueReporting"
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Error Reporting"
        Write-Host "END STEP: $global:stepNumber : Disable Error Reporting"
        $global:stepNumber++
    }
}

Function Disable-DiagTrack {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Diagnostics Tracking"
        Write-Host "START STEP: $global:stepNumber : Disable Diagnostics Tracking" 
    }
    Process {
        try {
            Stop-Service "DiagTrack" -WarningAction SilentlyContinue
            Write-Log -Path $global:logFile -Level Info -Message "STOPPING: DiagTrack Service"
            Set-Service "DiagTrack" -StartupType Disabled         
            Write-Log -Path $global:logFile -Level Info -Message "DISABLED: DiagTrack Service" 
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Diagnostics Tracking"
        Write-Host "END STEP: $global:stepNumber : Disable Diagnostics Tracking" 
        $global:stepNumber++
    }
}



# POWERSHELL FUNCTIONS

Function Enable-PowershellScriptBlockLogging {
    # Source (ish): https://adamtheautomator.com/powershell-logging-recording-and-auditing-all-the-things/
    # Logs all Powershell activity to the Powershell > Operational Event Log.
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Registry key
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        $basePath = "HKLM:\\Software\\Policies\\Microsoft\\Windows\\PowerShell\\ScriptBlockLogging"
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable Powershell Scriptblock Logging"
        Write-Host "START STEP: $global:stepNumber : Enable Powershell Scriptblock Logging" 
    }
    Process {
        try {
            # Create the key if it does not exist
            if(-not (Test-Path $basePath)){
                $null = New-Item $basePath -Force
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: $basePath"
    
                # Create the correct properties
                New-ItemProperty -Path $basePath -Name "EnableScriptBlockLogging" -PropertyType Dword
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: $(Join-Path -Path $basePath -ChildPath 'EnableScriptBlockLogging')"
            }
            
            # These can be enabled (1) or disabled (0) by changing the value
            Set-ItemProperty $basePath -Name "EnableScriptBlockLogging" -Value "1"
            Write-Host -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging\EnableScriptBlockLogging, 1"
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    } 
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable Scriptblock Logging"
        Write-Host "END STEP: $global:stepNumber : Enable Scriptblock Logging" 
        $global:stepNumber++
    }
}

Function Enable-PowershellModuleLogging {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable Powershell Module Logging"
        Write-Host "START STEP: $global:stepNumber : Enable Powershell Module Logging" 
    }
    Process {
        try {
            # Registry path
            $basePath = "HKLM:\\SOFTWARE\\WOW6432Node\\Policies\\Microsoft\\Windows\\PowerShell\\ModuleLogging"
            
            # Create the key if it does not exist
            if(-not (Test-Path $basePath)){
                $null = New-Item $basePath -Force
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: $basePath"
                # Create the correct properties
                New-ItemProperty $basePath -Name "EnableModuleLogging" -PropertyType Dword
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: $(Join-Path -Path $basePath -ChildPath 'EnableModuleLogging')"
            }

            # These can be enabled (1) or disabled (0) by changing the value
            Set-ItemProperty $basePath -Name "EnableModuleLogging" -Value "1"
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: $(Join-Path -Path $basePath -ChildPath 'EnableModuleLogging'), 1"

            # Now enforce logging for all modules
            # Registry Path
            $basePathModules = 'HKLM:\\SOFTWARE\\WOW6432Node\\Policies\\Microsoft\\Windows\\PowerShell\\ModuleLogging\\ModuleNames'
            
            # Create the key if it does not exist
            if(-not (Test-Path $basePathModules)){
                $null = New-Item $basePathModules -Force
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: $basePathModules"
            }
            # Set the key value to log all modules
            Set-ItemProperty $basePathModules -Name "*" -Value "*"
            Write-Log -Path $basePath -Level Info -Message "VALUE SET: $basePathModules \*, *"
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }

    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable Powershell Module Logging"
        Write-Host "END STEP: $global:stepNumber : Enable Powershell Module Logging" 
        $global:stepNumber++
    }
}

Function Set-PowerShellRemoteSigned {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Set Powershell Execution Policy to RemoteSigned"
        Write-Host "START STEP: $global:stepNumber : Set Powershell Execution Policy to RemoteSigned" 
    }
    Process{
        try {
            if ($(Get-ExecutionPolicy) -eq "RemoteSigned"){
                Write-Output "Powershell execution policy is RemoteSigned. No action required."
            } else {
                Write-Output "Setting Powershell execution policy to RemoteSigned"
                Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
            }            
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Set Powershell Execution Policy to RemoteSigned"
        Write-Host "END STEP: $global:stepNumber : Set Powershell Execution Policy to RemoteSigned" 
        $global:stepNumber++
    }
}




# SECURITY FUNCTIONS

Function Enable-UacHigh {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable UAC (High)"
        Write-Host "START STEP: $global:stepNumber : Enable UAC (High)" 
    }
    Process {
        try {
            if(!(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System")){
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 5
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\ConsentPromptBehaviourAdmin, 5"
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Type DWord -Value 1
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\PromptOnSecureDesktop, 1"
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable UAC (High)"
        Write-Host "END STEP: $global:stepNumber : Enable UAC (High)" 
        $global:stepNumber++
    }
}

Function Enable-WindowsFirewall {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable Windows Firewall"
        Write-Host "START STEP: $global:stepNumber : Enable Windows Firewall" 
    }
    Process {
        try {
            if (Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile"){
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" -Name "EnableFirewall" -ErrorAction SilentlyContinue
                Write-Log -Path $global:logFile -Level Info -Message "REMOVED: HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile\EnableFirewall" 
            }
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable Windows Firewall"
        Write-Host "END STEP: $global:stepNumber : Enable Windows Firewall" 
        $global:stepNumber++
    }
}

Function Disable-MappedDriveSharing {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Sharing Mapped Drives"
        Write-Host "START STEP: $global:stepNumber : Disable Sharing Mapped Drives" 
    }
    Process {
        try {
            if (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"){
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLinkedConnections" -ErrorAction SilentlyContinue
                Write-Log -Path $global:logFile -Level Info -Message "REMOVED: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\EnableLinkedConnections"
            }
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Sharing Mapped Drives"
        Write-Host "END STEP: $global:stepNumber : Disable Sharing Mapped Drives" 
        $global:stepNumber++
    }
}

Function Disable-WindowsScriptHost {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()

    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Windows Script Host"
        Write-Host "START STEP: $global:stepNumber : Disable Windows Script Host" 
    }
    Process {
        try {
            if (!(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings")){
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings" -Name "Enabled" -Type DWord -Value 0
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings\Enabled, 0"
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Windows Script Host"
        Write-Host "END STEP: $global:stepNumber : Disable Windows Script Host" 
        $global:stepNumber++
    }
}

Function Enable-DotNotStrongCrypto {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()

    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable .NET Strong Cryptography"
        Write-Host "START STEP: $global:stepNumber : Enable .NET Strong Cryptography" 
    }
    Process {
        try {
            if (!(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319")){
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Type DWord -Value 1
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319\SchUseStrongCrypto, 1"

            if (!(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319")){
                New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HHKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Type DWord -Value 1      
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319\SchUseStrongCrypto, 1"  
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable .NET Strong Cryptography"
        Write-Host "END STEP: $global:stepNumber : Enable .NET Strong Cryptography" 
        $global:stepNumber++
    }
}

Function Enable-MeltdownCompatFlag {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable Meltdown Compatibility Flag"
        Write-Host "START STEP: $global:stepNumber : Enable Meltdown Compatibility Flag" 
    }
    Process {
        try {
            If (!(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat")) {
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat" | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat" -Name "cadca5fe-87d3-4b96-b7fb-a231484277cc" -Type DWord -Value 0   
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat\cadca5fe-87d3-4b96-b7fb-a231484277cc, 0"         
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable Meltdown Compatibility Flag"
        Write-Host "END STEP: $global:stepNumber : Enable Meltdown Compatibility Flag" 
        $global:stepNumber++
    }
}

Function Enable-DepOptIn {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable Data Execution Prevention (Opt In)"
        Write-Host "START STEP: $global:stepNumber : Enable Data Execution Prevention (Opt In)" 
    }
    Process {
        try {
            bcdedit /set `{current`} nx OptIn | Out-Null
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable Data Execution Prevention (Opt In)"
        Write-Host "END STEP: $global:stepNumber : Enable Data Execution Prevention (Opt In)" 
        $global:stepNumber++
    }
}

Function Disable-Smb1 {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable SMB1"
        Write-Host "START STEP: $global:stepNumber : Disable SMB1" 
    }
    Process {
        try {
            Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
            Write-Log -Path $global:logFile -Level Info -Message "Disabling SMB1 Protocol..."
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable SMB1"
        Write-Host "END STEP: $global:stepNumber : Disable SMB1" 
        $global:stepNumber++
    }
}

Function Disable-RemoteAssistance {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Remote Assistance"
        Write-Host "START STEP: $global:stepNumber : Disable Remote Assistance" 
    }
    Process {
        try {
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 0
            Get-WindowsCapability -Online | Where-Object { $_.Name -like "App.Support.QuickAssist*" } | Remove-WindowsCapability -Online | Out-Null            
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Remote Assistance"
        Write-Host "END STEP: $global:stepNumber : Disable Remote Assistance" 
        $global:stepNumber++
    }
}

Function Disable-AutoRestartSignOn {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Auto-Sign in on Restart"
        Write-Host "START STEP: $global:stepNumber : Disable Auto-Sign in on Restart" 
    }
    Process {
        try {
            if (!(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System")){
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableAutomaticRestartSignOn" -Type DWord -Value 1
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\DisableAutomaticRestartSignOn, 1"
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP:Disable Auto-Sign in on Restart"
        Write-Host "END STEP: $global:stepNumber : Disable Auto-Sign in on Restart" 
        $global:stepNumber++
    }
}

Function Disable-AutoPlay {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Autoplay"
        Write-Host "START STEP: $global:stepNumber : Disable Autoplay" 
    }
    Process {
        try {
            $disableAutoPlay = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers"
                registryKeyName = "DisableAutoplay"
                registryKeyType = "DWord"
                registryKeyValue = 1
            }
            Update-KeyForAllUsers @disableAutoPlay
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Autoplay"
        Write-Host "END STEP: $global:stepNumber : Disable Autoplay" 
        $global:stepNumber++
    }
}

Function Disable-AutoRun {
    # TESTED: Good  
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Autorun"
        Write-Host "START STEP: $global:stepNumber : Disable Autorun" 
    }
    Process {
        try {
            if (!(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Type DWord -Value 255
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoDriveTypeAutoRun, 255"        
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Autorun"
        Write-Host "END STEP: $global:stepNumber : Disable Autorun" 
        $global:stepNumber++
    }
}




# WINDOWS DEFENDER SETTINGS

Function Enable-WindowsDefender {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable Windows Defender"
        Write-Host "START STEP: $global:stepNumber : Enable Windows Defender" 
    }
    Process {
        try {
            if (Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"){
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -ErrorAction SilentlyContinue
                Write-Log -Path $global:logFile -Level Info -Message "REMOVED: HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\DisableAntiSpyware"
            }
            if ([System.Environment]::OSVersion.Version.Build -eq 14393){
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsDefender" -Type ExpandString -Value "`"%ProgramFiles%\Windows Defender\MSASCuiL.exe`""
                Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\WindowsDefender, `"%ProgramFiles%\Windows Defender\MSASCuiL.exe`""
            } elseif ([System.Environment]::OSVersion.Version.Build -ge 15063 -And [System.Environment]::OSVersion.Version.Build -le 17134){
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -Type ExpandString -Value "%ProgramFiles%\Windows Defender\MSASCuiL.exe"
                Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\SecurityHealth, %ProgramFiles%\Windows Defender\MSASCuiL.exe"
            } elseif ([System.Environment]::OSVersion.Version.Build -ge 17763){
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -Type ExpandString -Value "%windir%\system32\SecurityHealthSystray.exe"
                Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\SecurityHealth, windir%\system32\SecurityHealthSystray.exe"
            }
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable Windows Defender"
        Write-Host "END STEP: $global:stepNumber : Enable Windows Defender" 
        $global:stepNumber++
    }
}

Function Enable-WindowsDefenderCloud {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable Windows Defender Cloud Features"
        Write-Host "START STEP: $global:stepNumber : Enable Windows Defender Cloud Features" 
    }
    Process {
        try {
            if (Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet"){
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SpynetReporting" -ErrorAction SilentlyContinue
                Write-Log -Path $global:logFile -Level Info -Message "REMOVED: HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet\SpynetReporting"
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SubmitSamplesConsent" -ErrorAction SilentlyContinue
                Write-Log -Path $global:logFile -Level Info -Message "REMOVED: HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet\SubmitSamplesConsent"
            } 
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable Windows Defender Cloud Features"
        Write-Host "END STEP: $global:stepNumber : Enable Windows Defender Cloud Features" 
        $global:stepNumber++
    }
}

Function Enable-ControlledFolderAccess {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable Windows Defender Controlled Folder Access"
        Write-Host "START STEP: $global:stepNumber : Enable Windows Defender Controlled Folder Access" 

    }
    Process {
        try {
            Set-MpPreference -EnableControlledFolderAccess Enabled -ErrorAction SilentlyContinue
            Write-Log -Path $global:logFile -Level Info -Message "ENABLED: Defender Controlled Folder Access"
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable Windows Defender Controlled Folder Access"
        Write-Host "END STEP: $global:stepNumber : Enable Windows Defender Controlled Folder Access"
        $global:stepNumber++ 
    }
}

Function Enable-CoreIsolationMemoryIntegrity {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable Core Isolation Memory Integrity"
        Write-Host "START STEP: $global:stepNumber : Enable Core Isolation Memory Integrity" 
    }
    Process {
        try {
            If (!(Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity")) {
                New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
            }
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -Type DWord -Value 1
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity\Enabled, 1"       
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable Core Isolation Memory Integrity"
        Write-Host "END STEP: $global:stepNumber : Enable Core Isolation Memory Integrity" 
        $global:stepNumber++
    }
}

Function Enable-DefenderAppGuard {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable Windows Defender Application Guard"
        Write-Host "START STEP: $global:stepNumber : Enable Windows Defender Application Guard" 
    } 
    Process {
        try {
            Enable-WindowsOptionalFeature -online -FeatureName "Windows-Defender-ApplicationGuard" -NoRestart -WarningAction SilentlyContinue | Out-Null
            Write-Log -Path $global:logFile -Level Info -Message "ENABLED: Windows 10 Optional Feature - Windows Defender Application Guard"
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable Windows Defender Application Guard"
        Write-Host "END STEP: $global:stepNumber : Enable Windows Defender Application Guard" 
        $global:stepNumber++
    }
}

Function Disable-AccountProtectionWarning {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Account Protection Warning"
        Write-Host "START STEP: $global:stepNumber : Disable Account Protection Warning" 
    }
    Process {
        try {
            $disableAccountProtectionWarning = @{
                registryKeyPath = "HKCU:\Software\Microsoft\Windows Security Health\State"
                registryKeyName = "AccountProtection_MicrosoftAccount_Disconnected"
                registryKeyType = "DWord"
                registryKeyValue = 1
                action = "Update"
             }
             Update-KeyForAllUsers @disableAccountProtectionWarning
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Account Protection Warning"
        Write-Host "END STEP: $global:stepNumber : Disable Account Protection Warning" 
        $global:stepNumber++
    }
}





# SEARCH & CORTANA FUNCTIONS

Function Disable-StartWebSearch {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Cortana Web Search"
        Write-Host "START STEP: $global:stepNumber : Disable Cortana Web Search" 
    }
    Process {
        try {
            $disableStartWebSearch1 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
                registryKeyName = "BingSearchEnabled"
                registryKeyType = "DWord"
                registryKeyValue = 0
            }
            $disableStartWebSearch2 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
                registryKeyName = "CortanaConsent"
                registryKeyType = "DWord"
                registryKeyValue = 0
            }

            Update-KeyForAllUsers @disableStartWebSearch1
            Update-KeyForAllUsers @disableStartWebSearch2

            if (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Type DWord -Value 1
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }

    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Cortana Web Search"
        Write-Host "END STEP: $global:stepNumber : Disable Cortana Web Search" 
        $global:stepNumber++
    }
}

Function Disable-AppSuggestions {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Cortana App Suggestions"
        Write-Host "START STEP: $global:stepNumber : Disable Cortana App Suggestions" 
        $pathContentDeliveryManager = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    }
    Process {
        try {
            $disableAppSuggestions1 = @{
                registryKeyPath = $pathContentDeliveryManager
                registryKeyName = "ContentDeliveryAllowed"
                registryKeyType = "DWord"
                registryKeyValue = 0
                action = "Update"
            }
            Update-KeyForAllUsers @disableAppSuggestions1

            $disableAppSuggestions2 = @{
                registryKeyPath = $pathContentDeliveryManager
                registryKeyName = "OemPreInstalledAppsEnabled"
                registryKeyType = "DWord"
                registryKeyValue = 0
                action = "Update"
            }
            Update-KeyForAllUsers @disableAppSuggestions2

            $disableAppSuggestions3 = @{
                registryKeyPath = $pathContentDeliveryManager
                registryKeyName = "PreInstalledAppsEnabled"
                registryKeyType = "DWord"
                registryKeyValue = 0
                action = "Update"
            }
            Update-KeyForAllUsers @disableAppSuggestions3

            $disableAppSuggestions4 = @{
                registryKeyPath = $pathContentDeliveryManager
                registryKeyName = ""
                registryKeyType = "DWord"
                registryKeyValue = 0
                action = "Update"
            }
            Update-KeyForAllUsers @disableAppSuggestions4

            $disableAppSuggestions5 = @{
                registryKeyPath = $pathContentDeliveryManager
                registryKeyName = "SilentInstallAppsEnabled"
                registryKeyType = "DWord"
                registryKeyValue = 0
                action = "Update"
            }
            Update-KeyForAllUsers @disableAppSuggestions5

            $disableAppSuggestions6 = @{
                registryKeyPath = $pathContentDeliveryManager
                registryKeyName = ""
                registryKeyType = "DWord"
                registryKeyValue = 0
                action = "Update"
            }
            Update-KeyForAllUsers @disableAppSuggestions6

            $disableAppSuggestions7 = @{
                registryKeyPath = $pathContentDeliveryManager
                registryKeyName = "SubscribedContent-314559Enabled"
                registryKeyType = "DWord"
                registryKeyValue = 0
                action = "Update"
            }
            Update-KeyForAllUsers @disableAppSuggestions7

            $disableAppSuggestions8 = @{
                registryKeyPath = $pathContentDeliveryManager
                registryKeyName = "SubscribedContent-338387Enabled"
                registryKeyType = "DWord"
                registryKeyValue = 0
                action = "Update"
            }
            Update-KeyForAllUsers @disableAppSuggestions8

            $disableAppSuggestions9 = @{
                registryKeyPath = $pathContentDeliveryManager
                registryKeyName = "SubscribedContent-338388Enabled"
                registryKeyType = "DWord"
                registryKeyValue = 0
                action = "Update"
            }
            Update-KeyForAllUsers @disableAppSuggestions9

            $disableAppSuggestions10 = @{
                registryKeyPath = $pathContentDeliveryManager
                registryKeyName = "SubscribedContent-338389Enabled"
                registryKeyType = "DWord"
                registryKeyValue = 0
                action = "Update"
            }
            Update-KeyForAllUsers @disableAppSuggestions10

            $disableAppSuggestions11 = @{
                registryKeyPath = $pathContentDeliveryManager
                registryKeyName = "SubscribedContent-338393Enabled"
                registryKeyType = "DWord"
                registryKeyValue = 0
                action = "Update"
            }
            Update-KeyForAllUsers @disableAppSuggestions11

            $disableAppSuggestions12 = @{
                registryKeyPath = $pathContentDeliveryManager
                registryKeyName = "SubscribedContent-353694Enabled"
                registryKeyType = "DWord"
                registryKeyValue = 0
                action = "Update"
            }
            Update-KeyForAllUsers @disableAppSuggestions12

            $disableAppSuggestions13 = @{
                registryKeyPath = $pathContentDeliveryManager
                registryKeyName = "SubscribedContent-353696Enabled"
                registryKeyType = "DWord"
                registryKeyValue = 0
                action = "Update"
            }
            Update-KeyForAllUsers @disableAppSuggestions13

            $disableAppSuggestions14 = @{
                registryKeyPath = $pathContentDeliveryManager
                registryKeyName = "SubscribedContent-353698Enabled"
                registryKeyType = "DWord"
                registryKeyValue = 0
                action = "Update"
            }
            Update-KeyForAllUsers @disableAppSuggestions14

            $disableAppSuggestions15 = @{
                registryKeyPath = $pathContentDeliveryManager
                registryKeyName = "SubscribedContent-310093Enabled"
                registryKeyType = "DWord"
                registryKeyValue = 0
                action = "Update"
            }
            Update-KeyForAllUsers @disableAppSuggestions15
            
            $disableAppSuggestions16 = @{
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement"
                registryKeyName = "ScoobeSystemSettingEnabled"
                registryKeyType = "DWord"
                registryKeyValue = 0
                action = "Add"
            }
            Update-KeyForAllUsers @disableAppSuggestions16
            
            if (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace")) {
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" -Force | Out-Null
	        }

            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" -Name "AllowSuggestedAppsInWindowsInkWorkspace" -Type DWord -Value 0

            # Empty placeholder tile collection in registry cache and restart Start Menu process to reload the cache
            if ([System.Environment]::OSVersion.Version.Build -ge 17134) {
                $key = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*windows.data.placeholdertilecollection\Current"
                Set-ItemProperty -Path $key.PSPath -Name "Data" -Type Binary -Value $key.Data[0..15]
                Stop-Process -Name "ShellExperienceHost" -Force -ErrorAction SilentlyContinue
            }
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Cortana App Suggestions"
        Write-Host "END STEP: $global:stepNumber : Disable Cortana App Suggestions" 
        $global:stepNumber++
    }
}

Function Disable-Cortana {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Cortana"
        Write-Host "START STEP: $global:stepNumber : Disable Cortana"
    }
    Process {
        try {
            $disableCortana1 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Personalization\Settings"
                registryKeyName = "AcceptedPrivacyPolicy"
                registryKeyType = "DWord"
                registryKeyValue = 0
            }
            Update-KeyForAllUsers @disableCortana1
            
            $disableCortana2 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore"
                registryKeyName = "HarvestContacts"
                registryKeyType = "DWord"
                registryKeyValue = 0
            }
            Update-KeyForAllUsers @disableCortana2

            $disableCortana3 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\InputPersonalization"
                registryKeyName = "RestrictImplicitTextCollection"
                registryKeyType = "DWord"
                registryKeyValue = 1
            }
            Update-KeyForAllUsers @disableCortana3

            $disableCortana4 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\InputPersonalization"
                registryKeyName = "RestrictImplicitInkCollection"
                registryKeyType = "DWord"
                registryKeyValue = 1
            }
            Update-KeyForAllUsers @disableCortana4

            $disableCortana5 = @{
                action = "Update"
                registryKeyPath = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Experience\AllowCortana"
                registryKeyName = "Value"
                registryKeyType = "DWord"
                registryKeyValue = 0
            }
            Update-KeyForAllUsers @disableCortana5
            
            If (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0

            If (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization")) {
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization" -Force | Out-Null
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization" -Name "AllowInputPersonalization" -Type DWord -Value 0        
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Cortana"
        Write-Host "END STEP: $global:stepNumber : Disable Cortana"
        $global:stepNumber++
    }
}



# WINDOWS UPDATE FUNCTIONS

Function Set-WindowsUpdateP2PLocal {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Windows Update - Set P2P to Local Network Only"
        Write-Host "START STEP: $global:stepNumber : Windows Update - Set P2P to Local Network Only" 
    }
    Process {
        try {
            if ([System.Environment]::OSVersion.Version.Build -eq 10240){
                # Method used in 1507
                if (!(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config")) {
                    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" | Out-Null
                }
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 1
            } elseIf ([System.Environment]::OSVersion.Version.Build -le 14393){
                # Method used in 1511 and 1607
                if (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization")){
                    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" | Out-Null
                }
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -Type DWord -Value 1
            } else {
                # Method used since 1703
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -ErrorAction SilentlyContinue
            }
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Windows Update - Set P2P to Local Network Only"
        Write-Host "END STEP: $global:stepNumber : Windows Update - Set P2P to Local Network Only" 
        $global:stepNumber++
    }
}

Function Enable-WindowsUpdateMaliciousRemovalTool {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Windows Update - Include Malicious Software Removal Tool"
        Write-Host "START STEP: $global:stepNumber : Windows Update - Include Malicious Software Removal Tool" 
    }
    Process {
        try {
            Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT" -Name "DontOfferThroughWUAU" -ErrorAction SilentlyContinue
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }   
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Windows Update - Include Malicious Software Removal Tool"
        Write-Host "END STEP: $global:stepNumber : Windows Update - Include Malicious Software Removal Tool" 
        $global:stepNumber++
    }
}

Function Enable-WindowsUpdateAllMicrosoftProducts {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Windows Update - Include All Microsoft Products"
        Write-Host "START STEP: $global:stepNumber : Windows Update - Include All Microsoft Products" 
    }
    Process {
        try {
            (New-Object -ComObject Microsoft.Update.ServiceManager).AddService2("7971f918-a847-4430-9279-4a52d1efe18d", 7, "") | Out-Null
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Windows Update - Include All Microsoft Products"
        Write-Host "END STEP: $global:stepNumber : Windows Update - Include All Microsoft Products" 
        $global:stepNumber++
    }
}

Function Disable-WindowsUpdateAutomaticRestart {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Windows Update - Disable Automatic Restart"
        Write-Host "START STEP: $global:stepNumber : Windows Update - Disable Automatic Restart" 
    }
    Process {
        try {
            if (!(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MusNotification.exe")) {
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MusNotification.exe" -Force | Out-Null
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MusNotification.exe" -Name "Debugger" -Type String -Value "cmd.exe"
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Windows Update - Disable Automatic Restart"
        Write-Host "END STEP: $global:stepNumber : Windows Update - Disable Automatic Restart" 
        $global:stepNumber++
    }
}

Function Disable-WindowsUpdateMaintenanceWakeup {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Windows Update - Disable Maintenance Wakeup"
        Write-Host "START STEP: $global:stepNumber : Windows Update - Disable Maintenance Wakeup" 
    }
    Process {
        try {
            if (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU")) {
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force | Out-Null
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUPowerManagement" -Type DWord -Value 0
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" -Name "WakeUp" -Type DWord -Value 0
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Windows Update - Disable Maintenance Wakeup"
        Write-Host "END STEP: $global:stepNumber : Windows Update - Disable Maintenance Wakeup" 
        $global:stepNumber++
    }
}

Function Disable-WindowsUpdateEdgeShortcutCreation {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Windows Update - Disable Edge Shortcut Creation"
        Write-Host "START STEP: $global:stepNumber : Windows Update - Disable Edge Shortcut Creation" 
    }
    Process {
        try {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "DisableEdgeDesktopShortcutCreation" -Type DWord -Value 1
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Windows Update - Disable Edge Shortcut Creation"
        Write-Host "END STEP: $global:stepNumber : Windows Update - Disable Edge Shortcut Creation" 
        $global:stepNumber++
    }
}




# MISCELLANEOUS FUNCTIONS

Function Enable-WapPushService {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable InTune/Endpoint Manager WAP Push Service"
        Write-Host "START STEP: $global:stepNumber : Enable InTune/Endpoint Manager WAP Push Service" 
    }
    Process {
        try {
            Set-Service "dmwappushservice" -StartupType Automatic
            Start-Service "dmwappushservice" -WarningAction SilentlyContinue
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\dmwappushservice" -Name "DelayedAutoStart" -Type DWord -Value 1
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable InTune/Endpoint Manager WAP Push Service"
        Write-Host "END STEP: $global:stepNumber : Enable InTune/Endpoint Manager WAP Push Service" 
        $global:stepNumber++
    }
}

Function Enable-SystemRestore {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable System Restore"
        Write-Host "START STEP: $global:stepNumber : Enable System Restore" 
    }
    Process {
        try {
            Enable-ComputerRestore -Drive "$env:SYSTEMDRIVE"
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable System Restore"
        Write-Host "END STEP: $global:stepNumber : Enable System Restore" 
        $global:stepNumber++
    }
}

Function Disable-ModernUiSwapFile {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Modern UI Swap File"
        Write-Host "START STEP: $global:stepNumber : Disable Modern UI Swap File" 
    }
    Process {
        try {
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "SwapfileControl" -Type Dword -Value 0
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Modern UI Swap File"
        Write-Host "END STEP: $global:stepNumber : Disable Modern UI Swap File" 
        $global:stepNumber++
    }
}

Function Enable-NtfsLongFilePaths {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable NTFS Long File Paths"
        Write-Host "START STEP: $global:stepNumber : Enable NTFS Long File Paths" 
    }
    Process {
        try {
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Type DWord -Value 1  
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable NTFS Long File Paths"
        Write-Host "END STEP: $global:stepNumber : Enable NTFS Long File Paths" 
        $global:stepNumber++
    }
}

Function Enable-NtfsLastAccessTimeStamps {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable NTFS Last Access Timestamps"
        Write-Host "START STEP: $global:stepNumber : Enable NTFS Last Access Timestamps" 
    }
    Process {
        try {
            if ([System.Environment]::OSVersion.Version.Build -ge 17134){
                # System Managed, Last Access Updates Enabled
                fsutil behavior set DisableLastAccess 2 | Out-Null
            } else {
                # Last Access Updates Enabled
                fsutil behavior set DisableLastAccess 0 | Out-Null
            }            
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable NTFS Last Access Timestamps"
        Write-Host "END STEP: $global:stepNumber : Enable NTFS Last Access Timestamps" 
        $global:stepNumber++
    }
}

Function Enable-OsDriveShadowCopies {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable System Drive Shadow Copies"
        Write-Host "START STEP: $global:stepNumber : Enable System Drive Shadow Copies" 
    }
    Process {
        try {
            Write-Log -Path $global:logFile -Level Info -Message "Enabling Shadow Copies on $env:SystemDrive"
            # BELOW ONLY WORKS ON SERVERS
            #vssadmin add shadowstorage /for=$env:SystemDrive /on=$env:SystemDrive /maxsize=15%
            # BELOW IS FOR WINDOWS 10
            if ($null -eq (Get-CimInstance -Class Win32_ShadowCopy)){
                $osShadows = (Get-WmiObject -List Win32_ShadowCopy).Create($env:SystemDrive.ToString()+"\",'ClientAccessible')
                if ($osShadows.ReturnValue -eq 0){
                    $osDrivePath = $(Get-Volume -DriveLetter $($env:SystemDrive.Remove($env:SystemDrive.length-1,1))).Path
                    $osDriveGuid = $osDrivePath.Remove(0,10)
                    $osDriveGuid = $osDriveGuid.Remove($osDriveGuid.Length-1,1)
                    $vssJobName = "ShadowCopyVolume" + $osDriveGuid
                    $sysDir = [System.Environment]::SystemDirectory
                    $vssJobProgram = Join-Path -Path $sysDir -ChildPath "vssadmin.exe"
                    $vssJobArguments = "create Shadow /AutoRetry=15 For=$osDrivePath"
                    $vssTrigger01 = New-ScheduledTaskTrigger -Daily -At 9am
                    $vssTrigger02 = New-ScheduledTaskTrigger -Daily -At 12pm
                    $vssTrigger03 = New-ScheduledTaskTrigger -Daily -At 4pm
                    $vssAction = New-ScheduledTaskAction -Execute $vssJobProgram -Argument $vssJobArguments
                    Register-ScheduledTask -Action $vssAction -Trigger $vssTrigger01 -TaskName $vssJobName -User "System"
                    Add-JobTrigger -Trigger $vssTrigger02 -Name $vssJobName
                    Add-JobTrigger -Trigger $vssTrigger03 -Name $vssJobName
                } else {
                    Write-Log -Path $global:logFile -Level Error -Message "ERROR: Shadow Copies not enabled on $env:SystemDrive"
                    Break
                }      
            }              
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally { 
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable System Drive Shadow Copies"
        Write-Host "END STEP: $global:stepNumber : Enable System Drive Shadow Copies" 
        $global:stepNumber++
    }
}




# POWER FUNCTIONS

Function Enable-UltimatePowerPlan {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable Ultimate Power Plan"
        Write-Host "START STEP: $global:stepNumber : Enable Ultimate Power Plan" 
    }
    Process {
        try {
            powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
            $planActive = powercfg -getactivescheme 
            if ($($planActive) -notmatch "e9a42b02-d5df-448d-aa00-03f14749eb61"){
                powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61
            }            
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable Ultimate Power Plan"
        Write-Host "END STEP: $global:stepNumber : Enable Ultimate Power Plan" 
        $global:stepNumber++
    }
}

Function Disable-NicPowerSaving {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Network Adapter Power Saving"
        Write-Host "START STEP: $global:stepNumber : Disable Network Adapter Power Saving" 
    }
    Process {
        try {
	#find only physical network,if value of properties of adaptersConfigManagerErrorCode is 0,  it means device is working properly. 
	#even covers enabled or disconnected devices.
	#if the value of properties of configManagerErrorCode is 22, it means the adapter was disabled. 
	$PhysicalAdapters = Get-WmiObject -Class Win32_NetworkAdapter|Where-Object{$_.PNPDeviceID -notlike "ROOT\*" `
	-and $_.Manufacturer -ne "Microsoft" -and $_.ConfigManagerErrorCode -eq 0 -and $_.ConfigManagerErrorCode -ne 22} 
	
	Foreach($PhysicalAdapter in $PhysicalAdapters)
	{
		$PhysicalAdapterName = $PhysicalAdapter.Name
		#check the unique device id number of network adapter in the currently environment.
		$DeviceID = $PhysicalAdapter.DeviceID
		If([Int32]$DeviceID -lt 10)
		{
			$AdapterDeviceNumber = "000"+$DeviceID
		}
		Else
		{
			$AdapterDeviceNumber = "00"+$DeviceID
		}
		
		#check whether the registry path exists.
		$KeyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}\$AdapterDeviceNumber"
		If(Test-Path -Path $KeyPath)
		{
			$PnPCapabilitiesValue = (Get-ItemProperty -Path $KeyPath).PnPCapabilities
			If($PnPCapabilitiesValue -eq 24)
			{
				Write-Warning """$PhysicalAdapterName"" - The option ""Allow the computer to turn off this device to save power"" has been disabled already."
			}
			If($PnPCapabilitiesValue -eq 0)
			{
				#check whether change value was successed.
				Try
				{	
					#setting the value of properties of PnPCapabilites to 24, it will disable save power option.
					Set-ItemProperty -Path $KeyPath -Name "PnPCapabilities" -Value 24 | Out-Null
					Write-Host """$PhysicalAdapterName"" - The option ""Allow the computer to turn off this device to save power"" was disabled."
				}
				Catch
				{
					Write-Host "Setting the value of properties of PnpCapabilities failed." -ForegroundColor Red
				}
			}
			If($null -eq $PnPCapabilitiesValue)
			{
				Try
				{
					New-ItemProperty -Path $KeyPath -Name "PnPCapabilities" -Value 24 -PropertyType DWord | Out-Null
					Write-Host """$PhysicalAdapterName"" - The option ""Allow the computer to turn off this device to save power"" was disabled."
				}
				Catch
				{
					Write-Host "Setting the value of properties of PnpCapabilities failed." -ForegroundColor Red
				}
			}
		}
		Else
		{
			Write-Warning "The path ($KeyPath) not found."
		}
	}
            
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Network Adapter Power Saving"
        Write-Host "END STEP: $global:stepNumber : Disable Network Adapter Power Saving" 
        $global:stepNumber++
    }
}



# OPS FUNCTIONS

Function Enable-F8BootMenu {
    # TESTED: GOOD
    [CmdletBinding(SupportsShouldProcess)]
    Param ()

    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable F8 Boot Menu"
        Write-Host "START STEP: $global:stepNumber : Enable F8 Boot Menu" 
    }
    Process {
        try {
            bcdedit /set `{current`} BootMenuPolicy Legacy | Out-Null
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable F8 Boot Menu"
        Write-Host "END STEP: $global:stepNumber : Enable F8 Boot Menu" 
        $global:stepNumber++
    }
}



# NETWORK FUNCTIONS

Function Set-CurrentNetworkPrivate {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Set Current Network to Private"
        Write-Host "START STEP: $global:stepNumber : Set Current Network to Private" 
    }
    Process {
        try {
            if((Get-NetConnectionProfile).NetworkCategory -ne "DomainAuthenticated"){
                Set-NetConnectionProfile -NetworkCategory Private
                Write-Log -Path $global:logFile -Level Info -Message "SET: Network profile to PRIVATE"
            } else {
                Write-Log -Path $global:logFile -Level Info -Message "NO CHANGE: Network Profile is Domain Authenticated. "
            }
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Set Current Network to Private"
        Write-Host "END STEP: $global:stepNumber : Set Current Network to Private" 
        $global:stepNumber++
    }
}

Function Enable-NetworkDeviceAutoInstall {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable Network Device Auto-Install"
        Write-Host "START STEP: $global:stepNumber : Enable Network Device Auto-Install" 
    }
    Process {
        try {
            Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private" -Name "AutoSetup" -ErrorAction SilentlyContinue
            Write-Log -Path $global:logFile -Level Info -Message "REMOVED: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private\AutoSetup"
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable Network Device Auto-Install"
        Write-Host "END STEP: $global:stepNumber : Enable Network Device Auto-Install" 
        $global:stepNumber++
    }
}

Function Disable-InternetConnectionSharing {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Internet Connection Sharing"
        Write-Host "START STEP: $global:stepNumber : Disable Internet Connection Sharing" 
    }
    Process {
        try {
            if (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections")){
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections" -Name "NC_ShowSharedAccessUI" -Type DWord -Value 0    
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections\NC_ShowSharedAccessUI, 0"        
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Internet Connection Sharing"
        Write-Host "END STEP: $global:stepNumber : Disable Internet Connection Sharing" 
        $global:stepNumber++
    }
}




# EXPERIENCE FUNCTIONS

Function Disable-SharedExperiences {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Shared Experiences"
        Write-Host "START STEP: $global:stepNumber : Disable Shared Experiences" 
    }
    Process {
        try {
            $disableSharedExperiences = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP"
                registryKeyName = "RomeSdkChannelUserAuthzPolicy"
                registryKeyType = "DWord"
                registryKeyValue = 0
            }
            Update-KeyForAllUsers @disableSharedExperiences
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Shared Experiences"
        Write-Host "END STEP: $global:stepNumber : Disable Shared Experiences" 
        $global:stepNumber++
    }
}

Function Enable-ClipboardHistory {
    # TESTED: Good  
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable Clipboard History"
        Write-Host "START STEP: $global:stepNumber : Enable Clipboard History" 
    }
    Process {
        try {
            $enableClipboardHistory = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP"
                registryKeyName = "RomeSdkChannelUserAuthzPolicy"
                registryKeyType = "DWord"
                registryKeyValue = 0
            }
            Update-KeyForAllUsers @enableClipboardHistory
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable Clipboard History"
        Write-Host "END STEP: $global:stepNumber : Enable Clipboard History" 
        $global:stepNumber++
    }
}

Function Enable-StorageSense {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable Storage Sense"
        Write-Host "START STEP: $global:stepNumber : Enable Storage Sense" 
    }
    Process {
        try {
            $enableStorageSense1 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy"
                registryKeyName = "01"
                registryKeyType = "DWord"
                registryKeyValue = 1
            }
            $enableStorageSense2 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy"
                registryKeyName = "StoragePoliciesNotified"
                registryKeyType = "DWord"
                registryKeyValue = 1
            }

            Update-KeyForAllUsers @enableStorageSense1
            Update-KeyForAllUsers @enableStorageSense2
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable Storage Sense"
        Write-Host "END STEP: $global:stepNumber : Enable Storage Sense" 
        $global:stepNumber++
    }
}

Function Disable-ActionCenter {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Action Center"
        Write-Host "START STEP: $global:stepNumber : Disable Action Center" 
    }
    Process {
        try {
            $disableActionCenter1 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Policies\Microsoft\Windows\Explorer"
                registryKeyName = "DisableNotificationCenter"
                registryKeyType = "DWord"
                registryKeyValue = 1
            }
            $disableActionCenter2 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Policies\Microsoft\Windows\Explorer"
                registryKeyName = "ToastEnabled"
                registryKeyType = "DWord"
                registryKeyValue = 0
            }
            Update-KeyForAllUsers @disableActionCenter1
            Update-KeyForAllUsers @disableActionCenter2
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Action Center"
        Write-Host "END STEP: $global:stepNumber : Disable Action Center" 
        $global:stepNumber++
    }
}

Function Disable-ShowNetworkOnLockScreen {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Network Display on Lock Screen"
        Write-Host "START STEP: $global:stepNumber : Disable Network Display on Lock Screen" 
    }
    Process {
        try {
            if (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System")){
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "DontDisplayNetworkSelectionUI" -Type DWord -Value 1 
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\DontDisplayNetworkSelectionUI, 1"
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Network Display on Lock Screen"
        Write-Host "END STEP: $global:stepNumber : Disable Network Display on Lock Screen" 
        $global:stepNumber++
    }
}

Function Disable-ShowShutdownOnLockScreen {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Shutdown from Lock Screen"
        Write-Host "START STEP: $global:stepNumber : Disable Shutdown from Lock Screen" 
    }
    Process {
        try {
            if (!(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System")){
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ShutdownWithoutLogon" -Type DWord -Value 0
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\ShutdownWithoutLogon, 0"
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Shutdown from Lock Screen"
        Write-Host "END STEP: $global:stepNumber : Disable Shutdown from Lock Screen" 
        $global:stepNumber++
    }
}

Function Disable-LockScreenBlur {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Lock Screen Blur"
        Write-Host "START STEP: $global:stepNumber : Disable Lock Screen Blur" 
    }
    Process {
        try {
            if (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System")){
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "DisableAcrylicBackgroundOnLogon" -Type DWord -Value 1
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\DisableAcrylicBackgroundOnLogon, 1"
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Lock Screen Blur"
        Write-Host "END STEP: $global:stepNumber : Disable Lock Screen Blur" 
        $global:stepNumber++
    }
}

Function Enable-ShowTaskManagerDetail {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Show Task Manager Detail"
        Write-Host "START STEP: $global:stepNumber : Show Task Manager Detail" 
    }
    Process {  
        try {
            $taskmgr = Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -PassThru
            $timeout = 30000
            $sleep = 100
            do {
                Start-Sleep -Milliseconds $sleep
                $timeout -= $sleep
                $preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
            } until ($preferences -or $timeout -le 0)
            Stop-Process $taskmgr
            if ($preferences){
                $preferences.Preferences[28] = 0
                $enableTaskManagerDetail = @{
                    action = "Update"
                    registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager"
                    registryKeyName = "Preferences"
                    registryKeyType = "Binary"
                    registryKeyValue = $preferences.Preferences
                }
                Update-KeyForAllUsers @enableTaskManagerDetail
            }                    
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Show Task Manager Detail"
        Write-Host "END STEP: $global:stepNumber : Show Task Manager Detail" 
        $global:stepNumber++
    }
}

Function Enable-ShowFileOperationDetail {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Show File Operation Details"
        Write-Host "START STEP: $global:stepNumber : Show File Operation Details" 
    }
    Process {
        try {
            $showFileOperationDetail = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager"
                registryKeyName = "EnthusiastMode"
                registryKeyType = "DWord"
                registryKeyValue = 1
            }
            Update-KeyForAllUsers @showFileOperationDetail
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Show File Operation Details"
        Write-Host "END STEP: $global:stepNumber : Show File Operation Details" 
        $global:stepNumber++
    }
}

Function Disable-TaskbarSearchBar {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Taskbar Search Bar"
        Write-Host "START STEP: $global:stepNumber : Disable Taskbar Search Bar" 
    }
    Process {
        try {
            $disableTaskbarSearchBar = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
                registryKeyName = "SearchboxTaskbarMode"
                registryKeyType = "DWord"
                registryKeyValue = 0
            }
            Update-KeyForAllUsers @disableTaskbarSearchBar
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Taskbar Search Bar"
        Write-Host "END STEP: $global:stepNumber : Disable Taskbar Search Bar" 
        $global:stepNumber++
    }
}

Function Enable-TaskbarCombineWhenFull {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable Taskbar Icon Combine When Full"
        Write-Host "START STEP: $global:stepNumber : Enable Taskbar Icon Combine When Full" 
    }
    Process {
        try {
            $enableTaskbarCombine1 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
                registryKeyName = "TaskbarGlomLevel"
                registryKeyType = "DWord"
                registryKeyValue = 1
            }
            $enableTaskbarCombine2 = @{
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
                registryKeyName = "MMTaskbarGlomLevel"
                registryKeyType = "DWord"
                registryKeyValue = 1
            }
            Update-KeyForAllUsers @enableTaskbarCombine1
            Update-KeyForAllUsers @enableTaskbarCombine2
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable Taskbar Icon Combine When Full"
        Write-Host "END STEP: $global:stepNumber : Enable Taskbar Icon Combine When Full" 
        $global:stepNumber++
    }
}

Function Disable-UnknownExtensionStoreAppSearch {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable App Store Search for Unknown File Extensions"
        Write-Host "START STEP: $global:stepNumber : Disable App Store Search for Unknown File Extensions" 
    }
    Process {
        try {
            if (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer")){
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoUseStoreOpenWith" -Type DWord -Value 1  
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer\NoUseStoreOpenWith, 1"
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable App Store Search for Unknown File Extensions"
        Write-Host "END STEP: $global:stepNumber : Disable App Store Search for Unknown File Extensions" 
        $global:stepNumber++
    }
}

Function Set-ControlPanelUseSmallIcons {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Control Panel - Use Small Icons"
        Write-Host "START STEP: $global:stepNumber : Control Panel - Use Small Icons" 
    }
    Process {
        try {
            $controlPanelSmallIcons1 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel"
                registryKeyName = "StartupPage"
                registryKeyType = "DWord"
                registryKeyValue = 1
            }
            $controlPanelSmallIcons2 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel"
                registryKeyName = "AllItemsIconView"
                registryKeyType = "DWord"
                registryKeyValue = 1
            }
            Update-KeyForAllUsers @controlPanelSmallIcons1
            Update-KeyForAllUsers @controlPanelSmallIcons2
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Control Panel - Use Small Icons"
        Write-Host "END STEP: $global:stepNumber : Control Panel - Use Small Icons" 
        $global:stepNumber++
    }
}

Function Disable-AddShortcutToName {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Adding `"Shortcut`" to Shortcut Names"
        Write-Host "START STEP: $global:stepNumber : Disable Adding `"Shortcut`" to Shortcut Names" 
    }
    Process {
        try {
            $disableShortcutName = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
                registryKeyName = "link"
                registryKeyType = "Binary"
                registryKeyValue = ([byte[]](0,0,0,0))
            }
            Update-KeyForAllUsers @disableShortcutName
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Adding `"Shortcut`" to Shortcut Names"
        Write-Host "END STEP: $global:stepNumber : Disable Adding `"Shortcut`" to Shortcut Names" 
        $global:stepNumber++
    }
}

Function Set-VisualEffectsForPerformance {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Adjust Visual Effects for Performance"
        Write-Host "START STEP: $global:stepNumber : Adjust Visual Effects for Performance" 
    }
    Process {
        try {
            $visualEffectsPerformance1 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Control Panel\Desktop"
                registryKeyName = "DragFullWindows"
                registryKeyType = "String"
                registryKeyValue = 0
            }
            Update-KeyForAllUsers @visualEffectsPerformance1
            
            $visualEffectsPerformance2 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Control Panel\Desktop"
                registryKeyName = "MenuShowDelay"
                registryKeyType = "String"
                registryKeyValue = 0
            }
            Update-KeyForAllUsers @visualEffectsPerformance2
            
            $visualEffectsPerformance3 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Control Panel\Desktop"
                registryKeyName = "UserPreferencesMask"
                registryKeyType = "Binary"
                registryKeyValue = ([byte[]](144,18,3,128,16,0,0,0))
            }
            Update-KeyForAllUsers @visualEffectsPerformance3
            
            $visualEffectsPerformance4 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Control Panel\Desktop\WindowMetrics"
                registryKeyName = "MinAnimate"
                registryKeyType = "String"
                registryKeyValue = 0
            }
            Update-KeyForAllUsers @visualEffectsPerformance4
            
            $visualEffectsPerformance5 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Control Panel\Keyboard"
                registryKeyName = "KeyboardDelay"
                registryKeyType = "DWord"
                registryKeyValue = 0
            }
            Update-KeyForAllUsers @visualEffectsPerformance5
            
            $visualEffectsPerformance6 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
                registryKeyName = "ListviewAlphaSelect"
                registryKeyType = "DWord"
                registryKeyValue = 0
            }
            Update-KeyForAllUsers @visualEffectsPerformance6
            
            $visualEffectsPerformance7 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
                registryKeyName = "ListviewShadow"
                registryKeyType = "DWord"
                registryKeyValue = 0
            }
            Update-KeyForAllUsers @visualEffectsPerformance7
            
            $visualEffectsPerformance8 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
                registryKeyName = "TaskbarAnimations"
                registryKeyType = "DWord"
                registryKeyValue = 0
            }
            Update-KeyForAllUsers @visualEffectsPerformance8
            
            $visualEffectsPerformance9 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
                registryKeyName = "VisualFXSetting"
                registryKeyType = "DWord"
                registryKeyValue = 3
            }
            Update-KeyForAllUsers @visualEffectsPerformance9
            
            $visualEffectsPerformance10 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\DWM"
                registryKeyName = "EnableAeroPeek"
                registryKeyType = "DWord"
                registryKeyValue = 1
            }
            Update-KeyForAllUsers @visualEffectsPerformance10
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Adjust Visual Effects for Performance"
        Write-Host "END STEP: $global:stepNumber : Adjust Visual Effects for Performance" 
        $global:stepNumber++
    }
}

# DONT INCLUDE THE BELOW. LOOKS *SO* GROSS
# DOES NOT APPLY TO TASKBAR AND WHATNOT, DOES TO EXPLORER
Function Set-DarkTheme {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Apply Dark Theme"
        Write-Host "START STEP: $global:stepNumber : Apply Dark Theme" 
    }
    Process {
        try {
            $setDarkTheme = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
                registryKeyName = "AppsUseLightTheme"
                registryKeyType = "DWord"
                registryKeyValue = 0
            }
            Update-KeyForAllUsers @setDarkTheme
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Apply Dark Theme"
        Write-Host "END STEP: $global:stepNumber : Apply Dark Theme" 
        $global:stepNumber++
    }
}

Function Enable-NumLock {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable Num Lock"
        Write-Host "START STEP: $global:stepNumber : Enable Num Lock" 
    }
    Process {
        try {
            if ((Get-WmiObject -Class Win32_ComputerSystem).PCSystemType -ne 2){
                if (!(Test-Path -Path "HKU:")){
                    New-PSDrive -Name "HKU" -PSProvider "Registry" -Root "HKEY_USERS" | Out-Null
                }
                Set-ItemProperty -Path "HKU:\.DEFAULT\Control Panel\Keyboard" -Name "InitialKeyboardIndicators" -Type DWord -Value 2147483650
                Add-Type -AssemblyName System.Windows.Forms
                if (!([System.Windows.Forms.Control]::IsKeyLocked('NumLock'))){
                    $wsh = New-Object -ComObject WScript.Shell
                    $wsh.SendKeys('{NUMLOCK}')
                }
            }
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable Num Lock"
        Write-Host "END STEP: $global:stepNumber : Enable Num Lock" 
        $global:stepNumber++
    }
}

Function Enable-EnhancedPointerPrecision { 
    # TESTED: Good 
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable Enhanced Pointer Precision"
        Write-Host "START STEP: $global:stepNumber : Enable Enhanced Pointer Precision" 
    }
    Process {
        try {
            $enablePointerPrecision1 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Control Panel\Mouse"
                registryKeyName = "MouseSpeed"
                registryKeyType = "String"
                registryKeyValue = "1"
            }
            $enablePointerPrecision2 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Control Panel\Mouse"
                registryKeyName = "MouseThreshold1"
                registryKeyType = "String"
                registryKeyValue = "6"
            }
            $enablePointerPrecision3 = @{
                action = "Update"
                registryKeyPath = "HKCU:\Control Panel\Mouse"
                registryKeyName = "MouseThreshold2"
                registryKeyType = "String"
                registryKeyValue = "10"
            }
            Update-KeyForAllUsers @enablePointerPrecision1
            Update-KeyForAllUsers @enablePointerPrecision2
            Update-KeyForAllUsers @enablePointerPrecision3
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable Enhanced Pointer Precision"
        Write-Host "END STEP: $global:stepNumber : Enable Enhanced Pointer Precision" 
        $global:stepNumber++
    }
}

Function Enable-VerboseStatusMessages {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable Verbose Status Messages"
        Write-Host "START STEP: $global:stepNumber : Enable Verbose Status Messages" 
    }
    Process {
        try {
            If ((Get-CimInstance -Class "Win32_OperatingSystem").ProductType -eq 1) {
                Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "VerboseStatus" -Type DWord -Value 1
                Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\VerboseStatus, 1"
            } Else {
                Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "VerboseStatus" -ErrorAction SilentlyContinue
                Write-Log -Path $global:logFile -Level Info -Message "REMOVED: HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\VerboseStatus"
            }            
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable Verbose Status Messages"
        Write-Host "END STEP: $global:stepNumber : Enable Verbose Status Messages" 
        $global:stepNumber++
    }
}

Function Disable-GameFullScreenOptimisations {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Gaming Optimisations"
        Write-Host "START STEP: $global:stepNumber : Disable Gaming Optimisations" 
    }
    Process {
        try {
            $disableGameFullScreenOpts1 = @{
                action = "Update"
                registryKeyPath = "HKCU:\System\GameConfigStore"
                registryKeyName = "GameDVR_DXGIHonorFSEWindowsCompatible"
                registryKeyType = "DWord"
                registryKeyValue = 1
            }
            Update-KeyForAllUsers @disableGameFullScreenOpts1

            $disableGameFullScreenOpts2 = @{
                action = "Update"
                registryKeyPath = "HKCU:\System\GameConfigStore"
                registryKeyName = "GameDVR_FSEBehavior"
                registryKeyType = "DWord"
                registryKeyValue =  2
            }
            Update-KeyForAllUsers @disableGameFullScreenOpts2

            $disableGameFullScreenOpts3 = @{
                action = "Update"
                registryKeyPath = "HKCU:\System\GameConfigStore"
                registryKeyName = "GameDVR_FSEBehaviorMode"
                registryKeyType = "DWord"
                registryKeyValue = 2
            }
            Update-KeyForAllUsers @disableGameFullScreenOpts3

            $disableGameFullScreenOpts4 = @{
                action = "Update"
                registryKeyPath = "HKCU:\System\GameConfigStore"
                registryKeyName = "GameDVR_HonorUserFSEBehaviorMode"
                registryKeyType = "DWord"
                registryKeyValue = 1
            }
            Update-KeyForAllUsers @disableGameFullScreenOpts4
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Gaming Optimisations"
        Write-Host "END STEP: $global:stepNumber : Disable Gaming Optimisations" 
        $global:stepNumber++
    }
}

Function Disable-InternetExplorerFirstRunWizard {   
    # TESTED: Good        
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Internet Explorer First Run Wizard"
        Write-Host "START STEP: $global:stepNumber : Disable Internet Explorer First Run Wizard" 
    }
    Process {
        try {
            if (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main")){
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize" -Type DWord -Value 1
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main\DisableFirstRunCustomize, 1"
                    
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Internet Explorer First Run Wizard"
        Write-Host "END STEP: $global:stepNumber : Disable Internet Explorer First Run Wizard" 
        $global:stepNumber++
    }
}

Function Disable-FirstLogonAnimation {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable First Logon Animation"
        Write-Host "START STEP: $global:stepNumber : Disable First Logon Animation" 
    }
    Process {
        try {
            if (!(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System")){
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableFirstLogonAnimation" -Type DWord -Value 0     
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\EnableFirstLogonAnimation, 0"     
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable First Logon Animation"
        Write-Host "END STEP: $global:stepNumber : Disable First Logon Animation" 
        $global:stepNumber++
    }
}

Function Disable-MediaSharing {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Media Sharing"
        Write-Host "START STEP: $global:stepNumber : Disable Media Sharing" 
    }
    Process {
        try {
            if (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer")){
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer" -Name "PreventLibrarySharing" -Type DWord -Value 1    
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer\PreventLibrarySharing, 1" 
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Media Sharing"
        Write-Host "END STEP: $global:stepNumber : Disable Media Sharing" 
        $global:stepNumber++
    }
}

Function Enable-PhotoViewerFileAssociations {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable Photo Viewer File Associations"
        Write-Host "START STEP: $global:stepNumber : Enable Photo Viewer File Associations" 
    }
    Process {
        try {
            if (!(Test-Path -Path "HKCR:")){
                Write-Log -Path $global:logFile -Level Info -Message "NOT MOUNTED: HKCR. Mounting..."
                New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
            }
            foreach ($type in @("Paint.Picture", "giffile", "jpegfile", "pngfile")){
                Write-Log -Path $global:logFile -Level Info -Message "Enabling Photo Viewer file associations for $type.ToUpper()"
                New-Item -Path $("HKCR:\$type\shell\open") -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKCR:\$type\shell\open"
                New-Item -Path $("HKCR:\$type\shell\open\command") | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKCR:\$type\shell\open\command"
                Set-ItemProperty -Path $("HKCR:\$type\shell\open") -Name "MuiVerb" -Type ExpandString -Value "@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3043"
                Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKCR:\$type\shell\open\MuiVerb, @%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3043"
                Set-ItemProperty -Path $("HKCR:\$type\shell\open\command") -Name "(Default)" -Type ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
                Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKCR:\$type\shell\open\command\(Default), %SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
            }                    
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable Photo Viewer File Associations"
        Write-Host "END STEP: $global:stepNumber : Enable Photo Viewer File Associations" 
        $global:stepNumber++
    }


}

Function Enable-PhotoViewerOpenWith {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable Photo Viewer Open With Menu"
        Write-Host "START STEP: $global:stepNumber : Enable Photo Viewer Open With Menu" 
    }
    Process {
        try {
            if (!(Test-Path -Path "HKCR:")){
                Write-Log -Path $global:logFile -Level Info -Message ""
                New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
            }
            New-Item -Path "HKCR:\Applications\photoviewer.dll\shell\open\command" -Force | Out-Null
            Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKCR:\Applications\photoviewer.dll\shell\open\command"
            New-Item -Path "HKCR:\Applications\photoviewer.dll\shell\open\DropTarget" -Force | Out-Null
            Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKCR:\Applications\photoviewer.dll\shell\open\DropTarget"
            Set-ItemProperty -Path "HKCR:\Applications\photoviewer.dll\shell\open" -Name "MuiVerb" -Type String -Value "@photoviewer.dll,-3043"
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKCR:\Applications\photoviewer.dll\shell\open\MuiVerb, @photoviewer.dll,-3043"
            Set-ItemProperty -Path "HKCR:\Applications\photoviewer.dll\shell\open\command" -Name "(Default)" -Type ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKCR:\Applications\photoviewer.dll\shell\open\command\(Default), %SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
            Set-ItemProperty -Path "HKCR:\Applications\photoviewer.dll\shell\open\DropTarget" -Name "Clsid" -Type String -Value "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"  
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKCR:\Applications\photoviewer.dll\shell\open\DropTarget\Clsid, {FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable Photo Viewer Open With Menu"
        Write-Host "END STEP: $global:stepNumber : Enable Photo Viewer Open With Menu" 
        $global:stepNumber++
    }
}

Function Set-InternetExplorerDefaultSearchEngineGoogle {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Set Google to Internet Explorer Default Search Engine"
        Write-Host "START STEP: $global:stepNumber : Set Google to Internet Explorer Default Search Engine" 
    }
    Process {
        try {
            $newSearchGuid = [GUID]::NewGuid()
            $newSearchGuidString = $newSearchGuid.ToString()
            $newSearchGuidString = $newSearchGuidString.ToUpper()
            $newSearchGuidString = "{" + $newSearchGuidString + "}"
            if (!(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\SearchScopes")){
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\SearchScopes" -Force | Out-Null
                Write-Host -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Microsoft\Internet Explorer\SearchScopes"
                New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\SearchScopes" -Name "DefaultScope" -Value $newSearchGuidString -Type "String"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\SearchScopes" -Name "DefaultScope" -Value $newSearchGuidString -Type "String" | Out-Null
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Microsoft\Internet Explorer\SearchScopes\$newSearchGuidString"
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\SearchScopes" -Name $newSearchGuidString -Force | Out-Null
            Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Microsoft\Internet Explorer\SearchScopes\$newSearchGuidString"
            New-ItemProperty $(Join-Path -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\SearchScopes" -ChildPath $newSearchGuidString) -Name "DisplayName" -Type "String" -Value "Google" | Out-Null
            Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Microsoft\Internet Explorer\SearchScopes\$newSearchGuidString\DisplayName, Google"
            New-ItemProperty $(Join-Path -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\SearchScopes" -ChildPath $newSearchGuidString) -Name "FaviconURL" -Type "String" -Value "http://www.google.com/favicon.ico" | Out-Null
            Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Microsoft\Internet Explorer\SearchScopes\$newSearchGuidString\FaviconURL, http://www.google.com/favicon.ico"
            New-ItemProperty $(Join-Path -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\SearchScopes" -ChildPath $newSearchGuidString) -Name "ShowSearchSuggestions" -Type "DWORD" -Value 1 | Out-Null
            Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Microsoft\Internet Explorer\SearchScopes\$newSearchGuidString\ShowSearchSuggestions, 1"
            New-ItemProperty $(Join-Path -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\SearchScopes" -ChildPath $newSearchGuidString) -Name "SuggestionsURL" -Type "String" -Value "http://clients5.google.com/complete/search?q={searchTerms}&client=ie8&mw={ie:maxWidth}&sh={ie:sectionHeight}&rh={ie:rowHeight}&inputencoding={inputEncoding}&outputencoding={outputEncoding}" | Out-Null
            Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Microsoft\Internet Explorer\SearchScopes\$newSearchGuidString\SuggestionsURL, http://clients5.google.com/complete/search?q={searchTerms}&client=ie8&mw={ie:maxWidth}&sh={ie:sectionHeight}&rh={ie:rowHeight}&inputencoding={inputEncoding}&outputencoding={outputEncoding}"
            New-ItemProperty $(Join-Path -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\SearchScopes" -ChildPath $newSearchGuidString) -Name "URL" -Type "String" -Value "http://www.google.com/search?q={searchTerms}" | Out-Null
            Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Microsoft\Internet Explorer\SearchScopes\$newSearchGuidString\URL, http://www.google.com/search?q={searchTerms}"
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Set Google to Internet Explorer Default Search Engine"
        Write-Host "END STEP: $global:stepNumber : Set Google to Internet Explorer Default Search Engine" 
        $global:stepNumber++
    }
}

Function Disable-TipsTricksNotifications {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Tips & Tricks Notifications"
        Write-Host "START STEP: $global:stepNumber : Disable Tips & Tricks Notifications" 
    }
    Process {
        try {
            $disableTipsTricks1 = @{
                action = "Update"
                registryKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
                registryKeyName = "SubscribedContent-338389Enabled"
                registryKeyType = "DWord"
                registryKeyValue = 0
            }
            Update-KeyForAllUsers @disableTipsTricks1            
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Tips & Tricks Notifications"
        Write-Host "END STEP: $global:stepNumber : Disable Tips & Tricks Notifications" 
        $global:stepNumber++
    }
}



# SOUND FUNCTIONS

Function Set-ActiveSchemeNoSounds {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Set No Sounds to Active Sound Scheme"
        Write-Host "START STEP: $global:stepNumber : Set No Sounds to Active Sound Scheme" 
    }
    Process {
        try {
            $SoundScheme = ".None"
            Get-ChildItem -Path "HKCU:\AppEvents\Schemes\Apps\*\*" | ForEach-Object {
                # If scheme keys do not exist in an event, create empty ones (similar behavior to Sound control panel).
                if (!(Test-Path -Path "$($_.PsPath)\$($SoundScheme)")){
                    New-Item -Path "$($_.PsPath)\$($SoundScheme)" | Out-Null
                }
                if (!(Test-Path -Path "$($_.PsPath)\.Current")){
                    New-Item -Path "$($_.PsPath)\.Current" | Out-Null
                }
                # Get a regular string from any possible kind of value, i.e. resolve REG_EXPAND_SZ, copy REG_SZ or empty from non-existing.
                $Data = (Get-ItemProperty -Path "$($_.PsPath)\$($SoundScheme)" -Name "(Default)" -ErrorAction SilentlyContinue)."(Default)"
                # Replace any kind of value with a regular string (similar behavior to Sound control panel).
                Set-ItemProperty -Path "$($_.PsPath)\$($SoundScheme)" -Name "(Default)" -Type String -Value $Data
                # Copy data from source scheme to current.
                Set-ItemProperty -Path "$($_.PsPath)\.Current" -Name "(Default)" -Type String -Value $Data
            }
            Set-ItemProperty -Path "HKCU:\AppEvents\Schemes" -Name "(Default)" -Type String -Value $SoundScheme
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Set No Sounds to Active Sound Scheme"
        Write-Host "END STEP: $global:stepNumber : Set No Sounds to Active Sound Scheme" 
        $global:stepNumber++
    }
}

Function Disable-StartupSound {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Startup Sound"
        Write-Host "START STEP: $global:stepNumber : Disable Startup Sound"
    }
    Process {
        try {
            if (!(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation")){
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation" -Name "DisableStartupSound" -Type DWord -Value 1 
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation\DisableStartupSound, 1"           
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Startup Sound"
        Write-Host "END STEP: $global:stepNumber : Disable Startup Sound" 
        $global:stepNumber++
    }
}



# WINDOWS EXPLORER FUNCTIONS

Function Enable-ExplorerShowFullTitlePath {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Show Explorer Full Title Path"
        Write-Host "START STEP: $global:stepNumber : Show Explorer Full Title Path" 
    }
    Process {
        try {
            $enableExplorerFullTitle = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState"
                registryKeyName = "FullPath"
                registryKeyType = "DWord"
                registryKeyValue = 1
            }
            Update-KeyForAllUsers @enableExplorerFullTitle
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Show Explorer Full Title Path"
        Write-Host "END STEP: $global:stepNumber : Show Explorer Full Title Path" 
        $global:stepNumber++
    }
}

Function Enable-ExplorerShowKnownExtensions {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {       
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Show Known File Extensions"
        Write-Host "START STEP: $global:stepNumber : Show Known File Extensions" 
    }
    Process {
        try {
            $enableExplorerShowExtensions = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
                registryKeyName = "HideFileExt"
                registryKeyType = "DWord"
                registryKeyValue = 0
            }
            Update-KeyForAllUsers @enableExplorerShowExtensions
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Show Known File Extensions"
        Write-Host "END STEP: $global:stepNumber : Show Known File Extensions" 
        $global:stepNumber++
    }
}

Function Enable-ExplorerShowHiddenFiles {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Show Hidden Files"
        Write-Host "START STEP: $global:stepNumber : Show Hidden Files" 
    }
    Process {
        try {
            $enableExplorerShowHiddenFiles = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
                registryKeyName = "Hidden"
                registryKeyType = "DWord"
                registryKeyValue = 1
            }
            Update-KeyForAllUsers @enableExplorerShowHiddenFiles
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Show Hidden Files"
        Write-Host "END STEP: $global:stepNumber : Show Hidden Files" 
        $global:stepNumber++
    }
}

Function Enable-ExplorerShowFolderMergeConflicts {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Show Folder Merge Conflicts"
        Write-Host "START STEP: $global:stepNumber : Show Folder Merge Conflicts" 
    }
    Process {
        try {
            $enableExplorerShowMergeConflicts = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
                registryKeyName = "HideMergeConflicts"
                registryKeyType = "DWord"
                registryKeyValue = 0
            }
            Update-KeyForAllUsers @enableExplorerShowMergeConflicts
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Show Folder Merge Conflicts"
        Write-Host "END STEP: $global:stepNumber : Show Folder Merge Conflicts" 
        $global:stepNumber++
    }
}

Function Enable-ExplorerExpandedNavPane {   
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Enable Explorer Expanded Navigation Pane"
        Write-Host "START STEP: $global:stepNumber : Enable Explorer Expanded Navigation Pane" 
    }
    Process {
        try {
            $enableExplorerExpandedNav = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
                registryKeyName = "NavPaneExpandToCurrentFolder"
                registryKeyType = "DWord"
                registryKeyValue = 1
            }
            Update-KeyForAllUsers @enableExplorerExpandedNav
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Enable Explorer Expanded Navigation Pane"
        Write-Host "END STEP: $global:stepNumber : Enable Explorer Expanded Navigation Pane" 
        $global:stepNumber++
    }
}

Function Enable-ExplorerEncryptedFileColour {
    # TESTED
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Show Encrypted Files in Colour"
        Write-Host "START STEP: $global:stepNumber : Show Encrypted Files in Colour" 
    }
    Process {
        try {
            $enableExplorerEncryptedColour = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
                registryKeyName = "howEncryptCompressedColor"
                registryKeyType = "DWord"
                registryKeyValue = 1
            }
            Update-KeyForAllUsers @enableExplorerEncryptedColour
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Show Encrypted Files in Colour"
        Write-Host "END STEP: $global:stepNumber : Show Encrypted Files in Colour" 
        $global:stepNumber++
    }
}

Function Set-ExplorerOpenThisPC {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Explorer - Open at `" This PC`" by Default"
        Write-Host "START STEP: $global:stepNumber : Explorer - Open at `" This PC`" by Default" 
    }
    Process {
        try {
            $showExplorerThisPC = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
                registryKeyName = "LaunchTo"
                registryKeyType = "DWord"
                registryKeyValue = 1
            }
            Update-KeyForAllUsers @showExplorerThisPC
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Explorer - Open at `" This PC`" by Default"
        Write-Host "END STEP: $global:stepNumber : Explorer - Open at `" This PC`" by Default" 
        $global:stepNumber++
    }
}

Function Disable-Explorer3DObjectsThisPC {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable 3D Objects Folder"
        Write-Host "START STEP: $global:stepNumber : Disable 3D Objects Folder" 
    }
    Process {
        try {
            Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Recurse -ErrorAction SilentlyContinue     
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable 3D Objects Folder"
        Write-Host "END STEP: $global:stepNumber : Disable 3D Objects Folder" 
        $global:stepNumber++
    }
}

Function Disable-Explorer3DObjects {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    # Disassembler
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable 3D Objects Folder in Explorer"
        Write-Host "START STEP: $global:stepNumber : Disable 3D Objects Folder in Explorer" 
    }
    Process {
        try {
            If (!(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag")) {
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
            If (!(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag")) {
                New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag\ThisPCPolicy, Hide"
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable 3D Objects Folder in Explorer"
        Write-Host "END STEP: $global:stepNumber : Disable 3D Objects Folder in Explorer" 
        $global:stepNumber++
    }
}

Function Disable-ExplorerThumbnailCache {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Thumbnail Cache"
        Write-Host "START STEP: $global:stepNumber : Disable Thumbnail Cache" 
    }
    Process {
        try {
            $disableExplorerThumbnailCache = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
                registryKeyName = "DisableThumbnailCache"
                registryKeyType = "DWord"
                registryKeyValue = 1
            }
            Update-KeyForAllUsers @disableExplorerThumbnailCache
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Thumbnail Cache"
        Write-Host "END STEP: $global:stepNumber : Disable Thumbnail Cache" 
        $global:stepNumber++
    }
}

Function Disable-ExplorerThumbnailNetworkCache {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Thumbnails for Network Folders"
        Write-Host "START STEP: $global:stepNumber : Disable Thumbnails for Network Folders" 
    }
    Process {
        try {
            $disableExplorerNetworkThumbnailCache = @{
                action = "Update"
                registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
                registryKeyName = "DisableThumbsDBOnNetworkFolders"
                registryKeyType = "DWord"
                registryKeyValue = 1
            }
            Update-KeyForAllUsers @disableExplorerNetworkThumbnailCache
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Thumbnails for Network Folders"
        Write-Host "END STEP: $global:stepNumber : Disable Thumbnails for Network Folders" 
        $global:stepNumber++
    }
}





# APPLICATION FUNCTIONS

Function Disable-AdobeFlash {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Adobe Flash"
        Write-Host "START STEP: $global:stepNumber : Disable Adobe Flash" 
    }
    Process {
        try {
            if (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer")){
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer" -Name "DisableFlashInIE" -Type DWord -Value 1
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\DisableFlashInIE, 1"

            if (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Addons")){
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Addons" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Addons"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Addons" -Name "FlashPlayerEnabled" -Type DWord -Value 0
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Addons\FlashPlayerEnabled, 0"                    
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Adobe Flash"
        Write-Host "END STEP: $global:stepNumber : Disable Adobe Flash" 
        $global:stepNumber++
    }
}

Function Disable-EdgePreload {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Disable Edge Preload"
        Write-Host "START STEP: $global:stepNumber : Disable Edge Preload" 
    }
    Process {
        try {
            if (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main")){
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" -Name "AllowPrelaunch" -Type DWord -Value 0
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main\AllowPrelaunch, 0"

            if (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader")){
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader" -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "CREATED: HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader"
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader" -Name "AllowTabPreloading" -Type DWord -Value 0   
            Write-Log -Path $global:logFile -Level Info -Message "VALUE SET: HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader\AllowTabPreloading, 0"                 
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Disable Edge Preload"
        Write-Host "END STEP: $global:stepNumber : Disable Edge Preload" 
        $global:stepNumber++
    }
}

Function Install-DotNetVersions23 {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Install .NET Framework 2 & 3"
        Write-Host "START STEP: $global:stepNumber : Install .NET Framework 2 & 3" 
    }
    Process {
        try {
            if ((Get-CimInstance -Class "Win32_OperatingSystem").ProductType -eq 1){
                Write-Log -Path $global:logFile -Level Info -Message "Enabling .NET 2 & 3"
                Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "NetFx3" } | Enable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
            } else {
                Write-Log -Path $global:logFile -Level Info -Message "Enabling .NET 2 & 3"
                Install-WindowsFeature -Name "NET-Framework-Core" -WarningAction SilentlyContinue | Out-Null

            }                    
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Install .NET Framework 2 & 3"
        Write-Host "END STEP: $global:stepNumber : Install .NET Framework 2 & 3" 
        $global:stepNumber++
    }
}

Function Uninstall-MathRecognizer {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Uninstall Math Recogniser"
        Write-Host "START STEP: $global:stepNumber : Uninstall Math Recogniser" 
    }
    Process {
        try {
            Write-Log -Path $global:logFile -Level Info -Message "Removing Math Recognizer..."
            Get-WindowsCapability -Online | Where-Object { $_.Name -like "MathRecognizer*" } | Remove-WindowsCapability -Online | Out-Null
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Uninstall Math Recogniser"
        Write-Host "END STEP: $global:stepNumber : Uninstall Math Recogniser"
        $global:stepNumber++
    }
}

Function Uninstall-PowershellV2 {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Uninstall Powershell V2"
        Write-Host "START STEP: $global:stepNumber : Uninstall Powershell V2" 
    }
    Process {
        try {
            if ((Get-CimInstance -Class "Win32_OperatingSystem").ProductType -eq 1){
                Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "MicrosoftWindowsPowerShellV2Root" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
            } else {
                Remove-WindowsFeature -Name "PowerShell-V2" -WarningAction SilentlyContinue | Out-Null
            }            
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Uninstall Powershell V2"
        Write-Host "END STEP: $global:stepNumber : Uninstall Powershell V2" 
        $global:stepNumber++
    }
}

Function Uninstall-HyperV {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Uninstall Hyper-V"
        Write-Host "START STEP: $global:stepNumber : Uninstall Hyper-V" 
    }
    Process {
        try {
            if ((Get-CimInstance -Class "Win32_OperatingSystem").ProductType -eq 1){
                Write-Log -Path $global:logFile -Level Info -Message "UNINSTALLING: All Hyper-V Features"
                Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "Microsoft-Hyper-V-All" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
            } Else {
                Write-Log -Path $global:logFile -Level Info -Message "UNINSTALLING: Hyper-V Windows Feature..."
                Uninstall-WindowsFeature -Name "Hyper-V" -IncludeManagementTools -WarningAction SilentlyContinue | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "UNINSTALLING: Hyper-V Complete."
            }   
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Uninstall Hyper-V"
        Write-Host "END STEP: $global:stepNumber : Uninstall Hyper-V" 
        $global:stepNumber++
    }
}

Function Uninstall-OpenSshClient {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Uninstall OpenSSH Client"
        Write-Host "START STEP: $global:stepNumber : Uninstall OpenSSH Client" 
    }
    Process {
        try {
            Write-Log -Path $global:logFile -Level Info -Message "UNINSTALLING: OpenSSH Client Windows Capability"
            Get-WindowsCapability -Online | Where-Object { $_.Name -like "OpenSSH.Client*" } | Remove-WindowsCapability -Online | Out-Null  
            Write-Log -Path $global:logFile -Level Info -Message "UNINSTALL: Complete: OpenSSH Client"   
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Uninstall OpenSSH Client"
        Write-Host "END STEP: $global:stepNumber : Uninstall OpenSSH Client" 
        $global:stepNumber++
    }
}

Function Uninstall-OpenSshServer {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Uninstall OpenSSH Server"
        Write-Host "START STEP: $global:stepNumber : Uninstall OpenSSH Server" 
    }
    Process {
        try {
            Write-Log -Path $global:logFile -Level Info -Message "UNINSTALLING: OpenSSH Server Windows Capability"
            Get-WindowsCapability -Online | Where-Object { $_.Name -like "OpenSSH.Server*" } | Remove-WindowsCapability -Online | Out-Null
            Wite-Log -Path $global:logFile -Level Info -Message "UNINSTALLING: OpenSSH Server Complete"
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Uninstall OpenSSH Server"
        Write-Host "END STEP: $global:stepNumber : Uninstall OpenSSH Server" 
        $global:stepNumber++
    }
}

Function Install-7Zip {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = "Install 7-Zip (MSI)"
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName" 

        $startLocation = Get-Location

        # Get the product version by querying the HTML, but with Regex nightmares
        $7zDomain = "https://www.7-zip.org/download.html"
        $7zTemp   = (Invoke-WebRequest -uri $7zDomain)
        $7zRegex  = $7zTemp.Content -match 'Download 7-Zip (.*)\s(.*) for Windows'
        if ($7zRegex){
            $ver  = $Matches[1]
        }
        $7zVersion = $ver.Replace(".","")
        $Product = "7-Zip"
        $7zArch = "x64"
        $7zInst = "msi"
        $7zDir = "7z" + $7zVersion
        $7zDownloadLocation = Join-Path -Path $generalOutputFolder -ChildPath $7zDir
        if (!(Test-Path -Path $7zDownloadLocation)){
            Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Creating directories"
            New-Item -ItemType Directory -Path $7zDownloadLocation | Out-Null
        }
        $7zFileName = "7z" + $7zVersion + "-" + $7zArch + "." + $7zInst
        Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Setting Arguments"
    }
    Process {
        # Now build the download URI
        [STRING]$7zDownloadUrl = "https://www.7-zip.org/a/7z" + $7zVersion + "-" + $7zArch + "." + $7zInst
        # Now it puts it in it's pocketses
        Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Obtaining latest stable version"
        Invoke-WebRequest -uri $7zDownloadUrl -OutFile (Join-Path -Path $7zDownloadLocation -ChildPath $7zFileName)

        # Installs it
        Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Installing $Product $7zVersion"
        [STRING]$7zInstaller = Join-Path -Path (Join-Path -Path $global:generalOutputFolder -ChildPath $7zVersion) -ChildPath $7zFileName 
        [STRING]$7zInstallArgs = "/i $7zInstaller /qn /norestart"
         try {
            Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Installing version $Version"
            Start-Process msiexec.exe -ArgumentList $7zInstallArgs -Wait -Passthru
        }
        catch {
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Set-Location $startLocation
    }
}

Function Install-MicrosoftLAPS {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [ValidateSet("win32","win64")][STRING]$architecture="win64"
    )

    begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        $startLocation = Get-Location
        
        try {
            Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Obtaining latest available stable software version"
            $lapsUrl = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=46899"
        }
        catch {
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }

        Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Setting Arguments"
        $Vendor = "Microsoft"
        $Product = "LAPS CSE"
        $PackageName = "LAPS.x64"
        $InstallerType = "msi"
        $Source = "$PackageName" + "." + "$InstallerType"
        $LogApp = "${env:SystemRoot}" + "\Temp\$PackageName.log"
        $SourcePath = Join-Path -Path $global:generalOutputFolder -ChildPath $Source
        $msiArgs = "/i $SourcePath /qn /norestart /reboot=REALLYSUPPRESS"
        $ProgressPreference = 'SilentlyContinue'
    }
    process {
        Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Creating directories"
        $VersionPath = Join-Path -Path $global:generalOutputFolder -ChildPath $Version
        if ( -Not (Test-Path -Path $VersionPath)){
            New-Item -ItemType Directory -Path $VersionPath | Out-Null
        }
        Set-Location $VersionPath
        
        try {
            Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Downloading $Vendor $Product version $Version"
            if (!(Test-Path -Path $Source)){
                Invoke-WebRequest -Uri $lapsUrl -OutFile $Source
            } else {
                Remove-Item -Path $Source -Force
                Invoke-WebRequest -Uri $lapsUrl -OutFile $Source
            }
        }
        catch {
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }

        try {
            Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Installing version $Version"
            Start-Process msiexec.exe -ArgumentList $msiArgs -Wait -Passthru | Out-Null
        }
        catch {
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    end {
        Set-Location $startLocation
    }
}

# 01/2021: ISSUE: Not exiting properly
Function Install-GoogleChromeEnterprise {
    # LINK: https://xenappblog.com/2018/download-and-install-latest-google-chrome-enterprise/
    # JH: Modified quite a bit...
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Parameter(Mandatory = $False)]
        [string] $Uri = "https://omahaproxy.appspot.com/all.json",
 
        [Parameter(Mandatory = $False)]
        [ValidateSet('win', 'win64', 'mac', 'linux', 'ios', 'cros', 'android', 'webview')]
        [string] $Platform = "win",
 
        [Parameter(Mandatory = $False)]
        [ValidateSet('stable', 'beta', 'dev', 'canary', 'canary_asan')]
        [string] $Channel = "stable"
    )
 
    begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        $startLocation = Get-Location

        try {
            # Read the JSON and convert to a PowerShell object. Return the current release version of Chrome
            Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Obtaining latest available stable software version"
            $chromeVersions = (Invoke-WebRequest -uri $Uri).Content | ConvertFrom-Json
            $currentChromeVersion = (($chromeVersions | Where-Object { $_.os -eq $Platform }).versions | Where-Object { $_.channel -eq $Channel }).current_version
        }
        catch {
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }

        Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Setting Arguments"
        $Vendor = "Google"
        $Product = "Chrome Enterprise"
        $Version = $currentChromeVersion
        $PackageName = "googlechromestandaloneenterprise64"
        $InstallerType = "msi"
        $Source = "$PackageName" + "." + "$InstallerType"
        $LogApp = "${env:SystemRoot}" + "\Temp\$PackageName.log"
        $UnattendedArgs = "/i $PackageName.$InstallerType ALLUSERS=1 NOGOOGLEUPDATEPING=1 /qn /liewa $LogApp"
        $url = "https://dl.google.com/tag/s/dl/chrome/install/googlechromestandaloneenterprise64.msi"
        $ProgressPreference = 'SilentlyContinue'
    }

    process {
        Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Creating directories"
        $VersionPath = Join-Path -Path $global:generalOutputFolder -ChildPath $Version
        if (-Not (Test-Path -Path $VersionPath)){
            New-Item -ItemType Directory -Path $VersionPath | Out-Null
        }
        Set-Location $VersionPath
        
        try {
            Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Downloading $Vendor $Product $Version"
            if (!(Test-Path -Path $Source)){
                Invoke-WebRequest -Uri $url -OutFile $Source
            } else {
                Write-Log -Path $global:logFile -Level Info -Message "INSTALL $Vendor $Product : File exists. Skipping Download." -Verbose
            }
        }
        catch {
            Write-Log -Path $global:logFile -Level Error $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
        
        try {
            Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Installing version $Version"
            $installer = Start-Process msiexec.exe -ArgumentList $UnattendedArgs -Wait -Passthru
            if ($installer.LastExitCode -ne 0){
                $instLastExit = $installer.LastExitCode
                Write-Log -Path $global:logFile -Level Warn -Message "INSTALL $Vendor $Product : Installer Exit Code: $instLastExit" 
            } else {
                Write-Log -Path $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Installation complete"
            }
        }
        catch {
            Write-Log -Path $global:logFile -Level Error $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }        

        Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Customising services"
        if (Get-Service -Name "gupdate"){
            if ((Get-Service -Name "gupdate").Status -ne "Stopped"){
                Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Customising services"
                Stop-Service -Name "gpupdate" -Force | Out-Null
            }
            Set-Service -Name "gupdate" -StartupType Disabled
        }
        if (Get-Service -Name "gupdatem"){
            if ((Get-Service -Name "gupdatem").Status -ne "Stopped"){
                Stop-Service -Name "gpupdatem" -Force | Out-Null
            }
            Set-Service -Name "gupdatem" -StartupType Disabled
        }
        Unregister-ScheduledTask -TaskName GoogleUpdateTaskMachineCore -Confirm:$false
        Unregister-ScheduledTask -TaskName GoogleUpdateTaskMachineUA -Confirm:$false
        
        Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : INSTALLATION COMPLETE"
    }
    end {
        Set-Location $startLocation
        Get-ChildItem -Path $VersionPath -Recurse -Force | Remove-Item | Out-Null
        Remove-Item $VersionPath -Force | Out-Null
    }
}

Function Install-MozillaFirefoxESR {
    # TESTED: Good
    # SOURCE: https://xenappblog.com/2018/download-and-install-latest-mozilla-firefox/
    # JH: Again, extensively modified
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [ValidateSet("bn-BD","bn-IN","en-CA","en-GB","en-ZA","es-AR","es-CL","es-ES","es-MX")][STRING]$culture = "en-GB",
        [ValidateSet("win32","win64")][STRING]$architecture="win64"
    )

    begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        $startLocation = Get-Location
        
        try {
            # JSON that provide details on Firefox versions
            $uriSource = "https://product-details.mozilla.org/1.0/firefox_versions.json"
            
            # Read the JSON and convert to a PowerShell object
            Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Obtaining latest available stable software version"
            $firefoxVersions = (Invoke-WebRequest -uri $uriSource).Content | ConvertFrom-Json
            $ffurl = "https://download.mozilla.org/?product=firefox-esr-next-msi-latest-ssl&os=" + $architecture + "&lang=" + $culture
            $firefoxVersion = [Version]$firefoxVersions.FIREFOX_ESR.replace("esr","")
        }
        catch {
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }

        Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Setting Arguments"
        $Vendor = "Mozilla"
        $Product = "FireFox"
        $Version = $firefoxVersion
        $PackageName = "Firefox"
        $InstallerType = "msi"
        $Source = "$PackageName" + "." + "$InstallerType"
        $LogApp = "${env:SystemRoot}" + "\Temp\$PackageName.log"
        $msiArgs = "/i $Source /qn /norestart /reboot=REALLYSUPPRESS INSTALL_MAINTENANCE_SERVICE=false PREVENT_REBOOT_REQUIRED=true"
        $ProgressPreference = 'SilentlyContinue'
    }
    process {
        Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Creating directories"
        $VersionPath = Join-Path -Path $global:generalOutputFolder -ChildPath $Version
        if ( -Not (Test-Path -Path $VersionPath)){
            New-Item -ItemType Directory -Path $VersionPath | Out-Null
        }
        Set-Location $VersionPath
        
        try {
            Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Downloading $Vendor $Product version $Version"
            if (!(Test-Path -Path $Source)){
                Invoke-WebRequest -Uri $ffurl -OutFile $Source
            } else {
                Remove-Item -Path $Source -Force
                Invoke-WebRequest -Uri $ffurl -OutFile $Source
            }
        }
        catch {
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }

        try {
            Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Installing version $Version"
            Start-Process msiexec.exe  -ArgumentList  $msiArgs -Wait -Passthru
        }
        catch {
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }

        try {
            Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Customising services"
            if (Get-Service -Name "MozillaMaintenance"){
                if ((Get-Service -Name "MozillaMaintenance").Status -ne "Stopped"){
                    Stop-Service -Name "MozillaMaintenance" -Force | Out-Null
                }
                Set-Service -Name "MozillaMaintenance" -StartupType Disabled
            }
            Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : INSTALLATION COMPLETE"
        }
        catch {
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    end {
        Set-Location $startLocation
        Get-ChildItem -Path $VersionPath -Recurse -Force | Remove-Item | Out-Null
        Remove-Item $VersionPath -Force | Out-Null
    }
}

Function Uninstall-OfficePreloaded {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = "Uninstall Pre-loaded Office"
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName"
        $clickToRunExe = "C:\Program Files\Common Files\Microsoft Shared\ClickToRun\OfficeClickToRun.exe"
    }
    Process {
        try {
            if (Test-Path -Path $clickToRunExe){
                [ARRAY]$officeArgs = $("scenario=install scenariosubtype=ARP sourcetype=None productstoremove=O365HomePremRetail.16_fr-fr_x-none culture=fr-fr version.16=16.0","scenario=install scenariosubtype=ARP sourcetype=None productstoremove=O365HomePremRetail.16_fr-fr_x-none culture=it-tt version.16=16.0","scenario=install scenariosubtype=ARP sourcetype=None productstoremove=O365HomePremRetail.16_fr-fr_x-none culture=en-us version.16=16.0","scenario=install scenariosubtype=ARP sourcetype=None productstoremove=O365HomePremRetail.16_fr-fr_x-none culture=nl-nl version.16=16.0","scenario=install scenariosubtype=ARP sourcetype=None productstoremove=O365HomePremRetail.16_fr-fr_x-none culture=en-gb version.16=16.0")
                foreach ($args in $officeArgs){
                    try {
                        Start-Process $clickToRunExe -ArgumentList $args -Wait -Passthru | Out-Null
                    }
                    catch {
                        Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
                    }
                    finally {
                        $Error.Clear | Out-Null
                    }
                }
            }
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : $stepName"
        Write-Host "END STEP: $global:stepNumber : $stepName" 
        $global:stepNumber++
        Remove-Variable -Name $stepName
    }
}

Function Install-DellCommandUpdate {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = "Install Dell Driver & Firmware Updates"
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName"
    }
    Process {
        try {
            if ($(Get-ComputerInfo).csManufacturer -like "Dell*"){
                Write-Log -Path $global:logFile -Level Info -Message "Device is manufactured by Dell. Dell Command Update will be installed."

                Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Setting Arguments"
                $Vendor = "Dell"
                $Product = "Command Update"
                $Version = "3.1.3"
                $dcuUrl = "https://dl.dell.com/FOLDER06445000M/1/Dell-Command-Update_5P2R9_WIN_3.1.3_A00.EXE"
                $PackageName = "delldcu"
                $InstallerType = "exe"
                $Source = "$PackageName" + "." + "$InstallerType"
                $LogApp = "${env:SystemRoot}" + "\Temp\$PackageName.log"
                $msiArgs = "$Source /s /l=$LogApp"
                $ProgressPreference = 'SilentlyContinue'

                try {
                    Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Downloading $Vendor $Product version $Version"
                    if (!(Test-Path -Path $Source)){
                        Invoke-WebRequest -Uri $dcuUrl -OutFile $Source
                    } else {
                        Remove-Item -Path $Source -Force
                        Invoke-WebRequest -Uri $dcuUrl -OutFile $Source
                    }
                }
                catch {
                    Write-Host $PSItem.Exception.Message -ForegroundColor Red
                    Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
                }
                finally {
                    $Error.Clear | Out-Null
                }

                Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Installing version $Version"
                Start-Process -Path $Source -ArgumentList $msiArgs -Wait -PassThru

            } else {
                Write-Log -Path $global:logFile -Level Warn -Message "Device is not Dell. Dell Command Update cannot be installed."
                Break
            }
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : $stepName"
        Write-Host "END STEP: $global:stepNumber : $stepName" 
        $global:stepNumber++
        Remove-Variable -Name $stepName
    }
}

Function Install-DellDriverFirmwareUpdates {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = "Install Dell Driver & Firmware Updates"
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName"
    }
    Process {
        try {
            # SUSPEND BITLOCKER HERE, but only for BIOS?
            if ($null -ne (Get-BitlockerVolume -Mountpoint $($env:SystemDrive))){
                Suspend-Bitlocker -Mountpoint $($env:SystemDrive) -RebootCount 1
            }
            Start-Process -Path "$($env:ProgramFiles)\DCU\dcu-cli.exe" -ArgumentList "/silent /reboot" -Wait -ErrorAction SilentlyContinue
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : $stepName"
        Write-Host "END STEP: $global:stepNumber : $stepName" 
        $global:stepNumber++
        Remove-Variable -Name $stepName
    }
}

Function Install-Raccine {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = "Install Raccine"
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName"
        $repo = "Neo23x0/Raccine"
        $filenamePattern = "Raccine.zip"
        $pathExtract = Join-Path -Path $global:generalOutputFolder -ChildPath "Raccine"
        $innerDirectory = $False
        $preRelease = $False
    }
    Process {
        try {
            # Original concept code borrowed heavily from https://gist.github.com/Splaxi/fe168eaa91eb8fb8d62eba21736dc88a
            # Download latest dotnet/codeformatter release from github
            if ($preRelease) {
                $releasesUri = "https://api.github.com/repos/$repo/releases"
                $downloadUri = ((Invoke-RestMethod -Method GET -Uri $releasesUri)[0].assets | Where-Object name -like $filenamePattern ).browser_download_url
            }
            else {
                $releasesUri = "https://api.github.com/repos/$repo/releases/latest"
                $downloadUri = ((Invoke-RestMethod -Method GET -Uri $releasesUri).assets | Where-Object name -like $filenamePattern ).browser_download_url
            }

            $pathZip = Join-Path -Path $([System.IO.Path]::GetTempPath()) -ChildPath $(Split-Path -Path $downloadUri -Leaf)

            Write-Log -Path $global:logFile -Level Info -Message "Downloading Raccine from Github to $pathZip"
            Invoke-WebRequest -Uri $downloadUri -Out $pathZip

            Write-log -Path $global:logFile -Level Info -Message "Cleaning Raccine output directory before extraction"
            Remove-Item -Path $pathExtract -Recurse -Force -ErrorAction SilentlyContinue

            if ($innerDirectory) {
                $tempExtract = Join-Path -Path $([System.IO.Path]::GetTempPath()) -ChildPath $((New-Guid).Guid)
                Expand-Archive -Path $pathZip -DestinationPath $tempExtract -Force
                Move-Item -Path "$tempExtract\*" -Destination $pathExtract -Force
                Remove-Item -Path $tempExtract -Force -Recurse -ErrorAction SilentlyContinue
            }
            else {
                Write-Log -Path $global:logFile -Level Info -Message "Extracting Raccine files to $pathExtract"
                Expand-Archive -Path $pathZip -DestinationPath $pathExtract -Force
            }
            Write-Log -Path $global:logFile -Level Info -Message "Deleting Raccine zip archive from $pathZip"
            Remove-Item $pathZip -Force
            # Download & unpack complete, now install
            # Run .bat installer here
            try {
                Write-Log -Path $global:logFile -Level Info -Message "Running Raccine installer..."
                Start-Process -FilePath $(Join-Path -Path $pathExtract -ChildPath "install-raccine.bat") -Wait -Passthru
            }
            catch {
                Write-Host $PSItem.Exception.Message -ForegroundColor Red
                Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
            }
            finally {
                $Error.Clear | Out-Null
            }

            # When run OK, now cleanup all Raccine temp files
            try {
                Write-Log -Path $global:logFile -Level Info -Message "Deleting temporary Raccine files"
                $raccineFiles = Get-ChildItem $pathExtract -Recurse -Force
                $raccineFiles | Remove-Item -Force
                Remove-Item $pathExtract -Force
            }
            catch {
                Write-Host $PSItem.Exception.Message -ForegroundColor Red
                Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message    
            }
            finally {
                $Error.Clear | Out-Null
            }
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }

    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : $stepName"
        Write-Host "END STEP: $global:stepNumber : $stepName" 
        $global:stepNumber++
        Remove-Variable -Name stepName
        Remove-Variable -Name repo
        Remove-Variable -Name filenamePattern
        Remove-Variable -Name innerDirectory
        Remove-Variable -Name preRelease
        Remove-Variable -Name releasesUri
        Remove-Variable -Name downloadUri
        Remove-Variable -Name pathZip
        Remove-Variable -Name tempExtract
        Remove-Variable -Name pathExtract
    }
}
}

Function Install-WindowsUpdates {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = "Install Windows Updates"
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName"

    }
    Process {
        try {
            try {
                Write-Log -Path $global:logFile -Level Info -Message "Attempting import of Windows Update module"
                Import-Module -Name WindowsUpdateProvider
            }
            catch {
                Write-Log -Path $global:logFile -Level Info -Message "Import failed. Attempting module installation..."
                Install-Module -Name WindowsUpdateProvider -Force
                Import-Module -Name WindowsUpdateProvider
            }

            Write-Log -Path $global:logFile -Level Info -Message "Scanning for & installing available Windows Updates"
            Install-WUUpdates -Updates $(Start-WUScan -SearchCriteria "Type!='Driver' AND IsInstalled=0")
                
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : $stepName"
        Write-Host "END STEP: $global:stepNumber : $stepName" 
        $global:stepNumber++
        Remove-Variable -Name $stepName
    }
}




# PRINTER FUNCTIONS

Function Remove-XpsPrinter {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Remove XPS Printer"
        Write-Host "START STEP: $global:stepNumber : Remove XPS Printer" 
    }
    Process {
        try {
            Write-Log -Path $global:logFile -Level Info -Message "UNINSTALLING: Microsoft XPS Printer"
            Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "Printing-XPSServices-Features" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null    
            Write-Log -Path $global:logFile -Level Info -Message "UNINSTALLING: Complete: Microsoft XPS Printer."
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Remove XPS Printer"
        Write-Host "END STEP: $global:stepNumber : Remove XPS Printer" 
        $global:stepNumber++
    }
}

Function Remove-FaxPrinter {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Remove Fax Printer"
        Write-Host "START STEP: $global:stepNumber : Remove Fax Printer" 
    }
    Process {
        try {
            Remove-Printer -Name "Fax" -ErrorAction SilentlyContinue
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Remove Fax Printer"
        Write-Host "END STEP: $global:stepNumber : Remove Fax Printer" 
        $global:stepNumber++
    }
}



# COMPANYNAME FUNCTIONS

Function Set-CompanyBranding {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Apply Company Branding"
        Write-Host "START STEP: $global:stepNumber : Apply Company Branding" 
    }
    Process {
        try {
            # VALUE: Logo (Path, BMP)
            Write-Log $global:logFile -Level Info -Message "BRANDING: Applying Company Branding"
            [STRING]$brandKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation"
            # Download logo from online source to temporary location
            Write-Log $global:logFile -Level Info -Message "BRANDING: Downloading Company branding assets"
            [STRING]$logoUrl = "https://www.companyname.tld/assets/images/companyname-logo.png"
            [STRING]$logoFileName = Split-Path -Path $logoUrl -Leaf
            [STRING]$temporaryLogoLocation = Split-Path -Path $global:logFile
            if (!$(Test-Path -Path $temporaryLogoLocation)){
                New-Item -Path $temporaryLogoLocation -ItemType Directory
                try {
                    Invoke-WebRequest -URI $logoUrl -OutFile (Join-Path -Path $temporaryLogoLocation -ChildPath $logoFileName) -ErrorAction SilentlyContinue
                }
                catch {
                    Write-Log -Path $global:logFile -Level Error -Message $_.Exception.Response.StatusCode.Value__
                }
            } else {
                Invoke-WebRequest -URI $logoUrl -OutFile (Join-Path -Path $temporaryLogoLocation -ChildPath $logoFileName) -ErrorAction SilentlyContinue
            }

            # Image must be BMP, not PNG
            Write-Log $global:logFile -Level Info -Message "BRANDING: Processing branding assets"
            [STRING]$permanentLogoLocation = Join-Path -Path "C:\Windows\CompanyName\" -ChildPath $logoFileName
            [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
            $convertedLogoPath = $permanentLogoLocation.Replace(".png",".bmp")
            Resize-Image -InputFile (Join-Path -Path $temporaryLogoLocation -ChildPath $logoFileName) -OutputFile $convertedLogoPath -Width 120 -Height 44

            Write-Log $global:logFile -Level Info -Message "BRANDING: Setting custom logo value"
            if ($null -ne (Get-Item -Path $brandKey).GetValue("Logo")){
                # No previous value, just set the new
                New-ItemProperty -Path $brandKey -Name "Logo" -Type "String" -Value $convertedLogoPath -Force | Out-Null
            } else {
                # There's a previous character. Let's back it up
                [STRING]$originalLogoPath = Get-ItemProperty -Path $brandKey -Name "Logo"
                Copy-Item -Path $originalLogoPath -Destination "C:\Windows\CompanyName\*"
                # Now replace with ours
                Set-ItemProperty -Path $brandKey -Name "Logo" -Type "String" -Value $convertedLogoPath -Force
            }

            Write-Log $global:logFile -Level Info -Message "BRANDING: Setting custom manufacturer value"
            if ($null -ne (Get-Item -Path $brandKey).GetValue("Manufacturer")){
                New-ItemProperty -Path $brandKey -Name "Manufacturer" -Type "String" -Value "CompanyName" -Force | Out-Null
            } else {
                [STRING]$originalManufacturer = Get-ItemProperty -Path $brandKey -Name "Manufacturer"
                Set-ItemProperty -Path $brandKey -Name "Manufacturer" -Type "String" -Value "CompanyName" -Force
            }

            Write-Log $global:logFile -Level Info -Message "BRANDING: Setting custom model value"
            if ($null -ne (Get-Item -Path $brandKey).GetValue("Model")){
                # If there's no OEM value for model, scrape from WMI
                [STRING]$cimModel = (Get-CimInstance -Class Win32_ComputerSystem).Model
                [STRING]$cimManufacturer = (Get-CimInstance -Class Win32_ComputerSystem).Manufacturer
                [STRING]$cimValue = $cimManufacturer + " " + $cimModel
                New-ItemProperty -Path $brandKey -Name "Model" -Type "String" -Value $cimValue -Force | Out-Null
            } else {
                # There's a value, collect and combine with manufacturer.
                [STRING]$originalModel = Get-ItemProperty -Path $brandKey -Name "Model"
                [STRING]$modelKey = $originalManufacturer + " " + $originalModel
                Set-ItemProperty -Path $brandKey -Name "Model" -Type "String" -Value $modelKey -Force
            }

            Write-Log $global:logFile -Level Info -Message "BRANDING: Setting custom support hours value"
            if ($null -ne (Get-Item -Path $brandKey).GetValue("SupportHours")){
                New-ItemProperty -Path $brandKey -Name "SupportHours" -Type "String" -Value "09:00-17:30, Mon-Fri" -Force | Out-Null
            } else {
                Set-ItemProperty -Path $brandKey -Name "SupportHours" -Type "String" -Value "09:00-17:30, Mon-Fri" -Force
            }

            Write-Log $global:logFile -Level Info -Message "BRANDING: Setting custom support phone value"
            if ($null -ne (Get-Item -Path $brandKey).GetValue("SupportPhone")){
                New-ItemProperty -Path $brandKey -Name "SupportPhone" -Type "String" -Value "11111 1111111" -Force | Out-Null
            } else {
                Set-ItemProperty -Path $brandKey -Name "SupportPhone" -Type "String" -Value "11111 111111" -Force
            }

            Write-Log $global:logFile -Level Info -Message "BRANDING: Setting custom support url value"
            if ($null -ne (Get-Item -Path $brandKey).GetValue("SupportUrl")){
                New-ItemProperty -Path $brandKey -Name "SupportUrl" -Type "String" -Value "www.companyname.tld" -Force | Out-Null
            } else {
                Set-ItemProperty -Path $brandKey -Name "SupportUrl" -Type "String" -Value "www.companyname.tld" -Force
            }
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Apply CompanyName Branding"
        Write-Host "END STEP: $global:stepNumber : Apply CompanyName Branding"
        $global:stepNumber++ 
    }
}

Function New-CompanyLocalAdmin {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : Create Local Company Administrator"
        Write-Host "START STEP: $global:stepNumber :  Create Local Company Administrator"

        $minLength = 15 ## characters
        $maxLength = 64 ## characters
        $length = Get-Random -Minimum $minLength -Maximum $maxLength
        $nonAlphaChars = 5
        $password = [System.Web.Security.Membership]::GeneratePassword($length, $nonAlphaChars)
        $secPw = ConvertTo-SecureString -String $password -AsPlainText -Force
        $accountName = "CompanyAdminName"
    }
    Process {
        try {
            if (!(Get-LocalUser -Name $accountName)){
                Write-Log -Path $global:logFile -Level Info -Message "USER MANAGEMENT: Creating a new local user $accountName"
                New-LocalUser -Name $accountName -Password $secPw -AccountNeverExpires | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "USER MANAGEMENT: New user $accountName created"
                Write-Log -Path $global:logFile -Level Info -Message "USER MANAGEMENT: Adding user $accountName to the LOCAL ADMINISTRATORS group."
                Add-LocalGroupMember -Group "Administrators" -Member $accountName  | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "USER MANAGEMENT: $accountName user added to the LOCAL ADMINISTRATORS group."
                Write-Log -Path $global:logFile -Level Info -Message "USER MANAGEMENT: Forcing $accountName user password expiry."
                $companyUser = [ADSI]'WinNT://localhost/Administrator'
                $companyUser.PasswordExpired = 1
                $companyUser.SetInfo()
                Write-Log -Path $global:logFile -Level Info -Message "REBOOT is now required to apply the change."
                $global:rebootRequired = 1
                Write-Log -Path $global:logFile -Level Info -Message "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
                Write-Log -Path $global:logFile -Level Info -Message "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
                Write-Log -Path $global:logFile -Level Info -Message "$accountName local account temporary password: $password"
                Write-Log -Path $global:logFile -Level Info -Message "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
                Write-Log -Path $global:logFile -Level Info -Message "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
                Remove-Variable -Name "password"
                Remove-Variable -Name "secPw"
            } elseif ((Get-LocalUser -Name $accountName) -AND ((Get-LocalGroupMember -Group "Administrators").Name -Contains $accountName)){
                Write-Log -Path $global:logFile -Level Info -Message "A local $accountName user already exists and is a member of the LOCAL ADMINISTRATOR group. No further action necessary."
            } elseif ((Get-LocalUser -Name $accountName) -AND ((Get-LocalGroupMember -Group "Administrators").Name -NotContains $accountName)){
                Write-Log -Path $global:logFile -Level Info -Message "A local $accountName user already exists, but is not a member of the LOCAL ADMINISTRATORS group."
                Add-LocalGroupMember -Group "Administrators" -Member $accountName  | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "$accountName local user has been added to the LOCAL ADMINISTRATORS group."
            }          
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : Create Local CompanyName Administrator"
        Write-Host "END STEP: $global:stepNumber : Create Local CompanyName Administrator" 
        $global:stepNumber++
    }
}

Function New-CompanyAssetName {
    # TESTED: Good
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = "Name Device"
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName"
    }
    Process {
        try {
            if ($global:assetID){
                # Asset ID has been supplied. Use that for a simple name
                [STRING]$newDeviceName = "CompanyPrefix-" + $global:assetID
            } else {
                # Asset ID has not been supplied. Use the serial number instead so we can tie it back at a later date.
                $deviceSerialNumber = (Get-CimInstance Win32_Bios).SerialNumber.Replace("-","").Replace(".","").Replace(" ","")
                [STRING]$newDeviceName = "CompanyPrefix-" + $deviceSerialNumber
            }

            # Sanitise the device name in case of silly serial numbers of mistyped asset IDs
            # Restrictions on device name: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/rename-computer?view=powershell-7
            # $deviceSerialNumber = $deviceSerialNumber.Replace(".","").Replace(" ","")

            if ($newDeviceName.Length -le 63){
                # Rename the device
                Rename-Computer -NewName $newDeviceName -Force
            } else {
                Write-Host "DEVICE NAME IS TOO LONG (>63 CHARS)" -ForegroundColor Red
                Write-Log -Path $global:logFile -Level Error -Message "DEVICE NAME IS TOO LONG (>63 CHARS)"
            }

            if ($global:rebootRequired -ne 1){
                $global:rebootRequired = 1
            }
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : $stepName"
        Write-Host "END STEP: $global:stepNumber : $stepName" 
        $global:stepNumber++
        Remove-Variable -Name $stepName
    }
}


#
#
# DEBLOATER SCRIPTS
#
#

# Scripts based on the Windows 10 Debloater scripts
# https://github.com/Sycnex/Windows10Debloater


Function Remove-StartMenuPinnedTiles {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = "Unpin all Start Menu Tiles"
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName"
    }
    Process {
        try {
            # https://superuser.com/questions/1068382/how-to-remove-all-the-tiles-in-the-windows-10-start-menu
            # Unpins all tiles from the Start Menu
            Write-Output "Unpinning all tiles from the start menu"
            (New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | Foreach-Object { $_.Verbs() } | Where-Object {$_.Name -match 'Un.*pin from Start'} | Foreach-Object {$_.DoIt()}
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : $stepName"
        Write-Host "END STEP: $global:stepNumber : $stepName" 
        $global:stepNumber++
        Remove-Variable -Name $stepName
    }
}

Function Remove-RegistryBloat {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = "Remove Registry Bloat"
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName"
    }
    Process {
        try {
            $bloatwareKeys = @(
            
                # Remove Background Tasks
                "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
                "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
                "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
                "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
                "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
                "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
                    
                # Windows File
                "HKCR:\Extensions\ContractId\Windows.File\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
                    
                # Registry keys to delete if they aren't uninstalled by RemoveAppXPackage/RemoveAppXProvisionedPackage
                "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
                "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
                "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
                "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
                "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
                    
                # Scheduled Tasks to delete
                "HKCR:\Extensions\ContractId\Windows.PreInstalledConfigTask\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
                    
                # Windows Protocol Keys
                "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
                "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
                "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
                "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
                    
                # Windows Share Target
                "HKCR:\Extensions\ContractId\Windows.ShareTarget\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
            )
                
            #This writes the output of each key it is removing and also removes the keys listed above.
            ForEach ($bloatwareKey in $bloatwareKeys) {
                Write-Log -Path $global:logFile -Level Info -Message "Removing $bloatwareKey from registry"
                Remove-Item $Key -Recurse
            }
                
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : $stepName"
        Write-Host "END STEP: $global:stepNumber : $stepName" 
        $global:stepNumber++
        Remove-Variable -Name $stepName
    }
}

Function Remove-AppxBloat {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = ""
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName"
    }
    Process {
        try {
            $AppXApps = @(

                # Unnecessary Windows 10 AppX Apps
                "*Microsoft.BingNews*"
                "*Microsoft.GetHelp*"
                "*Microsoft.Getstarted*"
                "*Microsoft.Messaging*"
                "*Microsoft.Microsoft3DViewer*"
                "*Microsoft.MicrosoftOfficeHub*"
                "*Microsoft.MicrosoftSolitaireCollection*"
                "*Microsoft.NetworkSpeedTest*"
                "*Microsoft.Office.Sway*"
                "*Microsoft.OneConnect*"
                "*Microsoft.People*"
                "*Microsoft.Print3D*"
                "*Microsoft.SkypeApp*"
                "*Microsoft.WindowsAlarms*"
                "*Microsoft.WindowsCamera*"
                "*microsoft.windowscommunicationsapps*"
                "*Microsoft.WindowsFeedbackHub*"
                "*Microsoft.WindowsMaps*"
                "*Microsoft.WindowsSoundRecorder*"
                "*Microsoft.Xbox.TCUI*"
                "*Microsoft.XboxApp*"
                "*Microsoft.XboxGameOverlay*"
                "*Microsoft.XboxIdentityProvider*"
                "*Microsoft.XboxSpeechToTextOverlay*"
                "*Microsoft.ZuneMusic*"
                "*Microsoft.ZuneVideo*"

                # Sponsored Windows 10 AppX Apps
                # Add sponsored/featured apps to remove in the "*AppName*" format
                "*EclipseManager*"
                "*ActiproSoftwareLLC*"
                "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
                "*Duolingo-LearnLanguagesforFree*"
                "*PandoraMediaInc*"
                "*CandyCrush*"
                "*Wunderlist*"
                "*Flipboard*"
                "*Twitter*"
                "*Facebook*"
                "*Spotify*"

                # Optional: Typically not removed but you can if you need to for some reason
                #"*Microsoft.Advertising.Xaml_10.1712.5.0_x64__8wekyb3d8bbwe*"
                #"*Microsoft.Advertising.Xaml_10.1712.5.0_x86__8wekyb3d8bbwe*"
                #"*Microsoft.BingWeather*"
                #"*Microsoft.MSPaint*"
                #"*Microsoft.MicrosoftStickyNotes*"
                #"*Microsoft.Windows.Photos*"
                #"*Microsoft.WindowsCalculator*"
                #"*Microsoft.WindowsStore*"
            )
            foreach ($App in $AppXApps) {
                Write-Log -Path $global:logFile -Level Info -Message ('Removing Package {0}' -f $App)
                Get-AppxPackage -Name $App | Remove-AppxPackage -ErrorAction SilentlyContinue
                Get-AppxPackage -Name $App -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
                Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $App | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
            }
            
            # Removes AppxPackages
            # Credit to /u/GavinEke for a modified version of my whitelist code
            [regex]$WhitelistedApps = 'Microsoft.Paint3D|Microsoft.WindowsCalculator|Microsoft.WindowsStore|Microsoft.Windows.Photos|CanonicalGroupLimited.UbuntuonWindows|Microsoft.XboxGameCallableUI|Microsoft.XboxGamingOverlay|Microsoft.Xbox.TCUI|Microsoft.XboxGamingOverlay|Microsoft.XboxIdentityProvider|Microsoft.MicrosoftStickyNotes|Microsoft.MSPaint*'
            Get-AppxPackage -AllUsers | Where-Object {$_.Name -NotMatch $WhitelistedApps} | Remove-AppxPackage
            Get-AppxPackage | Where-Object {$_.Name -NotMatch $WhitelistedApps} | Remove-AppxPackage
            Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -NotMatch $WhitelistedApps} | Remove-AppxProvisionedPackage -Online
                
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : $stepName"
        Write-Host "END STEP: $global:stepNumber : $stepName" 
        $global:stepNumber++
        Remove-Variable -Name $stepName
    }
}

Function Repair-AppxDebloat {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = ""
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName"
    }
    Process {
        try {
            If (!(Get-AppxPackage -AllUsers | Select-Object Microsoft.Paint3D, Microsoft.WindowsCalculator, Microsoft.WindowsStore, Microsoft.Windows.Photos)) {
    
                # Credit to abulgatz for these 4 lines of code
                Get-AppxPackage -AllUsers Microsoft.Paint3D | Foreach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
                Get-AppxPackage -AllUsers Microsoft.WindowsCalculator | Foreach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
                Get-AppxPackage -AllUsers Microsoft.WindowsStore | Foreach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
                Get-AppxPackage -AllUsers Microsoft.Windows.Photos | Foreach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"} 
            } 
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : $stepName"
        Write-Host "END STEP: $global:stepNumber : $stepName" 
        $global:stepNumber++
        Remove-Variable -Name $stepName
    }
}

Function Invoke-PreventAppxBloatBoomerang {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = "Prevent Appx bloat recurring"
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName"
    }
    Process {
        try {
            # Prevents bloatware applications from returning and removes Start Menu suggestions               
            Write-Log -Path $global:logFile -Level Info -Message "Adding Registry key to prevent bloatware apps from returning"
            $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
            $registryOEM = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            If (!(Test-Path $registryPath)) { 
                New-Item $registryPath | Out-Null
            }
            Set-ItemProperty $registryPath DisableWindowsConsumerFeatures -Value 1 

            If (!(Test-Path $registryOEM)) {
                Update-KeyForAllUsers -registryKeyPath $registryOEM -Action "Create"
            }
            # Set-ItemProperty $registryOEM  ContentDeliveryAllowed -Value 0 
            Update-KeyForAllUsers -registryKeyPath $registryOEM -registryKeyName "ContentDeliveryAllowed" -registryKeyValue 0 -Action "Update"
            # Set-ItemProperty $registryOEM  OemPreInstalledAppsEnabled -Value 0 
            Update-KeyForAllUsers -registryKeyPath $registryOEM -registryKeyName "OemPreInstalledAppsEnabled" -registryKeyValue 0 -Action "Update"
            # Set-ItemProperty $registryOEM  PreInstalledAppsEnabled -Value 0 
            Update-KeyForAllUsers -registryKeyPath $registryOEM -registryKeyName "PreInstalledAppsEnabled" -registryKeyValue 0 -Action "Update"
            # Set-ItemProperty $registryOEM  PreInstalledAppsEverEnabled -Value 0 
            Update-KeyForAllUsers -registryKeyPath $registryOEM -registryKeyName "PreInstalledAppsEverEnabled" -registryKeyValue 0 -Action "Update"
            # Set-ItemProperty $registryOEM  SilentInstalledAppsEnabled -Value 0 
            Update-KeyForAllUsers -registryKeyPath $registryOEM -registryKeyName "SilentInstalledAppsEnabled" -registryKeyValue 0 -Action "Update"
            # Set-ItemProperty $registryOEM  SystemPaneSuggestionsEnabled -Value 0          
            Update-KeyForAllUsers -registryKeyPath $registryOEM -registryKeyName "SystemPaneSuggestionsEnabled" -registryKeyValue 0 -Action "Update"
            
            # Prepping mixed Reality Portal for removal    
            Write-Log -Path $global:logFile -Level Info -Message "Setting Mixed Reality Portal value to 0 so that you can uninstall it in Settings"
            $Holo = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic"    
            If (Test-Path $Holo) {
                #Set-ItemProperty -Path $Holo -Name "FirstRunSucceeded" -Value 0 
                Update-KeyForAllUsers -registryKeyPath $Holo -registryKeyName "FirstRunSucceeded" -registryKeyValue 0 -action "Update"
            }
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : $stepName"
        Write-Host "END STEP: $global:stepNumber : $stepName" 
        $global:stepNumber++
        Remove-Variable -Name $stepName
    }
}


Function Remove-PeopleIcon {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = "Remove Taskbar People Icon"
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName"
    }
    Process {
        try {
            # Disables People icon on Taskbar
            Write-Log -Path $global:logFile -Level Info -Message "Disabling People icon on Taskbar"
            $People = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"    
            If (!(Test-Path $People)) {
                Update-KeyForAllUsers -registryKeyPath $People -Action "Create"
            }
            Update-KeyForAllUsers -registryKeyPath $People -Name "PeopleBand" -registryKeyValue 0 -Action "Update"
                
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : $stepName"
        Write-Host "END STEP: $global:stepNumber : $stepName" 
        $global:stepNumber++
        Remove-Variable -Name $stepName
    }
}


Function Disable-ScheduledTasks {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = "Disable extra scheduled tasks"
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName"
    }
    Process {
        try {
                $scheduledTaskNames = "XblGameSaveTaskLogon","XblGameSaveTask","Consolidator","UsbCeip","DmClient","DmClientOnScenarioDownload"
                foreach ($schTask in $scheduledTaskNames){
                    Write-Log -Path $global:logFile -Level Info -Message "Disabling scheduled task $schTask"
                    Get-ScheduledTask -Name $schTask | Disable-ScheduledTask
                }
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : $stepName"
        Write-Host "END STEP: $global:stepNumber : $stepName" 
        $global:stepNumber++
        Remove-Variable -Name $stepName
    }
}


Function Invoke-CleanEventLogs {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = "Cleaning Event Logs"
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName"
    }
    Process {
        try {
            Write-Log -Path $global:logFile -Level Info -Message "Collating event logs to clean."
            wevtutil el 1 | Out-File -Path (Join-Path -Path $global:generalOutputFolder -ChildPath "cleaneventlog.txt")
            Write-Log -Path $global:logFile -Level Info -Message "Enumerating individual log entries to clean"
            $eventLogsToClean = Get-Content -Path (Join-Path -Path $global:generalOutputFolder -ChildPath "cleaneventlog.txt")
            foreach ($dirtyLog in $eventLogsToClean){
                try {
                    Write-Log -Path $global:logFile -Level Info -Message "Cleaning log: $dirtyLog"
                    wevtutil cl $dirtyLog  
                }
                catch {
                    Write-Log -Path $global:logFile -Level Error -Message "ERROR: Unable to clean log $dirtyLog."
                    Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
                    Write-Host $PSItem.Exception.Message -ForegroundColor Red
                }
                finally {
                    $Error.Clear | Out-Null
                }
            }
            Write-Host "Removing event log export file"
            Remove-Item -Path (Join-Path -Path $global:generalOutputFolder -ChildPath "cleaneventlog.txt") -Force | Out-Null
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : $stepName"
        Write-Host "END STEP: $global:stepNumber : $stepName" 
        $global:stepNumber++
        Remove-Variable -Name $stepName
    }
}


Function Invoke-MakeItSparkle {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = "Cleaning up"
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName"
    }
    Process {
        try {
            # Step 1: CleanMgr
            try {
                Write-Log -Path $global:logFile -Level Info -Message "Initialising cleanmgr.exe with sagerun:1"
                Start-Process -Path "C:\Windows\System32\cleanmgr" -ArgumentList "/sagerun:1" -Wait -Passthru
            }
            catch {
                Write-Host $PSItem.Exception.Message -ForegroundColor Red
                Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
            }
            finally {
                $Error.Clear | Out-Null
            }

            # Step 2: Purge update cache
            try {
                if ($(Get-Service -Name "wuauserv").Status -ne "Stopped"){
                    Write-Log -Path $global:logFile -Level Info -Message "Stopping Windows Update Service"
                    Stop-Service -Name "wuauserv" -Force | Out-Null
                }

                Write-Log -Path $global:logFile -Level Info -Message "Purging Windows Update cached content"
                Get-ChildItem -Path "C:\Windows\SoftwareDistribution\Downloads" -Recurse | Remove-Item -Force | Out-Null

                if ($(Get-Service -Name "wuauserv").Status -ne "Running"){
                    Write-Log -Path $global:logFile -Level Info -Message "Starting Windows Update Service"
                    Start-Service -Name "wuauserv"
                }                
            }
            catch {
                Write-Host $PSItem.Exception.Message -ForegroundColor Red
                Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
            }
            finally {
                $Error.Clear | Out-Null
            }

            # Step 3: Clear hidden install files
            try {
                Write-Log -Path $global:logFile -Level Info -Message "Deleting hidding installation files within C:\Windows\NT*"
                Get-ChildItem -Path (Join-Path -Path $env:SystemDrive -ChildPath "Windows\NT*") -Recurse | Remove-Item -Force | Out-Null                
            }
            catch {
                Write-Host $PSItem.Exception.Message -ForegroundColor Red
                Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
            }
            finally {
                $Error.Clear | Out-Null
            }

            # Step 4: Clean prefetch
            try {
                Write-Log -Path $global:logFile -Level Info -Message "Cleaning Windows Prefetch"
                Get-ChildItem -Path (Join-Path -Path $env:SystemDrive -ChildPath "Windows\Prefetch") -Recurse | Remove-Item -Force | Out-Null
            }
            catch {
                Write-Host $PSItem.Exception.Message -ForegroundColor Red
                Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
            }
            finally {
                $Error.Clear | Out-Null
            }

            # Step 5: Flush DNS
            try {
                Write-Log -Path $global:logFile -Level Info -Message "Clearing DNS Client Cache"
                Clear-DnsClientCache
            }
            catch {
                Write-Host $PSItem.Exception.Message -ForegroundColor Red
                Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
            }
            finally {
                $Error.Clear | Out-Null
            }

            # Step 6: DISM
            try {
                Write-Log -Path $global:logFile -Level Info -Message "Starting DISM Component Cleanup"
                Start-Process -Path "dism.exe" -Wait -Passthru -ArgumentList "/online /cleanup-image /startcomponentcleanup /resetbase"
            }
            catch {
                Write-Host $PSItem.Exception.Message -ForegroundColor Red
                Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
            }
            finally {
                $Error.Clear | Out-Null
            }

            # Step 7: Delete temp files
            try {
                Write-Log -Path $global:logFile -Level Info -Message "Cleaning other temporary directories"
                $foldersToClean = "C:\MININT","C:\SYSPREP","C:\_SMSTaskSequence","C:\WindowsTempDeploymentLogs","C:\Users\*\AppData\Local\Temp","C:\Windows\Temp\","C:\Users\*\Downloads","C:\Windows\Logs\CBS","C:\swsetup\","C:\Drivers\","C:\Dell\","C:\users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files","C:\inetpub\logs\LogFiles","C:\Windows.old","C:\Windows.del"
                foreach ($folder in $foldersToClean){
                    if ([System.IO.File]::Exists($folder)){
                        Write-Log -Path $global:logFile -Level Info -Message "Folder $folder exists. Cleaning..."
                        $files = Get-ChildItem -Path $folder -Recurse
                        foreach ($file in $files){
                            Remove-Item -Path $file.PSPath -Force
                        }
                        Remove-Item -Path $folder -Force
                    } else {
                        Write-Log -Path $global:logFile -Level Info -Message "Folder $folder does not exist. No further action."
                        Continue
                    }
                }

                # Step 8: Clean Chrome
                try {
                    $chromeProcess = Get-Process -Name "chrome.exe" -ErrorAction SilentlyContinue
                    if ($chromeProcess){
                        $chromeProcess.CloseMainWindow()
                        Write-Log -Path $global:logFile -Level Info -Message "Chrome.exe processes found. Attempting graceful close."
                        Start-Sleep -Seconds 5
                        if (!$chromeProcess.HasExited){
                            Write-Log -Path $logFile -Level Info -Message "Chrome.exe process has failed to exit gracefully. Terminating process."
                            $chromeProcess | Stop-Process -Force
                        }
                    }
                    $chromeItems = @('Archived History',
                            'Cache',
                            'Cookies-Journal',
                            'Entries',
                            'Media Cache',
                            'Top Sites',
                            'ChromeDWriteFontCache',
                            'Visited Links',
                            'Web Data')
                    $chromeFolder = "Google\Chrome\User Data\Default"
                    # Get list of user profiles
                    $profileDirectory = "$env:SystemDrive\Users\*"
                    $profileList = Get-ChildItem -Path $profileDirectory
                    Write-Log -Path $global:logFile -Level Info -Message "Building list of Google Chrome user profiles on $env:Hostname"
                    foreach ($userProfile in $profileList){
                        Write-Log -Path $global:logFile -Level Info -Message "Working on Google Chrome user profile: $userProfile.PSPath"
                        foreach ($chromeItem in $chromeItems){
                            Write-Log -Path $global:logFile -Level Info -Message "Working on Google Chrome item: $chromeItem"
                            if (Test-Path -Path $(Join-Path -Path $userProfile.PSPath -ChildPath $(Join-Path -Path $chromeFolder -ChildPath $chromeItem))){
                                try {
                                    Get-ChildItem -Path $(Join-Path -Path $(Join-Path -Path $userProfile.Path -ChildPath $chromeFolder) -ChildPath $(Join-Path -Path $chromeItem -ChildPath "*")) | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                                }
                                catch {
                                    Write-Host $PSItem.Exception.Message -ForegroundColor Red
                                    Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
                                }
                                finally {
                                    $Error.Clear | Out-Null
                                }
                            }
                        }
                    }
                }
                catch {
                    Write-Host $PSItem.Exception.Message -ForegroundColor Red
                    Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
                }
                finally {
                    $Error.Clear | Out-Null
                }
                # 
                
            }
            catch {
                Write-Host $PSItem.Exception.Message -ForegroundColor Red
                Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
            }
            finally {
                $Error.Clear | Out-Null
            }


                
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : $stepName"
        Write-Host "END STEP: $global:stepNumber : $stepName" 
        $global:stepNumber++
        Remove-Variable -Name $stepName
    }
}






#
#
# CIS BENCHMARK FUNCTIONS
#
#

# Template function for easier access

Function Set-CisRegistryFunction {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Parameter(Mandatory=$True)][STRING]$keyPath,
        [Parameter(Mandatory=$True)][STRING]$keyName,
        [Parameter(Mandatory=$True)]$keyValueCorrect,
        [Parameter(Mandatory=$True)][STRING]$keyType,
        [Parameter(Mandatory=$True)][STRING]$cisControlNumber,
        [Parameter(Mandatory=$True)][STRING]$cisControlName
    )
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = "CIS: $cisControlNumber : $cisControlName"
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName"
    }
    Process {
        try {
            if (Test-Path -Path (Join-Path -Path $keyPath -ChildPath $keyName)){
                if ((Get-ItemProperty -Path $keyPath -Name $keyName) -ne $keyValueCorrect){
                    Write-Log -Path $global:logFile -Level Info -Message "Key value is set incorrectly. Value to be set correctly."
                    Set-ItemProperty -Path $keyPath -Name $keyName -Value $keyValue -Type $keyType | Out-Null
                }
            } else {
                Write-Log -Path $global:logFile -Level Info -Message "Key $keyPath\$keyName does not exist, creating."
                New-Item -Path $keyPath -Name $keyName -Force | Out-Null
                Set-ItemProperty -Path $keyPath -Name $keyName -Value $keyValue -Type $keyType | Out-Null
            }
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : $stepName"
        Write-Host "END STEP: $global:stepNumber : $stepName" 
        $global:stepNumber++
        Remove-Variable -Name stepName
        Remove-Variable -Name keyName
        Remove-Variable -Name keyPath
        Remove-Variable -Name keyType
        Remove-Variable -Name keyValueCorrect
    }
}
$setCisRegistryFunctionSplat = @{
    $keyPath = ""
    $keyName = ""
    $keyValueCorrect = ""
    $keyType = ""
    $cisControlNumber = ""
    $cisControlName = ""
}

Function Set-CisRegistryUserFunction {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Parameter(Mandatory=$True)][STRING]$keyPath,
        [Parameter(Mandatory=$True)][STRING]$keyName,
        [Parameter(Mandatory=$True)]$keyValueCorrect,
        [Parameter(Mandatory=$True)][STRING]$keyType,
        [Parameter(Mandatory=$True)][STRING]$cisControlNumber,
        [Parameter(Mandatory=$True)][STRING]$cisControlName
    )
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = "CIS: $cisControlNumber : $cisControlName"
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName"
    }
    Process {
        try {
            if (Test-Path -Path (Join-Path -Path $keyPath -ChildPath $keyName)){
                if ((Get-ItemProperty -Path $keyPath -Name $keyName) -ne $keyValueCorrect){
                    Write-Log -Path $global:logFile -Level Info -Message "Key value is set incorrectly. Value to be set correctly."
                    Update-KeyForAllUsers -registryKeyPath $keyPath -registryKeyName $keyName -registryKeyValue $keyValueCorrect -registryKeyType $keyType
                }
            } else {
                Write-Log -Path $global:logFile -Level Info -Message "Key $keyPath\$keyName does not exist, creating."
                New-Item -Path $keyPath -Name $keyName -Force | Out-Null
                Update-KeyForAllUsers -registryKeyPath $keyPath -registryKeyName $keyName -registryKeyValue $keyValueCorrect -registryKeyType $keyType
            }
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : $stepName"
        Write-Host "END STEP: $global:stepNumber : $stepName" 
        $global:stepNumber++
        Remove-Variable -Name stepName
        Remove-Variable -Name keyName
        Remove-Variable -Name keyPath
        Remove-Variable -Name keyType
        Remove-Variable -Name keyValueCorrect
    }
}


#
# INCLUDES:
#
# WINDOWS 10 2004
# TODO: GOOGLE CHROME
# TODO: MOZILLA FIREFOX
# TODO: MICROSOFT OFFICE
# TODO: KERBEROS
#

#
# WINDOWS 10 2004
#


# 2.2 Accounts
# SPLATS

$cisAccountsBlockMicrosoft = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $keyName = "NoConnectedUser"
    $keyValueCorrect = "Users can't add or log on with Microsoft accounts"
    $keyType = "REG_SZ"
    $cisControlNumber = "2.3.1.2"
    $cisControlName = "Accounts: Block Microsoft Accounts"
}

# 2.3.1 Audit
# SPLATS

$cisAuditPolicySubcategory = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
    $keyName = "SCENoApplyLegacyAuditPolicy"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.2.1"
    $cisControlName = "Audit: Force audit policy subcategory settings (Windows Vista or later) to override audit policy category settings' is set to 'Enabled' "
}

$cisAuditShutdownBehaviour = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
    $keyName = "CrashOnAuditFail"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.2.2"
    $cisControlName = "Audit: Shut down system immediately if unable to log security audits"
}

# 2.3.4 Devices
# SPLATS

$cisDevicesFormatRMedia = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    $keyName = "AllocateDASD"
    $keyValueCorrect = "0"
    $keyType = "REG_SZ"
    $cisControlNumber = "2.3.4.1"
    $cisControlName = "Devices: Allowed to format and eject removable media' is set to 'Administrators"
}

# 2.3.6 Domain Member

$cisDomMemSecureChannelAlways = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters"
    $keyName = "RequireSignOrSeal"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.6.1"
    $cisControlName = "Domain member: Digitally encrypt or sign secure channel data (always)'"
}

$cisDomMemEncryptSecureChannelAlways = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters"
    $keyName = "SealSecureChannel"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.6.2"
    $cisControlName = "Domain member: Digitally encrypt secure channel data (when possible)' "
}

$cisDomMemSignSecureChannelPossible = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters"
    $keyName = "SignSecureChannel"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.6.3"
    $cisControlName = "'Domain member: Digitally sign secure channel data (when possible)' "
}

$cisDomMemDisableMachinePassChange = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters:"
    $keyName = "DisablePasswordChange"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.6.4"
    $cisControlName = " 'Domain member: Disable machine account password changes'"
}

$cisDomMemRequireStrongSessionKey = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters"
    $keyName = "RequireStrongKey"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.6.6"
    $cisControlName = "Domain member: Require strong (Windows 2000 or later) session key"
}

# 2.3.7 Interactive Logon

$cisIntLogonDisableCAD = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $keyName = "DisableCAD"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.7.1"
    $cisControlName = "Interactive logon: Do not require CTRL+ALT+DEL"
}


$cisIntLogonDisplayLastSignIn = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $keyName = "DontDisplayLastUserName"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.7.2"
    $cisControlName = "'Interactive logon: Don't display last signed-in' is set to 'Enabled"
}


$cisIntLogonMachineInactivityLimit = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $keyName = "InactivityTimeoutSecs"
    $keyValueCorrect = "900"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.7.4"
    $cisControlName = "Interactive logon: Machine inactivity limit"
}


$cisIntLogonUserPasswordPrompt = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    $keyName = "PasswordExpiryWarning"
    $keyValueCorrect = "14"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.7.8"
    $cisControlName = "Interactive logon: Prompt user to change password before expiration"
}


$cisIntLogonSmartCardRemoval = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    $keyName = "ScRemoveOption"
    $keyValueCorrect = "1"
    $keyType = "REG_SZ"
    $cisControlNumber = "'Interactive logon: Smart card removal behavior' is set to 'Lock Workstation"
    $cisControlName = "2.3.7.9"
}

# 2.3.8 Microsoft Network Client

$cisNetCliDigitallySignAlways = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"
    $keyName = "RequireSecuritySignature"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.8.1"
    $cisControlName = "Microsoft network client: Digitally sign communications (always)"
}

$cisNetCliDigitallySignServerAgrees = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"
    $keyName = "EnableSecuritySignature"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.8.2"
    $cisControlName = "Microsoft network client: Digitally sign communications (if server agrees)"
}

$cisNetCliUnencryptedSmb = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"
    $keyName = "EnablePlaintextPassword"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.8.3"
    $cisControlName = "Microsoft network client: Send unencrypted password to third-party SMB servers"
}

# 2.3.9 Microsoft Network Server

$cisNetSrvIdleSuspend = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters"
    $keyName = "AutoDisconnect"
    $keyValueCorrect = "15"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.9.1"
    $cisControlName = "Microsoft network server: Amount of idle time required before suspending session"
}

$cisNetSrvDigitallySignAlways = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters"
    $keyName = "RequireSecuritySignature"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.9.2"
    $cisControlName = "Microsoft network server: Digitally sign communications (always)"
}

$cisNetSrvDigitallySignClient = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters"
    $keyName = "EnableSecuritySignature"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.9.3"
    $cisControlName = "Microsoft network server: Digitally sign communications (if client agrees)"
}

$cisNetSrvDisconnectLogonHours = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters"
    $keyName = "enableforcedlogoff"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.9.4"
    $cisControlName = "Microsoft network server: Disconnect clients when logon hours expire"
}

$cisNetSrvSPNValidationLevel = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters"
    $keyName = "SMBServerNameHardeningLevel"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.9.5"
    $cisControlName = "Microsoft network server: Server SPN target name validation level"
}

# 2.3.10 Network Access

$cisNetAccAnonymousSAMEnumeration = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
    $keyName = "RestrictAnonymousSAM"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.10.2"
    $cisControlName = "Network access: Do not allow anonymous enumeration of SAM accounts"
}
$cisNetAccAnonymousSAMShares = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
    $keyName = "RestrictAnonymous"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.10.3"
    $cisControlName = "Network access: Do not allow anonymous enumeration of SAM accounts and shares"
}
$cisNetAccCredentialStorage = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
    $keyName = "DisableDomainCreds"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.10.4"
    $cisControlName = "Network access: Do not allow storage of passwords and credentials for network authentication"
}
$cisNetAccEveryoneToAnonymous = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
    $keyName = "EveryoneIncludesAnonymous"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.10.5"
    $cisControlName = "Network access: Let Everyone permissions apply to anonymous users"
}
$cisNetAccAnonymousNamedPipes = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters"
    $keyName = "NullSessionPipes"
    $keyValueCorrect = ""
    $keyType = "MULTISTRING"
    $cisControlNumber = "2.3.10.6"
    $cisControlName = "Network access: Named Pipes that can be accessed anonymously"
}
$cisNetAccRemoteRegistryPaths = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurePipeServers\Winreg\AllowedExactPaths"
    $keyName = "Machine"
    $keyValueCorrect = "System\CurrentControlSet\Control\ProductOptions","System\CurrentControlSet\Control\Server Applications","Software\Microsoft\Windows NT\CurrentVersion"
    $keyType = "MULTISTRING"
    $cisControlNumber = "2.3.10.7"
    $cisControlName = "Network access: Remotely accessible registry paths"
}
$cisNetAccRemoteRegistrySubPaths = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurePipeServers\Winreg\AllowedPaths"
    $keyName = "Machine"
    $keyValueCorrect = @'
System\CurrentControlSet\Control\Print\Printers
System\CurrentControlSet\Services\Eventlog
Software\Microsoft\OLAP Server
Software\Microsoft\Windows NT\CurrentVersion\Print
Software\Microsoft\Windows NT\CurrentVersion\Windows
System\CurrentControlSet\Control\ContentIndex
System\CurrentControlSet\Control\Terminal Server
System\CurrentControlSet\Control\Terminal Server\UserConfig
System\CurrentControlSet\Control\Terminal Server\DefaultUserConfiguration
Software\Microsoft\Windows NT\CurrentVersion\Perflib
System\CurrentControlSet\Services\SysmonLog
'@
    $keyType = "MULTISTRING"
    $cisControlNumber = "2.3.10.8"
    $cisControlName = "Network access: Remotely accessible registry paths and sub-paths"
}
$cisNetAccAnonymousPipeShareAccess = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters"
    $keyName = "RestrictNullSessAccess"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.10.9"
    $cisControlName = "Network access: Restrict anonymous access to Named Pipes and Shares"
}
$cisNetAccClientRemoteSAMCalls = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
    $keyName = "restrictremotesam"
    $keyValueCorrect = "O:BAG:BAD:(A;;RC;;;BA)"
    $keyType = "STRING"
    $cisControlNumber = "2.3.10.10"
    $cisControlName = "Network access: Restrict clients allowed to make remote calls to SAM"
}
$cisNetAccAnonymousShares = @{
    $keyPath = "HKLN:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters"
    $keyName = "NullSessionShares"
    $keyValueCorrect = ""
    $keyType = "MULTISTRING"
    $cisControlNumber = "2.3.10.11"
    $cisControlName = "Network access: Shares that can be accessed anonymously"
}
$cisNetAccLocalAccSecModel = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
    $keyName = "ForceGuest"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.10.12"
    $cisControlName = "Network access: Sharing and security model for local accounts"
}

# 2.3.11 Network Security

$cisNetSecCompIdentity = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
    $keyName = "UseMachineId"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.11.1"
    $cisControlName = "Network security: Allow Local System to use computer identity for NTLM"
}
$cisNetSecNullFallback = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"
    $keyName = "AllowNullSessionFallback"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.11.2"
    $cisControlName = "Network security: Allow LocalSystem NULL session fallback"
}
$cisNetSecPKU2UOnlineIdentities = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\pku2u"
    $keyName = "AllowOnlineID"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.11.3"
    $cisControlName = "Network Security: Allow PKU2U authentication requests to this computer to use online identities"
}
$cisNetSecKerberosEncryptionTypes = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters"
    $keyName = "SupportedEncryptionTypes"
    $keyValueCorrect = "2147483644"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.11.4"
    $cisControlName = "Network security: Configure encryption types allowed for Kerberos'"
}
$cisNetSecLMHashStorage = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
    $keyName = "NoLMHash"
    $keyValueCorrect = "1"
    $keyType = "DWORD" 
    $cisControlNumber = "2.3.11.5"
    $cisControlName = "Network security: Do not store LAN Manager hash value on next password change"
}
$cisNetSecLMAuthLevel = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
    $keyName = "LmCompatibilityLevel"
    $keyValueCorrect = "5"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.11.7"
    $cisControlName = "Network security: LAN Manager authentication level"
}
$cisNetSecLDAPClientSignReq = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LDAP"
    $keyName = "LDAPClientIntegrity"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.11.8"
    $cisControlName = "Network security: LDAP client signing requirements"
}
$cisNetSecNtlmSspMinSec = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"
    $keyName = "NTLMMinClientSec"
    $keyValueCorrect = "537395200"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.11.9"
    $cisControlName = "Network security: Minimum session security for NTLM SSP based (including secure RPC) clients"
}
$cisNetSecNtlmSspMinSecRPC = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"
    $keyName = "NTLMMinServerSec"
    $keyValueCorrect = "537395200"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.11.10"
    $cisControlName = "Network security: Minimum session security for NTLM SSP based (including secure RPC) servers"
}

# 2.3.15 System Objects

$cisSysObjWinSubSys = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Kernel"
    $keyName = "ObCaseInsensitive"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.15.1"
    $cisControlName = "System objects: Require case insensitivity for nonWindows subsystems"
}
$cisSysObjIntObjStrength = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager"
    $keyName = "ProtectionMode"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.15.2"
    $cisControlName = "System objects: Strengthen default permissions of internal system objects (e.g. Symbolic Links)"
}

# 2.3.17 User Account Control

$cisUacAdminApprovalMode = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $keyName = "FilterAdministratorToken"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.17.1"
    $cisControlName = "User Account Control: Admin Approval Mode for the Built-in Administrator account"
}
$cisUacAdminApprovalElevationBehaviour = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $keyName = "ConsentPromptBehaviorAdmin"
    $keyValueCorrect = "2"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.17.2"
    $cisControlName = " User Account Control: Behavior of the elevation prompt for administrators in Admin Approval Mode"
}
$cisUacStdUserElevationPrompt = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $keyName = "ConsentPromptBehaviorUser"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.17.3"
    $cisControlName = "User Account Control: Behavior of the elevation prompt for standard users"
}
$cisUacAppElevationPrompt = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $keyName = "EnableInstallerDetection"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.17.4"
    $cisControlName = "User Account Control: Detect application installations and prompt for elevation"
}
$cisUacElevateSecureOnly = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $keyName = "EnableSecureUIAPaths"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.17.5"
    $cisControlName = "User Account Control: Only elevate UIAccess applications that are installed in secure locations"
}
$cisUacAdminsInApprovalMode = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $keyName = "EnaleLUA"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.17.6"
    $cisControlName = "User Account Control: Run all administrators in Admin Approval Mode"
}
$cisUacElevateOnSecureDesktop = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $keyName = "PromptOnSecureDesktop"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = ""
    $cisControlName = "User Account Control: Switch to the secure desktop when prompting for elevation"
}
$cisUacVirtualiseWriteFailures = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $keyName = "EnableVirtualization"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "2.3.17.8"
    $cisControlName = "User Account Control: Virtualize file and registry write failures to per-user locations"
}

# 5 System Services

Function Set-CisServiceDisabled {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Parameter(Mandatory=$True)][STRING]$serviceName,
        [Parameter(Mandatory=$True)][STRING]$cisControlNumber,
        [Parameter(Mandatory=$True)][STRING]$cisControlName
    )
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = "CIS: $cisControlNumber : $cisControlName"
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName"
    }
    Process {
        try {
            Write-Log -Path $global:logFile -Level Info -Message "Retrieving $serviceName service status"
            $service = Get-Service -Name $serviceName | Out-Null
            if ($service.StartupType -ne "Disabled"){
                Write-Log -Path $global:logFile -Level Info -Message "Stopping service $serviceName"
                Stop-Service -Name $serviceName -Force | Out-Null
                Write-Log -Path $global:logFile -Level Info -Message "Disabling service $serviceName"
                Set-Service -Name $serviceName -StartupType "Disabled" | Out-Null
            } elseif (!$service){
                Write-Log -Path $global:logFile -Level Info -Message "Service $serviceName is not installed"
            } else {
                Write-Log -Path $global:logFile -Level Info -Message "Service $serviceName is already disabled. No further action."
            }
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : $stepName"
        Write-Host "END STEP: $global:stepNumber : $stepName" 
        $global:stepNumber++
        Remove-Variable -Name stepName
        Remove-Variable -Name sserviceName
    }
}
$cisServiceComputerBrowser = @{
    $serviceName = "Browser"
    $cisControlNumber = "5.3"
    $cisControlName = "Computer Browser (Browser)"
}
$cisServiceIisAdmin = @{
    $serviceName = "IISADMIN"
    $cisControlNumber = "5.6"
    $cisControlName = "IIS Admin Service (IISADMIN)"
}
$cisServiceIRMon = @{
    $serviceName = "irmon"
    $cisControlNumber = "5.7"
    $cisControlName = "Infrared Monitor Service (irmon)"
}
$cisServiceIcs = @{
    $serviceName = "SharedAccess"
    $cisControlNumber = "5.8"
    $cisControlName = "Internet Connection Sharing (ICS)(SharedAccess)"
}
$cisServiceLxssManager = @{
    $serviceName = "LxssManager"
    $cisControlNumber = "5.10"
    $cisControlName = "LxssManager (LxssManager)"
}
$cisServiceFtpSvc = @{
    $serviceName = "FTPSVC"
    $cisControlNumber = "5.11"
    $cisControlName = "Microsoft FTP Service (FTPSVC)"
}
$cisServiceSshd = @{
    $serviceName = "sshd"
    $cisControlNumber = "5.13"
    $cisControlName = "OpenSSH SSH Server (sshd)"
}
$cisServiceRpcLocator = @{
    $serviceName = "RpcLocator"
    $cisControlNumber = "5.23"
    $cisControlName = "Remote Procedure Call (RPC) Locator (RpcLocator)"
}
$cisServiceRemoteAccess = @{
    $serviceName = "RemoteAccess"
    $cisControlNumber = "5.25"
    $cisControlName = "Routing & Remote Access (RemoteAccess)"
}
$cisServiceSimpTcp = @{
    $serviceName = "simptcp"
    $cisControlNumber = "5.27"
    $cisControlName = "Simple TCP/IP Services (simptcp)"
}
$cisServiceSacSvr = @{
    $serviceName = "sacsvr"
    $cisControlNumber = "5.29"
    $cisControlName = "Special Administration Console Helper (sacsvr)"
}
$cisServiceSsdpSrv = @{
    $serviceName = "SSDPSRV"
    $cisControlNumber = "5.30"
    $cisControlName = "SSDP Discovery (SSDPSRV)"
}
$cisServiceUpnpHost = @{
    $serviceName = "upnphost"
    $cisControlNumber = "5.31"
    $cisControlName = "UPnP Device Host (upnphost)"
}
$cisServiceWMSvc = @{
    $serviceName = "WMSvc"
    $cisControlNumber = "5.32"
    $cisControlName = "Web Management Service (WMSvc)"
}
$cisServiceWMPNetworkSvc = @{
    $serviceName = "WMPNetworkSvc"
    $cisControlNumber = "5.35"
    $cisControlName = "Windows Media Player Network Sharing Service (WMPNetworkSvc)"
}
$cisServiceIcssSvc = @{
    $serviceName = "icssvc"
    $cisControlNumber = "5.36"
    $cisControlName = "Windows Mobile Hotspot Service (icssvc)"
}
$cisServiceW3svc = @{
    $serviceName = "W3SVC"
    $cisControlNumber = "5.40"
    $cisControlName = "World Wide Web Publishing Service (W3SVC)"
}
$cisServiceXboxGipSvc = @{
    $serviceName = "XboxGipSvc"
    $cisControlNumber = "5.41"
    $cisControlName = "Xbox Accessory Management Service (XboxGipSvc)"
}
$cisServiceXblAuthManager = @{
    $serviceName = "XblAuthManager"
    $cisControlNumber = "5.42"
    $cisControlName = "Xbox Live Auth Manager (XblAuthManager)"
}
$cisServiceXblGameSave = @{
    $serviceName = "XblGameSave"
    $cisControlNumber = "5.43"
    $cisControlName = "Xbox Live Game Save (XblGameSave)"
}
$cisServiceXboxNetApiSvc = @{
    $serviceName = "XboxNetApiSvc"
    $cisControlNumber = "5.44"
    $cisControlName = "Xbox Live Networking Service (XboxNetApiSvc)"
}

# 9 Windows Firewall with Advanced Security

# 9.1 Domain Profile
$cisFwDomSetOn = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile"
    $keyName = "EnableFirewall"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "9.1.1"
    $cisControlName = "Windows Firewall: Domain: Firewall state"
}
$cisFwDomDefaultInbound = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile"
    $keyName = "DefaultInboundAction"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "9.1.2"
    $cisControlName = "Windows Firewall: Domain: Inbound connections"
}
$cisFwDomDefaultOutbound = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile"
    $keyName = "DefaultOutboundAction"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "9.1.3"
    $cisControlName = "Windows Firewall: Domain: Outbound connections"
}
$cisFwDomDisableNotifications = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile"
    $keyName = "DisableNotifications"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "9.1.4"
    $cisControlName = "Windows Firewall: Domain: Settings: Display a notification"
}
$cisFwDomLogFilePath = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging"
    $keyName = "LogFilePath"
    $keyValueCorrect = "%SystemRoot%\System32\logfiles\firewall\domainfw.log"
    $keyType = "REG_SZ"
    $cisControlNumber = "9.1.5"
    $cisControlName = "Windows Firewall: Domain: Logging: Name"
}
$cisFwDomLogFileSize = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging"
    $keyName = "LogFileSize"
    $keyValueCorrect = "16384"
    $keyType = "DWORD"
    $cisControlNumber = "9.1.6"
    $cisControlName = "Windows Firewall: Domain: Logging: File size"
}
$cisFwDomLogDroppedPackets = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging"
    $keyName = "LogDroppedPackets"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "9.1.7"
    $cisControlName = "Windows Firewall: Domain: Logging: Log Dropped Packets"
}
$cisFwDomLogSuccessfulConnections = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging"
    $keyName = "LogSuccessfulConnections"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "9.1.8"
    $cisControlName = "Windows Firewall: Domain: Logging: Log Successful Connections"
}


# 9.2 Private Profile
$cisFwPriSetOn = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile"
    $keyName = "EnableFirewall"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "9.2.1"
    $cisControlName = "Windows Firewall: Private: Firewall state"
}
$cisFwPriDefaultInbound = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile"
    $keyName = "DefaultInboundAction"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "9.2.2"
    $cisControlName = "Windows Firewall: Private: Inbound connections"
}
$cisFwPriDefaultOutbound = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile"
    $keyName = "DefaultOutboundAction"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "9.2.3"
    $cisControlName = "Windows Firewall: Private: Outbound connections"
}
$cisFwPriDisableNotifications = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile"
    $keyName = "DisableNotifications"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "9.2.4"
    $cisControlName = "Windows Firewall: Private: Settings: Display a notification"
}
$cisFwPriLogFilePath = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging"
    $keyName = "LogFilePath"
    $keyValueCorrect = "%SystemRoot%\System32\logfiles\firewall\privatefw.log"
    $keyType = "REG_SZ"
    $cisControlNumber = "9.2.5"
    $cisControlName = "Windows Firewall: Private: Logging: Name"
}
$cisFwPriLogFileSize = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging"
    $keyName = "LogFileSize"
    $keyValueCorrect = "16384"
    $keyType = "DWORD"
    $cisControlNumber = "9.2.6"
    $cisControlName = "Windows Firewall: Private: Logging: File Size"
}
$cisFwPriLogDroppedPackets = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging"
    $keyName = "LogDroppedPackets"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "9.2.7"
    $cisControlName = "Windows Firewall: Private: Logging: Log Dropped Packets"
}
$cisFwPriLogSuccessfulConnections = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging"
    $keyName = "LogSuccessfulConnections"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "9.2.8"
    $cisControlName = "Windows Firewall: Private: Logging: Log Successful Connections"
}

# 9.3 Public Profile
$cisFwPubSetOn = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile"
    $keyName = "EnableFirewall"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "9.3.1"
    $cisControlName = "Windows Firewall: Public: Firewall state"
}
$cisFwPubDefaultInbound = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile"
    $keyName = "DefaultInboundAction"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "9.3.2"
    $cisControlName = "Windows Firewall: Public: Inbound connections"
}
$cisFwPubDefaultOutbound = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile"
    $keyName = "DefaultOutboundAction"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "9.3.3"
    $cisControlName = "Windows Firewall: Public: Outbound connections"
}
$cisFwPubDisableNotifications = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile"
    $keyName = "DisableNotifications"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "9.3.4"
    $cisControlName = "Windows Firewall: Public: Settings: Display a notification"
}
$cisFwPubApplyLocalRules = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile"
    $keyName = "AllowLocalPolicyMerge"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "9.3.5"
    $cisControlName = "Windows Firewall: Public: Settings: Apply local firewall rules"
}
$cisFwPubApplyLocalIPSecRules = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile"
    $keyName = "AllowLocalIPsecPolicyMerge"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "9.3.6"
    $cisControlName = "Windows Firewall: Public: Settings: Apply local connection security rules"
}
$cisFwPubLogFilePath = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging"
    $keyName = "LogFilePath"
    $keyValueCorrect = "%SystemRoot%\System32\logfiles\firewall\publicfw.log"
    $keyType = "REG_SZ"
    $cisControlNumber = "9.3.7"
    $cisControlName = "Windows Firewall: Public: Logging: Name"
}
$cisFwPubLogFileSize = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging"
    $keyName = "LogFileSize"
    $keyValueCorrect = "16384"
    $keyType = "DWORD"
    $cisControlNumber = "9.1.8"
    $cisControlName = "Windows Firewall: Public: Logging: File Size"
}
$cisFwPubLogDroppedPackets = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging"
    $keyName = "LogDroppedPackets"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "9.1.9"
    $cisControlName = "Windows Firewall: Public: Logging: Log Dropped Packets"
}
$cisFwPubLogSuccessfulConnections = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging"
    $keyName = "LogSuccessfulConnections"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "9.1.10"
    $cisControlName = "Windows Firewall: Public: Logging: Log Successful Connections"
}


# CIS SECTION 17: Advanced Audit Policy Configuration

Function Set-CisAuditPolicy {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [STRING]$subcategory,
        [SWITCH]$enableSuccess,
        [SWITCH]$disableSuccess,
        [SWITCH]$enableFailure,
        [SWITCH]$disableFailure,
        [STRING]$cisControlNumber,
        [STRING]$cisControlName
    )
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = "CIS: $cisControlNumber : $cisControlName"
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName"
    }
    Process {
        try {
            [STRING]$enableDisable = ""
            if ($enableSuccess){
                $enableDisable += "/success:enable "
            } elseif ($disableSuccess){
                $enableDisable += "/success:disable "
            } elseif ($enableFailure){
                $enableDisable += "/failure:enable "
            } elseif ($disableFailure){
                $enableDisable += "/failure:disable "
            }
            $enableDisable = $enableDisable.Trim()
            $auditPolArgs = "/set /subcategory:$subcategory $enableDisable"
            Start-Process -Path Auditpol.exe -ArgumentList $auditPolArgs -Wait -PassThru 
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : $stepName"
        Write-Host "END STEP: $global:stepNumber : $stepName" 
        $global:stepNumber++
        Remove-Variable -Name $stepName
    }
}
$cisAuditPolSplatTemplate = @{
    $subcategory = ""
    $enableSuccess = $True
    $disableSuccess = $True
    $enableFailure = $True
    $disableFailure = $True
    $cisControlNumber = ""
    $cisControlName = ""
}

# CIS SECTION 17.1: Account Logon

$cisAuditPolCredentialValidation = @{
    $subcategory = "Credential Validation"
    $enableSuccess = $True
    $disableSuccess = $False
    $enableFailure = $True
    $disableFailure = $False
    $cisControlNumber = "17.1.1"
    $cisControlName = "Audit Credential Validation"
}

# CIS SECTION 17.2: Account Management

$cisAuditPolAppGroupManagement = @{
    $subcategory = "Application Group Management"
    $enableSuccess = $True
    $disableSuccess = $False
    $enableFailure = $True
    $disableFailure = $False
    $cisControlNumber = "17.2.1"
    $cisControlName = "Audit Application Group Management"
}
$cisAuditPolSecGroupManagement = @{
    $subcategory = "Security Group Management"
    $enableSuccess = $True
    $disableSuccess = $False
    $enableFailure = $False
    $disableFailure = $True
    $cisControlNumber = "17.2.2"
    $cisControlName = "Audit Security Group Management"
}
$cisAuditPolUserAccManagement = @{
    $subcategory = "User Account Management"
    $enableSuccess = $True
    $disableSuccess = $False
    $enableFailure = $True
    $disableFailure = $False
    $cisControlNumber = "17.2.3"
    $cisControlName = "Audit User Account Management"
}

# CIS SECTION 17.3: Detailed Tracking

$cisAuditPolPnpActivity = @{
    $subcategory = "PNP Activity"
    $enableSuccess = $True
    $disableSuccess = $False
    $enableFailure = $False
    $disableFailure = $True
    $cisControlNumber = "17.3.1"
    $cisControlName = "Audit PNP Activity"
}
$cisAuditPolProcessCreation = @{
    $subcategory = "Process Creation"
    $enableSuccess = $True
    $disableSuccess = $False
    $enableFailure = $False
    $disableFailure = $True
    $cisControlNumber = "17.3.2"
    $cisControlName = "Audit Process Creation"
}

# CIS SECTION 17.5: Logon/Logoff

$cisAuditPolAccountLockout = @{
    $subcategory = "Account Lockout"
    $enableSuccess = $False
    $disableSuccess = $True
    $enableFailure = $True
    $disableFailure = $False
    $cisControlNumber = "17.5.1"
    $cisControlName = "Audit Account Lockout"
}
$cisAuditPolGroupMembership = @{
    $subcategory = "Group Membership"
    $enableSuccess = $True
    $disableSuccess = $False
    $enableFailure = $False
    $disableFailure = $True
    $cisControlNumber = "17.5.2"
    $cisControlName = "Audit Group Membership"
}
$cisAuditPolLogoff = @{
    $subcategory = "Logoff"
    $enableSuccess = $True
    $disableSuccess = $False
    $enableFailure = $False
    $disableFailure = $True
    $cisControlNumber = "17.5.3"
    $cisControlName = "Audit Logoff"
}
$cisAuditPolLogon = @{
    $subcategory = "Logon"
    $enableSuccess = $True
    $disableSuccess = $False
    $enableFailure = $True
    $disableFailure = $False
    $cisControlNumber = "17.5.3"
    $cisControlName = "Audit Logon"
}
$cisAuditPolOtherLogonEvents = @{
    $subcategory = "Other Logon/Logoff Events"
    $enableSuccess = $True
    $disableSuccess = $False
    $enableFailure = $True
    $disableFailure = $False
    $cisControlNumber = "17.5.5"
    $cisControlName = "Audit Other Logon/Logoff Events"
}
$cisAuditPolSpecialLogon = @{
    $subcategory = "Special Logon"
    $enableSuccess = $True
    $disableSuccess = $False
    $enableFailure = $False
    $disableFailure = $True
    $cisControlNumber = "17.5.6"
    $cisControlName = "Audit Special Logon"
}

# CIS SECTION 17.6: Object Access


$cisAuditPolDetailedFileShare = @{
    $subcategory = "Detailed File Share"
    $enableSuccess = $False
    $disableSuccess = $True
    $enableFailure = $True
    $disableFailure = $False
    $cisControlNumber = "17.6.1"
    $cisControlName = "Audit Detailed File Share"
}
$cisAuditPolFileShare = @{
    $subcategory = "File Share"
    $enableSuccess = $True
    $disableSuccess = $False
    $enableFailure = $True
    $disableFailure = $False
    $cisControlNumber = "17.6.2"
    $cisControlName = "Audit File Share"
}
$cisAuditPolOtherObjectEvents = @{
    $subcategory = "Other Object Access Events"
    $enableSuccess = $True
    $disableSuccess = $False
    $enableFailure = $True
    $disableFailure = $False
    $cisControlNumber = "17.6.3"
    $cisControlName = "Audit Other Object Access Events"
}
$cisAuditPolRemoveableStorage = @{
    $subcategory = "Removeable Storage"
    $enableSuccess = $True
    $disableSuccess = $False
    $enableFailure = $True
    $disableFailure = $False
    $cisControlNumber = "17.6.4"
    $cisControlName = "Audit Removeable Storage"
}

# CIS SECTION 17.7: Policy Change


$cisAuditPolPolicyChange = @{
    $subcategory = "Policy Change"
    $enableSuccess = $True
    $disableSuccess = $False
    $enableFailure = $False
    $disableFailure = $True
    $cisControlNumber = "17.7.1"
    $cisControlName = "Audit Policy Change"
}
$cisAuditPolAuthenticationPolicyChange = @{
    $subcategory = "Authentication Policy Change"
    $enableSuccess = $True
    $disableSuccess = $False
    $enableFailure = $False
    $disableFailure = $True
    $cisControlNumber = "17.7.2"
    $cisControlName = "Audit Authentication Policy Change"
}
$cisAuditPolAuthorizationPolicyChange = @{
    $subcategory = "Authorization Policy Change"
    $enableSuccess = $True
    $disableSuccess = $False
    $enableFailure = $False
    $disableFailure = $True
    $cisControlNumber = "17.7.3"
    $cisControlName = "Audit Authorization Policy Change"
}
$cisAuditPolMpssvcChange = @{
    $subcategory = "MPSSV Rule-Level Policy Change"
    $enableSuccess = $True
    $disableSuccess = $False
    $enableFailure = $True
    $disableFailure = $False
    $cisControlNumber = "17.7.4"
    $cisControlName = "Audit MPSSVC Rule-Level Policy Change"
}
$cisAuditPolOtherPolicyChange = @{
    $subcategory = "Other Policy Change Events"
    $enableSuccess = $False
    $disableSuccess = $True
    $enableFailure = $True
    $disableFailure = $False
    $cisControlNumber = "17.7.5"
    $cisControlName = "Audit Other Policy Change Events"
}

# CIS SECTION 17.8: Privilege Use

$cisAuditPolSensitivePriv = @{
    $subcategory = "Sensitive Privilege"
    $enableSuccess = $True
    $disableSuccess = $False
    $enableFailure = $True
    $disableFailure = $False
    $cisControlNumber = "17.8.1"
    $cisControlName = "Audit Sensitive Privilege Use"
}

# CIS SECTION 17.9: System

$cisAuditPolIpsecDriver = @{
    $subcategory = "IPsec Driver"
    $enableSuccess = $True
    $disableSuccess = $False
    $enableFailure = $True
    $disableFailure = $False
    $cisControlNumber = "17.9.1"
    $cisControlName = "Audit IPsec Driver"
}
$cisAuditPolOtherSystemEvents = @{
    $subcategory = "Other System Events"
    $enableSuccess = $True
    $disableSuccess = $False
    $enableFailure = $True
    $disableFailure = $False
    $cisControlNumber = "17.9.2"
    $cisControlName = "Audit Other System Events"
}
$cisAuditPolSecStateChange = @{
    $subcategory = "Security State Change"
    $enableSuccess = $True
    $disableSuccess = $False
    $enableFailure = $False
    $disableFailure = $True
    $cisControlNumber = "17.9.3"
    $cisControlName = "Audit Security State Change"
}
$cisAuditPolSecSystemExtension = @{
    $subcategory = "Security System Extension"
    $enableSuccess = $True
    $disableSuccess = $False
    $enableFailure = $False
    $disableFailure = $True
    $cisControlNumber = "17.9.4"
    $cisControlName = "Audit Security System Extension"
}
$cisAuditPolSystemIntegrity = @{
    $subcategory = "System Integrity"
    $enableSuccess = $True
    $disableSuccess = $False
    $enableFailure = $True
    $disableFailure = $False
    $cisControlNumber = "17.9.5"
    $cisControlName = "Audit System Integrity"
}


# CIS SECTION 18 Administrative Templates
# CIS SECTION 18.1: Control Panel
# CIS SECTION 18.1.1 Personalisation
$cisPreventLockScreenCamera = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
    $keyName = "NoLockScreenCamera"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.1.1.1"
    $cisControlName = "Prevent enabling lock screen camera"
}
$cisPreventLockScreenSlideshow = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
    $keyName = "NoLockScreenSlideshow"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.1.1.2"
    $cisControlName = "Prevent enabling lock screen slideshow"
}
# CIS SECTION: 18.1.2 Language & Regional Options
$cisDenyOnlineSpeechServices = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization"
    $keyName = "AllowInputPersonalization"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.1.2.2"
    $cisControlName = "Allow users to enable online speech recognition services"
}

# CIS SECTION 18.2: LAPS
Function Test-cisLapsPresence {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    Begin {
        Write-Log -Path $global:logFile -Level Info -Message $(New-Hashline -LineLength 80)
        [STRING]$stepName = ""
        Write-Log -Path $global:logFile -Level Info -Message "START STEP: $global:stepNumber : $stepName"
        Write-Host "START STEP: $global:stepNumber : $stepName"
    }
    Process {
        try {
            $cisPresence = Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\GPExtensions\{D76B9641-3288-4f75-942D087DE603E3EA}\DllName"
            if ($cisPresence -eq $True){
                Write-Log -Path $global:logFile -Level Info -Message "Microsoft LAPS CSE is installed. No further action required" 
            } else {
                Write-Log -Path $global:logFile -Level Info -Message "Microsoft LAPS CSE is NOT installed." 
                Install-MicrosoftLAPS
            }
        }
        catch {
            Write-Host $PSItem.Exception.Message -ForegroundColor Red
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    End {
        Write-Log -Path $global:logFile -Level Info -Message "END STEP: $global:stepNumber : $stepName"
        Write-Host "END STEP: $global:stepNumber : $stepName" 
        $global:stepNumber++
        Remove-Variable -Name $stepName
    }
}
$cisLapsLimitPasswordExpiryTime = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft Services\AdmPwd"
    $keyName = "PwdExpirationProtectionEnabled"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.2.2"
    $cisControlName = "'Do not allow password expiration time longer than required by policy"
}
$cisLapsEnableLaps = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft Services\AdmPwd"
    $keyName = "AdmPwdEnabled"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.2.3"
    $cisControlName = "Enable Local Admin Password Management"
}
$cisLapsPasswordComplexity = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft Services\AdmPwd"
    $keyName = "PasswordComplexity"
    $keyValueCorrect = "4"
    $keyType = "DWORD"
    $cisControlNumber = "18.2.4"
    $cisControlName = "Password Settings: Password Complexity"
}
$cisLapsPasswordLength = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft Services\AdmPwd"
    $keyName = "PasswordLength"
    $keyValueCorrect = "20"
    $keyType = "DWORD"
    $cisControlNumber = "18.2.5"
    $cisControlName = "Password Settings: Password Length"
}
$cisLapsPasswordAge = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft Services\AdmPwd"
    $keyName = "PasswordAge"
    $keyValueCorrect = "15"
    $keyType = "DWORD"
    $cisControlNumber = "18.2.6"
    $cisControlName = "Password Settings: Password Age (Days)"
}

# CIS SECTION 18.3: Microsoft Security Guide
Function Install-MicrosoftSecurityBaselines {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    begin {
        try {
            # ZIP file for 2004
            $uriSource = "https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/Windows%2010%20Version%202004%20and%20Windows%20Server%20Version%202004%20Security%20Baseline.zip"            
        }
        catch {
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }

        Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Setting Arguments"
        $Vendor = "Microsoft"
        $Product = "Security Baseline"
        $Version = "2004"
        $PackageName = "MSG"
        $InstallerType = "zip"
        $Source = "$PackageName" + "." + "$InstallerType"
        $LogApp = "${env:SystemRoot}" + "\Temp\$PackageName.log"
        $ProgressPreference = 'SilentlyContinue'
    }
    process {
        Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Creating directories"
        $VersionPath = Join-Path -Path $global:generalOutputFolder -ChildPath $Version
        if ( -Not (Test-Path -Path $VersionPath)){
            New-Item -ItemType Directory -Path $VersionPath | Out-Null
        }
        Set-Location $VersionPath
        
        try {
            Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Downloading $Vendor $Product version $Version"
            if (!(Test-Path -Path $Source)){
                Invoke-WebRequest -Uri $uriSource -OutFile $Source
            } else {
                Remove-Item -Path $Source -Force
                Invoke-WebRequest -Uri $uriSource -OutFile $Source
            }
        }
        catch {
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }

        try {
            Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Installing version $Version"
            New-Item -Path $(Join-Path -Path (Split-Path -Path $LogApp) -ChildPath $PackageName) -ItemType Directory -Force | Out-Null
            [STRING]$extractedContent = $(Join-Path -Path (Split-Path -Path $LogApp) -ChildPath $PackageName)
            Expand-Archive -LiteralPath (Join-Path -Path (Split-Path -Path $LogApp) -ChildPath $Source) | Out-Null
            
            $admxSecGuide = "Templates\SecGuide.admx"
            $admlSecGuide = "Templates\en-US\SecGuide.adml"
            $admxLegacy = "Templates\MSS-legacy.admx"
            $admlLegacy = "Templates\en-US\MSS-legacy.adml"

            Copy-Item -Path (Join-Path -Path $extractedContent -ChildPath $admxSecGuide) -Destination $env:WinDir\PolicyDefinitions -Force | Out-Null
            Copy-Item -Path (Join-Path -Path $extractedContent -ChildPath $admxLegacy) -Destination $env:WinDir\PolicyDefinitions -Force | Out-Null
            Copy-Item -Path (Join-Path -Path $extractedContent -ChildPath $admlSecGuide) -Destination $env:WinDir\PolicyDefinitions\en-US -Force | Out-Null
            Copy-Item -Path (Join-Path -Path $extractedContent -ChildPath $admlLegacy) -Destination $env:WinDir\PolicyDefinitions\en-US -Force | Out-Null
        }
        catch {
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }

        try {
            Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : Cleaning up"
            if (Test-Path $extractedContent){
                Get-ChildItem -Path $extractedContent -Recurse -Force | Remove-Item -Force | Out-Null
                Remove-Item -Path $extractedContent -Force | Out-Null
            }
            Write-Log $global:logFile -Level Info -Message "INSTALL $Vendor $Product : INSTALLATION COMPLETE"
        }
        catch {
            Write-Log -Path $global:logFile -Level Error -Message $PSItem.Exception.Message
        }
        finally {
            $Error.Clear | Out-Null
        }
    }
    end {
        Set-Location $startLocation
        Get-ChildItem -Path $VersionPath -Recurse -Force | Remove-Item | Out-Null
        Remove-Item $VersionPath -Force | Out-Null
    }
}

$cisMsgUacToLocalOnNetwork = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $keyName = "LocalAccountTokenFilterPolicy"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.3.1"
    $cisControlName = "Apply UAC restrictions to local accounts on network logons"
}
$cisMsgConfigureSmbV1Driver = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Services\mrxsmb10"
    $keyName = "Start"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.3.2"
    $cisControlName = "Configure SMB v1 client driver"
}
$cisMsgConfigureSmbV1 = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
    $keyName = "SMB1"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.3.3"
    $cisControlName = "Configure SMB v1 server"
}
$cisMsgSehop = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel"
    $keyName = "DisableExceptionChainValidation"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = ""
    $cisControlName = ""
}
$cisMsgNetbtNodeType = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters"
    $keyName = "NodeType"
    $keyValueCorrect = "2"
    $keyType = "DWORD"
    $cisControlNumber = "18.3.5"
    $cisControlName = "NetBT NodeType configuration"
}
$cisMsgWdigestAuth = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest"
    $keyName = "UseLogonCredential"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.3.6"
    $cisControlName = "WDigest Authentication"
}

# CIS SECTION 18.4: MSS (Legacy)
$cisMssAutoLoginDisabled = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    $keyName = "AutoAdminLogon"
    $keyValueCorrect = "0"
    $keyType = "REG_SZ"
    $cisControlNumber = "18.4.1"
    $cisControlName = "'MSS: (AutoAdminLogon) Enable Automatic Logon (not recommended)"
}
$cisMssClearDefaultPassword = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    $keyName = "DefaultPassword"
    $keyValueCorrect = ""
    $keyType = "REG_SZ"
    $cisControlNumber = "N/A"
    $cisControlName = "N/A"
}
$cisMssIPv6SourceRouting = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters"
    $keyName = "DisableIPSourceRouting"
    $keyValueCorrect = "2"
    $keyType = "DWORD"
    $cisControlNumber = "18.4.2"
    $cisControlName = "MSS: (DisableIPSourceRouting IPv6) IP source routing protection level (protects against packet spoofing)"
}
$cisMssIpSourceRouting = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    $keyName = "DisableIPSourceRouting"
    $keyValueCorrect = "2"
    $keyType = "DWORD"
    $cisControlNumber = "18.4.3"
    $cisControlName = "MSS: (DisableIPSourceRouting) IP source routing protection level (protects against packet spoofing)"
}
$cisMssIcmpRedirect = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    $keyName = "EnableICMPRedirect"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.4.5"
    $cisControlName = "MSS: (EnableICMPRedirect) Allow ICMP redirects to override OSPF generated routes"
}
$cisMssIgnoreNetbiosRequests = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters"
    $keyName = "NoNameReleaseOnDemand"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.4.7"
    $cisControlName = "MSS: (NoNameReleaseOnDemand) Allow the computer to ignore NetBIOS name release requests except from WINS servers"
}
$cisMssSafeDllSearchMode = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager"
    $keyName = "SafeDllSearchMode"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.4.9"
    $cisControlName = "MSS: (SafeDllSearchMode) Enable Safe DLL search mode (recommended)"
}
$cisMssScreenSaverGracePeriod = @{
    $keyPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
    $keyName = "ScreenSaverGracePeriod"
    $keyValueCorrect = "0"
    $keyType = "REG_SZ"
    $cisControlNumber = "18.4.10"
    $cisControlName = "MSS:(ScreenSaverGracePeriod) The time in seconds before the screen saver grace period expires (0 recommended)"
}
$cisSecurityEventLogAlertLevel = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Eventlog\Security"
    $keyName = "WarningLevel"
    $keyValueCorrect = "90"
    $keyType = "DWORD"
    $cisControlNumber = "18.4.13"
    $cisControlName = "MSS: (WarningLevel) Percentage threshold for the security event log at which the system will generate a warning"
}

# CIS SECTION 18.5.4: DNS Client
$cisDnsCliMulticast = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient"
    $keyName = "EnableMulticast"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.5.4.1"
    $cisControlName = "Turn off multicast name resolution"
}

# CIS SECTION 18.5.8: Lanman Workstation
$cisLanmanInsecureLogons = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation"
    $keyName = "AllowInsecureGuestAuth"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.5.8.1"
    $cisControlName = "'Enable insecure guest logons"
}

# CIS SECTION 18.5.11: Network Connections
# CIS SECTION 18.5.11.1: Windows Defender Firewall
$cisDefProhibitDnsBridge = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections"
    $keyName = "NC_AllowNetBridge_NLA"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.5.11.2"
    $cisControlName = "Prohibit installation and configuration of Network Bridge on your DNS domain network"
}
$cisDefProhibitIcs = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections"
    $keyName = "NC_ShowSharedAccessUI"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.5.11.3"
    $cisControlName = "Prohibit use of Internet Connection Sharing on your DNS domain network"
}
$cisDefElevateWhenChangeLocation = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections"
    $keyName = "NC_StdDomainUserSetLocation"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.5.11.4"
    $cisControlName = "Require domain users to elevate when setting a network's location"
}

# CIS SECTION 18.5.14: Network Provider
$cisNetProvHardenedUncPathsEnabled1 = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths"
    $keyName = "\\*\NETLOGON"
    $keyValueCorrect = "RequireMutualAuthentication=1,RequireIntegrity=1"
    $keyType = "REG_SZ"
    $cisControlNumber = "18.5.14.1"
    $cisControlName = "Ensure 'Hardened UNC Paths' is set to 'Enabled, with Require Mutual Authentication and Require Integrity set for all NETLOGON and SYSVOL shares "
}
$cisNetProvHardenedUncPathsEnabled2 = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths"
    $keyName = "\\*\SYSVOL"
    $keyValueCorrect = "RequireMutualAuthentication=1,RequireIntegrity=1"
    $keyType = "REG_SZ"
    $cisControlNumber = "18.5.14.1"
    $cisControlName = "Ensure 'Hardened UNC Paths' is set to 'Enabled, with Require Mutual Authentication and Require Integrity set for all NETLOGON and SYSVOL shares "
}

# CIS SECTION 18.5.21: Windows Connection Manager
$cisWinConMgrMinimizeConnections = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy"
    $keyName = "fMinimizeConnections"
    $keyValueCorrect = "3"
    $keyType = "DWORD"
    $cisControlNumber = "18.5.21.1"
    $cisControlName = "Minimize the number of simultaneous connections to the Internet or a Windows Domain"
}
$cisWinConMgrProhibitNonDomain = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy"
    $keyName = "fBlockNonDomain"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.5.21.2"
    $cisControlName = "Prohibit connection to non-domain networks when connected to domain authenticated network"
}

# CIS SECTION 18.5.23.2: WLAN Settings
$cisWlanDisableAutoHotspotConnect = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"
    $keyName = "AutoConnectAllowedOEM"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.5.23.2.1"
    $cisControlName = "Allow Windows to automatically connect to suggested open hotspots, to networks shared by contacts, and to hotspots offering paid services"
}

# CIS SECTION 18.8.3: Audit Process Creation
$cisAuditProcCreation = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit"
    $keyName = "ProcessCreationIncludeCmdLine_Enabled"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.3.1"
    $cisControlName = "Include command line in process creation events"
}

# CIS SECTION 18.8.4: Credentials Delegation
$cisCredDelegEncryptionOracle = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters"
    $keyName = "AllowEncryptionOracle"
    $keyValueCorrect = "2"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.4.1"
    $cisControlName = "Encryption Oracle Remediation"
}
$cisCredDelegNonExportableCredentials = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation"
    $keyName = "AllowProtectedCreds"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.4.2"
    $cisControlName = "Remote host allows delegation of non-exportable credentials"
}

# CIS SECTION 18.8.5: Device Guard
$cisDevGuardSecBoot = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard\"
    $keyName = "EnableVirtualizationBasedSecurity"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.5.1"
    $cisControlName = "Turn On Virtualization Based Security"
}
$cisDevGuardPlatformSecurity = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard\"
    $keyName = "RequirePlatformSecurityFeatures"
    $keyValueCorrect = "3"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.5.2"
    $cisControlName = "Turn On Virtualization Based Security: Select Platform Security Level"
}
$cisDevGuardVirtCodeIntegrity = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard"
    $keyName = "HypervisorEnforcedCodeIntegrity"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.5.3"
    $cisControlName = "Turn On Virtualization Based Security: Virtualization Based Protection of Code Integrity"
}
$cisDevGuardUefiMemAttributes = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard"
    $keyName = "HVCIMATRequired"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.5.4"
    $cisControlName = "Turn On Virtualization Based Security: Require UEFI Memory Attributes Table"
}
$cisDevGuardCredGuardConfig = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard"
    $keyName = "LsaCfgFlags"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.5.5"
    $cisControlName = "Turn On Virtualization Based Security: Credential Guard Configuration"
}
$cisDevGuardSecureLaunch = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard"
    $keyName = "ConfigureSystemGuardLaunch"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.5.6"
    $cisControlName = "Turn On Virtualization Based Security: Secure Launch Configuration"
}

# CIS SECTION 18.8.14: Early Launch Antimalware
$cisELABootStartDriver = @{
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Policies\EarlyLaunch"
    $keyName = "DriverLoadPolicy"
    $keyValueCorrect = "3"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.14.1"
    $cisControlName = "Boot-Start Driver Initialization Policy"
}

# CIS SECTION 18.8.21.1: Logging & Tracing
$cisLoggingConfigRegistryPolicyProcessing = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\{35378EAC-683F-11D2-A89A-00C04FBBCFA2}"
    $keyName = "NoBackgroundPolicy"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.21.2"
    $cisControlName = "Configure registry policy processing: Do not apply during periodic background processing"
}
$cisLoggingRegPolAlwayProcess = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\{35378EAC-683F-11D2-A89A-00C04FBBCFA2}"
    $keyName = "NoGPOListChanges"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.21.3"
    $cisControlName = "Configure registry policy processing: Process even if the Group Policy objects have not changed"
}
$cisLoggingContinueExperiences = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    $keyName = "EnableCdp"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.21.4"
    $cisControlName = "Continue experiences on this device"
}
$cisLoggingDisableBackgroundGpoRefresh = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $keyName = "DisableBkGndGroupPolicy"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.21.5"
    $cisControlName = "Turn off background refresh of Group Policy"
}

# CIS SECTION 18.8.22: Internet Connection Settings
$cisICSDisableHttpPrintDriverDownload = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers"
    $keyName = "DisableWebPnPDownload"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.22.2"
    $cisControlName = "Turn off downloading of print drivers over HTTP"
}
$cisICSDisableInternetDownload = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    $keyName = "NoWebServices"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.22.1.6"
    $cisControlName = "Turn off Internet download for Web publishing and online ordering wizards"
}

# CIS SECTION 18.8.28: Logon
$cisLogonBlockAccountDetailDisplay = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    $keyName = "BlockUserFromShowingAccountDetailsOnSignin"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.28.1"
    $cisControlName = "Block user from showing account details on sign-in"
}
$cisLogonNetworkSelectionUi = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    $keyName = "DontDisplayNetworkSelectionUI"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.28.2"
    $cisControlName = "Do not display network selection UI"
}
$cisLogonPreventEnumerateConnectedUsers = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    $keyName = "DontEnumerateConnectedUsers"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.28.3"
    $cisControlName = "Do not enumerate connected users on domain- joined computers"
}
$cisLogonEnumerateLocalUsers = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    $keyName = "EnumerateLocalUsers"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.28.4"
    $cisControlName = "Enumerate local users on domain-joined computers"
}
$cisLogonLockScreenAppNotifications = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    $keyName = "DisableLockScrenAppNotifications"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.28.5"
    $cisControlName = "Turn off app notifications on the lock screen"
}
$cisLogonDisablePicturePassword = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    $keyName = "BlockDomainPicturePassword"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.28.6"
    $cisControlName = "Turn off picture password sign-in"
}
$cisLogonDisablePin = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    $keyName = "AllowDomainPINLogon"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.28.7"
    $cisControlName = "Turn on convenience PIN sign-in"
}

# CIS SECTION 18.8.34.6: Sleep Settings
$cisSleepBatteryNetConnectivity = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9"
    $keyName = "DCSettingIndex"
    $keyValueCorrect = "0"
    $keyType = "DWORD."
    $cisControlNumber = "18.8.34.6.1"
    $cisControlName = "Allow network connectivity during connected- standby (on battery)"
}
$cisSleepACNetConnectivity = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9"
    $keyName = "ACSettingIndex"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.34.6.2"
    $cisControlName = "Allow network connectivity during connected- standby (plugged in)"
}
$cisSleepBatteryRequirePassword = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\0e796bdb-100d-47d6-a2d5-f7d2daa51f51"
    $keyName = "DCSettingIndex"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.34.6.5"
    $cisControlName = "Require a password when a computer wakes (on battery)"
}
$cisSleepAcRequirePassword = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\0e796bdb-100d-47d6-a2d5-f7d2daa51f51"
    $keyName = "ACSettingIndex"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.34.6.6"
    $cisControlName = "Require a password when a computer wakes (plugged in)"
}

# CIS SECTION 18.8.36: Remote Assistance
$cisRemoteAssistanceConfigure = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
    $keyName = "fAllowUnsolicited"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.36.1"
    $cisControlName = "Configure Offer Remote Assistance"
}
$cisRemoteAssistanceConfigureSolicited = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
    $keyName = "fAllowToGetHelp"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.36.2"
    $cisControlName = "Configure Solicited Remote Assistance"
}

# CIS SECTION 18.8.37: Remote Procedure Call
$cisRpcEndpointMapperAuth = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Rpc"
    $keyName = "EnableAuthEpResolution"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.37.1"
    $cisControlName = "Enable RPC Endpoint Mapper Client Authentication"
}
$cisRpcRestrictUnauthClients = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Rpc"
    $keyName = "RestrictRemoteClients"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.37.2"
    $cisControlName = "Restrict Unauthenticated RPC clients"
}

# CIS SECTION 18.9.4: App Package Deployment
$cisAppDepPreventNonAdminInstall = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx"
    $keyName = "BlockNonAdminUserInstall"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.4.2"
    $cisControlName = "Prevent non-admin users from installing packaged Windows apps"
}

# CIS SECTION 18.9.5: App Privacy
$cisAppPrivacyLockVoiceActivation = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy"
    $keyName = "LetAppsActivateWithVoiceAboveLock"
    $keyValueCorrect = "2"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.5.1"
    $cisControlName = "Let Windows apps activate with voice while the system is locked"
}

# CIS SECTION 18.9.6: App Runtime
$cisAppRunOptionalMsAccounts = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $keyName = "MSAOptional"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.6.1"
    $cisControlName = "Allow Microsoft accounts to be optional"
}

# CIS SECTION 18.9.8: Autoplay Policies
$cisDisableAutoplayNonVolume = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
    $keyName = "NoAutoplayfornonVolume"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.8.1"
    $cisControlName = "Disallow Autoplay for non-volume devices"
}
$cisAutorunDefaultBehaviour = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    $keyName = "NoAutorun"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.8.2"
    $cisControlName = "Set the default behavior for AutoRun"
}
$cisDisableAutoplay = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    $keyName = "NoDriveTypeAutoRun"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.8.3"
    $cisControlName = "Turn off Autoplay'"
}

# CIS SECTION 18.9.10: Biometrics
$cisBiometricsAntiSpoofing = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics\FacialFeatures"
    $keyName = "EnhancedAntiSpoofing"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.10.1.1"
    $cisControlName = "Configure enhanced anti-spoofing"
}

# CIS SECTION 18.9.13: Cloud Content
# NOTE: ONLY ENTERPRISE
$cisDisableConsumerExperiences = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    $keyName = "DisableWindowsConsumerFeatures"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.13.1"
    $cisControlName = "Turn off Microsoft consumer experiences"
}

# CIS SECTION 18.9.4: Connect
$cisConnectRequirePinPair = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Connect"
    $keyName = "RequirePinForPairing"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.14.1"
    $cisControlName = "Require pin for pairing"
}

# CIS SECTION 18.9.15: Credential User Interface
$cisCUIHidePasswordReveal = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI"
    $keyName = "DisablePasswordReveal"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.15.1"
    $cisControlName = "Do not display the password reveal button"
}
$cisCUIEnumerateAdminsOnElevation = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI"
    $keyName = "EnumerateAdministrators"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.15.2"
    $cisControlName = "Enumerate administrator accounts on elevation"
}
$cisCUIPreventSecurityQuestions = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    $keyName = "NoLocalPasswordResetQuestions"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.15.3"
    $cisControlName = "Prevent the use of security questions for local accounts"
}

# CIS SECTION 18.9.16: Data Collection & Preview Builds
$cisDataCollAllowTelemetryBasic = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    $keyName = "AllowTelemetry"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.16.1"
    $cisControlName = "Allow Telemetry"
}
$cisDataCollHideFeedbackNotifications = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    $keyName = "DoNotShowFeedbackNotifications"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.16.3"
    $cisControlName = "Do not show feedback notifications"
}
$cisDataCollInsiderBuildsControl = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds"
    $keyName = "AllowBuildPreview"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.16.4"
    $cisControlName = "Toggle user control over Insider builds"
}

# CIS SECTION 18.9.17: Delivery Optimization
#
# NEEDS VALUE HERE
#
$cisDelOptDownloadMode = @{
    $keyPath = ""
    $keyName = ""
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.17.1"
    $cisControlName = "Download Mode"
}

# CIS SECTION 18.9.26: Event Log Service
# 18.9.26.1: Applications
$cisEvLogAppReachMaxSize = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application"
    $keyName = "Retention"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.26.1.1"
    $cisControlName = "Application: Control Event Log behavior when the log file reaches its maximum size"
}
$cisEvLogAppMaxSize = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application"
    $keyName = "MaxSize"
    $keyValueCorrect = "32768"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.26.1.2"
    $cisControlName = "Application: Specify the maximum log file size (KB)"
}
# 18.9.26.2: Security
$cisEvLogSecReachMaxSize = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security"
    $keyName = "Retention"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.26.2.1"
    $cisControlName = "Security: Control Event Log behavior when the log file reaches its maximum size"
}
$cisEvLogSecMaxSize = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security"
    $keyName = "MaxSize"
    $keyValueCorrect = "196608"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.26.2.2"
    $cisControlName = "Security: Specify the maximum log file size (KB)"
}
# 18.9.26.3: Setup
$cisEvLogSetReachMaxSize = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Setup"
    $keyName = "Retention"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.26.3.1"
    $cisControlName = "Setup: Control Event Log behavior when the log file reaches its maximum size"
}
$cisEvLogSetMaxSize = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Setup"
    $keyName = "MaxSize"
    $keyValueCorrect = "32768"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.26.3.1"
    $cisControlName = "Setup: Specify the maximum log file size (KB)"
}
# 18.9.26.4: System
$cisEvLogSysReachMaxSize = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\System"
    $keyName = "Retention"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.26.4.1"
    $cisControlName = "System: Control Event Log behavior when the log file reaches its maximum size"
}
$cisEvLogSysMaxSize = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\System"
    $keyName = "MaxSize"
    $keyValueCorrect = "32768"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.26.3.1"
    $cisControlName = "System: Specify the maximum log file size (KB)"
}

# CIS SECTION 18.9.30.1: Previous Versions
$cisPreVerDisableDep = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
    $keyName = "NoDataExecutionPrevention"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.30.2.2"
    $cisControlName = "Turn off Data Execution Prevention for Explorer"
}
$cisPreVerDisableHeapTermination = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
    $keyName = "NoHeapTerminationCorruption"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.30.3"
    $cisControlName = "Turn off heap termination on corruption"
}
$cisPreVerDisableShellProtectedMode = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    $keyName = "PreXPSP2ShellProtocolBehavior"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.30.4"
    $cisControlName = "Turn off shell protocol protected mode"
}

# CIS SECTION 18.9.35: HomeGroup
$cisHomeGroupDenyJoin = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\HomeGroup"
    $keyName = "DisableHomeGroup"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.35.1"
    $cisControlName = "Prevent the computer from joining a homegroup"
}

# CIS SECTION 18.9.44: Microsoft Account
$cisMsAccBlockConsumerAuth = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftAccount"
    $keyName = "DisableUserAuth"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.44.1"
    $cisControlName = "Block all consumer Microsoft account user authentication"
}

# CIS SECTION 19.9.45: Microsoft Defender Antivirus
# 18.9.45.3: MAPS (Microsoft Active Protection Service)
$cisDefMapsConfigureLocalOverride = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet"
    $keyName = "LocalSettingOverrideSpynetReporting"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.45.3.1"
    $cisControlName = "Configure local setting override for reporting to Microsoft MAPS"
}
# 18.9.45.4: Microsoft Defender Exploit Guard
$cisDefDegConfigureAsr = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR"
    $keyName = "ExploitGuard_ASR_Rules"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.45.4.1.1."
    $cisControlName = "Configure Attack Surface Reduction rules"
}
# CONFIGURE ASR RULES
$cisDefAsrBlockOfficeCommsChildProcesses = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules"
    $keyName = "26190899-1602-49e8-8b27-eb1d0a1ce869"
    $keyValueCorrect = "1"
    $keyType = "REG_SZ"
    $cisControlNumber = "18.9.45.4.1.2"
    $cisControlName = "Block Office communication application from creating child processes"
}
$cisDefAsrBlockOfficeCreateExecutables = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules"
    $keyName = "3b576869-a4ec-4529-8536-b80a7769e899"
    $keyValueCorrect = "1"
    $keyType = "REG_SZ"
    $cisControlNumber = "18.9.45.4.1.2"
    $cisControlName = "Block Office applications from creating executable content"
}
$cisDefAsrBlockObfuscatedScripts = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules"
    $keyName = "5beb7efe-fd9a-4556-801d-275e5ffc04cc"
    $keyValueCorrect = "1"
    $keyType = "REG_SZ"
    $cisControlNumber = "18.9.45.4.1.2"
    $cisControlName = "Block execution of potentially obfuscated scripts"
}
$cisDefAsrBlockOfficeCodeInjection = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules"
    $keyName = "75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84"
    $keyValueCorrect = "1"
    $keyType = "REG_SZ"
    $cisControlNumber = "18.9.45.4.1.2"
    $cisControlName = "Block Office eapplications from injecting code into other processes"
}
$cisDefAsrBlockAdobeReaderChildProcesses = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules"
    $keyName = "7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c"
    $keyValueCorrect = "1"
    $keyType = "REG_SZ"
    $cisControlNumber = "18.9.45.4.1.2"
    $cisControlName = "Block Adobe Reader from creating child processes"
}
$cisDefAsrBlockOfficeMacroWin32ApiCalls = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules"
    $keyName = "92e97fa1-2edf-4476-bdd6-9dd0b4dddc7b"
    $keyValueCorrect = "1"
    $keyType = "REG_SZ"
    $cisControlNumber = "18.9.45.4.1.2"
    $cisControlName = "Block Win32 API calls from Office macro"
}
$cisDefAsrBlockLsassCredentialTheft = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules"
    $keyName = "9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2"
    $keyValueCorrect = "1"
    $keyType = "REG_SZ"
    $cisControlNumber = "18.9.45.4.1.2"
    $cisControlName = "Block credential stealing from the Windows local security authority subsystem (lsass.exe)"
}
$cisDefAsrBlockUntrustedUsbProcesses = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules"
    $keyName = "b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4"
    $keyValueCorrect = "1"
    $keyType = "REG_SZ"
    $cisControlNumber = "18.9.45.4.1.2"
    $cisControlName = "Block untrusted and unsigned processes that run from USB"
}
$cisDefAsrBlockEmailExecutables = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules"
    $keyName = "be9ba2d9-53ea-4cdc-84e5-9b1eeee46550"
    $keyValueCorrect = "1"
    $keyType = "REG_SZ"
    $cisControlNumber = "18.9.45.4.1.2"
    $cisControlName = "Block executable content from email client and webmail"
}
$cisDefAsrBlockJavaVbScriptDownloads = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules"
    $keyName = "d3e037e1-3eb8-44c8-a917-57927947596d"
    $keyValueCorrect = "1"
    $keyType = "REG_SZ"
    $cisControlNumber = "18.9.45.4.1.2"
    $cisControlName = "Block Java & VBScript Downloads"
}
$cisDefAsrBlockOfficeChildProcesses = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules"
    $keyName = "d4f940ab-401b-4efc-aadc-ad5f3c50688a"
    $keyValueCorrect = "1"
    $keyType = "REG_SZ"
    $cisControlNumber = "18.9.45.4.1.2"
    $cisControlName = "Block Office applications from creating child processes"
}
# 18.9.45.4.3: Network Protection
$cisDefNetPreventDangerousWebsites = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Microsoft Defender\Microsoft Defender Exploit Guard\Network Protection"
    $keyName = "EnableNetworkProtection"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.45.4.3"
    $cisControlName = "Prevent users and apps from accessing dangerous websites"
}
# 18.9.45.5.8: Real-time Protection
$cisDefRtEnableBehaviourMonitor = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection"
    $keyName = "DisableBehaviourMonitoring"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.45.8.1"
    $cisControlName = "Turn on behavior monitoring"
}
# 18.9.45.11: Scan
$cisDefScanRemoveableDrive = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan"
    $keyName = "DisableRemoveableDriveScanning"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.45.11.1"
    $cisControlName = "Scan removable drives"
}
$cisDefScanEmail = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan"
    $keyName = "DisableEmailScanning"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.45.11.2"
    $cisControlName = "Turn on e-mail scanning"
}
# 18.9.45.13: Threats
$cisDefThreatsPua = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
    $keyName = "PUAProtection"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.45.13"
    $cisControlName = "Configure detection for potentially unwanted applications"
}
$cisDefDisableDefender = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
    $keyName = "DisableAntiSpyware"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.45.15"
    $cisControlName = "Turn off Microsoft Defender AntiVirus"
}
# CIS SECTION 18.9.46: Microsoft Defender Application Guard
$cisDefAGAuditApplicationGuard = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI"
    $keyName = "AuditApplicationGuard"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.45.1"
    $cisControlName = "Allow auditing events in Microsoft Defender Application Guard"
}
$cisDefAGAllowCameraMic = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI"
    $keyName = "AllowCameraMicrophoneRedirection"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.46.2"
    $cisControlName = "Allow camera and microphone access in Microsoft Defender Application Guard"
}
$cisDefAGAllowDataPersistence = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI"
    $keyName = "AllowPersistence"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.46.3"
    $cisControlName = "Allow data persistence for Microsoft Defender Application Guard"
}
$cisDefAGAllowDAGFileDownload = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI"
    $keyName = "SaveFilesToHost"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.46.4"
    $cisControlName = "Allow files to download and save to the host operating system from Microsoft Defender Application Guard"
}
$cisDefAGClipboardBehaviour = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI"
    $keyName = "AllowAppHVSI_ProviderSet"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.46.5"
    $cisControlName = "Configure Microsoft Defender Application Guard clipboard settings: Clipboard behavior setting"
}
$cisDefAGManagedMode = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI"
    $keyName = "AllowAppHVSI_ProviderSet"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.46.6"
    $cisControlName = "Turn on Microsoft Defender Application Guard in Managed Mode"
}

# CIS SECTION 18.9.48: Microsoft Edge (Original)
$cisMsEdgeAllowExtensionSideloading = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Extensions"
    $keyName = "AllowSideloadingOfExtensions"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.48.4"
    $cisControlName = "Allow Sideloading of extension"
}
$cisMsEdgeConfigureCookies = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main"
    $keyName = "Cookies"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.48.5"
    $cisControlName = "Configure cookies"
}
$cisMsEdgeConfigurePasswordManager = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main"
    $keyName = "FormSuggestPasswords"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.48.6"
    $cisControlName = "Configure Password Manager"
}
$cisMsEdgeConfigureFlashClickToRun = @{
    $keyPath = "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Security"
    $keyName = "FlashClickToRunMode"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.48.9"
    $cisControlName = "Configure the Adobe Flash Click-to-Run setting"
}
$cisMsEdgePreventSmartScreenBypass = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter"
    $keyName = "PreventOverrideAppRepUnknown"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.48.11"
    $cisControlName = "Prevent bypassing Windows Defender SmartScreen prompts for files"
}
$cisMsEdgePreventCertificateOverrides = @{
    $keyPath = "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Internet Setting"
    $keyName = "PreventCertErrorOverrides"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.48.12"
    $cisControlName = "Prevent certificate error overrides"
}

# CIS SECTION 18.9.62.2: Remote Desktop Connection Client
$cisRdpDenySavedPasswords = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
    $keyName = "DisablePasswordSaving"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.62.2.2"
    $cisControlName = "Do not allow passwords to be saved"
}
# CIS SECTION 18.9.62.3.3: Device & Resource Redirection
$cisRdpDenyDriveRedirection = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
    $keyName = "fDisableCdm"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.62.3.3.2"
    $cisControlName = "Do not allow drive redirection"
}
# CIS SECTION 18.9.62.3.9: Security
$cisRdpAlwaysRequirePassword = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
    $keyName = "fPromptForPassword"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.62.3.9"
    $cisControlName = "Always prompt for password upon connection"
}
$cisRdpRequireSecureRpc = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
    $keyName = "fEncryptRPCTraffic"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.62.3.9.2"
    $cisControlName = "Require secure RPC communication"
}
$cisRdpRequireSslSecurityLayer = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
    $keyName = "SecurityLayer"
    $keyValueCorrect = "2"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.62.3.9.3"
    $cisControlName = "Require use of specific security layer for remote (RDP) connections"
}
$cisRdpRequireUserAuthNla = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
    $keyName = "UserAuthentication"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.62.3.9.4"
    $cisControlName = "Require user authentication for remote connections by using Network Level Authentication"
}
$cisRdpClientEncryptionLevel = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
    $keyName = "MinEncryptionLevel"
    $keyValueCorrect = "3"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.62.3.9.5"
    $cisControlName = "Set client connection encryption level"
}
# CIS SECTION 18.9.62.3.11: Temporary Folders
$cisRdpAlwaysDeleteTempFolders = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
    $keyName = "DeleteTempDirsOnExit"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.62.3.1"
    $cisControlName = "Do not delete temp folders upon exit"
}
# CIS SECTION 18.9.63: RSS FEEDS
$cisRssPreventEnclosureDownload = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds"
    $keyName = "DisableEnclosureDownload"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.63.1"
    $cisControlName = "Prevent downloading of enclosures"
}
# CIS SECTION 18.9.64.1: Windows Search
$cisOcrAllowCortana = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    $keyName = "AllowCortana"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.64.3"
    $cisControlName = "Allow Cortana"
}
$cisOcrAllowCortanaLockScreen = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    $keyName = "AllowCortanaAboveLock"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.64.4"
    $cisControlName = "Allow Cortana above lock screen"
}
$cisOcrIndexEncryptedFiles = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    $keyName = "AllowIndexingEncryptedStoresOrItems"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.64.5"
    $cisControlName = "Allow indexing of encrypted files"
}
$cisOcrAllowCortanaLocation = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    $keyName = "AllowSearchToUseLocation"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.64.6"
    $cisControlName = "Allow search and Cortana to use location"
}
# CIS SECTION 18.9.72: Windows Store
$cisStorePrivateOnly = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
    $keyName = "RequirePrivateStoreOnly"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.72.2"
    $cisControlName = "Only display the private store within the Microsoft Store"
}
$cisStoreForceAutoUpdate = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
    $keyName = "AutoDownload"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.72.3"
    $cisControlName = "Turn off Automatic Download and Install of updates"
}
$cisStoreWindowsUpdatePrompt = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
    $keyName = "DisableOSUpgrade"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.72.4"
    $cisControlName = "Turn off the offer to update to the latest version of Windows"
}
# CIS SECTION 18.9.80: WINDOWS DEFENDER
# CIS SECTION 18.9.80.1: Explorer
$cisExplorerDefenderSmartScreen1 = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    $keyName = "EnableSmartScreen"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.80.1.1"
    $cisControlName = "Configure Windows Defender SmartScreen"
}
$cisExplorerDefenderSmartScreen2 = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    $keyName = "ShellSmartScreenLevel"
    $keyValueCorrect = "Block"
    $keyType = "REG_SZ"
    $cisControlNumber = "18.9.80.1.1"
    $cisControlName = "Configure Windows Defender SmartScreen"
}
# CIS SECTION 18.9.80.2: Microsoft Edge 
$cisEdgeConfigureSmartScreen = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter"
    $keyName = "EnabledV9"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.80.2.1"
    $cisControlName = "Configure Windows Defender SmartScreen"
}
$cisEdgePreventSmartScreenBypass = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter"
    $keyName = "PreventOverride"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "1"
    $cisControlName = "Prevent bypassing Windows Defender SmartScreen prompts for sites"
}
# CIS SECTION 18.9.82: Windows Game Recording & Broadcasting
$cisGameDisableRecording = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
    $keyName = "AllowGameDVR"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.82.1"
    $cisControlName = "Enables or disables Windows Game Recording and Broadcasting"
}
# CIS SECTION 18.9.84: Windows Ink Workspace
$cisWIWDisallowLockAccess = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace"
    $keyName = "AllowWindowsInkWorkspace"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.84.2"
    $cisControlName = "Allow Windows Ink Workspace"
}
# CIS SECTION 18.9.85: Windows Installer
$cisInstallerUserControl = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer"
    $keyName = "EnabledUserControl"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.85.1"
    $cisControlName = "Allow user control over installs"
}
$cisInstallElevatedPriv = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer"
    $keyName = "AlwaysInstallElevated"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.85.2"
    $cisControlName = "Always install with elevated privileges"
}
# CIS SECTION 18.9.86: Windows Logon Options
$cisWinLogonRestartInteractiveLock = @{
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $keyName = "DisableAutomaticRestartSignOn"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.86.1"
    $cisControlName = "Sign-in and lock last interactive user automatically after a restart"
}
# CIS SECTION 18.9.95: Windows PowerShell
$cisPsEnableScriptBlockLogging = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
    $keyName = "EnableScriptBlockLogging"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.95.1"
    $cisControlName = "Turn on PowerShell Script Block Logging"
}
$cisPsEnableTranscription = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription"
    $keyName = "EnableTranscripting"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.95.2"
    $cisControlName = "Turn on PowerShell Transcription"
}
# CIS SECTION 18.9.97: Windows Remote Management (WinRM)
# CIS SECTION 18.9.97.1: WinRM Client
$cisWinRmCliBasicAuth = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client"
    $keyName = "AllowBasic"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.97.1.1"
    $cisControlName = "Allow Basic authentication"
}
$cisWinRmCliUnencryptedTraffic = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client"
    $keyName = "AllowUnencryptedTraffic"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.97.1.2"
    $cisControlName = "Allow unencrypted traffic"
}
$cisWinRmCliDigestAuth = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client"
    $keyName = "AllowDigest"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = ""
    $cisControlName = "Disallow Digest authentication"
}
# CIS SECTION 18.8.87.2: WinRM Service
$cisWinRmSrvBasicAuth = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service"
    $keyName = "AllowBasic"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.8.87.2.1"
    $cisControlName = "Allow Basic authentication"
}
$cisWinRmSrvUnencryptedTraffic = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service"
    $keyName = "AllowUnencryptedTraffic"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.97.2.3"
    $cisControlName = "Allow unencrypted traffic"
}
$cisWinRmSrvRunAsCredentialStorage = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service"
    $keyName = "DisableRunAs"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.9"
    $cisControlName = "Disallow WinRM from storing RunAs credentials"
}
# CIS SECTION 18.9.99: Windows Security
# CIS SECTION 18.9.99.2: App & Browser Protection
$cisSecCenterPreventUserModification = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protection"
    $keyName = "DisallowExploitProtectionOverride"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.99.2.1"
    $cisControlName = "Prevent users from modifying settings"
}
# CIS SECTION 18.9.102: Windows Update
# CIS SECTION 18.9.102.1: Windows Update for Business
$cisWuWufbDeferUpdates1 = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $keyName = "ManagePreviewBuilds"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.102.1.1"
    $cisControlName = "Manage preview builds"
}
$cisWuWufbDeferUpdates2 = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $keyName = "ManagePreviewBuildsPolicyValue"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.102.1.1"
    $cisControlName = "Manage preview builds"
}
$cisWuWufbPreviewBuilds1801 = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $keyName = "DeferFeatureUpdates"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.102.1.2"
    $cisControlName = "Select when Preview Builds and Feature Updates are received"
}
$cisWuWufbPreviewBuilds1802 = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $keyName = "BranchReadinessLevel"
    $keyValueCorrect = "16"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.102.1.2"
    $cisControlName = "Select when Preview Builds and Feature Updates are received"
}
$cisWuWufbPreviewBuilds1803 = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $keyName = "DeferFeatureUpdatesPeriodInDays"
    $keyValueCorrect = "180"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.102.1.2"
    $cisControlName = "Select when Preview Builds and Feature Updates are received"
}
$cisWuWufbQualityUpdateSchedule1 = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $keyName = "DeferQualityUpdates"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.102.1.3"
    $cisControlName = "Select when Quality Updates are received"
}
$cisWuWufbQualityUpdateSchedule2 = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $keyName = "DeferQualityUpdatesPeriodInDays"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.102.1.3"
    $cisControlName = "Select when Quality Updates are received"
}
$cisWuWufbConfigureUpdates = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    $keyName = "NoAutoUpdate"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.102.2"
    $cisControlName = "Configure Automatic Updates"
}
$cisWuWufbConfigureUpdatesSchedule = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    $keyName = "ScheduledInstallDay"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.102.3"
    $cisControlName = "Configure Automatic Updates: Scheduled install day"
}
$cisWuWufbAutoRestartWithLoggedOn = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    $keyName = "NoAutoRebootWithLoggedOnUsers"
    $keyValueCorrect = "0"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.102.4"
    $cisControlName = "No auto-restart with logged on users for scheduled automatic updates installations"
}
$cisWuWufbRemovePauseUpdatesFeature = @{
    $keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $keyName = "SetDisablePauseUXAccess"
    $keyValueCorrect = "1"
    $keyType = "DWORD"
    $cisControlNumber = "18.9.102.5"
    $cisControlName = "Remove access to Pause Updates feature"
}










#
# DECLARE VARIABLES
#

# If log file parameter is not specified, use a default value
if ($null -eq $global:logFile -OR !($global:logFile)){
    [STRING]$global:logFileName = "Windows10SetupScript-" + (Get-Date).ToString().Replace(" ","").Replace("/","").Replace("\","").Replace(":","") + ".log"
    [STRING]$global:logFilePath = Join-Path -Path $env:SystemDrive -ChildPath "\Windows\Temp\CompanyName"
    [STRING]$global:logFile = Join-Path -Path $global:logFilePath -ChildPath $global:logFileName
}

$generalOutputFolder = Split-Path $global:logFile
$global:stepNumber = 0


# Turn on script block logging
Enable-PowershellScriptBlockLogging
Enable-PowershellModuleLogging


#
# MAIN SCRIPT
#

# TODO: ADD WRAPPER: IS WINDOWS 10 WORKSTATION? NO, QUIT. YES, CONTINUE.

# INITIALISE THE DULL BITS
Set-ConsoleWindowSize
Set-DisplayHeader

# BACKUP THE REGISTRY

# CREATE A RESTORE POINT
Checkpoint-Computer -Description "Pre Setup Script"
Export-RegistryBackup


# START PROCESSING EVERYTHING
# DO SECURITY & CORE FIRST
Enable-UacHigh
Enable-WindowsFirewall
Enable-DotNetStrongCrypto
Enable-MeltdownCompatFlag
Enable-DepOptIn
Disable-RemoteAssistance
Disable-AutoRestartSignOn
Disable-AutoPlay
Disable-AutoRun
Disable-MappedDriveSharing
Disable-WindowsScriptHost

# WINDOWS DEFENDER
Enable-WindowsDefender
Enable-WindowsDefenderCloud
Enable-ControlledFolderAccess
Enable-CoreIsolationMemoryIntegrity
Enable-DefenderAppGuard
Disable-AccountProtectionWarning

# PRIVACY
Disable-Telemetry
Disable-WifiSense
Enable-SmartScreen
Disable-Location
Disable-MapsUpdates
Disable-Feedback
Disable-TailoredExperiences
Disable-AdvertisingId
Disable-WebLangList
Disable-ErrorReporting
Disable-DiagTrack

# CORTANA
Disable-Cortana
Disable-StartWebSearch
Disable-AppSuggestions

# WINDOWS UPDATE
Set-WindowsUpdateP2PLocal
Enable-WindowsUpdateMaliciousRemovalTool
Enable-WindowsUpdateAllMicrosoftProducts
Disable-WindowsUpdateAutomaticRestart
Disable-WindowsUpdateMaintenanceWakeup
Disable-WindowsUpdateEdgeShortcutCreation


# THEN ANYTHING THAT'S ONLINE
if ($(Test-InternetConnectivity) -eq $True){
    # DO INTERNET THINGS HERE
    # MISC
    Set-CompanyBranding
    # APP INSTALLS
    Install-7Zip
    Install-GoogleChromeEnterprise
    Install-MozillaFirefoxESR
    Install-MicrosoftLAPS
    Install-DotNetVersions23
    Install-DellCommandUpdate
    Install-MicrosoftSecurityBaselines
    Install-Raccine
}


# POWER FIRST
# Needs check on desktop form here
Enable-UltimatePowerPlan
Disable-NicPowerSaving

# NETWORK
Set-CurrentNetworkPrivate
Disable-InternetConnectionSharing
Enable-NetworkDeviceAutoInstall

# APPS
Uninstall-PowershellV2
Uninstall-MathRecognizer
Uninstall-HyperV
Uninstall-OpenSshClient
Uninstall-OpenSshServer
Uninstall-OfficePreloaded
Disable-EdgePreload
Disable-AdobeFlash

# MISC
New-CompanyAssetName
Enable-WapPushService
Enable-SystemRestore
Enable-NtfsLongFilePaths
Enable-NtfsLastAccessTimeStamps
Enable-OsDriveShadowCopies
Disable-ModernUiSwapFile


# EXPERIENCE
Disable-SharedExperiences
Disable-ActionCenter
Disable-ShowNetworkOnLockScreen
Disable-ShowShutdownOnLockScreen
Disable-LockScreenBlur
Disable-TaskbarSearchBar
Disable-UnknownExtensionStoreAppSearch
Disable-AddShortcutToName
Disable-GameFullScreenOptimisations
Disable-InternetExplorerFirstRunWizard
Disable-FirstLogonAnimation
Disable-MediaSharing
Disable-TipsTricksNotifications
Enable-PhotoViewerFileAssociations
Enable-PhotoViewerOpenWith
Enable-TaskbarCombineWhenFull
Enable-ShowTaskManagerDetail
Enable-ShowFileOperationDetail
Enable-ClipboardHistory
Enable-StorageSense
Enable-NumLock
Enable-EnhancedPointerPrecision
Enable-VerboseStatusMessages
Set-ControlPanelUseSmallIcons
Set-InternetExplorerDefaultSearchEngineGoogle
Set-VisualEffectsForPerformance

# EXPLORER
Disable-Explorer3DObjects
Disable-Explorer3DObjectsThisPC
Disable-ExplorerThumbnailCache
Disable-ExplorerThumbnailNetworkCache
Enable-ExplorerEncryptedFileColour
Enable-ExplorerExpandedNavPane
Enable-ExplorerShowFolderMergeConflicts
Enable-ExplorerShowFullTitlePath
Enable-ExplorerShowHiddenFiles
Enable-ExplorerShowKnownExtensions
Set-ExplorerOpenThisPC

# SOUND
Disable-StartupSound
Set-ActiveSchemeNoSounds

# THEN CIS

# CIS SECTION 2.2: Accounts
Set-CisRegistryFunction @cisAccountsBlockMicrosoft

# CIS SECTION 2.3.1: Audit
Set-CisRegistryFunction @cisAuditPolicySubcategory
Set-CisRegistryFunction @cisAuditShutdownBehaviour

# CIS SECTION 2.3.4: Devices
Set-CisRegistryFunction @cisDevicesFormatRMedia

# CIS SECTION 2.3.6: Domain Member
Set-CisRegistryFunction @cisDomMemSecureChannelAlways
Set-CisRegistryFunction @cisDomMemEncryptSecureChannelAlways
Set-CisRegistryFunction @cisDomMemSignSecureChannelPossible
Set-CisRegistryFunction @cisDomMemDisableMachinePassChange
Set-CisRegistryFunction @cisDomMemRequireStrongSessionKey

# CIS SECTION 2.3.7: Interactive Logo
Set-CisRegistryFunction @cisIntLogonDisableCAD
Set-CisRegistryFunction @cisIntLogonDisplayLastSignIn
Set-CisRegistryFunction @cisIntLogonMachineInactivityLimit
Set-CisRegistryFunction @cisIntLogonUserPasswordPrompt
Set-CisRegistryFunction @cisIntLogonSmartCardRemoval

# CIS SECTION 2.3.8: Microsoft Network Client
Set-CisRegistryFunction @cisNetCliDigitallySignAlways
Set-CisRegistryFunction @cisNetCliDigitallySignServerAgrees
Set-CisRegistryFunction @cisNetCliUnencryptedSmb

# CIS SECTION 2.3.9: Microsoft Network Server
Set-CisRegistryFunction @cisNetSrvIdleSuspend
Set-CisRegistryFunction @cisNetSrvDigitallySignAlways
Set-CisRegistryFunction @cisNetSrvDigitallySignClient
Set-CisRegistryFunction @cisNetSrvDisconnectLogonHours
Set-CisRegistryFunction @cisNetSrvSPNValidationLevel

# CIS SECTION 2.3.10: Network Access
Set-CisRegistryFunction @cisNetAccAnonymousSAMEnumeration
Set-CisRegistryFunction @cisNetAccAnonymousSAMShares
Set-CisRegistryFunction @cisNetAccCredentialStorage
Set-CisRegistryFunction @cisNetAccEveryoneToAnonymous
Set-CisRegistryFunction @cisNetAccAnonymousNamedPipes
Set-CisRegistryFunction @cisNetAccRemoteRegistryPaths
Set-CisRegistryFunction @cisNetAccRemoteRegistrySubPaths
Set-CisRegistryFunction @cisNetAccAnonymousPipeShareAccess
Set-CisRegistryFunction @cisNetAccClientRemoteSAMCalls
Set-CisRegistryFunction @cisNetAccAnonymousShares
Set-CisRegistryFunction @cisNetAccLocalAccSecModel

# CIS SECTION 2.3.11: Network Security
Set-CisRegistryFunction @cisNetSecCompIdentity
Set-CisRegistryFunction @cisNetSecNullFallback
Set-CisRegistryFunction @cisNetSecPKU2UOnlineIdentities
Set-CisRegistryFunction @cisNetSecKerberosEncryptionTypes
Set-CisRegistryFunction @cisNetSecLMHashStorage
Set-CisRegistryFunction @cisNetSecLMAuthLevel
Set-CisRegistryFunction @cisNetSecLDAPClientSignReq
Set-CisRegistryFunction @cisNetSecNtlmSspMinSec
Set-CisRegistryFunction @cisNetSecNtlmSspMinSecRPC

# CIS SECTION 2.3.15: System Objects
Set-CisRegistryFunction @cisSysObjWinSubSys
Set-CisRegistryFunction @cisSysObjIntObjStrength

# CIS SECTION 2.3.17: User Account Control
Set-CisRegistryFunction @cisUacAdminApprovalMode
Set-CisRegistryFunction @cisUacAdminApprovalElevationBehaviour
Set-CisRegistryFunction @cisUacStdUserElevationPrompt
Set-CisRegistryFunction @cisUacAppElevationPrompt
Set-CisRegistryFunction @cisUacElevateSecureOnly
Set-CisRegistryFunction @cisUacAdminsInApprovalMode
Set-CisRegistryFunction @cisUacElevateOnSecureDesktop
Set-CisRegistryFunction @cisUacVirtualiseWriteFailures

# CIS SECTION 5: System Services
Set-CisServiceDisabled @cisServiceComputerBrowser
Set-CisServiceDisabled @cisServiceIisAdmin
Set-CisServiceDisabled @cisServiceIRMon
Set-CisServiceDisabled @cisServiceIcs
Set-CisServiceDisabled @cisServiceLxssManager
Set-CisServiceDisabled @cisServiceFtpSvc
Set-CisServiceDisabled @cisServiceSshd
Set-CisServiceDisabled @cisServiceRpcLocator
Set-CisServiceDisabled @cisServiceRemoteAccess
Set-CisServiceDisabled @cisServiceSimpTcp
Set-CisServiceDisabled @cisServiceSacSvr
Set-CisServiceDisabled @cisServiceSsdpSrv
Set-CisServiceDisabled @cisServiceUpnpHost
Set-CisServiceDisabled @cisServiceWMSvc
Set-CisServiceDisabled @cisServiceWMPNetworkSvc
Set-CisServiceDisabled @cisServiceIcssSvc
Set-CisServiceDisabled @cisServiceW3svc
Set-CisServiceDisabled @cisServiceXboxGipSvc
Set-CisServiceDisabled @cisServiceXblAuthManager
Set-CisServiceDisabled @cisServiceXblGameSave
Set-CisServiceDisabled @cisServiceXboxNetApiSvc

# CIS SECTION 9: Windows Firewall
# CIS SECTION 9.1: Domain Profile
Set-CisRegistryFunction @cisFwDomSetOn
Set-CisRegistryFunction @cisFwDomDefaultInbound
Set-CisRegistryFunction @cisFwDomDefaultOutbound
Set-CisRegistryFunction @cisFwDomDisableNotifications
Set-CisRegistryFunction @cisFwDomLogFilePath
Set-CisRegistryFunction @cisFwDomLogFileSize
Set-CisRegistryFunction @cisFwDomLogDroppedPackets
Set-CisRegistryFunction @cisFwDomLogSuccessfulConnections


# CIS SECTION 9.2: Private Profile
Set-CisRegistryFunction @cisFwPriSetOn
Set-CisRegistryFunction @cisFwPriDefaultInbound
Set-CisRegistryFunction @cisFwPriDefaultOutbound
Set-CisRegistryFunction @cisFwPriDisableNotifications
Set-CisRegistryFunction @cisFwPriLogFilePath
Set-CisRegistryFunction @cisFwPriLogFileSize
Set-CisRegistryFunction @cisFwPriLogDroppedPackets
Set-CisRegistryFunction @cisFwPriLogSuccessfulConnections

# CIS SECTION 9.3: Public Profile
Set-CisRegistryFunction @cisFwPubSetOn
Set-CisRegistryFunction @cisFwPubDefaultInbound
Set-CisRegistryFunction @cisFwPubDefaultOutbound
Set-CisRegistryFunction @cisFwPubDisableNotifications
Set-CisRegistryFunction @cisFwPubApplyLocalRules
Set-CisRegistryFunction @cisFwPubApplyLocalIPSecRules
Set-CisRegistryFunction @cisFwPubLogFilePath
Set-CisRegistryFunction @cisFwPubLogFileSize
Set-CisRegistryFunction @cisFwPubLogDroppedPackets
Set-CisRegistryFunction @cisFwPubLogSuccessfulConnections

# CIS SECTION 17: Audit Policy
# CIS SECTION 17.1: Account Logon
Set-CisAuditPolicy @cisAuditPolCredentialValidation

# CIS SECTION 17.2: Account Management
Set-CisAuditPolicy @cisAuditPolAppGroupManagement
Set-CisAuditPolicy @cisAuditPolSecGroupManagement
Set-CisAuditPolicy @cisAuditPolUserAccManagement

# CIS SECTION 17.3: Detailed Tracking
Set-CisAuditPolicy @cisAuditPolPnpActivity
Set-CisAuditPolicy @cisAuditPolProcessCreation

# CIS SECTION 17.4: Logon/Logoff
Set-CisAuditPolicy @cisAuditPolAccountLockout
Set-CisAuditPolicy @cisAuditPolGroupMembership
Set-CisAuditPolicy @cisAuditPolLogoff
Set-CisAuditPolicy @cisAuditPolLogon
Set-CisAuditPolicy @cisAuditPolOtherLogonEvents
Set-CisAuditPolicy @cisAuditPolSpecialLogon

# CIS SECTION 17.6: Object Access
Set-CisAuditPolicy @cisAuditPolDetailedFileShare
Set-CisAuditPolicy @cisAuditPolFileShare
Set-CisAuditPolicy @cisAuditPolOtherObjectEvents
Set-CisAuditPolicy @cisAuditPolRemoveableStorage

# CIS SECTION 17.7: Policy Change
Set-CisAuditPolicy @cisAuditPolPolicyChange
Set-CisAuditPolicy @cisAuditPolAuthenticationPolicyChange
Set-CisAuditPolicy @cisAuditPolAuthorizationPolicyChange
Set-CisAuditPolicy @cisAuditPolMpssvcChange
Set-CisAuditPolicy @cisAuditPolOtherPolicyChange

# CIS SECTION 17.8: Privilege Use
Set-CisAuditPolicy @cisAuditPolSensitivePriv

# CIS SECTION 17.9: System
Set-CisAuditPolicy @cisAuditPolIpsecDriver
Set-CisAuditPolicy @cisAuditPolOtherSystemEvents
Set-CisAuditPolicy @cisAuditPolSecStateChange
Set-CisAuditPolicy @cisAuditPolSecSystemExtension
Set-CisAuditPolicy @cisAuditPolSystemIntegrity

# CIS SECTION 18.1: Control Panel
Set-CisRegistryFunction @cisPreventLockScreenCamera
Set-CisRegistryFunction @cisPreventLockScreenSlideshow
Set-CisRegistryFunction @cisDenyOnlineSpeechServices

# CIS SECTION 18.2: LAPS
Set-CisRegistryFunction @cisLapsEnableLaps
Set-CisRegistryFunction @cisLapsLimitPasswordExpiryTime
Set-CisRegistryFunction @cisLapsPasswordComplexity
Set-CisRegistryFunction @cisLapsPasswordLength
Set-CisRegistryFunction @cisLapsPasswordAge

# CIS SECTION 18.3: MSG
Set-CisRegistryFunction @cisMsgUacToLocalOnNetwork
Set-CisRegistryFunction @cisMsgNetbtNodeType
Set-CisRegistryFunction @cisMsgWDigestAuth
Set-CisRegistryFunction @cisMsgConfigureSmbV1Driver
Set-CisRegistryFunction @cisMsgConfigureSmbV1
Set-CisRegistryFunction @cisMsgSehop

# CIS SECTION 18.4: MSS
Set-CisRegistryFunction @cisMssAutoLoginDisabled
Set-CisRegistryFunction @cisMssClearDefaultPassword
Set-CisREgistryFunction @cisMssIPv6SourceRouting
Set-CisRegistryFunction @cisMssIpSourceRouting
Set-CisRegistryFunction @cisMssIcmpRedirect
Set-CisRegistryFunction @cisMssIgnoreNetbiosRequests
Set-CisREgistryFunction @cisMssSafeDllSearchMode
Set-CisRegistryFunction @cisMssScreenSaverGracePeriod

Set-CisRegistryFunction @cisSecurityEventLogAlertLevel

Set-CisRegistryFunction @cisDnsCliMulticast

Set-CisRegistryFunction @cisLanmanInsecureLogons

Set-CisRegistryFunction @cisDefProhibitDnsBridge
Set-CisRegistryFunction @cisDefProhibitIcs
Set-CisRegistryFunction @cisDefElevateWhenChangeLocation

Set-CisRegistryFunction @cisNetProvHardenedUncPathsEnabled1
Set-CisRegistryFunction @cisNetProvHardenedUncPathsEnabled2

Set-CisRegistryFunction @cisWinConMgrMinimizeConnections
Set-CisRegistryFunction @cisWinConMgrProhibitNonDomain

Set-CisRegistryFunction @cisWlanDisableAutoHotspotConnect

Set-CisRegistryFunction @cisAuditProcCreation


# CIS SECTION 18.8.4: Credential Delegation
Set-CisRegistryFunction @cisCredDelegEncryptionOracle
Set-CisRegistryFunction @cisCredDelegNonExportableCredentials

# CIS SECTION 18.8.5: Device Guard
Set-CisRegistryFunction @cisDevGuardSecBoot
Set-CisRegistryFunction @cisDevGuardPlatformSecurity
Set-CisRegistryFunction @cisDevGuardVirtCodeIntegrity
Set-CisRegistryFunction @cisDevGuardUefiMemAttributes
Set-CisRegistryFunction @cisDevGuardCredGuardConfig
Set-CisRegistryFunction @cisDevGuardSecureLaunch

# CIS SECTION 18.8.14: Early Launch Antimalware
Set-CisRegistryFunction @cisELABootStartDriver

# CIS SECTION 18.8.21.1: Logging & Tracking
Set-CisRegistryFunction @cisLoggingConfigRegistryPolicyProcessing
Set-CisRegistryFunction @cisLoggingRegPolAlwayProcess
Set-CisRegistryFunction @cisLoggingContinueExperiences
Set-CisRegistryFunction @cisLoggingDisableBackgroundGpoRefresh

# CIS SECTION 18.8.22: Internet Connection Settings
Set-CisRegistryFunction @cisICSDisableHttpPrintDriverDownload
Set-CisRegistryFunction @cisICSDisableInternetDownload

# CIS SECTION 18.8.28: Logon
Set-CisRegistryFunction @cisLogonBlockAccountDetailDisplay
Set-CisRegistryFunction @cisLogonNetworkSelectionUi
Set-CisRegistryFunction @cisLogonPreventEnumerateConnectedUsers
Set-CisRegistryFunction @cisLogonEnumerateLocalUsers
Set-CisRegistryFunction @cisLogonLockScreenAppNotifications
Set-CisRegistryFunction @cisLogonDisablePicturePassword
Set-CisRegistryFunction @cisLogonDisablePin


# CIS SECTION 18.8.34.6: Sleep Settings
Set-CisRegistryFunction @cisSleepBatteryNetConnectivity
Set-CisRegistryFunction @cisSleepACNetConnectivity
Set-CisRegistryFunction @cisSleepBatteryRequirePassword
Set-CisRegistryFunction @cisSleepAcRequirePassword

# CIS SECTION 18.8.36: Remote Assistance
Set-CisRegistryFunction @cisRemoteAssistanceConfigure
Set-CisRegistryFunction @cisRemoteAssistanceConfigureSolicited

# CIS SECTION 18.8.37: Remote Procedure Call
Set-CisRegistryFunction @cisRpcEndpointMapperAuth
Set-CisRegistryFunction @cisRpcRestrictUnauthClients

# CIS SECTION 18.9.4: App Package Deployment
Set-CisRegistryFunction @cisAppDepPreventNonAdminInstall

# CIS SECTION 18.9.5: App Privacy
Set-CisRegistryFunction @cisAppPrivacyLockVoiceActivation

# CIS SECTION 18.9.6: App Runtime
Set-CisRegistryFunction @cisAppRunOptionalMsAccounts

# CIS SECTION 18.9.8: Autoplay Policies
Set-CisRegistryFunction @cisDisableAutoplayNonVolume
Set-CisRegistryFunction @cisAutorunDefaultBehaviour
Set-CisRegistryFunction @cisDisableAutoplay

# CIS SECTION 18.9.10: Biometrics
Set-CisRegistryFunction @cisBiometricsAntiSpoofing

# CIS SECTION 18.9.13: Cloud Content (requires Enterprise OS licence)
Set-CisRegistryFunction @cisDisableConsumerExperiences

# CIS SECTION 18.9.4: Connect
Set-CisRegistryFunction @cisConnectRequirePinPair

# CIS SECTION 18.9.15: Credential User Interfaces
Set-CisRegistryFunction @cisCUIHidePasswordReveal
Set-CisRegistryFunction @cisCUIEnumerateAdminsOnElevation
Set-CisRegistryFunction @cisCUIPreventSecurityQuestions

# CIS SECTION 18.9.16: Data Collection & Preview Builds
Set-CisRegistryFunction @cisDataCollAllowTelemetryBasic
Set-CisRegistryFunction @cisDataCollHideFeedbackNotifications
Set-CisRegistryFunction @cisDataCollInsiderBuildsControl

# CIS SECTION 18.9.17: Delivery Optimization
Set-CisRegistryFunction @cisDelOptDownloadMode
#
#
# NEEDS VALUES
#
#

# CIS SECTION 18.9.26
# CIS SECTION 18.9.26.1: Application
Set-CisRegistryFunction @cisEvLogAppReachMaxSize
Set-CisRegistryFunction @cisEvLogAppMaxSize

# CIS SECTION 18.9.26.2: Security
Set-CisRegistryFunction @cisEvLogSecReachMaxSize
Set-CisRegistryFunction @cisEvLogSecMaxSize

# CIS SECTION 18.9.26.3: Setup
Set-CisRegistryFunction @cisEvLogSetReachMaxSize
Set-CisRegistryFunction @cisEvLogSetMaxSize

# CIS SECTION 18.9.26.4: System
Set-CisRegistryFunction @cisEvLogSysReachMaxSize
Set-CisRegistryFunction @cisEvLogSysMaxSize

# CIS SECTION 18.9.30.1: Previous Versions
Set-CisRegistryFunction @cisPreVerDisableDep
Set-CisRegistryFunction @cisPreVerDisableHeapTermination
Set-CisRegistryFunction @cisPreVerDisableShellProtectedMode

# CIS SECTION 18.9.35: HomeGroup
Set-CisRegistryFunction @cisHomeGroupDenyJoin

# CIS SECTION 18.9.44: Microsoft Account
Set-CisRegistryFunction @cisMsAccBlockConsumerAuth

# CIS SECTION 18.9.45: Microsoft Defender Antivirus
# CIS SECTION 18.9.45.3: MAPS
Set-CisRegistryFunction @cisDefMapsConfigureLocalOverride

# CIS SECTION 18.9.45.4: Defender Exploit Guard
Set-CisRegistryFunction @cisDefDegConfigureAsr
Set-CisRegistryFunction @cisDefAsrBlockOfficeCommsChildProcesses
Set-CisRegistryFunction @cisDefAsrBlockOfficeCreateExecutables
Set-CisRegistryFunction @cisDefAsrBlockObfuscatedScripts
Set-CisRegistryFunction @cisDefAsrBlockOfficeCodeInjection
Set-CisRegistryFunction @cisDefAsrBlockAdobeReaderChildProcesses
Set-CisRegistryFunction @cisDefAsrBlockOfficeMacroWin32ApiCalls
Set-CisRegistryFunction @cisDefAsrBlockLsassCredentialTheft
Set-CisRegistryFunction @cisDefAsrBlockUntrustedUsbProcesses
Set-CisRegistryFunction @cisDefAsrBlockEmailExecutables
Set-CisRegistryFunction @cisDefAsrBlockJavaVBScriptDownloads
Set-CisRegistryFunction @cisDefAsrBlockOfficeChildProcesses

# CIS SECTION 18.9.45.4.3: Network Protection
Set-CisRegistryFunction @cisDefNetPreventDangerousWebsites

# CIS SECTION 18.9.45.5.8: Real-Time Protection
Set-CisRegistryFunction @cisDefRtEnableBehaviourMonitor

# CIS SECTION 18.9.45.11: Scan
Set-CisRegistryFunction @cisDefScanRemoveableDrive
Set-CisRegistryFunction @cisDefScanEmail

# CIS SECTION 18.9.45.13: Threats
Set-CisRegistryFunction @cisDefThreatsPua
Set-CisRegistryFunction @cisDefDisableDefender

# CIS SECTION 18.9.46: Microsoft Defender Application Guard
Set-CisRegistryFunction @cisDefAGAuditApplicationGuard
Set-CisRegistryFunction @cisDefAGAllowCameraMic
Set-CisRegistryFunction @cisDefAGAllowDAGFileDownload
Set-CisRegistryFunction @cisDefAGClipboardBehaviour
Set-CisRegistryFunction @cisDefAGManagedMode
Set-CisRegistryFunction @cisDefAGAllowDataPersistence

# CIS SECTION 18.9.48: Microsoft Edge
Set-CisRegistryFunction @cisMsEdgeAllowExtensionSideloading
Set-CisRegistryFunction @cisMsEdgeConfigureCookies
Set-CisRegistryFunction @cisMsEdgeConfigurePasswordManager
Set-CisRegistryFunction @cisMsEdgeConfigureFlashClickToRun
Set-CisRegistryFunction @cisMsEdgePreventSmartScreenBypass
Set-CisRegistryFunction @cisMsEdgePreventCertificateOverrides

# CIS SECTION 18.9.62.2: Remote Desktop Connection Client
Set-CisRegistryFunction @cisRdpDenySavedPasswords

# CIS SECTION 18.9.62.3.3: Device & Resource Redirection
Set-CisRegistryFunction @cisRdpDenyDriveRedirection

# CIS SECTION 18.9.62.3.9: Security
Set-CisRegistryFunction @cisRdpAlwaysRequirePassword
Set-CisRegistryFunction @cisRdpRequireSecureRpc
Set-CisRegistryFunction @cisRdpRequireSslSecurityLayer
Set-CisRegistryFunction @cisRdpRequireUserAuthNla
Set-CisRegistryFunction @cisRdpClientEncryptionLevel
Set-CisRegistryFunction @cisRdpAlwaysDeleteTempFolders

# CIS SECTION 18.9.63: RSS Feeds
Set-CisRegistryFunction @cisRssPreventEnclosureDownload

# CIS SECTION 18.9.64.1: Windows Search
Set-CisRegistryFunction @cisOcrAllowCortana
Set-CisRegistryFunction @cisOcrAllowCortanaLockScreen
Set-CisRegistryFunction @cisOcrIndexEncryptedFiles
Set-CisRegistryFunction @cisOcrAllowCortanaLocation

# CIS SECTION 18.9.72: Windows Store
Set-CisRegistryFunction @cisStorePrivateOnly
Set-CisRegistryFunction @cisStoreForceAutoUpdate
Set-CisRegistryFunction @cisStoreWindowsUpdatePrompt

# CIS SECTION 18.9.80: Windows Defender
# CIS SECTION 18.9.80.1: Explorer
Set-CisRegistryFunction @cisExplorerDefenderSmartScreen1
Set-CisRegistryFunction @cisExplorerDefenderSmartScreen2

# CIS SECTION 18.9.80.2: Microsoft Edge
Set-CisRegistryFunction @cisEdgeConfigureSmartScreen
Set-CisRegistryFunction @cisEdgePreventSmartScreenBypass

# CIS SECTION 18.9.82: Windows Game Recording & Broadcasting
Set-CisRegistryFunction @cisGameDisableRecording

# CIS SECTION 18.9.84: Windows Ink Workspace
Set-CisRegistryFunction @cisWIWDisallowLockAccess

# CIS SECTION 18.9.85: Windows Installer
Set-CisRegistryFunction @cisInstallerUserControl
Set-CisRegistryFunction @cisInstallElevatedPriv

# CIS SECTION 18.9.86: Windows Logon Options
Set-CisRegistryFunction @cisWinLogonRestartInteractiveLock

# CIS SECTION 18.9.95: Windows Powershell
Set-CisRegistryFunction @cisPsEnableScriptBlockLogging
Set-CisRegistryFunction @cisPsEnableTranscription

# CIS SECTION 18.9.97: Windows Remote Management
# CIS SECTION 18.9.97.1: WinRM Client
Set-CisRegistryFunction @cisWinRmCliBasicAuth
Set-CisRegistryFunction @cisWinRmCliUnencryptedTraffic
Set-CisRegistryFunction @cisWinRmCliDigestAuth

# CIS SECTION 18.9.97.2: WinRM Service
Set-CisRegistryFunction @cisWinRmSrvBasicAuth
Set-CisRegistryFunction @cisWinRmSrvUnencryptedTraffic
Set-CisRegistryFunction @cisWinRmSrvRunAsCredentialStorage

# CIS SECTION 18.9.99: Windows Security
# CIS SECTION 18.9.99.2: App & Browser Protection
Set-CisRegistryFunction @cisSecCenterPreventUserModification

# CIS SECTION 18.9.102: Windows Updates
# CIS SECTION 18.9.102.1: Windows Update for Business
Set-CisRegistryFunction @cisWuWufbDeferUpdates1
Set-CisRegistryFunction @cisWuWufbDeferUpdates2
Set-CisRegistryFunction @cisWuWufbPreviewBuilds1801
Set-CisRegistryFunction @cisWuWufbPreviewBuilds1802
Set-CisRegistryFunction @cisWuWufbPreviewBuilds1803
Set-CisRegistryFunction @cisWuWufbQualityUpdateSchedule1
Set-CisRegistryFunction @cisWuWufbQualityUpdateSchedule2
Set-CisRegistryFunction @cisWuWufbConfigureUpdates
Set-CisRegistryFunction @cisWuWufbConfigureUpdatesSchedule
Set-CisRegistryFunction @cisWuWufbAutoRestartWithLoggedOn
Set-CisRegistryFunction @cisWuWufbRemovePauseUpdatesFeature

# POWERSHELL
Set-PowerShellRemoteSigned

# PRINT THE ENDING

# INSTALL UPDATES
Install-DellDriverFirmwareUpdates
Install-WindowsUpdates

# DEBLOAT
Remove-PeopleIcon
Disable-ScheduledTasks
Remove-StartMenuPinnedTiles
Remove-AppxBloat
Repair-AppxDebloat
Invoke-PreventAppxBloatBoomerang
Remove-RegistryBloat
Invoke-CleanEventLogs
Invoke-MakeItSparkle

# CLEANUP TIME
Remove-Variables

# CREATE A RESTORE POINT
Checkpoint-Computer -Description "Post Setup Script"

# END WITH A RESTART
Reboot-ThisPc