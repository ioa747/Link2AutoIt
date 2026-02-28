; Link2AutoIt.au3
#include-once
#include <WinAPIFiles.au3>
#include <WinAPIHObj.au3>

; === Global Configuration ===
Global $g__DebugInfo = True
Global Const $L2A_MAPPING_NAME = "Local\Link2AutoIt"
Global Const $L2A_MAPPING_SIZE = 8192
Global Const $L2A_PROXY_EXE = "Proxy.exe"

;---------------------------------------------------------------------------------------
Func _L2A_Init() ; initialization to ensure Proxy is running
	Local $hMapping = _WinAPI_OpenFileMapping($L2A_MAPPING_NAME)

	If Int($hMapping) = 0 Then
		__DW("L2A: Proxy not detected. Attempting to start..." & @CRLF)
		If Not ProcessExists($L2A_PROXY_EXE) Then
			Local $sInstallDir = @LocalAppDataDir & "\Link2AutoIt\"
			Local $sProxyPath = $sInstallDir & $L2A_PROXY_EXE

			; close any orphaned LinkHost to unlock the log
			If ProcessExists("LinkHost.exe") Then ProcessClose("LinkHost.exe")
			FileDelete($sInstallDir & "LinkHost.log")

			If FileExists($sProxyPath) Then
				Run($sProxyPath, $sInstallDir, @SW_HIDE)
				ProcessWait($L2A_PROXY_EXE, 5) ; Increased wait time to 5s
				Sleep(1000) ; Give it a full second to initialize memory
				__DW("L2A: Proxy started successfully." & @CRLF)
			Else
				__DW("L2A: Fatal Error - Proxy.exe missing at: " & $sProxyPath & @CRLF)
				Return SetError(2, 0, False)
			EndIf
		EndIf

		; Re-verify
		$hMapping = _WinAPI_OpenFileMapping($L2A_MAPPING_NAME)
		If Int($hMapping) = 0 Then
			__DW("L2A: Failed to connect to shared memory after start." & @CRLF)
			Return SetError(3, 0, False)
		EndIf
	EndIf

	_WinAPI_CloseHandle($hMapping)
	Return True
EndFunc   ;==>_L2A_Init
;---------------------------------------------------------------------------------------
Func _L2A_GetRawData() ; Function to read the entire raw JSON from shared memory
	; Ensure environment is ready
	If Not _L2A_Init() Then Return SetError(1, 0, "")

	Local $hMapping = _WinAPI_OpenFileMapping($L2A_MAPPING_NAME)
	If Int($hMapping) = 0 Then Return SetError(1, 0, "")

	Local $pAddress = _WinAPI_MapViewOfFile($hMapping)
	Local $tMemory = DllStructCreate("byte[" & $L2A_MAPPING_SIZE & "]", $pAddress)

	Local $bData = DllStructGetData($tMemory, 1)
	Local $sJson = BinaryToString($bData, 4) ; UTF-8

	_WinAPI_UnmapViewOfFile($pAddress)
	_WinAPI_CloseHandle($hMapping)

	Return $sJson
EndFunc   ;==>_L2A_GetRawData
;---------------------------------------------------------------------------------------
Func _L2A_GetField($sField) ; Function to extract a specific field from the JSON string
	; Fetch the raw data stored in shared memory by the Proxy/LinkHost
	Local $sJson = _L2A_GetRawData()
	If $sJson == "" Then Return ""

	; Extract the value of the specific field using Regular Expressions
	; It searches for the pattern: "fieldName":"value"
	Local $aMatch = StringRegExp($sJson, '"' & $sField & '":"(.*?)"', 1)

	; If a match is found, return the captured group (the value)
	If Not @error Then Return $aMatch[0]

	Return "" ; Return empty string if the field doesn't exist or regex fails
