cls

start:
'randomize some y values for the chars
  y=int(rnd(1)*800)
 y2=int(rnd(1)*800)
 y3=int(rnd(1)*800)
 y4=int(rnd(1)*800)
 y5=int(rnd(1)*800)
 y6=int(rnd(1)*800)
 y7=int(rnd(1)*800)
 y8=int(rnd(1)*800)
 y9=int(rnd(1)*800)
y10=int(rnd(1)*800)
y11=int(rnd(1)*800)
y12=int(rnd(1)*800)
y13=int(rnd(1)*800)
y14=int(rnd(1)*800)
y15=int(rnd(1)*800)
y16=int(rnd(1)*800)
y17=int(rnd(1)*800)
y18=int(rnd(1)*800)
y19=int(rnd(1)*800)
y20=int(rnd(1)*800)

for x=1 to 560 step 8
color rgb(0,255,40)
'randomize chars from 32-255

r1=int(rnd(1)*255-32)+32
r2=int(rnd(1)*255-32)+32
r3=int(rnd(1)*255-32)+32
r4=int(rnd(1)*255-32)+32
r5=int(rnd(1)*255-32)+32
r6=int(rnd(1)*255-32)+32
r7=int(rnd(1)*255-32)+32
r8=int(rnd(1)*255-32)+32
r9=int(rnd(1)*255-32)+32

'write the chars
if x>230 then color rgb(0,((-1*x)/570*255)+255+20,40)
if x<230 then color rgb(0,255,0)
?@(y,x);chr$(r1)
?@(y2,x*0.5);chr$(r1)
?@(y3,x*0.7);chr$(r2)
?@(y4,x*0.6);chr$(r3)
?@(y5,x*0.9);chr$(r4)
?@(y6,x);chr$(r5)
?@(y7,x*0.5);chr$(r6)
?@(y8,x*0.7);chr$(r7)
?@(y9,x*0.6);chr$(r8)
?@(y10,x*0.9);chr$(r9)

'erase the chars
color rgb (0,0,0)
?@(y11,x*0.5);"_"
?@(y12,x*0.7);"-"
?@(y13,x);"_"
?@(y14,x*0.9);"_-_"
?@(y15,x*0.5);"-_-_"
?@(y16,x*0.7);chr$(r6)
?@(y17,x*0.6);chr$(r7)
?@(y18,x*0.9);chr$(r8)
?@(y19,x);chr$(r9)
?@(y20,x);chr$(r1)

?@(y11,x);"---"
?@(y12,x);"---"
?@(y13,x);"----"
?@(y14,x);"---"
?@(y15,x*0.7);"----"
?@(y16,x);"---"
?@(y17,x*0.2);"-_-_-"
?@(y18,x);"---"
?@(y19,x*0.8);"-_-_-"
?@(y20,x);"-_-_-"

next x
taste:
ta$=inkey$
if ta$=" " then end
goto start

