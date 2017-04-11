strUserLogin = "CT-N0060\maven"
strUser = "maven"
strPassword = "impetus"
strMachine = "CT-N0060"
strNewFolder = "d:\iplookup1\dump"
strShareName= "PCAP_dump"
strShareDesc = "dump for iplookup"

CreateShare strUserLogin,strUser,strPassword,strMachine,strNewFolder,strShareName,strShareDesc

Function CreateShare(strUserLogin,strUser,strPassword,strComputer,strNewFolder,strShareName,strShareDesc)
	
	Set SWBemlocator = CreateObject("WbemScripting.SWbemLocator")	
	Set objWMIService = SWBemlocator.ConnectServer(strComputer,"root\CIMV2",strUserLogin, strPassword)
	SWBemlocator.Security_.ImpersonationLevel = 3
	If Err.Number<>"0" Then 
		Wscript.echo " ERROR CONNECTION_FAILED"
	ELSE
		Wscript.echo " NOTIFICATION CONNECTION_SUCCESSFUL"
		
		Wscript.echo " NOTIFICATION CREATING_FOLDER"
		Set objWMIServiceFolder = objWMIService.get("Win32_Process")
		errReturn = objWMIServiceFolder.Create("cmd.exe /c md "&strNewFolder, Null, Null, intProcessID)
		If 0 = errReturn Then
			Wscript.echo " NOTIFICATION FOLDER_CREATION_SUCCESSFUL"		
			Wscript.echo " NOTIFICATION SHARING_FOLDER"		
			IF True = ShareFolder(objWMIService,strUser,strNewFolder,strShareName,strShareDesc) Then
				Wscript.echo "Log.vbs NOTIFICATION FOLDER_SHARING_SUCCESSFUL"		
			Else
				Wscript.echo "Log.vbs ERROR FOLDER_SHARING_FAILED"
			End IF
		Else
			Wscript.echo "Log.vbs ERROR FOLDER_CREATION_FAILED"
		End IF
	END If
	Wscript.echo "Log.vbs DEBUG EXIT_CreateFolders_INSTALL_CreateShareFolder"
		
End Function	

Function ShareFolder(objWMIService,strUser,strNewFolder,strShareName,strShareDesc)
	
		Set  Services = objWMIService
		' Connects to the WMI service with security privileges 
		Set SecDescClass = Services.Get("Win32_SecurityDescriptor") 
		' Need an instance of the Win32_SecurityDescriptor so we can create an instance of a Security Descriptor. 
		Set SecDesc = SecDescClass.SpawnInstance_() 
		' Create an instance of a Security Descriptor. 
		Set colWinAcc = Services.ExecQuery("SELECT * FROM Win32_ACCOUNT WHERE Name='" & strUser & "'") 
		If colWinAcc.Count < 1 Then 
			Wscript.echo("User " & strUser & "Not Found") 
			'wscript.quit 
			objShell.Run "Log.vbs ERROR USER_NAME_NOT_FOUND"
			ShareFolder = False
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
		InParam.Properties_.Item("Description") = strShareDesc
		InParam.Properties_.Item("Name") = strShareName 
		InParam.Properties_.Item("Path") = strNewFolder 
		InParam.Properties_.Item("Type") = 0 
		Set outParams=Share.ExecMethod_("Create", InParam)  
		' Create the share with all the parameters we have set up 
		wscript.echo("OUT: " & outParams.returnValue) 	
		If outParams.returnValue <> 0 Then 
			wscript.echo("Failed to Create Share, return Code:" & outParams.returnValue) 
			ShareFolder = False
		Else 
			wscript.echo("Folder " & strNewFolder & " sucessfully shared as: " & strShareName & " with FULL CONTROL Permissions for user " & strUserLogin) 
			ShareFolder = True
		End If 		
End Function
