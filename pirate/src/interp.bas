' Scott Adams Adventure Game Interpreter for Colour Maximite 2
' Original TRS-80 Level II BASIC code (c) Scott Adams 1978
' MMBasic port for CMM2 by Thomas Hugo Williams 2020

Option Explicit On
Option Default Integer

#Include "advdata.inc"
#Include "console.inc"
#Include "file.inc"
#Include "persist.inc"
#Include "strings.inc"
#Include "util.inc"
#Include "../../common/welcome.inc"

CON.WIDTH = 80

Const STATE_CONTINUE = 0
Const STATE_QUIT     = 1
Const STATE_RESTART  = 2

Const ACTION_PERFORMED = 3
Const ACTION_UNKNOWN   = 4
Const ACTION_NOT_YET   = 5

' Hardcoded Verb id's.
Const VERB_NONE       = -1
Const VERB_TOO_MANY   = -2
Const VERB_RECORD_ON  = -3
Const VERB_RECORD_OFF = -4
Const VERB_REPLAY_ON  = -5
Const VERB_REPLAY_OFF = -6
Const VERB_DUMP_STATE = -7
Const VERB_DEBUG_ON   = -8
Const VERB_DEBUG_OFF  = -9
Const VERB_FIXED_SEED = -10

Dim STORY$ = "pirate"

' These global variables hold the current game state
Dim lx ' light duration
Dim df ' dark flag
Dim r  ' current room
Dim sf ' status flags
' And ia() which contains the current object locations,
' but is declared by adv.read()

Dim state
Dim debug

' TODO: This shouldn't be global
Dim ip ' action parameter pointer

Mode 2
main()
Pause 2000
we.end_program()

Sub main()
  adv.read(FIL.PROG_DIR$ + "/" + STORY$ + ".dat")

  Do
    state = STATE_CONTINUE
    show_intro()
    If state = STATE_CONTINUE Then game_loop()
    con.close_all()
  Loop While state <> STATE_QUIT

  con.println("Goodbye!")
  con.close_all()
End Sub

Sub show_intro(f$)
  Local i, k$

  Cls
  con.lines = 0
  Colour RGB(White)
  con.print_file(FIL.PROG_DIR$ + "/" + STORY$ + ".tit", 1)
  Colour RGB(Green)
  con.println()
  con.println("S  Start the game             ", 1)
  con.println("R  Restore a saved game       ", 1)
  con.println("C  Show credits               ", 1)
  con.println("I  Instructions on how to play", 1)
  con.println("Q  Quit                       ", 1)
  con.println()
  con.println("Adventure Game Interpreter for Colour Maximite 2", 1)
  con.println("Version 1.0", 1)

  Do While Inkey$ <> "" : Loop
  Do
    k$ = LCase$(Inkey$)
    Select Case k$
      Case "s" : reset_state()
      Case "r" : If Not do_restore() Then Pause 2000 : state = STATE_RESTART
      Case "c" : show_credits() : state = STATE_RESTART
      Case "i" : show_instructions() : state = STATE_RESTART
      Case "q" : state = STATE_QUIT
      Case Else : k$ = ""
    End Select
  Loop Until k$ <> ""
End Sub

Sub show_credits()
  Cls
  con.lines = 0
  Colour RGB(White)
  con.println()
  con.println("CREDITS", 1)
  con.println("=======", 1)
  con.println()
  Colour RGB(Green)
  con.print_file(FIL.PROG_DIR$ + "/" + STORY$ + ".cre", 1)
  con.println()
  Colour RGB(White)
  con.println("Press any key to continue", 1)
  Colour RGB(Green)
  Do While Inkey$ <> "" : Loop
  Do While Inkey$ = "" : Loop
End Sub

Sub show_instructions()
  Cls
  con.lines = 0
  Colour RGB(White)
  con.println()
  con.println("HOW TO PLAY", 1)
  con.println("===========", 1)
  con.println()
  Colour RGB(Green)
  con.print_file(FIL.PROG_DIR$ + "/" + STORY$ + ".ins", 1)
  con.println()
  Colour RGB(White)
  con.println("Press any key to continue", 1)
  Colour RGB(Green)
  Do While Inkey$ <> "" : Loop
  Do While Inkey$ = "" : Loop
End Sub

