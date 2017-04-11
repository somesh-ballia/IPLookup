# ---------------------------------------------------------------------------
### <Script>
### <Author>jachymko</Author>
### <Description>
### Functions to generate HTML "screen shot" of the host buffer.
### </Description>
### <Usage>
### Get-ScreenHtml
### Get-ScreenHtml 25
### </Usage>
### </Script>
# ---------------------------------------------------------------------------
param($Count = $Host.UI.RawUI.WindowSize.Height)

function BuildHtml($out, $buff) {
	function OpenElement($out, $fore, $back) {
		& { 
			$out.Append('<span class="F').Append($fore)
			$out.Append(' B').Append($back).Append('">')
		} | out-null
	}
	
	function CloseElement($out) {
		$out.Append('</span>') | out-null
	}


	$height = $buff.GetUpperBound(0)
	$width = $buff.GetUpperBound(1)
	
	$prev = $null
	$whitespaceCount = 0
	
	$out.Append("<pre class=`"B$($Host.UI.RawUI.BackgroundColor)`">") | out-null
	
	for($y = 0; $y -lt $height; $y++) {
		for($x = 0; $x -lt $width; $x++) {
			
			$current = $buff[$y, $x] 
		
			if($current.Character -eq ' ') {
				$whitespaceCount++
				write-debug "whitespaceCount: $whitespaceCount"
			}
			else {
				if($whitespaceCount) {
					write-debug "appended $whitespaceCount spaces, whitespaceCount: 0"					
					$out.Append((new-object string ' ', $whitespaceCount)) | out-null
					$whitespaceCount = 0
				}
	
				if((-not $prev) -or 
				   ($prev.ForegroundColor -ne $current.ForegroundColor) -or
				   ($prev.BackgroundColor -ne $current.BackgroundColor)) {
				
					if($prev) { CloseElement $out }
					
					OpenElement $out $current.ForegroundColor $current.BackgroundColor
				} 
						
                $char = [System.Web.HttpUtility]::HtmlEncode($current.Character)

				write-debug "appending $char; prev = $($prev.ForegroundColor)/$($prev.BackgroundColor); current = $($current.ForegroundColor)/$($current.BackgroundColor)"
				$out.Append($char) | out-null

				$prev =	$current	
			}
		}
		
		$out.Append("`n") | out-null
		$whitespaceCount = 0
	}
	
	if($prev) { CloseElement $out }
	
	$out.Append('</pre>') | out-null
} 

# Required by HttpUtility
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Web")

$raw = $Host.UI.RawUI
$buffsz = $raw.BufferSize
$cursor = $raw.CursorPosition

$rect = new-object Management.Automation.Host.Rectangle 0, ($cursor.Y - $Count), $buffsz.Width, $cursor.Y
$buff = $raw.GetBufferContents($rect)

$out = new-object Text.StringBuilder
BuildHtml $out $buff
$out.ToString()