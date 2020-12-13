' Hunt the Wumpus for CMM2
' Based on the original Hunt the Wumpus game by Gregory Yob (1973)
' Rev 1.0.0 William M Leue 8/15/2020

option default integer

#Include "../common/welcome.inc"

const NUM_CAVES = 20
const NUM_TUNNELS = 3
const NUM_BATS = 2
const NUM_PITS = 2
const START_NUM_ARROWS = 5
const MAX_SHOOT_ROOMS = 5
const ENTITIES = 6
const PLAYER = 1
const WUMPUS = 2
const BAT1 = 3
const BAT2 = 4
const PIT1 = 5
const PIT2 = 6
const DEBUG = 0

const MSGX = 0
const MSGY = 0
const MSGW = 450
const MSGH = 600
const SCRL = 12

const ECOLOR = RGB(BLACK)
' globals
dim num_arrows = START_NUM_ARROWS
dim locs(ENTITIES+1)
dim tunnels(NUM_CAVES+1, NUM_TUNNELS+1)
dim running = 0
dim visited(NUM_CAVES+1)

' main program
mode 1, 8
Cls
page write 1

box 0, 0, 799, 599,, ECOLOR, ECOLOR
page write 0
LoadMatrix
PrintRules
NewGame  
PlayLoop running
we.end_program()

' load the room connectivity matrix data
sub LoadMatrix
  local i, j
  for i= 1 to NUM_CAVES
    for j = 0 to NUM_TUNNELS
      read tunnels(i, j)
    next j
  next i
end sub 

' create a new game
sub NewGame
  local i, j, c, n, retry, ok
  
  cls
  PrintMsg "----------------------------"
  PrintMsg " Welcome to the Wumpus Cave "
  PrintMsg "----------------------------"
  n = 1
  for i = 1 to ENTITIES
    do
      retry = 0
      c = int(rnd*NUM_CAVES) + 1
        for j = 1 to n
          if c = locs(j) then
            retry = 1
          end if
        next j
      end if
    loop until retry = 0
    n = n+1
    locs(n) = c
  next i
  locs(PLAYER) = c  
  num_arrows = START_NUM_ARROWS
  for i = 1 to NUM_CAVES-1
    visited(i) = 0
  next i
  visited(c) = 1
  running = 1
  ClearMsgArea
  DrawCaves
end sub

' Debugging info
sub ShowEntities
  print "player is in room " + str$(locs(PLAYER))
  print "wumpus is in room " + str$(locs(WUMPUS))
  print "bat1   is in room " + str$(locs(BAT1))
  print "bat2   is in room " + str$(locs(BAT2))
  print "pit1   is in room " + str$(locs(PIT1))
  print "pit2   is in room " + str$(locs(PIT2))
end sub

' the play loop
sub PlayLoop running 
  local croom, ok

  do
    croom = locs(PLAYER)
    PrintRoom croom
    do 
      if running = 1 then
        PrintMsg ""
        AskQuestion "Shoot or Move (S, M)? ", m$
        ok = 1
        m1$ = UCASE$(LEFT$(m$, 1)) 
        if m1$ = "M" then
          AskQuestion "Move To? ", r$
          MoveToRoom locs(PLAYER), val(r$)
        else if m1$ = "S" then
          ShootArrows croom
        else if m1$ = "Q" then
          we.end_program()
        else
          PrintMsg "Sorry, I didn't understand that"
          PrintMsg ""
          ok = 0
        end if
      end if
    loop until ok = 1
    DrawCaves()
  loop until running = 0
end sub

' print a description of the current room, including any
' warnings or hazards
sub PrintRoom croom
  local event

  PrintMsg ""  
  PrintMsg "You are in room " + str$(croom)
  msg$ = "Tunnels lead to rooms " + str$(tunnels(croom, 1)) + ", "
  msg$ = msg$ + str$(tunnels(croom, 2)) + ", and " + str$(tunnels(croom, 3))
  PrintMsg msg$
  PrintMsg ""
  event = CheckHazards(croom)
  if event = 0 then
    PrintWarnings croom
  end if
end sub


' move the player to a new room
' if croom <> 0, then it is a voluntary move
' if croom = 0, then it is a move caused by a super bat
sub MoveToRoom croom, nroom
  local i, cr, ok

  ok = 0
  if croom <> 0 then
    for i = 1 to 3
      if tunnels(croom, i) = nroom then
        ok = 1
        exit for
      end if    
    next i
    if ok = 0 then
      PrintMsg "Sorry, that room is not connected to your current room"
      exit sub
    end if
  end if
  visited(nroom) = 1
  locs(PLAYER) = nroom
