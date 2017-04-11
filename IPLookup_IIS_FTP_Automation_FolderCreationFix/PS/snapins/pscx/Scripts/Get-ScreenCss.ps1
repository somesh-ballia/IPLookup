# ---------------------------------------------------------------------------
### <Script>
### <Author>jachymko</Author>
### <Description>
### Generate CSS header for HTML "screen shot" of the host buffer.
### </Description>
### <Usage>$css = Get-ScreenCss</Usage>
### </Script>
# ---------------------------------------------------------------------------
'<style>'

[Enum]::GetValues([ConsoleColor]) | Foreach {
	"`t.F$_ { color: $_; }"
	"`t.B$_ { background-color: $_; }"
}

'</style>'