' Author: Thomas Hugo Williams

Const WE.VERSION$ = "Version 0.1"
Const WE.PROG_DIR$ = we.get_parent$(Mm.Info$(Current))
Const WE.INSTALL_DIR$ = we.get_install_dir$()

Dim we.quit% = 0

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

' Gets the name of file/directory 'f$' minus any path information.
Function we.get_name$(f$)
  Local i%
  For i% = Len(f$) To 1 Step -1
    If InStr("/\", Mid$(f$, i%, 1)) > 0 Then Exit For
  Next i%
  we.get_name$ = Mid$(f$, i% + 1)
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

Function we.is_menu_launched%()
  we.is_menu_launched% = InStr(Mm.CmdLine$, "--menu") > 0
End Function

Sub we.run_menu()
  we.run_program(WE.INSTALL_DIR$ + "/menu/menu.bas")
End Sub

Sub we.run_program(f$, cmdline$)
  Execute("Run " + Chr$(34) + f$ + Chr$(34) + ", " + cmdline$)
End Sub

Sub we.clear_keyboard_buffer()
  Do While Inkey$ <> "" : Loop
End Sub

Sub we.wait_for_quit()
  Do While Not we.is_quit_pressed%() : Loop
End Sub

Function we.is_quit_pressed%()
  If Not we.quit% Then we.quit% = LCase$(Inkey$) = "q"
  we.is_quit_pressed% = we.quit%
End Function

Sub we.end_program()
  we.wait_for_quit()
  Page Write 0
  If we.is_menu_launched%() Then we.run_menu()
  End
End Sub

Sub we.wait_for_key()
  Local ch$
  Do While ch$ = "" : ch$ = Inkey$ : Loop
  If ch$ = "q" Then we.quit% = 1
End Sub

Sub we.title(title$, can_continue%)
  Text 0, 0, title$, "", 2
  Local s$ = "Press [Esc] to return to the menu"
  If can_continue% Then s$ = s$ + ", or any other key to continue"
  Text 2, 25, s$, "", 1
End Sub
