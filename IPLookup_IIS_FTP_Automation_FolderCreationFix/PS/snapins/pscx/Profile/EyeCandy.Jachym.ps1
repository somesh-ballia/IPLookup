# ---------------------------------------------------------------------------
# Author: jachymko
# Desc:   Prompt function that displays current location and admin status in 
#		  the window title. The startup banner contains bitness of the current
#	      process and PSCX version information.
#
# Date:   Dec 23, 2006
# Site:   http://pscx.codeplex.com
# Usage:  In your profile place the following command:
#  
#         $Pscx:Preferences['EyeCandyScript'] = "$($Pscx:Home)\Profile\EyeCandy.Jachym.ps1"
# ---------------------------------------------------------------------------

# Display file size in units
$Pscx:Preferences['FileSizeInUnits'] = $true

#
# Colors
#
$Pscx:Session['EyeCandy/PromptBackColor'] = $null
if($Pscx:IsAdmin)
{
	$Pscx:Session['EyeCandy/ConsoleForeColor'] = 'White'
	$Pscx:Session['EyeCandy/ConsoleBackColor'] = 'DarkRed'
	$Pscx:Session['EyeCandy/PromptForeColor'] = 'Gray'
	$Pscx:Session['EyeCandy/RepeatPromptColor'] = 'DarkCyan'  
}
else
{
	$Pscx:Session['EyeCandy/ConsoleForeColor'] = 'White'
	$Pscx:Session['EyeCandy/ConsoleBackColor'] = 'Black'
	$Pscx:Session['EyeCandy/PromptForeColor'] = 'Yellow'
	$Pscx:Session['EyeCandy/RepeatPromptColor'] = 'DarkCyan'
}

#
# Host Window Title
#
$Pscx:Session['EyeCandy/HostTitlePreference'] = 
{
	if($Pscx:IsAdmin) { '(Admin)' }
	
	'Microsoft Windows PowerShell'
	'-'
	(Get-Location)
}

#
# Prompt
#
$Pscx:Session['EyeCandy/PromptPreference'] = 
{
	param($Id) 
	
	if($NestedPromptLevel) 
	{
		new-object string ([char]0xB7), $NestedPromptLevel
	}
	
	"[$Id] $([char]0xBB)"
}

#
# Message of the Day
#
$Pscx:Session['EyeCandy/MotDayPreference'] = 
{
	if($DebugPreference -eq 'SilentlyContinue') 
	{
		Clear-Host
	}

	$MachineArchitecture = $( if([IntPtr]::Size -eq 8) { "64-bit" } else { "32-bit" } )
	$PSVersionString     = (Get-FileVersionInfo "$PSHome\PowerShell.exe").ProductVersion
	$PscxVersionString   = $Pscx:Version.ToString(2)

	"PowerShell Community Extensions $PscxVersionString"
	"Microsoft Windows PowerShell $PSVersionString ($MachineArchitecture)"
	""
	
	$user =	"Logged in on $([DateTime]::Now.ToString((get-culture))) as $($Pscx:WindowsIdentity.Name)"
	
	if($Pscx:IsAdmin) { $user += ' (Elevated!)' }
	else { $user += '.' }
	
	$user
}
