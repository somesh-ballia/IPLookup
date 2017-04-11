#region ----------- Beginning of PSCX 1.2 Initialization --------------------

Add-PSSnapin Pscx

#region ----------- Preference Variables ------------------------------------
# The following preferences variables can be uncommented out to change their
# value before executing the PscxConfig.  Each preference is shown set to its
# default value.

#-- Default text editor for the 'e' alias
# $Pscx:Preferences['TextEditor'] = "Notepad.exe"

#-- Configure the use of less.exe for paging the output of the man and help aliases.
#-- Press 'q' key to exit less.exe and press the 'h' key for help on using less.exe.
# $Pscx:Preferences["PageHelpUsingLess"] = $true

#-- Dirx/dirs/dirt/dird/dirw functions will specify the value of the DirForce preference
#-- variable to the Get-ChildItem -Force parameter.  If set to $true, normally hidden 
#-- items to be displayed.  The extended dir functions will also filter out files with the
#-- system attribute set if the DirHideSystem preference variable is set to $true. 
#-- However performance may suffer on high latency networks or in folders with many files.
# $Pscx:Preferences['DirForce']      = $true
# $Pscx:Preferences['DirHideSystem'] = $false

#-- Display file sizes in KB, MB, GB multiples.
# $Pscx:Preferences['FileSizeInUnits'] = $false

#-- Specify if you want PSCX to update the output of 'dir' to show junctions and symlinks
# $Pscx:Preferences['UpdateFileSystemFormatData'] = $true

#-- The Send-SmtpMail default settings.
# $Pscx:Preferences['SmtpFrom'] = '<not set>'
# $Pscx:Preferences['SmtpHost'] = '<not set>'
# $Pscx:Preferences['SmtpPort'] = <not set> # Integer - cmdlet uses port 25 if variable not set

#-- You can modify the PSCX prompt appearance by creating your own eye-candy script.
# $Pscx:Preferences['EyeCandyScript'] = "$Pscx:ProfileDir\EyeCandy.Jachym.ps1"
# $Pscx:Preferences['EyeCandyScript'] = "$Pscx:ProfileDir\EyeCandy.WinXP.ps1" # (Default on XP/Windows Server 2003)
# $Pscx:Preferences['EyeCandy.WinXP/WindowTitlePrefix'] = "PoSh "
# $Pscx:Preferences['EyeCandyScript'] = "$Pscx:ProfileDir\EyeCandy.Vista.ps1" # (Default on Vista/Windows 7/Windows Server 2008)

#-- Specify if you want a Visual Studio environment configured
# $Pscx:Preferences["ImportVisualStudioVars"] = $false
#-- Specify which Visual Studio environments you prefer. The first available will be initalized.
# $Pscx:Preferences['VisualStudioSku'] = 'VisualStudio', 'VCSExpress', 'VWDExpress', 'VCExpress', 'VBExpress'
# $Pscx:Preferences['VisualStudioVersion'] = '9.0', '8.0'
# $Pscx:Preferences['MSBuildToolsVersion'] = '3.5', '2.0'

#-- Enable PSCX tab expansion.  PSCX tab expansion is known to crash on x64
# $Pscx:Preferences["EnablePscxTabExpansion"] = $false

#-- Enable dot source of various PSCX function libraries
# $Pscx:Preferences['DotSource/Cd.ps1']                 = $true  
# $Pscx:Preferences['DotSource/Dir.ps1']                = $true  
# $Pscx:Preferences['DotSource/Debug.ps1']              = $true  
# $Pscx:Preferences['DotSource/EyeCandy.ps1']           = $false  
# $Pscx:Preferences['DotSource/GenericFilters.ps1']     = $true  
# $Pscx:Preferences['DotSource/GenericFunctions.ps1']   = $true  
# $Pscx:Preferences['DotSource/PscxAliases.ps1']        = $true  
# $Pscx:Preferences['DotSource/RegexLib.ps1']           = $true  
# $Pscx:Preferences['DotSource/VirtualServerAlias.ps1'] = $true  
# $Pscx:Preferences['DotSource/TranscribeSession.ps1']  = $false

#endregion -------- End of Preference Variables -----------------------------

# ---------------------------------------------------------------------------
# Configure PSCX based on the settings above (or their defaults).
# ---------------------------------------------------------------------------
. "$Pscx:ProfileDir\PscxConfig.ps1"

#endregion -------- End of PSCX 1.2 Initialization --------------------------