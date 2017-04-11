param($machine, $processName) 

Get-WmiObject `
	-ComputerName $machine `
	-Class Win32_Process `
	-Filter "Name LIKE '%$processName%'" |% `
{
	if ($_.Terminate().ReturnValue -ne 0)
	{
		Write-Error "Failed to terminate $processName on $machine."
	}
}
