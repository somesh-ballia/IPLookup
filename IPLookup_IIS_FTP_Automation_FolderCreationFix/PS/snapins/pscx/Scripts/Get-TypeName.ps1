# ---------------------------------------------------------------------------
### <Script>
### <Author>Keith Hill</Author>
### <Description>
### This filter is handy for finding out what types are being passed
### down the pipeline quickly. Normally you would use Get-Member to
### determine this but if you are only interested in the type name
### this filter produces much less output.  Also, since Get-Member
### accumulates multiple instances of the same type into a single output
### record for that type, you don't get any sense of how many objects of
### that type are traversing the pipeline.  With this filter, you will
### see the type name of *every* object passed into it.  NOTE: If you
### specify any arguments then all pipeline input is ignored. This is
### due to the fact that PowerShell executes the Process function even
### if there isn't any input so it is impossible to distinguish between
### $null pipeline input and no pipeline input.
### </Description>
### <Usage>
### gcm get-* | Get-TypeName
### Get-TypeName "hi" 1 3.14 $false
### Get-Command get-* | Get-TypeName -FullName
### </Usage>
### </Script>
# ---------------------------------------------------------------------------
param([switch]$FullName=$false, [switch]$PassThru)

begin {	
	if ($args -eq '-?') {
		""
		"Usage: Get-TypeName [[-FullName] <switch>]"
		""
		"Parameters:"
		"    -FullName : Display the fully qualified type name"
		"    -PassThru : Passes the object to the next stage of the pipeline"
		"    -?        : Display this usage information"
		""
		exit
	}
			
	$script:processedInput = $false
	
	function WriteTypeName($obj) {
		if ($obj -eq $null) {
			Write-Host "<null>"
		}
		else {
			$typeName = $obj.PSObject.TypeNames[0]
			if (!$fullName) {
				$ndx = $typeName.LastIndexOf('.')
				if (($ndx -ne -1) -and ($ndx -lt ($typeName.length - 1))) {
					$typeName = $typeName.Substring($ndx+1)
				}
			}
			Write-Host $typename
		}
		$script:processedInput = $true		
	}
}

process {
	if ($args.count -eq 0) {
		WriteTypeName $_
		if ($PassThru) {
			$_
		}
	}
}

end {
	foreach ($arg in $args) {
		WriteTypeName $arg
	}
	
	if (!$script:processedInput) {
		Write-Warning 'Get-TypeName did not receive any input. The input may be an empty collection. You can either prepend the collection expression with the comma operator e.g. ",$collection | gtn" or you can pass the variable or expression to Get-TypeName as an argument e.g. "gtn $collection".'
	}
}