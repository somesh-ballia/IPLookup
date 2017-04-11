# ---------------------------------------------------------------------------
### <Script>
### <Author>Keith Hill</Author>
### <Description>
### Exports your entire command history to a clixml file.
### </Description>
### <Usage>
### Export-History
### Export-History $home\hist.xml
### </Usage>
### </Script>
# ---------------------------------------------------------------------------
param([string]$Path)

if ($args -eq '-?') {
	""
	"Usage: Export-History [[-Path] <string>]"
	""
	"Parameters:"
	"    -Path : Path to history clixml file to import"
	"    -?    : Display this usage information"
	""
	return
}

if (!$Path) {
	$destDir = Split-Path $Profile -parent
	if (!(Test-Path $destDir)) {
		$destDir = $home
	}
	$Path = Join-Path $destDir PSHistory.xml
}

Get-History -count $MaximumHistoryCount | Export-Clixml $Path