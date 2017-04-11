# ---------------------------------------------------------------------------
# Desc:   PowerShell Community Extensions miscellaneous function definitions.
# Site:   http://pscx.codeplex.com
# Usage:  In your profile place the following command:
#  
#         . "$Pscx:ProfileDir\GenericFunctions.ps1"
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
### <Function name='cd..'>
### <Author>Keith Hill</Author>
### <Description>
### Auto-correct function for 'cd ..' which changes location up one level.
### </Description>
### </Function>
# ---------------------------------------------------------------------------
function cd..    { cd .. }

# ---------------------------------------------------------------------------
### <Function name='cd...'>
### <Author>Keith Hill</Author>
### <Description>
### Auto-correct function for 'cd ...' which changes location up two levels.
### </Description>
### </Function>
# ---------------------------------------------------------------------------
function cd...   { cd ..\.. }

# ---------------------------------------------------------------------------
### <Function name='cd....'>
### <Author>Keith Hill</Author>
### <Description>
### Auto-correct function for 'cd ....' which changes location up three levels.
### </Description>
### </Function>
# ---------------------------------------------------------------------------
function cd....  { cd ..\..\.. }

# ---------------------------------------------------------------------------
### <Function name='cd.....'>
### <Author>Keith Hill</Author>
### <Description>
### Auto-correct function for 'cd .....' which changes location up four levels.
### </Description>
### </Function>
# ---------------------------------------------------------------------------
function cd..... { cd ..\..\..\.. }

# ---------------------------------------------------------------------------
### <Function name='cd\'>
### <Author>Keith Hill</Author>
### <Description>
### Auto-correct function for 'cd \' which changes location to the root of the current drive.
### </Description>
### </Function>
# ---------------------------------------------------------------------------
function cd\     { cd \ }

# ---------------------------------------------------------------------------
### <Function name='cd~'>
### <Author>Keith Hill</Author>
### <Description>
### Auto-correct function for 'cd ~' which changes location to your Home dir.
### </Description>
### </Function>
# ---------------------------------------------------------------------------
function cd~     { cd ~ }

