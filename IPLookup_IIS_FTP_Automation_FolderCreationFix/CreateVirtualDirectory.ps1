$PSiteName = $args[0]
$PVDName = $args[1]
$PRemotePath = $args[2]
$PUserName = $args[3]
$PPassword = $args[4]

Function CreateVirtualDirectory($SiteName,$VDName,$RemotePath,$UserName,$Password)	{
$message = "ENTER_POWERSHELL_CreateVirtualDirectory()"
LogDebug -message $message

Trap	
	{
		$message = "VIRTUAL_DIRECTORY_CREATION_FAILED_VDNAME=_" +$VDName + "___REMOTE_PATH_=_"+$RemotePath   
		LogProgress -message $message
		LogError -message $message
		$message = "EXIT_POWERSHELL_CreateVirtualDirectory()"
		LogDebug -message $message

		EXIT -1
	}	
	
	$server = $env:computername 
	
	$service = New-Object System.DirectoryServices.DirectoryEntry("IIS://$server/MSFTPSVC") 

	$site = $service.psbase.children |Where-Object { $_.ServerComment -eq $SiteName } 
	
	$site = New-Object System.DirectoryServices.DirectoryEntry($site.psbase.path+"/Root") 
	
	$virtualdir = $site.psbase.children.Add($VDName,"IIsFtpVirtualDir") 
	
	$virtualdir.psbase.CommitChanges() 
	
	$virtualdir.put("Path",$RemotePath)
	
	$virtualdir.put("UNCUserName",$UserName)
	
	$virtualdir.put("UNCPassword",$Password)
	
	$virtualdir.put("AccessRead",$true)		
	
	$virtualdir.put("AccessWrite",$true)	
	
	$virtualdir.psbase.CommitChanges()		
	
	$service.psbase.refreshCache()				
	
	$message = "VIRTUAL_DIRECTORY_CREATION_SUCCESSFUL_VDNAME=_" +$VDName + "___REMOTE_PATH_=_"+$RemotePath   
	LogProgress -message $message
	LogError -message $message
	$message = "EXIT_POWERSHELL_CreateVirtualDirectory()"
	LogDebug -message $message
	
	EXIT 0	
}

Function LogProgress($message)
{
	$FullMessage = "PROGRESS , " + $message
	1..1| % { $FullMessage >> "Progress.txt" }
}

Function LogError($message)
{
	$FullMessage = "NOTIFICATION , " + $message
	1..1| % { $FullMessage >> "Log.txt" }
}

Function LogDebug($message)
{
	$FullMessage = "DEBUG , " + $message
	1..1| % { $FullMessage >> "Log.txt" }
}

CreateVirtualDirectory -SiteName $PSiteName -VDName $PVDName -RemotePath $PRemotePath -UserName $UserName -Password $PPassword


