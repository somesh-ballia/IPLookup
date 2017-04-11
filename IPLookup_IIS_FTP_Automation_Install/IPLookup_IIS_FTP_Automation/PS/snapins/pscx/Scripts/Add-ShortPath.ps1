# ---------------------------------------------------------------------------
### <Script>
### <Author>Keith Hill</Author>
### <Description>
### Adds the file or directory's short path as a "ShortPath" 
### NoteProperty to the input DirectoryInfo object. NOTE: This filter 
### requires the PSCX cmdlet Get-ShortPath
### </Description>
### <Usage>dir | Add-ShortPath | Format-Table ShortPath,FullName</Usage>
### </Script>
# ---------------------------------------------------------------------------
process {
	if ($_ -is [System.IO.FileSystemInfo]) {
		$shortPathInfo = Get-ShortPath -LiteralPath $_.Fullname 
		Add-Member NoteProperty ShortPath $shortPathInfo.ShortPath -InputObject $_
	}
	$_
}