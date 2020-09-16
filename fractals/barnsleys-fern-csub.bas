' CSUB demo of Barnsley's Fern
' Author: The "Sasquatch"
'
' Renders ~150X faster than pure MMBasic version
'
' This demo will render continuously until Q)uit
' Press I key to Zoom in
' Press O key to Zoom out
' Press Q key to Quit

#Include "../common/welcome.inc"

Mode 1,8  ' 800 x 600
'Mode 9,8 ' 1024 x 768

Zoom = 1.0
Seed% = &hAAAAAAAA

ScreenSetup

Do While Inkey$<>"" : Loop   'Clear Keyboard buffer

'Main Loop
Do
 Fern(40000,Zoom,Seed%)
 K$ = LCase$(Inkey$)
 If K$ <> "" Then
   If K$ = "i" Then Zoom = Zoom * 2 : ScreenSetup()
   If K$ = "o" Then Zoom = Zoom / 2 : ScreenSetup()
   If K$ = "q" Then Exit Do
 EndIf
Loop

we.end_program()

Sub ScreenSetup()
  Cls

  Text 0, 0, "Barnsley's Fern using CSUB", "", 2
  Text 2, 25, "Press 'I' to Zoom in", "", 1
  Text 2, 40, "Press 'O' to Zoom out", "", 1
  Text 2, 55, "Press 'Q' to Quit", "", 1

  'Draw a white pixel in the cente of the screen
  'Pixel 400,300,RGB(white)
End Sub

' CSUB version of Barnsley's Fern
'
' Fern(Iterations%,Zoom!,Seed%)
'
' Note that this Sub stores it's state in Seed and can be called repeatedly -
'   it will continue to render as long as the Seed is not the same on each call.
' Caution:  I have found that calling for more than 40,000 iterations -
'   can interfere with MMBasic background functions such as reading keyboard
' Higher Zoom factor will take some time to render
' File fern.bas written 12-09-2020 13:37:05
CSUB Fern
  00000000
  4FF0E92D 46924C7E 68244B7E 8000F8D0 681B6822 0F00F1B8 0252EA4F 5000F8DA
  ED2D681B B0838B10 AB00ED91 F3409201 EE07809E 085B2A90 EB00EEB7 EEB846A9
  EE07CBE7 46AB3A90 EEB8462F 26009BE7 8B4EEEB0 BB4AED9F 6B4BED9F FB4CED9F
  BB0BEE2A AB06EE2A DB4BED9F ED9FE033 ED9F5B4C ED9F4B4D EE2E6B4E EE2E5B05
  EEA87B04 EEA85B04 EEB07B06 EEB06B4C EEAB8B45 ED9F6B05 EE37EB48 EEFDEB0E
  EE177BC6 EEB10A90 4B576B04 7B49EEB0 681B3601 42C8F44F 6B4EEE36 EEA6464D
  EEFD7B0A EE177BC7 47981A90 D04F45B0 46BB46D9 F3C64627 B913030A 681B4B4B
  EA854798 4B4A25C5 44D7EA85 EA84407C 429C2415 4B47D2BB 44234A47 D81C4293
  6B4CEEB0 5B2EED9F 4B2FED9F 7B30ED9F 5B05EE2E 7B07EE2E 5B04EEA8 7B0DEEA8
  EB2DED9F 6B05EEAB 8B45EEB0 EB0EEE37 6BC6EEFD 0A90EE16 4B38E7B5 44234A38
  D80C4293 5B4EEE2D 6B25ED9F 7B26ED9F 5B06EEA8 7B07EE2E 6B25ED9F ED9FE793
  EEB07B26 98018B4F EB07EE2E 462CE79B 4000F8CA ECBDB003 E8BD8B10 BF008FF0
  00000000 40590000 00000000 40490000 00000000 00000000 0A3D70A4 3FD0A3D7
  47AE147B 3FA47AE1 33333333 3FEB3333 47AE147B BFA47AE1 9999999A 3FF99999
  1EB851EC 3FD1EB85 33333333 BFC33333 EB851EB8 3FCEB851 C28F5C29 3FDC28F5
  9999999A 3FC99999 C28F5C29 3FCC28F5 D70A3D71 3FCD70A3 47AE147B 3FC47AE1
  080002EC 080002F0 08000338 0800033C 26666666 EB851EB8 11EB851D FD70A3D7
  11EB851E
End CSUB
