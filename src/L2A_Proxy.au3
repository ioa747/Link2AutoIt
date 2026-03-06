#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\Icons\Proxy.ico
#AutoIt3Wrapper_Outfile_x64=L2A_Proxy.exe
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Comment=L2A_Proxy.exe: is part of Link2AutoIt (The memory 'anchor' that keeps the IPC bridge alive)
#AutoIt3Wrapper_Res_Description=Link2AutoIt is a high-performance bridge between Mozilla Firefox and AutoIt.
#AutoIt3Wrapper_Res_Fileversion=0.0.0.5
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Res_ProductName=Link2AutoIt
#AutoIt3Wrapper_Res_ProductVersion=0.0.0.3
#AutoIt3Wrapper_Res_LegalCopyright=This project is open-source and available under the MIT License.
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
; L2A_Proxy.au3

#include <WinAPIFiles.au3>

Opt("TrayAutoPause", 0) ;0=no pause, 1=Pause

; The name of the memory that everyone will know
Global Const $sMappingName = "Local\Link2AutoIt", $iMappingSize = 8192

; Creating and keeping the memory open FOREVER
Global $hMapping = _WinAPI_CreateFileMapping(-1, $iMappingSize, $sMappingName)
Global $pAddress = _WinAPI_MapViewOfFile($hMapping)

; CHANGED: Use 'byte' instead of 'char' to prevent premature string termination
Global $tMemory = DllStructCreate("byte[" & $iMappingSize & "]", $pAddress)

ConsoleWrite(">>> Proxy is running. Memory mapping is locked (Byte Mode)." & @CRLF)

While 1
    Sleep(1000)
WEnd