; LinkHost.au3
#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\Icons\LinkHost.ico
#AutoIt3Wrapper_Outfile_x64=LinkHost.exe
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Change2CUI=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <File.au3>
#include <WinAPIFiles.au3>
#include <WinAPIHObj.au3>

; Shared Memory Settings
Global Const $sMappingName = "Local\Link2AutoIt"
Global Const $iMappingSize = 8192

Global $g_bFileWriteLog = True

_WL("--- LinkHost Triggered ---")

; --- 1. Read raw data from STDIN (Browser's Native Messaging) ---
Local $bRaw = ConsoleRead(0, True)

If BinaryLen($bRaw) > 4 Then
	; Convert binary to UTF-8 String
	Local $sRaw = BinaryToString($bRaw, 4)
	_WL("Raw Data Received: " & $sRaw)

	; --- 2. Validate the data ---
	; Check if the payload contains our expected 'action' field
	If StringInStr($sRaw, '"action"') Then

		; --- 3. Connecting to the Proxy via Shared Memory ---
		Local $hMapping = _WinAPI_OpenFileMapping($sMappingName)

		If $hMapping <> 0 Then
			Local $pAddress = _WinAPI_MapViewOfFile($hMapping)

			; Convert the incoming JSON string to UTF-8 Binary for safe transfer
			Local $bData = StringToBinary($sRaw, 4)

			; Define the memory structure as a raw BYTE array (not char)
			Local $tMemory = DllStructCreate("byte[" & $iMappingSize & "]", $pAddress)

			; Wipe the memory area to ensure no leftovers from previous calls
			_WinAPI_ZeroMemory($pAddress, $iMappingSize)

			; Write the binary data into the shared memory
			DllStructSetData($tMemory, 1, $bData)

			_WL("Successfully wrote " & BinaryLen($bData) & " bytes to Shared Memory.")

			_SendSignal()

			; Cleanup resources
			_WinAPI_UnmapViewOfFile($pAddress)
			_WinAPI_CloseHandle($hMapping)
		Else
			_WL("Error: Proxy mapping not found! Ensure Proxy.exe is running.")
		EndIf

	Else
		_WL("Error: Invalid JSON structure (field 'action' missing).")
	EndIf
Else
	_WL("Error: Received empty or invalid payload from Browser.")
EndIf

; 4. Required response to keep the browser happy
_ReplyOK()

_WL("--- LinkHost Exiting ---")
Exit

; Function to send "OK" to Browser (Native Messaging Protocol)
Func _ReplyOK()
	Local $sResp = '{"status":"ok"}'
	Local $bBody = StringToBinary($sResp, 4)
	Local $iLen = BinaryLen($bBody)

	; Create 4-byte header (Length)
	Local $tHeader = DllStructCreate("uint")
	DllStructSetData($tHeader, 1, $iLen)

	; Write Header and Body to STDOUT
	ConsoleWrite(BinaryToString(DllStructGetData(DllStructCreate("byte[4]", DllStructGetPtr($tHeader)), 1)))
	ConsoleWrite(BinaryToString($bBody))
EndFunc   ;==>_ReplyOK

Func _SendSignal()
    Local Const $WM_USER_SIGNAL = 0x0401
    Local Const $sListenerTitle = "Link2AutoIt_Listener"

    ; Εύρεση του Handle του Listener
    Local $hWnd = WinGetHandle($sListenerTitle)

    If $hWnd Then
        _WL("Sending signal to Listener (HWND: " & $hWnd & ")")
        ; Χρήση PostMessage για να μη "κολλήσει" ο LinkHost αν ο Listener είναι απασχολημένος
        DllCall("user32.dll", "bool", "PostMessageW", "hwnd", $hWnd, "uint", $WM_USER_SIGNAL, "wparam", 0, "lparam", 0)
    Else
        _WL("Signal skip: Listener window not found.")
    EndIf
EndFunc

; Log File (for debugging)
Func _WL($sMsg)
	If Not $g_bFileWriteLog Then Return
	_FileWriteLog(@ScriptDir & "\LinkHost.log", "PID:" & @AutoItPID & " " & $sMsg & @CRLF)
EndFunc   ;==>_WL
