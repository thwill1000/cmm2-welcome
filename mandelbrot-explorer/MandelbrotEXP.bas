'Mandelbrot Explorer V1.3 for Color Maximite 2  9/20/2020
'By the Sasquatch
'with thanks to matherp, vegipete, thwill and yock1960 for your contributions
'www.thebackshed.com

#Include "../common/welcome.inc"

Setup:
  'Screen Resolution set here,
  'Should work at any reasonable resolution with at least 3 graphics pages
  'Z)oom cursor requires 3 pages, everything else should work with 2
  Mode 1,8  '800 X 600 for compatabliliy with MMBasic V5.05.04
'  Mode 9,8  '1024 X 768 Nice but a bit slower to render
  CLS


  XMax = MM.HRES - 1
  YMax = MM.VRES - 1
  XCursor = XMax / 2
  YCursor = YMax / 2

  KeyCount = 1

  CONST True = 1
  CONST False = 0
  SFileName$ = "MandelBrot.bmp"
  FileName$ = "MandelBrot.dat"

  Zoom = 2.0
  Depth% = 64
  Scale! = 1.0
  XCenter! = -0.7
  YCenter! = 0.0

  Dim Clut(256) as Integer
  For X = 0 To 255
    Clut(X) = Map(X)
  Next X

  Dim XUndo(100)
  Dim YUndo(100)
  Dim SUndo(100)
  Dim DUndo(100)

  Refresh = True
  Push = True
  Done = False
  RollColors = False
  CList = False
  HaveChuk = False
  HaveClassic = False
  ZoomMode = False
  RefreshCursor = False

  Dim cursor_visible = False

  T = Timer

  MakeSprite

  HelpScreen

  'Check for Wii Nunchuk
  On Error Skip 1
    Wii Nunchuk Open
  If MM.ERRNO = 0 Then
   If Nunchuk(T) = &HA4200000 Then  'Check for original style nunchuk
     HaveChuk = True
   Else
     Wii Nunchuk Close
   End If
  End If

  If Not HaveChuk Then
    'Check for Wii Classic Controller
    On Error Skip 1
      Wii Classic Open
    If MM.ERRNO = 0 Then
     If Classic(T) = &HA4200101 Then  'Check for Classic
       HaveClassic = True
     Else
       Wii Classic Close
     End If
    End If
  End If


