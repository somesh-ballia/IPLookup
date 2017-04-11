# ---------------------------------------------------------------------------
### <Script>
### <Author>Joris van Lier and Keith Hill</Author>
### <Description>
### Gets the possible alternate views for the specified object.
### </Description>
### <Usage>
### Get-ViewDefinition
### Get-ViewDefinition System.Diagnostics.Process
### Get-ViewDefinition Pscx.Commands.HashInfo $pscxhome\formatdata\*.ps1xml
### Get-Process | Select -first 1 | Get-ViewDefinition | ft Name,Style -groupby SelectedBy 
### </Usage>
### </Script>
# ---------------------------------------------------------------------------
param([string]$TypeName, [string[]]$Path="$pshome\*.ps1xml")

begin {	
	if ($args -eq '-?') {
		""
		"Usage: Get-ViewDefinition [[-TypeName] <string>] [[-Path] <string[]>]"
		""
		"Parameters:"
		"    -TypeName : Displays view definitions for the specified type name"
		"    -Path     : Path to format files to search (defaults to `$PSHome\*.ps1xml)"
		"    -?        : Display this usage information"
		""
		"Example: Get-ViewDefinition System.Diagnostics.Process | ft -groupby selectedby Name, Style"
		""
		exit
	}
	
	$TypesSeen = @{}
    $InvokedViaPipeline = $false
    
	function IsViewSelectedByTypeName($view, $typeName, $formatFile) {
        if ($view.ViewSelectedBy.TypeName) {
            foreach ($t in @($view.ViewSelectedBy.TypeName)) {
                if ($typeName -eq $t) { return $true }
            }
            $false
        }
        elseif ($view.ViewSelectedBy.SelectionSetName) {
            $typeNameNodes = $formatFile.SelectNodes('/Configuration/SelectionSets/SelectionSet/Types')
            $typeNames = $typeNameNodes | foreach {$_.TypeName}
            $typeNames -contains $typeName
        }
        else {
            $false
        }
	}

    function GenerateViewDefinition($typeName, $view, $path) {
        $ViewDefinition = new-object psobject

        Add-Member NoteProperty Name $view.Name -Input $ViewDefinition
        Add-Member NoteProperty Path $path -Input $ViewDefinition
        Add-Member NoteProperty TypeName $typeName -Input $ViewDefinition
        $selectedBy = ""
        if ($view.ViewSelectedBy.TypeName) {
            $selectedBy = $view.ViewSelectedBy.TypeName
        }
        elseif ($view.ViewSelectedBy.SelectionSetName) {
            $selectedBy = $view.ViewSelectedBy.SelectionSetName
        }
        Add-Member NoteProperty SelectedBy $selectedBy -Input $ViewDefinition
        Add-Member NoteProperty GroupBy $view.GroupBy.PropertyName -Input $ViewDefinition
        if ($view.TableControl) {
            Add-Member NoteProperty Style 'Table' -Input $ViewDefinition
        }
        elseif ($view.ListControl) {
            Add-Member NoteProperty Style 'List' -Input $ViewDefinition
        }
        elseif ($view.WideControl) {
            Add-Member NoteProperty Style 'Wide' -Input $ViewDefinition
        }
        elseif ($view.CustomControl) {
            Add-Member NoteProperty Style 'Custom' -Input $ViewDefinition
        }
        else {
            Add-Member NoteProperty Style 'Unknown' -Input $ViewDefinition
        }

        $ViewDefinition
    }
    
    function GenerateViewDefinitions($typeName, $path) {
        $rpaths = resolve-path $path
        foreach ($rpath in $rpaths) {
            $formatFile = [xml](Get-Content $rpath)
            foreach ($view in $formatFile.Configuration.ViewDefinitions.View) {
                if ($typeName) {
                    if (IsViewSelectedByTypeName $view $typeName $formatFile) {
                        GenerateViewDefinition $typeName $view $rpath
                    }
                }
                else {
                    GenerateViewDefinition $typeName $view $rpath		
                }
            }
        }
    }
}

process {
    if ($_ -and !$TypesSeen[$_.PSObject.TypeNames[0]]) {
        if ($_ -is [string]) {
            GenerateViewDefinitions $_ $Path
        }
        else {
            GenerateViewDefinitions $_.PSObject.TypeNames[0] $Path
        }
        $TypesSeen[$_.PSObject.TypeNames[0]] = $true
        $script:InvokedViaPipeline = $true
    }
}

end {
    if (!$InvokedViaPipeline) {
        GenerateViewDefinitions $TypeName $Path
    }
}