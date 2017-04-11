strFolder = "\\192.168.129.76\TestShare"
Dim fso, msg
Set fso = CreateObject("Scripting.FileSystemObject")
If (fso.FolderExists(strFolder)) Then
    msg = fldr & " exists."
Else
    msg = fldr & " doesn't exist."
End If
 Wscript.Echo msg