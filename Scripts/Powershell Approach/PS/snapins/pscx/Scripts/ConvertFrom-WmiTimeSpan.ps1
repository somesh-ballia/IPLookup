# ---------------------------------------------------------------------------
### <Script>
### <Author>Keith Hill inspired by a Jim Truher newsgroup post</Author>
### <Description>
### Uses the PowerShell ManagementDateTimeConverter to converter between WMI
### and .NET TimeSpan.  This is a pipeline oriented script.
### </Description>
### </Script>
# ---------------------------------------------------------------------------
param($wmiTimeSpan)

process {
	if ($_ -ne $null) {
		[System.Management.ManagementDateTimeConverter]::ToTimeSpan($_)
	}
}

end {
	if ($wmiTimeSpan -ne $null) {
		[System.Management.ManagementDateTimeConverter]::ToTimeSpan($wmiTimeSpan)
	}
}