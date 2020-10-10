' Author: Thomas Hugo Williams

Option Explicit
Option Default Integer
Option Base 1

#Include "../common/welcome.inc"

we.check_firmware_version()

Mode 1, 8
Page Write 0

Dim menu_label$ = Mm.CmdLine$
If menu_label$ = "" Then menu_label$ = "menu_top"

Do While menu_label$ <> ""
  menu_label$ = show_menu$(menu_label$)
Loop

goodbye()
End

Function show_menu$(menu_label$)
  On Error Ignore
  Execute "Restore " + menu_label$
  On Error Abort
  If Mm.ErrNo <> 0 Then Error "Unknown menu: " + menu_label$

  Local menu_name$
  Read menu_name$
  Local items$(20, 3)
  read_string_array(items$())

  Local i, width
  For i = Bound(items$(), 0) To Bound(items$(), 1)
    width = Max(width, Len(items$(i, 2)))
  Next i
  For i = Bound(items$(), 0) To Bound(items$(), 1)
    items$(i, 2) = items$(i, 2) + Space$(width - Len(items$(i, 2)))
  Next i

  Local title$ = "Colour Maximite 2 " + Chr$(34) + "Welcome Tape" + Chr$(34)
  show_menu_vga(title$, menu_name$, items$())
  show_menu_serial(title$, menu_name$, items$())

  we.clear_keyboard_buffer()

  Local k$
  Do
    Do : k$ = LCase$(Inkey$) : Loop Until k$ <> ""
    If k$ = "m" Then k$ = "b" ' For backward compatibility [M] does same as [B].

    For i = Bound(items$(), 0) To Bound(items$(), 1)
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
  For i = Bound(a$(), 0) To Bound(a$(), 1)
    Print "[" Str$(i) "] ";
    For j = Bound(a$(), 0) To Bound(a$(), 2)
      If j <> 1 Then Print ", ";
      If a$(i, j) = "" Then Print "<empty>"; Else Print "{" a$(i, j) "}";
    Next j
    Print
  Next i
End Sub

Sub show_menu_vga(title$, menu$, items$())
  Local i

  Page Write 1
  Cls ' Note this will also clear the serial console.
  Local x = Mm.HRes \ 2
  Local y = 48
  Text x, y, title$, C, 3, 1, RGB(Yellow)
  y = y + 24
  Text x, y, WE.VERSION$, C, 1, 1, RGB(Yellow)
  y = y + 36
  Text x, y, UCase$(menu$), C, 3, 1, RGB(White)
  y = y + 48
  For i = Bound(items$(), 0) To Bound(items$(), 1)
    If items$(i, 1) <> "" Then
      Text x, y, "[" + items$(i, 1) + "] " + items$(i, 2), C, 3, 1, RGB(White)
      y = y + 24
    EndIf
  Next i
  y = y + 24
  Text x, y, "Press a key to select an option", C, 3, 1, RGB(Yellow)
  Page Copy 1 To 0, B
  Page Write 0
End Sub

Sub show_menu_serial(title$, menu$, items$())
  Local i

  Option Console Serial
  print_centered(title$)
  print_centered(WE.VERSION$)
  Print
  print_centered(UCase$(menu$))
  Print
  For i = Bound(items$(), 0) To Bound(items$(), 1)
    If items$(i, 1) <> "" Then
      print_centered("  [" + items$(i, 1) + "] " + items$(i, 2))
    EndIf
  Next i
  Print
  print_centered("Press a key to select an option")
  Option Console Both
End Sub

Sub print_centered(s$)
  Print Space$((100 - Len(s$)) \ 2) s$
End Sub

Sub show_credits()
  Local denizens$(20, 3), i, s$, sz
  Restore denizens
  read_string_array(denizens$())

  ' Format credits.
  Local credits$(Bound(denizens$(), 1))
  For i = Bound(denizens$(), 0) To Bound(denizens$(), 1)
    s$ = denizens$(i, 1)
    If s$ = "" Then s$ = denizens$(i, 2) + " " + denizens$(i, 3)
    s$ = Space$((15 - Len(s$)) \ 2) + s$
    s$ = s$ + Space$(15 - Len(s$))
    If s$ <> Space$(15) Then sz = sz + 1 : credits$(sz) = s$
  Next i
  If sz Mod 2 = 1 Then sz = sz + 1 : credits$(sz) = Space$(15)

  Local url$ = "http://www.thebackshed.com/forum/ViewForum.php?FID=16"

  show_credits_vga(credits$(), sz, url$)
  show_credits_serial(credits$(), sz, url$)

  Local k$ = we.wait_for_key$()
End Sub

