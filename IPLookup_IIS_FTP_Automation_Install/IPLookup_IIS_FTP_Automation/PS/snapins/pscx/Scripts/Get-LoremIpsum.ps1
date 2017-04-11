# ---------------------------------------------------------------------------
### <Script>
### <Author>jachymko</Author>
### <Description>
### Lorem ipsum generator.
### </Description>
### <Remarks>
### This version of Lorem Ipsum was written by jachymko. It's a PowerShell port of
### a JavaScript version by Will Munslow (http://subterrane.com), who completly 
### re-wrote a version by Captain Cursor, aka Taylor (http://www.captaincursor.com/), 
### originally distributed as a Dreamweaver extension and later adapted by Travis 
### Spencer (http://travisspencer.com/).
### </Remarks>
### <Usage>
### Get-LoremIpsum
### Get-LoremIpsum 20 -Language Spanish
### </Usage>
### </Script>
# ---------------------------------------------------------------------------
param(
	$Length = 1,
	[switch] $Chars, 
	[switch] $Words, 
	[switch] $Paragraphs = $true,
	[string] $Language = 'Latin'	
)

if ($args -eq '-?') {
    ""
    "Usage: Get-LoremIpsum [[-Length] <object>] [[-Chars] <switch>] [[-Words] <switch>] " +
                          "[[-Paragraphs] <switch>] [[-Language] <string>]"
    ""
    "Parameters:"
    "    -Length     : The number of chars, words, paragraphs to display (default is 1)"
    "    -Chars      : Apply length parameter to number of characters to display"
    "    -Words      : Apply length parameter to number of words to display"
    "    -Paragraphs : Apply length parameter to number of paragraphs to display (default)"
    "    -Language   : The language to use: Latin (default), Silly, Spanish or Italian"
    "    -?          : Display this usage information"
    ""
    return
}

$Lorem = @{}
$Lorem['Latin'] = (
	'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.',
	'Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.',
	'Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi.',
	'Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat.',
	'Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis.',
	'At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, At accusam aliquyam diam diam dolore dolores duo eirmod eos erat, et nonumy sed tempor et et invidunt justo labore Stet clita ea et gubergren, kasd magna no rebum. sanctus sea sed takimata ut vero voluptua. est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat.',
	'Consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus.'
)
$Lorem['Silly'] = (
	'Epsum factorial non deposit quid pro quo hic escorol. Olypian quarrels et gorilla congolium sic ad nauseum. Souvlaki ignitus carborundum e pluribus unum. Defacto lingo est igpay atinlay. Marquee selectus non provisio incongruous feline nolo contendre. Gratuitous octopus niacin, sodium glutimate. Quote meon an estimate et non interruptus stadium.',
	'Sic tempus fugit esperanto hiccup estrogen. Glorious baklava ex librus hup hey ad infinitum. Non sequitur condominium facile et geranium incognito. Epsum factorial non deposit quid pro quo hic escorol. Marquee selectus non provisio incongruous feline nolo contendre Olypian quarrels et gorilla congolium sic ad nauseum. Souvlaki ignitus carborundum e pluribus unum.',
	'Defacto lingo est igpay atinlay. Marquee selectus non provisio incongruous feline nolo contendre. Gratuitous octopus niacin, sodium glutimate. Quote meon an estimate et non interruptus stadium. Sic tempus fugit esperanto hiccup estrogen. Glorious baklava ex librus hup hey ad infinitum. Non sequitur condominium facile et geranium incognito. Epsum factorial non deposit quid pro quo hic escorol. Olypian quarrels et gorilla congolium sic ad nauseum. Souvlaki ignitus carborundum e pluribus unum. Defacto lingo est igpay atinlay. Gratuitous octopus niacin, sodium glutimate.',
	'Quote meon an estimate et non interruptus stadium. Sic tempus fugit esperanto hiccup estrogen. Glorious baklava ex librus hup hey ad infinitum. Non sequitur condominium facile et geranium incognito goo goo ga joob.'
)
$Lorem['Spanish'] = (
	'Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc., li tot Europa usa li sam vocabularium. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilit&aacute; de un nov lingua franca: on refusa continuar payar custosi traductores. It solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles.'
)
$Lorem['Italian'] = (
	'Ma quande lingues coalesce, li grammatica del resultant lingue es plu simplic e regulari quam ti del coalescent lingues. Li nov lingua franca va esser plu simplic e regulari quam li existent Europan lingues. It va esser tam simplic quam Occidental: in fact, it va esser Occidental. A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es.'
)	

$CurrentLorem = $Lorem[$Language]

if( $Chars) {
	$output = new-object Text.StringBuilder $Length
	$temp = [string]::Join("`n`n", $CurrentLorem)
	
	while ($output.Length -lt $Length) {
		[void]$output.Append($temp)
	}
	
	if ($output.Length -gt $Length) {
		$output.Length = $Length
	}
	
	return $output.ToString()
}

if ($Words) {
	$output = @()
	$wordList = $CurrentLorem.Split(' ')
	
	$paraCount = 0;
	$wordCount = 0;
	
	while ($output.Length -lt $Length) {
		if ($wordCount -gt $wordList.Length) {
			$wordCount = 0
			$paraCount = ($paraCount+1) % $CurrentLorem.Length
			
			$wordList = $CurrentLorem[$paraCount].Split(' ')
			$wordList[0] = "`n`n" + $wordList[0]
		}
		
		$output += $wordList[$wordCount++]
	}
	
	return [string]::Join(' ', $output)
}

if ($Paragraphs) {
	$output = @()
	
	while($output.Length -lt $Length) {
		$output += $CurrentLorem[$output.Length % $CurrentLorem.Length] 		
	}
	
	return [string]::Join("`n`n", $output)
}