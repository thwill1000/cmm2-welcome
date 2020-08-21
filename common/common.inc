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

' Runs the first .bas file in directory 'd$'.
Sub we.run_first_program(d$)
  Local progs$(20) Length 32
  we.get_prog_list(d$, progs$())
  Local first_prog$ = progs$(Bound(progs$(), 0))
  If first_prog$ = Chr$(&h7F) Then Error "No programs found"
  we.run_program(d$ + "/" + first_prog$, "--menu")
End Sub

Sub we.get_prog_list(d$, progs$())
  Local i%, f$

  ' Use Chr$(&h7F) for empty elements to ensure they are sorted to end of array.
  For i% = Bound(progs$(), 0) To Bound(progs$(), 1)
    progs$(i%) = Chr$(&h7F)
  Next i%

  i% = Bound(progs$(), 0)
  f$ = Dir$(d$ + "/*.bas", File)
  Do While f$ <> ""
    If i% = Bound(progs$(), 1) + 1 Then Error "Too many programs"
    progs$(i%) = LCase$(f$)
    f$ = Dir$()
    i% = i% + 1
  Loop

  Sort progs$()
End Sub

Sub we.run_next_program()
  Local progs$(20) Length 32

  Local d$ = we.get_parent$(Mm.Info$(Current))
  we.get_prog_list(d$, progs$())
  If progs$(Bound(progs$(), 0)) = Chr$(&h7F) Then Error "No programs found"

  Local current$ = LCase$(we.get_name$(Mm.Info$(Current)))
  Local i%

  For i% = Bound(progs$(), 0) To Bound(progs$(), 1)
    If progs$(i%) = current$ Then Exit For
  Next i%

  If progs$(i%) = Chr$(&h7F) Then Error "Current program not found"

  If progs$(i%) = current$ Then
    If i% < Bound(progs$(), 1) Then
      If progs$(i% + 1) <> Chr$(&h7F) Then
        we.run_program(WE.PROG_DIR$ + "/" + progs$(i% + 1), "--menu")
      EndIf
    EndIf
  EndIf

  we.run_menu()
End Sub

Sub we.clear_keyboard_buffer()
  Do While Inkey$ <> "" : Loop
End Sub

Function we.is_quit_pressed%()
  If Not we.quit% Then we.quit% = LCase$(Inkey$) = "q"
  we.is_quit_pressed% = we.quit%
End Function

Sub we.end_program()
  Do While Not we.is_quit_pressed%() : Loop
  If we.is_menu_launched%() Then we.run_next_program()
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