MainLoop:
Do  'Main Loop Starts Here
  Key$ = Inkey$              'Read Key from console buffer
  'Process Cursor Keys
  If KeyDown(0) Then         'Read Key on USB keyboard
    For X = 1 to KeyDown(0)
      K = KeyDown(X)
      move_cursor(K)
    Next X

    ' Make the cursor move faster if movement key held down
    ' (which will have set 'RefreshCursor').
    If RefreshCursor Then
      KeyCount = KeyCount + 1
      If KeyCount > 18 Then KeyCount = 18
      Pause(190 - KeyCount * 10)
    EndIf

  Else If Key$ <> "" Then   'Key from Console buffer
    K = Asc(Key$)
    move_cursor(K)

  Else
    ' If Key not pressed, reset key held count
    KeyCount = 1
    K = 0
  EndIf

  If HaveChuk Then
     If Nunchuk(Z) = 1 Then K = 73 'Zoom in
     If Nunchuk(C) = 1 Then K = 67 'Re-Center
     XChuk = Nunchuk(JX)
     YChuk = Nunchuk(JY)
  End If

  If HaveClassic Then
     ClassB = Classic(B)
     if (ClassB AND 1024) Then K = 73 'X button Zoom in
     if (ClassB AND 8192) Then K = 67 'B button re-Center
     XChuk = Classic(LX)
     YChuk = Classic(LY)
  End IF

  If HaveChuk Or HaveClassic Then
     If XChuk > 140 Then XCursor = XCursor + (XChuk - 140) / 250
     If XCursor > XMax Then XCursor = XMax
     If XChuk < 116 Then XCursor = XCursor - (116 - XChuk) / 250
     If XCursor < 0 Then XCursor = 0

     If YChuk > 140 Then YCursor = YCursor - (YChuk - 140) / 250
     If YCursor < 0 Then YCursor = 0
     If YChuk < 115 Then YCursor = YCursor + (115 - YChuk) / 250
     If YCursor > YMax Then YCursor = YMax
     If XCursor <> XOld or YCursor <> YOld Then
       RefreshCursor = True
       XOld = XCursor : YOld = YCursor
       If Not ZoomMode and Not Clist Then Pause 5
     End If
   End If

  'Now Check for other Key Commands
  If K <> 0 Then

    If K = 134 Then               '<Home>
    'Home Key Reset everything
      Zoom = 2.0
      Depth% = 64
      Scale! = 1.0
      XCenter! = -0.70
      YCenter! = 0.0
      Refresh = True
      RollColors = False
      Map Reset

    Else IF K = 67 or K = 99 Then  'C or c
      'Re center at cursor
      UpdateToCursor
      Refresh = True

    Else IF K = 73 Or K = 105 Then 'I or i
      'Zoom in at cursor center
      UpdateToCursor
      Scale! = Scale! * Zoom
      Refresh = True

    Else IF K = 79 Or K = 111 Then  'O or o
      'Zoom out at cursor center
      UpdateToCursor
      Scale! = Scale! / Zoom
      Refresh = True

    Else If K = 90 or K = 122 Then  'Z or z
      If ZoomMode Then
        ZoomMode = False
        Zoom = NewZoom
        BoxW = 0
        Page Copy 1,0
      Else
      'Turn Zoom mode on
        Page Write 2
        CLS
        Page Write 0
        NewZoom = Zoom
        ZoomMode = True
      End If
      RefreshCursor = True
      Pause(200)

    Else IF K = 81 Or K = 113 Then  'Q or q
      'Time to Quit
      Done = True

    Else IF K = 83 Or K = 115 Then  'S or s
      'Save as Bitmap
      Print @(0,0) "Save Bitmap - Please Be Patient "
      Print "Saving the image will take a few seconds "
      Print "File name for Save [";SFileName$;"]";
      Input ;Res$
      If Res$ <> "" Then
          SFileName$ = Res$
      EndIf
      hide_cursor()
      'Refresh the Image
      Page Copy 1 To 0,B
      'Now save to file
      Save Image SFileName$
      Print @(0,0) "Save Image Done "
      Refresh = True

    Else IF K = 68 Or K = 100 Then  'D or d
      'Prompt for new Depth
      Page Copy 1 To 0,B
      Print @(0,0) "Enter Depth (Iterations) ["+STR$(Depth%)+"]";
      Input ;Res$
      If Res$ <> "" And Val(Res$) > 0 And Val(Res$) <= 5000 Then
        Depth% = Val(Res$)
        Refresh = True
      Else
        Page Copy 1 To 0,B
        Pause(200)
      EndIf

    Else IF K = 69 Or K = 101 Then  'E or e
     'Prompt for new coordinates
     Page Copy 1 To 0,B
     Print @(0,0) "Enter Scale ["+STR$(Scale!)+"]";
     Input ;Res$
      If Res$ <> "" And Val(Res$) > 0.0 And Val(Res$) <= 1E13 Then
        SCALE! = Val(Res$)
        Refresh = True
      EndIf
     Print "Enter X Center ["+STR$(XCenter!)+"]";
     Input ;Res$
      If Res$ <> "" And Val(Res$) > -2.0 And Val(Res$) < 2.0 Then
        XCenter! = Val(Res$)
        Refresh = True
      EndIf
     Print "Enter Y Center ["+STR$(YCenter!)+"]";
     Input ;Res$
      If Res$ <> "" And Val(Res$) > -2.0 And Val(Res$) < 2.0 Then
        YCenter! = Val(Res$)
        Refresh = True
      EndIf
     If Not Refresh Then
       Page Copy 1 To 0,B
       Pause(200)
     EndIf

    Else IF K = 76 Or K = 108 Then  'L or l
      'List Current Coordinates On/Off
      If CList Then
        CList = False
        Page Copy 1 To 0,B
      Else
        CList = True
      End If
      Pause(200)

    Else IF K = 72 Or K = 104 Or K = 63 Then 'H or h or ?
      'Show Help Screen
      hide_cursor()
      HelpScreen
      Page Copy 1 To 0,B
      RefreshCursor = True
      Pause(200)

    Else IF K = 70 Or K = 102 Then  'F or f
      'File Menu???
      hide_cursor()
      FileMenu
      Page Copy 1 To 0,B
      RefreshCursor = True
      Pause(200)

    Else IF K = 82 Or K = 114 Then  'R or r
      'Toggle Roll Colors On/Off
      If RollColors Then
        RollColors = False
      else
        RollColors = True
      EndIf
      Pause(200)

    Else IF K = 77 Or K = 109 Then  'M or m
      'Reset Color Map
       RollColors = False
       Map Reset

    Else IF K = 85 Or K = 117 Then  'U or u
      'Undo last coordinate change
       PopUndo 'Get previous coordinates from the undo buffer
       Push = False
       Pause(200)

    Else If ZoomMode Then  ' Commands only if Zoom cursor on
      If K = 27 Then             '<Esc>
        ZoomMode = False
        Page Copy 1,0
        RefreshCursor = True
      End If

      If K = 10 Then        '<Enter>
        ZoomMode = False
        UpdateToCursor
        Zoom = NewZoom
        Scale! = Scale! * Zoom
        Refresh = True
      End If

      If K = 43 Or K = 61 Then  '+ or =
       NewZoom = NewZoom * 2
       If NewZoom > 32.0 Then NewZoom = 32.0
       RefreshCursor = True
       Pause(200)
      End If

      If K = 45 Or K = 95 Then   '- Or _
       NewZoom = NewZoom / 2
       If NewZoom < 1.0 Then NewZoom = 1.0
       RefreshCursor = True
       Pause(200)
      EndIf


    EndIf  'If ZoomMode Then

  EndIf  'If K <> 0 Then

  If Refresh Then
    hide_cursor()
    'Call the Mandelbrot CSUB to render the image
