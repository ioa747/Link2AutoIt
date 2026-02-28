; Proxy.au3
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\Icons\Proxy.ico
#AutoIt3Wrapper_Outfile_x64=Proxy.exe
#AutoIt3Wrapper_UseX64=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <WinAPIFiles.au3>

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