# ---------------------------------------------------------------------------
### <Function name='Elevate'>
### <Author>Keith Hill</Author>
### <Description>
### Runs the specified command via an elevated PowerShell instance on Vista.
### To get debug info, set $DebugPreference temporarily to 'Continue'.
### </Description>
### <Usage>
### elevate
### elevate notepad c:\windows\system32\drivers\etc\hosts
### elevate gci c:\windows\temp
### elevate {gci c:\windows\temp | export-clixml tempdir.xml; exit}
### elevate {gci c:\windows\temp | export-clixml tempdir.xml; exit} | 
###         %{$_.WaitForExit(5000)} | %{Import-Clixml tempdir.xml}
### </Usage>
### </Function>
# ---------------------------------------------------------------------------
Set-Alias su Elevate -Option AllScope -Description "PSCX function alias"
function Elevate {
	$ndx=0
	if ($MyInvocation.PositionMessage -match 'char:(\d+)') {
		$ndx = [int]$matches[1]
	}
	
	$setDirCmd = "[Environment]::CurrentDirectory = (set-location -LiteralPath '$pwd' -PassThru).ProviderPath"
	
	$OFS = ","
	Write-Debug "`$MyInvocation.Line args index is $ndx; `$args are <$args>"
	
	if ($args.Length -eq 0)	{
        Write-Debug "Starting Powershell without args"
        start-process powershell.exe -verb runas  -workingdir $pwd `
            -arguments "-noexit -command & {$setDirCmd}"		
	}
	elseif ($args[0] -is [Scriptblock]) {
        $script = $args[0]
        Write-Debug "Starting PowerShell with scriptblock: {$script}"
        start-process powershell.exe -verb runas -workingdir $pwd `
            -arguments "-noexit -command & {$setDirCmd; $script}"	
	}
	elseif ($args[0].length -gt 0) {
        $startProcessArgs = $MyInvocation.Line.Substring($ndx)
        
        $app = get-command $args[0] | select -first 1 | ? {$_.CommandType -eq 'Application'}
        if ($app) {
            $startProcessArgs = $startProcessArgs.Substring($args[0].Length).Trim()
            Write-Debug "Starting <$($app.Path)> with args: <$startProcessArgs>"
            start-process $app.Path -verb runas -workingdir $pwd -arguments $startProcessArgs	
        }
        else {
            Write-Debug "Starting PowerShell with args: <$startProcessArgs>"
            start-process powershell.exe -verb runas -workingdir $pwd `
                -arguments "-noexit -command & {$setDirCmd; $startProcessArgs}"	        
        }
	}
}

# ---------------------------------------------------------------------------
### <Function name='Get-VariableSorted'>
### <Author>Keith Hill</Author>
### <Description>
### Behaves just like Get-Variable except that the output is sorted by name.
### </Description>
### </Function>
# ---------------------------------------------------------------------------
Set-Alias gvs Get-VariableSorted -Option AllScope -Description "PSCX function alias"
function Get-VariableSorted { 
	Get-Variable | Sort Name 
}

# ---------------------------------------------------------------------------
### <Function name='Get-PscxAlias'>
### <Author>Keith Hill</Author>
### <Description>
### Displays all of the aliases created by PSCX.
### </Description>
### </Function>
# ---------------------------------------------------------------------------
Set-Alias galpscx Get-PscxAlias -Option AllScope -Description "PSCX function alias"
function Get-PscxAlias {
	Get-Alias | Where {$_.Description -match "^PSCX" -or $_.Name -match "Pscx|__pscx"} | Sort Name
}

# ---------------------------------------------------------------------------
### <Function name='Get-PscxCmdlet'>
### <Author>Keith Hill</Author>
### <Description>
### Displays all of the cmdlets provided by PSCX.
### </Description>
### </Function>
# ---------------------------------------------------------------------------
Set-Alias gcmpscx Get-PscxCmdlet -Option AllScope -Description "PSCX function alias"
function Get-PscxCmdlet {
	Get-Command -type cmdlet | Where {$_.PSSnapin -match "^Pscx"} | Sort Noun, Verb
}

# ---------------------------------------------------------------------------
### <Function name='Get-PscxDrive'>
### <Author>Keith Hill</Author>
### <Description>
### Displays all of the drives created by PSCX.
### </Description>
### </Function>
# ---------------------------------------------------------------------------
Set-Alias gdrpscx Get-PscxDrive -Option AllScope -Description "PSCX drive alias"
function Get-PscxDrive {
	Get-PSDrive | Where {$_.Provider -match '^Pscx'} | Sort Name
}

# ---------------------------------------------------------------------------
### <Function name='Edit-File'>
### <Author>Keith Hill</Author>
### <Description>
### Opens up the specified text file in the text editor specified by 
### $Pscx:Preferences['TextEditor'] variable.  If not specified or the 
### specified editor isn't found then notepad is used.
### </Description>
### <Usage>
### Edit-File foo.txt
### gci -r -filter *.make | edit-file
### </Usage>
### </Function>
# ---------------------------------------------------------------------------
Set-Alias e Edit-File -Option AllScope -Description "PSCX function alias"
function Edit-File([string]$Path) {
	begin {
		$editor = "notepad.exe"
	    $InvokedViaPipeline = $false	
		if ($Pscx:Preferences['TextEditor']) {
			Get-Command $Pscx:Preferences['TextEditor'] 2>&1 | out-null
			if ($?) {
				$editor = $Pscx:Preferences['TextEditor']
			}
		}
		
		function EditFileImpl($path) {
			$filePath = $path
			if (Test-Path $path) {
				$rpath = Resolve-Path $path
				$filePath = $rpath.ProviderPath
			}
			& $editor $filePath
		}
	}
	process {
		if ($_) {
	        $InvokedViaPipeline = $true		
			if ($_ -is [System.IO.FileInfo]) {
				EditFileImpl $_.Fullname
			}
			else {
				EditFileImpl $_.ToString()
			}
		}
	}
	end {
		if (!$InvokedViaPipeline) {
			EditFileImpl $Path
		}
	}
}

# ---------------------------------------------------------------------------
### <Function name='Update-Profile'>
### <Author>Jachym</Author>
### <Description>
### Reloads the user's generic (non-host specific) profile.
### </Description>
### </Function>
# ---------------------------------------------------------------------------
Set-Alias up Update-Profile -Option AllScope -Description "PSCX function alias"
Set-Alias rehash Update-Profile -Option AllScope -Description "PSCX function alias"
function Update-Profile {
	. (Join-Path (Split-Path $Profile -Parent) Profile.ps1)
}

# ---------------------------------------------------------------------------
### <Function name='Edit-Profile'>
### <Author>Keith Hill</Author>
### <Description>
### Opens the user's generic (non-host specific) profile into the editor 
### defined by $Pscx:Preferences['TextEditor'] variable.  If not specified
### or the specified editor isn't found then notepad is used.
### </Description>
### </Function>
# ---------------------------------------------------------------------------
Set-Alias ep Edit-Profile -Option AllScope -Description "PSCX function alias"
function Edit-Profile {
	Edit-File (Join-Path (Split-Path $Profile -Parent) Profile.ps1)
}

# ---------------------------------------------------------------------------
### <Function name='Edit-HostProfile'>
### <Author>Keith Hill</Author>
### <Description>
### Opens the user's host specific profile into the editor 
### defined by $PscxTextEditorPreference variable.  If not specified or the 
### specified editor isn't found then notepad is used.
### </Description>
### </Function>
# ---------------------------------------------------------------------------
Set-Alias ehp Edit-HostProfile -Option AllScope -Description "PSCX function alias"
function Edit-HostProfile {
	Edit-File $Profile
}

# ---------------------------------------------------------------------------
### <Function name='Edit-GlobalProfile'>
### <Author>Keith Hill</Author>
### <Description>
### Opens the machine wide generic (non-host specific) profile into the editor 
### defined by $PscxTextEditorPreference variable.  If not specified or the 
### specified editor isn't found then notepad is used.
### </Description>
### </Function>
# ---------------------------------------------------------------------------
Set-Alias egp Edit-GlobalProfile -Option AllScope -Description "PSCX function alias"
function Edit-GlobalProfile {
	Edit-File (Join-Path $PSHome Profile.ps1)
}

# ---------------------------------------------------------------------------
### <Function name='Edit-GlobalHostProfile'>
### <Author>Keith Hill</Author>
### <Description>
### Opens the machine wide, host specific profile into the editor 
### defined by $PscxTextEditorPreference variable.  If not specified or the 
### specified editor isn't found then notepad is used.
### </Description>
### </Function>
# ---------------------------------------------------------------------------
Set-Alias eghp Edit-GlobalHostProfile -Option AllScope -Description "PSCX function alias"
function Edit-GlobalHostProfile {
	Edit-File (Join-Path $PSHome (Split-Path $Profile -Leaf))
}

# ---------------------------------------------------------------------------
### <Function name='Less'>
### <Author>jachymko</Author>
### <Description>
### Provides easy PowerShell access to the external Less-394 paging application.
### NOTE: Be careful using less with large amounts of output e.g. gci $env:windir\System32 | less.
### It appears that PowerShell buffers up all the gci output before converting it to strings to
### pass to less.
### </Description>
### <Usage>Get-Content foo.txt | less</Usage>
### </Function>
# ---------------------------------------------------------------------------
Set-Alias pager less -Option AllScope -Description "PSCX alias"
function Less {
	$OutputEncoding = [Console]::OutputEncoding
	
	if ($args) {
		& "$Pscx:Home\Applications\Less-394\less.exe" @($args |? { test-path $_ } |% { "`"$(resolve-path $_)`"" })
	}
	else {
		$input | out-string | & "$Pscx:Home\Applications\Less-394\less.exe"
	}
}

# ---------------------------------------------------------------------------
### <Function name='Quote-List'>
### <Author>Bruce Payette - from the book Windows PowerShell In Action</Author>
### <Description>
### Use as a wrist friendly way of creating an array of strings without
### having to type extraneous commas and quotes:
### </Description>
### <Usage>ql foo bar baz # equivalent of "foo", "bar", "baz"</Usage>
### </Function>
# ---------------------------------------------------------------------------
Set-Alias ql Quote-List -Option AllScope -Description "PSCX function alias"
function Quote-List { $args }

# ---------------------------------------------------------------------------
### <Function name='Quote-String'>
### <Author>Bruce Payette - from the book Windows PowerShell In Action</Author>
### <Description>
### Use as a wrist friendly way of create a string from a set of items
### where each item will be separated by $OFS.  Eliminates having to
### type extraneous quotes:
### </Description>
### <Usage>qs $a $b $c # equivalent of "$a $b $c"</Usage>
### </Function>
# ---------------------------------------------------------------------------
Set-Alias qs Quote-String -Option AllScope -Description "PSCX function alias"
function Quote-String { "$args" }

# ---------------------------------------------------------------------------
### <Function name='Collect'>
### <Author>Keith Hill</Author>
### <Description>
### Simple alias for the [System.GC]::Collect() static method.  This comes
### in handy when a .NET object hasn't been disposed and is causing a file
### system handle to not be released.
### </Description>
### <Usage>collect</Usage>
### </Function>
# ---------------------------------------------------------------------------
function Collect {
	[System.GC]::Collect()
}

# ---------------------------------------------------------------------------
### <Function name='Get-ExceptionForHR'>
### <Author>jachymko</Author>
### <Description>Returns an exception object for a HRESULT code.</Description>
### <Usage>
### hrexc -2147023293
### Fatal error during installation. (Exception from HRESULT: 0x80070643)
### </Usage>
### </Function>
# ---------------------------------------------------------------------------
Set-Alias hrexc Get-ExceptionForHR -Option AllScope -Description "PSCX function alias"
function Get-ExceptionForHR([long]$hr = $(throw "Parameter '-hr' (position 1) is required")) {
	[Runtime.InteropServices.Marshal]::GetExceptionForHR($hr)
}

# ---------------------------------------------------------------------------
### <Function name='Get-ExceptionForWin32'>
### <Author>jachymko</Author>
### <Description>Returns an exception object for a windows error code.</Description>
### <Usage>
### winexc 5
### Access is denied
### </Usage>
### </Function>
# ---------------------------------------------------------------------------
Set-Alias winexc Get-ExceptionForWin32 -Option AllScope -Description "PSCX function alias"
function Get-ExceptionForWin32([int]$errnum = $(throw "Parameter '-errnum' (position 1) is required")) {
	new-object ComponentModel.Win32Exception $errnum
}
