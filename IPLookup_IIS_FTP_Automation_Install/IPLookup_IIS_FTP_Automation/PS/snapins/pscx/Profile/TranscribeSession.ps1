# ---------------------------------------------------------------------------
# Author: Misc, most inspired by ~Clint, Alex Angelopoulos and Andrew Watt
# Desc:   Logs each PowerShell session via the Start-Transcipt functionality
#         to a unique filename in the Transcripts subdir of your 
#         WindowsPowerShell user directory.
# Site:   http://pscx.codeplex.com
# Usage:  In your profile place the following command:
#  
#         . "$Pscx:ProfileDir\TranscribeSession.ps1"
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Transcribe is only supported in console host.
# Only execute this code once per PowerShell session.  
# ---------------------------------------------------------------------------
if (($Host.Name -ne 'ConsoleHost') -or $Pscx:Session['DotSourced\TranscribeSession.ps1']) 
{ 
	return
}

& {
	$Pscx:Session['DotSourced\TranscribeSession.ps1'] = $true
	
	# Create Transcripts dir under user's profile directory
	$TranscriptDir = Join-Path (Split-Path $Profile -Parent) Transcripts
	if (!(test-path $TranscriptDir)) {
		New-Item $TranscriptDir -ItemType Directory > $null
	}

	$TranscriptFile = "{0}-{1:0###}.txt" -f (Get-Date -Format yyyyMMdd-HHmm), $PID
	$Pscx:Session['TranscribeSession/TranscriptPath'] = Join-Path $TranscriptDir $TranscriptFile
	Start-Transcript $Pscx:Session['TranscribeSession/TranscriptPath']
}
