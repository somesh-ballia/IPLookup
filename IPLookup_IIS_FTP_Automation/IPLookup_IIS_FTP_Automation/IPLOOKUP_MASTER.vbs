'change this version if running on different version of windows server 2003
strRequiredOS = "5.2.3790"
Dim objShell
Set objShell = Wscript.CreateObject("WScript.Shell")
strConfigFileName = "Config.ini"
Dim ENABLE_SETUP_INSTALL
Dim ENABLE_USER_FOLDER_CREATION
Dim ENABLE_FTP_SITE
Main()

Function Main()
	objShell.Run "Log.vbs DEBUG ****************************************************START**************************************************",0,true
	objShell.Run "Log.vbs PROGRESS ****************************************************START**************************************************",0,true
	objShell.Run "Log.vbs DEBUG ENTER_IPLOOKUP_MASTER_Main()",0,true
	
	objShell.Run "Log.vbs NOTIFICATION CHANGING_DEFAULT_EXECUTION_TO_CSCRIPT",0,true	
	objShell.Run "cscript.exe //h:cscript",0,true
	objShell.Run "Log.vbs NOTIFICATION CHANGING_DEFAULT_EXECUTION_TO_CSCRIPT_SUCCESSFUL",0,true	
	objShell.Run "Log.vbs PROGRESS DEFAULT_EXECUTION_ENVIRONMENT_CHNAGED_TO_CSCRIPT",0,true							
	
	IF TRUE = ISValidOS(strRequiredOS) Then
		IF True = ReadConfigFile() Then
			'CHECK IF SERVERINSTALLATION IS REQUIRED
			IF True = ENABLE_SETUP_INSTALL Then
				objShell.Run "Log.vbs NOTIFICATION FTP_SERVER_INSTALLATION_ENABLED",0,true
				'EXECUTE SCRIPT FOR FTP SERVER INSTALLATION
				IF True = InstallFTPServer() Then
					objShell.Run "Log.vbs NOTIFICATION FTP_SERVER_INSTALLATION_SUCCESSFUL",0,true
				Else
					objShell.Run "Log.vbs ERROR ERROR_INSTALLING_FTP_SERVER",0,true	
				End IF
			Else
				objShell.Run "Log.vbs NOTIFICATION FTP_SERVER_INSTALLATION_DISABLED",0,true
			End IF
			
			'CHECK IF FOLDER CREATION IS REQUIRED
			IF True = ENABLE_USER_FOLDER_CREATION Then
				'EXECUTE SCRIPT FOR FTP SERVER INSTALLATION
				objShell.Run "Log.vbs NOTIFICATION FOLDER_CREATION_ENABLED",0,true
				IF True = CreateFolders() Then
					objShell.Run "Log.vbs NOTIFICATION FOLDER_CREATION_SUCCESSFUL",0,true
				Else
					objShell.Run "Log.vbs ERROR ERROR_CREATING_FOLDERS",0,true
				End IF
			Else
				objShell.Run "Log.vbs NOTIFICATION FOLDER_CREATION_DISABLED",0,true
			End IF
			
			'CHECK IF FTP SERVER MANAGEMENT IS REQUIRED
			IF True = ENABLE_FTP_SITE Then
				'EXECUTE SCRIPT FOR FTP SERVER INSTALLATION
				objShell.Run "Log.vbs NOTIFICATION FTP_SITE_MANAGEMENT_ENABLED",0,true
				IF True = ManageFTPSite() Then
					objShell.Run "Log.vbs NOTIFICATION FTP_SITE_MANAGEMENT_SUCCESSFUL",0,true
				Else
					objShell.Run "Log.vbs ERROR ERROR_MANAGING_FTP_SITE",0,true	
				End IF
			Else
				objShell.Run "Log.vbs NOTIFICATION FTP_SITE_MANAGEMENT_DISABLED",0,true
			End IF			
		Else			
			objShell.Run "Log.vbs CRITICAL_ERROR ERROR_READING_CONFIG_FILE",0,true
		End IF
	
	
	ELSE		
		objShell.Run "Log.vbs ERROR CRITICAL_INVALID_OPERATING_SYSTEM_FOUND",0,true
	End IF
	
	objShell.Run "Log.vbs DEBUG EXIT_IPLOOKUP_MASTER_Main()",0,true
	MsgBox "SCRIPT EXECUTION COMPLETE"
	objShell.Run "Log.vbs DEBUG ****************************************************END**************************************************",0,true
	objShell.Run "Log.vbs PROGRESS ****************************************************END**************************************************",0,true