Sub reset_state()
  Local i
  r = ar  ' current room = starting room
  lx = lt ' light source starts full
  df = 0  ' dark flag is unset
  sf = 0  ' status flags are clear
  For i = 0 To il : ia(i) = i2(i) : Next i ' initial object locations
  state = STATE_CONTINUE
End Sub

Sub game_loop()
  Local noun, nstr$, verb

  Cls
  describe_room()

  Do
    do_actions() ' handle automatic actions
    prompt_for_command(verb, noun, nstr$)
    do_actions(verb, noun, nstr$) ' handle player actions
    If state = STATE_CONTINUE Then update_light()
  Loop While state = STATE_CONTINUE
End Sub

Sub describe_room()
  Local count, i

  ' Object 9 is the lit light source.
  If df And ia(9) <> -1 And ia(9) <> r Then
    If debug Then con.print("[" + Str$(r) + "] ")
    con.println("I can't see, its too dark!")
    Exit Sub
  EndIf

  Colour RGB(White)

  If Mm.Info(VPOS) > 0 Then con.println()
'  Cls
'  con.lines = 0

  If debug Then con.print("[" + Str$(r) + "] ")
  If Left$(rs$(r), 1) = "*" Then
    ' A leading asterisk means use the room description verbatim.
    con.println(Mid$(rs$(r), 2))
  Else
    con.println("I'm in a " + rs$(r))
  EndIf

  con.print("Obvious exits: ")
  For i = 0 To 5
    If rm(r, i) <> 0 Then
      ' Use sentence case for directions.
      count = count + 1
      If count > 1 Then con.print(", ")
      con.print(UCase$(Left$(nv_str$(i + 1, 1), 1)))
      con.print(LCase$(Mid$(nv_str$(i + 1, 1), 2)))
    EndIf
  Next i
  If count = 0 Then con.print("None")
  con.println(".")

  con.print("Visible items: ")
  print_object_list(r, "None")

  con.println("<" + String$(CON.WIDTH - 2, "-") + ">")
  con.println()

  Colour RGB(Green)

End Sub

Sub print_object_list(rm, none$)
  Local count, i, p

  For i = 0 To il
    If ia(i) = rm Then
      count = count + 1
      If count > 1 Then con.print(", ")
      If debug Then con.print("[" + Str$(i) + "] ")
      p = InStr(ia_str$(i), "/")
      If p < 1 Then
        con.print(ia_str$(i))
      Else
        con.print(Left$(ia_str$(i), p - 1))
      EndIf
    EndIf
  Next i

  If count = 0 Then con.print(none$)
  con.println(".")
End Sub

Sub do_actions(verb, noun, nstr$)
  Local a, an, av, process_action, result

  ' Handle "go <direction>"
  If verb = 1 And noun < 7 Then
    go_direction(noun)
    Exit Sub
  EndIf

  result = ACTION_UNKNOWN

  For a = 0 to cl
    av = Int(ca(a, 0) / 150) ' action - verb
    an = ca(a, 0) - av * 150 ' action - noun

    ' Stop processing automatic actions (verb == 0) when we reach the first
    ' non-zero action verb.
    If verb = 0 And av <> 0 Then Exit Sub

    If av = 0 And verb = 0 Then
      ' Automatic action, 'an' is the probability
      process_action = pseudo%(100) <= an
    ElseIf av = verb And (an = noun Or an = 0) Then
      ' Verb and noun match, or action noun is 'ANY'
      process_action = 1
    Else
      process_action = 0
    EndIf

    If process_action Then
      If process_conditions(a) Then
        do_commands(a)
        result = ACTION_PERFORMED
      Else
        result = ACTION_NOT_YET
      EndIf
    EndIf

    ' Stop processing actions when a non-automatic action is performed.
    If verb <> 0 And result = ACTION_PERFORMED Then Exit For

  Next a

  ' Whilst the action table contains some specialist pickup and drop handling
  ' the general case is handled by this code.
  If result = ACTION_UNKNOWN Then
    If verb = 10 Then
      do_get(nstr$)
      result = ACTION_PERFORMED
    ElseIf verb = 18 Then
      do_drop(nstr$)
      result = ACTION_PERFORMED
    EndIf
  EndIf

  Select Case result
    Case ACTION_UNKNOWN : con.println("I don't understand your command.")
    Case ACTION_NOT_YET : con.println("I can't do that yet.")
    Case Else :           If con.lines = 0 And state = STATE_CONTINUE Then con.println("OK.")
  End Select