EndFunc   ;==>_L2A_GetField
;---------------------------------------------------------------------------------------
Func _L2A_Blacklist($sDomain, $bState = "") ; Function to Get, Add, or Remove domains from the Blacklist
	; $sDomain: The domain to check/process
	; $bState:  "" [default] = Getter (returns True if blacklisted)
	;           True         = Setter (adds domain to blacklist)
	;           False        = Setter (removes domain from blacklist)

	Local Static $sList = "|doubleclick.net|google-analytics.com|adnxs.com|amazon-adsystem.com|"

	If $sDomain = "" Then Return False
	$sDomain = StringStripWS($sDomain, 3) ; Clean spaces
	Local $sSearchTerm = "|" & $sDomain & "|"

	; GETTER MODE
	If $bState = "" Then
		Return StringInStr($sList, $sSearchTerm) > 0
	EndIf

	; SETTER MODE (Add)
	If $bState = True Then
		If Not StringInStr($sList, $sSearchTerm) Then
			$sList &= $sDomain & "|"
		EndIf
		Return True
	EndIf

	; SETTER MODE (Remove)
	If $bState = False Then
		If StringInStr($sList, $sSearchTerm) Then
			$sList = StringReplace($sList, $sSearchTerm, "|")
			Return True
		EndIf
		Return False
	EndIf
EndFunc   ;==>_L2A_Blacklist
;---------------------------------------------------------------------------------------
Func _L2A_GetURL()
	Return _L2A_GetField("url")
EndFunc   ;==>_L2A_GetURL
;---------------------------------------------------------------------------------------
Func _L2A_GetDomain()
	Local $sDomain = _L2A_GetField("domain")
	; Fallback: Extract from URL if domain field is empty
	If $sDomain == "" Then
		Local $sUrl = _L2A_GetURL()
		Local $aExtract = StringRegExp($sUrl, '(?i)https?://([^/]+)', 1)
		If Not @error Then $sDomain = $aExtract[0]
	EndIf
	Return $sDomain
EndFunc   ;==>_L2A_GetDomain
;---------------------------------------------------------------------------------------
Func _L2A_GetActionType()
	Return _L2A_GetField("type")
EndFunc   ;==>_L2A_GetActionType
;---------------------------------------------------------------------------------------
Func _L2A_IsImage($sUrl = Default)
	If $sUrl = Default Then $sUrl = _L2A_GetURL()
	Return StringRegExp($sUrl, '(?i)\.(jpg|jpeg|png|gif|bmp|webp)(\?|#|$)')
EndFunc   ;==>_L2A_IsImage
;---------------------------------------------------------------------------------------
Func _L2A_IsDownload($sUrl = Default)
	If $sUrl = Default Then $sUrl = _L2A_GetURL()
	Return StringRegExp($sUrl, '(?i)\.(zip|rar|7z|exe|msi|pdf)(?:\?|#|$)')
EndFunc   ;==>_L2A_IsDownload
;---------------------------------------------------------------------------------------
Func _L2A_ToolTip($sText, $iX = Default, $iY = Default, $sTitle = "", $iIcon = 0, $iTimeout = 2000, $iOptions = 0)
	AdlibUnRegister("__L2A_ToolTipKiller") ; This prevents the previous timer from closing the new tooltip.
	If $iX = Default Then $iX = MouseGetPos(0) + 15
	If $iY = Default Then $iY = MouseGetPos(1) + 15
	ToolTip($sText, $iX, $iY, $sTitle, $iIcon, $iOptions)
	AdlibRegister("__L2A_ToolTipKiller", $iTimeout)
EndFunc   ;==>_L2A_ToolTip
;---------------------------------------------------------------------------------------
Func __L2A_ToolTipKiller()
	ToolTip("") ; Hide the tooltip
	AdlibUnRegister("__L2A_ToolTipKiller") ; unregister itself.
EndFunc   ;==>__L2A_ToolTipKiller
;---------------------------------------------------------------------------------------
Func __DW($sString, $iErrorNoLineNo = 1, $iLine = @ScriptLineNumber, $iError = @error, $iExtended = @extended)
	If Not $g__DebugInfo Then Return SetError($iError, $iExtended, 0)
	Local $iReturn, $sLine
	If $iErrorNoLineNo = 1 Then
		If $iError Then
			$iReturn = ConsoleWrite("@@(" & $iLine & ") :: @error:" & $iError & ", @extended:" & $iExtended & ", " & $sString)
		Else
			$iReturn = ConsoleWrite("+>(" & $iLine & ") :: " & $sString)
		EndIf
	Else
		$iReturn = ConsoleWrite($sString)
	EndIf
	; Remarks: The @error and @extended are not set on return leaving them as they were before calling.
	Return SetError($iError, $iExtended, $iReturn)
EndFunc   ;==>__DW
;---------------------------------------------------------------------------------------