End Function	

Function ReadConfigFile()
	objShell.Run "Log.vbs DEBUG ENTER_IPLOOKUP_MASTER_ReadConfigFile()",0,true
		
	If "1" = ReadIni(strConfigFileName,"GENERAL","ENABLE_SETUP_INSTALL") Then
		ENABLE_SETUP_INSTALL = True		
	Else
		ENABLE_SETUP_INSTALL = False
	End IF
	objShell.Run "Log.vbs PROGRESS ENABLE_SETUP_INSTALL_=_"&ENABLE_SETUP_INSTALL,0,true	
	
	If "1" = ReadIni(strConfigFileName,"GENERAL","ENABLE_USER_REMOTE_FOLDER_CREATION") Then
		ENABLE_USER_FOLDER_CREATION = True
	Else
		ENABLE_USER_FOLDER_CREATION = False
	End IF
	objShell.Run "Log.vbs PROGRESS ENABLE_USER_REMOTE_FOLDER_CREATION_=_"&ENABLE_USER_FOLDER_CREATION,0,true

	If "1" = ReadIni(strConfigFileName,"GENERAL","ENABLE_LOCAL_FOLDER_AND_FTP_SITE_CREATION") Then
		ENABLE_FTP_SITE = True
	Else
		ENABLE_FTP_SITE = False
	End IF
	objShell.Run "Log.vbs PROGRESS ENABLE_LOCAL_FOLDER_AND_FTP_SITE_CREATION_=_"&ENABLE_FTP_SITE,0,true
	
	ReadConfigFile = True
	
	objShell.Run "Log.vbs DEBUG EXIT_IPLOOKUP_MASTER_ReadConfigFile()",0,true
End Function	

Function InstallFTPServer()
	objShell.Run "Log.vbs DEBUG ENTER_IPLOOKUP_MASTER_InstallFTPServer()",0,true
	
	Wscript.echo "EXECUTING SCRIPT FOR INSTALLATION OF FTP SERVER"
	objShell.Run "IIS_Install.vbs",1,true		
	InstallFTPServer = TRUE
	Wscript.echo "FTP SERVER INSTALLATION SCRIPT COMPLETE"
	
	objShell.Run "Log.vbs DEBUG EXIT_IPLOOKUP_MASTER_InstallFTPServer()",0,true
End Function

Function CreateFolders()
	objShell.Run "Log.vbs DEBUG ENTER_IPLOOKUP_MASTER_CreateFolders()",0,true
	
	Wscript.echo "EXECUTING SCRIPT FOR FOLDER CREATION ON REMOTE MACHINES"
	objShell.Run "CreateFolders.vbs",1,true		
	CreateFolders = TRUE		
	Wscript.echo "FOLDER CREATION ON REMOTE MACHINES COMPLETE"	
	
	objShell.Run "Log.vbs DEBUG EXIT_IPLOOKUP_MASTER_CreateFolders()",0,true
End Function

Function ManageFTPSite()
	objShell.Run "Log.vbs DEBUG ENTER_IPLOOKUP_MASTER_ManageFTPSite()",0,true
	
	Wscript.echo "EXECUTING SCRIPT FOR CONFIGURING FTP SITE"	
	IF True = ENABLE_SETUP_INSTALL Then		
		objShell.Run "ManageFTPSite.vbs 1",1,true
		ManageFTPSite = TRUE	
	Else	
		objShell.Run "ManageFTPSite.vbs 0",1,true
		ManageFTPSite = TRUE	
	End IF	
	Wscript.echo "FTP SITE CONFIGURATION COMPLETE"	
	
	objShell.Run "Log.vbs DEBUG EXIT_IPLOOKUP_MASTER_ManageFTPSite()",0,true
End Function

Function IsValidOS(strRequiredOS)
	objShell.Run "Log.vbs DEBUG ENTER_IPLOOKUP_MASTER_IsValidOS()",0,true
	
	Dim strProvidedOS
	Dim retValue
	strComputer = "."
	Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
	Set colOperatingSystems = objWMIService.ExecQuery("SELECT * FROM Win32_OperatingSystem")
	For Each objOperatingSystem in colOperatingSystems
		strProvidedOS = objOperatingSystem.Version
		IF 0 = strComp(strRequiredOS,strProvidedOS) Then
			retValue = TRUE
		Else
			retValue = FALSE
		END If
	Next
	ISValidOS = retValue

	objShell.Run "Log.vbs DEBUG EXIT_IPLOOKUP_MASTER_IsValidOS()",0,true
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