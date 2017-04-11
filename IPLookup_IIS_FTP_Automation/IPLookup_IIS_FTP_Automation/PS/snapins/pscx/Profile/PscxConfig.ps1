# ---------------------------------------------------------------------------
# Author: Keith Hill, jachymko
# Desc:   Configure PSCX specific format data as well as dot sourcing various
#         functions and functionality.
# Date:   Nov 18, 2006
# Site:   http://pscx.codeplex.com
# Usage:  Dot source this configuration script in your profile script e.g.:
#
# . "$Pscx:ProfileDir\PscxConfig.ps1"
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Only execute this code once per PowerShell session, not during Update-Profile.
# ---------------------------------------------------------------------------
if ($Pscx:Session["PSConfig/RanOnce"]) 
{
	Write-Warning "PSCX already configured."
	return
}

$Pscx:Session["PSConfig/RanOnce"] = $true

# ---------------------------------------------------------------------------
# Load PSCX FileSystem format file which overrides built-in PowerShell defaults.
# ---------------------------------------------------------------------------
if ($Pscx:Preferences["UpdateFileSystemFormatData"]) {
	Write-Verbose "PSCX updating format data ${Pscx:Home}\FormatData\FileSystem.ps1xml."
	Update-FormatData -PrependPath "$Pscx:Home\FormatData\FileSystem.ps1xml"
}

# ---------------------------------------------------------------------------
# Configure PowerShell to use less.exe to page help output.
# ---------------------------------------------------------------------------
if ($Pscx:Preferences["PageHelpUsingLess"]) {
	Write-Verbose "PSCX configuring PowerShell to use less.exe to page help output."
	if (!(Test-Path Variable:\PSVersionTable)) {
		Set-Alias -Name man  -Value Get-PagedHelpV1 -Scope Global -Option AllScope -Force -Description "PSCX script alias"
		Set-Alias -Name help -Value Get-PagedHelpV1 -Scope Global -Option AllScope -Force -Description "PSCX script alias"
	}
	else {
		Set-Alias -Name man  -Value Get-PagedHelp -Scope Global -Option AllScope -Force -Description "PSCX script alias"
		Set-Alias -Name help -Value Get-PagedHelp -Scope Global -Option AllScope -Force -Description "PSCX script alias"
	}
}

# ---------------------------------------------------------------------------
# Imports environment for Visual Studio (if installed - otherwise does nothing)
# ---------------------------------------------------------------------------	
if ($Pscx:Preferences["ImportVisualStudioVars"]) {
	Write-Verbose "PSCX configuring Visual Studio environment variables."
	& "$Pscx:ScriptsDir\Import-VisualStudioVars.ps1"
}

# ---------------------------------------------------------------------------
# Intialize tab expansion system
# ---------------------------------------------------------------------------
if ($Pscx:Preferences["EnablePscxTabExpansion"]) {
	Write-Verbose "PSCX configuring tab expansion. NOTE: PSCX's Start-TabExpansion crashes PowerShell on x64 OSs."
	Start-TabExpansion  
	. "$Pscx:ProfileDir\TabExpansion.ps1"
}

# ---------------------------------------------------------------------------
# Dot source PSCX utility functions and filters.
# ---------------------------------------------------------------------------
function DotSourceScriptPerPreference($scriptName) {
	if ($Pscx:Preferences["DotSource/$scriptName"]) {
		Write-Verbose "PSCX dotting ${Pscx:ProfileDir}\$scriptName."
		. "$Pscx:ProfileDir\$scriptName"
	}
	else
	{
		Write-Verbose "PSCX skipped ${Pscx:ProfileDir}\$scriptName."
	}
}

. DotSourceScriptPerPreference Cd.ps1
. DotSourceScriptPerPreference Debug.ps1
. DotSourceScriptPerPreference Dir.ps1
. DotSourceScriptPerPreference VirtualServerAlias.ps1
. DotSourceScriptPerPreference GenericFilters.ps1
. DotSourceScriptPerPreference GenericFunctions.ps1
. DotSourceScriptPerPreference PscxAliases.ps1
. DotSourceScriptPerPreference RegexLib.ps1
. DotSourceScriptPerPreference TranscribeSession.ps1
. DotSourceScriptPerPreference EyeCandy.ps1

Remove-Item Function:\DotSourceScriptPerPreference -Force
Remove-Item Variable:\scriptName
