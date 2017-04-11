# ---------------------------------------------------------------------------
### <Script>
### <Author>Keith Hill</Author>
### <Description>
### Does a first pass parse of the script looking for syntax errors. 
### Note: This script will not find runtime errors.
### </Description>
### <Usage>
### Test-Script foo.ps1
### Get-ChildItem . *.ps1 -r | Where {!(Test-Script $_)}
### </Usage>
### </Script>
# ---------------------------------------------------------------------------
param($Path, [switch]$Verbose)

begin {	
	if ($args -eq '-?') {
		""
		"Usage: Test-Script -Path <string[]> [[-Verbose] <switch>]"
		""
		"Parameters:"
		"    -Path    : Parses the specified scripts for syntax errors"
		"    -Verbose : Displays information on syntax errors encountered"
		"    -?       : Display this usage information"
		""
		exit
	}

	if ($verbose) { $VerbosePreference = 'Continue' }
	
	function TestScript($path) {
		foreach ($rpath in Resolve-Path $Path) {
			trap { Write-Warning $_; $false; continue }
			& {
				$contents = get-content $rpath
				$contents = [string]::Join([Environment]::NewLine, $contents)
				[void]$executioncontext.InvokeCommand.NewScriptBlock($contents)
				Write-Verbose "$rpath parsed without errors"
				$true
			}
		}
	}
}	

process {
	if ($_) {
		TestScript $_
	}
}

end {
	if ($Path) {
		TestScript $Path
    }
}
