' CMM2 "Welcome Tape" Menu
' By Thomas Hugo Williams "thwill" 2020
' With UI polishing by "vegipete"
' And soundtrack by "TweakerRay"

Option Explicit
Option Default Float
Option Base 0

#Include "../common/welcome.inc"
#Include "splash.inc"

we.check_firmware_version()

Const TOPLINE = 106
Const TITLE$ = "WELCOME TAPE"

Mode 1, 8

Play MP3 WE.PROG_DIR$ + "/TweakerRaySpaceFlight-160kb.mp3"

Dim menu_label$ = Mm.CmdLine$
If menu_label$ = "" Then
  menu_label$ = "menu_top"
  splash()
EndIf

' Load CMM2 logo.
Page Write 2
Cls
Load PNG WE.PROG_DIR$ + "/logo-small.png", 276, 10
Text MM.HRes / 2, 70, TITLE$, C, 3, 1, RGB(Yellow)
Text MM.HRes - 16, MM.VRes - 16, WE.VERSION$, R, 1, 1, RGB(White)
Page Write 0

Do While menu_label$ <> ""
  menu_label$ = show_menu$(menu_label$)
Loop

goodbye()
Play Stop
End

Function show_menu$(menu_label$)
  On Error Ignore
  Execute "Restore " + menu_label$
  On Error Abort
  If Mm.ErrNo <> 0 Then Error "Unknown menu: " + menu_label$

  Local menu_name$
  Read menu_name$
  Local items$(20, 2)
  Local items_sz = read_string_array(items$())

  Local i, width
  For i = 0 To items_sz - 1
    width = Max(width, Len(items$(i, 1)))
  Next i
  For i = 0 To items_sz - 1
    items$(i, 1) = items$(i, 1) + Space$(width - Len(items$(i, 1)))
  Next i

  draw_menu(menu_name$, items$(), items_sz, -1)

  we.clear_keyboard_buffer()

  Local k$
  Local selected = -1
  Local old_selected
  Do
    k$ = wait_for_key$()

    old_selected = selected
    Select Case k$
      Case "down"
        ' Move selection down if not at bottom.
        If selected < items_sz - 1 Then selected = selected + 1
      Case "select"
        If selected > -1 Then k$ = LCase$(items$(selected, 0))
      Case "up" :
        ' Move selection up if not at top.
        If selected = -1 Then selected = 0
        If selected > 0 Then selected = selected - 1
    End Select

    If old_selected <> selected Then draw_menu(menu_name$, items$(), items_sz, selected)

    For i = 0 To items_sz - 1
      If LCase$(items$(i, 0)) = k$ Then
        If items$(i, 2) = "credits" Then
          show_credits()
          show_menu$ = menu_label$
          Exit Function
        Else If items$(i, 2) = "quit" Then
          If Not quit() Then show_menu$ = menu_label$
          Exit Function
        Else If Left$(items$(i, 2), 5) = "menu_" Then
          show_menu$ = items$(i, 2)
          Exit Function
        Else
          Play Stop
          we.run_program(WE.INSTALL_DIR$ + "/" + items$(i, 2), "--menu " + menu_label$)
          Error "Should never get here"
        EndIf
      EndIf
    Next i
  Loop

End Function

' @return  number of elements (of first index) read.
Function read_string_array(a$())
  Local lbound = Bound(a$(), 0)
  Local i = lbound, j = lbound, s$
  Do
    Read s$
    If s$ = "end" Then Exit Do
    a$(i, j) = s$
    j = j + 1
    If j = Bound(a$(), 2) + 1 Then j = lbound : i = i + 1
  Loop
  read_string_array = i - lbound
End Function

Sub dump_string_array(a$())
  Local lbound = Bound(a$(), 0)
  Local i, j
  For i = lbound To Bound(a$(), 1)
    Print "[" Str$(i) "] ";
    For j = lbound To Bound(a$(), 2)
      If j <> lbound Then Print ", ";
      If a$(i, j) = "" Then Print "<empty>"; Else Print "{" a$(i, j) "}";
    Next j
    Print
  Next i
End Sub

