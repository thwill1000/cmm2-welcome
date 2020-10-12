 cls
mode 1,16
color rgb (40,255,20)
?" Hi ! This is my small Polysynth V1"
?" "
?" You can play the synth with your keyboard:"
?" Just imagine the Keys from Q-P as White Keys and the numberkeys above as Black keys of a Piano"
?" "
?"  2  3        5  6  7     9  0     <----- Black Keys"
?" "
?" Q  W  E  R  T  Z  U  I  O  P      <----- White Keys"
?" "
?" The Synth can play up to 4 Notes simultaneously. All sounds come from both Speakers."
?" "
?" You can change the okaves on the 4 Notes independently:"
?"
?" F1 / F2  Oktave up / down on Note 1"
?" F3 / F4  Oktave up / down on Note 2"
?" F5 / F6  Oktave up / down on Note 3
?" F7 / F8  Oktave up / down on Note 4
?" "
?" "
?" F9 / F10 Oktave up / down on ALL 4 Notes"
?" "
?" F11  Reset All oktaves to Zero   "
?" F12  Reset Tuning to Zero     "
?" "
?" Change the Sound on the Channel:
?" "
?" A / S / D / F  -  Sound change + on Channel 1 / 2 / 3 / 4 (Sqare or Sine)"
?" Y / X / C / V  -  Sound change - on Channel 1 / 2 / 3 / 4 (Sqare or Sine)"
?" "
?" Detune Channels with:
?" "
?" G / H / J / K  -  Detune + on Note 1 / 2 / 3 / 4"
?" B / N / M / ,  -  Detune - on Note 1 / 2 / 3 / 4"
?" "
?" "
?" The Keyboardlayout is set for a german Keyboard. (DE)"
?" If you want to switch to US Layout where Z is on the Y position you have to Press ESC to change"



tastestart:
tb1$=chr$(keydown(1))
if keydown(1)=0 then goto tastestart



cls



fc=1: bc=9 : rem Color 1-15
volume=12 : rem Volume 1-25


dim tnr(10)

tnr(1)=28: 'for if okt would be pressed before a key we set the key to C2
tnr(2)=28: 'for if okt would be pressed before a key we set the key to C2
tnr(3)=28: 'for if okt would be pressed before a key we set the key to C2
tnr(4)=28: 'for if okt would be pressed before a key we set the key to C2


toggle=0 :yz1$="z":yz2$="y": layout$="DE" ' - German Layout


Flag=0:
s=1: rem sound 1=square 2=sine 3= noise
okt=0 : rem oktave to zero

dim freq(88),freq1(88),freq2(88),freq3(88),freq4(88),ta$(88):



freq(01)=27.5000 : freq(11)=48.9995 : freq(21)=87.3071 : freq(31)=155.563
freq(02)=29.1353 : freq(12)=51.9130 : freq(22)=92.4986 : freq(32)=164.814
freq(03)=30.8677 : freq(13)=55.0000 : freq(23)=97.9989 : freq(33)=174.614
freq(04)=32.7032 : freq(14)=58.2705 : freq(24)=103.826 : freq(34)=184.997
freq(05)=34.6479 : freq(15)=61.7354 : freq(25)=110.000 : freq(35)=195.998
freq(06)=36.7081 : freq(16)=65.4064 : freq(26)=116.541 : freq(36)=207.652
freq(07)=38.8909 : freq(17)=69.2957 : freq(27)=123.471 : freq(37)=220.000
freq(08)=41.2035 : freq(18)=73.4162 : freq(28)=130.813 : freq(38)=233.082
freq(09)=43.6536 : freq(19)=77.7817 : freq(29)=138.591 : freq(39)=246.942
freq(10)=46.2493 : freq(20)=82.4069 : freq(30)=146.832 : freq(40)=261.626