end sub

' print warnings about nearby hazards
sub PrintWarnings croom
  local i, nroom, nbat, npit

  nbat = 0 : npit = 0
  for i = 1 to NUM_TUNNELS
    nroom = tunnels(croom, i)
    if nroom = locs(WUMPUS) then
      PrintMsg "I smell a Wumpus"
    else if nroom = locs(PIT1) or nroom = locs(PIT2) then
      if npit = 0 then
        PrintMsg "I feel a draft"
        npit = npit + 1
      end if
    else if nroom = locs(BAT1) or nroom = locs(BAT2) then
      if nbat = 0 then
        PrintMsg "Bats nearby"
        nbat = nbat + 1
      end if
    end if
  next i      
end sub

' on moving to a new room, check for hazards the player will encounter there.
' if the new room has the Wumpus, there is a 50% chance it will eat the player.
' bottomless pits are always fatal.
' bats move the player to a random room which might have hazards.
function CheckHazards (croom)
  local event, nroom, again
  
  event = 0
  if croom = locs(WUMPUS) then
    if rnd() > 0.5 then
      PrintMsg ""
      PrintMsg "Oh No! You got eaten by the Wumpus! "
      PrintMsg "(He thinks you were very tasty)"
      event = 1
      again = PlayAgain()
      exit function
    else
      MoveWumpus
    end if
  end if
  if croom = locs(PIT1) or croom = locs(PIT2) then
    PrintMsg ""
    PrintMsg "Oh No! You fell into a bottomless pit! (You are dead)"
    event = 1
    again = PlayAgain()
    exit function
  end if
  if croom = locs(BAT1) or croom = locs(BAT2) then
    PrintMsg ""
    PrintMsg "Oh No! You got picked up by a super bat"
    PrintMsg " and moved to a different room!"
    event = 1
    nroom = int(rnd()*NUM_CAVES) + 1
    MoveToRoom 0, nroom
    PrintRoom nroom
    DrawCaves
  end if
  CheckHazards = event 
end function

' ask the player if he or she wants to play again
function PlayAgain()
  local ok = 1
  local again = 0

  running = 0
  do
    PrintMsg ""
    AskQuestion "Play Again (Y, N)? ", yn$
    ans$ = LEFT$(UCASE$(yn$), 1)
    if ans$ = "N" then
      PlayAgain = again
      cls
      we.end_program()
    else if ans$ = "Y" then
      again = 1
      NewGame
      PlayLoop running
    else
      PrintMsg "Sorry, I didn't understand that"
      ok = 0
    end if
  loop until ok = 1
  PlayAgain = again
end function

' manage shooting arrows
sub ShootArrows croom
  local i, j, nr, r, ok, aroom, w, again
  local rlist(MAX_SHOOT_ROOMS+1)
  
  ' collect the room info for the shot
  do
    ok = 1
    PrintMsg "How many rooms for the crooked arrow "
    AskQuestion "to go through (1-5)? ", snr$
    nr = val(snr$)
    if nr < 1 or nr > MAX_SHOOT_ROOMS then
      PrintMsg "Sorry, your answer has to be a number from 1 to 5"
      ok = 0
    end if
  loop while ok = 0
  for i = 0 to nr-1
    do
      ok = 1
      msg$ = "Room number for room " + str$(i+1) + "? "
      AskQuestion msg$, snr$
      r = val(snr$)
      if r < 1 or r > NUM_CAVES then
        PrintMsg "Sorry, that room does not exist"
        ok = 0
      else
        rlist(i) = r
      end if
    loop until ok = 1
  next i

  ' check to make sure the current room is the first room specified
  if rlist(0) <> croom then
    PrintMsg "Oh no! You forgot to put the current room"
    PrintMsg "as the first room for the arrow!"
    PrintMsg "Your arrow hits a wall and falls to the floor."
    num_arrows = num_arrows-1
    exit sub
  end if  
  
  ' do the shot - if a room specified by the user does not match
  ' the connectivity, a random tunnel is chosen.
  aroom = rlist(0)
  for i = 1 to nr
    r = rlist(i)
    ok = 0
    for j = 1 to 3
      if tunnels(aroom, j) = r then
        nr = tunnels(aroom, j)
        ok = 1
        exit for
      end if   
    next j
    if ok = 1 then
      aroom = nr
      visited(aroom) = 1
    else
      w = rnd()*3 + 1
      aroom = tunnels(aroom, w)
    end if
    if aroom = locs(WUMPUS) then
      PrintMsg ""
      PrintMsg "Aha! You got the Wumpus. He was in room " + str$(aroom)
      PrintMsg "Hee hee hee - the Wumpus'll getcha next time!"
      DrawCaves()
      again = PlayAgain()
      exit sub
    end if
  next i
  PrintMsg "Your arrow didn't hit anything."
  MoveWumpus
  num_arrows = num_arrows-1
  if num_arrows = 0 then
    PrintMsg ""
    PrintMsg "Oh No! You ran out of arrows!"
    PrintMsg "Something large and smelly just ate you!"
    again = PlayAgain()
  else
    PrintMsg "You have " + str$(num_arrows) + " arrows left"
  end if      