'    S = Timer
    Mandelbrot Depth%,Scale!,XCenter!,YCenter!
'    Print @(0,0) Timer - S
    Page Copy 0 TO 1
    XCursor = XMax / 2
    YCursor = YMax / 2
    If Push Then PushUndo ' Push the new coordinates into the undo buffer
    Push = True
    Refresh = False
    show_cursor()
    Do While Inkey$ <> "" : Loop

  EndIf

  If CList Then
      Print @(0,0)"X Center = [";XCenter!;"] ";
      Print XCenter! + (XCursor - XMax / 2) / XMax * 3 / Scale!;" "
      Print "Y Center = [";YCenter!;"] ";
      Print YCenter! + (YMax / 2 - YCursor) / YMax * 3 / Scale!;" "
      Print "Scale = [";Scale!;"] "
      Print "Depth = [";Depth%;"] "
  EndIf


  If RefreshCursor Then
    If ZoomMode Then
      Page Write 2
'      CLS
      If BoxW <> 0.0 Then Box BoxX,BoxY,BoxW,BoxH,,0
      BoxX = XCursor-(XMax/NewZoom)/2
      BoxY = YCursor-(YMax/NewZoom)/2
      BoxW = Xmax/NewZoom
      BoxH = YMax/NewZoom
      Box BoxX,BoxY,BoxW,BoxH
      Page Write 0
      Page XOR_PIXELS 1,2,0
      If Not CList Then
        Print @(0,0) "Zoom Factor ["+STR$(Zoom)+"]"; NewZoom;" "
      End If
    End If
    show_cursor()

    RefreshCursor = False
  End If


  If RollColors And Timer - T > 750 Then
    T = Timer
    Temp = Clut(0)
    For X = 0 to 254
       Clut(X) = Clut(X+1)
       Map(X) = Clut(X)
    Next X
    Clut(255) = Temp
    Map(255) = Temp
    Map Set
  EndIf

