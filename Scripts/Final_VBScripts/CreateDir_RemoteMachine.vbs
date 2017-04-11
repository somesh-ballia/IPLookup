strComputer="CT-N0060"
strUserLogin="ct-n0060\iplookup"
strDomain=""
strPassword="iplookup"
strFolder = "D:\11CPS1"
Set SWBemlocator = CreateObject("WbemScripting.SWbemLocator")
Set objWMIService = SWBemlocator.ConnectServer(strComputer,"root\CIMV2",strUserLogin, strPassword)
SWBemlocator.Security_.ImpersonationLevel = 3
If Err.Number<>"0" Then WScript.Echo "Cannot find machine: "& strComputer & WScript.Quit
Set objWMIService = objWMIService.get("Win32_Process")
errReturn = objWMIService.Create("cmd.exe /c md "&strFolder, Null, Null, intProcessID)
wscript.echo errReturn