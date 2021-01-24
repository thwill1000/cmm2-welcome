' Author: Thomas Hugo Williams

Const WE.VERSION$ = "Version 1.0.0"
Const WE.PROG_DIR$ = we.get_parent$(Mm.Info$(Current))
Const WE.INSTALL_DIR$ = we.get_install_dir$()
Const WE.QUIT_KEY$ = "Q"

Dim we.quit% = 0

Sub we.check_firmware_version(v$)
  If v$ = "" Then v$ = "5.06.00"

  Local actual$ = we.sanitise_firmware_version$(Str$(Mm.Info(Version)))
  Local desired$ = we.sanitise_firmware_version$(v$)

  If actual$ < desired$ Then
    Cls
    Print "Requires firmware version " v$ " or later."
    Print "Press any key to exit"
    Local k$ = we.wait_for_key$()
    we.end_program()
  EndIf
End Sub

Function we.sanitise_firmware_version$(v$)
  Local i%, s$
  For i% = 1 To Len(v$)
    If InStr("0123456789", Mid$(v$, i%, 1)) > 0 Then s$ = s$ + Mid$(v$, i%, 1)
  Next i%
  Do While Len(s$) < 5 : s$ = s$ + "0" : Loop
  If Len(s$) > 5 Then Error "Unexpected firmware version format: " + v$
  we.sanitise_firmware_version$ = s$
End Function

Function we.get_install_dir$()
  Local d$ = WE.PROG_DIR$
  Do While d$ <> ""
    ' The 'welcome' directory is the first one we encounter containing a 'welcome.bas' file.
    If Mm.Info(FileSize d$ + "/welcome.bas") <> -1 Then
      we.get_install_dir$ = d$
      Exit Function
    EndIf
    d$ = we.get_parent$(d$)
  Loop

  Error "Failed to determine 'welcome' directory"
End Function

' Gets the parent directory of 'f$', or the empty string if it does not have one.
Function we.get_parent$(f$)
  Local i%

  For i% = Len(f$) To 1 Step -1
    If InStr("/\", Mid$(f$, i%, 1)) > 0 Then Exit For
  Next i%

  If i% = 0 Then
    we.get_parent$ = ""
  Else
    we.get_parent$ = Left$(f$, i% - 1)
  EndIf
End Function

Sub we.run_menu()
  Local i%, j%
  Local menu_label$ = ""
  i% = InStr(Mm.CmdLine$, "--menu")
  If i% > 0 Then
    i% = i% + 7
    j% = InStr(i%, Mm.CmdLine$ + " ", " ")
    menu_label$ = Mid$(Mm.CmdLine$, i%, j% - i%)
  EndIf
  we.run_program(WE.INSTALL_DIR$ + "/menu/menu.bas", menu_label$)
End Sub

Sub we.run_program(f$, cmdline$)
  Mode 1,8
  Page Write 0
  Cls
  Print : Print "Loading '"; f$; "'..."
  Execute("Run " + Chr$(34) + f$ + Chr$(34) + ", " + cmdline$)
End Sub

Sub we.end_program()
  Page Write 0
  If we.is_menu_launched%() Then we.run_menu()
  End
End Sub

Function we.is_menu_launched%()
  we.is_menu_launched% = InStr(Mm.CmdLine$, "--menu") > 0
End Function

Sub we.clear_keyboard_buffer()
  Do While Inkey$ <> "" : Loop
End Sub

Function we.is_quit_pressed%()
  If Not we.quit% Then we.quit% = we.is_quit_key%(Inkey$)
  we.is_quit_pressed% = we.quit%
End Function

Function we.is_quit_key%(k$)
  we.is_quit_key% = UCase$(k$) = WE.QUIT_KEY$
End Function

Function we.wait_for_key$()
  Local k$
  Do While k$ = "" : k$ = Inkey$ : Loop
  If we.is_quit_key%(k$) Then we.quit% = 1
  we.wait_for_key$ = k$
End Function

Sub we.wait_for_quit()
  Local k$
  Do While Not we.quit%
    k$ = we.wait_for_key$()
  Loop
End Sub