Loop While Not Done  'End of Main Loop

Map Reset
If HaveChuk Then Wii Nunchuk Close
If HaveClassic Then Wii Classic Close
CLS

we.end_program()

Sub move_cursor(k)
  Select Case k
    Case 128 ' Up Arrow
      YCursor = YCursor - 1
      If YCursor < 0 Then YCursor = 0
    Case 129 ' Down Arrow
      YCursor = YCursor + 1
      If YCursor > YMax Then YCursor = YMax
    Case 130 ' Left Arrow
      XCursor = XCursor - 1
      If XCursor < 0 Then XCursor = 0
    Case 131 ' Right Arrow
      XCursor = XCursor + 1
      If XCursor > XMax Then XCursor = XMax
    Case Else
      Exit Sub
  End Select

  RefreshCursor = True
End Sub

Sub show_cursor()
  Sprite Show 1,XCursor-15,YCursor-15,1
  cursor_visible = True
End Sub

Sub hide_cursor()
  If cursor_visible Then Sprite Hide 1
  cursor_visible = False
End Sub

'Push current coordinates into Undo buffer
Sub PushUndo
   For i = 98 to 1 step -1
     XUndo(i) = XUndo(i-1)
     YUndo(i) = YUndo(i-1)
     DUndo(i) = DUndo(i-1)
     SUndo(i) = SUndo(i-1)
   Next i

   XUndo(0) = XCenter!
   YUndo(0) = YCenter!
   SUndo(0) = Scale!
   DUndo(0) = Depth%
End Sub

'Pop coordinates from Undo buffer
Sub PopUndo
  For i = 0 to 99
    XUndo(i) = XUndo(i+1)
    YUndo(i) = YUndo(i+1)
    SUndo(i) = SUndo(i+1)
    DUndo(i) = DUndo(i+1)
  Next i

  If DUndo(0) <> 0 Then
    XCenter! = XUndo(0)
    YCenter! = YUndo(0)
    Scale! = SUndo(0)
    Depth% = DUndo(0)
    Refresh = True
  End If
End Sub


Sub UpdateToCursor
  'Calculate new Mandelbrot coordinates from cursor position
  XCenter! = XCenter! + (XCursor - XMax / 2) / XMax * 3 / Scale!
  YCenter! = YCenter! + (YMax / 2 - YCursor) / YMax * 3 / Scale!
End Sub


SUB MakeSprite
  'Draw the cursor sprite and then read from screen
  CLS
  Line 15,0,15,29,1
  Line 0,15,29,15,1
  Circle 15,15,10,1
  Circle 15,15,2,1,,0,0
  Sprite Read 1,0,0,30,30
  CLS
End Sub


