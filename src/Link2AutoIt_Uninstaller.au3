#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\Icons\zClassic.ico
#AutoIt3Wrapper_Outfile_x64=Link2AutoIt_Uninstaller.exe
#AutoIt3Wrapper_UseX64=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <MsgBoxConstants.au3>

; === Configuration (Must match the Installer) ===
Global Const $APP_NAME = "Link2AutoIt"
Global Const $INSTALL_DIR = @LocalAppDataDir & "\" & $APP_NAME
Global Const $REG_KEY = "HKEY_CURRENT_USER\Software\Mozilla\NativeMessagingHosts\com.link2autoit.bridge"
Global Const $EXT_REG_KEY = "HKEY_CURRENT_USER\Software\Mozilla\Extensions"
Global Const $EXT_ID = "link2autoit@autoit"

_Uninstall()

Func _Uninstall()
    Local $iConfirm = MsgBox($MB_YESNO + $MB_ICONQUESTION, "Uninstall Link2AutoIt", _
        "Are you sure you want to completely remove Link2AutoIt and all its components?")

    If $iConfirm <> $IDYES Then Exit

    ; 1. Kill running processes
    ProcessClose("Proxy.exe")
    ProcessClose("LinkHost.exe")
    _Log("Processes stopped (if they were running).")

    ; 2. Remove Registry Entries (Native Messaging Host)
    If RegDelete($REG_KEY) Then
        _Log("Native Messaging Registry key removed.")
    EndIf

    ; 3. Remove Extension Registry Entry (if installed permanently)
    If RegDelete($EXT_REG_KEY, $EXT_ID) Then
        _Log("Extension Registry entry removed.")
    EndIf

    ; 4. Delete Installation Folder
    If FileExists($INSTALL_DIR) Then
        If DirRemove($INSTALL_DIR, 1) Then ; 1 = recurse (delete all files)
            _Log("Installation folder deleted: " & $INSTALL_DIR)
        Else
            _Log("Warning: Could not delete folder. Some files might be in use.")
        EndIf
    EndIf

    MsgBox($MB_ICONINFORMATION, "Done", "Link2AutoIt has been successfully uninstalled.")
EndFunc

Func _Log($sMsg)
    ; Simple console log for the Uninstaller
    ConsoleWrite("!> " & $sMsg & @CRLF)
EndFunc