End Sub

' @param  a  current action index
Function process_conditions(a)
  Local code, i, ok, value

  ok = 1
  For i = 1 To 5
    value = Int(ca(a, i) / 20)
    code = ca(a, i) - value * 20
    ok = ok And evaluate_condition(code, value)
    If Not ok Then Exit For
  Next i

  process_conditions = ok
End Function

' @param  a  current action index
Sub do_commands(a)
  Local cmd(3)

  ip = 0 ' reset parameter pointer
  cmd(0) = Int(ca(a, 6) / 150)
  cmd(1) = ca(a, 6) - cmd(0) * 150
  cmd(2) = Int(ca(a, 7) / 150)
  cmd(3) = ca(a, 7) - cmd(2) * 150

  do_command(a, cmd(0))
  do_command(a, cmd(1))
  do_command(a, cmd(2))
  do_command(a, cmd(3))
End Sub

Sub go_direction(noun)
  Local l = df
  If l Then l = df And ia(9) <> R and ia(9) <> - 1
  If l Then con.println("Dangerous to move in the dark!")
  If noun < 1 Then con.println("Give me a direction too.") : Exit Sub
  Local k = rm(r, noun - 1)
  If k < 1 Then
    If l Then
      con.println("I fell down and broke my neck.")
      k = rl
      df = 0
    Else
      con.println("I can't go in that direction.")
      Exit Sub
    EndIf
  EndIf
'  If Not l Then Cls
  r = k
  describe_room()
End Sub

Function evaluate_condition(code, value)
  Local i, pass
  Select Case code
    Case 0
      pass = 1
    Case 1
      ' Passes if the player is carrying object <value>.
      pass = (ia(value) = -1)
    Case 2
      ' Passes if the player is in the same room (but not carrying) object <value>.
      pass = (ia(value) = r)
    Case 3
      ' Passes if object <value> is available; i.e. carried or in the current room
      pass = (ia(value) = -1) Or (ia(value) = r)
    Case 4
      ' Passes if the player is in room <value>.
      pass = (r = value)
    Case 5
      ' Passes if the player is carrying object <value> or it is in a different room.
      pass = (ia(value) <> r)
    Case 6
      ' Passes if the player is not carrying object <value>.
      pass = (ia(value) <> -1)
    Case 7
      ' Passes if the player is not in room <value>.
      pass = (r <> value)
    Case 8
      ' Passes if numbered flag-bit set.
      pass = (sf And Int(2^value + 0.5)) <> 0
    Case 9
      ' Passes if numbered flag-bit clear.
      pass = (sf And Int(2^value + 0.5)) = 0
    Case 10
      ' Passes if the player is carrying anything.
      For i = 0 To il
        If ia(i) = -1 Then pass = 1 : Exit For
      Next i
    Case 11
      ' Passes if the player is carrying nothing.
      pass = 1
      For i = 0 To il
        If ia(i) = -1 Then pass = 0 : Exit For
      Next i
    Case 12
      ' Passes if object <number> is not available; i.e. not carried or in the current room.
      pass = (ia(value) <> -1) And (ia(value) <> r)
    Case 13
      ' Passes if object <value> is not in the store room (0)
      pass = (ia(value) <> 0)
    Case 14
      ' Passes if object <value> is in the store room (0)
      pass = (ia(value) = 0)
    Case Else
      Error "Unknown condition: " + Str$(code)
  End Select

  evaluate_condition = pass
End Function

