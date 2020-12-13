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

we.check_firmware_version("5.06.00")

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
CSUB Fern
  00000000
  4FF8E92D 46904C80 68074B80 681B6824 68222F00 F8D8681B ED2D5000 ED918B10
  F3409B00 085280A9 EB00EEB7 46AB085B 2A90EE07 EEB046A9 46AA8B4E ABE7EEB8
  3A90EE07 EEB82600 ED9FBBE7 ED9FDB4F ED9FCB50 E03BFB51 7B51ED9F 4B52ED9F
  5B53ED9F 7B07EE2E 6B04EE2E 7B04EEA8 6B05EEA8 4B50ED9F EB51ED9F 8B47EEB0
  7B04EE27 EB0EEE36 4B4AEEB0 EEB14B60 36015B04 F44F681B EEA942C8 465D4B07
  5B45EE3E 7B48ED9F 7B45EE27 6BC4EEFD 0A90EE16 6B4BEEB0 6B09EEA7 7BC6EEFD
  1A90EE17 42B74798 46CBD057 46A246D1 030AF3C6 4B4FB913 4798681B 25C5EA85
  EA854B4D EA8444DA EA84040A 429C2415 4B4AD2B2 44234A4A D8184293 7B34ED9F
  6B35ED9F 5B36ED9F 7B07EE2E 6B06EE2E 7B05EEA8 6B0CEEA8 4B27ED9F EB32ED9F
  8B47EEB0 7B04EE27 EB0EEE36 4B3DE7AC 44234A3D D8164293 7B4EEE2C 6B2CED9F
  4B2DED9F 7B0FEEA8 6B06EE2E EB1CED9F 6B04EEA8 8B47EEB0 4B17ED9F 7B04EE27
  EB0EEE36 ED9FE790 EEB07B26 EE2E8B4D EEB0EB07 E7877B4D F8C8462C ECBD4000
  E8BD8B10 BF008FF8 00000000 00000000 0A3D70A4 3FD0A3D7 9999999A 3FC99999
  47AE147B 3FA47AE1 33333333 3FEB3333 47AE147B BFA47AE1 00000000 40590000
  9999999A 3FF99999 00000000 40490000 1EB851EC 3FD1EB85 EB851EB8 3FCEB851
  33333333 BFC33333 C28F5C29 3FDC28F5 C28F5C29 3FCC28F5 D70A3D71 3FCD70A3
  47AE147B 3FC47AE1 080002EC 080002F0 08000338 0800033C 26666666 EB851EB8
  11EB851D FD70A3D7 11EB851E
End CSUB
