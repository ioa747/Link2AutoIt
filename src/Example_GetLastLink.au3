; Example_GetLastLink.au3
#include "Link2AutoIt.au3" ; Include your new library

_L2A_Init() ; initialization to ensure Proxy is running

HotKeySet("{F8}", "_GetLastLink") ; Set Hotkey to trigger the function

; Main Loop
While 1
    Sleep(100)
WEnd

; Function triggered by F8
Func _GetLastLink()
    ; Use the UDF function to get specific fields
    Local $sUrl = _L2A_GetURL()
    Local $sDomain = _L2A_GetDomain()
    Local $sAction = _L2A_GetActionType()

    ; Check if we actually have data
    If $sUrl <> "" Then
		Local $sDisplayUrl = $sUrl
		If StringLen($sDisplayUrl) > 80 Then $sDisplayUrl = StringLeft($sDisplayUrl, 77) & "..."
		_L2A_ToolTip($sDisplayUrl, Default, Default, "URL:")
        ConsoleWrite("--- Link Caught ---" & @CRLF)
        ConsoleWrite("Action: " & $sAction & @CRLF)
        ConsoleWrite("Domain: " & $sDomain & @CRLF)
        ConsoleWrite("URL:    " & $sUrl & @CRLF)
        ConsoleWrite("-------------------" & @CRLF)
    Else
        ConsoleWrite("! No link found in shared memory. Make sure Proxy.exe is running." & @CRLF)
    EndIf
EndFunc
