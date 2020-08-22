' Author: Peter Mather

option explicit
option default none

#Include "../common/welcome.inc"

mode 2
page write 1
const edgelength=100 'set the length of the verticies of the ticosahedron
const zlocation=1000 'how far is the center of the ticosahedron away from us
const viewplane=800 'how far is the viewplane away from us
dim float x,y,d
dim float phi=(1+sqr(5))/2
dim float x1,y1,z1
dim integer col(11), sortorder(11)
dim float q1(4),depth(11),v(4), vout(4)
' data for location of verticies for ticosahedron of edge length 2
data 0,1,3*phi
data 0,1,-3*phi
data 0,-1,3*phi
data 0,-1,-3*phi
data 1,3*phi,0
data 1,-3*phi,0
data -1,3*phi,0
data -1,-3*phi,0
data 3*phi,0,1
data 3*phi,0,-1
data -3*phi,0,1
data -3*phi,0,-1
data 2,(1+2*phi),phi
data 2,(1+2*phi),-phi
data 2,-(1+2*phi),phi
data 2,-(1+2*phi),-phi
data -2,(1+2*phi),phi
data -2,(1+2*phi),-phi
data -2,-(1+2*phi),phi
data -2,-(1+2*phi),-phi
data (1+2*phi),phi,2
data (1+2*phi),phi,-2
data (1+2*phi),-phi,2
data (1+2*phi),-phi,-2
data -(1+2*phi),phi,2
data -(1+2*phi),phi,-2
data -(1+2*phi),-phi,2
data -(1+2*phi),-phi,-2
data phi,2,(1+2*phi)
data phi,2,-(1+2*phi)
data phi,-2,(1+2*phi)
data phi,-2,-(1+2*phi)
data -phi,2,(1+2*phi)
data -phi,2,-(1+2*phi)
data -phi,-2,(1+2*phi)
data -phi,-2,-(1+2*phi)
data 1,(2+phi),2*phi
data 1,(2+phi),-2*phi
data 1,-(2+phi),2*phi
data 1,-(2+phi),-2*phi
data -1,(2+phi),2*phi
data -1,(2+phi),-2*phi
data -1,-(2+phi),2*phi
data -1,-(2+phi),-2*phi
data (2+phi),2*phi,1
data (2+phi),2*phi,-1
data (2+phi),-2*phi,1
data (2+phi),-2*phi,-1
data -(2+phi),2*phi,1
data -(2+phi),2*phi,-1
data -(2+phi),-2*phi,1
data -(2+phi),-2*phi,-1
data 2*phi,1,(2+phi)
data 2*phi,1,-(2+phi)
data 2*phi,-1,(2+phi)
data 2*phi,-1,-(2+phi)
data -2*phi,1,(2+phi)
data -2*phi,1,-(2+phi)
data -2*phi,-1,(2+phi)
data -2*phi,-1,-(2+phi)
' 12 faces with 5 sides
data 0,28,36,40,32
data 1,29,37,41,33
data 2,30,38,42,34
data 3,31,39,43,35
data 4,12,44,45,13
data 5,14,46,47,15
data 6,16,48,49,17
data 7,18,50,51,19
data 8,20,52,54,22
data 9,21,53,55,23
data 10,24,56,58,26
data 11,27,59,57,25
' 20 faces with 6 sides
data 0,2,34,58,56,32
data 0,2,30,54,52,28
data 1,3,31,55,53,29
data 1,3,35,59,57,33
data 4,6,17,41,37,13
data 4,6,16,40,36,12
data 5,7,19,43,39,15
data 5,7,18,42,38,14
data 8,9,23,47,46,22
data 8,9,21,45,44,20
data 10,11,27,51,50,26
data 10,11,25,49,48,24
data 12,44,20,52,28,36
data 13,45,21,53,29,37
data 14,46,22,54,30,38
data 15,47,23,55,31,39
data 16,48,24,56,32,40
data 17,49,25,57,33,41
data 18,50,26,58,34,42
data 19,51,27,59,35,43
'
dim float zpos(31),zsort(31)
dim float ticos(2,59), nticos(3,59)
dim integer i,j,k,l,m,n
dim integer xs(179),ys(179),xe(179),ye(179)
dim integer index(31),nnum(31)
' read in the coordinates of the verticies and scale
for j=0 to 59
 for i=0 to 2
   read ticos(i,j)
   ticos(i,j)=ticos(i,j)*edgelength/2
 next i
next j
'
dim integer xarr(179),yarr(179)
dim integer nv(31)=(5,5,5,5,5,5,5,5,5,5,5,5,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6)
dim integer np(31)=(0,1,2,3,4,5,6,7,8,9,10,11,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19)
dim integer nd(31)
dim integer f5(4,11), f6(5,19)
dim integer ncol(31)
for j=0 to 11
 for i=0 to 4
   read f5(i,j)
 next i
next j
for j=0 to 19
 for i=0 to 5
   read f6(i,j)
 next i
next j

