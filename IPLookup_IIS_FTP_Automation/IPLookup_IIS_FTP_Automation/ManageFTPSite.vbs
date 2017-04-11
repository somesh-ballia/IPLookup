Dim objShell
Set objShell = Wscript.CreateObject("WScript.Shell")
strConfigFileName = "Config.ini"
strDefaultSiteName = "Default FTP Site"
DELAY = 1000
Dim NUMBER_OF_CPS
Dim CPS_NAME(100)
Dim DUMP_FOLDER_PATH(100)
Dim FTP_BASE_PATH
Dim FTP_SITE_NAME
Dim IP_ADDRESS
Dim USER_NAME
Dim PASSWORD 
Dim DUMP_FOLDER_NAME
Dim SHARE_NAME
Dim HOST_NAME
Dim HOST_DUMP_FOLDER_PATH
Dim SHARE_DESCRIPTION
Dim OVERWRITE_DEFAULT_SITE
Dim strPROGRESS
Dim bFtpInstalled
Dim ArgumentObject
Set ArgumentObject=Wscript.Arguments
bFtpInstalled=ArgumentObject.Item(0)
ParseConfig()
Execute()

Function Execute()
	objShell.Run "Log.vbs DEBUG ENTER_ManageFTPSite_Execute()"	,0,true
	IF True = IsFTPRunning() Then
		
		objShell.Run "Log.vbs NOTIFICATION CREATE_FTP_BASE_DIRECTORY_=_"&FTP_BASE_PATH,0,true
		' creating FTP_ROOT Directory
	
		' CREATING CPS FOLDER
		strShareName = SHARE_NAME
		strNewFolder = HOST_DUMP_FOLDER_PATH&"\"&Clean(strShareName)
		strUserName = Clean(USER_NAME)
		CreateShareFolder strUserName,strNewFolder,SHARE_NAME,SHARE_DESCRIPTION	
		
		IF True = CreateBasePathDirectory() Then
			objShell.Run "Log.vbs NOTIFICATION CREATE_FTP_BASE_DIRECTORY_SUCCESSFUL_=_"&FTP_BASE_PATH,0,true
			objShell.Run "Log.vbs PROGRESS CREATE_FTP_BASE_DIRECTORY_SUCCESSFUL_=_"&FTP_BASE_PATH,0,true		
			objShell.Run "Log.vbs CREATING_FTP_SITE_=_"&FTP_SITE_NAME,0,true	
			
			' if FTP server was not installed in this script execution
			IF 0 = bFtpInstalled Then
			
				iSiteCount = GetFTPSiteCount()					
				if 1 = iSiteCount Then
					strSiteName = GetFTPSiteName()
					IF strDefaultSiteName = strSiteName Then
						IF True = OVERWRITE_DEFAULT_SITE Then
							objShell.Run "Log.vbs NOTIFICATION DEFAULT_FTP_SITE_EXISTING_OVERWRITE_DEFAULT_SITE_ENABLED ",0,true
							objShell.Run "Log.vbs PROGRESS DEFAULT_FTP_SITE_EXISTING_OVERWRITE_DEFAULT_SITE_ENABLED ",0,true
							'Deleteing default stite
							DeleteDefaultSite()
							ContinueExecution()
						Else
							objShell.Run "Log.vbs NOTIFICATION CRITICAL_DEFAULT_FTP_SITE_EXISTING_OVERWRITE_DEFAULT_SITE_DISABLED ",0,true
							objShell.Run "Log.vbs PROGRESS CRITICAL_DEFAULT_FTP_SITE_EXISTING_OVERWRITE_DEFAULT_SITE_DISABLED ",0,true
							objShell.Run "Log.vbs PROGRESS CRITICAL_QUITING_SCRIPT ",0,true
						End If
					Else
						objShell.Run "Log.vbs NOTIFICATION PRE-REQUSITE_VOILATED_EXISTING_FTP_SITE_=_"&strSiteName,0,true
						objShell.Run "Log.vbs PROGRESS PRE-REQUSITE_VOILATED_EXISTING_FTP_SITE_=_"&strSiteName,0,true
					End IF
				Else			
					If 0 = iSiteCount Then
						objShell.Run "Log.vbs NOTIFICATION NO_EXISTING_FTP_SITE_FOUND_CREATING_SITE_=_"&FTP_SITE_NAME,0,true
						objShell.Run "Log.vbs PROGRESS NO_EXISTING_FTP_SITE_FOUND_CREATING_SITE_=_"&FTP_SITE_NAME,0,true
						ContinueExecution()						
						'objShell.Run "Log.vbs NOTIFICATION CHANGE_FTP_SITE_SETTINGS_MANUALLY",0,true
						'objShell.Run "Log.vbs PROGRESS CHANGE_FTP_SITE_SETTINGS_MANUALLY",0,true
						'objShell.Run "inetmgr",0,false						
					Else
						objShell.Run "Log.vbs NOTIFICATION MULTIPLE_FTP_SITE_EXISTING_PRE-REQUSITE_VOILATED",0,true
						objShell.Run "Log.vbs PROGRESS MULTIPLE_FTP_SITE_EXISTING_PRE-REQUSITE_VOILATED",0,true
					End If				
				End If
			Else
				' if FTP server was installed in this script execution			
				DeleteDefaultSite()
				ContinueExecution()
			End IF
		Else
			objShell.Run "Log.vbs NOTIFICATION CRITICAL_CREATING_FOLDER_FAILURE_CreateBasePathDirectory_=_"&FTP_BASE_PATH,0,true
			objShell.Run "Log.vbs PROGRESS CRITICAL_CREATING_FOLDER_FAILURE_CreateBasePathDirectory_=_"&FTP_BASE_PATH,0,true
		End IF
	Else
		
		IF 1 = bFtpInstalled Then
			
			' wait for ftp service to get up			
			
		Else		
			objShell.Run "Log.vbs NOTIFICATION FTP_SERVICE_NOT_RUNNING",0,true
			objShell.Run "Log.vbs PROGRESS FTP_SERVICE_NOT_RUNNING",0,true
		End IF
		
	End IF
	objShell.Run "Log.vbs DEBUG EXIT_ManageFTPSite_Execute()",0,true	
