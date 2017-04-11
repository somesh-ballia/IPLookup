strLogFilePath = "Log.txt"
strLogFilePath_Progress = "Progress.txt"
Dim strPROGRESS
Dim ArgumentObject
Dim strLogType
Dim strMessage
strPROGRESS = "PROGRESS"
Set ArgumentObject=Wscript.Arguments
strLogType=ArgumentObject.Item(0)
strMessage=ArgumentObject.Item(1)

IF Not StrComp(strLogType,strPROGRESS) Then	
	Progress strLogType,strMessage
Else
	Log strLogType,strMessage
End If

Function Log(strLogTypeL,strMessageL)
	Dim objFSO 'As FileSystemObject
    Dim objTextFile 'As Object
   
    Const ForReading = 1
    Const ForWriting = 2
    Const ForAppending = 8
   
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    bFileExist = FileExist(strLogFilePath)

    if 	false = bFileExist Then
    	Set objTextFile = objFSO.CreateTextFile(strLogFilePath,true)
    else 
        Set objTextFile = objFSO.OpenTextFile(strLogFilePath,ForAppending,true)
    End IF

    ' Write a line.
    objTextFile.Write(strLogTypeL)
	objTextFile.Write(" , ")
    objTextFile.Write(strMessageL)
	objTextFile.WriteLine("")
    objTextFile.Close
    'objTextFile.Close

End Function

Function Progress(strLogTypeP,strMessageP)
	
	Dim objFSO 'As FileSystemObject
    Dim objTextFile 'As Object
   
    Const ForReading = 1
    Const ForWriting = 2
    Const ForAppending = 8
   
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    bFileExist = FileExist(strLogFilePath_Progress)

    if 	false = bFileExist Then
    	Set objTextFile = objFSO.CreateTextFile(strLogFilePath_Progress,true)
    else 
        Set objTextFile = objFSO.OpenTextFile(strLogFilePath_Progress,ForAppending,true)
    End IF

    ' Write a line.
    objTextFile.Write(strLogTypeP)
	objTextFile.Write(" , ")
    objTextFile.Write(strMessageP)
	objTextFile.WriteLine("")
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