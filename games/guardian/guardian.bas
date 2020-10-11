' Code by "PeteCotton"
' Music by "TweakerRay"

#Include "../../common/welcome.inc"

mode 1,8
cls
Text 400,300,"LOADING","C",5
dim integer alienCount=30
dim integer humanCount=40
' field is 10 screens wide (8000px)
'Players ship
playerShipX=400            ' Players ship x location 0 to 7999
playerShipY=300            ' Players ship y location 0 to 599
playerShipDirection=1      ' 1= facing right, -1 = facing left

' Parallax background scroll
dim float scroll1=0
dim float scroll2=0
dim float scroll3=0
dim float scroll4=0
' Aliens
dim integer alienX(50)
dim integer alienY(50)
dim integer alienDX(50)
dim integer alienDY(50)
dim integer alienHealth(50)
dim integer alienAction(50)   ' >0 locked on to a human, 0 looking, -1 abducting, -2 aborted, -3 attack
dim float alienAnimation(50)
dim integer alienAbortToHeight(50)   ' When an alien aborts a snatch, they each return to a unique (to them) random height

dim integer humanX(50)
dim integer humanY(50)
dim integer humanCaptured(50)   ' The ID of the alien that has captured them
dim integer humanHealth(50)
dim integer humanAction(50)     ' >0 falling (value is height from which they fell)
dim float humanAnimation(50)

dim integer explosionCount(10)
dim integer explosionX(10)
dim integer explosionY(10)
dim integer explosionDirection(10)

dim float bulletLifeCount(10)
dim float bulletX(10)
dim float bulletY(10)
dim float bulletDX(10)
dim float bulletDY(10)

'Temporary for drawing explosions
  dim float particleX(100)
  dim float particleY(100)
  dim float particleAge(100)
  dim float particleColour(100)
  dim float particleDX(100)
  dim float particleDY(100)

dim int gameOverCounter=0 ' When 0, game is still running, if > 0 it is over

dim float fpsTimerCount=0
dim float fpsTimerVal=0
dim float fps=0

sub LoadAssets()
  page write 2   ' store background on page 2
  load png WE.PROG_DIR$ + "/mountains.png"
  page write 3   ' store sprites on page 3
  load png WE.PROG_DIR$ + "/sprites.png"
  page write 4   ' page 4 is for particles
  load png WE.PROG_DIR$ + "/particles.png"
  ' Load High score
  on error skip 3
  open WE.PROG_DIR$ + "/guardian-hiscore.dat" for input as #1
  input #1, highScore
  close #1

end sub

' StartGame() re-initialises all of the game variables
sub StartGame
  for t=1 to alienCount
    alienX(t)=rnd*8000
    alienY(t)=200+rnd*200
    alienHealth(t)=1
    alienAction(t)=0
    alienAnimation(t)=0
    alienAbortToHeight(t)=200 + rnd*300
  next t

  for t=1 to humanCount
    humanX(t)=rnd*8000
    humanY(t)=570
    humanCaptured(t)=0
    humanHealth(t)=1
    humanAction(t)=0
    humanAnimation(t)=rnd*5
  next t

  if score>highScore then
    highScore=score
  on error skip 3
    open WE.PROG_DIR$ + "/defender-hiscore.dat" for output as #1
    print #1, highScore
    close #1
  end if

  score=0
  shipCaughtHuman=0
  alienSpeed=1
  invulnerableCounter=100   ' Give the player about 3 second of invulnerability incase the aliens are on top of them at the start
  shipHealth=1    '1=player alive, 0=player killed
  playerLives=3
  gameOverCounter=0  ' Used to show the end of the game screen - when it is 0 game is not over

  ' Show title page and instructions
  page write 0  ' We don't need to buffer this screen, so write it directly to screen 0
  load png WE.PROG_DIR$ +"/GuardianLogo.png"
  Text 400, 20, "A game by Pete Cotton","C",4,,rgb(255,0,0)
  Text 400,400, "Aliens will try and abduct the human survivors.","C",4,,rgb(0,200,255)
  Text 400,420, "Use cursor keys to move and [A] key to shoot.","C",4,,rgb(200,0,255)
  Text 400,440, "If they have a human captive, the captive will fall.","C",4,,rgb(255,200,0)
  Text 400,460, "Catch the human and return them to the ground for bonus points.","C",4,,rgb(200,200,255)
  Text 400,480, "Use [F1] and [F2] to adjust volume.", "C",4,,rgb(255,128,128)
  Text 400,530, "Press fire [A] to start game.","C",3,,rgb(Yellow)
  Text 400,500, "Music by TweakerRay (www.tweakerray.de)","C",4,,rgb(255,0,0)
  play stop
  play mp3 WE.PROG_DIR$ + "/TweakerRayGuardian-160kb.mp3"
  Do
    Select Case keydown(1)
      Case Asc("A"), Asc("a") : Exit Do ' Fire has been pressed
      Case Asc("Q"), Asc("q") : we.end_program()
    End Select
  Loop
  play stop
  page write 1 ' Set the write destination back to the buffer screen
