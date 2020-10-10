' Author: "capsikin"

#Include "../../common/welcome.inc"

we.clear_keyboard_buffer()

'DIM BG=RGB(blue)
DIM BG=RGB(black)
DIM FG=RGB(white)

DIM titlecolour=RGB(green)

DIM parametercolour=RGB(Cyan)

DIM controlhighlight=RGB(magenta)

MODE 2,8,BG
'MODE 1,8,BG
'MODE 3,8,BG
'COLOUR FG,BG

sub normalvideo
  colour fg,bg
end sub

sub inversevideo
  colour bg,fg
end sub

'May need padding if the layout is too small for the mode
DIM toppadding=2
DIM leftpadding=12
DIM padspace$=space$(leftpadding)

sub pad
  print padspace$;
end sub

sub toppad
  local n
  for n=1 to toppadding
    print
  next n
end sub

dim steps=6
dim f1=1000
dim f2=2000
dim v1=25
dim v2=10
dim steptime=20
dim ft=2
dim rfn=1

dim sets=5
dim f3=f1*0.5

dim i,j

dim param_count=10
dim params(param_count)
dim pname$(param_count)
dim pdescription$(param_count)

dim pd(param_count)
'if the parameter goes up and down in steps bigger than one.

dim max_freq=20000
dim min_freq=1
dim max_param=max_freq

dim max_vol=25
dim min_vol=1

pname$(1)="steps"
pname$(2)="f1"
pname$(3)="f2"
pname$(4)="f3"
pd(2)=100
pd(3)=100
pd(4)=100
pname$(5)="v1"
pname$(6)="v2"
pname$(7)="steptime"
pname$(8)="ft"
pname$(9)="rfn"
pname$(10)="sets"

pdescription$(1)  = "How many steps            (steps)"
pdescription$(2)  = "Start frequency              (f1)"
pdescription$(3)  = "End frequency of first set   (f2)"
pdescription$(4)  = "Start frequency of last set  (f3)"
pdescription$(5)  = "Start volume                 (v1)"
pdescription$(6)  = "End volume                   (v2)"
pdescription$(7)  = "ms per step            (stepTime)"
pdescription$(8)  = "f change type (1=L/2=E/3=LW) (ft)"
pdescription$(9)  = "Round frequency (Y=1/N=0)   (rfn)"
pdescription$(10) = "Number of sets             (sets)"

'pdescription$(8)  = "freq change type - 1 - linear. 2 - exponential. 3 - linear wavelength - ft"
'pdescription$(9)  = "round frequency to avoid partial wavelengths (Y=1/N=other) - rfn"

params(1)=steps
params(2)=f1
params(3)=f2
params(4)=f3
params(5)=v1
params(6)=v2
params(7)=steptime
params(8)=ft
params(9)=rfn
params(10)=sets

sub setparam

 steps=params(1)
 f1=params(2)
 f2=params(3)
 f3=params(4)
 v1=params(5)
 v2=params(6)
 steptime=params(7)
 ft=params(8)
 rfn=params(9)
 sets=params(10)

end sub

sub printcontrol(s$)
  colour controlhighlight : Print s$; : normalvideo
end sub

sub printinfo
  Colour RGB(Green)

  Pad : Print "                 Chirps!"
  Colour FG
  Print
  Pad : Print " Controls: ";

  printcontrol     "Up"
  print              ", ";
  printcontrol         "Down"
  print                    ". ";
  printcontrol               "Left"
  print                          ", ";
  printcontrol                     "Right"
  print                                 " or ";
  printcontrol("+") : print ", ";
  printcontrol("-") : print ".";
  Print

  Pad : Print " Press ";

  printcontrol "Space"
  print             " to play the sounds, ";
  printcontrol                           "Q"
  print                                   " to quit"
  print

  Pad : Print " Parameter ft, frequency change type:"
  Pad : Print "   1 - linear change of frequency."
  Pad : Print "   2 - exponential."
  Pad : Print "   3 - linear change of wave period."
  Pad : Print " Parameter rfn, round f to avoid partial waves."
  Pad : Print " Frequencies from 1-20000. Volumes from 1-25."
  Pad : Print " Suggestions: Try f2 higher, lower, or equal to f1."

end sub

sub printparams

  for i=1 to param_count
    colour parametercolour
    Pad
    if i=p_index then inversevideo
    Print " ";pdescription$(i); TAB(37+leftpadding);" =";params(i);" "
    normalvideo
  next
end sub

sub printsounds vs(), fss()
  page write 0
  print "vs():  ";
  for i=1 to steps
    print vs(i);"  "; 
  next
  print
  print "fss(): ";
  for j=1 to sets
    for i=1 to steps
      print fss(j,i);"  ";
    next
  next
  print