end sub

' Move the Wumpus to a random adjacent room
sub MoveWumpus
  local c, nx, nroom

  c = locs(WUMPUS)
  nx = rnd()*3 + 1
  nroom = tunnels(c, nx)
  locs(WUMPUS) = nroom
  PrintMsg "You hear something large moving to a different room"
  DrawCaves
end sub

sub ClearMsgArea
  page write 2
  box MSGX, MSGY, MSGW, MSGH,, RGB(BLACK)
end sub

sub PrintMsg msg$
  page write 2
  sprite scrollr MSGX, MSGY, MSGW, MSGH, 0, SCRL, RGB(BLACK)
  text MSGX, 500, msg$
  'print msg$
  page write 0
  blit MSGX, MSGY, MSGX, MSGY, MSGW, MSGH, 2
end sub

sub AskQuestion msg$, ans$
  PrintMsg msg$  
  input "", ans$
  PrintMsg ans$  
end sub
   
' Print the rules
sub PrintRules
  input "Do you want to see the rules? ", sr$
  print LEFT$(UCASE$(sr$), 1)
  if LEFT$(UCASE$(sr$), 1) <> "Y" then exit sub
  cls
  print "You are an explorer in a large cave that has 20 rooms."
  print "You are armed with a bow and 5 crooked arrows."
  print "If you run out of arrows, you die."
  print ""
  print "There are many hazards in the caves."
  print "There are 2 bottomless pits. If you fall in one, you die."
  print "There are 2 super bats that will pick you up and put you in a different room."
  print ""
  print "But the most dangerous hazard is the Wumpus."
  print "If you come into his room, sometimes he will move to another room,"
  print "but sometimes he will eat you!"
  print ""
  print "You can shoot arrows to try to kill the Wumpus. If you hit him, you win!"
  print "When you shoot an arrow, you can tell it to travel from 1 to 5 rooms."
  print "Say how many rooms you want the arrow to travel, and then the numbers"
  print "of the rooms it should go through."
  print ""
  print "IMPORTANT: the number of the room you are in now MUST be the first room"
  print "number you give. If you forget, your arrow will hit a wall and be wasted."
  print ""
  print "The room numbers you give have to be rooms that are connected."
  print "If you give the wrong numbers then the arrow willl go where it wants to."
  print ""
  print "When you shoot an arrow anywhere in the caves, it wakes up the Wumpus,"
  print "and he decides to move to a different cave."
  print ""
  print "Each time you go to a new room you will be told the room number"
  print "and the numbers of the rooms that connect to it.
  print "Then you have to decide to move again (M) or shoot an arrow. (S)"
  print ""
  print "There is a map that shows the caves. The cave with the yellow circle is where"
  print "you are, and the number in that circle is the cave number. As you explore,
  print "you will see more cave numbers come into view. You will also see the colors"
  print "for the hazards come into view. To see a hazard color without going into"
  print "a hazard cave, explore all the caves that connect to it.
  print ""
  print "Good luck hunting the Wumpus!"
  print ""
  print "Press any key to play"

  we.clear_keyboard_buffer()
  sr$ = we.wait_for_key$()
  If we.is_quit_key%(sr$) Then we.end_program()
end sub