freq(41)=277.183 : freq(51)=493.883 : freq(61)=880.000 : freq(71)=1567.98
freq(42)=293.665 : freq(52)=523.251 : freq(62)=932.328 : freq(72)=1661.22
freq(43)=311.127 : freq(53)=554.365 : freq(63)=987.767 : freq(73)=1760.00
freq(44)=329.628 : freq(54)=587.330 : freq(64)=1046.50 : freq(74)=1864.66
freq(45)=349.228 : freq(55)=622.254 : freq(65)=1108.73 : freq(75)=1975.53
freq(46)=369.994 : freq(56)=659.255 : freq(66)=1174.66 : freq(76)=2093.00
freq(47)=391.995 : freq(57)=698.456 : freq(67)=1244.51 : freq(77)=2217.46
freq(48)=415.305 : freq(58)=739.989 : freq(68)=1318.51 : freq(78)=2349.32
freq(49)=440.000 : freq(59)=783.991 : freq(69)=1396.91 : freq(79)=2489.02
freq(50)=466.164 : freq(60)=830.609 : freq(70)=1479.98 : freq(80)=2637.02

freq(81)=2793.83
freq(82)=2959.96
freq(83)=3135.96
freq(84)=3322.44
freq(85)=3520.00
freq(86)=3729.31
freq(87)=3951.07
freq(88)=4186.01

'Fill frequency table for all 4 channels
for x = 1 to 88
freq1(x)=freq(x):freq2(x)=freq(x):freq3(x)=freq(x):freq4(x)=freq(x)
next

ta$(28)="q"
ta$(29)="2"
ta$(30)="w"
ta$(31)="3"
ta$(32)="e"
ta$(33)="r"
ta$(34)="5"
ta$(35)="t"
ta$(36)="6"
ta$(37)="z"
ta$(38)="7"
ta$(39)="u"
ta$(40)="i"
ta$(41)="9"
ta$(42)="o"
ta$(43)="0"
ta$(44)="p"

'set sounds to same on all 4 channels
freq1(tnr(1))=freq(28)
freq2(tnr(2))=freq(28)
freq3(tnr(3))=freq(28)
freq4(tnr(4))=freq(28)


askKeyboard:

k1=keydown(1)
k2=keydown(2)
k3=keydown(3)
k4=keydown(4)
keys=keydown(0)


font 2:
Screenstart:


    ' For Checking the Keys coming in...
    '         Print @(10,40)"Taste:";k1;"   ";k2;"   ";k3;"   ";k4;"   ";keys;"  "


    '         Print @(10,80)"Buffer:";buffer$;"  "
              Print @(10,100)"Keydown:";keydown(0);" "
              Print @(10,120)"Frequency:"
              print @(130,120)"";freq(tnr(1))
              print @(250,120)"";freq(tnr(2))
              Print @(370,120)"";freq(tnr(3))
              Print @(490,120)"";freq(tnr(4))



              print @(10,240)"Sound:";s1;s2;s3;s4;"   "
              print @(10,160)"Tuning:";tune1;" ";tune2;" ";tune3;" ";tune4;"               ":
              print @(10,180)"Oktave:";okt1;okt2;okt3;okt4;"              ":
              print @(10,200)"keynr:";fullkey1;fullkey2;fullkey3;fullkey4;"         "
              print @(10,220)"Layout:";layout$
     font 1
              print @(10,320)"More music at http://tweakerray.bandcamp,com"
              print @(10,340)"And follow at http://www.youtube.com/tweakerray"
     font 2



Checktaste:
r1=rnd(1)*255:g1=rnd(1)*255:b1=rnd(1)*255
color rgb(r1,g1,b1): ?@(12,1)"* * * * * * * * * Mr. Polysynth by TweakerRay * * * * * * * * *":
color rgb(0,255,0)

if keydown(0)=0 then play stop: goto Checktaste

for i=1 to keydown(0)
tpress$=chr$(keydown(i))

