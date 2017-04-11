# ---------------------------------------------------------------------------
### <Script>
### <Author>Keith Hill inspired by a Jim Truher newsgroup post</Author>
### <Description>
### Uses the PowerShell ManagementDateTimeConverter to converter between DMTF
### and .NET DateTime.
### </Description>
### </Script>
# ---------------------------------------------------------------------------
param($dateTime)

process {
	if ($_ -ne $null) {
		[System.Management.ManagementDateTimeConverter]::ToDmtfDateTime($_)
	}
}

end {
	if ($dateTime -ne $null) {
		[System.Management.ManagementDateTimeConverter]::ToDmtfDateTime($dateTime)
	}
}