Sub FileMenu
  Do While Inkey$ <> "" : Loop
  CLS
  Print:Print
  Print "File Menu"
  Print:Print
  FName$ = Dir$(WE.PROG_DIR$ + "/*.Dat",FILE)
  Do While FName$ <> ""
    IF Left$(FName$,1) <> "." Then Print FName$
    FName$ = Dir$()
  Loop
  Print:Print
  Print "Press   L)oad   S)ave   D)one :"
  FileDone = False
  Do
    R$ = Inkey$
    If R$ = "D" Or R$ = "d" Then
      FileDone = True
    Else If R$ = "L" Or R$ = "l" Then
      Pause(400)
      OldFileName$ = FileName$
      Print"File Name to Load:["+FileName$+"]"; :Input;FileName$
      if FileName$ = "" Then FileName$ = OldFileName$
      if Instr(1,FileName$,".") = 0 Then FileName$ = FileName$ + ".Dat"
      On Error Skip 1
       Open WE.PROG_DIR$ + "/" + FileName$ for Input As #1
      If MM.ERRNO = 0 Then
        Print "Loading: ";FileName$
        Input #1, XCenter!
        Input #1, YCenter!
        Input #1, Scale!
        Input #1, Depth%
        Close #1
        Refresh = True
      Else
        Print "File Error: ";MM.ERRNO
        Pause 2000
      EndIf
      FileDone = True
    Else If R$ = "S" Or R$ = "s" Then
      Pause(400)
      OldFileName$ = FileName$
      Print"File Name to Save:["+FileName$+"]"; :Input;FileName$
      if FileName$ = "" Then FileName$ = OldFileName$
      If Instr(1,FileName$,".") = 0 Then FileName$ = FileName$ + ".Dat"
      On Error Skip 1
        Open WE.PROG_DIR$ + "/" + FileName$ for Output As #1
      If  MM.ERRNO = 0 Then
        Print "Saving: ";FileName$
        Print #1,STR$(XCenter!,0,15)
        Print #1,STR$(YCenter!,0,15)
        Print #1,Scale!
        Print #1,Depth%
        Close #1
      Else
        Print "File Error: ";MM.ERRNO
        Pause 2000
      End IF
      FileDone = True
    End If
        Pause(400)
  Loop While Not FileDone
  Do While Inkey$ <> "" : Loop
  CLS
End Sub


Sub HelpScreen
  'Because we all need a little help sometimes :)
  CLS
  Do While Inkey$ <> "" : Loop
  Print
  Print "Mandelbrot Explorer V1.3 for Color Maximite 2
  Print
  Print "By the Sasquatch"
  Print " With thanks to matherp, vegipete, thwill and yock1960 for your contributions"
  Print "www.thebackshed.com"
  Print : Print
  Print "Nunchuk Controls:                                 Wii Classic Controls:"
  Print "       Joystick - Move cursor                           LJoystick - Move cursor"
  Print "       C Button - re-Center at cursor                    A Button - re-Center at cursor"
  Print "       ZButton - Zoom in at cursor                       X Button - Zoom in at cursor"
  Print
  Print "Cursor Command Keys:"
  Print "   <Arrow Keys> - Move Cursor"
  Print "         <Home> - Reset to default coordinates"
  Print "              C - re-Center at cursor"
  Print "              I - zoom In at cursor"
  Print "              O - zoom Out at cursor"
  Print "              Z - Enter Zoom Cursor Mode"
  Print "                    +/- - Increase/Decrease Zoom Factor"
  Print "                  <Esc> - Abort Zoom Mode"
  Print "                <Enter> - Zoom to current cursor"
  Print "                    <Z> - Set Zoom Factor and exit"
  Print
  Print "Color Command Keys:"
  Print "              R - toggle Roll Colors on/off"
  Print "              M - reset color Map"
  Print
  Print "Coordinate Command Keys:"
  Print "              D - change Depth (iterations)"
  Print "              E - Enter new coordinates"
  Print "              L - Toggle coordinates List On/Off"
  Print "              U - Undo the last coordinate change"
  Print
  Print "System Command Keys:"
  Print "              F - File Menu
  Print "            H,? - Help screen"
  Print "              S - Save bitmap file"
  Print "              Q - Quit program"
  Print
  Print "Note: Press <Enter> at any prompt to retain current value"
  Print : Print
  On Error Skip 1
  Load JPG WE.PROG_DIR$ + "/Mandelbrotaxes.jpg",XMax-351,200
  Print "Press Q)uit F)ile or any key to Continue"
  Pause(100)
  Do
    R$ = Inkey$
    Pause(100)
  Loop While R$ = ""
  If R$ = "Q" or R$ = "q" Then
    CLS
    we.end_program()
  End If
  If R$ = "F" or R$ = "f" Then FileMenu
  CLS
  Do While Inkey$ <> "" : Loop
