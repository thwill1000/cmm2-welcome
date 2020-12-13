' Author: Peter Mather

option explicit
option default none

#Include "../common/welcome.inc"

page write 1
const edgelength=100 'set the length of the verticies of the ticosahedron
const zlocation=1000 'how far is the center of the ticosahedron away from us
const viewplane=800 'how far is the viewplane away from us
dim float x,y,d
dim float phi=(1+sqr(5))/2
dim float x1,y1,z1
dim integer col(11), sortorder(11)
dim float q1(4),depth(11),v(4), vout(4)
' data for location of verticies for truncated icosahedron of edge length 2
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


dim float ticos(2,59), nticos(3,59)
dim integer i,j,k
dim integer xs(179),ys(179),xe(179),ye(179)
' read in the coordinates of the verticies and scale
for j=0 to 59
 for i=0 to 2
   read ticos(i,j)
   ticos(i,j)=ticos(i,j)*edgelength/2
 next i
next j

'Find coordinate pairs that are 100 pixels apart
dim integer linelist(2,59)
for i=0 to 59
 k=0
 for j=0 to 59
   d=sqr((ticos(0,j)-ticos(0,i))^2 + (ticos(1,j)-ticos(1,i))^2 + (ticos(2,j)-ticos(2,i))^2 )
   if abs(d-100)<1 then
     linelist(k,i)=j
     k=k+1
   endif
 next j
next i

'convert coordinates to normalised form
for i=0 to 59
 x1=ticos(0,i): y1=ticos(1,i): z1=ticos(2,i)
 create_vector(x1,y1,z1,v())
 nticos(0,i)=v(2): nticos(1,i)=v(3): nticos(2,i)=v(4): nticos(3,i)=v(0)
next i

'create a quarternion to rotate 2 degrees about a chosen axis
'play with the x,y,z vector which is the sxis of rotation
create_normalised_quaternion(2,1,0.5,0.25,q1())

we.clear_keyboard_buffer()

do
  cls
  Text 0, 0, "Rotating Wireframe Buckyball", "", 2
  Text 2, 25, "Press Q to Quit", "", 1

  for i=0 to 59 'rotate coordinates
    v(2)=nticos(0,i): v(3)=nticos(1,i): v(4)=nticos(2,i): v(0)=nticos(3,i): v(1)=0
    rotate_vector(vout(),v(),q1())
    nticos(0,i)=vout(2): nticos(1,i)=vout(3): nticos(2,i)=vout(4): nticos(3,i)=vout(0)
  next i

  ' for every vertex create the lines that radiate from it. This will draw every line twice
  j=0
  for k=0 to 59
    x=nticos(0,k)*viewplane/(nticos(2,k)+zlocation)*nticos(3,k)+MM.HRES/2
    y=nticos(1,k)*viewplane/(nticos(2,k)+zlocation)*nticos(3,k)+MM.VRES/2
    for i=0 to 2
      x1=nticos(0,linelist(i,k))*viewplane/(nticos(2,linelist(i,k))+zlocation)*nticos(3,linelist(i,k))+MM.HRES/2
      y1=nticos(1,linelist(i,k))*viewplane/(nticos(2,linelist(i,k))+zlocation)*nticos(3,linelist(i,k))+MM.VRES/2
      'store the coordinates for a single line command
      xs(j)=x:ys(j)=y:xe(j)=x1:ye(j)=y1:j=j+1
    next i
  next k
  line xs(),ys(),xe(),ye()

  page copy 1 to 0,b

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
