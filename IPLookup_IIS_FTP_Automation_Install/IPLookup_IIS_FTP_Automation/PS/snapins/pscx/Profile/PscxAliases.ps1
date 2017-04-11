# ---------------------------------------------------------------------------
# Desc:   PowerShell Community Extensions aliases for cmdlets and scripts.
# Site:   http://pscx.codeplex.com
# ---------------------------------------------------------------------------

function Set-PscxAlias($alias, $target, $type = 'cmdlet') {
	Set-Alias -Name $alias -Value $target -Scope Global -Option AllScope -Force -Description "PSCX $type alias"
}

#-------------------
# Cmdlet aliases PowerShell cmdlets
#-------------------	
Set-PscxAlias 'sls' 'Select-String'

#-------------------
# Cmdlet aliases for PSCX cmdlets
#-------------------	
Set-PscxAlias 'cvxml'      'Convert-Xml'
Set-PscxAlias 'fhex'       'Format-Hex'
Set-PscxAlias 'fxml'       'Format-Xml'
Set-PscxAlias 'gcb'        'Get-Clipboard'
Set-PscxAlias 'rnd'        'Get-Random'
Set-PscxAlias 'ln'         'New-HardLink'
Set-PscxAlias 'mail'       'Send-SmtpMail'
Set-PscxAlias 'ocb'        'Out-Clipboard'
Set-PscxAlias 'ping'       'Ping-Host'
Set-PscxAlias 'slxml'      'Select-Xml'
Set-PscxAlias 'skip'       'Skip-Object'
Set-PscxAlias 'saps'       'Start-Process'
Set-PscxAlias 'start'      'Start-Process'
Set-PscxAlias 'tail'       'Tail-File'
Set-PscxAlias 'touch'      'Set-FileTime'

#-------------------
# Compat aliases	
#-------------------	
Set-PscxAlias 'Get-DiskUsage'  'Get-DriveInfo'

#-------------------
# Script aliases	
#-------------------
if (!(Test-Path Variable:\PSVersionTable)) {
	# Only create these aliases for V1 since V2's Get-Help automatically searches content
	Set-PscxAlias 'apropos'  'Get-HelpMatch'          'script'
	Set-PscxAlias 'ghm'      'Get-HelpMatch'          'script'

	# This functionality has been deprecated in V2 by Add-Type -assembly
	Set-PscxAlias 'ipasm'    'Import-Assembly'        'script'
	
	# This alias is now defined in V2
	Set-PscxAlias 'Measure'  'Measure-Object'
}	

Set-PscxAlias 'ephy'     'Export-History'         'script'
Set-PscxAlias 'iphy'     'Import-History'         'script'
Set-PscxAlias 'lorem'    'Get-LoremIpsum'         'script'
Set-PscxAlias 'gtn'      'Get-TypeName'           'script'
Set-PscxAlias 'rver'     'Resolve-Error'          'script'
Set-PscxAlias 'srts'     'Search-Transcript'      'script'
Set-PscxAlias 'sro'      'Set-ReadOnly'           'script'
Set-PscxAlias 'swr'      'Set-Writable'           'script'

Remove-Item Function:\Set-PscxAlias -Force
