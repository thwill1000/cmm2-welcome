' Mandelbrot Explorer V1.4 for Color Maximite 2, 26-Oct-2020
' Author: The Sasquatch
' From:   https://www.thebackshed.com/forum/ViewTopic.php?TID=12685&PID=157748
'
' By the Sasquatch with thanks to matherp, vegipete, thwill and
' yock1960 for your contributions.

#Include "../common/welcome.inc"

we.check_firmware_version("5.06.00")

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
  HaveMouse = False
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

  'Check for Mouse on I2C2 Pin27 SDA, Pin28 SCK
  On Error Skip 1
    Controller Mouse Open
  If MM.ERRNO = 0 Then
    HaveMouse = True
    OldMouseX = Mouse(X)
    OldMouseY = Mouse(Y)
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
     If (ClassB AND 134) Then K = 134 'Home Button, Reset
     If (ClassB AND 1024) Then K = 73 'X button, Zoom in
     If (ClassB AND 4096) Then K = 79 'Y button, Zoom Out
     If (ClassB AND 8192) Then K = 67 'B button, re-Center
     XChuk = Classic(LX)
     YChuk = Classic(LY)
  End IF

  If HaveChuk Or HaveClassic Then
     If XChuk > 140 Then XCursor = XCursor + (XChuk - 140) / 250 : PauseMouse = True
     If XCursor > XMax Then XCursor = XMax
     If XChuk < 116 Then XCursor = XCursor - (116 - XChuk) / 250 : PauseMouse = True
     If XCursor < 0 Then XCursor = 0

     If YChuk > 140 Then YCursor = YCursor - (YChuk - 140) / 250 : PauseMouse = True
     If YCursor < 0 Then YCursor = 0
     If YChuk < 115 Then YCursor = YCursor + (115 - YChuk) / 250 : PauseMouse = True
     If YCursor > YMax Then YCursor = YMax
     If XCursor <> XOld or YCursor <> YOld Then
       RefreshCursor = True
       XOld = XCursor : YOld = YCursor
       If Not ZoomMode and Not Clist Then Pause 5
     End If
   End If

  'Check for Mouse Movement and Buttons
  If HaveMouse Then

    ' If Mouse is paused, check for intentional movement
    ' This allows movement by keyboard or 'Chuk
    If PauseMouse Then
      If ABS(Mouse(X) - OldMouseX) > 5 Or Abs(Mouse(Y) - OldMouseY) > 5 Then
        PauseMouse = False
      End If
    End If

    ' If mouse not paused, move cursor to mouse position
    If Not PauseMouse Then
      If Mouse(X) <> OldMouseX Or Mouse(Y) <> OldMouseY Then
        XCursor = Mouse(X)
        YCursor = Mouse(Y)
        RefreshCursor = True
        OldMouseX = Mouse(X)
        OldMouseY = Mouse(Y)
      End If
    End If

    If Mouse(L) Then K = 67 'Left Mouse Button, Re-Center at Cursor
    If Mouse(R) Then K = 73 'Right Mouse Button, Zoom In
    If Mouse(W) THen K = 79 'Center Mouse Button, Zoom Out

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
      Hide_Cursor

      Resize

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
        Hide_Cursor
        Resize
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
    If ABS(YCenter!) < 0.01 Then YCenter! = 0
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
If HaveMouse Then Controller Mouse Close
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

  PauseMouse = True
  RefreshCursor = True
End Sub

Sub show_cursor()
  Sprite Show 1,XCursor-16,YCursor-16,1
  cursor_visible = True
End Sub

Sub hide_cursor()
  If cursor_visible Then Sprite Hide 1
  cursor_visible = False
End Sub

' Call Image Resize_Fast to update the screen
Sub Resize
  SX = 0 : SY = 0
  AX = 0 : AY = 0
  EX = Xmax+1 : EY = YMax+1

  ZX = XCursor-(XMax/Zoom)/2

  If ZX < 0 Then
    SX = FIX((0 - ZX) * Zoom)
    ZX = 0
  End If

  ZW = XMax/Zoom-SX

  If ZX + ZW > XMax Then
    AX = (ZW - (XMax - ZX)) * Zoom
    ZW = XMax - ZX
  End If

  ZY = YCursor-(YMax/Zoom)/2

  If ZY < 0 Then
    SY = FIX((0 - ZY) * Zoom)
    ZY = 0
  End If

  ZH = YMax/Zoom-SY

  If ZY + ZH > YMax Then
    AY = (ZH - (YMax - ZY)) * Zoom
    ZH = YMax - ZY
  End If

  Image Resize_Fast ZX,ZY,ZW,ZH,SX,SY,EX-SX-AX,EY-SY-AY

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
  Print "Mandelbrot Explorer V1.4 for Color Maximite 2
  Print
  Print "By the Sasquatch"
  Print " With thanks to matherp, vegipete, thwill and yock1960 for your contributions"
  Print "www.thebackshed.com"
  Print : Print
  Print "Nunchuk Controls:                                      Wii Classic Controls:"
  Print "       Joystick - Move cursor                                LJoystick - Move cursor"
  Print "       C Button - re-Center at cursor                         B Button - re-Center at cursor"
  Print "       Z Button - Zoom in at cursor                           X Button - Zoom in at cursor"
  Print "                                                              Y Button - Zoom Out at cursor"
  Print "Cursor Command Keys:                                       Home Button - Reset to defaults"
  Print "   <Arrow Keys> - Move Cursor"
  Print "         <Home> - Reset to default coordinates         Mouse Control:"
  Print "              C - re-Center at cursor                         L Button - re-Center"
  Print "              I - zoom In at cursor                           R Button - Zoom In"
  Print "              O - zoom Out at cursor                          C Button - Zoom Out "
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


