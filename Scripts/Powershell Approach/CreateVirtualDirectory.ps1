$server = $env:computername
$service = New-Object System.DirectoryServices.DirectoryEntry("IIS://$server/MSFTPSVC")
$site = $service.psbase.children |Where-Object { $_.ServerComment -eq 'Default FTP Site' }
$site = New-Object System.DirectoryServices.DirectoryEntry($site.psbase.path+"/Root") # <-- IIS 6 requires this. Not sure why. Otherwise, it never appears to commit changes. This line is not required for IIS 7.
$virtualdir = $site.psbase.children.Add("NewUser","IIsFtpVirtualDir")
$virtualdir.psbase.CommitChanges()
$virtualdir.put("Path","\\192.168.129.110\share")
$virtualdir.put("UNCUserName","Administrator")
$virtualdir.put("UNCPassword","none")
$virtualdir.put("AccessRead",$true)
$virtualdir.put("AccessWrite",$true)
$virtualdir.psbase.CommitChanges()
$service.psbase.refreshCache() # OPTIONAL