' Author: Thomas Hugo Williams

Option Explicit
Option Default Integer
Option Base 1

#Include "../common/common.inc"

Dim contents$(10, 2)
Dim denizens$(20, 3)

Mode 1
Page Write 0

read_string_data_2d("CONTENTS", contents$())
read_string_data_2d("DENIZENS", denizens$())

Do While show_menu() : Loop

End

Sub read_string_data_2d(section$, a$())
  Local i = 1, j = 1, s$
  Restore
  Do : Read s$ : Loop Until s$ = section$
  Do
    Read s$
    If s$ = "END" Then Exit Do
    a$(i, j) = s$
    j = j + 1
    If j = Bound(a$(), 2) + 1 Then j = 1 : i = i + 1
  Loop
End Sub

Function show_menu()
  Local i, k$

  Cls

  Print
  Print "Welcome to the Colour Maximite 2"
  Print WE.VERSION$
  Print
  Print "Press a key to select an option:"
  Print
  i = 1
  Do While contents$(i, 1) <> ""
    Print "  [" Str$(i) "] " contents$(i, 1)
    i = i + 1
  Loop
  Print "  [C] Show credits"
  Print "  [Q] Quit"

  ' Clear the keyboard buffer.
  Do While Inkey$ <> ""
  Loop

  show_menu = 1

  Do
    k$ = LCase$(Inkey$)
    Select Case k$
      Case "1" To "9" : launch_program(Val(k$)) : Exit Do
      Case "c"        : show_credits() : Exit Do
      Case "q"        : show_menu = Not quit() : Exit Do
    End Select
  Loop

End Function

Sub launch_program(i)
  ' Check that there is a program 'i'
  If i < 0 Or contents$(i, 2) = "" Then Exit Sub

  we.run_first_program(WE.INSTALL_DIR$ + "/" + contents$(i, 2))
End Sub

Sub show_credits()
  Cls

  Print
  Print "This Welcome Disk was brought to you by the Denizens of The Back Shed:"
  Print

  Local i = 1
  Do While denizens$(i, 1) <> ""
    Print "  " denizens$(i, 1);
    If denizens$(i, 2) <> "" Then
      Print Space$(12 - Len(denizens$(i, 1))) " - " denizens$(i, 2) " ";
      If denizens$(i, 3) <> "" Then Print denizens$(i, 3) " ";
    EndIf
    Print
    i = i + 1
  Loop

  Print
  Print "Please join us as http://www.thebackshed.com/forum/ViewForum.php?FID=16"

  Print
  Print "Many thanks also to:"
  Print
  Print "  Geoff Graham, Peter Mather & 'The Team' - for creating the Colour Maximite 2"
  Print "  Scott Adams - for permission to include 'Pirate Adventure'"
  Print
  Print "Press any key to return to the menu."

  Do While Inkey$ <> "" : Loop
  Do While Inkey$ = "" : Loop
End Sub

Function quit()
  Print
  Print "QUIT"
  ' TODO: Prompt for if the user really wants to quit.
  End
  quit = 1
End Function

Sub dump_string_array_2d(a$())
  Local i, j
  For i = 1 To Bound(a$(), 1)
    Print "[" Str$(i) "] ";
    For j = 1 To Bound(a$(), 2)
      If j <> 1 Then Print ", ";
      If a$(i, j) = "" Then Print "<empty>"; Else Print "{" a$(i, j) "}";
    Next j
    Print
  Next i
End Sub

' Contents and corresponding sub-directories
Data "CONTENTS"
Data "Lunar Lander", "lunar"
Data "Turtle Graphics Demos", "turtle"
Data "Graphics Primitives Demos", "graphics"
Data "Conway's Game of Life", "life"
Data "Eliza, the Rogerian psychotherapist", "eliza"
Data "Scott Adams' Pirate Adventure [COMING SOON]", "pirate"
Data "END"

' Denizens of TBS: TBS username, forename, surname, TBS username
'  - ordered alphabetically by username unless someone has a better idea.
' Note that Scott Adams will be listed seperately as he is not a denizen of the TBS.
DATA "DENIZENS"
Data "Andrew_G", "", ""
Data "bigmik", "Mick", ""
Data "capsikin", "", ""
Data "matherp", "Peter", "Mather"
Data "Sasquatch", "", ""
Data "TassyJim", "Jim", "Hiley"
Data "thwill", "Thomas", "Williams"
Data "Turbo46", "Bill", "McKinley"
Data "vegipete", "", ""
Data "END"