Function wait_for_key$()
  Local k$ = we.wait_for_key$()
  Select Case Asc(k$)
    Case 13       : k$ = "select" ' enter
    Case 27       : k$ = "q"      ' escape
    Case Asc("m") : k$ = "b"      ' for backward compatibility [M] does same as [B]
    Case 128      : k$ = "up"     ' up arrow
    Case 129      : k$ = "down"   ' down arrow
    Case 130      : k$ = "b"      ' left arrow
    Case 131      : k$ = "select" ' right arrow
    Case Else     : k$ = LCase$(k$)
  End Select
  wait_for_key$ = k$
End Function

Sub draw_menu(menu$, items$(), items_sz, sel)
  draw_menu_vga(menu$, items$(), items_sz, sel)
  draw_menu_serial(menu$, items$(), items_sz, sel)
End Sub

Sub draw_menu_vga(menu$, items$(), items_sz, sel)
  Local i
  Local x = Mm.HRes \ 2
  Local y = TOPLINE

  Option Console Screen
  Page Write 1
  Page Copy 2, 1

  Text x, y, UCase$(menu$), C, 3, 1, RGB(White) : y = y + 36
  For i = 0 To items_sz - 1
    Text x, y, format_item$(items$(), i), C, 2, 1, RGB(White) * (i <> sel), RGB(White) * (i = sel)
    y = y + 20
  Next i
  y = y + 12
  Text x, y, "Press a key to select an option", C, 2, 1, RGB(Yellow) : y = y + 20
  Local s$ = "Or use " + Chr$(146) + ", " + Chr$(147) + ", [Enter] to select, "
  s$ = s$ + Chr$(149) + " to go back, [Esc] to quit"
  Text x, y, s$, C, 1, 1, RGB(Yellow)

  Page Copy 1 To 0, B
  Page Write 0
  Option Console Both
End Sub

Function format_item$(items$(), i)
  format_item$ = "[" + items$(i, 0) + "] " + items$(i, 1)
End Function

Sub draw_menu_serial(menu$, items$(), items_sz, sel)
  Local i

  Option Console Serial
  vt100("H") ' cursor home

  If sel > 0 Then

    ' Just redraw the selection.
    vt100(Str$(sel + 4) + "B") ' cursor down n lines
    For i = sel - 1 To sel + 1
      If i < 0 Then
        Print
      ElseIf i > items_sz - 1 Then
        Print
      Else
        print_centered(format_item$(items$(), i), i = sel)
      EndIf
    Next i
    vt100(Str$(items_sz + 8) + ";0H") ' move cursor to screen location
  Else

    ' Redraw the whole menu.
    vt100("2J") ' clear screen
    print_centered("Colour Maximite 2 " + Chr$(34) + TITLE$ + CHr$(34))
    print_centered(WE.VERSION$)
    Print
    print_centered(UCase$(menu$))
    Print
    For i = 0 To items_sz - 1
      print_centered(format_item$(items$(), i), i = sel)
    Next i
    Print
    print_centered("Press a key to select an option")
    print_centered("Or use [Up], [Down], [Enter] to select, [Left] to go back, [Esc] to quit")
  EndIf

  Option Console Both
End Sub

Sub vt100(s$)
  Print Chr$(27) "[" s$;
End Sub

Sub print_centered(s$, reverse)
  Print Space$((100 - Len(s$)) \ 2);
  If reverse Then vt100("7m")
  Print s$;
  If reverse Then vt100("0m")
  Print
End Sub

Sub show_credits()
  Local denizens$(20, 2), i, s$, sz
  Restore denizens
  sz = read_string_array(denizens$())

  we.clear_keyboard_buffer()

  ' Format credits.
  If sz Mod 2 = 1 Then sz = sz + 1
  Local credits$(sz - 1)
  For i = 0 To sz - 1
    s$ = denizens$(i, 0)
    If s$ = "" Then s$ = denizens$(i, 1) + " " + denizens$(i, 2)
    s$ = Space$((15 - Len(s$)) \ 2) + s$
    credits$(i) = s$ + Space$(15 - Len(s$))
  Next i

  Local txt$(6)
  txt$(0) = "Soundtrack: 'SPACEFLIGHT' from the Album 'Distance'"
  txt$(1) = "available for FREE download at https://tweakerray.bandcamp.com"
  txt$(2) = "composed by TweakerRay (www.tweakerray.de)"
  txt$(3) = "Geoff Graham, Peter Mather & 'The CMM2 Team'"
  txt$(4) = "Scott Adams for 'Pirate Adventure'"
  txt$(5) = "Comment at: http://www.thebackshed.com/forum/ViewForum.php?FID=16"
  txt$(6) = "Updates from: https://github.com/thwill1000/cmm2-welcome/releases"

  show_credits_vga(credits$(), txt$())
  show_credits_serial(credits$(), txt$())

  Local k$ = we.wait_for_key$()
