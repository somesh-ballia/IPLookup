strComputer="ct-n0016"
strUser="CLEAR-TRAIL\somesh.pathak"
strDomain=""
strPassword="somesh@#$"
Set SWBemlocator = CreateObject("WbemScripting.SWbemLocator")
Set objWMIService = SWBemlocator.ConnectServer(strComputer,"root\CIMV2",strUser, strPassword)
SWBemlocator.Security_.ImpersonationLevel = 3
If Err.Number<>"0" Then WScript.Echo "Cannot find machine: "& strComputer & WScript.Quit
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2:Win32_Process")
errReturn = objWMIService.Create("cmd.exe /c md D:\newfolder_somesh", Null, Null, intProcessID)