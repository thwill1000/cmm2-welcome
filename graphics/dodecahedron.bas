' Author: Peter Mather

option explicit
option default none

#Include "../common/welcome.inc"

page write 1
const edgelength=200 'set the length of the verticies of the dodecahedron
const zlocation=1000 'how far is the center of the dodecahedron away from us
const viewplane=800 'how far is the viewplane away from us
dim float xarr(4),yarr(4)
dim float phi=(1+sqr(5))/2 ' golden ratio
dim float x,y,x1,y1,z1
dim integer col(11), sortorder(11)
dim float q1(4),depth(11),v(4), vout(4)
' data for location of verticies for dodecahedron of edge length 2
data phi,phi,phi
data phi,phi,-phi
data phi,-phi,phi
data -phi,phi,phi
data -phi,-phi,phi
data -phi,phi,-phi
data phi,-phi,-phi
data -phi,-phi,-phi
data 0,-(phi^2),1
data 0,phi^2,1
data 0,-(phi^2),-1
data 0,phi^2,-1
data phi^2,1,0
data -(phi^2),1,0
data phi^2,-1,0
data -(phi^2),-1,0
data 1,0,phi^2
data 1,0,-(phi^2)
data -1,0,phi^2
data -1,0,-(phi^2)
dim float dodec(2,19), ndodec(3,19)
dim integer i,j,k

' read in the coordinates of the verticies and scale
for j=0 to 19
 for i=0 to 2
   read dodec(i,j)
   dodec(i,j)=dodec(i,j)*edgelength/2
 next i
next j

'convert coordinates to normalised form
for i=0 to 19
 x1=dodec(0,i): y1=dodec(1,i): z1=dodec(2,i)
 create_vector(x1,y1,z1,v())
 ndodec(0,i)=v(2): ndodec(1,i)=v(3): ndodec(2,i)=v(4): ndodec(3,i)=v(0)
next i

'create a quarternion to rotate 5 degrees about a chosen axis
'play with the x,y,z vector which is the sxis of rotation
create_normalised_quaternion(5,1,0.5,0.25,q1())

'array to hold verticies for each face and its colour
dim integer faces(4,11)
data 10,6,17,19,7,rgb(red)
data 7,19,5,13,15,rgb(blue)
data 6,14,12,1,17,rgb(yellow)
data 19,17,1,11,5,rgb(green)
data 8,2,16,18,4,rgb(magenta)
data 2,14,12,0,16,rgb(cyan)
data 18,16,0,9,3,rgb(brown)
data 4,18,3,13,15,rgb(white)
data 12,0,9,11,1,rgb(gray)
data 13,3,9,11,5,rgb(255,0,128)
data 8,4,15,7,10,rgb(128,0,255)
data 8,2,14,6,10,rgb(128,255,0)
for j=0 to 11
 for i=0 to 4
   read faces(i,j)
 next i
 read col(j)
next j

we.clear_keyboard_buffer()

do
  cls
  Text 0, 0, "Rotating Dodecahedron", "", 2
  Text 2, 25, "Press Q to Quit", "", 1

  for i=0 to 19 'rotate coordinates
    v(2)=ndodec(0,i): v(3)=ndodec(1,i): v(4)=ndodec(2,i): v(0)=ndodec(3,i): v(1)=0
    rotate_vector(vout(),v(),q1())
    ndodec(0,i)=vout(2): ndodec(1,i)=vout(3): ndodec(2,i)=vout(4): ndodec(3,i)=vout(0)
  next i

  ' Now see which faces are furthest away by adding up the Z coordinates
  for i=0 to 11
    depth(i)=0
    sortorder(i)=i
    for j=0 to 4
      depth(i)=depth(i)+ndodec(2,faces(j,i))
    next j
  next i

  sort depth(),sortorder()

  for k=0 to 11
    i=sortorder(11-k) 'get the index to the faces in order of nearest last
    for j=0 to 4
      xarr(j)=ndodec(0,faces(j,i))*viewplane/(ndodec(2,faces(j,i))+zlocation)*ndodec(3,faces(j,i))+MM.HRES/2
      yarr(j)=ndodec(1,faces(j,i))*viewplane/(ndodec(2,faces(j,i))+zlocation)*ndodec(3,faces(j,i))+MM.VRES/2
    next j
    polygon 5,xarr(),yarr(),col(i),col(i)
  next k

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