'convert coordinates to normalised form
for i=0 to 59
 x1=ticos(0,i): y1=ticos(1,i): z1=ticos(2,i)
 create_vector(x1,y1,z1,v())
 nticos(0,i)=v(2): nticos(1,i)=v(3): nticos(2,i)=v(4): nticos(3,i)=v(0)
next i

'create a quarternion to rotate 4 degrees about a chosen axis
'play with the x,y,z vector which is the sxis of rotation
create_normalised_quaternion(4,1,0.5,0.25,q1())

' Clear the_keyboard_buffer.
we.clear_keyboard_buffer()

do
  cls
  Text 10, 0, "Rotating Football", "", 2
  Text 12, 25, "Press Q to Quit", "", 1

  for i=0 to 59 'rotate coordinates
    v(2)=nticos(0,i): v(3)=nticos(1,i): v(4)=nticos(2,i): v(0)=nticos(3,i): v(1)=0
    rotate_vector(vout(),v(),q1())
    nticos(0,i)=vout(2): nticos(1,i)=vout(3): nticos(2,i)=vout(4): nticos(3,i)=vout(0)
  next i

  ' average the z positions for the five sided faces
  for k=0 to 11
    zpos(k)=0
    for i=0 to 4
      zpos(k)=zpos(k)+nticos(2,f5(i,k))
    next i
    zpos(k)=zpos(k)/5
    ' index(k)=k
  next k

  'average the z positions for the 6 sided faces
  for k=12 to 31
    zpos(k)=0
    for i=0 to 5
      zpos(k)=zpos(k)+nticos(2,f6(i,k-12))
    next i
    zpos(k)=zpos(k)/6
    ' index(k)=k
  next k

  ' sort the z positions
  sort zpos(),index()

  j=0:m=0
  for l=0 to 31
    k=index(l)
    m=np(k)
    nd(l)=nv(k)
    if nv(k)=5 then
      ncol(l)=rgb(red)
    else
      ncol(l)=rgb(white)
    endif
    for i=0 to nv(k)-1
      if nv(k)=5 then
        xarr(j)=nticos(0,f5(i,m))*viewplane/(nticos(2,f5(i,m))+zlocation)*nticos(3,f5(i,m))+MM.HRES/2
        yarr(j)=nticos(1,f5(i,m))*viewplane/(nticos(2,f5(i,m))+zlocation)*nticos(3,f5(i,m))+MM.VRES/2
      else
        xarr(j)=nticos(0,f6(i,m))*viewplane/(nticos(2,f6(i,m))+zlocation)*nticos(3,f6(i,m))+MM.HRES/2
        yarr(j)=nticos(1,f6(i,m))*viewplane/(nticos(2,f6(i,m))+zlocation)*nticos(3,f6(i,m))+MM.VRES/2
      endif
      j=j+1
    next i
  next l
  polygon nd(),xarr(),yarr(),rgb(black),ncol()

  page copy 1 to 0

Loop While Not we.is_quit_pressed%()

we.end_program()

sub create_normalised_quaternion(theta as float,x as float,y as float,z as float,q() as float)
 local float radians = theta/180.0*PI
 local float sineterm= sin(radians!/2)
 q(1)=cos(radians/2)
 q(2)=x* sineterm
 q(3)=y* sineterm
 q(4)=z* sineterm
 q(0)=sqr(q!(1)*q(1) + q(2)*q(2) + q(3)*q(3) + q(4)*q(4)) 'calculate the magnitude
 q(1)=q(1)/q(0) 'create a normalised quaternion
 q(2)=q(2)/q(0)
 q(3)=q(3)/q(0)
 q(4)=q(4)/q(0)
 q(0)=1
end sub
'
sub invert_quaternion(n() as float,q() as float)
 n(0)=q(0)
 n(1)=q(1)
 n(2)=-q(2)
 n(3)=-q(3)
 n(4)=-q(4)
end sub
'
sub multiply_quaternion(n() as float,q1() as float,q2() as float)
 local float a1=q1(1),a2=q2(1),b1=q1(2),b2=q2(2),c1=q1(3),c2=q2(3),d1=q1(4),d2=q2(4)
 n(1)=a1*a2-b1*b2-c1*c2-d1*d2
 n(2)=a1*b2+b1*a2+c1*d2-d1*c2
 n(3)=a1*c2-b1*d2+c1*a2+d1*b2
 n(4)=a1*d2+b1*c2-c1*b2+d1*a2
 n(0)=q1(0)*q2(0)
end sub
'
sub create_vector(x as float,y as float ,z as float,v() as float)
 v(0)=sqr(x*x + y*y + z*z)
 v(1)=0
 v(2)=x/v(0)
 v(3)=y/v(0)
 v(4)=z/v(0)
end sub

sub rotate_vector(vnew() as float,v() as float,q() as float)
 local float n(4),iq(4)
 multiply_quaternion(n(),q(),v())
 invert_quaternion(iq(),q())
 multiply_quaternion(vnew(),n(),iq())
end sub