end sub

' We can have up to 10 explosion animations on the screen at any time
' StartExplosion() finds the next available slot in the explosions arrays and starts it running
sub StartExplosion(x,y)
  PlaySoundEffect(EXPLODE, playerShipX-x)
  for z=1 to 10
    if explosionCount(z)=0 then
      explosionX(z)=x
      explosionY(z)=y-40
      explosionDirection(z)=int(rnd*2)
      if rnd*2=0 then
        explosionCount(z)=1
      else
        explosionCount(z)=31
      endif
      exit sub
    end if
  next z
end sub

sub TryAndFireBullet x,y
  for z=1 to 10
    if bulletLifeCount(z)=0 then
      bulletLifeCount(z)=100
      bulletX(z)=x
      bulletY(z)=y
      diffXBullet=playerShipX-x
      diffYBullet =playerShipY-y
      if diffXBullet>4000 then diffXBullet=diffXBullet-8000
      if diffXBullet<-4000 then diffXBullet=diffXBullet+8000
      if diffXBullet>0 then
        bulletDX(z)=4
        bulletDY(z)=diffYBullet/(diffXBullet*4)
      else if diffXBullet<0 then
        bulletDX(z)=-4
        bulletDY(z)=diffYBullet/(diffXBullet*-4)
      else
        bulletDX(z)=0
        bulletDY(z)=diffYBullet/5
      endif
      exit sub
    endif
  next z
end sub

