'Barnsley's Fern

Mode 1,8

CLS

G = RGB(0,100,0)

For i = 1 to 1000000

 Select Case Rnd()
   Case IS < .01
     NextX = 0
     NextY = 0.16 * Y
   Case .01 TO .08
     NextX = .2 * X - .26 * Y
     NextY = .23 * X + .22 * Y + 1.6
   Case .08 TO .15
     NextX = -.15 * X + .28 * Y
     NextY = .26 * X + .24 * Y + .44
   Case Else
     NextX = .85 * X + .04 * Y
     NextY = -.04 * X + .85 * Y + 1.6
 End Select

 X = NextX
 Y = NextY

 Pixel X * 100 + 400,600 - Y * 55 ,G

Next i
