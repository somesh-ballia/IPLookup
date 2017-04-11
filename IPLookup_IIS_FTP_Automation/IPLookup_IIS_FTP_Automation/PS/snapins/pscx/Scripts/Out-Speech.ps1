# ---------------------------------------------------------------------------
### <Script>
### <Author>
### Joel "Jaykul" Bennett
### </Author>
### <Description>
### Outputs text as spoken words
### </Description>
### <Usage>
### Out-Speech "Hello World"
### </Usage>
### </Script>
# ---------------------------------------------------------------------------
param([array]$Collection, [switch]$Wait, [switch]$Purge, [switch]$ReadFiles, [switch]$ReadXml, [switch]$NotXml)
 
begin {  
	if ($args -eq '-?') {
		''
		'Usage: Out-Speech [[-Collection] <array>]'
		''
		'Parameters:'
		'    -Collection : A collection of items to speak.'
		'    -?          : Display this usage information'
		'  Switches:'
		'    -Wait       : Wait for the machine to read each item (NOT asynchronous).'
		'    -Purge      : Purge all other speech requests before making this call.'
		'    -ReadFiles  : Read the contents of the text files indicated.'
		'    -ReadXml    : Treat input as speech XML markup.'
		'    -NotXml     : Do NOT parse as XML (if text starts with "<" but is not XML).'
		''
		'Examples:'
		'    PS> Out-Speech "Hello World"'
		'    PS> Select-RandomLine quotes.txt | Out-Speech -wait'
		'    PS> Out-Speech -readfiles "Hitchhiker''s Guide To The Galaxy.txt"'
		''
		exit
	}
    
	# To override this default, use the other flag values given below.
	$SPF_DEFAULT = 0          # Specifies that the default settings should be used.  
	## The defaults are:
	#~ * Speak the given text string synchronously
	#~ * Not purge pending speak requests
	#~ * Parse the text as XML only if the first character is a left-angle-bracket (<)
	#~ * Not persist global XML state changes across speak calls
	#~ * Not expand punctuation characters into words.
	$SPF_ASYNC = 1            # Specifies that the Speak call should be asynchronous.
	$SPF_PURGEBEFORESPEAK = 2 # Purges all pending speak requests prior to this speak call.
	$SPF_IS_FILENAME = 4      # The string passed is a file name, and the file text should be spoken.
	$SPF_IS_XML = 8           # The input text will be parsed for XML markup. 
	$SPF_IS_NOT_XML= 16       # The input text will not be parsed for XML markup.
  
	$SPF = $SPF_DEFAULT
	if (!$wait)    { $SPF += $SPF_ASYNC }
	if ($purge)    { $SPF += $SPF_PURGEBEFORESPEAK }
	if ($readfiles){ $SPF += $SPF_IS_FILENAME }
	if ($readxml)  { $SPF += $SPF_IS_XML }
	if ($notxml)   { $SPF += $SPF_IS_NOT_XML }

	$Voice = new-object -com SAPI.SpVoice

	if ($collection.count -gt 0) {
		foreach( $item in $collection ) {
			$exit = $Voice.Speak(($item | out-string), $SPF)
		}
	}
}
 
process {
	if ($_) {
		$exit = $Voice.Speak(($_ | out-string), $SPF)
	}
}
