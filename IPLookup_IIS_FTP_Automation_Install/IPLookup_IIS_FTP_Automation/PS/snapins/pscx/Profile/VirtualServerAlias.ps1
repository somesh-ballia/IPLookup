# ---------------------------------------------------------------------------
# Author: jachymko
# Desc:   Configures a Windows PowerShell prompt for use with 
#         Microsoft Virtual Server 2005.
# Date:   Feb 15, 2007
# Site:   http://pscx.codeplex.com
# ---------------------------------------------------------------------------

# Bail out if Virtual Server is not installed
if (!(Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Virtual Server')) {
	return
}

& {
	$VirtualServerKey = get-itemproperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Virtual Server'

	if ($VirtualServerKey) {
		$VirtualServerDir = $VirtualServerKey.ImagePath
		
		if (($VirtualServerDir) -match '"([^"]*)"') { 
			$VirtualServerDir = $matches[1] 
		}
		
		$VirtualServerDir = Split-Path $VirtualServerDir -Parent
		
		if (Test-Path $VirtualServerDir) {
			$vmrc = (join-path $VirtualServerDir 'VMRC Client\vmrc.exe')
			Set-Alias -Name vmrc -Value $vmrc -Scope Global -Option AllScope -Force -Description "PSCX application alias"
		}
	}
}