End Sub


'Mandelbrot CSub
'Mandelbrot(Depth,Scale,XCenter,YCenter)
'File mandelbrot.bas written 20-09-2020 13:23:23
CSUB mandelbrot
  00000000
  'mandelbrot
  4FF0E92D 46834C54 460F2000 46916824 8B08ED2D 9301B083 4B5047A0 681B4950
  681B6809 2B00680A F3409200 EE07808A EE063A90 EEB72A90 2A007A00 7AE7EEF8
  6AE6EEF8 BA27EE87 BA26EEC7 F103DD79 F8DF38FF 4615A110 0608FB02 AB00EEB6
  9B3BED9F 6A8BEE27 EEB09B01 EEB75B08 ED976AC6 EE367B00 ED936B4A EE868B00
  EE944B07 06AB8B05 F8DAD102 47983000 5A90EE07 3000F8DB 5B08EEB0 6AE7EEB8
  ED972B01 EE267B00 ED996A2B EEB72B00 EE366AC6 EE866B4A EEA44B07 DD3D2B05
  EEB02401 EEB11B00 EEB00B00 EEB05B49 EEB07B49 EEB06B49 EE274B49 34017B05
  EE32429C EEB06B46 EEA75B48 EE365B01 D01E7B04 4B07EE27 6B05EE25 3B04EE36
  3BC0EEB4 FA10EEF1 F004DDE7 19AB043F 4C01F803 D1B63D01 1AF69B00 0F00F1B8
  EE07D00F 461D8A90 38FFF108 7AE7EEF8 19ABE798 F8032000 E7EB0C01 2401D0F9
  B003E7E3 8B08ECBD 8FF0E8BD 8000F3AF 00000000 00000000 08000340 080002F0
  080002EC 0800033C
End CSUB


'To use the function below, rename the CSUB version above to MandelbrotC
'And rename the function below to Mandelbrot (without the B)

'Pure MMBASCIC version of the Mandelbrot Sub
'Fully compatable with the CSUB version
'Runs about 400 times slower than CSUB
'Useful for educaton and experimentation
'Mandelbrot(Depth,Scale,XCenter,YCenter)
'Variable names shortened for efficiency
Sub MandelbrotB(IMax%,Mag!,XCen!,YCen!)  'Maximum Iterations (Depth), Magnification (Scale)
                                         'X-Center, Y-Center
  For HY = YMax To 1 Step - 1    'Step through each Row (Line) of pixels (Y-Axis)
    CY = (HY / YMax - 0.5) / Mag! * 3.0 - YCen!

    For HX = XMax TO 1 Step - 1   'Step through each Pixel in the Row (X-Axis)
      CX = (HX / XMax - 0.5) / Mag! * 3.0 + XCen!

      X = 0.0 : Y = 0.0

      For Iter = 1 to IMax%      'Step from 1 to Maximum Iterations
        XSqr = X * X
        YSqr = Y * Y

        If XSqr + YSqr > 4.0 Then Exit For  'If "radius" greater than escape value stop
                                            'C^2 = A^2 + B^2 or R^2 = X^2 + Y^2

        Y = 2.0 * X * Y + CY     'Iterate next value
        X = XSqr - YSqr + CX

      Next Iter

      If Iter - 1 < IMax% Then   'If we didn't reach the Maximum number of iterations (Depth)
        Pixel HX - 1, HY - 1, map(Iter Mod 64) 'color the pixel based on number of Iterations
      Else
        Pixel HX - 1, HY - 1, 0  'Otherwise Make the Pixel black
      End If

    Next HX

  Next HY
End Sub