End Function

Function CreateBasePathDirectory()
	objShell.Run "Log.vbs DEBUG ENTER_ManageFTPSite_CreateBasePathDirectory()"	,0,true
	
	IF False = FolderExist(FTP_BASE_PATH) Then
		IF True = CreateFolder(FTP_BASE_PATH) Then
			CreateBasePathDirectory = True
		Else
			CreateBasePathDirectory = False
		End IF
	Else
		CreateBasePathDirectory = True
	End IF
	
	CreateBasePathDirectory = True
	objShell.Run "Log.vbs DEBUG ENTER_ManageFTPSite_CreateBasePathDirectory()"	,0,true
End Function

Function ContinueExecution()
	objShell.Run "Log.vbs DEBUG ENTER_ManageFTPSite_ContinueExecution()"	,0,true
	
	retCreateFTPSite = CreateFTPSite(HOST_NAME,FTP_BASE_PATH,FTP_SITE_NAME,IP_ADDRESS,USER_NAME,PASSWORD)
			IF True = retCreateFTPSite Then
				objShell.Run "Log.vbs NOTIFICATION CREATING_FTP_SITE_SUCCESSFUL_=_"&FTP_SITE_NAME,0,true
				objShell.Run "Log.vbs PROGRESS CREATING_FTP_SITE_SUCCESSFUL_=_"&FTP_SITE_NAME,0,true
			
				objShell.Run "Log.vbs NOTIFICATION ENABLING_POWERSHELL_EXECUTION",0,true
				objShell.Run "Log.vbs PROGRESS ENABLING_POWERSHELL_EXECUTION",0,true
				objShell.Run ".\ps\PortablePowerShell.exe set-executionpolicy remotesigned",0,true
				objShell.Run "Log.vbs NOTIFICATION ENABLING_POWERSHELL_EXECUTION_SUCCESSFUL",0,true
				objShell.Run "Log.vbs PROGRESS ENABLING_POWERSHELL_EXECUTION_SUCCESSFUL",0,true				
				
				objShell.Run "Log.vbs NOTIFICATION CREATING_VIRTUAL_DIRECTORIES",0,true
				for icount = 0 To NUMBER_OF_CPS-1
					Dim strVirtualDirFolder
					strTemp = Clean(FTP_BASE_PATH)&"\"& Clean(CPS_NAME(iCount))
					strVirtualDirFolder = """"&strTemp&""""				
					objShell.Run "Log.vbs NOTIFICATION CREATING_FTP_SITE_SUCCESSFUL_=_"&FTP_SITE_NAME,0,true
					objShell.Run "Log.vbs PROGRESS CPS_=_"&CPS_NAME(iCount)&"_VIRTUAL_DIRECTORY_PATH_=_"&strVirtualDirFolder,0,true
					IF False = FolderExist(strVirtualDirFolder) Then	
							
						objShell.Run "Log.vbs NOTIFICATION CREATING_FOLDER_"&strVirtualDirFolder,0,true
						objShell.Run "Log.vbs PROGRESS CREATING_FOLDER_"&strVirtualDirFolder,0,true
						retCreateFolder = CreateFolder (strVirtualDirFolder)
						IF True = retCreateFolder Then 
						
							objShell.Run "Log.vbs NOTIFICATION CREATING_FOLDER_SUCCESSFUL_"&strVirtualDirFolder,0,true
							objShell.Run "Log.vbs PROGRESS CREATING_FOLDER_SUCCESSFUL_"&strVirtualDirFolder,0,true
							strPhysicalDirPath = "\\"
							strPhysicalDirPath = strPhysicalDirPath&""&Clean(CPS_NAME(iCount))&"\"&Clean(SHARE_NAME)
							' Checking if remote folder for virutal dir exists
							objShell.Run "Log.vbs NOTIFICATION CHECK_IF_FOLDER_EXIST_"&strPhysicalDirPath,0,true
							objShell.Run "Log.vbs PROGRESS CHECK_IF_FOLDER_EXIST_"&strPhysicalDirPath,0,true
							
							objShell.Run "Log.vbs NOTIFICATION CREATING_VIRTUAL_DIRECTORY_AT_=_"&strPhysicalDirPath,0,true
							objShell.Run "Log.vbs PROGRESS CREATING_VIRTUAL_DIRECTORY_AT_=_"&strPhysicalDirPath,0,true
							retCreateVirtualDir = CreateVirtualDirectory(FTP_SITE_NAME, CPS_NAME(iCount), strPhysicalDirPath,CPS_NAME(iCount), USER_NAME, PASSWORD ) 
							IF True = retCreateVirtualDir Then
								objShell.Run "Log.vbs NOTIFICATION CREATING_VIRTUAL_DIRECTORY_SUCCESS_=_"&strPhysicalDirPath,0,true
								objShell.Run "Log.vbs PROGRESS CREATING_VIRTUAL_DIRECTORY_SUCCESS_=_"&strPhysicalDirPath,0,true
							Else
								objShell.Run "Log.vbs NOTIFICATION CREATING_VIRTUAL_DIRECTORY_FAILURE_=_"&strPhysicalDirPath,0,true
								objShell.Run "Log.vbs PROGRESS CREATING_VIRTUAL_DIRECTORY_FAILURE_=_"&strPhysicalDirPath,0,true
							End IF
						Else
							objShell.Run "Log.vbs NOTIFICATION CREATING_FOLDER_FAILURE_ContinueExecution_=_"&strVirtualDirFolder,0,true
							objShell.Run "Log.vbs PROGRESS CREATING_FOLDER_FAILURE_ContinueExecution_=_"&strVirtualDirFolder,0,true
						End IF
					End IF
				Next
			Else
				objShell.Run "Log.vbs CRITICAL_NOTIFICATION CREATING_SITE_FAILURE_=_"&FTP_SITE_NAME,0,true
				objShell.Run "Log.vbs PROGRESS CRITICAL_CREATING_SITE_FAILURE_=_"&FTP_SITE_NAME,0,true
			End IF
			
	objShell.Run "Log.vbs DEBUG EXIT_ManageFTPSite_ContinueExecution()"	,0,true