if toggle=0 and tpress$=chr$(27) then toggle=1:tpress$="":Layout$="US": changelayout:pause 50:goto screenstart
if toggle=1 and tpress$=chr$(27) then toggle=0:tpress$="":Layout$="DE": changelayout:pause 50:goto screenstart

if tpress$="q" then tnr(i)=28
if tpress$="2" then tnr(i)=29
if tpress$="w" then tnr(i)=30
if tpress$="3" then tnr(i)=31
if tpress$="e" then tnr(i)=32
if tpress$="r" then tnr(i)=33
if tpress$="5" then tnr(i)=34
if tpress$="t" then tnr(i)=35
if tpress$="6" then tnr(i)=36
if tpress$=yz1$ then tnr(i)=37
if tpress$="7" then tnr(i)=38
if tpress$="u" then tnr(i)=39
if tpress$="i" then tnr(i)=40
if tpress$="9" then tnr(i)=41
if tpress$="o" then tnr(i)=42
if tpress$="0" then tnr(i)=43
if tpress$="p" then tnr(i)=44
' Channel Oktave up and down

if tpress$=chr$(145) then okt1=okt1-12:keys=keys-1:pause 50
if tpress$=chr$(146) then okt1=okt1+12:keys=keys-1:pause 50
if tpress$=chr$(147) then okt2=okt2-12:keys=keys-1:pause 50
if tpress$=chr$(148) then okt2=okt2+12:keys=keys-1:pause 50
if tpress$=chr$(149) then okt3=okt3-12:keys=keys-1:pause 50
if tpress$=chr$(150) then okt3=okt3+12:keys=keys-1:pause 50
if tpress$=chr$(151) then okt4=okt4-12:keys=keys-1:pause 50
if tpress$=chr$(152) then okt4=okt4+12:keys=keys-1:pause 50

' All four Channels Oktave up and down
if tpress$=chr$(154) then okt1=okt1+12:okt2=okt2+12:okt3=okt3+12:okt4=okt4+12:keys=keys-1:pause 50
if tpress$=chr$(153) then okt1=okt1-12:okt2=okt2-12:okt3=okt3-12:okt4=okt4-12:keys=keys-1:pause 50
'Reset Tuning + Reset Oktaves
if tpress$=chr$(155) then okt1=0:okt2=0:okt3=0:okt4=0:keys=keys-1:pause 50
if tpress$=chr$(156) then tune1=0:tune2=0:tune3=0:tune4=0:keys=keys-1:pause 50



'restrictioms (Check if Oktave Values get too high or low)
if okt1>48 then okt1=48:
if okt2>48 then okt2=48:
if okt3>48 then okt3=48:
if okt4>48 then okt4=48:
if okt1<-24 then okt1=-24:
if okt2<-24 then okt2=-24:
if okt3<-24 then okt3=-24:
if okt4<-24 then okt4=-24:

if tpress$="a" then s1=s1+1:keys=keys-1:pause 50'Soundchange on sound 1
if tpress$=yz2$ then s1=s1-1:keys=keys-1:pause 50'Soundchange on sound 1
if tpress$="s" then s2=s2+1:keys=keys-1:pause 50'Soundchange on sound 2
if tpress$="x" then s2=s2-1:keys=keys-1:pause 50'Soundchange on sound 2
if tpress$="d" then s3=s3+1:keys=keys-1:pause 50'Soundchange on sound 3
if tpress$="c" then s3=s3-1:keys=keys-1:pause 50'Soundchange on sound 3
if tpress$="f" then s4=s4+1:keys=keys-1:pause 50'Soundchange on sound 4
if tpress$="v" then s4=s4-1:keys=keys-1:pause 50'Soundchange on sound 4
if tpress$="g" then tune1=tune1+0.1:keys=keys-1:Pause 50
if tpress$="b" then tune1=tune1-0.1:keys=keys-1:Pause 50
if tpress$="h" then tune2=tune2+0.1:keys=keys-1:Pause 50
if tpress$="n" then tune2=tune2-0.1:keys=keys-1:Pause 50
if tpress$="j" then tune3=tune3+0.1:keys=keys-1:Pause 50
if tpress$="m" then tune3=tune3-0.1:keys=keys-1:Pause 50
if tpress$="k" then tune4=tune4+0.1:keys=keys-1:Pause 50
if tpress$="," then tune4=tune4-0.1:keys=keys-1:Pause 50