' @param  a  current action index
Sub do_command(a, cmd)
  Local i, p, x, y

  Select Case cmd
    Case 0
      ' Do nothing ? Or should it display message 0 which is null ?

    Case 1 To 51
      ' Display corresponding message.
      If debug Then con.print("[" + Str$(cmd) + "] ")
      con.println(ms$(cmd))

    Case 52
      ' GETx
      ' Pick up the Par #1 object unless player already carrying the limit.
      ' The object may be in this room, or in any other room.
      p = get_parameter(a)
      For i = 1 To il : If ia(i) = -1 Then x = x + 1 : Next i
      If x <= mx Then
        ia(p) = -1
      Else
        con.println("I've too much to carry. Try " + Chr$(34) + "Inventory" + Chr$(34) + ".")
      EndIf

    Case 53
      ' DROPx
      ' Drop the Par #1 object in the current room.
      ' The object may be carried or in any other room
      p = get_parameter(a)
      ia(p) = r

    Case 54
      ' GOTOy
      ' Move the player to the Par #1 room.
      ' This command should be followed by a DspRM (64) command.
      ' Also it may need to be followed by a NIGHT (56) or DAY (57) command.
      p = get_parameter(a)
      r = p

    Case 55, 59
      ' x->RM0
      ' Move the Par #1 object to room 0 (the storeroom).
      p = get_parameter(a)
      ia(p) = 0

    Case 56
      ' NIGHT
      ' Set the darkness flag-bit (15).
      ' It will be dark if the artificial light source is not available,
      ' so this should be followed by a DspRM (64) command.
      df = 1
      ' TODO: 'df' is not flag-bit 15.
      '       The incorrect comment probably refer to a later version of the
      '       original Scott Adams interpreter.

    Case 57
      ' DAY
      ' Clear the darkness flag-bit (15).
      ' This should be followed by a DspRM (64) command.
      df = 0

    Case 58
      ' SETz
      ' Set the Par #1 flag-bit.
      p = get_parameter(a)
      sf = sf Or 1 << p

    Case 60
      ' CLRz
      ' Clear the Par #1 flag-bit.
      p = get_parameter(a)
      sf = (sf Or 1 << p) Xor 1 << p

    Case 61
      ' DEAD
      ' Tell the player they are dead,
      ' Goto the last room (usually some form of limbo),
      ' make it DAY and display the room.
      con.println("I'm dead...")
      r = rl
      df = 0
      describe_room()

    Case 62
      ' x->y
      ' Move the Par #1 object to the Par #2 room.
      ' This will automatically display the room if the object came from,
      ' or went to the current room.
      x = get_parameter(a)
      ia(x) = get_parameter(a)
      ' TODO: This isn't automatically displaying the room.
      '       The incorrect comment probably refer to a later version of the
      '       original Scott Adams interpreter.

    Case 63
      ' FINI
      ' Tell the player the game is over and ask if they want to play again.
      Local s$ = prompt$("The game is now over, would you like to play again [Y|n]? ")
      If LCase$(s$) = "n" Then state = STATE_QUIT Else state = STATE_RESTART

    Case 64
      ' DspRM
      ' Display the current room.
      ' This checks if the darkness flag-bit (15) is set and the artificial
      ' light (object 9) is not available.
      ' If there is light, it displays the room description, the objects in
      ' the room and any obvious exits.
      describe_room()

    Case 65
      ' SCORE
      ' Tells the player how many treasures they have collected by getting
      ' them to the treasure room and what their percentage of the total is.
      x = 0
      For i = 1 To il
        If ia(i) = tr And Left$(ia_str$(i), 1) = "*" Then x = x + 1
      Next i
      con.print("I've stored " + Str$(x) + " treasures. On a scale of 0 to 100 that rates a ")
      con.println(Str$(Int(x/tt*100)) + ".")
      If x = tt Then
        con.println("WELL DONE !!!")
        do_command(a, 63)
      EndIf

    Case 66
      ' INV
      ' Tells the player what objects they are carrying.
      con.print("I'm carrying: ")
      print_object_list(-1, "Nothing")

    Case 67
      ' SET0
      ' Sets the flag-bit numbered 0 (this may be convenient because no parameter is used).
      sf = sf Or 1

    Case 68
      ' CLR0
      ' Clears the flag-bit numbered 0 (this may be convenient because no parameter is used).
      sf = (sf Or 1) Xor 1

    Case 69
      ' FILL
      ' Re-fill the artifical light source and clear flag-bit 16 which
      ' indicates that it was empty. This also picks up the artifical light
      ' source (object 9). This command should be followed by a x->RM0 to store
      ' the unlighted light source (these are two different objects).
      lx = lt
      ia(9) = -1

    Case 70
      ' CLS
      ' As far as I can tell a CLS is always followed by a DspRM thus making it superfluous.

    Case 71
      ' SAVEz
      ' This command saves the current game state to a file.
      x = do_save()

    Case 72
      ' EXx,x
      ' This command exchanges the room locations of the Par #1 object and the
      ' Par #2 object. If the objects in the current room change, the new
      ' description will be displayed.
      x = get_parameter(a) ' x = object 1
      y = get_parameter(a) ' y = object 2
      p = ia(x)           ' p = location of object 1
      ia(x) = ia(y)
      ia(y) = p

    Case 102 To 149
      ' Display corresponding message.
      If debug Then con.print("[" + Str$(cmd - 50) + "] ")
      con.println(ms$(cmd - 50))

    Case Else
      Error "Unknown command: " + Str$(cmd)

  End Select

