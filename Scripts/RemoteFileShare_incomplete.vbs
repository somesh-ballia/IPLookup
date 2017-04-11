strComputer="ct-n0016"
strUser="CLEAR-TRAIL\somesh.pathak"
strDomain=""
strPassword="somesh@#$"
strFolder = "D:\Test"
strShareName = "TestShare"
strShareDescription = "Public share for test."
Const MAXIMUM_CONNECTIONS = 25
Const FILE_SHARE = 0

Set SWBemlocator = CreateObject("WbemScripting.SWbemLocator")
Set objWMIService = SWBemlocator.ConnectServer(strComputer,"root\CIMV2",strUser, strPassword)
SWBemlocator.Security_.ImpersonationLevel = 3
If Err.Number<>"0" Then WScript.Echo "Cannot find machine: "& strComputer & WScript.Quit
Set objWMIService = GetObject("winmgmts:"& "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set objNewShare = objWMIService.Get("Win32_Share")
errReturn = objNewShare.Create (strFolder, strShareName, FILE_SHARE, MAXIMUM_CONNECTIONS, strShareDescription)
Wscript.Echo errReturn