strComputer = "192.168.129.76"
if fPingTest(strComputer) then strStatus = "UP" else strStatus = "DOWN"
WScript.StdOut.write strStatus

function fPingTest( strComputer )
        dim objShell,objPing
        dim strPingOut, flag
        set objShell = CreateObject("Wscript.Shell")
        set objPing = objShell.Exec("ping " & strComputer)
    strPingOut = objPing.StdOut.ReadAll
    if instr(LCase(strPingOut), "reply") then
        flag = TRUE
        else
                flag = FALSE
        end if
        fPingTest = flag
 
end function