' Aliens are either looking for a human. Action = 0
' Locked on to a human they want abduct. Action = HumanId (corresponds to human() array indexes)
' In the process of abducting a human (rising to the top of screen). Action = -1
' Aborting an abduction (rise back up and try and lock on again). Action =-2
' Have completed their abduction and are now in attack mode. Action -3
'
' Abduction are aborted when two or more aliens are going for the same human, and the other
' one gets to the human first. In this case the unsuccessful one(s) will rise back up to a
' random height (defined by AbortToHeight()) before returning to Action 0
' When an alien successfully grabs a human, they go to action -2 and start climbing to the
' top of the screen. The corresponding human has the id of their abductor stored in humanCaptured()
' If they succeed in reaching the top fo the screen, the human is killed off and the alien turns
' in to attack mode (Action=-3) where they will actively attack the player
sub DoAlienAI(id)
  if alienAction(id)=0 then
    'Lock on to nearest human
     dist=10000
     alienDY(id)=0  ' Don't change altitude
     for human=1 to humanCount
       if humanHealth(human)>0 and humanCaptured(human)=0 and abs(alienX(id)-humanX(human))<dist then
        dist=abs(alienX(id)-humanX(human))
        alienAction(id)=human
      endif
    next human
  endif


  if (alienaction(id)>0) then  'Alien has locked on to human, but not captured it yet
    'Move to human
    humanID=alienAction(id)   'Human locked on
    diffX=humanX(humanID)-alienX(id)  ' Move towards targeted human
    if (diffX>0 and diffX<4000) or diffX<-4000 then
      alienDX(id)=alienSpeed
    else
      alienDX(id)=-1*alienSpeed
    endif
    ' If directly overhead of target, then drop down
    if abs(diffX)<10 then
      ' The alien is very close to the human on the X axis, so make small X value changes
      alienDY(id)=1 * alienSpeed
      alienDX(id)=0.2 * sgn(alienDX(id)) ' if the DX is 1 make 0.2 if it is -1 make it -0.2
    else
      alienDY(id)=0 ' Maintain altitude
    endif

    'Has target been snatched by another
    if humanCaptured(humanID)<>0 and humanCaptured(humanID)<>t then
      alienAction(id)=-2
    endif
    if alienY(id)>560 then 'The alien is at the bottom of the screen, have they captured their human?
      if humanCaptured(humanID)=0 and humanHealth(humanID)>0 and abs(diffX)<10 then
        humanCaptured(humanID)=t   ' Mark this human as captured by this alien
        alienAction(id)=-1 ' ascend
      else
        'look for a new human
        alienAction(id)=-2  'Abort, rise and find a new human when back up to alienAbortToHeight(x)
      endif
    endif
  endif

  if alienAction(id)=-1 then ' Ascend with captive
    if alienY(id)>0 then ' Rising with captive
      alienDY(id)=-1 * alienSpeed
    else
      ' Alien has made it to the top with a captive and is now an attacker
      alienAction(id)=-3 'Attacker
    end if
  endif

  if alienAction(id)=-2 then ' Abort, go back up and try again
    if alienY(id)>alienAbortToHeight(id) then
      alienDY(id)=-2
      alienDX(id)=rnd(2)-1
    else
      alienDY(id)=0
      alienAction(id)=0 ' Lock on to a new target
    end if
  endif

  if alienAction(id)=-3 then ' Attack the player
    diffX=alienX(id)-playerShipX
    if diffX>4000 then diffX=diffX-8000
    diffY=alienY(id)-playerShipY+(rnd*200)-100    ' The random is to stop all aliens attackin at the same height
    if diffX>0 then alienDX(id)=-3 * alienSpeed
    if diffX<0 then alienDX(id)=3 * alienSpeed
    if diffY>0 then alienDY(id)=-2
    if diffY<0 then alienDY(id)=2
  endif
end sub

' The player has 3 seconds of invulnerability after they are re-spawned. Apart from that
' the subroutine title is fairly self explanatory
sub KillPlayer
  if invulnerableCounter<=0 then
    shipHealth=0 ' Player is killed
    invulnerableCounter=100  ' Restart invulnerabilty counter for player
    playerLives=playerLives-1
    StartExplosion playerShipX, playerShipY
    cls rgb(255,255,255)  'Flash screen
  end if
end sub

' Does what it says on the tin
sub KillAlien (alienID)
  alienHealth(alienID)=0
  score=score+50
  StartExplosion alienX(alienID), alienY(alienID)
end sub

' Shows the game over screen, then after 2 seconds waits for the player to press space to restart
' This is used to let the game animations run for a bit after the player dies, so that they
' see their ship explode. Otherwise the game would just abruptly finish
sub ShowGameOverScreen
    Text 400,200, "GAME OVER","C",5,,rgb(yellow)
    gameOverCounter = gameOverCounter+1
    if gameOverCounter > 60 then
      StopAllSoundEffects()
      Text 400,400, "Press [Space] to start a new game","C",5,,rgb(yellow)
      Text 400,450, "Press [Q] to Quit","C",5,,rgb(yellow)
    end if
    if gameOverCounter > 65 then
      Do
        Select Case(keydown(1))
          Case 32 : Exit Do
          Case Asc("Q"), Asc("q") : we.end_program()
        End Select
      Loop
      StartGame()
    endif
