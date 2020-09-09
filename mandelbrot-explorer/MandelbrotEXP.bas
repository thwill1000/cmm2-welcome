'Mandelbrot Explorer V1.1 for Color Maximite 2
'By the Sasquatch
'with thanks to matherp, vegipete, and yock1960 for your contributions
'www.thebackshed.com

#Include "../common/welcome.inc"

Setup:
  'Screen Resolution set here, Should work at any reasonable resolution
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

  'Process Cursor Keys
  If KeyDown(0) Then
    For X = 1 to KeyDown(0)
      K = KeyDown(X)
      Select case K
        case 128  'Up Arrow  
          YCursor = YCursor - 1
          If YCursor < 0 Then YCursor = 0
        case 129  'Down Arrow
          YCursor = YCursor + 1
          If YCursor > YMax Then YCursor = YMax
        case 130  'Left Arrow
          XCursor = XCursor - 1
          If XCursor < 0 Then XCursor = 0
        case 131  'Right Arrow
          XCursor = XCursor + 1
          If XCursor > XMax Then XCursor = XMax
      End Select
    Next X

    ' Refresh Cursor Sprite
    If K >= 128 And K <= 131 Then
       RefreshCursor = True

      'Make the cursor move faster if key held down
      KeyCount = KeyCount + 1
      If KeyCount > 18 Then KeyCount = 18
      Pause(190 - KeyCount * 10)
    EndIf

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
      XCenter = -0.70
      YCenter = 0.0
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
      'Hide the cursor Sprite
      If Sprite(X,1) > -1 Then Sprite Hide 1
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
      If Res$ <> "" And Val(Res$) > 0 And Val(Res$) < 1025 Then
        Depth% = Val(Res$)
        Refresh = True
      Else
        Page Copy 1 To 0,B
        Pause(200)  
      EndIf

    Else IF K = 69 Or K = 101 Then  'E or e
     'Propmt for new coordinates
     Page Copy 1 To 0,B
     Print @(0,0) "Enter Scale ["+STR$(Scale!)+"]";
     Input ;Res$
      If Res$ <> "" And Val(Res$) > 0.0 And Val(Res$) < 1E10 Then
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
      If Sprite(X,1) > -1 Then Sprite Hide 1
      HelpScreen
      Page Copy 1 To 0,B
      RefreshCursor = True
      Pause(200)

    Else IF K = 70 Or K = 102 Then  'F or f
      'File Menu???
      If Sprite(X,1) > -1 Then Sprite Hide 1
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
    'Hide the cursor sprite
    If Sprite(X,1) > -1 Then Sprite Hide 1
    'Call the Mandelbrot CSUB to render the image
    S = Timer
    Mandelbrot Depth%,Scale!,XCenter!,YCenter!
    Print @(0,0) Timer - S
    Page Copy 0 TO 1
    XCursor = XMax / 2
    YCursor = YMax / 2 
    If Push Then PushUndo ' Push the new coordinates into the undo buffer
    Push = True
    Refresh = False
'    Pause(400)
    'Show the cursor sprite
    Sprite Show 1,XCursor-15,YCursor-15,1    
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
    Sprite Show 1, XCursor-15,YCursor-15,1

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
Cls

we.quit% = 1
we.end_program()

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
  Print "L)oad   S)ave   Q)uit :"
  FileDone = False
  Do
    R$ = Inkey$
    If R$ = "Q" Or R$ = "q" Then
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
  
  CLS
End Sub


Sub HelpScreen
  'Because we all need a little help sometimes :)
  CLS
  Print 
  Print "Mandelbrot Explorer V1.1 for Color Maximite 2"
  Print 
  Print "By the Sasquatch"
  Print " With thanks to matherp, vegipete, and yock1960 for your contributions"
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
  Print "Press any key to Continue"
  Pause(100)
  Do While Inkey$ = ""
    Pause(100)
  Loop
  CLS
End Sub


'Mandelbrot CSub 
'Mandelbrot(Depth,Scale,XCenter,YCenter)
'File mandelbrot.bas written 08-09-2020 12:39:16
CSUB mandelbrot
  00000000
  B096B580 60F8AF00 607A60B9 4B73603B 2000681B 46034798 4B7163BB 681B681B 
  4B70637B 681B681B 6B3B633B E0CC63FB EE076BFB EEF83A90 6B3B6AE7 3A90EE07 
  7AE7EEB8 7A87EEC6 7AE7EEB7 6B00EEB6 5B46EE37 ED9368BB EE856B00 EEB07B06 
  EE276B08 683B6B06 7B00ED93 7B47EE36 7B0AED87 643B6B7B 6C3BE0A0 033FF003 
  D1022B00 681B4B58 6C3B4798 3A90EE07 6AE7EEF8 EE076B7B EEB83A90 EEC67AE7 
  EEB77A87 EEB67AE7 EE376B00 68BB5B46 6B00ED93 7B06EE85 6B08EEB0 6B06EE27 
  ED93687B EE367B00 ED877B07 F04F7B08 F04F0200 E9C70300 F04F2314 F04F0200 
  E9C70300 23012312 E035647B 7B14ED97 7B07EE27 7B06ED87 7B12ED97 7B07EE27 
  7B04ED87 7B14ED97 6B07EE37 7B12ED97 7B07EE26 6B0AED97 7B07EE36 7B12ED87 
  6B06ED97 7B04ED97 7B47EE36 6B08ED97 7B07EE36 7B14ED87 6B06ED97 7B04ED97 
  7B07EE36 6B00EEB1 7BC6EEB4 FA10EEF1 6C7BDC08 647B3301 681B68FB 429A6C7A 
  E000DBC4 68FBBF00 6C7A681B D10D429A 3B016BFB FB026B7A 461AF303 44136C3B 
  6BBA3B01 22004413 E014701A 425A6C7B 033FF003 023FF002 4253BF58 3A016BFA 
  FB016B79 4611F202 440A6C3A 6BB93A01 B2DB440A 6C3B7013 643B3B01 2B006C3B 
  AF5BF73F 3B016BFB 6BFB63FB F73F2B00 BF00AF2F 3758BF00 BD8046BD 08000340 
  080002EC 080002F0 0800033C 
End CSUB