End Function

Function ParseConfig()	
	objShell.Run "Log.vbs DEBUG ENTER_ManageFTPSite_ParseConfig()"	,0,true
	
	bFtpInstalled = 0
	
	Dim strTemp
	strTemp = ReadIni(strConfigFileName,"GENERAL","USER_NAME")
	USER_NAME = """" &strTemp& """"
	
	strTemp = ReadIni(strConfigFileName,"GENERAL","PASSWORD")
	PASSWORD = """" &strTemp& """"
	
	strTemp = ReadIni(strConfigFileName,"GENERAL","DUMP_FOLDER_NAME")
	DUMP_FOLDER_NAME = """" &strTemp& """"
	SHARE_NAME = DUMP_FOLDER_NAME	
	
	strTemp = ReadIni(strConfigFileName,"FTP_SITE","FTP_BASE_PATH")
	FTP_BASE_PATH = """" &strTemp& """"
	objShell.Run "Log.vbs PROGRESS FTP_BASE_PATH_=_"&FTP_BASE_PATH,0,true
	
	strTemp = ReadIni(strConfigFileName,"FTP_SITE","FTP_SITE_NAME")
	FTP_SITE_NAME = """" &strTemp& """"
	objShell.Run "Log.vbs PROGRESS FTP_SITE_NAME _=_"&FTP_SITE_NAME ,0,true
	
	strTemp = ReadIni(strConfigFileName,"FTP_SITE","IPADDRESS")
	IPADDRESS = """" &strTemp& """"
	objShell.Run "Log.vbs PROGRESS IPADDRESS_=_"&IPADDRESS,0,true
	
	strTemp = ReadIni(strConfigFileName,"CPS_INFO","NUMBER_OF_CPS")
	NUMBER_OF_CPS = strTemp	
	
	HOST_NAME = ReadIni(strConfigFileName,"FTP_SITE","CPS_NAME")	 
	objShell.Run "Log.vbs PROGRESS HOST_NAME_=_"&HOST_NAME,0,true
	
	If "1" = ReadIni(strConfigFileName,"FTP_SITE","OVERWRITE_DEFAULT_SITE")	 Then
		OVERWRITE_DEFAULT_SITE = True
	Else
		OVERWRITE_DEFAULT_SITE = False
	End If
	objShell.Run "Log.vbs PROGRESS OVERWRITE_DEFAULT_SITE_=_"&OVERWRITE_DEFAULT_SITE,0,true
	
	
	HOST_DUMP_FOLDER_PATH = ReadIni(strConfigFileName,"FTP_SITE","DUMP_FOLDER_PATH")	
	objShell.Run "Log.vbs PROGRESS DUMP_FOLDER_PATH_=_"&HOST_DUMP_FOLDER_PATH,0,true
	
	SHARE_DESCRIPTION = "SHARE DATA FOR IPLOOKUP"
	
	'Wscript.echo USER_NAME
	'Wscript.echo PASSWORD
	'Wscript.echo DUMP_FOLDER_NAME
	'Wscript.echo FTP_BASE_PATH
	'Wscript.echo FTP_SITE_NAME
	'Wscript.echo IPADDRESS
	'Wscript.echo NUMBER_OF_CPS 
	
	For iCount = 0 To NUMBER_OF_CPS-1
		strTemp = ReadIni(strConfigFileName,"CPS_"&iCount,"CPS_NAME")
		CPS_NAME(iCount) = """" &strTemp& """"
		strTemp = ReadIni(strConfigFileName,"CPS_"&iCount,"DUMP_FOLDER_PATH")
		DUMP_FOLDER_PATH(iCount) = """" &strTemp& """"			
		'Wscript.echo CPS_NAME(iCount)
		'Wscript.echo DUMP_FOLDER_PATH(iCount)
	Next
	
	CPS_NAME(iCount) = """"&HOST_NAME&""""
	DUMP_FOLDER_PATH(iCount) = """"&HOST_DUMP_FOLDER_PATH&""""
	NUMBER_OF_CPS = NUMBER_OF_CPS+1
	
	objShell.Run "Log.vbs DEBUG EXIT_ManageFTPSite_ParseConfig()"	,0,true
