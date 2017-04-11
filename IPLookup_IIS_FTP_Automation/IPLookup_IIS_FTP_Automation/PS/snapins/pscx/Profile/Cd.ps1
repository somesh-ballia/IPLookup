# ---------------------------------------------------------------------------
# Author: Keith Hill
# Desc:   A CD replacement function that handles history and - and + as well
#         as ..[.]*.  Also provides a prompt function.
# Date:   Nov 18, 2006
# Site:   http://pscx.codeplex.com
# Usage:  In your profile place the following command:
#         . "$Pscx:ProfileDir\CD.ps1"
# ---------------------------------------------------------------------------

# Only initialize the backward/foreward stack once. Don't want to lose CD history
# if script is dotted multiple times.
if (!$Pscx:Session['CD/BackwardStack']) {
	$Pscx:Session['CD/BackwardStack'] = new-object System.Collections.ArrayList
	$Pscx:Session['CD/ForwardStack'] = new-object System.Collections.ArrayList
}

# We are going to replace the PowerShell default "cd" alias
Remove-Item alias:cd -Force -ErrorAction SilentlyContinue

# ---------------------------------------------------------------------------
### <Function name='cd-'>
### <Author>Keith Hill</Author>
### <Description>
### Auto-correct function for 'cd -' which changes location backwards in the stack.
### </Description>
### </Function>
# ---------------------------------------------------------------------------
function cd- { 
	cd - 
}

# ---------------------------------------------------------------------------
### <Function name='cd+'>
### <Author>Keith Hill</Author>
### <Description>
### Auto-correct function for 'cd +' which changes location forwards in the stack.
### </Description>
### </Function>
# ---------------------------------------------------------------------------
function cd+ { 
	cd + 
}

# ---------------------------------------------------------------------------
### <Function name='cd?'>
### <Author>Keith Hill</Author>
### <Description>
### Auto-correct function for 'cd ?' which displays usage information.
### </Description>
### </Function>
# ---------------------------------------------------------------------------
function cd? { 
	cd ? 
}