End Sub

Sub show_credits_vga(credits$(), txt$())
  Local i, s$, sz = Bound(credits$(), 1) + 1

  Option Console Screen
  Page Write 1
  Page Copy 2, 1

  Local x = Mm.HRes \ 2
  Text x, TOPLINE, "Brought to you by the", C, 3, 1, RGB(White)
  Text x, Mm.Info(VPOS) + 24, "Denizens of The Back Shed", C, 3, 1, RGB(White)
  Text x, Mm.Info(VPOS) + 16, ""
  For i = 0 To sz \ 2 - 1
    s$ = credits$(i) + "  " + credits$(i + sz \ 2)
    Text x, Mm.Info(VPOS) + 20, s$, C, 2, 1, RGB(Yellow)
  Next i
  Text x, Mm.Info(VPOS) + 36, txt$(0), C, 1, 1, RGB(Cyan)
  Text x, Mm.Info(VPOS) + 16, txt$(1), C, 1, 1, RGB(Cyan)
  Text x, Mm.Info(VPOS) + 16, txt$(2), C, 1, 1, RGB(Cyan)
  Text x, Mm.Info(VPOS) + 36, "Additional thanks to", C, 3, 1, RGB(White)
  Text x, Mm.Info(VPOS) + 36, txt$(3), C, 2, 1, RGB(Yellow)
  Text x, Mm.Info(VPOS) + 24, txt$(4), C, 2, 1, RGB(Yellow)
  Text x, Mm.Info(VPOS) + 36, txt$(5), C, 1, 1, RGB(Cyan)
  Text x, Mm.Info(VPOS) + 16, txt$(6), C, 1, 1, RGB(Cyan)
  Text x, Mm.Info(VPOS) + 36, "Press any key to return to the menu", C, 2, 1, RGB(White)

  Page Copy 1 To 0, B
  Page Write 0
  Option Console Both
End Sub

Sub show_credits_serial(credits$(), txt$())
  Local i, s$, sz = Bound(credits$(), 1) + 1

  Option Console Serial
  vt100("H")  ' cursor home
  vt100("2J") ' clear screen
  print_centered("Colour Maximite 2 " + Chr$(34) + TITLE$ + CHr$(34))
  print_centered(WE.VERSION$)
  Print
  print_centered("Brought to you by the Denizens of The Back Shed")
  Print
  For i = 0 To sz \ 2 - 1
    print_centered(credits$(i) + "  " + credits$(i + sz \ 2))
  Next i
  Print
  print_centered(txt$(0))
  print_centered(txt$(1))
  print_centered(txt$(2))
  Print
  print_centered("Additional thanks to")
  Print
  print_centered(txt$(3))
  print_centered(txt$(4))
  Print
  print_centered(txt$(5))
  print_centered(txt$(6))
  Print
  print_centered("Press any key to return to the menu")
  Option Console Both
End Sub

Function quit()
  we.clear_keyboard_buffer()

  Local s$ = "Are you sure you want to Quit [y|N] ?"
  Text Mm.HRes \ 2, Mm.Info(VPos) + 20, s$, C, 3, 1, RGB(YELLOW)
  Option Console Serial
  Print
  print_centered(s$)
  Option Console Both
  If LCase$(we.wait_for_key$()) = "y" Then quit = 1
End Function

Sub goodbye()
  Text Mm.HRes \ 2, Mm.Info(VPos), Space$(Mm.HRes \ 16), C, 3
  Text Mm.HRes \ 2, Mm.Info(VPos), "Goodbye!", C, 3, 1, RGB(YELLOW)
  Option Console Serial
  Print
  print_centered("Goodbye!")
  Option Console Both
End Sub

menu_top:
Data "Contents"
'Data "1", "WHAT'S NEW?", "menu_new"
Data "1", "Games & Other Amusements", "menu_games"
Data "2", "Graphics, 3D", "menu_3d"
Data "3", "Graphics, Fractals", "menu_fractals"
Data "4", "Graphics, Sprites", "menu_sprites"
Data "5", "Graphics, Turtle", "menu_turtle"
Data "6", "Sound & Music", "menu_sound"
Data "7", "CSUB Examples", "menu_csub"
Data "8", "Miscellaneous", "menu_misc"
Data "9", "Utilities", "menu_utils"
Data "C", "Show Credits", "credits"
'Data "D", "COMING SOON", "menu_next"
Data "Q", "Quit", "quit"
Data "end"