End Function

Function IsFTPRunning()
	objShell.Run "Log.vbs DEBUG ENTER_ManageFTPSite_IsFTPRunning()	",0,true
	
	Dim bReturn
	bReturn = False
	strComputer = "."
	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\MicrosoftIISv2")
	Set colItems = objWMIService.ExecQuery("SELECT * FROM IIsFtpService",,48)
	For Each objItem in colItems	
		if False = bReturn Then
			bReturn = objItem.Started
		End If
	Next

	IF False = bReturn Then
		IsFTPRunning = False
	Else
		IsFTPRunning = True
	End if
		
	objShell.Run "Log.vbs DEBUG EXIT_ManageFTPSite_IsFTPRunning()	",0,true
End Function

Function GetFTPSiteCount()
	objShell.Run "Log.vbs DEBUG ENTER_ManageFTPSite_GetFTPSiteCount()"	,0,true
	
	Dim iCount
	iCount = 0
	strComputer = "."
	Set objWMIService = GetObject("winmgmts:{authenticationLevel=pktPrivacy}\\"& strComputer & "\root\microsoftiisv2")
	Set colItems = objWMIService.ExecQuery ("Select * from IIsFtpServerSetting")
	For Each objItem in colItems
		iCount = iCount+1
		'Wscript.Echo "Server Comment: " & objItem.ServerComment    
	Next
	'Wscript.Echo iCount
	GetFTPSiteCount = iCount
	
	objShell.Run "Log.vbs DEBUG EXIT_ManageFTPSite_GetFTPSiteCount()"	,0,true
