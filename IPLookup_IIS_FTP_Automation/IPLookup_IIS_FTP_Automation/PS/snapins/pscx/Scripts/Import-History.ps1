# ---------------------------------------------------------------------------
### <Script>
### <Author>Keith Hill</Author>
### <Description>
### Imports command history from a clixml file.
### </Description>
### <Usage>
### Import-History
### Import-History $home\hist.xml
### </Usage>
### </Script>
# ---------------------------------------------------------------------------
param([string]$Path)

if ($args -eq '-?') {
	""
	"Usage: Import-History [[-Path] <string>]"
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

Import-Clixml $Path | Add-History