end sub

const PLAYERFIRE=1
const EXPLODE=2

sub UpdateAudio()
  if fireSoundCounter>0 then
    fireSoundCounter=fireSoundCounter-1
    if fireSoundCounter=0 then play sound 1, B, O
  end if

  if explodeSoundCounter>0 then
    explodeSoundCounter=explodeSoundCounter-1
    if explodeSoundCounter=0 then play sound 2, B, O
  end if
end sub

dim integer explodeSoundCounter=0
dim integer fireSoundCounter=0
dim float MasterVolume = 20
sub PlaySoundEffect(n, xdiff)
  if n=PLAYERFIRE then
    if xdiff <0 then play sound 1, L, P, 1, int(MasterVolume/2)
    if xdiff >0 then play sound 1, R, P, 1, int(MasterVolume/2)
    fireSoundCounter=10
  endif
  if n=EXPLODE then
    if xdiff<0 then play sound 2, L, N, 100, int(MasterVolume)
    if xdiff>=0 then play sound 2, R, N, 100, int(MasterVolume)
    explodeSoundCounter=15
  endif
end sub

sub StopAllSoundEffects()
  play sound 1, B, O
  play sound 2, B, O
end sub

'
' ********************************************************************************
'                            Start of code
' ********************************************************************************

LoadAssets()
StartGame()

page write 1 'From now on, we write everything to the copy buffer on page 1

fpsTimerCount=0
fpsTimerVal=TIMER

