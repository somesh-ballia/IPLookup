# ---------------------------------------------------------------------------
### <Script>
### <Author>Keith Hill</Author>
### <Description>
### Calculates the sizes of the specified directory and adds that size
### as a "Length" NoteProperty to the input DirectoryInfo object. This script
### is pipeline oriented.
### </Description>
### <Usage>Get-ChildItem . -recurse | Add-DirectoryLength | sort Length</Usage>
### </Script>
# ---------------------------------------------------------------------------
param([string]$ErrorAction='Continue')

begin {
	function processFile([string]$path) {
		(get-item -LiteralPath $path -Force -ea Continue).Length
	}
	
	function processDirectory([string]$path) {
		$dirSize = 0
		$items = get-childitem -LiteralPath $path -Force -ea $ErrorAction | sort @{e={$_.PSIsContainer}}
		if ($items -eq $null) {
			return $null
		}
		foreach ($item in $items) {
			if ($item.PSIsContainer) {
				$dirSize += processDirectory($item.FullName)
			}
			else {
				$dirSize += processFile($item.FullName)
			}
		}
		$dirSize
	}
}

process {
	if ($_ -is [System.IO.DirectoryInfo]) {
		$dirSize = processDirectory($_.FullName)
		Add-Member NoteProperty Length $dirSize -InputObject $_
	}
	$_
}