'check values to high or low for soundchange
'you could go bigger as 2 to set it to 4 but 1 and 2 are only usefull.
'3 and 4 would be noise
if s1<1 then s1=1
if s1>2 then s1=2
if s2<1 then s2=1
if s2>2 then s2=2
if s3<1 then s3=1
if s3>2 then s3=2
if s4<1 then s4=1
if s4>2 then s4=2

'Checking restrictions of frequency (Not below 20 Hz or over 20 Khz)

'check if keyvalue too high or low
fullkey1=tnr(1)+okt1:fullkey2=tnr(2)+okt2:fullkey3=tnr(3)+okt3:fullkey4=tnr(4)+okt4:


if okt1=48 and tnr(1)>40 then tnr(1)=40
if okt2=48 and tnr(2)>40 then tnr(2)=40
if okt3=48 and tnr(3)>40 then tnr(3)=40
if okt4=48 and tnr(4)>40 then tnr(4)=40


'Check if the same key is pressed, which means the sound is already playing
'if buffer$=tpress$ then samesound=1 else samesound=0

'buffer$=tpress$

switch=0
for x=28 to 44
if tpress$=ta$(x) then switch=1
next x

next i

if switch=0 goto Screenstart



Soundausgabe:





 If s1=1 and keys>0 then Play Sound 1,B,Q,freq1(tnr(1)+okt1)+tune1,volume
 if s1=2 and Keys>0 then play Sound 1,B,S,freq1(tnr(1)+okt1)+tune1,volume
' if s1=3 and Keys>0 then play sound 1,B,N,freq1(tnr(1)+okt1)+tune1,volume
' if s1=4 and keys>0 then play sound 1,B,P,freq1(tnr(1)+okt1)+tune1,volume

 If s2=1 and keys>1 then Play Sound 2,B,Q,freq2(tnr(2)+okt2)+tune2,volume
 if s2=2 and keys>1 then play Sound 2,B,S,freq2(tnr(2)+okt2)+tune2,volume
' if s2=3 and keys>1 then play sound 2,B,N,freq2(tnr(2)+okt2)+tune2,volume
' if s2=4 and keys>1 then play sound 2,B,P,freq2(tnr(2)+okt2)+tune2,volume

 If s3=1 and keys>2 then Play Sound 3,B,Q,freq3(tnr(3)+okt3)+tune3,volume
 if s3=2 and keys>2 then play Sound 3,B,S,freq3(tnr(3)+okt3)+tune3,volume
' if s3=3 and keys>2 then play sound 3,B,N,freq3(tnr(3)+okt3)+tune3,volume
' if s3=4 and keys>2 then play sound 4,B,P,freq3(tnr(3)+okt3)+tune3,volume

 If s4=1 and keys>3 then Play Sound 4,B,Q,freq4(tnr(4)+okt4)+tune4,volume
 if s4=2 and keys>3 then play Sound 4,B,S,freq4(tnr(4)+okt4)+tune4,volume
' if s4=3 and keys>3 then play sound 4,B,N,freq4(tnr(4)+okt4)+tune4,volume
' if s4=4 and keys>3 then play sound 4,B,P,freq4(tnr(4)+okt4)+tune4,volume

goto Askkeyboard



sub changelayout
if toggle=0 then yz1$="z":yz2$="y": Layout$="DE" ' - German Layout
if toggle=1 then yz1$="y":yz2$="z": Layout$="US" ' - German Layout
End Sub






