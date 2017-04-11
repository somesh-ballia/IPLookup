# ---------------------------------------------------------------------------
# Author: Keith Hill
# Desc:   Variation of Jachym's chrome which I think works nice with Vista
# Date:   June 15, 2007
# Site:   http://pscx.codeplex.com
# Usage:  In your profile place the following command:
#  
#         $Pscx:Preferences['EyeCandyScript'] = "$($Pscx:Home)\Profile\EyeCandy.Jachym.ps1"
# ---------------------------------------------------------------------------

#
# Colors
#
$Pscx:Session['EyeCandy/PromptBackColor'] = $null
if($Pscx:IsAdmin) {
	$Pscx:Session['EyeCandy/ConsoleForeColor'] = 'White'
	$Pscx:Session['EyeCandy/ConsoleBackColor'] = 'DarkRed'
	$Pscx:Session['EyeCandy/PromptForeColor'] = 'Gray'
}
else {
	$Pscx:Session['EyeCandy/ConsoleForeColor'] = 'White'
	$Pscx:Session['EyeCandy/ConsoleBackColor'] = 'Black'
	$Pscx:Session['EyeCandy/PromptForeColor'] = 'Cyan'
}

#
# Host Window Title
#
$Pscx:Session['EyeCandy/HostTitlePreference'] = {
	$adminPrefix = ''
	if ($Pscx:IsAdmin) {
		$adminPrefix = 'Admin'
	}
	$location = Get-Location
	$version = 1
	if (Test-Path Variable:\PSVersionTable) {
		$version = $PSVersionTable.PSVersion.Major
	}
	
	$bitness = ''
	if ([IntPtr]::Size -eq 8) {
		$bitness = ' (x64)'
	}
	elseif ($Pscx:IsWow64Process) {
		$bitness = ' (x86)'
	}
	
	"$adminPrefix $location - Windows PowerShell V${version}$bitness"
}

#
# Prompt
#
$Pscx:Session['EyeCandy/PromptPreference'] = {
	param($Id) 
	
	if ($NestedPromptLevel) {
		new-object string ([char]0xB7), $NestedPromptLevel
	}
	
	$sepChar = '>' # [char]0xBB
	if ($Pscx:IsAdmin) {
        $sepChar = '#'
	}
	
	$path = ''
	if ($host.Name -eq 'Windows PowerShell ISE Host') {
		$path = " $(Get-Location)"
	}
	
	"${Id}$path$sepChar"
}

#
# Message of the Day
#
$Pscx:Session['EyeCandy/MotDayPreference'] = {

	if (($DebugPreference -eq 'SilentlyContinue') -and ($VerbosePreference -eq 'SilentlyContinue')) {
		Clear-Host
	}

	$MachineArchitecture = $(if([IntPtr]::Size -eq 8) { "64-bit" } else { "32-bit" })
	$PSVersionString     = (Get-Command "$PSHome\PowerShell.exe").FileVersionInfo.ProductVersion

	"Windows PowerShell $($host.Version), ProductVersion $PSVersionString ($MachineArchitecture)"
	"PowerShell Community Extensions $($Pscx:Version)"
	""
	
	$user =	"Logged in on $([DateTime]::Now.ToString((get-culture))) as $($Pscx:WindowsIdentity.Name)"
	
	if ($Pscx:IsAdmin) { 
		$user += ' (Elevated).' 
	}
	else { 
		$user += '.' 
	}
	
	$user
}
