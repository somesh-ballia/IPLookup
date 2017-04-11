strComputer="ct-n0060"
strUserLogin="ct-n0060\maven"
strDomain=""
strPassword="impetus"

Foldername="d:\Test"    'folder to share 
sharename="Test_Share"    'Share Name 
strDesc="Test Share"    'Share Description 
strUser="ct"        'User to set permissions for 
 
 
Set SWBemlocator = CreateObject("WbemScripting.SWbemLocator")
Set objWMIService = SWBemlocator.ConnectServer(strComputer,"root\CIMV2",strUserLogin, strPassword)
SWBemlocator.Security_.ImpersonationLevel = 3
If Err.Number<>"0" Then WScript.Echo "Cannot find machine: "& strComputer & WScript.Quit

Set  Services = objWMIService
' Connects to the WMI service with security privileges 
Set SecDescClass = Services.Get("Win32_SecurityDescriptor") 
' Need an instance of the Win32_SecurityDescriptor so we can create an instance of a Security Descriptor. 
Set SecDesc = SecDescClass.SpawnInstance_() 
' Create an instance of a Security Descriptor. 
Set colWinAcc = Services.ExecQuery("SELECT * FROM Win32_ACCOUNT WHERE Name='" & strUser & "'") 
If colWinAcc.Count < 1 Then 
    Wscript.echo("User " & strUser & "Not Found - quitting") 
    wscript.quit 
End If 
' Find the WMI representation of a particular Windows Account 
For Each refItem in colWinAcc 
    Set refSID = Services.Get("Win32_SID='" & refItem.SID & "'") 
    ' Get the SID for the choosen Windows account. 
Next 
Set refTrustee = Services.Get("Win32_Trustee").spawnInstance_() 
' Creates an instance of a Windows Security Trustee (usually a user but anything with a SID I guess...) 
With refTrustee 
    .Domain = refSID.ReferencedDomainName 
    .Name = refSID.AccountName 
    .SID = refSID.BinaryRepresentation 
    .SidLength = refSID.SidLength 
    .SIDString = refSID.SID 
End With 
' Sets the trustee object up with the SID & all that malarkey from the user object we have choosen to work on 
Set ACE = Services.Get("Win32_Ace").SpawnInstance_ 
' Creates an instance of an Access Control Entry Object(this will be one entry on the access list on an object) 
ACE.Properties_.Item("AccessMask") = 2032127 
' This is full Control     ' This is full Control (bitflag) full list here: http://msdn.microsoft.com/library/default.asp?

ACE.Properties_.Item("AceFlags") = 3 
' what to apply ACE to inc inhehitance 3 - means files & folders get permssions & pass onto children 
ACE.Properties_.Item("AceType") = 0 
' 0=allow access 1=deny access 
ACE.Properties_.Item("Trustee") = refTrustee 
' Set the Trustee (user) that this Access control Entry will refer to. 
SecDesc.Properties_.Item("DACL") = Array(ACE) 
' Get the DACL property of the Security Descriptor object 
' Add the ACE to the Dynamic Access Control List on the object (an array) it will overwrite the old entries  
' unless you retreive & save 'em first & add them to a big array with the new entry as well as the old ones 
Set Share = Services.Get("Win32_Share") 
' Get a WMI share Object 
Set InParam = Share.Methods_("Create").InParameters.SpawnInstance_() 
' Create an instance of a WMI input Parameters object 
InParam.Properties_.Item("Access") = SecDesc 
' Set the Access Parameter to the Security Descriptor Object we configured above 
InParam.Properties_.Item("Description") = strDesc 
InParam.Properties_.Item("Name") = ShareName 
InParam.Properties_.Item("Path") = FolderName 
InParam.Properties_.Item("Type") = 0 
Set outParams=Share.ExecMethod_("Create", InParam) 
 
' Create the share with all the parameters we have set up 
wscript.echo("OUT: " & outParams.returnValue) 
If outParams.returnValue <> 0 Then 
    wscript.echo("Failed to Create Share, return Code:" & outParams.returnValue) 
Else 
    wscript.echo("Folder " & Foldername & " sucessfully shared as: " & sharename & " with FULL CONTROL Permissions for user " & strUser) 
End If 