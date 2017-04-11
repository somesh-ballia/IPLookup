# ---------------------------------------------------------------------------
### <Script>
### <Author>Keith Hill</Author>
### <Description>
### This script scrapes the web page of the supplied web URL and 
### outputs a string containing the contents of the web page.
### </Description>
### <Usage>Get-Url http://pscx.codeplex.com/Project/ProjectRss.aspx</Usage>
### </Script>
# ---------------------------------------------------------------------------
param([string]$Url)

function Usage {
	""
	"Usage: Get-Url [-Url] <string>"
	""
	"Parameters:"
	"    -Url : Url of web page to download"
	"    -?   : Display this usage information"
	""
	exit
}
     
if ($args -eq '-?') {
	Usage
}

if (!$Url) {
	Write-Error "Please specify a url to download."
	Usage
}

$webClient = new-object System.Net.WebClient
$webClient.DownloadString($Url)