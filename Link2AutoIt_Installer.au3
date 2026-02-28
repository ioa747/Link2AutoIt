#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\Icons\zClassic.ico
#AutoIt3Wrapper_Outfile_x64=Link2AutoIt_Installer.exe
#AutoIt3Wrapper_UseX64=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <File.au3>
#include <WinAPIFiles.au3>

; === Configuration ===
Global Const $APP_NAME = "Link2AutoIt"
Global Const $INSTALL_DIR = @LocalAppDataDir & "\" & $APP_NAME
Global Const $REG_KEY = "HKEY_CURRENT_USER\Software\Mozilla\NativeMessagingHosts\com.link2autoit.bridge"
Global Const $PROXY_EXE = "Proxy.exe"
Global Const $HOST_EXE = "LinkHost.exe"
Global Const $ADDON_XPI = "link2autoit.xpi"
Global Const $App_JSON = "com.link2autoit.bridge.json"

_Main()

Func _Main()
	ConsoleWrite(">>> Starting Installation..." & @CRLF)

	; Close running processes to unlock files
	ProcessClose($PROXY_EXE)
	ProcessClose($HOST_EXE)

	; Create Installation Folder
	If Not FileExists($INSTALL_DIR) Then
		If DirCreate($INSTALL_DIR) Then
			_Log("Folder created: " & $INSTALL_DIR)
		Else
			MsgBox(16, "Error", "Could not create installation directory." & @CRLF & $INSTALL_DIR)
			Exit
		EndIf
	EndIf

	; Copy Files
	Local $aExeFiles[3] = [$PROXY_EXE, $HOST_EXE, $ADDON_XPI]
	For $sFile In $aExeFiles
		Local $sSourcePath = ""

		If FileExists(@ScriptDir & "\" & $sFile) Then
			$sSourcePath = @ScriptDir & "\" & $sFile
		ElseIf FileExists(@ScriptDir & "\..\Bin\" & $sFile) Then
			$sSourcePath = @ScriptDir & "\..\Bin\" & $sFile
		EndIf

		If $sSourcePath <> "" Then
			If FileCopy($sSourcePath, $INSTALL_DIR & "\" & $sFile, 9) Then
				_Log("Copied: " & $sFile & " from " & $sSourcePath)
			Else
				_Log("Failed to copy: " & $sFile)
			EndIf
		Else
			_Log("Source file not found: " & $sFile)
		EndIf
	Next

	; Creation of com.link2autoit.bridge.json file
	Local $hFile = FileOpen($INSTALL_DIR & "\" & $App_JSON, $FO_UTF8_NOBOM + $FO_OVERWRITE)
	If $hFile <> -1 Then
		FileWrite($hFile, _Make_App_JSON())
		FileClose($hFile)
		_Log("Created Native Messaging Host JSON: " & $App_JSON)
	Else
		_Log("Failed to Create: " & $App_JSON)
	EndIf

	; Registry Registration
	If RegWrite($REG_KEY, "", "REG_SZ", $INSTALL_DIR & "\" & $App_JSON) Then
		_Log("Registry key created successfully.")
	Else
		_Log("Failed to write to Registry.")
	EndIf

	; Prompt Firefox to install the signed XPI
	Local $sXpiPath = $INSTALL_DIR & "\" & $ADDON_XPI
	If FileExists($sXpiPath) Then
		_Log("Launching Firefox for XPI installation...")
		ShellExecute("firefox.exe", '"' & $sXpiPath & '"')
	EndIf

	MsgBox(64, "Installation Complete", "The Native Messaging host has been " & @CRLF & "installed and registered." & @CRLF & "Location: " & $INSTALL_DIR)
	ShellExecute($INSTALL_DIR)
EndFunc   ;==>_Main

Func _Log($sMsg)
	ConsoleWrite("+> " & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & " : " & $sMsg & @CRLF)
	FileWriteLine($INSTALL_DIR & "\install.log", @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & " : " & $sMsg)
EndFunc   ;==>_Log

Func _Make_App_JSON()
	Local $sLinkHostPath = StringReplace($INSTALL_DIR & "\" & $HOST_EXE, "\", "\\")
	Local $sTxt = "{" & @CRLF & _
			'  "name": "com.link2autoit.bridge",' & @CRLF & _
			'  "description": "Link2AutoIt Native Messaging Host",' & @CRLF & _
			'  "path": "' & $sLinkHostPath & '",' & @CRLF & _
			'  "type": "stdio",' & @CRLF & _
			'  "allowed_extensions": [ "link2autoit@autoit" ]' & @CRLF & _
			"}"
	Return $sTxt
EndFunc   ;==>_Make_App_JSON
