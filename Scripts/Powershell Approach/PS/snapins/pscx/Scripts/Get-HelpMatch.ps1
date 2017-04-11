# ---------------------------------------------------------------------------
### <Script>
### <Author>
### Lee Holmes, modified by Keith Hill to add aliases and -verbose param.
### </Author>
### <Description>
### Search the PowerShell help documentation for a given keyword or regular
### expression.  NOTE: In PowerShell V2, the built-in Get-Help cmdlet searches
### help topic content.
### </Description>
### <Remarks>
### Used with permission from Lee Holmes - http://www.leeholmes.com/blog
### </Remarks>
### <Usage>
### Get-HelpMatch hashtable
### Get-HelpMatch "(datetime|ticks)" -verbose
### </Usage>
### </Script>
# ---------------------------------------------------------------------------
param($Pattern,
     [switch]$Verbose,
     [switch]$NoProgress)
     
function Usage {
	""
	"Usage: Get-HelpMatch [-Pattern] <object> [[-Verbose] <switch>] " +
						  "[[-NoProgressDisplay] <switch>]"
	""
	"Parameters:"
	"    -Pattern    : Regex search pattern to use to search help content"
	"    -Verbose    : Display lines that match search pattern"
	"    -NoProgress : Suppresses display of progress window"
	"    -?          : Display this usage information"
	""
	exit
}
     
if ($args -eq '-?') {
	Usage
}

if (!$Pattern) {
	Write-Error "Please specify pattern to search for in help."
	Usage
}
     
$i = 1

$helpNames  = Get-Help -Category 'HelpFile' | Sort Name
$helpNames += Get-Help -Category 'Cmdlet'   | where {$_.Category -ne 'Alias'} | Sort Name
$helpNames += Get-Help -Category 'Provider' | Sort Name

foreach ($helpTopic in $helpNames) {
	if (!$NoProgress) {
		Write-Progress -Activity "Searching help for '$Pattern'" -Status 'Progress:' `
		               -CurrentOp "$($helpTopic.Category): $($helpTopic.Name)" `
			           -PercentComplete ($i++/$helpNames.Count*100)
	}
	
    $content = get-help -Full $helpTopic.Name | Out-String
    
    if ($content -match $Pattern) {
        $helpTopic | select Name,Synopsis
        
        if ($Verbose) {
            $content | %{$_.Split([System.Environment]::NewLine)} |
                Select-String $Pattern | %{"    $($_.Line.Trim())"}
        }
    }
}