# ---------------------------------------------------------------------------
# Author: Keith Hill
# Desc:   Prompt function that display full path on separate line from prompt.
#         It also displays history id, admin status as well as nesting level
#         for subshells.
# Date:   Nov 18, 2006
# Site:   http://pscx.codeplex.com
# Usage:  In your profile place the following command:
#  
#         $Pscx:Preferences['EyeCandyScript'] = "$($Pscx:Home)\Profile\EyeCandy.Keith.ps1"
# ---------------------------------------------------------------------------

# If you want to have a string always prefixed to the console
# window's title bar before the path, then set the session variable
# to the desired prefix.
$Pscx:Session['EyeCandy.WinXP/WindowTitlePrefix'] = $Pscx:Preferences['EyeCandy.WinXP/WindowTitlePrefix']

# Configure console colors.  $null signifies to use the console default color
if ($Pscx:IsAdmin -and ([System.Environment]::OSVersion.Version.Major -gt 5)) {
	$Pscx:Session['EyeCandy/PromptForeColor'] = 'Red'
}
else {
	$Pscx:Session['EyeCandy/PromptForeColor'] = $null
}
$Pscx:Session['EyeCandy/ConsoleForeColor'] = $null
$Pscx:Session['EyeCandy/ConsoleBackColor'] = $null
$Pscx:Session['EyeCandy/PromptBackColor'] = $null
$Pscx:Session['EyeCandy/RepeatPromptColor'] = $null
$Pscx:Session['EyeCandy/MotDayPreference'] = $null

$Pscx:Session['EyeCandy/HostTitlePreference'] = {
	# Pretty much everyone runs as admin on XP and below so displaying
	# the admin status in the title bar is a waste of space. Only do this
	# on Vista.
	$isVistaOrHigher = ([System.Environment]::OSVersion.Version.Major -gt 5)	

	$adminStatus = ''
	if ($Pscx:IsAdmin -and $isVistaOrHigher) { $adminStatus = 'Admin: ' }
	
	$titlePrefix = $Pscx:Session['EyeCandy.WinXP/WindowTitlePrefix']
	
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
	
	"$adminStatus$titlePrefix$location - Windows PowerShell V${version}$bitness"
}

$Pscx:Session['EyeCandy/PromptPreference'] = {
	param($nextCommandId) 
	
    # Determine what nesting level we are at (if any)
    $nestingLevel = ''
    if ($nestedpromptlevel -ge 1) {
        $nestingLevel = " [Nested:${nestedpromptlevel}]"
    }
    
    $promptChar = '>'
    if ($Pscx:IsAdmin) {
		$promptChar = '#'
	}
    
    # Output prompt string
    "${nextCommandId}${nestingLevel}$promptChar"
}
