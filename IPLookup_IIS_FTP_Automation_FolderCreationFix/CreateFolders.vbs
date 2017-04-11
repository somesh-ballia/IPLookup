Dim objShell
Set objShell = Wscript.CreateObject("WScript.Shell")
strConfigFileName = "Config.ini"
Dim NUMBER_OF_CPS
Dim CPS_NAME(100)
Dim DUMP_FOLDER_PATH(100)
Dim HOST_DUMP_FOLDER_PATH
Dim USER_NAME
Dim PASSWORD 
Dim SHARE_NAME
Dim DUMP_FOLDER_NAME
Dim SHARE_DESCRIPTION

Execute()

Function Execute()	
	
	objShell.Run "Log.vbs DEBUG ENTER_CreateFolders_Execute()",0,true	
	ParseConfig()
		
	strShareName = SHARE_NAME
	strNewFolder = HOST_DUMP_FOLDER_PATH&"\"&strShareName
	strUserName = USER_NAME		
	objShell.Run "Log.vbs NOTIFICATION CREATING_LOCAL_FOLDER_=_"&strNewFolder,0,true
	objShell.Run "Log.vbs PROGRESS CREATING_LOCAL_FOLDER_=_"&strNewFolder,0,true

	If True = CreateShareFolderLocal (strUserName,strNewFolder,strShareName,SHARE_DESCRIPTION) Then
		objShell.Run "Log.vbs NOTIFICATION CREATING_LOCAL_FOLDER_SUCCESSFUL_=_"&strNewFolder,0,true
		objShell.Run "Log.vbs PROGRESS CREATING_LOCAL_FOLDER_SUCCESSFUL_=_"&strNewFolder,0,true
	Else
		objShell.Run "Log.vbs NOTIFICATION CREATING_LOCAL_FOLDER_FAILURE_=_"&strNewFolder,0,true
		objShell.Run "Log.vbs PROGRESS CREATING_LOCAL_FOLDER_FAILURE_=_"&strNewFolder,0,true
	End If
	
	for iCount = 0 To NUMBER_OF_CPS-1
		objShell.Run "Log.vbs NOTIFICATION PINGINIG_MACHINE_"&CPS_NAME(iCount),0,true
		objShell.Run "Log.vbs PROGRESS PINGINIG_MACHINE_"&CPS_NAME(iCount),0,true
		
		strShareName = SHARE_NAME
		wscript.echo SHARE_NAME
		
		if True = PingSuccess(CPS_NAME(iCount)) Then
			Dim strUserLogin
			Dim strTemp
			Dim strNewFolder
			objShell.Run "Log.vbs NOTIFICATION PING_SUCCESSFUL_"&CPS_NAME(iCount),0,true
			objShell.Run "Log.vbs PROGRESS PING_SUCCESSFUL_"&CPS_NAME(iCount),0,true
			strUserLogin = CPS_NAME(iCount) &"\" & USER_NAME			 
						
			strTemp = Clean(DUMP_FOLDER_PATH(iCount))&"\"&DUMP_FOLDER_NAME
			strNewFolder = """"&strTemp&""""
			
			'wscript.echo strUserLogin
			'wscript.echo strNewFolder
			If True = CreateShareFolder (CPS_NAME(iCount),strUserLogin,USER_NAME,PASSWORD,strNewFolder,strShareName,SHARE_DESCRIPTION) Then
				objShell.Run "Log.vbs NOTIFICATION FOLDER_CREATION_AND_SHARING_SUCCESSFUL"
				objShell.Run "Log.vbs PROGRESS FOLDER_CREATION_AND_SHARING_SUCCESSFUL"
			Else
				objShell.Run "Log.vbs NOTIFICATION FOLDER_CREATION_AND_SHARING_FAILURE"
				objShell.Run "Log.vbs PROGRESS FOLDER_CREATION_AND_SHARING_FAILURE"
			End If
		Else
			objShell.Run "Log.vbs ERROR MACHINE_NOT_AVAILABLE_"&CPS_NAME(iCount),0,true
			objShell.Run "Log.vbs PROGRESS MACHINE_NOT_AVAILABLE_PING_FAILURE_"&CPS_NAME(iCount),0,true
		End IF
	Next
	
	objShell.Run "Log.vbs DEBUG EXIT_CreateFolders_Execute()",0,true
End Function

