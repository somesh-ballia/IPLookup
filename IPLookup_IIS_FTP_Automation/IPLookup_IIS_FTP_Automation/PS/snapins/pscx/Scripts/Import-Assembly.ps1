# ---------------------------------------------------------------------------
### <Script>
### <Author>Keith Hill</Author>
### <Description>
### Imports the specified assembly via LoadWithPartialName or LoadFrom.
### </Description>
### <Usage>
### Import-Assembly System.Windows.Forms
### Import-Assembly .\Foo.dll
### </Usage>
### </Script>
# ---------------------------------------------------------------------------
param([string]$partialNameOrPath)

function Usage {
    ""
    "Usage: Import-Assembly -PartialNameOrPath <string>"
    ""
    "Parameters:"
    "    -PartialNameOrPath : The partial name of an assembly e.g. System.Windows.Forms"
    "                         or the path to an assembly to load"
    "    -?                 : Display this usage information"
    ""
    exit
}

if ($args -eq '-?') {
	Usage
}

if (!$partialNameOrPath) {
	Write-Error "You must specify either a partial name or a path to an assembly"
	Usage
}

$assembly = $null
if (Test-Path($partialNameOrPath)) {
    $rpath = Resolve-Path $partialNameOrPath
	$assembly = [System.Reflection.Assembly]::LoadFrom($rpath)
	if ($assembly -eq $null) {
		Write-Error "Failed to import assembly from $rpath"
	}
}
else {
	$assembly = [System.Reflection.Assembly]::LoadWithPartialName($partialNameOrPath)
	if ($assembly -eq $null) {
		Write-Error "Failed to import assembly with the partial name $partialNameOrPath"
	}
}

$assembly