menu_csub:
Data "CSUB Examples"
Data "1", "Barnsley's Fern using CSUB", "fractals/barnsleys-fern-csub.bas"
Data "2", "Mandelbrot Explorer", "mandelbrot-explorer/mandelbrotexp.bas"
Data "3", "Scrolling Text", "misc/scrolling-text/scrolling-text.bas"
Data "B", "Back", "menu_top"
Data "Q", "Quit", "quit"
Data "end"

menu_fractals:
Data "Graphics, Fractals"
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
Data "Games & Other Amusements"
Data "1", "Conway's Game of Life", "life/life.bas"
Data "2", "Eliza, the Rogerian psychotherapist", "eliza/eliza.bas"
Data "3", "Guardian, Shoot 'Em Up", "games/guardian/guardian.bas"
Data "4", "Hunt the Wumpus", "games/wumpus.bas"
Data "5", "Lunar Lander", "games/lunar/lunar.bas"
Data "6", "Mandelbrot Explorer", "mandelbrot-explorer/mandelbrotexp.bas"
Data "7", "Minesweeper", "games/minesweeper.bas"
Data "8", "Scott Adams' Pirate Adventure", "pirate/src/interp.bas"
Data "B", "Back", "menu_top"
Data "Q", "Quit", "quit"
Data "end"

menu_misc:
Data "Miscellaneous"
Data "1", "Matrix Text", "misc/matrix-text/matrix-text.bas"
Data "2", "Original Splash Screen", "misc/original-splash/splash.bas"
Data "3", "Scrolling Text", "misc/scrolling-text/scrolling-text.bas"
Data "B", "Back", "menu_top"
Data "Q", "Quit", "quit"
Data "end"

menu_new:
Data "What's New?"
Data "1", "Bouncing Balls", "sprites/bouncing-balls/balls.bas"
Data "2", "Brownian Motion", "sprites/brownian-motion/brownian.bas"
Data "3", "Composition #1 (Passacaglia in 32 bits)", "sound/gen-music/GenMusic1.bas"
Data "4", "Ghost, sprite with transparency", "sprites/ghost/ghost.bas"
Data "5", "GPIO Pin Tester", "utils/pin-test/PinTest.bas"
Data "6", "Guardian, Shoot 'Em Up", "games/guardian/guardian.bas"
Data "7", "Matrix Text", "misc/matrix-text/matrix-text.bas"
Data "8", "Mr. Polysynth", "sound/mr-polysynth/mr-polysynth.bas"
Data "9", "Musical Scales", "sound/scales/scales.bas"
Data "X", "Scrolling Text", "misc/scrolling-text/scrolling-text.bas"
Data "B", "Back", "menu_top"
Data "Q", "Quit", "quit"
Data "end"

menu_sound:
Data "Sound & Music"
Data "1", "Chirps, an interactive sound effect demo", "sound/chirps/chirps-ui.bas"
Data "2", "Composition #1 (Passacaglia in 32 bits)", "sound/gen-music/GenMusic1.bas"
Data "3", "Mr. Polysynth", "sound/mr-polysynth/mr-polysynth.bas"
Data "4", "Musical Scales", "sound/scales/scales.bas"
Data "5", "Speech Demo", "sound/speech/speech.bas"
Data "B", "Back", "menu_top"
Data "Q", "Quit", "quit"
Data "end"

menu_sprites:
Data "Graphics, Sprites"
Data "1", "Bouncing Balls", "sprites/bouncing-balls/balls.bas"
Data "2", "Brownian Motion", "sprites/brownian-motion/brownian.bas"
Data "3", "Ghost, sprite with transparency", "sprites/ghost/ghost.bas"
Data "4", "Playing Cards", "sprites/playing-cards/showcards.bas"
Data "B", "Back", "menu_top"
Data "Q", "Quit", "quit"
Data "end"

menu_turtle:
Data "Graphics, Turtle"
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
Data "Graphics, 3D"
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
Data "jirsoft", "", ""
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
