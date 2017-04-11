# ---------------------------------------------------------------------------
# Author: Keith Hill based on a Start-Debug script by Jeff Jones (MSFT) and
#         from scripts in the excellent book "Windows PowerShell In Action" by
#         Bruce Payette.
# Desc:   Set of debug functions that allow you to set breakpoints in a
#         script as well as temporarily disable/enable and skip breakpoints.
# Date:   Nov 18, 2006
# Site:   http://pscx.codeplex.com
# Usage:  In your profile place the following command:
#  
#         . "$Pscx:ProfileDir\Debug.ps1"
# ---------------------------------------------------------------------------
if (Test-Path Variable:\PSVersionTable)
{
	Write-Warning "This script is deprecated on PowerShell V2.  See the built-in cmdlets: *-PSBreakpoint and Get-PSCallStack."
}

$Pscx:Session['Debug/BreakpointsEnabled'] = $true
$Pscx:Session['Debug/BreakpointSkipCount'] = 0

# ---------------------------------------------------------------------------
### <Function name='Set-Breakpoint'>
### <Author>Keith Hill inspired by Jeff Jones and Bruce Payette.</Author>
### <Description>
### This function sets a breakpoint in a script that causes a nested prompt to be entered.
### NOTE: In PowerShell V2, use the built-in Set-PSBreakpoint cmdlet instead.
### </Description>
### <Usage>Set-Breakpoint</Usage>
### </Function>
# ---------------------------------------------------------------------------
set-alias bp Set-Breakpoint -Option AllScope -Description "PSCX function alias"
function Set-Breakpoint([scriptblock] $condition, [bool]$displaySkipCount = $false)
{
    if (!$Pscx:Session['Debug/BreakpointsEnabled']) { return }
	
    if ($Pscx:Session['Debug/BreakpointSkipCount']-- -gt 0) {
		if ($displaySkipCount) {
			Write-Host "Skipping breakpoint, skip count is $Pscx:Session['Debug/BreakpointSkipCount']"
		}
		return 
	}
	
	$breakpointHit = $false
	if ($condition) {
		if (. $condition) {
			$breakpointHit = $true
		}
	}
	else {
		$breakpointHit = $true
	}
	
	if ($breakpointHit) {
		$scriptName = $MyInvocation.ScriptName
		$lineNumber = $MyInvocation.ScriptLineNumber
		function prompt
		{
			$fmt = "Bkpt scope:{0} line:{1} <Type 'exit' to continue execution>`n! "
			if ($scriptName) {
				 $fmt -f "globalscope", "<unknown>"
			}
			else {
				 $fmt -f (Split-Path $scriptName -Leaf), $lineNumber	
			}
		}
		$host.EnterNestedPrompt()	
	}
}

# ---------------------------------------------------------------------------
### <Function name='Get-CallStack'>
### <Author>Bruce Payette - from the book Windows PowerShell In Action</Author>
### <Description>
### Displays the function invocation callstack.
### NOTE: In PowerShell V2, use the built-in Get-PSCallStack cmdlet instead.
### </Description>
### </Function>
# ---------------------------------------------------------------------------
set-alias gcs Get-CallStack -Option AllScope -Description "PSCX function alias"
function Get-CallStack {
	trap { continue }
	0..100 | foreach {
		$var = Get-Variable -scope $_ myinvocation
		$var.Value.PositionMessage -replace "`n"
	}
}

# ---------------------------------------------------------------------------
### <Function name='Enable-Breakpoints'>
### <Author>Keith Hill</Author>
### <Description>
### Globally enables breakpoints.
### NOTE: In PowerShell V2, use the built-in Enable-PSBreakpoint cmdlet instead.
### </Description>
### </Function>
# ---------------------------------------------------------------------------
set-alias ebp Enable-Breakpoints -Option AllScope -Description "PSCX function alias"
function Enable-Breakpoints {
	$Pscx:Session['Debug/BreakpointsEnabled'] = $true
	Write-Host "Breakpoints enabled"
}

# ---------------------------------------------------------------------------
### <Function name='Disable-Breakpoints'>
### <Author>Keith Hill</Author>
### <Description>
### Globally disables breakpoints.
### NOTE: In PowerShell V2, use the built-in Disable-PSBreakpoint cmdlet instead.
### </Description>
### </Function>
# ---------------------------------------------------------------------------
set-alias dbp Disable-Breakpoints -Option AllScope -Description "PSCX function alias"
function Disable-Breakpoints {
	$Pscx:Session['Debug/BreakpointsEnabled'] = $false
	Write-Host "Breakpoints disabled"
}

# ---------------------------------------------------------------------------
### <Function name='Skip-Breakpoints'>
### <Author>Keith Hill</Author>
### <Description>
### Skips over specified number of breakpoints before breaking.
### </Description>
### <Usage>Skip-Breakpoints 5</Usage>
### </Function>
# ---------------------------------------------------------------------------
set-alias skbp Skip-Breakpoints -Option AllScope -Description "PSCX function alias"
function Skip-Breakpoints([int]$num) {
	$Pscx:Session['Debug/BreakpointSkipCount'] = $num
}