end sub

p_index=1

do
  do
    page write 1
    'CLS BG
    CLS

    toppad

    Print
    printinfo
    print
    printparams
    page copy 1 to 0

    do
      k$=inkey$
      ka=asc(k$)
    loop until k$ <> ""
    if pd(p_index)=0 then pd(p_index)=1
    if ka=129 then ' down
      p_index=MIN(param_count,p_index+1)
    else if ka=128 then 'up
      p_index=MAX(1,p_index-1)
    else if k$="+" or ka=131 then '+ or right
      params(p_index) = MIN(max_param,params(p_index) + pd(p_index))
      setparam
    else if k$="-" or ka=130 then '- or left
      params(p_index) = MAX(0,params(p_index) - pd(p_index))
      setparam
    end if

    if we.is_quit_key%(k$) then we.end_program()

  loop until k$=" "
  playsounds
loop

sub playsounds
  static transitions=steps-1

  steps=MAX(1,steps)
  sets=MAX(1,sets)

  local fs(steps)
  local vs(steps)
  local f_comp(steps)

  local fss(sets,steps)
  local fss_comp(sets,steps)

  v1=MAX(1,v1)
  v2=MAX(1,v2)

  v1=MIN(max_vol,v1)
  v2=MIN(max_vol,v2)


  interpolate vs(),v1,v2,steps

  f1=MAX(1,f1)
  f2=MAX(1,f2)
  f3=MAX(1,f3)

if ft=3 then
  interpolate f_comp(),1/f1,1/f2,steps
  for i=1 to steps
    fs(i)=1/f_comp(i)
  next
else if ft=2 then
  interpolate f_comp(),LOG(f1),LOG(f2),steps
  for i=1 to steps
    fs(i)=EXP(f_comp(i))
  next
else
  interpolate fs(),f1,f2,steps
end if

  static  f_comp1
  static  f_comp2
  static  f_comp3

f1=MIN(max_freq,f1)
f2=MIN(max_freq,f2)
f3=MIN(max_freq,f3)

if ft=3 then
  f_comp1=1/f1
  f_comp2=1/f2
  f_comp3=1/f3
else if ft=2 then
  f_comp1=LOG(f1)
  f_comp2=LOG(f2)
  f_comp3=LOG(f3)
else
  f_comp1=f1
  f_comp2=f2
  f_comp3=f3
end if

'no, change with f_comp1
interpolate2 fss_comp(),f_comp1,f_comp2,f_comp3,steps,sets

for j=1 to sets
  for i=1 to steps
    if ft=3 then
      if fss_comp(j,i) < 1/max_freq then
        fss_comp(j,i) = 1/max_freq
      endif

      fss(j,i)=1/fss_comp(j,i)

    else if ft=2 then
      fss(j,i)=EXP(fss_comp(j,i))
    else if ft=1 then
      fss(j,i)=fss_comp(j,i)
    else
      print "ft unknown";ft
    end if
    fss(j,i)=MAX(1,fss(j,i))
    fss(j,i)=MIN(max_freq,fss(j,i))
  next
next

if rfn=1 then
  for i=1 to steps
    fs(i)=fixcycles(fs(i),steptime)
  next
end if

if rfn=1 then
  for j=1 to sets
    for i=1 to steps
      fss(j,i)=fixcycles(fss(j,i),steptime)
    next
  next
end if

'for i=1 to steps
'    play sound 1,B,q,fs(i),vs(i)
'    pause steptime
'next
'play sound 1,B,O,300
'
'pause 500

'print
'printsounds vs(),fss()

for j=1 to sets
  for i=1 to steps
    play sound 1,B,q,fss(j,i),vs(i)
    pause steptime
  next
next

play sound 1,B,O,300

'print "Press a key to continue"
'do
'loop until inkey$ <> ""
end sub

end

function fixcycles(freq,t)
  'new value for freq that gives a whole number of cycles in time t.
  'integer number of cycles
  cycles% = freq * t / 1000
  if cycles% < 1 then cycles%=1
  fixcycles=cycles% * 1000 / t
end function

sub interpolate a(),val1,val2,num
  transitions=num-1
  if transitions > 0 then local dval=(val2-val1)/transitions
  for i=0 to transitions
    a(i+1)=val1+dval*i
  next
end sub

sub interpolate2 a(),val1,val2,val3,num,num2
  transitions=num-1
  transitions2=num2-1

  if transitions > 0 then local dval=(val2-val1)/transitions
  if transitions2 > 0 then local dval2=(val3-val1)/transitions2
  for j=0 to transitions2
    for i=0 to transitions
      a(j+1,i+1)=val1+dval*i+dval2*j
    next
  next
end sub