End Function

Function GetFTPSiteName()
	objShell.Run "Log.vbs DEBUG ENTER_ManageFTPSite_GetFTPSiteName()"	,0,true
	
	strComputer = "."
	Set objWMIService = GetObject("winmgmts:{authenticationLevel=pktPrivacy}\\"& strComputer & "\root\microsoftiisv2")
	Set colItems = objWMIService.ExecQuery ("Select * from IIsFtpServerSetting")
	
	For Each objItem in colItems
		GetFTPSiteName = objItem.ServerComment    		
	Next	
	
	objShell.Run "Log.vbs DEBUG EXIT_ManageFTPSite_GetFTPSiteName()"	,0,true
End Function

Function DeleteDefaultSite()
	objShell.Run "Log.vbs DEBUG ENTER_ManageFTPSite_DeleteDefaultSite()",0,true	
	
	Set WshShell = WScript.CreateObject("WScript.Shell")	
	command = "cmd /c iisftp /delete ""Default FTP Site"""
	WshShell.Run command,0,True
	
	objShell.Run "Log.vbs DEBUG ENTER_ManageFTPSite_DeleteDefaultSite()",0,true	
End Function

Function CreateShareFolder(strUser,strNewFolder,strShareName,strShareDesc)
	objShell.Run "Log.vbs DEBUG ENTER_ManageFTPSite_CreateShareFolder()",0,true	
	
	If True = CreateFolder(strNewFolder) Then		
		objShell.Run "Log.vbs NOTIFICATION CREATING_FOLDER_SUCCESSFUL_=_"&strNewFolder,0,true
		objShell.Run "Log.vbs PROGRESS CREATING_FOLDER_SUCCESSFUL_=_"&strNewFolder,0,true
		strComputer = "."
		Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
		If True = ShareFolder(objWMIService ,strUser,strNewFolder,strShareName,strShareDesc) Then
			objShell.Run "Log.vbs NOTIFICATION SHAIRING_FOLDER_SUCCESSFUL_=_"&strNewFolder,0,true
			objShell.Run "Log.vbs PROGRESS SHAIRING_FOLDER_SUCCESSFUL_=_"&strNewFolder,0,true
		Else
			objShell.Run "Log.vbs NOTIFICATION SHAIRING_FOLDER_FAILURE_=_"&strNewFolder,0,true
			objShell.Run "Log.vbs PROGRESS SHAIRING_FOLDER_FAILURE_=_"&strNewFolder,0,true
		End IF
	Else
		objShell.Run "Log.vbs NOTIFICATION CREATING_FOLDER_FAILURE_CreateShareFolder_=_"&strNewFolder,0,true
		objShell.Run "Log.vbs PROGRESS CREATING_FOLDER_FAILURE_CreateShareFolder_=_"&strNewFolder,0,true		
	End IF	
	
	objShell.Run "Log.vbs DEBUG EXIT_ManageFTPSite_CreateShareFolder()",0,true	
End Function

