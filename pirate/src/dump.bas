' Copyright (c) 2020 Thomas Hugo Williams
' For Colour Maximite 2, MMBasic 5.05

Option Explicit On
Option Default Integer

#Include "advdata.inc"
#Include "strings.inc"

main()
End

Sub main()
  Local in$ = Mm.CmdLine$ + ".dat"
  Local out$ = Mm.CmdLine$ + ".dmp"
  Local fd = 1

  Cls
  adv.read(in$)
  Open out$ For Output As #fd
  Print #fd, "Data dump for '" in$ "'"
  Print #fd
  dump(fd)
  Close #fd
End Sub

' Copyright (c) 2020 Thomas Hugo Williams
' For Colour Maximite 2, MMBasic 5.05

Sub dump(fd)
  Print #fd, "Max object index:       " Str$(il)
  Print #fd, "Max action index:       " Str$(cl)
  Print #fd, "Max vocabulary index:   " Str$(nl)
  Print #fd, "Max room index:         " Str$(rl)
  Print #fd, "Max objects carried:    " Str$(mx)
  Print #fd, "Starting room index:    " Str$(ar)
  Print #fd, "Number of treasures:    " Str$(tt)
  Print #fd, "Vocabulary word length: " Str$(ln)
  Print #fd, "Time limit:             " Str$(lt)
  Print #fd, "Max message index:      " Str$(ml)
  Print #fd, "Treasure room index:    " Str$(tr)
  Print #fd

  dump_actions(fd)
  Print #fd
  dump_vocab(fd)
  Print #fd
  dump_rooms(fd)
  Print #fd
  dump_messages(fd)
  Print #fd
  dump_objects(fd)
End Sub

Sub dump_actions(fd)
  Local i

  Print #fd, "ACTIONS"
  Print #fd, "-------"
  Print #fd

  For i = 0 To cl
    dump_action(fd, i)
  Next i
End Sub

Sub dump_action(fd, i)
  Local cmd(3), cond(4, 1), j, noun, n$, verb, v$

  verb = Int(ca(i, 0) / 150)
  noun = ca(i, 0) - verb * 150

  For j = 0 To 4
    cond(j, 1) = Int(ca(i, j + 1) / 20)
    cond(j, 0) = ca(i, j + 1) - cond(j, 1) * 20
  Next j

  cmd(0) = Int(ca(i, 6) / 150)
  cmd(1) = ca(i, 6) - cmd(0) * 150
  cmd(2) = Int(ca(i, 7) / 150)
  cmd(3) = ca(i, 7) - cmd(2) * 150

  If verb = 0 Then
    n$ = Str$(noun)
    v$ = Str$(verb)
  Else
    n$ = get_noun$(noun)
    v$ = get_verb$(verb)
  End If

  Print #fd, str.rpad$(Str$(i) + ":", 6);
  Print #fd, str.rpad$(v$, 6);
  Print #fd, str.rpad$(n$, 6);
  Print #fd, str.rpad$(get_cond$(cond(0, 0), cond(0, 1)), 9);
  Print #fd, str.rpad$(get_cond$(cond(1, 0), cond(1, 1)), 9);
  Print #fd, str.rpad$(get_cond$(cond(2, 0), cond(2, 1)), 9);
  Print #fd, str.rpad$(get_cond$(cond(3, 0), cond(3, 1)), 9);
  Print #fd, str.rpad$(get_cond$(cond(4, 0), cond(4, 1)), 9);
  Print #fd, str.rpad$(get_cmd$(cmd(0)), 8);
  Print #fd, str.rpad$(get_cmd$(cmd(1)), 8);
  Print #fd, str.rpad$(get_cmd$(cmd(2)), 8);
  Print #fd, get_cmd$(cmd(3));
  Print #fd
End Sub

