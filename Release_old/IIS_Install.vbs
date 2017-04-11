Dim objShell
Set objShell = Wscript.CreateObject("WScript.Shell")
strConfigFileName = "Config.ini"
Dim I386_PATH
Dim SETUP_FILE_PATH

ParseConfig()	
Execute()

Function Execute()
	objShell.Run "Log.vbs DEBUG ENTER_IIS_Install_Execute()",0,true
	
	IF False = IsFTPRunning() Then 
	
		objShell.Run "Log.vbs DEBUG TRYING_TO_CREATE_INSTALL_INSTRUCTION_FILE",0,true
		CreateInstallFile(SETUP_FILE_PATH)
	
		objShell.Run "Log.vbs DEBUG TRYING_TO_MOFIFY_REGISTRY_SETTINGS",0,true
		WriteRegsistrySettings(I386_PATH)
	
		objShell.Run "Log.vbs DEBUG EXECUTING_INSTALL_COMMAND",0,true
		ExecuteCommand(SETUP_FILE_PATH)
	Else
		
		objShell.Run "Log.vbs NOTIFICATION FTP_SERVICE_IS_ALREADY_RUNNING",0,true
		objShell.Run "Log.vbs PROGRESS FTP_SERVICE_IS_ALREADY_RUNNING",0,true
		
	End IF
		objShell.Run "Log.vbs DEBUG EXIT_IIS_Install_Execute()",0,true
	
End Function

Function ParseConfig()	
	objShell.Run "Log.vbs DEBUG ENTER_IIS_Install_ParseConfig()	",0,true
	
	SETUP_FILE_PATH = "c:\IIS_Setup.txt"
	objShell.Run "Log.vbs PROGRESS INSTALLATION_COMMAND_FILE_=_"&SETUP_FILE_PATH,0,true
	Dim strTemp
	strTemp = ReadIni(strConfigFileName,"GENERAL","I386_PATH")
	I386_PATH = strTemp	
	objShell.Run "Log.vbs PROGRESS I386_PATH_=_"&I386_PATH,0,true
	
	objShell.Run "Log.vbs DEBUG EXIT_IIS_Install_ParseConfig()	",0,true
End Function

Function IsFTPRunning()
	objShell.Run "Log.vbs DEBUG ENTER_IIS_Install_IsFTPRunning()	",0,true
	
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
		
	objShell.Run "Log.vbs DEBUG EXIT_IIS_Install_IsFTPRunning()	",0,true
End Function

Function GetFTPSiteCount()
	objShell.Run "Log.vbs DEBUG ENTER_IIS_Install_GetFTPSiteCount()	",0,true
	
	Dim iCount
	iCount = 0
	strComputer = "."
	Set objWMIService = GetObject("winmgmts:{authenticationLevel=pktPrivacy}\\"& strComputer & "\root\microsoftiisv2")
	Set colItems = objWMIService.ExecQuery ("Select * from IIsFtpServerSetting")
	For Each objItem in colItems
		iCount = iCount+1		
	Next
	
	GetFTPSiteCount = iCount
	
	objShell.Run "Log.vbs DEBUG EXIT_IIS_Install_GetFTPSiteCount()	",0,true
End Function

Function IsIISInstalled()
	objShell.Run "Log.vbs DEBUG ENTER_IIS_Install_IsIISInstalled()",0,true
	
	objShell.Run "Log.vbs NOTIFICATION CHECKING_IF_IIS_SERVER_IS_INSTALLED",0,true
	Dim bReturn
	Set WshShell = CreateObject( "WScript.Shell" )
	strDisplayName = WshShell.RegRead ( "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W3SVC\DisplayName" )
	if strDisplayName = "World Wide Web Publishing Service" Then 
		objShell.Run "Log.vbs NOTIFICATION IIS_SERVER_ALREADY_INSTALLED",0,true
		objShell.Run "Log.vbs PROGRESS IIS_SERVER_ALREADY_INSTALLED",0,true
		bReturn = True
	else
		objShell.Run "Log.vbs NOTIFICATION IIS_SERVER_NOT_INSTALLED",0,true
		objShell.Run "Log.vbs PROGRESS IIS_SERVER_NOT_INSTALLED",0,true
		bReturn = False
	End IF
	
	IsIISInstalled = bReturn
	
	objShell.Run "Log.vbs DEBUG EXIT_IIS_Install_IsIISInstalled()",0,true
End Function