# ---------------------------------------------------------------------------
### <Function name='cd'>
### <Author>Keith Hill</Author>
### <Description>
### CD function that handles location history via a backward and forward
### stack mechanism that can be navigated using "cd -" to go backwards in the
### stack and "cd +" to go forwards in the stack.  Executing "cd" without any
### parameters will display the current stack history.  For more information
### execute "cd -?".
### </Description>
### <Usage>cd $pscxhome; cd -; cd +; cd -0</Usage>
### </Function>
# ---------------------------------------------------------------------------
function cd([string]$Path, [string]$LiteralPath, [switch]$PassThru) {
	begin {
		$processedPipelineObjects = $false
			
		function cdimpl($Path, $PassThruObject) {
			$curPath = get-location
			
			$backwardStack = $Pscx:Session['CD/BackwardStack']
			$forewardStack = $Pscx:Session['CD/ForwardStack']

			# Dump the directory stack
			if (!$Path -and !$LiteralPath) {
				# Command to dump the back & fore stacks
				""
				"     # Directory Stack:"
				"   --- ----------------"
				if ($backwardStack.Count -ge 0) {
					for ($i = 0; $i -lt $backwardStack.Count; $i++) { 
						"   {0,3} {1}" -f $i, $backwardStack[$i]
					} 
				}

				"-> {0,3} {1}" -f $i++, $curPath

				if ($forewardStack.Count -ge 0) {
					$ndx = $i
					for ($i = 0; $i -lt $forewardStack.Count; $i++) { 
						"   {0,3} {1}" -f ($ndx+$i), $forewardStack[$i]
					} 
				}
				""
				return
			}

			# Expand ..[.]+ out to ..\..[\..]+
			if ($Path -like "*...*") {
				$regex = [regex]"\.\.\."
				while ($regex.IsMatch($path)) {
					$path = $regex.Replace($path, "..\..")
				}
			}

			if ($Path -eq "-") {
				if ($backwardStack.Count -eq 0) {
					Write-Host "`nThe backward stack is empty.`n"
				}
				else {        
					$lastNdx = $backwardStack.Count - 1
					$prevPath = $backwardStack[$lastNdx]
					Set-Location -literalPath $prevPath; (Get-Location).ProviderPath
					[void]$forewardStack.Insert(0, $curPath)
					$backwardStack.RemoveAt($lastNdx)
				}
			}
			elseif ($Path -eq "+") {
				if ($forewardStack.Count -eq 0) {
					Write-Host "`nThe foreward stack is empty.`n"
				}
				else {
					$nextPath = $forewardStack[0]
					Set-Location -literalPath $nextPath; (Get-Location).ProviderPath
					[void]$backwardStack.Add($curPath)
					$forewardStack.RemoveAt(0)
				}
			}
			elseif ($Path -like "-[0-9]*")
			{
				[int]$num = $path.replace("-","")
				$backstackSize = $backwardStack.Count
				$forestackSize = $forewardStack.Count
				if ($num -eq $backstackSize) {
					Write-Host "`nWherever you go, there you are!`n"
				}
				elseif ($num -lt $backstackSize) {
					$selectedPath = $backwardStack[$num]
					Set-Location -literalPath $selectedPath; (Get-Location).ProviderPath
					[void]$forewardStack.Insert(0, $curPath)
					$backwardStack.RemoveAt($num)
		            
					[int]$ndx = $num
					[int]$count = $backwardStack.Count - $ndx
					if ($count -gt 0) {
						$itemsToMove = $backwardStack.GetRange($ndx, $count)
						$forewardStack.InsertRange(0, $itemsToMove)
						$backwardStack.RemoveRange($ndx, $count)
					}
				}
				elseif (($num -gt $backstackSize) -and ($num -lt ($backstackSize + 1 + $forestackSize))) {
					[int]$ndx = $num - ($backstackSize + 1)
					$selectedPath = $forewardStack[$ndx]
					Set-Location -literalPath $selectedPath; (Get-Location).ProviderPath
					[void]$backwardStack.Add($curPath)
					$forewardStack.RemoveAt($ndx)
		            
					[int]$count = $ndx
					if ($count -gt 0) {
						$itemsToMove = $forewardStack.GetRange(0, $count)
						$backwardStack.InsertRange(($backwardStack.Count), $itemsToMove)
						$forewardStack.RemoveRange(0, $count)
					}
				}
				else {
					Write-Host "`n$num is out of range.`n"
				}
			}
			else
			{
				# CD to specified path
				if ($LiteralPath) {
					if (test-path $LiteralPath -type leaf) {
						$LiteralPath = split-path $LiteralPath -parent
					}
					Set-Location -literalPath $LiteralPath -ErrorAction Stop
				}
				else {
					if (test-path $path -type leaf) {
						$path = split-path $path -parent
					}
					Set-Location $path -ErrorAction Stop
				}
				
				if ($PassThru) { 
					$PassThruObject
				}
				else {
					(Get-Location).ProviderPath 
				}
				
				$forewardStack.Clear()
				
				# Don't add the same path twice in a row
				if ($backwardStack.Count -gt 0) {
					$newPath = get-location
					if ($curPath.Path -eq $newPath.Path) {
						return
					}
				}
				[void]$backwardStack.Add($curPath)
			}
		}
    }
		
	process {
		if ($_) {
			if ($Path) {
				Write-Error "Input object cannot be bound to any parameter for this function"
				return
			}
			
			$processedPipelineObjects = $true
			if ($_.PSPath) {
				$pipelinePath = $_.PSPath
			}
			elseif ($_.Path) {
				$pipelinePath = $_.Path
			}
			elseif ($_ -is [string]) {
				$pipelinePath = $_
			}
			else {
				$pipelinePath = $_.ToString()
			}
			cdimpl (resolve-path $pipelinePath).ProviderPath $_
		}
	}
	
	end {
		# Handle the rest of the commands plus a path arg
		if (($args -eq '-?') -or ($Path -eq '?')) {
			""
			"Usage: cd command | [Path | [-LiteralPath <string>]] [-PassThru]"
			"Commands:"
			"    <no arg> : Display the directory stack"
			"    ~        : Change directory to your `$Home directory"
			"    -        : Change directory to the previous directory in the stack"
			"    +        : Change directory to the next directory in the stack"
			"    -number  : Change directory to the specified directory in the stack"
			"    ..[.]*   : Change directory to a parent directory of the current directory"
			"    ?        : Display this usage information"
			""
			return
		}
	    
		# If more than one arg, let set-location handle this error
		if ($args.Length -gt 0) {
			write-error "Takes only one argument."
			return 
		}
			
		if (!$processedPipelineObjects) {
			cdimpl $Path $Path
		}
	}			
}
