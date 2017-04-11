# ---------------------------------------------------------------------------
### <Script>
### <Author>Keith Hill</Author>
### <Description>
### Selects individual history info objects or ranges of them.
### </Description>
### <Usage>Select-History (1..5+8,9+14..20)</Usage>
### </Script>
# ---------------------------------------------------------------------------
param([int[]]$Indices)

function Usage {
	""
	"Usage: Select-History [-Indices] <int[]>"
	""
	"Parameters:"
	"    -Indices    : Indices of history to select e.g. Select-History (1..5+8,9+14..20)"
	"    -?          : Display this usage information"
	""
	exit
}
     
if ($args -eq '-?') {
	Usage
}

if (!$Indices) {
	Write-Error "You must specify an array of indices."
	Usage
}

$Indices | foreach {(get-history -id $_).CommandLine}