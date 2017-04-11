# ---------------------------------------------------------------------------
### <Script>
### <Author>Keith Hill</Author>
### <Description>
### Pages help using LESS.
### </Description>
### </Script>
# ---------------------------------------------------------------------------
#requires -version 2.0 

<#
.FORWARDHELPTARGETNAME Get-Help
.FORWARDHELPCATEGORY Cmdlet
#>
[CmdletBinding(DefaultParameterSetName='AllUsersView')]
param(
    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
    [System.String]
    ${Name},

    [System.String]
    ${Path},

    [System.String[]]
    ${Category},

    [System.String[]]
    ${Component},

    [System.String[]]
    ${Functionality},

    [System.String[]]
    ${Role},

    [Parameter(ParameterSetName='DetailedView')]
    [Switch]
    ${Detailed},

    [Parameter(ParameterSetName='AllUsersView')]
    [Switch]
    ${Full},

    [Parameter(ParameterSetName='Examples')]
    [Switch]
    ${Examples},

    [Parameter(ParameterSetName='Parameters')]
    [System.String]
    ${Parameter},

	[Parameter()]
    [Switch]
    ${Online})
    
function pager {
	$OutputEncoding = [Console]::OutputEncoding	
	$input | & "$pscx:Home\Applications\Less-394\less.exe"
}

if ($Online) {
	Get-Help @PSBoundParameters
}
else {
	Get-Help @PSBoundParameters | pager
}