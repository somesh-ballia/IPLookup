# ---------------------------------------------------------------------------
### <Function name='dirx'>
### <Author>Keith Hill</Author>
### <Description>
### DIRX is an extended dir function that is used by dird, dirs and dirt. 
### It provides shortcuts for displaying files/dirs with particular 
### attributes.  For more information execute "dirx -?".
### </Description>
### <Usage>
### dirx
### dirx -set Directory,Hidden
### </Usage>
### </Function>
# ---------------------------------------------------------------------------
function dirx { 
	param (
		[string[]]$path = @('.'), 
		[string]$filter,
	    [switch]$force,
	    [switch]$recurse,
	    [string]$errorVariable,
	    [string]$outputVariable,
		[int]$first, 
		[int]$last, 
		[scriptblock]$where, 
		[object[]]$sort, 
	    [string[]]$setAttr, 
	    [string[]]$unsetAttr,
	    [switch]$combine,
	    [switch]$desc, 
	    [switch]$wide,
	    [switch]$verbose,
	    [switch]$debug
	)
	
	function Test-FileAttributes {
		param([IO.FileAttributes]$attr,  $setAttr, $unsetAttr)
		
		if ($unsetAttr) {
			$unsetAttr = [IO.FileAttributes]$unsetAttr
			if (($attr -band $unsetAttr)) {
				write-debug "Evaluating attribs: actual='$attr' set='$setAttr' unset='$unsetAttr'"
				return $false
			}
		}

		if ($setAttr) {
			$setAttr = [IO.FileAttributes]$setAttr
			if (($attr -band $setAttr) -ne $setAttr) {
				write-debug "Evaluating attribs: actual='$attr' set='$setAttr' unset='$unsetAttr'"
				return $false
			}
		}
		
		$true
	}
	
	function Test-FileSystem($currentPath) {
		(Get-Item $currentPath -Force).PSProvider.ImplementingType -eq [Microsoft.PowerShell.Commands.FileSystemProvider]
	}
	
	function New-DirExpression {
		
		$dircmd = 'Get-ChildItem -Path $currentPath -Force:$forceVal -Recurse:$recurse -Debug:$debug -Verbose:$verbose'
		
		if (!$debug) {
			$dircmd += ' -ErrorAction SilentlyContinue'
		}
		
		if ($filter) {
			$dircmd += ' -Filter:$filter'
		}
		
		if ($errorVariable) {
			$dircmd += ' -ErrorVariable:$errorVariable'
		}

		if ($outputVariable) {
			$dircmd += ' -OutputVariable:$outputVariable'
		}
		
		if (Test-FileSystem $currentPath) {
			if (($setAttr -or $unsetAttr) -and !($Pscx:Preferences['DirDisableAttrFiltering'] -eq $true)) 
			{
				$dircmd += ' | Where { (Test-FileAttributes $_.Attributes $setAttr $unsetAttr) }'
			}
		}
		
		if ($where) {
			$dircmd += ' | Where $where'
		}
		
		if ($sort) {
			$dircmd += ' | Sort $sort -Descending:$desc'
		}
		else {
			# default sort order is dirs first and then sort by name
			$dircmd += ' | Sort @{E={$_.PSIsContainer}; Asc=0}, @{E={$_.Name}; Asc=!$desc}'
		}
		
		if ($first -gt 0) {
			$dircmd += ' | Select -First $first'
		}
		elseif ($last -gt 0) {
			$dircmd += ' | Select -Last $last'
		}
			
		$dircmd	
	}
	
    if ($args -eq '-?') {
        ""
        "Usage: dirx [[-path] <string[]>] [[-filter] <string[]>] [[-force] <switch>] " +
                "[[-recurse] <switch>] [[-first] <int>] [[-last] <int>] [[-where] <scriptblock>] " +
                "[[-sort] <object[]>] [[-setAttr] <string[]>] [[-unsetAttr] <string[]>] " +
                "[[-desc] <switch>] [[-combine] <switch>] [[-wide] <switch>]" +
                "[[-errorVariable] <string>] [[-outputVariable] <string>]"
        ""
        "Parameters:"
        "    -path      : Path(s) to operate on"
        "    -filter    : Provider specific filter string that qualifies path parameter"
        "    -force     : Force display of hidden items"
        "    -recurse   : Operate recursively on path contents"
        "    -first     : Display only the first specified number of items"
        "    -last      : Display only the last specified number of items"
        "    -combine   : Combine output of multiple paths into a single stream"
        "    -where     : Filter scriptblock to apply to the output"
        "    -sort      : Sort property name(s) or hashtable to apply to output"
        "    -desc      : Modifies the sort parameter to sort in descending order"
        "    -setAttr   : Filter items by those that have the specified attrs set"
        "    -unsetAttr : Filter items by those that have the specified attrs not set"
        "    -wide      : Display directory output in wide format"
        "    -?         : Display this usage information"
        ""
        "The possible enumeration values for setAttr and unsetAttr are: "
        "    ReadOnly, Hidden, System, Directory, Archive, Device, Normal, Temporary, "
        "    SparseFile, ReparsePoint, Compressed, Offline, NotContentIndexed, Encrypted"
        ""
        return
    }

	$paths = $path   
    if ($combine) {
		$paths = ,$path
    }
    
    if ($Pscx:Preferences['DirForce'] -and $Pscx:Preferences['DirHideSystem'] -and !$setAttr -and !$unsetAttr) {
		$unsetAttr += 'System'
    }
        
    $forceVal = $force -or $Pscx:Preferences['DirForce'] -or $setAttr -or $unsetAttr
			    
	$OFS = ','
	foreach ($currentPath in $paths) {
		
		$dircmd = New-DirExpression
		
		Write-Debug ($ExecutionContext.InvokeCommand.ExpandString($dircmd))

		if ($wide) {
			Invoke-Expression $dircmd | Format-Wide -Autosize
		}
		else {
			Invoke-Expression $dircmd
		}
	}
}

