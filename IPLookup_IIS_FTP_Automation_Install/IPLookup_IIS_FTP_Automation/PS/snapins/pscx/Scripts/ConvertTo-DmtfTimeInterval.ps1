# ---------------------------------------------------------------------------
### <Script>
### <Author>Keith Hill inspired by a Jim Truher newsgroup post</Author>
### <Description>
### Uses the PowerShell ManagementDateTimeConverter to converter between DMTF
### and .NET TimeSpan.
### </Description>
### </Script>
# ---------------------------------------------------------------------------
param($timeSpan)

process {
	if ($_ -ne $null) {
		[System.Management.ManagementDateTimeConverter]::ToDmtfTimeInterval($_)
	}
}

end {
	if ($timeSpan -ne $null) {
		[System.Management.ManagementDateTimeConverter]::ToDmtfTimeInterval($timeSpan)
	}
}