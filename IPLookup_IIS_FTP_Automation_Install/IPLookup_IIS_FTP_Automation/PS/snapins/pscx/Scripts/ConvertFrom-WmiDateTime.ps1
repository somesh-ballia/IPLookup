# ---------------------------------------------------------------------------
### <Script>
### <Author>Keith Hill inspired by a Jim Truher newsgroup post</Author>
### <Description>
### Uses the PowerShell ManagementDateTimeConverter to converter between WMI
### and .NET DateTime.  This is a pipeline oriented script.
### </Description>
### <Usage>
### gwmi win32_operatingsystem | gpv LastBootUpTime | ConvertFrom-WmiDateTime
### </Usage>
### </Script>
# ---------------------------------------------------------------------------
param($wmiDateTime)

process {
	if ($_ -ne $null) {
		[System.Management.ManagementDateTimeConverter]::ToDateTime($_)
	}
}

end {
	if ($wmiDateTime -ne $null) {
		[System.Management.ManagementDateTimeConverter]::ToDateTime($wmiDateTime)
	}
}