# ---------------------------------------------------------------------------
### <Script>
### <Author>jachymko</Author>
### <Description>
### Returns manager of the specified Active Directory user.
### </Description>
### <Remarks>
### To get all all managers in the hierarchy, specify the -Recurse switch.
### </Remarks>
### <Usage>
### Get-Manager EUROPE:\UserAccounts\jachymko
### Get-Manager EUROPE:\UserAccounts\jachymko -Recurse
### </Usage>
### </Script>
# ---------------------------------------------------------------------------
param ($Path, [switch]$Recurse)

trap { break }
$current = Get-Item "$path"

do
{
	$current = (Get-ItemProperty $current).Manager
	$current
}
while($current -and $Recurse)