' Draw the caves with occupants noted by colored borders:
' Yellow = Player ("cowardly?")
' Red = Wumpus
' Blue = Bottomless Pits
' Green = Bats
sub DrawCaves
  local cx, cy, i, n, r1, r2, r3, r4
  local float angle, ainc, srad, frad
  local x, y, x1, y1, x2, y2, tx, ty
  local fcol = RGB(WHITE)
  local ecol

  cls
  page write 1

  ' Draw the Circle connections
  cx = 600 : cy = 300
  r1 = 48  : circle cx, cy, r1
  r2 = 98 : circle cx, cy, r2
  r3 = 148 : circle cx, cy, r3
  r4 = 15
  tx = -7
  ty = -4

  ' Draw the radial connections
  for i = 1 to 20
    srad = -1
    rconn = tunnels(i, 3)
    if i >= 1 and i <= 5 then
      srad = r1
      frad = r2
      angle = 240 + i*(360/5)
    else if i >= 6 and i <= 15 then
      srad = r2
      frad = r3
      angle = 276 + i*(360/5)
    end if
    if srad > 0 then
      x1 = cx + srad*cos(rad(angle))
      y1 = cy + srad*sin(rad(angle))
      x2 = cx + frad*cos(rad(angle))
      y2 = cy + frad*sin(rad(angle))
      line x1, y1, x2, y2,, fcol
    end if 
  next i

  ' Draw the cave circles.
  ' Draw the cave numbers and entity colors
  ' (Only for visited caves)
  n = 1
  angle = 240
  for i = 1 to 5 
    x = cx + r1*cos(rad(angle))
    y = cy + r1*sin(rad(angle))
    ecol = fcol
    if n = locs(PLAYER) then ecol = RGB(YELLOW)
    if visited(n) = 1 or VisitedAllNeighbors(n) = 1 then
      if n = locs(WUMPUS) then ecol = RGB(RED)
      if n = locs(BAT1) or n = locs(BAT2) then ecol = RGB(GREEN)
      if n = locs(PIT1) or n = locs(PIT2) then ecol = RGB(BLUE)
    end if
    circle x, y, r4, 3,, ecol, fcol
    if visited(n) = 1 or VisitedAllNeighbors(n) = 1 then
      text x+tx, y+ty, str$(n),,,, RGB(BLACK), RGB(WHITE)
    end if
    angle = angle + 360/5
    n = n+1
  next i
  angle = 168
  for i = 1 to 10
    x = cx + r2*cos(rad(angle))
    y = cy + r2*sin(rad(angle))
    ecol = fcol
    if n = locs(PLAYER) then ecol = RGB(YELLOW)
    if visited(n) = 1 or VisitedAllNeighbors(n) = 1 then
      if n = locs(WUMPUS) then ecol = RGB(RED)
      if n = locs(BAT1) or n = locs(BAT2) then ecol = RGB(GREEN)
      if n = locs(PIT1) or n = locs(PIT2) then ecol = RGB(BLUE)
    end if
    circle x, y, r4, 3,, ecol, fcol
    if visited(n) = 1 or VisitedAllNeighbors(n) = 1 then
      text x+tx, y+ty, str$(n),,,, RGB(BLACK), RGB(WHITE)
    end if
    angle = angle + 360/10
    n = n+1
  next i
  angle = 132
  for i = 1 to 5 
    x = cx + r3*cos(rad(angle))
    y = cy + r3*sin(rad(angle))
    ecol = fcol
    if n = locs(PLAYER) then ecol = RGB(YELLOW)
    if visited(n) = 1 or VisitedAllNeighbors(n) = 1 then
      if n = locs(WUMPUS) then ecol = RGB(RED)
      if n = locs(BAT1) or n = locs(BAT2) then ecol = RGB(GREEN)
      if n = locs(PIT1) or n = locs(PIT2) then ecol = RGB(BLUE)
    end if
    circle x, y, r4, 3,, ecol, fcol
    if visited(n) = 1 or VisitedAllNeighbors(n) = 1 then
      text x+tx, y+ty, str$(n),,,, RGB(BLACK), RGB(WHITE)
    end if
    angle = angle + 360/5
    n = n+1
  next i

  page write 0
  blit 449, 0, 449, 0, 350, 600, 1

end sub

function VisitedAllNeighbors(n)
  local i, ok
  ok = 1
  for i = 1 to NUM_TUNNELS
    if visited(tunnels(n, i)) = 0 then
      ok = 0
      exit for
    end if
  next i
  VisitedAllNeighbors = ok
end function

' Room connectivity matrix
data 1,  2,   5,  8
data 2,  1,   3, 10
data 3,  2,   4, 12
data 4,  3,   5, 14
data 5,  1,   4,  6
data 6,  7,  15,  5
data 7,  6,   8, 17
data 8,  7,   9,  1
data 9,  8,  10, 18
data 10, 9,  11,  2
data 11, 10, 12, 19
data 12, 11, 13,  3
data 13, 12, 14, 20
data 14, 13, 15,  4
data 15, 6,  14, 16
data 16, 17, 20, 15
data 17, 16, 18,  7
data 18, 17, 19,  9
data 19, 18, 20, 11
data 20, 16, 19, 13