End Sub

' @param   a   current action index
' @global  ip  parameter pointer
Function get_parameter(a)
 Local code, value

 Do
   ip = ip + 1
   value = Int(ca(a, ip) / 20)
   code = ca(a, ip) - value * 20
 Loop While code <> 0

 get_parameter = value
End Function

Sub prompt_for_command(verb, noun, nstr$)
  Local s$, _

  Do
    If con.count = 1 Then con.println()
    s$ = prompt$("What shall I do ? ", 1)
    parse(s$, verb, noun, nstr$)

    Select Case verb
      Case 0               : con.println("You use word(s) I don't know!")
      Case VERB_NONE       : ' Do nothing, user will be prompted for command again.
      Case VERB_TOO_MANY   : con.println("I only understand two word commands!")
      Case VERB_RECORD_ON  : record_on()
      Case VERB_RECORD_OFF : record_off()
      Case VERB_REPLAY_ON  : replay_on()
      Case VERB_REPLAY_OFF : replay_off()
      Case VERB_DUMP_STATE : print_state()
      Case VERB_DEBUG_ON   : con.println("OK.") : debug = 1
      Case VERB_DEBUG_OFF  : con.println("OK.") : debug = 0
      Case VERB_FIXED_SEED : con.println("OK.") : _ = pseudo%(-7)
      Case Else            : Exit Do ' Handle 'verb' in calling code.
    End Select

  Loop

End Sub

Function prompt$(s$, echo)
  con.print(s$)
  Colour RGB(White)
  prompt$ = con.in$("", echo)
  Colour RGB(Green)
End Function

Sub print_state()
  con.println()
  con.println("Current room:    " + Str$(r))
  con.println("Dark flag:       " + Str$(df))
  con.println("Remaining light: " + Str$(lx))
  con.print("Set flags:       ")
  Local count, i
  For i = 0 To 31
    If sf And 1 << i Then
      count = count + 1
      If count > 1 Then con.print(", ")
      con.print(Str$(i))
    EndIf
  Next i
  con.println()
End Sub

Sub parse(s$, verb, noun, nstr$)
  Local tmp$ = s$
  Local vstr$

  vstr$ = LCase$(str.next_token$(tmp$))
  nstr$ = LCase$(str.next_token$(tmp$))

  ' Handle empty input.
  If vstr$ = "" Then verb = VERB_NONE : Exit Sub

  ' Ignore input beginning with '#', used for comments in script files.
  If Left$(vstr$, 1) = "#" Then verb = VERB_NONE : Exit Sub

  ' Reject commands of more than two words.
  If str.next_token$(tmp$) <> "" Then verb = VERB_TOO_MANY : Exit Sub

  verb = lookup_meta_command(vstr$, nstr$)
  If verb <> 0 Then Exit Sub

  ' Hack to allow use of common abbreviations, and avoid typing 'go'.
  If nstr$ = "" Then
    Select Case vstr$:
      Case "n", "north" : vstr$ = "go" : nstr$ = "north"
      Case "s", "south" : vstr$ = "go" : nstr$ = "south"
      Case "e", "east"  : vstr$ = "go" : nstr$ = "east"
      Case "w", "west"  : vstr$ = "go" : nstr$ = "west"
      Case "u", "up"    : vstr$ = "go" : nstr$ = "up"
      Case "d", "down"  : vstr$ = "go" : nstr$ = "down"
      Case "i"          : vstr$ = "inventory"
      Case "q"          : vstr$ = "quit"
      Case "save"       : vstr$ = "save" : nstr$ = "game"
    End Select
  EndIf

  If Left$(vstr$, ln) = Left$("quit", ln) Then
    Local pr$ = prompt$("Are you sure you want to quit [y|N]? ")
    If LCase$(pr$) <> "y" Then verb = VERB_NONE : Exit Sub
  EndIf

  verb = lookup_word(Left$(vstr$, ln), 0)
  noun = lookup_word(Left$(nstr$, ln), 1)

  If noun <> 0 Then
    nstr$ = LCase$(nv_str$(noun, 1)) ' to use correct synonym
  Else
    nstr$ = Left$(nstr$, ln)
  EndIf