Function CreateVirtualDirectory(strFTPSiteName, strVirtualDirName, strPhysicalDirPath,strRemoteMachineName, strUserName, strPassword)
	objShell.Run "Log.vbs DEBUG ENTER_ManageFTPSite_CreateVirtualDirectory()",0,true	
	
	Set WshShell = WScript.CreateObject("WScript.Shell")
	'command = "\ps\pps ./CreateVirtualDirectory.ps1 "&strFTPSiteName& " "&strVirtualDirName&" "&strPhysicalDirPath&" "&strUserName&" "&strPassword
	'command = "powershell ./CreateVirtualDirectory.ps1 "&strFTPSiteName& " "&strVirtualDirName&" "&strPhysicalDirPath&" "&Clean(strUserName)&" "&Clean(strPassword)
	command = ".\ps\PortablePowerShell.exe ./CreateVirtualDirectory.ps1 "&strFTPSiteName& " "&strVirtualDirName&" "&strPhysicalDirPath&" "&Clean(strUserName)&" "&Clean(strPassword)
	
	'wscript.echo command
	Ret = WshShell.Run(command , 1, true)
	IF 0 = Ret Then
		CreateVirtualDirectory = TRUE
	Else
		CreateVirtualDirectory = FALSE
	End IF	
	objShell.Run "Log.vbs DEBUG EXIT_ManageFTPSite_CreateVirtualDirectory()",0,true	
End Function	

Function CreateFTPSite(strComputer,strFTPBasePath,strFTPSiteName,strIPAddress,strUserName,strPassword)
	
	objShell.Run "Log.vbs DEBUG ENTER_ManageFTPSite_CreateFTPSite()",0,true	
	command = "cmd /c iisftp /create "&strFTPBasePath&" "&strFTPSiteName&" /s "&strComputer&" /u "&strUserName&" /p "&strPassword
	Set WshShell = WScript.CreateObject("WScript.Shell")	
	ret = WshShell.Run(command , 0, true)
	IF 0 = ret Then
		CreateFTPSite = TRUE
	Else
		CreateFTPSite = FALSE
	End IF
	
	objShell.Run "Log.vbs DEBUG EXIT_ManageFTPSite_CreateFTPSite()"	,0,true
End Function

Function CreateFolder(strVirtualDirFolder)
	objShell.Run "Log.vbs DEBUG ENTER_ManageFTPSite_CreateFolder()",0,true
	
	Set WshShell = WScript.CreateObject("WScript.Shell")	
	command = "cmd /c mkdir "&strVirtualDirFolder&" "
	ret = WshShell.Run (command,0,True)
	IF 1 = ret Then			
		CreateFolder = False
	Else			
		CreateFolder = True
	End IF
	
	objShell.Run "Log.vbs DEBUG EXIT_ManageFTPSite_CreateFolder()",0,true
End Function

Function FolderExist(strFilePath)
	objShell.Run "Log.vbs DEBUG ENTER_ManageFTPSite_FolderExist()"	,0,true
	
	Dim returnValue 
	Set fso = CreateObject("Scripting.FileSystemObject")
	If (fso.FolderExists(strFilePath)) Then
		returnValue = True	 
		objShell.Run "Log.vbs NOTIFICATION FOLDER_EXISTING_TRUE_=_"&strFilePath,0,true
		objShell.Run "Log.vbs PROGRESS FOLDER_EXISTING_TRUE_=_"&strFilePath,0,true
	Else
		returnValue = False
		objShell.Run "Log.vbs NOTIFICATION FOLDER_EXISTING_FALSE_=_"&strFilePath,0,true
		objShell.Run "Log.vbs PROGRESS FOLDER_EXISTING_FALSE_=_"&strFilePath,0,true
	End If	
	FolderExist = returnValue

	objShell.Run "Log.vbs DEBUG EXIT_ManageFTPSite_FolderExist()",0,true	
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

Function Clean(strString)
	
	Dim iCount
	Dim iLength
	iLength = Len(strString)
	MARKER = """"
	iCount = inStr(strString,MARKER)
	Clean = Mid(strString,2,iLength-2)

End Function

Function ShareFolder(objWMIService,strUser,strNewFolder,strShareName,strShareDesc)
	objShell.Run "Log.vbs DEBUG ENTER_ManageFTPSite_ShareFolder()"	,0,true	
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
			InParam.Properties_.Item("Name") = Clean(strShareName) 
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
	objShell.Run "Log.vbs DEBUG EXIT_ManageFTPSite_ShareFolder()"	,0,true
End Function
