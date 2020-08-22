' Author: Thomas Hugo Williams

Option Explicit
Option Default Integer
Option Base 1

#Include "../common/welcome.inc"

Mode 1, 8
Page Write 0

Dim menu_label$ = Mm.CmdLine$
If menu_label$ = "" Then menu_label$ = "menu_top"

Do While menu_label$ <> ""
  menu_label$ = show_menu$(menu_label$)
Loop

Print
Print "Goodbye!"

End

Function show_menu$(menu_label$)
  Local i, k$, s$

  Cls

  On Error Ignore
  Execute "Restore " + menu_label$
  On Error Abort
  If Mm.ErrNo <> 0 Then Error "Unknown menu: " + menu_label$

  Local items$(20, 3)
  read_string_array(items$())

  Print
  Print "Welcome to the Colour Maximite 2"
  Print WE.VERSION$
  Print
  Print "Press a key to select an option:"
  Print
  i = 1
  Do While items$(i, 1) <> ""
    Print "  [" items$(i, 1) "] " items$(i, 2)
    i = i + 1
  Loop

  ' Clear the keyboard buffer.
  Do While Inkey$ <> ""
  Loop

  Do
    k$ = ""
    Do : k$ = LCase$(Inkey$) : Loop Until k$ <> ""

    For i = 1 To Bound(items$(), 1)
      If LCase$(items$(i, 1)) = k$ Then
        If items$(i, 3) = "credits" Then
          show_credits()
          show_menu$ = menu_label$
          Exit Function
        Else If items$(i, 3) = "quit" Then
          If Not quit() Then show_menu$ = menu_label$
          Exit Function
        Else If Left$(items$(i, 3), 5) = "menu_" Then
          show_menu$ = items$(i, 3)
          Exit Function
        Else
          we.run_program(WE.INSTALL_DIR$ + "/" + items$(i, 3), "--menu " + menu_label$)
          Error "Should never get here"
        EndIf
      EndIf
    Next i
  Loop

End Function

Sub read_string_array(a$())
  Local i = 1, j = 1, s$
  Do
    Read s$
    If s$ = "end" Then Exit Do
    a$(i, j) = s$
    j = j + 1
    If j = Bound(a$(), 2) + 1 Then j = 1 : i = i + 1
  Loop
End Sub

Sub dump_string_array(a$())
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

Sub show_credits()
  Local denizens$(20, 3)
  Restore denizens
  read_string_array(denizens$())

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

  we.wait_for_key()
End Sub

Function quit()
  Local k$
  Print
  Print "Are you sure you want to Quit [y|N] ?"
  Do While k$ = "" : k$ = Inkey$ : Loop
  If LCase$(k$) = "y" Then quit = 1
End Function

menu_top:
Data "1", "Lunar Lander", "lunar/LunarLander2v6.bas"
Data "2", "Turtle Graphics Demos", "menu_turtle"
Data "3", "Graphics Primitives Demos", "menu_graphics"
Data "4", "Conway's Game of Life", "life/life.bas"
Data "5", "Eliza, the Rogerian psychotherapist", "eliza/eliza.bas"
Data "6", "Scott Adams' Pirate Adventure [COMING SOON]", "pirate/pirate.bas"
Data "C", "Show credits", "credits"
Data "Q", "Quit", "quit"
Data "end"

menu_turtle:
Data "1", "Barnsley's Fern", "turtle/barnsleys-fern.bas"
Data "2", "Dragon Curve", "turtle/dragon-curve.bas"
Data "3", "Spirals", "turtle/spirals.bas"
Data "4", "Hilbert Curve", "turtle/hilbert-curve.bas"
Data "5", "Recursive Fractal Tree", "turtle/tree.bas"
Data "6", "Random Recursive Fractal Tree", "turtle/random-tree.bas"
Data "7", "Sierpinski Triangle", "turtle/sierpinskis-triangle.bas"
Data "8", "Square Nautilus", "turtle/square-nautilus.bas"
Data "9", "Recursive Fractal Pine Tree", "turtle/pine-tree.bas"
Data "A", "Random Recursive Fractal Pine Tree", "turtle/random-pine-tree.bas"
Data "B", "Hex Gasket", "turtle/hex-gasket.bas"
Data "M", "Back to main menu", "menu_top"
Data "Q", "Quit", "quit"
Data "end"

menu_graphics:
Data "1", "Rotating Wireframe Buckyball", "graphics/wireframe-buckyball.bas"
Data "2", "Rotating Dodecahedron", "graphics/dodecahedron.bas"
Data "3", "Rotating Football", "graphics/football.bas"
Data "M", "Back to main menu", "menu_top"
Data "Q", "Quit", "quit"
Data "end"

' Denizens of TBS: TBS username, forename, surname, TBS username
'  - ordered alphabetically by username unless someone has a better idea.
' Note that Scott Adams will be listed seperately as he is not a denizen of the TBS.
denizens:
Data "Andrew_G", "", ""
Data "bigmik", "Mick", ""
Data "capsikin", "", ""
Data "matherp", "Peter", "Mather"
Data "Sasquatch", "", ""
Data "TassyJim", "Jim", "Hiley"
Data "thwill", "Thomas Hugo", "Williams"
Data "Turbo46", "Bill", "McKinley"
Data "vegipete", "", ""
Data "end"