do ' Main Loop
'  if keydown(1)=147 then save image "screenshot.bmp"   F3 for screen shot

  cls

  ' Use these variables to track what keys the user has pressed
  firePressed=0
  leftPressed=0
  rightPressed=0
  upPressed=0
  downPressed=0
  F1Pressed=0
  F2Pressed=0

  if gameOverCounter > 0 then
    ShowGameOverScreen()
  else
    ' Scan keyboard
    keyPressedCount=keydown(0)
    for t=1 to keyPressedCount
      if keydown(t)=97 or keydown(t)=65 then firePressed=1  ' The A key
      if keydown(t)=130 then leftPressed=1
      if keydown(t)=131 then rightPressed=1
      if keydown(t)=128 then upPressed=1
      if keydown(t)=129 then downPressed=1
      if keydown(t)=32 then spacePressed=1
      if keydown(t)=145 then F1Pressed=1
      if keydown(t)=146 then F2Pressed=1
    next t
  endif

  if firePressed then fire=3
  if fire>0 then fire=fire-0.3   ' Add a delay so that the ship takes a split second to actually stop firing

  thrust=0   ' If neither left nor right cursor buttons are pressed, then zero thrust

  if leftPressed then 'left
    playerShipDirection=-1
    thrust=-10
  endif

  if rightPressed then 'right
    playerShipDirection=1
    thrust=10
  endif

  if upPressed then 'up
    playerShipY=playerShipY-6
    if playerShipY < 10 then playerShipY=10
  endif

  if downPressed then 'down
    playerShipY=playerShipY+6
    if playerShipY>570 then playerShipY=570
  endif

  if F1Pressed and MasterVolume>0 then
    MasterVolume=MasterVolume-0.1
    if MasterVolume<0 then MasterVolume=0
  end if

  if F2Pressed and MasterVolume<=25 then
    MasterVolume=MasterVolume+0.1
    if MasterVolume>25 then MaterVolume=25
  end if

  ' Give the player about 3 seconds of invulnerability when each wave starts
  ' This prevents the player unfairly exploding if they appear among a group of random aliens
  if invulnerableCounter>0 then invulnerableCounter=invulnerableCounter-1

  'Move the background relative to the ships movement
  inertiaX=inertiaX + thrust/15   ' This adds inertia to the ship so that it doen't stop instantly
  if thrust=0 and inertiaX<>0 then ' If there is no thrust, reduce speed
    if inertiaX>0 then inertiaX=inertiaX-0.1
    if inertiaX<0 then inertiaX=inertiaX+0.1
    if abs(inertiaX)<0.2 then inertiaX=0
  endif
  if inertiaX>30 then inertiaX=30
  if inertiaX<-30 then inertiaX=-30
  scroll1=scroll1 - inertiaX * 0.3
  scroll2=scroll2 - inertiaX * 0.6
  scroll3=scroll3 - inertiaX * 1
  scroll4=scroll4 - inertiaX/2   ' this is the foreground scroll. It is already 4 times as fast as scroll3
  if scroll4 >=20 then scroll4=scroll4-20   ' "Wrap" the foreground scroll so that it looks continuous
  if scroll4<0 then scroll4=scroll4+20

  ' Although the player ship stays in the middle of the screen, the X co-ord records our
  ' position in the 8000 pixel wide "map"
  playerShipX = playerShipX + inertiaX
  if playerShipX>7999 then playerShipX=playerShipX-8000
  if playerShipX<0 then playerShipX=playerShipX+8000

  'Draw the Radar background
  box 0,-1,801,21,1,rgb(white),rgb(0,0,0)
  box 400,0,80,20,1,rgb(white),rgb(0,0,100)

  'Draw the background (the mountains)
  ' As the player rises up n height we want to spread out the parallax layers to give it some
  ' vertical depth. This is handled by variable groundY.
  groundY=490
  groundDiff=(playerShipY-300)/10
  if groundDiff>0 then groundDiff=0
  if groundDiff<-20 then groundDiff=-20
  ' Each section of mountain is 1600 pixels wide (stored on 2 rows of 100 pixels high on page 2)
  ' Draw each section of mountain. Sometimes we need to patch a bit on before or after if the edge
  ' of the mountain range appears on screen (to make it look continuous). i.e. wrap around
  ' Mountain range 1 (very back) is stored at Y pixels 0 and 101 on page 2
  blit 0,0,scroll1,groundY+groundDiff*2,800,100,2
  if scroll1>0 then blit 0,101,scroll1-800,groundY+groundDiff*2,800,100,2 'blit the image to the left of this one
  if scroll1<0 then blit 0,101, scroll1+800,groundY+grounDdiff*2,800,100,2 'blit the image to the right of this one
  ' Mountain range 2 (middle) is stored at Y pixels 201 and 301 on page 2
  blit 0,201,scroll2,groundy + groundDiff,800,100,2,&B100
  if scroll2>0 then blit 0,301,scroll2-800,groundY + groundDiff,800,100,2,&B100 'blit the image to the left of this one
  if scroll2<0 then blit 0,301, scroll2+800,groundY + groundDiff,800,100,2,&B100 'blit the image to the right of this one
  ' Mountain range 3 (front) is stored at Y pixels 401 and 501
  blit 0,401,scroll3,groundY,800,100,2,&B100
  if scroll3>0 then blit 0,501,scroll3-800,groundY,800,100,2,&B100 'blit the image to the left of this one
  if scroll3<0 then blit 0,501, scroll3+800,groundY,800,100,2,&B100 'blit the image to the right of this one

  ' If any of the mountains are going to scroll off the right or left, reset them
  ' Becaue we are adjusting by 1600 pixels - which is the width of the mountain range, this will
  ' appear to be a seamless change on the screen
  if scroll1>800 then scroll1=scroll1-1600
  if scroll1<-800 then scroll1=scroll1+1600
  if scroll2>800 then scroll2=scroll2-1600
  if scroll2<-800 then scroll2=scroll2+1600
  if scroll3>800 then scroll3=scroll3-1600
  if scroll3<-800 then scroll3=scroll3+1600

  ' Draw the foreground scrolling grid at the bottom of the screen
  blit 0,200 +int(scroll4)*10,0,590 ,800,10,3

  ' The left most pixel of the screen in the range 0 to 7999. This is used repeatedly below
  screenLeftX=playerShipX-400

  'Alien AI
  ' The alien AI takes time to process, so each scan process a batch of 5 aliens. So an indivdiual
  ' Alien AI only makes a decision every few scans. Each scan we do the next 5 aliens.
  ' Note: the aliens still move every scan, this is just the decision making process for them
  AICount=AICount+1
  if AICount>=10 then AICount=0
  for t= (AICount*5)+1 to (AICount+1)*5  ' 1 to 5, then 6 to 10, then 11 to 15, up to 46 to 50
    if alienHealth(t) > 0 then   ' I the alien alive (if not, then ignore)
      DoAlienAI(t)
    endif
  next t

  ' Draw each alien
  countOfLiveAliens=0   ' We use this to see if the player has killed all the aliens in this wave
  for t= 1 to alienCount
    if alienHealth(t) > 0 then
      countOfLiveAliens=countOfLiveAliens+1   ' Used each scan to check if all aliens are dead
      alienX(t)=alienX(t)+alienDX(t)       ' Move the alien X pos
      alienY(t)=alienY(t)+alienDY(t)       ' Move the alien Y pos
      if alienX(t)>7999 then alienX(t)=alienX(t)-8000 ' Have they gone off the end of the map
      if alienX(t)<0 then alienX(t)=alienX(t)+8000    ' Have they gone off the beginning of the map

      onscreenX=alienX(t)-screenLeftX        ' Translate real world xpos to onscreen xpos
      if onscreenX<-4000 then onscreenX=onscreenX+8000
      if onScreenX>4000 then onscreenX=onscreenX-8000
      'Plot on Radar
      pixel onScreenX/10 +400, alienY(t)/30,rgb(red)
      pixel onScreenX/10 +401, alienY(t)/30,rgb(red)

      if onScreenX>-20 and onscreenX<800 then  ' is the alien visible on screen
        'check if this is a collision with the player
        if onScreenX>370 and onScreenX<430 and alienY(t)>playerShipY-10 and alienY(t)<playerShipY+10 then
          ' Collision with player
          KillPlayer()
          KillAlien(t)
        endif

        'Randomly occasionally fire at the player
        if int(rnd*100)=1 then TryAndFireBullet(alienX(t), alienY(t))

        ' Animate the alien (0 to 3 "normal" animation, 4 to 7 is "attacker" animation)
        alienAnimation(t) = alienAnimation(t)+1
        if alienAction(t) <> -3 and alienAnimation(t)>=4 then alienAnimation(t)=0
        if alienAction(t) =-3 and alienAnimation(t)>=8 then alienAnimation(t)=4
        if (alienAnimation(t)<4) then
          blit int(alienAnimation(t))*30,30,onScreenX, alienY(t),28,16,3,&B100
        else
          blit int(alienAnimation(t))*30,30,onScreenX, alienY(t),28,9,3,&B100
        endif

        'while we are here,look to see if the alien has been hit by the player's guns
        if fire>0 then
          if alienY(t) > playerShipY - 10 and alienY(t) < playerShipY+25  then ' It is in the right vertical range
            if playerShipDirection=1 and onscreenX>399 and onscreenX<720 then KillAlien(t)
            if playerShipDirection=-1 and onscreenX<401 and onscreenX>65 then KillAlien(t)
          endif
        endif
      endif
    end if
  next t

  'Draw human survivors
  countOfLiveHumans=0
  for t= 1 to humanCount
    if humanHealth(t) > 0 then
      countOfLiveHumans=countOfLiveHumans+1   ' Used each scan to see if all of the humans are dead
      onscreenX=humanX(t)-screenLeftX
      if onscreenX<-4000 then onscreenX=onscreenX+8000
      if onScreenX>4000 then onscreenX=onscreenX-8000
      'Plot on radar
      pixel onScreenX/10 +400, humanY(t)/30-1,rgb(white)
      pixel onScreenX/10 +400, humanY(t)/30-2,rgb(white)

      if humanCaptured(t) <>0 then     ' This human has been captured. Draw them below the alien
        captorID=humanCaptured(t)
        humanY(t)=alienY(captorID)+10
        humanX(t)=alienX(captorID)+7
        if alienHealth(captorID)=0 then 'Has their captor been killed
          humanAnimation(t)=6 'falling
          humanAction(t)=humanY(t) ' height from which they fell (so we know if they "splat")
          humanCaptured(t)=0
        endif
        if alienAction(captorID)=-3 then   ' Their captor made it to the top of the screen
          humanHealth(t)=0
        endif
      endif

      ' Handle human falling (i.e. their abductor alien has been shot)
      ' if they fallfrom less than 100 pixels (Y>=500) then they will survive if they hit the ground
      ' Otherwise they will die ("splat")
      if humanAction(t)>0 then    ' They are falling
        if humanY(t)<570 then
          humanY(t)=humanY(t)+1
          'Did the player catch them
          if humanX(t)>playerShipX-30 and humanX(t)<playerShipX+30 and humanY(t)>playerShipY and humanY(t)<playerShipY+30 and shipCaughtHuman=0 then
            shipCaughtHuman=t
            humanAction(t)=0
            humanAnimation(t)=0
          endif
        else
          ' Did they splat
          if humanAction(t)<500 then ' too high - they splat
            humanAnimation(t)=8
            humanAction(t)=0
          else
            humanAnimation(t)=0 ' They're fine, get them back to waving
            humanAction(t)=0
          endif
        endif
      endif

      if shipCaughtHuman=t then ' The player has caught them
        humanX(t)=playerShipX
        humanY(t)=playerShipY+10
        if playerShipY > 560 then   ' Safely back on the ground
          shipCaughtHuman=0
          humanY(t)=570
          score=score+80
        endif
      endif

      if onScreenX>-20 and onscreenX<800 then  'only draw if humam is onscreen
        blit 15*int(humanAnimation(t)),45,onScreenX, humanY(t),15,15,3,&B100
      endif
      humanAnimation(t)=humanAnimation(t)+0.2
      if humanAction(t)=0 and int(humanAnimation(t))=6 then humanAnimation(t)=0
      if humanAction(t)>0 and int(humanAnimation(t))=8 then humanAnimation(t)=6
      if int(humanAnimation(t))=14 then humanHealth(t)=0 'dead
    end if
  next t

  'Draw player ship
  if gameOverCounter=0 then
    if (playerShipDirection=1) then
      blit 0,0,370,playerShipY,60,25,3,&B101  ' flip image to face right
    else
      blit 0,0,370,playerShipY,60,25,3,&B100
    endif
    if invulnerableCounter>0 then
      if invulnerableCounter >60 then circle 400,playerShipY+10,22,,2,rgb(white)
      if invulnerableCounter <=60 then circle 400,playerShipY+10,22,,2,rgb(128,128,128)
      if invulnerableCounter <30 then circle 400,playerShipY+10,22,,2,rgb(64,64,64)
    endif
  endif

  'Draw explosion animations (up to 10 onscreen at any time - any above that are ignored)
  for t=1 to 10
    if explosionCount(t)<>0 then
      sourceX=(explosionCount(t)-1)
      sourceY=0
      do while sourceX>9
        sourceX=sourceX-10
        sourceY=sourceY+1
      loop
      onscreenX=explosionX(t)-screenLeftX
      if onScreenX>7980 then onscreenX=onscreenX-8000
      if onscreenX<-7180 then onscreenX=onscreenX+8000
      if explosionDirection(t)=1 then
        blit sourceX*80, sourceY*80, onscreenX,explosionY(t),80,80,4,&B100
      else
        blit sourceX*80, sourceY*80, onscreenX,explosionY(t),80,80,4,&B101
      endif
      explosionCount(t)=explosionCount(t)+1
      if explosionCount(t)=31 or explosionCount(t)=61 then explosionCount(t)=0
    endif
  next t

  'Draw player firing
  if fire>0 then
    PlaySoundEffect(PLAYERFIRE, playerShipDirection)
    animation=int(rnd*5)+1
    if playerShipDirection=1 then
      blit 0,145 + (animation*5), 420,playerShipY+10, 300,5,3,&B100
    else
      blit 0,145 + (animation*5), 80,playerShipY+10, 300,5,3,&B101    ' Flip the image left
    endif
  end if

  'Draw alien bullets
  for t=1 to 10
    if bulletLifeCount(t)>0 then
      bulletLifeCount(t)=bulletLifeCount(t)-1
      bulletX(t)=bulletX(t)+bulletDX(t)
      bulletY(t)=bulletY(t)+bulletDY(t)
      onscreenX=bulletX(t)-screenLeftX
      if onScreenX>7980 then onscreenX=onscreenX-8000
      if onscreenX<-7180 then onscreenX=onscreenX+8000
      pixel onScreenX, bulletY(t), rgb(white)
      pixel onScreenX+1,bulletY(t),rgb(white)
      pixel onScreenX, bulletY(t)+1, rgb(white)
      pixel onScreenX+1,bulletY(t)+1,rgb(white)
      if onScreenX>370 and onScreenX<430 and bulletY(t)>playerShipY-10 and bulletY(t)<playerShipY+10 then
        ' Collision with player
        KillPlayer()
        bulletLifeCount(t)=0  ' Destroy bullet
      endif
    endif
  next t

  'Text rendering
  text 0,0, "Score:" + str$(score,6,0,"0"),,4,,rgb(yellow)
  text 0,20, "High:" + str$(highscore,6,0,"0"),"L",4,,rgb(yellow)
  text 700,0, "Lives: " +str$(playerLives),"L",4,,rgb(yellow)

  ' Turn off any sound effects that are due to finish
  UpdateAudio()

  'Count the frames per second
  fpsTimerCount=fpsTimerCount+1
  if (fpsTimerCount>=100) then
    fps = 1000/((TIMER-fpsTimerVal)/100)
    fpsTimerVal=TIMER
    fpsTimerCount=0
  endif
  text 700,20, "FPS: " + str$(int(fps))

  ' Has the player lost
  if gameOverCounter=0 and ( countOfLiveHumans=0 or playerLives<=0) then gameOverCounter=1 ' Start the game over logic

  'Has the player cleared this level
  if countOfLiveAliens=0 then
    page write 0 ' Write directly to the displayed screen
    Text 400,200, "Congratulations you saved " + str$(countOfLiveHumans) + " humans!","C",4,,rgb(yellow)
    bonus = countOfLiveHumans * 50
    alienSpeed=alienSpeed+0.5
    Text 400, 250, "Bonus points of " + str$(bonus) + " awarded","C",4,,rgb(yellow)
    score=score+bonus
    Text 400,300, "Press [Space] to start the next level","C", 4,,rgb(yellow)

    StopAllSoundEffects()
    Do
      Select Case(keydown(1))
        Case 32 : Exit Do
        Case Asc("Q"), Asc("q") : we.end_program()
      End Select
    Loop
    page write 1 ' Set the output back to the buffer screen
    if alienCount<50 then alienCount=alienCount+1
    for t=1 to alienCount
      alienX(t)=rnd*8000
      alienY(t)=200+rnd*200
      alienHealth(t)=1
      alienAction(t)=0
      alienAnimation(t)=0
      alienAbortToHeight(t)=200 + rnd*300
    next t
    invulnerableCounter=100  ' 3 seconds of invulnerability for the player at the start of the game
  endif

  page copy 1 to 0,B
loop