Function CreateInstallFile(strFilePath)
	objShell.Run "Log.vbs DEBUG ENTER_IIS_Install_CreateInstallFile()"	,0,true
	
	objShell.Run "Log.vbs NOTIFICATION CREATING_INSTALL_FILE",0,true
	objShell.Run "Log.vbs PROGRESS CREATING_INSTALL_FILE",0,true
	ClearFile(strFilePath)
	WriteFileText strFilePath,"[Components]"
	If Flase = IsIISInstalled() Then
		WriteFileText strFilePath,"iis_common = ON"
		WriteFileText strFilePath,"iis_www = ON"
		WriteFileText strFilePath,"iis_www_vdir_scripts = ON"
		WriteFileText strFilePath,"iis_inetmgr = ON"
		WriteFileText strFilePath,"fp_extensions = ON"
	End If
		WriteFileText strFilePath,"iis_ftp = ON"
	objShell.Run "Log.vbs NOTIFICATION INSTALL_FILE_CREATED",0,true
	objShell.Run "Log.vbs PROGRESS INSTALL_FILE_CREATED",0,true
		
	objShell.Run "Log.vbs DEBUG EXIT_IIS_Install_CreateInstallFile	",0,true
End Function

Function WriteRegsistrySettings(strI386Path)
	objShell.Run "Log.vbs DEBUG ENTER_IIS_Install_WriteRegsistrySettings()",0,true
	
	objShell.Run "Log.vbs NOTIFICATION CHANGING_REGISTRY_VALUE",0,true
	Set Shell = CreateObject( "WScript.Shell" )
	Shell.RegWrite "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\SourcePath",strI386Path,"REG_SZ"
	Shell.RegWrite "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\ServicePackSourcePath",strI386Path,"REG_SZ"
	objShell.Run "Log.vbs NOTIFICATION REGISTRY_VALUE_CHANGED",0,true
	objShell.Run "Log.vbs PROGRESS REGISTRY_VALUE_CHANGED",0,true
	
	objShell.Run "Log.vbs DEBUG EXIT_IIS_Install_WriteRegsistrySettings()",0,true
End Function

Function ExecuteCommand(strFilePath)
	objShell.Run "Log.vbs DEBUG ENTER_IIS_Install_ExecuteCommand()",0,true
	
	objShell.Run "Log.vbs NOTIFICATION EXECUTING_INSTALL_COMMAND",0,true
	Set WshShell = WScript.CreateObject("WScript.Shell")
	WshShell.Run "sysocmgr /i:%windir%\inf\sysoc.inf /u:"&strFilePath,0,true	
	objShell.Run "Log.vbs NOTIFICATION INSTALL_COMMAND_EXECUTED",0,true
	objShell.Run "Log.vbs PROGRESS INSTALL_COMMAND_EXECUTED",0,true
	
	objShell.Run "Log.vbs DEBUG EXIT_IIS_Install_ExecuteCommand()",0,true
End Function

Function WriteFileText(sFilePath, sText)
	objShell.Run "Log.vbs DEBUG ENTER_IIS_Install_WriteFileText()",0,true
	
    Dim objFSO 'As FileSystemObject
    Dim objTextFile 'As Object
   
    Const ForReading = 1
    Const ForWriting = 2
    Const ForAppending = 8
   
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    bFileExist = FileExist(sFilePath)

    if 	false = bFileExist Then
    	Set objTextFile = objFSO.CreateTextFile(sFilePath,true)
    else 
        Set objTextFile = objFSO.OpenTextFile(sFilePath,ForAppending,true)
    End IF

    ' Write a line.
    objTextFile.WriteLine (sText)

    objTextFile.Close
    'objTextFile.Close
	
	objShell.Run "Log.vbs DEBUG EXIT_IIS_Install_WriteFileText()",0,true
End Function

Function FileExist(strFilePath)
	objShell.Run "Log.vbs DEBUG ENTER_IIS_Install_FileExist()",0,true
	
	Dim returnValue 
	Set fso = CreateObject("Scripting.FileSystemObject")
	If (fso.FileExists(strFilePath)) Then
  	  returnValue = true
	Else
   	 returnValue = false
	End If

	FileExist = returnValue
	
	objShell.Run "Log.vbs DEBUG EXIT_IIS_Install_FileExist()",0,true
End Function

Function ClearFile(strFilePath)
	 objShell.Run "Log.vbs DEBUG ENTER_IIS_Install_ClearFile()",0,true
	 
	 objShell.Run "Log.vbs NOTIFICATION CLEARING_INSTALL_FILE",0,true
	 Set objFSO = CreateObject("Scripting.FileSystemObject")
	 Set objTextFile = objFSO.CreateTextFile(strFilePath,true)
	 objTextFile.Close
	 objShell.Run "Log.vbs NOTIFICATION INSTALL_FILE_CLEARED",0,true
	
	objShell.Run "Log.vbs DEBUG EXIT_IIS_Install_ClearFile()",0,true
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