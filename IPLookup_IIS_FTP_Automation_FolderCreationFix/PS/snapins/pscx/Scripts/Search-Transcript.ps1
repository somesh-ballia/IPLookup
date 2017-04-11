# ---------------------------------------------------------------------------
### <Script>
### <Author>Keith Hill</Author>
### <Description>
### Searches your session transcript files for the specified pattern.
### </Description>
### <Usage>Search-Transcript fxml</Usage>
### </Script>
# ---------------------------------------------------------------------------
param([string]$Pattern = $(throw "You must specify a search pattern.  Type 'Search-Transcript ?' for usage."),
      [switch]$CurrentOnly = $false, 
      [switch]$SimpleMatch = $false, 
      [switch]$List = $false, 
      [switch]$NoCompact = $false,
      [switch]$PassThru = $false) 

if ($Pattern -eq '?') {
    ""
    "Usage: Search-Transcript -Pattern [-CurrentOnly] [-SimpleMatch] [-List] [-PassThru] [-NoCompact]"
    "  Parameters:"
    "    -Pattern     : Pattern to match which is a regex pattern"
    "    -CurrentOnly : Searches just the current transcript file"
    "    -SimpleMatch : Do not interpret Pattern as a regex"
    "    -List        : Just list transcript filenames that match pattern instead of each line"
    "    -PassThru    : Passes the MatchInfo object down the pipeline"
    "    -NoCompact   : Prevents multiple whitespace characters from being compacted to a single space"
    "    ?            : Display this usage information"
    ""
    return
}

# Determine full path to transcript dir
$TranscriptDir = Split-Path $Pscx:Session['TranscribeSession/TranscriptPath'] -parent

# Don't log any of the search activity to the transcript because it results in
# confusion when the results of previous searches turn up in the current search results.
Stop-Transcript > $null
	
# Trap any errors in the following nested scope so that we can be assured of starting
# the transcript back up.
trap {"Trapped error: $_; continue"}
&{
	$transcriptFiles = @($PscxTranscriptPath)
	if (!$CurrentOnly) {
		$transcriptFiles += get-childitem $TranscriptDir\*.txt -Exclude $PscxTranscriptPath
	}
		
	$results = Select-String $Pattern -Path $transcriptFiles -SimpleMatch:$SimpleMatch -List:$List
	if ($PassThru) {
		$results
	}
	else {
		foreach ($result in $results) {
			$path = $result.Path
			if ($List) {
				$path
			}
			else {
				if ($NoCompact) {
					$line = $result.line
				}
				else {
					$line = $result.Line -replace '\s+', ' '
				}
				"{0}:{1:0####} {2}" -f (split-path $path -leaf), $result.LineNumber, $line.TrimEnd()
			}
		}
	}
}

Start-Transcript $Pscx:Session['TranscribeSession/TranscriptPath'] -Append > $null