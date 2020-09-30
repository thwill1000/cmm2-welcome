' Copyright (c) 2019-20 Thomas Hugo Williams
' For Colour Maximite 2, MMBasic 5.05

Const SAVE_DIR$   = FIL.PROG_DIR$ + "/saves"
Const SCRIPT_DIR$ = FIL.PROG_DIR$ + "/scripts"

' Saves the current game state to a file.
' @return 1 on success, otherwise 0.
Function do_save()
  Local f$, i, game, s$

  con.println()
  con.println("Select saved game:")
  con.println()
  game = select_game()
  If game <> 0 Then f$ = save_file$(game)

  If game <> 0 And fil.exists%(f$) Then
    s$ = prompt$("Overwrite game " + Str$(game) + " [y|N]? ")
    If LCase$(s$) <> "y" Then game = 0
  EndIf

  If game <> 0 Then
    s$ = prompt$("Saved game name ? ")
    If s$ = "" Then game = 0
  EndIf

  If game = 0 Then con.println("Cancelled.") Exit Function

  con.println("Saving '" + f$ + "' ...")

  Open f$ For Output As #1

  ' Write file header
  Print #1, "SAINT save file"
  Print #1, "1"
  Print #1, Date$ + " " + Time$
  Print #1, s$

  ' Write state
  Print #1, "&b" Bin$(sf, 32) ' status flags
  Print #1, Str$(df)          ' dark flag
  Print #1, Str$(r)           ' current room
  Print #1, Str$(lx)          ' light duration
  For i = 0 To il : Print #1, Str$(ia(i)) : Next i ' object locations

  Close #1

  do_save = 1
End Function

' Gets the path to the file corresponding to saved game slot 'i'.
Function save_file$(i)
  If i < 1 Or i > 10 Then Error "Invalid saved game number"
  save_file$ = SAVE_DIR$ + "/" + Left$(STORY$, 6) + Str$(i) + ".sav"
End Function

' Restores game state from a file.
' @return 1 on success, otherwise 0.
Function do_restore()
  Local err$, f$, i, game, s$, values(4 + il)

  con.println()
  con.println("Select saved game to restore:")
  con.println()
  game = select_game()
  If game <> 0 Then f$ = save_file$(game)

  If game <> 0 Then
    If Not fil.exists%(f$) Then game = 0
  EndIf

  If game = 0 Then con.println("Cancelled.") : Exit Function

  Open f$ For Input As #1

  ' Read file header
  Line Input #1, s$
  Line Input #1, s$
  Line Input #1, s$
  Line Input #1, s$
  con.println("Restoring '" + s$ + "' ...")

  For i = 0 To 4 + il
    Line Input #1, s$
    If s$ = "" Then err$ = "missing data" : Exit For
    values(i) = Val(s$)
  Next i
  If Not Eof(#1) And err$ = "" Then err$ = "unexpected data"

  If err$ = "" Then
    ' Update game state with values read from file.
    sf = values(0)
    df = values(1)
    r  = values(2)
    lx = values(3)
    For i = 4 To il + 4 : ia(i - 4) = values(i) : Next i

    do_restore = 1
  Else
    con.println("Save file is invalid: " + err$)
  EndIf

  Close #1
End Function

' Prompts the user to select a saved game slot.
Function select_game()
  Local i, f$, s$(3) Length 64

  fil.mkdir(SAVE_DIR$)

  For i = 1 To 10
    f$ = save_file$(i)
    con.print("  [" + Format$(i, "%2g") + "] ")
    If fil.exists%(f$) Then
      Open f$ For Input As #1
      Line Input #1, s$(0) ' header
      Line Input #1, s$(1) ' version
      Line Input #1, s$(2) ' date/time
      Line Input #1, s$(3) ' game name
      Close #1
      ' TODO: verify header / version ?
      con.println(s$(2) + " - " + s$(3))
    Else
      con.println("Empty")
    EndIf
  Next i

  con.println()
  s$(0) = prompt$("Saved game number ? ")
  select_game = Val(s$(0))
  If select_game < 1 Or select_game > 10 Then select_game = 0

End Function

Sub record_on()
  Local f$, script, s$

  If con.fd_out <> 0 Then con.println("Already recording script.") : Exit Sub
  If con.fd_in <> 0  Then con.println("Cannot record whilst replaying script.") : Exit Sub

  con.println()
  con.println("Select script to record:")
  con.println()
  script = select_script()
  If script <> 0 Then f$ = script_file$(script)

  If script <> 0 And fil.exists%(f$) Then
    s$ = prompt$("Overwrite script " + Str$(script) + " [y|N]? ")
    If LCase$(s$) <> "y" Then script = 0
  EndIf

  If script <> 0 Then
    s$ = prompt$("Script name ? ")
    If s$ = "" Then script = 0
  EndIf

  If script = 0 Then con.println("Cancelled.") : Exit Sub

  con.println("Recording to '" + f$ + "' ...")

  con.open_out(2, f$)

  Print #2, "# " Date$ " " Time$
  Print #2, "# " s$

End Sub

' Prompts the user to select a script slot.
Function select_script()
  Local i, f$, s$

  fil.mkdir(SCRIPT_DIR$)

  For i = 1 To 10
    f$ = script_file$(i)
    con.print("  [" + Format$(i, "%2g") + "] ")
    If fil.exists%(f$) Then
      Open f$ For Input As #1
      Line Input #1, s$ ' date/time
      con.print(Mid$(s$, 3) + " - ")
      Line Input #1, s$ ' script name
      con.println(Mid$(s$, 3))
      Close #1
    Else
      con.println("Empty")
    EndIf
  Next i

  con.println()
  s$ = prompt$("Script number ? ")
  select_script = Val(s$)
  If select_script < 1 Or select_script > 10 Then select_script = 0

End Function

' Gets the path to the file corresponding to script slot 'i'.
Function script_file$(i)
  If i < 1 Or i > 10 Then Error "Invalid script number"
  script_file$ = SCRIPT_DIR$ + "/" + Left$(STORY$, 6) + Str$(i) + ".scr"
End Function

Sub record_off()
  If con.fd_out = 0 Then con.println("A script is not being recorded!") : Exit Sub
  con.close_out()
  con.println("Recording stopped.")
End Sub

Sub replay_on()
  Local f$, script, s$

  If con.fd_out <> 0 Then con.println("Cannot replay whist recording script.") : Exit Sub
  If con.fd_in <> 0  Then con.println("Already replaying script.") : Exit Sub

  con.println()
  con.println("Select script to replay:")
  con.println()
  script = select_script()
  If script <> 0 Then f$ = script_file$(script)

  If script <> 0 Then
    If Not fil.exists%(f$) Then script = 0
  EndIf

  If script = 0 Then con.println("Cancelled.") : Exit Sub

  con.println("Replaying from '" + f$ + "' ...")

  con.open_in(3, f$)
End Sub

Sub replay_off()
  If con.fd_in = 0 Then con.println("A script is not being replayed!") : Exit Sub
  con.close_in()
  con.println("Replaying stopped.")
End Sub
