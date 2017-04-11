
start-PortPsSnapinConfiguration
$base = [system.io.path]::Getdirectoryname([system.reflection.assembly]::getcallingassembly().Location)

if (! (test-path HKLM:\SOFTWARE\Microsoft\PowerShell\1\PowerShellSnapIns\pscx)) { 
md HKLM:\SOFTWARE\Microsoft\PowerShell\1\PowerShellSnapIns\pscx
}

Set-ItemProperty HKLM:\SOFTWARE\Microsoft\PowerShell\1\PowerShellSnapIns\pscx -name "ApplicationBase" -value "$base\snapins\pscx"

Set-ItemProperty HKLM:\SOFTWARE\Microsoft\PowerShell\1\PowerShellSnapIns\pscx -name "ModuleName" -value "$base\snapins\pscx\pscx.dll"

Set-ItemProperty HKLM:\SOFTWARE\Microsoft\PowerShell\1\PowerShellSnapIns\pscx -name "PowerShellVersion" -value "1.0"

Set-ItemProperty HKLM:\SOFTWARE\Microsoft\PowerShell\1\PowerShellSnapIns\pscx -name "Vendor" -value "Powershell commmunity"
Set-ItemProperty HKLM:\SOFTWARE\Microsoft\PowerShell\1\PowerShellSnapIns\pscx -name "Version" -value "1.2.0.0"

&{
$local:ofs = [char]0;
New-ItemProperty HKLM:\SOFTWARE\Microsoft\PowerShell\1\PowerShellSnapIns\pscx  -force -propertyType multistring -name "Formats" -value $([string]("FormatData\ArchiveEntry.ps1xml" , "FormatData\DirectoryServices.ps1xml" , "FormatData\Net.ps1xml" ,"FormatData\Pscx.ps1xml" ,"FormatData\TerminalServices.ps1xml")) | out-null
New-ItemProperty HKLM:\SOFTWARE\Microsoft\PowerShell\1\PowerShellSnapIns\pscx  -force -propertyType multistring -name "Types" -value $([string]("TypeData\ArchiveEntry.ps1xml","TypeData\DateTime.ps1xml","TypeData\DirectoryServices.ps1xml","TypeData\FeedStore.ps1xml","TypeData\Net.ps1xml","TypeData\Reflection.ps1xml","TypeData\ScriptBlock.ps1xml","TypeData\TerminalServices.ps1xml","TypeData\FileSystemV1.ps1xml")) | out-null
}
Set-ItemProperty HKLM:\SOFTWARE\Microsoft\PowerShell\1\PowerShellSnapIns\pscx -name "AssemblyName" -value "Pscx, Version=1.2.0.0, Culture=neutral, PublicKeyToken=null"
Set-ItemProperty HKLM:\SOFTWARE\Microsoft\PowerShell\1\PowerShellSnapIns\pscx -name "Description" -value "PowerShell Community Extensions (PSCX) base snapin which implements a general purpose set of cmdlets."
stop-PortPsSnapinConfiguration
add-pssnapin pscx