End Sub

Function lookup_meta_command(vstr$, nstr$)
  Local verb

  Select Case vstr$
    Case "*debug"
      If nstr$ = "on" Or nstr$ = "" Then verb = VERB_DEBUG_ON
      If nstr$ = "off" Then verb = VERB_DEBUG_OFF
    Case "*record"
      If nstr$ = "on" Or nstr$ = "" Then verb = VERB_RECORD_ON
      If nstr$ = "off" Then verb = VERB_RECORD_OFF
    Case "*replay"
      If nstr$ = "on" Or nstr$ = "" Then verb = VERB_REPLAY_ON
      ' "*replay off" only makes sense if put in a script file
      ' so as to stop it from being read to its end.
      If nstr$ = "off" Then verb = VERB_REPLAY_OFF
    Case "*seed"
      If nstr$ = "" Then verb = VERB_FIXED_SEED
    Case "*state"
      If nstr$ = "" Then verb = VERB_DUMP_STATE
  End Select

  lookup_meta_command = verb
End Function


' @param  word$  word to lookup
' @param  dict   dictionary to look in, 0 for verbs and 1 for nouns
Function lookup_word(word$, dict)
  Local i, s$

  lookup_word = 0

  If word$ = "" Then Exit Function

  For i = 0 To nl
    s$ = nv_str$(i, dict)
    If Left$(s$, 1) = "*" Then s$ = Mid$(s$, 2)
    If dict = 1 And i < 7 Then s$ = Left$(s$, ln)
    If word$ = LCase$(s$) Then
      ' Word found, if it's a synonym then use previous word
      lookup_word = i
      Do While Left$(nv_str$(lookup_word, dict), 1) = "*"
        lookup_word = lookup_word - 1
      Loop
      Exit For
    EndIf
  Next i
End Function

' Picks up the object identified by 'nstr$'
Sub do_get(nstr$)
  Local carried = 0, i, k

  If nstr$ = "" Then con.println("What?") : Exit Sub

  For i = 0 To il
    If ia(i) = -1 Then carried = carried + 1
  Next i
  If carried >= mx Then con.println("I've too much to carry!") : Exit Sub

  For i = 0 To il
    If LCase$(obj_noun$(i)) = nstr$ Then
      If ia(i) = r Then
        ia(i) = -1
        k = 3
        Exit For
      Else
        k = 2
      EndIf
    EndIf
  Next i

  If k = 2 Then
    con.println("I don't see it here.")
  ElseIf k = 0 Then
    con.println("It's beyond my power to do that.")
  EndIf
End Sub

' Gets the noun for referring to the given object.
Function obj_noun$(i)
  Local en, st

  st = InStr(ia_str$(i), "/")
  If st > 1 Then
    en = InStr(st + 1, ia_str$(i), "/")
    If en < st + 1 Then Error "Missing trailing '/'"
    obj_noun$ = Mid$(ia_str$(i), st + 1, en - st - 1)
  EndIf

  If Len(obj_noun$) > ln Then Error "Object noun too long: " + obj_noun$
End Function

' Drops the object identified by 'nstr$'
Sub do_drop(nstr$)
  Local i, k = 0

  If nstr$ = "" Then con.println("What?") : Exit Sub

  For i = 0 To il
    If LCase$(obj_noun$(i)) = nstr$ Then
      If ia(i) = -1 Then
        ia(i) = r
        k = 3
        Exit For
      Else
        k = 1
      EndIf
    EndIf
  Next i

  If k = 1 Then
    con.println("I'm not carrying it!")
  ElseIf k = 0 Then
    con.println("It's beyond my power to do that.")
  EndIf

End Sub

Sub update_light()
  ' If carrying the lit light source ...
  If ia(9) = -1 Then
    lx = lx - 1 ' decrement its duration
    If lx < 0 Then
      con.println("Light has run out!")
      ia(9) = 0
    ElseIf lx < 25 Then
      con.println("Light runs out in " + Str$(lx) + " turns!")
    EndIf
  EndIf
End Sub
