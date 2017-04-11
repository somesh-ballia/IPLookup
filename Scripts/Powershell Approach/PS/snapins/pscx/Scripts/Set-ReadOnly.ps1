# ---------------------------------------------------------------------------
### <Script>
### <Author>Keith Hill</Author>
### <Description>
### This filter can be used to change a file's read only status.
### </Description>
### <Usage>
### Set-ReadOnly foo.txt
### Set-ReadOnly [a-h]*.txt -passthru
### Get-ChildItem bar[0-9].txt | Set-ReadOnly
### </Usage>
### </Script>
# ---------------------------------------------------------------------------
param($Path, [switch]$PassThru, [switch]$Verbose)

begin {
	if ($args -eq '-?') {
		""
		"Usage: Set-ReadOnly [[-Path] <object>] [[-PassThru] <switch>] [[-Verbose] <switch>]"
		""
		"Parameters:"
		"    -Path     : Path of files or FileInfo objects to make readonly"
		"    -PassThru : Pass the input object down the pipeline"
		"    -Verbose  : Display verbose information"
		"    -?        : Display this usage information"
		""
		return
	}

	if ($verbose) { $VerbosePreference = 'Continue' }
	
	function MakeFileReadOnly($files) {
		foreach ($file in @($files)) {
			if ($file -is [System.IO.FileInfo]) {
				if ($verbose) {
					Write-Verbose "Set-ReadOnly processing $file"
				}
				$file.IsReadOnly = $true
				if ($passThru) {
					$file
				}
			}
			elseif ($file -is [string]) {
				$rpaths = @(Resolve-Path $file -ea SilentlyContinue)
				foreach ($rpath in $rpaths) {
					if ($verbose) {
						Write-Verbose "Set-ReadOnly processing $rpath"
					}
					$fileInfo = New-Object System.IO.FileInfo $rpath
					$fileInfo.IsReadOnly = $true
					if ($passThru) {
						$file
					}
				}
			}
			else {
				Write-Error "Expected type FileInfo or String, got $($file.psobject.typenames[0]) instead."
			}
		}
	}
}

process {
	if ($_) {
		MakeFileReadOnly $_
	}
}

end {
	if ($Path) {
		MakeFileReadOnly $Path
    }
}
