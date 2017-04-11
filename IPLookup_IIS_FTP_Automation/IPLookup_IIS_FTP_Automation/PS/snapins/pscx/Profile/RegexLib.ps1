# ---------------------------------------------------------------------------
# Author: Keith Hill
# Desc:   Creates a PowerShell custom object pre-populated with common regex
#         patterns.  This library is admittedly weak at the moment but my
#         hope is that folks will contribute to flesh it out.
# Site:   http://pscx.codeplex.com
# Usage:  In your profile place the following command:
#  
#         . "$Env:PscxHome\Profile\RegexLib.ps1"
#
#         Then use like so:
#
#         foreach ($file in (gci -r -filter *.[ch])) {
#             switch -regex -file ($file.PSPath) { 
#                 $regexlib.CComment { $matches.CComment }
#             }
#         }
# ---------------------------------------------------------------------------
& {
	$RegexLib = new-object psobject
	
	function AddRegex($name, $regex) {
	  Add-Member -Input $RegexLib NoteProperty $name $regex
	}

	AddRegex CDQString           '(?<CDQString>"\\.|[^\\"]*")'
	AddRegex CSQString           "(?<CSQString>'\\.|[^'\\]*')"
	AddRegex CMultilineComment   '(?<CMultilineComment>/\*[^*]*\*+(?:[^/*][^*]*\*+)*/)'
	AddRegex CppEndOfLineComment '(?<CppEndOfLineComment>//[^\n]*)'
	AddRegex CComment            "(?:$($RegexLib.CDQString)|$($RegexLib.CSQString))|(?<CComment>$($RegexLib.CMultilineComment)|$($RegexLib.CppEndOfLineComment))"

	AddRegex PSComment          '(?<PSComment>#[^\n]*)'
	AddRegex PSNonCommentedLine '(?<PSNonCommentedLine>^(?>\s*)(?!#|$))'

	AddRegex EmailAddress       '(?<EmailAddress>[A-Z0-9._%-]+@(?:[A-Z0-9-]+\.)+[A-Z]{2,4})'
	AddRegex IPv4               '(?<IPv4>)(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))'
	AddRegex RepeatedWord       '\b(?<RepeatedWord>(\w+)\s+\1)\b'
	AddRegex HexDigit           '[0-9a-fA-F]'
	AddRegex HexNumber          '(?<HexNumber>(0[xX])?[0-9a-fA-F]+)'
	AddRegex DecimalNumber      '(?<DecimalNumber>[+-]?(?:\d+\.?\d*|\d*\.?\d+))'
	AddRegex ScientificNotation '(?<ScientificNotation>[+-]?(?<Significand>\d+\.?\d*|\d*\.?\d+)[\x20]?(?<Exponent>[eE][+\-]?\d+)?)'

	$Pscx:RegexLib = $RegexLib
}