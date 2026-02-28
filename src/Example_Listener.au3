; Example_Listener.au3
#include <GUIConstantsEx.au3>
#include "Link2AutoIt.au3"

; Settings must match LinkHost.exe
Global Const $WM_USER_SIGNAL = 0x0401
Global Const $LISTENER_TITLE = "Link2AutoIt_Listener"

; Create a hidden GUI to catch the Windows Message
Local $hGUI = GUICreate($LISTENER_TITLE)
GUIRegisterMsg($WM_USER_SIGNAL, "_OnNewDataReceived")

_L2A_Init() ; initialization to ensure Proxy is running

__DW("Listener is active. Title: " & $LISTENER_TITLE & @CRLF)
__DW("Waiting for signals from LinkHost.exe..." & @CRLF)

; Main Loop
While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            ExitLoop
    EndSwitch
WEnd

;---------------------------------------------------------------------------------------
Func _OnNewDataReceived($hWnd, $iMsg, $wParam, $lParam) ; This function triggers AUTOMATICALLY when a link is hovered

	; Get the domain first to check the blacklist
    Local $sDomain = _L2A_GetField("domain")

    ; If it's blacklisted, Return
    If _L2A_Blacklist($sDomain) Then Return $GUI_RUNDEFMSG

    Local Static $sPrevUrl = ""
    Local Static $hDebounceTimer = TimerInit()

    ; Extract data using the new JSON field extractor (v3.0)
    Local $sUrl      = _L2A_GetField("url")
    Local $sAction   = _L2A_GetField("type")      ; HOVER or CLICK
    Local $sMType    = _L2A_GetField("mediaType") ; LINK or IMAGE
    Local $sLinkText = _L2A_GetField("text")

    ; Debounce logic: Process if it's a new URL OR if enough time has passed
    If $sUrl <> "" And ($sUrl <> $sPrevUrl Or TimerDiff($hDebounceTimer) > 2000) Then
        $sPrevUrl = $sUrl
        $hDebounceTimer = TimerInit()

        Local $iIcon = 1 ; Information Icon
        Local $sTitle = "Link Captured"

        ; Logic based on rich metadata from the extension
        If $sMType == "IMAGE" Then
            $sTitle = "🖼️ Image from " & $sDomain
        ElseIf _L2A_IsDownload($sUrl) Then
            $iIcon = 2 ; Warning Icon
            $sTitle = "💾 Download Detected!"
        Else
            $sTitle = "🔗 " & $sDomain
        EndIf

        ; Differentiate between hovering and clicking
        If $sAction == "CLICK" Then $sTitle = "🚀 CLICK: " & $sTitle

        ; Clean up long URLs for the ToolTip UI
        Local $sDisplayUrl = $sUrl
        If StringLen($sDisplayUrl) > 85 Then $sDisplayUrl = StringLeft($sDisplayUrl, 82) & "..."

        ; Output to UI and Debug Console
        _L2A_ToolTip($sDisplayUrl & @CRLF & "Info: " & $sLinkText, Default, Default, $sTitle, $iIcon)
        __DW("Signal Received! [" & $sAction & "] -> " & $sUrl & @CRLF)
    EndIf

    Return $GUI_RUNDEFMSG
EndFunc
;---------------------------------------------------------------------------------------