Function get_cond$(code, num)
  Local s$
  Select Case code
    Case 0 : s$ = "Par"
    Case 1 : s$ = "HAS"
    Case 2 : s$ = "IN/W"
    Case 3 : s$ = "AVL"
    Case 4 : s$ = "IN"
    Case 5 : s$ = "-IN/W"
    Case 6 : s$ = "-HAVE"
    Case 7 : s$ = "-IN"
    Case 8 : s$ = "BIT"
    Case 9 : s$ = "-BIT"
    Case 10 : s$ = "ANY"
    Case 11 : s$ = "-ANY"
    Case 12 : s$ = "-AVL"
    Case 13 : s$ = "-RM0"
    Case 14 : s$ = "RM0"
    Case 15 : s$ = "CT<="
    Case 16 : s$ = "CT>"
    Case 17 : s$ = "ORIG"
    Case 18 : s$ = "-ORIG"
    Case 19 : s$ = "CT="
    Case Else: s$ = "Huh?"
  End Select
  get_cond$ = s$ + " " + Str$(num)
End Function

Function get_verb$(v)
  get_verb$ = nv_str$(v, 0)
End Function

Function get_noun$(n)
  get_noun$ = nv_str$(n, 1)
End Function

Function get_cmd$(c)
  Local s$
  Select Case c
    Case 0 : s$ = "0"
    Case 1 To 51 : s$ = "MSG:" + Str$(c)
    Case 52: s$ = "GETx"
    Case 53: s$ = "DROPx"
    Case 54: s$ = "GOTOy"
    Case 55: s$ = "x->RM0"
    Case 56: s$ = "NIGHT"
    Case 57: s$ = "DAY"
    Case 58: s$ = "SETz"
    Case 59: s$ = "x->RM0" ' same as 55
    Case 60: s$ = "CLRz"
    Case 61: s$ = "DEAD"
    Case 62: s$ = "x->y"
    Case 63: s$ = "FINI"
    Case 64: s$ = "DspRM"
    Case 65: s$ = "SCORE"
    Case 66: s$ = "INV"
    Case 67: s$ = "SET0"
    Case 68: s$ = "CLR0"
    Case 69: s$ = "FILL"
    Case 70: s$ = "CLS"
    Case 71: s$ = "SAVEz"
    Case 72: s$ = "EXx,x"
    Case 102 To 149 : s$ = "MSG:" + Str$(c - 50)
    Case Else: s$ = "Huh?"
  End Select
  get_cmd$ = s$
End Function

Sub dump_vocab(fd)
  Local i

  Print #fd, "VOCAB"
  Print #fd, "-----"
  Print #fd

  For i = 0 To nl
    Print #fd, str.rpad$(Str$(i) + ":", 6) str.rpad$(nv_str$(i, 0), ln + 3) nv_str$(i, 1)
  Next i
End Sub

Sub dump_rooms(fd)
  Local count, i, j, s$

  Print #fd, "ROOMS"
  Print #fd, "-----"
  Print #fd

  For i = 0 To rl
    s$ = rs$(i)
    If s$ = "" Then
      If i = 0 Then s$ = "<storeroom>" Else s$ = "<empty>"
    End If
    Print #fd, str.rpad$(Str$(i) + ":", 6) s$
    Print #fd, "      Exits: ";
    count = 0
    For j = 0 To 5
      If rm(i, j) > 0 Then
        count = count + 1
        If count > 1 Then Print #fd, ", ";
        Select Case j
          Case 0 : Print #fd, "North";
          Case 1 : Print #fd, "South";
          Case 2 : Print #fd, "East";
          Case 3 : Print #fd, "West";
          Case 4 : Print #fd, "Up";
          Case 5 : Print #fd, "Down";
        End Select
      End If
    Next j
    If count = 0 Then Print #fd, "None" Else Print #fd
  Next i
End Sub

Sub dump_messages(fd)
  Local i, s$

  Print #fd, "MESSAGES"
  Print #fd, "--------"
  Print #fd

  For i = 0 To ml
    s$ = ms$(i)
    If s$ = "" Then s$ = "<empty>"
    Print #fd, str.rpad$(Str$(i) + ":", 6) s$
  Next i
End Sub

Sub dump_objects(fd)
  Local i, s$

  Print #fd, "OBJECTS"
  Print #fd, "-------"
  Print #fd

  For i = 0 To il
    s$ = ia_str$(i)
    If s$ = "" Then s$ = "<empty>"
    Print #fd, str.rpad$(Str$(i) + ":", 6) str.rpad$(Str$(ia(i)), 6) s$
  Next i
End Sub
