# ---------------------------------------------------------------------------
### <Function name='Get-TabExpansion'>
### <Author>jachymko</Author>
### <Description>
### TabExpansion enhances the built-in tab expansion feature of PowerShell.  
### This function does nothing more than call the PSCX cmdlet Get-TabExpansion.
### NOTE: This function is invoked by PowerShell.  You shouldn't need to invoke
### it directly.
### </Description>
### <Usage>
### Place the following command in your profile if it isn't present:
### . "$Pscx:ProfileDir\TabExpansion.ps1"
### </Usage>
### </Function>
# ---------------------------------------------------------------------------
function TabExpansion($line, $lastWord) {
	Get-TabExpansion $line $lastWord
}