Sub show_credits_vga(credits$(), sz, url$)
  Local i, s$

  Page Write 1
  Cls ' Note this will also clear the serial console.
  Local x = Mm.HRes \ 2
  Text x, Mm.Info(VPOS) + 48, "Brought to you by the", C, 3, 1, RGB(Yellow)
  Text x, Mm.Info(VPOS) + 24, "Denizens of The Back Shed", C, 3, 1, RGB(Yellow)
  Text x, Mm.Info(VPOS) + 16, ""
  For i = Bound(credits$(), 0) To sz \ 2
    s$ = credits$(i) + "  " + credits$(i + sz \ 2)
    Text x, Mm.Info(VPOS) + 20, s$, C, 2, 1, RGB(White)
  Next i
  Text x, Mm.Info(VPOS) + 36, url$, C, 1, 1, RGB(Cyan)
  Text x, Mm.Info(VPOS) + 48, "Additional thanks to", C, 3, 1, RGB(Yellow)
  Text x, Mm.Info(VPOS) + 36, "Geoff Graham, Peter Mather & 'The CMM2 Team'", C, 2
  Text x, Mm.Info(VPOS) + 24, "Scott Adams for 'Pirate Adventure'", C, 2
  Text x, Mm.Info(VPOS) + 48, "Press any key to return to the menu", C, 3, 1, RGB(Yellow)
  Page Copy 1 To 0, B
  Page Write 0
End Sub

Sub show_credits_serial(credits$(), sz, url$)
  Local i, s$

  Option Console Serial
  print_centered("Brought to you by the Denizens of The Back Shed")
  Print
  For i = Bound(credits$(), 0) To sz \ 2
    print_centered(credits$(i) + "  " + credits$(i + sz \ 2))
  Next i
  Print
  print_centered(url$)
  Print
  print_centered("Additional thanks to")
  Print
  print_centered("Geoff Graham, Peter Mather & 'The CMM2 Team'")
  print_centered("Scott Adams - for 'Pirate Adventure'")
  Print
  Print_centered("Press any key to return to the menu.")
  Option Console Both
End Sub

Function quit()
  Local s$ = "Are you sure you want to Quit [y|N] ?"
  Text Mm.HRes \ 2, Mm.Info(VPos), s$, C, 3, 1, RGB(YELLOW)
  Option Console Serial  
  Print
  Print s$
  Option Console Both
  If LCase$(we.wait_for_key$()) = "y" Then quit = 1
End Function

Sub goodbye()
  Text Mm.HRes \ 2, Mm.Info(VPos), Space$(Mm.HRes \ 16), C, 3
  Text Mm.HRes \ 2, Mm.Info(VPos), "Goodbye!", C, 3, 1, RGB(YELLOW)
  Option Console Serial  
  Print
  Print "Goodbye!"
  Option Console Both
End Sub

menu_top:
Data "Contents"
Data "1", "WHAT'S NEW?", "menu_new"
Data "2", "Games", "menu_games"
Data "3", "Other amusements", "menu_amusements"
Data "4", "Utilities", "menu_utils"
Data "5", "Demos - Graphics, 3D", "menu_3d"
Data "6", "Demos - Graphics, Fractals", "menu_fractals"
Data "7", "Demos - Graphics, Sprites", "menu_sprites"
Data "8", "Demos - Graphics, Turtle", "menu_turtle"
Data "9", "Demos - Sound", "menu_sound"
Data "X", "Demos - CSUBs", "menu_csub"
Data "C", "Show credits", "credits"
'Data "D", "COMING SOON", "menu_next"
Data "Q", "Quit", "quit"
Data "end"

menu_amusements:
Data "Other Amusements"
Data "1", "Conway's Game of Life", "life/life.bas"
Data "2", "Eliza, the Rogerian psychotherapist", "eliza/eliza.bas"
Data "3", "Mandelbrot Explorer", "mandelbrot-explorer/mandelbrotexp.bas"
Data "B", "Back", "menu_top"
Data "Q", "Quit", "quit"
Data "end"

menu_csub:
Data "CSUB Examples"
Data "1", "Barnsley's Fern using CSUB", "fractals/barnsleys-fern-csub.bas"
Data "2", "Mandelbrot Explorer", "mandelbrot-explorer/mandelbrotexp.bas"
Data "B", "Back", "menu_top"
Data "Q", "Quit", "quit"
Data "end"

