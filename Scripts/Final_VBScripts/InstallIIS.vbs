Dim strLogType
Dim I386_PATH
Dim SETUP_FILE_PATH

ParseConfig()
Execute()

Function Execute()

	CreateInstallFile(SETUP_FILE_PATH)
	WriteRegsistrySettings(strI386Path)
	ExecuteCommand(SETUP_FILE_PATH)
	
End Function

Function ParseConfig()	
		
		I386_PATH = "\\ct-0026\Windows_Server_2003\ISO_Contents"
		SETUP_FILE_PATH = "IIS_Setup.txt"
		
End Function

Function CreateInstallFile(strFilePath)

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
	

End Function

Function WriteRegsistrySettings(strI386Path)
	Set Shell = CreateObject( "WScript.Shell" )
	Shell.RegWrite "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\SourcePath",strI386Path,"REG_SZ"
	Shell.RegWrite "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\ServicePackSourcePath",strI386Path,"REG_SZ"
End Function

Function IsIISInstalled()
	Dim bReturn
	Set WshShell = CreateObject( "WScript.Shell" )
	strDisplayName = WshShell.RegRead ( "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W3SVC\DisplayName" )
	if strDisplayName = "World Wide Web Publishing Service" Then 
		bReturn = True
	else
		bReturn = False
	End IF
	
	IsIISInstalled = bReturn
	
End Function

Function ExecuteCommand(strFilePath)
	Set WshShell = WScript.CreateObject("WScript.Shell")
	WshShell.Run "sysocmgr /i:%windir%\inf\sysoc.inf /u:"&strFilePath, 0, true	
End Function

Function WriteFileText(sFilePath, sText)
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

End Function

Function FileExist(strFilePath)

	Dim returnValue 
	Set fso = CreateObject("Scripting.FileSystemObject")
	If (fso.FileExists(strFilePath)) Then
  	  returnValue = true
	Else
   	 returnValue = false
	End If

	FileExist = returnValue

End Function

Function ClearFile(strFilePath)
	 Set objFSO = CreateObject("Scripting.FileSystemObject")
	 Set objTextFile = objFSO.CreateTextFile(strFilePath,true)
	 objTextFile.Close
End Function