' Mandelbrot(Depth,Scale,XCenter,YCenter)
CSUB mandelbrot
  00000000
  4FF0E92D 8B10ED2D 4604B083 46924688 4B99469B 2000681B 4B984798 F8D3681B
  EE079000 EEB89A90 4B95BB67 681D681B 5A90EE07 FB67EEB8 ED9B6824 ED9AEB00
  ED98CB00 EEB5AB00 EEF1EB40 F040FA10 46AB8094 6BE7EEB8 7B00EEB6 7B07EE2F
  7B00ED8D 6BC7EEB4 FA10EEF1 80FBF340 3D014680 0705FB09 DB00EEB6 A204F8DF
  9B00EEB1 2C01E068 2301D04D F003425A F002033F BF58023F B2DB4253 F80219F2
  44463C01 3C01F806 D0443D01 F015462E D1020F3F 3000F8DA EE074798 EEB85A90
  EE866BE7 EE377B0B EE877B4D EEB06B0A EEB07B08 EE062B4C 2C012B07 2301DDD3
  5B63ED9F 7B45EEB0 4B45EEB0 6B45EEB0 7B07EE37 3B48EEB0 3B05EEA7 5B43EEB0
  7B44EE36 7B02EE37 429C3301 EE27D00B EE256B07 EE364B05 EEB43B04 EEF13BC9
  DDE5FA10 19F2E7B2 F8022300 44463C01 3C01F806 F10BE7B8 EE073BFF EEB8BA90
  EBA76BE7 44C80709 7B00ED9D 6BC7EEB4 FA10EEF1 8087F340 7B0FEE86 7B4DEE37
  6B0AEE87 7B08EEB0 8B4EEEB0 8B07EE16 F1B9464D DC990F00 46A8E7DD DD722D00
  FB093D01 EEB60605 4F3EDB00 9B00EEB1 2C01E054 2301D048 425A44B2 033FF003
  023FF002 4253BF58 3C01F80A D0403D01 F01546AA D1010F3F 4798683B 5A90EE07
  6BE7EEB8 7B0BEE86 7B4DEE37 6B0AEE87 7B08EEB0 2B4CEEB0 2B07EE06 DDD82C01
  ED9F2301 EEB05B23 EEB07B45 EEB04B45 EE376B45 EEB07B07 EEA73B48 EEB03B05
  EE365B43 EE377B44 33017B02 D00B429C 6B07EE27 4B05EE25 3B04EE36 3BC9EEB4
  FA10EEF1 E7B7DDE5 230044B2 3C01F80A EBA6E7BC F1B80609 D0140801 8A90EE07
  6BE7EEB8 7B0FEE86 7B4DEE37 6B0AEE87 7B08EEB0 8B4EEEB0 8B07EE16 F1B9464D
  DCA50F00 B003E7E5 8B10ECBD 8FF0E8BD 00000000 00000000 08000340 080002EC
  080002F0 0800033C
End CSUB


'To use the function below, rename the CSUB version above to MandelbrotC
'And rename the function below to Mandelbrot (without the B)

'Pure MMBASIC version of the Mandelbrot Sub
'Fully compatable with the CSUB version
'Runs about 400 times slower than CSUB
'Useful for educaton and experimentation
'Mandelbrot(Depth,Scale,XCenter,YCenter)
'Variable names shortened for efficiency
Sub MandelbrotB(IMax%,Mag!,XCen!,YCen!)  'Maximum Iterations (Depth), Magnification (Scale)
                                         'X-Center, Y-Center
  For HY=YMax To 1Step-1    'Step through each Row (Line) of pixels (Y-Axis)
    CY=(HY/YMax-0.5)/Mag!*3.0-YCen!

    For HX=XMax TO 1Step-1   'Step through each Pixel in the Row (X-Axis)
      CX=(HX/XMax-0.5)/Mag!*3.0+XCen!

      X=0.0:Y=0.0

      For Iter=1to IMax%      'Step from 1 to Maximum Iterations
        XSqr=X*X
        YSqr=Y*Y

        If XSqr+YSqr>4Then Exit For  'If "radius" greater than escape value stop
                                            'C^2 = A^2 + B^2 or R^2 = X^2 + Y^2

        Y=2*X*Y+CY     'Iterate next value
        X=XSqr-YSqr+CX

      Next Iter

      If Iter-1<IMax% Then   'If we didn't reach the Maximum number of iterations (Depth)
        Pixel HX-1,HY-1,map(Iter Mod 64) 'color the pixel based on number of Iterations
      Else
        Pixel HX-1,HY-1,0  'Otherwise Make the Pixel black
      End If

    Next HX

  Next HY
End Sub