menu_fractals:
Data "Fractals"
Data "1", "Mandelbrot Explorer", "mandelbrot-explorer/mandelbrotexp.bas"
Data "2", "Barnsley's Fern", "fractals/barnsleys-fern.bas"
Data "3", "Barnsley's Fern using CSUB", "fractals/barnsleys-fern-csub.bas"
Data "4", "Dragon Curve", "turtle/dragon-curve.bas"
Data "5", "Hex Gasket", "turtle/hex-gasket.bas"
Data "6", "Hilbert Curve", "turtle/hilbert-curve.bas"
Data "7", "Sierpinski Triangle", "turtle/sierpinskis-triangle.bas"
Data "8", "Square Nautilus", "turtle/square-nautilus.bas"
Data "9", "Tree - Recursive", "turtle/tree.bas"
Data "X", "Tree - Random Recursive", "turtle/random-tree.bas"
Data "Y", "Tree - Pine, Recursive", "turtle/pine-tree.bas"
Data "Z", "Tree - Pine, Random Recursive", "turtle/random-pine-tree.bas"
Data "B", "Back", "menu_top"
Data "Q", "Quit", "quit"
Data "end"

menu_games:
Data "Games"
Data "1", "Hunt the Wumpus", "games/wumpus.bas"
Data "2", "Lunar Lander", "games/lunar/lunar.bas"
Data "3", "Minesweeper", "games/minesweeper.bas"
Data "4", "Scott Adams' Pirate Adventure", "pirate/src/interp.bas"
Data "B", "Back", "menu_top"
Data "Q", "Quit", "quit"
Data "end"

menu_new:
Data "What's New?"
Data "1", "Composition #1 (Passacaglia in 32 bits)", "sound/gen-music/GenMusic1.bas"
Data "2", "GPIO Pin Tester", "utils/pin-test/PinTest.bas"
Data "B", "Back", "menu_top"
Data "Q", "Quit", "quit"
Data "end"

menu_sound:
Data "Sound"
Data "1", "Chirps, an interactive sound effect demo", "sound/chirps/chirps-ui.bas"
Data "2", "Composition #1 (Passacaglia in 32 bits)", "sound/gen-music/GenMusic1.bas"
Data "3", "Speech Demo", "sound/speech/speech.bas"
Data "B", "Back", "menu_top"
Data "Q", "Quit", "quit"
Data "end"

menu_sprites:
Data "Sprites"
Data "1", "Playing Cards", "sprites/playing-cards/showcards.bas"
Data "B", "Back", "menu_top"
Data "Q", "Quit", "quit"
Data "end"

menu_turtle:
Data "Turtle Graphics"
Data "1", "Dragon Curve", "turtle/dragon-curve.bas"
Data "2", "Hex Gasket", "turtle/hex-gasket.bas"
Data "3", "Hilbert Curve", "turtle/hilbert-curve.bas"
Data "4", "Sierpinski Triangle", "turtle/sierpinskis-triangle.bas"
Data "5", "Spirals", "turtle/spirals.bas"
Data "6", "Square Nautilus", "turtle/square-nautilus.bas"
Data "7", "Tree - Recursive", "turtle/tree.bas"
Data "8", "Tree - Random Recursive", "turtle/random-tree.bas"
Data "9", "Tree - Pine, Recursive", "turtle/pine-tree.bas"
Data "X", "Tree - Pine, Random Recursive", "turtle/random-pine-tree.bas"
Data "B", "Back", "menu_top"
Data "Q", "Quit", "quit"
Data "end"

menu_utils:
Data "Utilities"
Data "1", "Graphics Test Card", "utils/test-card.bas"
Data "2", "GPIO Pin Tester", "utils/pin-test/PinTest.bas"
Data "B", "Back", "menu_top"
Data "Q", "Quit", "quit"
Data "end"

menu_3d:
Data "3D Graphics"
Data "1", "Rotating Wireframe Buckyball", "graphics/wireframe-buckyball.bas"
Data "2", "Rotating Dodecahedron", "graphics/dodecahedron.bas"
Data "3", "Rotating Football", "graphics/football.bas"
Data "B", "Back", "menu_top"
Data "Q", "Quit", "quit"
Data "end"

' Denizens of TBS: TBS username, forename, surname, TBS username
'  - ordered alphabetically by username unless someone has a better idea.
' Note that Scott Adams will be listed separately as he is not a denizen of the TBS.
denizens:
Data "Andrew_G", "", ""
Data "Bigmik", "Mick", "Gulovsen"
Data "capsikin", "", ""
Data "matherp", "Peter", "Mather"
Data "", "Markus", "Mangold"
Data "PeteCotton", "", ""
Data "Sasquatch", "", ""
Data "TassyJim", "Jim", "Hiley"
Data "thwill", "Tom", "Williams"
Data "Turbo46", "Bill", "McKinley"
Data "TweakerRay", "", ""
Data "vegipete", "", ""
Data "", "William", "Leue"
Data "end"
