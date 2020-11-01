' Matrix Text v1.1
' Code by "TweakerRay"
' Messed about with for the CMM2 Welcome Tape by "thwill"

Option Explicit
Option Default Integer
Option Base 0

#Include "../../common/welcome.inc"

Cls

Dim i, y
Dim r$(10)
Dim x(19)

Color RGB(White)
Print @(0, 588) "Press Q to Quit"

Do
  ' Randomize some x values for the chars
  For i = 0 To 19
    x(i) = Int(Rnd() * 800)
  Next i

  For y=1 To 560 Step 8

    ' Randomize chars from 32-255
    For i = 0 To 9
      r$(i) = Chr$(Int(Rnd()*223)+32)
    Next i

    ' Write characters.
    If y>230 Then
      Color RGB(0,((-1*y)/570*255)+255+20,40)
    Else
      Color RGB(0,255,0)
    EndIf

    Print @(x(0),y*1.0) r$(0)
    Print @(x(1),y*0.5) r$(1)
    Print @(x(2),y*0.7) r$(2)
    Print @(x(3),y*0.6) r$(3)
    Print @(x(4),y*0.9) r$(4)
    Print @(x(5),y*1.0) r$(5)
    Print @(x(6),y*0.5) r$(6)
    Print @(x(7),y*0.7) r$(7)
    Print @(x(8),y*0.6) r$(8)
    Print @(x(9),y*0.9) r$(9)

    ' Erase characters.
    Color RGB(0,0,0)
    Print @(x(10),y*0.5) " "
    Print @(x(11),y*0.7) " "
    Print @(x(12),y*1.0) " "
    Print @(x(13),y*0.9) "   "
    Print @(x(14),y*0.5) "    "
    Print @(x(15),y*0.7) " "
    Print @(x(16),y*0.6) " "
    Print @(x(17),y*0.9) " "
    Print @(x(18),y*1.0) " "
    Print @(x(19),y*1.0) " "
    Print @(x(10),y*1.0) "   "
    Print @(x(11),y*1.0) "   "
    Print @(x(12),y*1.0) "    "
    Print @(x(13),y*1.0) "   "
    Print @(x(14),y*0.7) "    "
    Print @(x(15),y*1.0) "   "
    Print @(x(16),y*0.2) "     "
    Print @(x(17),y*1.0) "   "
    Print @(x(18),y*0.8) "     "
    Print @(x(19),y*1.0) "     "

    If we.is_quit_pressed%() Then Exit Do

  Next y

Loop

we.end_program()

