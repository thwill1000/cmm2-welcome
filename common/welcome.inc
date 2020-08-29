' Author: Thomas Hugo Williams

Const WE.VERSION$ = "Version 0.1"
Const WE.PROG_DIR$ = we.get_parent$(Mm.Info$(Current))
Const WE.INSTALL_DIR$ = we.get_install_dir$()
Const WE.QUIT_KEY$ = "Q"

Dim we.quit% = 0

Sub we.check_firmware_version()
  If Mm.Info(Version) < (5.0505-0.0001) Then Error "Requires firmware version 5.05.05 or later"
End Sub

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
  Cls
  Print : Print "Loading..."
  Execute("Run " + Chr$(34) + f$ + Chr$(34) + ", " + cmdline$)
End Sub

Sub we.clear_keyboard_buffer()
  Do While Inkey$ <> "" : Loop
End Sub

Sub we.end_program()
  Do While Not we.is_quit_pressed%() : Loop
  Page Write 0
  If we.is_menu_launched%() Then we.run_menu()
  End
End Sub

Function we.is_quit_pressed%()
  If Not we.quit% Then we.quit% = we.is_quit_key%(Inkey$)
  we.is_quit_pressed% = we.quit%
End Function

Function we.is_quit_key%(k$)
  we.is_quit_key% = UCase$(k$) = WE.QUIT_KEY$
End Function

Function we.is_menu_launched%()
  we.is_menu_launched% = InStr(Mm.CmdLine$, "--menu") > 0
End Function

Sub we.wait_for_key()
  Local k$
  Do While k$ = "" : k$ = Inkey$ : Loop
  If we.is_quit_key%(k$) Then we.quit% = 1
End Sub