Function Clean(strString)
	
	Dim iCount
	Dim iLength
	iLength = Len(strString)
	MARKER = """"
	iCount = inStr(strString,MARKER)
	Clean = Mid(strString,2,iLength-2)

End Function

Function ParseConfig()
	objShell.Run "Log.vbs DEBUG ENTER_CreateFolders_ParseConfig()",0,true	
		
	Dim strTemp
	USER_NAME = ReadIni(strConfigFileName,"GENERAL","USER_NAME")
	objShell.Run "Log.vbs PROGRESS USER_NAME_=_"&USER_NAME,0,true	
	
	PASSWORD = ReadIni(strConfigFileName,"GENERAL","PASSWORD")
	objShell.Run "Log.vbs PROGRESS PASSWORD_=_"&PASSWORD,0,true
		
	DUMP_FOLDER_NAME = ReadIni(strConfigFileName,"GENERAL","DUMP_FOLDER_NAME")	 
	objShell.Run "Log.vbs PROGRESS DUMP_FOLDER_NAME_=_"&DUMP_FOLDER_NAME,0,true
	
	SHARE_NAME = DUMP_FOLDER_NAME
	objShell.Run "Log.vbs PROGRESS SHARE_NAME_=_"&SHARE_NAME,0,true
	
	SHARE_DESCRIPTION = "SHARE DATA FOR IPLOOKUP"
	objShell.Run "Log.vbs PROGRESS SHARE_DESCRIPTION_=_"&SHARE_DESCRIPTION,0,true
	
	strTemp = ReadIni(strConfigFileName,"CPS_INFO","NUMBER_OF_CPS")
	NUMBER_OF_CPS = strTemp
	objShell.Run "Log.vbs PROGRESS NUMBER_OF_CPS_=_"&NUMBER_OF_CPS,0,true
	
	'Wscript.echo USER_NAME
	'Wscript.echo PASSWORD
	'Wscript.echo DUMP_FOLDER_NAME
	'Wscript.echo SHARE_DESCRIPTION
	'Wscript.echo NUMBER_OF_CPS 
	
	HOST_DUMP_FOLDER_PATH = ReadIni(strConfigFileName,"FTP_SITE","DUMP_FOLDER_PATH")	
	objShell.Run "Log.vbs PROGRESS DUMP_FOLDER_PATH_=_"&HOST_DUMP_FOLDER_PATH,0,true
	
	For iCount = 0 To NUMBER_OF_CPS-1
		CPS_NAME(iCount) = ReadIni(strConfigFileName,"CPS_"&iCount,"CPS_NAME")		 
		objShell.Run "Log.vbs PROGRESS CPS_"&iCount&"_CPS_NAME_=_"&CPS_NAME(iCount),0,true
		strTemp = ReadIni(strConfigFileName,"CPS_"&iCount,"DUMP_FOLDER_PATH")
		DUMP_FOLDER_PATH(iCount) = """" &strTemp& """"	
		objShell.Run "Log.vbs PROGRESS CPS_"&iCount&"_DUMP_FOLDER_PATH_=_"&DUMP_FOLDER_PATH(iCount),0,true
		
		'Wscript.echo CPS_NAME(iCount)
		'Wscript.echo DUMP_FOLDER_PATH(iCount)
	Next
		
	objShell.Run "Log.vbs DEBUG ENTER_CreateFolders_ParseConfig()",0,true
End Function

Function CreateShareFolder(strComputer,strUserLogin,strUser,strPassword,strNewFolder,strShareName,strShareDesc)
	objShell.Run "Log.vbs DEBUG ENTER_CreateFolders_CreateShareFolder()"	,0,true
	
	'wscript.echo strComputer
	'wscript.echo strUserLogin
	'wscript.echo strPassword

	Set SWBemlocator = CreateObject("WbemScripting.SWbemLocator")	
	objShell.Run "Log.vbs NOTIFICATION ESTABLISHING_CONNECTION_"&strComputer&"USER_NAME_=_"&strUserLogin&"_PASSWORD_=_"&strPassword,0,true
	'Wscript.echo NOTIFICATION ESTABLISHING_CONNECTION_"&strComputer&"USER_NAME_=_"&Clean(strUserLogin)&"_PASSWORD_=_"&Clean(strPassword)
	SWBemlocator.Security_.ImpersonationLevel = 3
	Set objWMIService = SWBemlocator.ConnectServer(strComputer,"root\CIMV2",strUserLogin,strPassword)
	
	If Err.Number<>"0" Then 
		objShell.Run "Log.vbs NOTIFICATION CONNECTION_FAILED_"&strComputer,0,true
		objShell.Run "Log.vbs PROGRESS CONNECTION_FAILED_"&strComputer,0,true
		CreateShareFolder = False
	ELSE
		objShell.Run "Log.vbs NOTIFICATION CONNECTION_ESTABLISHED_"&strComputer,0,true
		objShell.Run "Log.vbs PROGRESS CONNECTION_ESTABLISHED_"&strComputer,0,true
		
		objShell.Run "Log.vbs NOTIFICATION CONNECTION_ESTABLISHED_"&strNewFolder,0,true
		Set objWMIServiceFolder = objWMIService.get("Win32_Process")
		errReturn = objWMIServiceFolder.Create("cmd.exe /c md "&strNewFolder, Null, Null, intProcessID)
		If 0 = errReturn Then
			objShell.Run "Log.vbs NOTIFICATION FOLDER_CREATION_SUCCESSFUL_"&strNewFolder,0,true
			objShell.Run "Log.vbs PROGRESS FOLDER_CREATION_SUCCESSFUL_"&strNewFolder,0,true
			objShell.Run "Log.vbs NOTIFICATION SHAIRING_FOLDER_"&strNewFolder,0,true
			IF True = ShareFolder(objWMIService,strUser,strNewFolder,strShareName,strShareDesc) Then
				objShell.Run "Log.vbs NOTIFICATION FOLDER_SHAIRING_SUCCESSFUL_"&strNewFolder,0,true
				objShell.Run "Log.vbs PROGRESS FOLDER_SHAIRING_SUCCESSFUL_"&strNewFolder,0,true
				CreateShareFolder = True
			Else
				objShell.Run "Log.vbs NOTIFICATION FOLDER_SHAIRING_FAILED_"&strNewFolder,0,true
				objShell.Run "Log.vbs PROGRESS FOLDER_SHAIRING_FAILED_"&strNewFolder,0,true
				CreateShareFolder = False
			End IF
		Else
			objShell.Run "Log.vbs NOTIFICATION FOLDER_CREATION_FAILED_"&strNewFolder,0,true
			objShell.Run "Log.vbs PROGRESS FOLDER_CREATION_FAILED_"&strNewFolder,0,true
			CreateShareFolder = False
		End IF
	END If	
	
	objShell.Run "Log.vbs DEBUG EXIT_CreateFolders_CreateShareFolder()"	,0,true
End Function	


Function ShareFolder(objWMIService,strUser,strNewFolder,strShareName,strShareDesc)
	objShell.Run "Log.vbs DEBUG ENTER_CreateFolders_ShareFolder()"	,0,true
	strUser = strUser
	strNewFolder = Clean(strNewFolder)

	'wscript.echo strUser
	'wscript.echo strNewFolder
	'wscript.echo strShareName 
	'wscript.echo strShareDesc
	
	Set  Services = objWMIService
		' Connects to the WMI service with security privileges 
		Set SecDescClass = Services.Get("Win32_SecurityDescriptor") 
		' Need an instance of the Win32_SecurityDescriptor so we can create an instance of a Security Descriptor. 
		Set SecDesc = SecDescClass.SpawnInstance_() 
		' Create an instance of a Security Descriptor. 
		Set colWinAcc = Services.ExecQuery("SELECT * FROM Win32_ACCOUNT WHERE Name='" & strUser & "'") 
		If colWinAcc.Count < 1 Then 
			'Wscript.echo("User " & strUser & "Not Found") 
			'wscript.quit 
			objShell.Run "Log.vbs NOTIFICATION USER_NAME_NOT_FOUND_ON_MACHINE"	,0,true
			objShell.Run "Log.vbs PROGRESS USER_NAME_NOT_FOUND_ON_MACHINE"	,0,true
			ShareFolder = False		
		Else			
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
			'wscript.echo("OUT: " & outParams.returnValue) 	
			If outParams.returnValue <> 0 Then 
				objShell.Run "Log.vbs NOTIFICATION FOLDER_SHAIRING_FAILED_"&strNewFolder&"_ERROR_CODE_"&outParams.returnValue,0,true	
				objShell.Run "Log.vbs PROGRESS FOLDER_SHAIRING_FAILED_"&strNewFolder&"_ERROR_CODE_"&outParams.returnValue	,0,true
				ShareFolder = False
			Else 
				objShell.Run "Log.vbs NOTIFICATION FOLDER_SHAIRING_SUCCESSFUL_"&strNewFolder&"_SHARE_NAME_=_"&strShareName&"_USER_NAME_"&strUser,0,true
				objShell.Run "Log.vbs PROGRESS FOLDER_SHAIRING_SUCCESSFUL_"&strNewFolder&"_SHARE_NAME_=_"&strShareName&"_USER_NAME_"&strUser,0,true
				ShareFolder = True
			End If 	
		End If 
	objShell.Run "Log.vbs DEBUG EXIT_CreateFolders_ShareFolder()"	,0,true
End Function

Function CreateShareFolderLocal(strUser,strNewFolder,strShareName,strShareDesc)
	objShell.Run "Log.vbs DEBUG ENTER_CreateFolders_CreateShareFolderLocal()",0,true	
	
	If True = CreateFolderLocal(strNewFolder) Then		
		objShell.Run "Log.vbs NOTIFICATION CREATING_FOLDER_SUCCESSFUL_=_"&strNewFolder,0,true
		objShell.Run "Log.vbs PROGRESS CREATING_FOLDER_SUCCESSFUL_=_"&strNewFolder,0,true
		strComputer = "."
		Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
		If True = ShareFolderLocal(objWMIService ,strUser,strNewFolder,strShareName,strShareDesc) Then
			objShell.Run "Log.vbs NOTIFICATION SHAIRING_FOLDER_SUCCESSFUL_=_"&strNewFolder,0,true
			objShell.Run "Log.vbs PROGRESS SHAIRING_FOLDER_SUCCESSFUL_=_"&strNewFolder,0,true
			CreateShareFolderLocal = True
		Else
			objShell.Run "Log.vbs NOTIFICATION SHAIRING_FOLDER_FAILURE_=_"&strNewFolder,0,true
			objShell.Run "Log.vbs PROGRESS SHAIRING_FOLDER_FAILURE_=_"&strNewFolder,0,true
			CreateShareFolderLocal = False
		End IF
	Else
		objShell.Run "Log.vbs NOTIFICATION CREATING_FOLDER_FAILURE_CreateShareFolder_=_"&strNewFolder,0,true
		objShell.Run "Log.vbs PROGRESS CREATING_FOLDER_FAILURE_CreateShareFolder_=_"&strNewFolder,0,true
		CreateShareFolderLocal = False		
	End IF	
	
	objShell.Run "Log.vbs DEBUG EXIT_CreateFolders_CreateShareFolderLocal()",0,true	
End Function

Function CreateFolderLocal(strVirtualDirFolder)
	objShell.Run "Log.vbs DEBUG ENTER_CreateFolders_CreateFolderLocal()",0,true
	
	Set WshShell = WScript.CreateObject("WScript.Shell")	
	command = "cmd /c mkdir "&strVirtualDirFolder&" "
	ret = WshShell.Run (command,0,True)
	IF 1 = ret Then			
		CreateFolderLocal = False
	Else			
		CreateFolderLocal = True
	End IF
	
	objShell.Run "Log.vbs DEBUG EXIT_ENTER_CreateFolders_CreateFolderLocal()",0,true
End Function

Function ShareFolderLocal(objWMIService,strUser,strNewFolder,strShareName,strShareDesc)
	objShell.Run "Log.vbs DEBUG ENTER_CreateFolder_ShareFolderLocal()"	,0,true	
	'wscript.echo strUser
	'wscript.echo strNewFolder
	'wscript.echo strShareName 
	'wscript.echo strShareDesc
	strShareName = """"&strShareName&""""
	Set  Services = objWMIService
		' Connects to the WMI service with security privileges 
		Set SecDescClass = Services.Get("Win32_SecurityDescriptor") 
		' Need an instance of the Win32_SecurityDescriptor so we can create an instance of a Security Descriptor. 
		Set SecDesc = SecDescClass.SpawnInstance_() 
		' Create an instance of a Security Descriptor. 
		Set colWinAcc = Services.ExecQuery("SELECT * FROM Win32_ACCOUNT WHERE Name='" & strUser & "'") 
		If colWinAcc.Count < 1 Then 
			'Wscript.echo("User " & strUser & "Not Found") 
			'wscript.quit 
			objShell.Run "Log.vbs NOTIFICATION USER_NAME_NOT_FOUND_ON_MACHINE"	,0,true
			objShell.Run "Log.vbs PROGRESS USER_NAME_NOT_FOUND_ON_MACHINE"	,0,true
			ShareFolderLocal = False		
		Else			
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
			InParam.Properties_.Item("Name") = Clean(strShareName) 
			InParam.Properties_.Item("Path") = strNewFolder 
			InParam.Properties_.Item("Type") = 0 
			Set outParams=Share.ExecMethod_("Create", InParam)  
			' Create the share with all the parameters we have set up 
			'wscript.echo("OUT: " & outParams.returnValue) 	
			If outParams.returnValue <> 0 Then 
				objShell.Run "Log.vbs NOTIFICATION FOLDER_SHAIRING_FAILED_"&strNewFolder&"_ERROR_CODE_"&outParams.returnValue,0,true	
				objShell.Run "Log.vbs PROGRESS FOLDER_SHAIRING_FAILED_"&strNewFolder&"_ERROR_CODE_"&outParams.returnValue	,0,true
				ShareFolderLocal = False
			Else 
				objShell.Run "Log.vbs NOTIFICATION FOLDER_SHAIRING_SUCCESSFUL_"&strNewFolder&"_SHARE_NAME_=_"&strShareName&"_USER_NAME_"&strUser,0,true
				objShell.Run "Log.vbs PROGRESS FOLDER_SHAIRING_SUCCESSFUL_"&strNewFolder&"_SHARE_NAME_=_"&strShareName&"_USER_NAME_"&strUser,0,true
				ShareFolderLocal = True
			End If 	
		End If 
	objShell.Run "Log.vbs DEBUG EXIT_CreateFolder_ShareFolderLocal()"	,0,true	
End Function

Function PingSuccess( strComputer )
	Set objShell = Wscript.CreateObject("WScript.Shell")
	objShell.Run "Log.vbs DEBUG ENTER_CreateFolders_PingSuccess()"	,0,true
	
    Dim objShell,objPing
    Dim strPingOut, flag
    Set objShell = CreateObject("Wscript.Shell")
    Set objPing = objShell.Exec("ping " & strComputer)
    strPingOut = objPing.StdOut.ReadAll
    IF instr(LCase(strPingOut), "reply") Then
        flag = TRUE
    Else
        flag = FALSE
    End IF
       PingSuccess = flag 
	   
	objShell.Run "Log.vbs DEBUG EXIT_CreateFolders_PingSuccess()",0,true	 
End Function

Function ReadIni( myFilePath, mySection, myKey )
    ' This function returns a value read from an INI file
    '
    ' Arguments:
    ' myFilePath  [string]  the (path and) file name of the INI file
    ' mySection   [string]  the section in the INI file to be searched
    ' myKey       [string]  the key whose value is to be returned
    '
    ' Returns:
    ' the [string] value for the specified key in the specified section
    '
    ' CAVEAT:     Will return a space if key exists but value is blank
    '
    ' Written by Keith Lacelle
    ' Modified by Denis St-Pierre and Rob van der Woude

    Const ForReading   = 1
    Const ForWriting   = 2
    Const ForAppending = 8

    Dim intEqualPos
    Dim objFSO, objIniFile
    Dim strFilePath, strKey, strLeftString, strLine, strSection

    Set objFSO = CreateObject( "Scripting.FileSystemObject" )

    ReadIni     = ""
    strFilePath = Trim( myFilePath )
    strSection  = Trim( mySection )
    strKey      = Trim( myKey )

    If objFSO.FileExists( strFilePath ) Then
        Set objIniFile = objFSO.OpenTextFile( strFilePath, ForReading, False )
        Do While objIniFile.AtEndOfStream = False
            strLine = Trim( objIniFile.ReadLine )

            ' Check if section is found in the current line
            If LCase( strLine ) = "[" & LCase( strSection ) & "]" Then
                strLine = Trim( objIniFile.ReadLine )

                ' Parse lines until the next section is reached
                Do While Left( strLine, 1 ) <> "["
                    ' Find position of equal sign in the line
                    intEqualPos = InStr( 1, strLine, "=", 1 )
                    If intEqualPos > 0 Then
                        strLeftString = Trim( Left( strLine, intEqualPos - 1 ) )
                        ' Check if item is found in the current line
                        If LCase( strLeftString ) = LCase( strKey ) Then
                            ReadIni = Trim( Mid( strLine, intEqualPos + 1 ) )
                            ' In case the item exists but value is blank
                            If ReadIni = "" Then
                                ReadIni = " "
                            End If
                            ' Abort loop when item is found
                            Exit Do
                        End If
                    End If

                    ' Abort if the end of the INI file is reached
                    If objIniFile.AtEndOfStream Then Exit Do

                    ' Continue with next line
                    strLine = Trim( objIniFile.ReadLine )
                Loop
            Exit Do
            End If
        Loop
        objIniFile.Close
    Else
        WScript.Echo strFilePath & " doesn't exists. Exiting..."
        Wscript.Quit 1
    End If
End Function