# ---------------------------------------------------------------------------
### <Function name='dird'>
### <Author>Keith Hill</Author>
### <Description>
### Displays just containers (directories).
### </Description>
### <Usage>
### dird
### dird -first 5
### dird C:\,$env:windir -combine
### </Usage>
### </Function>
# ---------------------------------------------------------------------------
function dird { 
	param (
		[string[]]$path = '.', 
		[int]$first, 
		[int]$last, 
		[switch]$desc, 
		[switch]$combine, 
		[switch]$wide
	)
	
	dirx -path $path -where {$_.PSIsContainer} -desc:$desc `
	     -first $first -last $last -combine:$combine -wide:$wide
}

# ---------------------------------------------------------------------------
### <Function name='dirw'>
### <Author>Keith Hill</Author>
### <Description>
### Displays folder contents in wide format.
### </Description>
### <Usage>
### dirw
### dirw C:\,$env:windir -combine
### </Usage>
### </Function>
# ---------------------------------------------------------------------------
function dirw { 
	param (
		[string[]]$path = '.', 
		[int]$first, 
		[int]$last, 
		[switch]$desc, 
		[switch]$combine
	)
	
	dirx -path $path -desc:$desc -first $first -last $last -combine:$combine -wide
} 

# ---------------------------------------------------------------------------
### <Function name='dirs'>
### <Author>Keith Hill</Author>
### <Description>
### Displays folder contents sorted by size descending.
### </Description>
### <Usage>
### dirs
### dirs -first 10
### dirs C:\,$Home -combine -f 20
### </Usage>
### </Function>
# ---------------------------------------------------------------------------
function dirs {
	param (
		[string[]]$path = '.',
		[int]$first,
		[int]$last,
		[switch]$ascending, 
		[switch]$combine, 
		[switch]$wide
	)
	
	dirx -path $path -where { !$_.PSIsContainer } -sort @{E={$_.Length}; Asc=$ascending} `
	     -first $first -last $last -combine:$combine -wide:$wide
} 

# ---------------------------------------------------------------------------
### <Function name='dirt'>
### <Author>Keith Hill</Author>
### <Description>
### Displays folder contents sorted by time descending.
### </Description>
### <Usage>
### dirt
### dirt -first 10
### dirt C:\,$Home -combine -last 20
### </Usage>
### </Function>
# ---------------------------------------------------------------------------
function dirt { 
	param (
		[string[]]$path = '.', 
		[int]$first, 
		[int]$last, 
		[switch]$ascending, 
		[switch]$combine, 
		[switch]$wide
	)
	
	dirx -path $path -sort @{E={$_.LastWriteTime}; Asc=$ascending} `
	     -first $first -last $last -combine:$combine -wide:$wide
} 
