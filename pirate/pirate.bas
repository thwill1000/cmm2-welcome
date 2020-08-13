100 rem adventure 2
110 rem by scott adams
120 rem modified for pet by jeff jessee
125 rem modified for new rom 12/jun/79
130 poke59468,14
140 x=y=z:k=r=v:n=ll=f:tp$=k$:w=ip=p:gosub180:gosub 2100
150 print"hit RETURN to begin ADVENTURE";
160 get g$:ifg$=""then160
170 print"":goto300
180 print"         WELCOME TO ADVENTURE"
190 print"  the object of your adventure is to"
200 print"find treasures and return them to their"
210 print"proper place.
220 print"  i'm your clone. give me commands that"
230 print"consist of a verb and a noun.
240 print"I.E., GO EAST, TAKE KEY, CLIMB TREE,"
250 print"SAVE GAME, TAKE INVENTORY.
260 print"  you'll need special items to do some"
270 print"things, but I'm sure you'll be a good"
280 print"adventurer and figure these things out."
290 print"          HAPPY ADVENTURING!!":return
300 r=ar:lx=lt:df=0:sf=0:input"USE SAVED GAME (Y or N)   N";k$
310 if left$(k$,1)<>"y"then print"":goto370
320 input"IS SAVED GAME TAPE POSITIONED";k$:if left$(k$,1)<>"y"then300
330 open 1,1,0,"adventure game"
340 input#1,sf,lx,df,r
350 forx=0toil:input#1,ia(x):nextx
360 close1
370 gosub550:goto440
380 print:input"tell me what to do   Ä";tp$:print:gosub450
390 if f thenprint"you use word(s) i don't know!":goto380
400 gosub710:ifia(9)=-1thenlx=lx-1:goto420
410 goto440
420 iflx<0then print"light has run out!":ia(9)=0:goto440
430 iflx<25thenprint"light runs out in";lx;"turns!"
440 nv(0)=0:gosub710:goto380
450 k=0:nt$(0)="":nt$(1)=""
460 forx=1tolen(tp$):k$=mid$(tp$,x,1):ifk$=" "thenk=1:goto480
470 nt$(k)=left$(nt$(k)+k$,ln)
480 nextx:forx=0to1:nv(x)=0:ifnt$(x)=""then540
490 fory=0tonl:k$=nv$(y,x):ifleft$(k$,1)="*"thenk$=mid$(k$,2)
500 ifx=1andy<7thenk$=left$(k$,ln)
510 ifnt$(x)=k$thennv(x)=y:goto530
520 nexty:goto540
530 ifleft$(nv$(nv(x),x),1)="*"thennv(x)=nv(x)-1:goto530
540 nextx:f=nv(0)<1orlen(nt$(1))>0andnv(1)<1:return
550 ifdfthenifia(9)<>-1andia(9)<>rthenprint"i can't see, its too dark!":return
560 k=-1:ifleft$(rs$(r),1)="*"thenprintmid$(rs$(r),2);:goto580
570 print"i'm in a ";rs$(r);
580 forz=0toil:ifkthenifia(z)=rthenprint:print"visible items here:":k=0
590 goto640
600 tp$=ia$(z):ifright$(tp$,1)<>"/"thenreturn
610 forw=len(tp$)-1to1step-1:ifmid$(tp$,w,1)="/"thentp$=left$(tp$,w-1):return
620 nextw
630 return
640 ifia(z)<>rthen670
650 gosub600:ifpos(0)+len(tp$)+3>39thenprint
660 printtp$;".  ";
670 next:print
680 k=-1:forz=0to5:ifkthenifrm(r,z)<>0thenprint:print"obvious exits: ":k=0
690 ifrm(r,z)<>0thenprintnv$(z+1,1);" ";
700 next:print:print:return
710 f2=-1:f=-1:f3=0:ifnv(0)=1andnv(1)<7then1190
720 forx=0tocl:v=int(c0%(x)/150):ifnv(0)=0thenifv<>0thenreturn
730 ifnv(0)<>vthennextx:goto1640
740 n=c0%(x)-v*150
750 ifnv(0)=0thenf=0:goto770
760 goto790
770 ifint(rnd(1)*100+1)<=nthen800
780 nextx:goto1640
790 ifn<>nv(1)andn<>0thennextx:goto1640
800 f2=-1:f=0:f3=-1:fory=1to5:on y goto 810,820,830,840,850
810 w=c1%(x):goto860
820 w=c2%(x):goto860
830 w=c3%(x):goto860
840 w=c4%(x):goto860
850 w=c5%(x):goto860
860 ll=int(w/20):k=w-ll*20:f1=-1
870 onk+1goto1060,940,960,980,1000,1010,1020,1030,1040,1050,900,920
880 ifk<12then900
890 onk-11goto950,970,990
900 f1=-1:forz=0toil:ifia(z)=-1then1060
910 next:f1=0:goto1060
920 f1=0:forz=0toil:ifia(z)=-1then1060
930 next:f1=-1:goto1060
940 f1=ia(ll)=-1:goto1060
950 f1=ia(ll)<>-1andia(ll)<>r:goto1060
960 f1=ia(ll)=r:goto1060
970 f1=ia(ll)<>0:goto1060
980 f1=ia(ll)=r oria(ll)=-1:goto1060
990 f1=ia(ll)=0:goto1060
1000 f1=r=ll:goto1060
1010 f1=ia(ll)<>r:goto1060
1020 f1=ia(ll)<>-1:goto1060
1030 f1=r<>ll:goto1060
1040 f1=sfandint(2^ll+.5):f1=f1<>0:goto1060
1050 f1=sfandint(2^ll+.5):f1=f1=0:goto1060
1060 f2=f2andf1:iff2thennexty:goto1080
1070 nextx:goto1640
1080 ip=0:fory=1to4:k=int((y-1)/2+6):onygoto1090,1100,1110,1120
1090 ac=int(c6%(x)/150):goto1130
1100 ac=c6%(x)-int(c6%(x)/150)*150:goto1130
1110 ac=int(c7%(x)/150):goto1130
1120 ac=c7%(x)-int(c7%(x)/150)*150
1130 ifac>101then1180
1140 ifac=0then1610
1150 ifac<52thenprintms$(ac):goto1610
1160 onac-51goto1290,1330,1340,1360,1370,1380,1390,1360,1410,1430,1440
1170 onac-62goto1450,1470,1480,1530,1570,1580,1590,1600,2020,1350
1180 printms$(ac-50):goto1610
1190 l=df:iflthenl=dfandia(9)<>r andia(9)<>-1:goto1210
1200 goto1220
1210 iflthenprint"dangerous in the dark!"
1220 ifnv(1)<1thenprint"give me a direction too.":goto1690
1230 k=rm(r,nv(1)-1)
1240 ifk>=1then1270
1250 iflthenprint"i fell down and broke my neck.":k=rl:df=0:goto1270
1260 print"i can't go in that direction!!":goto1690
1270 if not l thenprint""
1280 r=k:gosub550:goto1690
1290 l=0:forz=1toil:ifia(z)=-1thenl=l+1
1300 nextz
1310 ifl>=mxthenprint"i've too much to carry!":goto1620
1320 gosub1700:ia(p)=-1:goto1610
1330 gosub1700:ia(p)=r:goto1610
1340 gosub1700:r=p:goto1610
1350 gosub1700:l=p:gosub1700:z=ia(p):ia(p)=ia(l):ia(l)=z:goto1610
1360 gosub1700:ia(p)=0:goto1610
1370 df=-1:goto1610
1380 df=0:goto1610
1390 gosub1700
1400 sf=int(.5+2^p)or sf:goto1610
1410 gosub1700
1420 sf=sf andnot int(.5+2^p):goto1610
1430 print"i'm dead...":r=rl:df=0:goto1470
1440 gosub1700:l=p:gosub1700:ia(l)=p:goto1610
1450 input"the game is now over.-another game";k$:ifleft$(k$,1)="n"thenend
1460 forx=0toil:ia(x)=i2(x):next:print"":goto300
1470 gosub550:goto1610
1480 l=0:forz=1toil:ifia(z)=tr thenifleft$(ia$(z),1)="*"thenl=l+1
1490 nextz:print"i've stored";l;"treasures. on a scale"
1500 print"of 0 TO 100 that rates a";int(l/tt*100)
1510 ifl=ttthenprint"well done. ":goto1450
1520 goto1610
1530 print"i'm carrying:":k$="nothing":forz=0toil:ifia(z)<>-1then1560
1540 gosub600:iflen(tp$)+pos(0)>39thenprint
1550 print tp$;".",;:k$=""
1560 next:printk$:goto1610
1570 p=0:goto1400
1580 p=0:goto1420
1590 lx=lt:ia(9)=-1:goto1610
1600 print"":goto1610
1610 nexty
1620 ifnv(0)<>0then1640
1630 nextx
1640 rem
1650 ifnv(0)=0then1690
1660 gosub1790
1670 iffthenprint"i don't understand your command.":goto1690
1680 if not f2thenprint"i can't do that yet.":goto1690
1690 return
1700 ip=ip+1
1710 onipgoto1720,1730,1740,1750,1760
1720 w=c1%(x):goto1770
1730 w=c2%(x):goto1770
1740 w=c3%(x):goto1770
1750 w=c4%(x):goto1770
1760 w=c5%(x):goto1770
1770 p=int(w/20):m=w-p*20:ifm<>0then1700
1780 return
1790 ifnv(0)<>10andnv(0)<>18orf3then2010
1800 ifnv(1)=0thenprint"what?":goto1950
1810 ifnv(0)<>10then1840
1820 l=0:forz=0toil:ifia(z)=-1thenl=l+1
1830 next:ifl>=mxthenprint"i've too much to carry!":goto1950
1840 k=0:forx=0toil:ifright$(ia$(x),1)<>"/"then1960
1850 ll=len(ia$(x))-1:tp$=mid$(ia$(x),1,ll):fory=llto2step-1
1860 ifmid$(tp$,y,1)<>"/"thennexty:goto1960
1870 tp$=left$(mid$(tp$,y+1),ln)
1880 iftp$<>nv$(nv(1),1)then1960
1890 ifnv(0)=10then1920
1900 ifia(x)<>-1thenk=1:goto1960
1910 ia(x)=r:k=3:goto1940
1920 ifia(x)<>rthenk=2:goto1960
1930 ia(x)=-1:k=3
1940 print"OK, ":print
1950 f=0:return
1960 nextx
1970 ifk=1thenprint"i'm not carrying it!"
1980 ifk=2thenprint"i don't see it here."
1990 ifk=0thenifnotf3thenprint"it's beyond my power to do that.":f=0
2000 ifk<>0thenf=0
2010 return
2020 rem save game
2030 input"OUTPUT TAPE READY TO SAVE GAME";k$:if left$(k$,1)<>"y"then2090
2040 open1,1,1,"adventure game"
2050 print#1,sf:print#1,lx:print#1,df:print#1,r
2060 forw=0toil:print#1,ia(w)
2070 poke59411,53:forz9=1to10:nextz9:poke59411,61
2080 nextw:close1
2090 goto1610
2100 read il,cl,nl,rl,mx,ar,tt,ln,lt,ml,tr
2110 dimnv(1),c0%(cl),c1%(cl),c2%(cl),c3%(cl),c4%(cl),c5%(cl),c6%(cl),c7%(cl)
2120 dim nv$(nl,1),ia$(il),ia(il),rs$(rl),rm(rl,5),ms$(ml),nt$(1),i2(il)
2130 forx=0toclstep2:y=x+1
2140 readc0%(x),c1%(x),c2%(x),c3%(x),c4%(x),c5%(x),c6%(x),c7%(x)
2150 readc0%(y),c1%(y),c2%(y),c3%(y),c4%(y),c5%(y),c6%(y),c7%(y):nextx
2160 forx=0tonlstep10:fory=0to1
2170 readnv$(x,y),nv$(x+1,y),nv$(x+2,y),nv$(x+3,y),nv$(x+4,y),nv$(x+5,y)
2180 read nv$(x+6,y),nv$(x+7,y),nv$(x+8,y),nv$(x+9,y):nexty,x
2190 forx=0torl:readrm(x,0),rm(x,1),rm(x,2),rm(x,3),rm(x,4),rm(x,5),rs$(x):next
2200 forx=0toml:readms$(x):nextx
2210 forx=0toil:readia$(x),ia(x):i2(x)=ia(x):nextx
2220 ms$(2)=ms$(2)+".there's a word encraved on the flyleaf: -yoho- "
2230 ms$(2)=ms$(2)+"and a message: long john silver  left 2 treasures on "
2240 ms$(2)=ms$(2)+"treasure island!!"
2250 ms$(31)=ms$(31)+",an anchor,sailsand a keel."
2260 return
2270 data 60,151,59,33,5,1,2,3,200,71,1
2280 data 80,422,342,420,340,0,16559,8850
2290 data 80,462,482,460,0,0,15712,1705
2300 data 100,521,552,540,229,220,203,8700
2310 data 3,483,0,0,0,0,15712,0
2320 data 100,284,0,0,0,0,8550,0
2330 data 100,28,663,403,40,0,8700,0
2340 data 100,48,20,660,740,220,9055,10902
2350 data 100,28,20,0,0,0,3810,0
2360 data 100,8,700,720,0,0,10868,0
2370 data 100,48,40,640,400,300,9055,8305
2380 data 25,664,0,0,0,0,4263,0
2390 data 40,104,886,0,0,0,4411,0
2400 data 80,242,502,820,80,240,9321,10109
2410 data 100,8,140,80,500,0,10262,8850
2420 data 35,421,846,420,200,0,5162,0
2430 data 100,129,120,0,0,0,6508,0
2440 data 50,242,982,820,440,240,9321,8850
2450 data 35,483,69,0,0,0,15705,0
2460 data 10,483,249,0,0,0,15706,0
2470 data 50,484,1073,1086,0,0,17661,9150
2480 data 50,204,1086,0,0,0,16711,0
2490 data 10,209,1040,1060,300,1100,10872,10050
2500 data 10,208,1040,1060,89,0,10867,0
2510 data 85,483,8,0,0,0,15719,10200
2520 data 100,8,0,0,0,0,10200,0
2530 data 100,104,0,0,0,0,8550,0
2540 data 80,462,282,280,1160,0,1422,0
2550 data 158,82,60,0,0,0,8170,9600
2560 data 4510,61,0,0,0,0,300,0
2570 data 163,22,100,0,0,0,8170,9600
2580 data 8100,0,0,0,0,0,16200,0
2590 data 4800,104,120,61,0,0,10507,8164
2600 data 4800,107,100,61,89,0,10507,8164
2610 data 4063,22,0,0,0,0,647,0
2620 data 5570,161,203,160,180,0,10870,1264
2630 data 6170,181,180,160,0,0,8302,0
2640 data 6300,104,0,0,0,0,900,0
2650 data 1529,442,465,440,0,0,7800,0
2660 data 1529,442,462,0,0,0,760,9150
2670 data 183,322,180,0,0,0,8170,9600
2680 data 1538,262,242,0,0,0,1800,0
2690 data 1538,262,245,260,0,0,7800,0
2700 data 5888,262,242,0,0,0,1800,0
2710 data 5888,262,245,0,0,0,1950,0
2720 data 6188,262,245,541,260,560,2155,7950
2730 data 5888,261,0,0,0,0,2400,0
2740 data 4088,561,0,0,0,0,2400,0
2750 data 4088,263,0,0,0,0,2713,0
2760 data 4088,562,580,109,100,249,2303,8700
2770 data 4088,249,562,108,900,240,6203,8700
2780 data 4088,248,562,0,0,0,6600,0
2790 data 4068,103,69,0,0,0,646,0
2800 data 4068,103,68,0,0,0,6600,0
2810 data 5887,342,0,0,0,0,2550,0
2820 data 5887,362,0,0,0,0,2713,0
2830 data 5887,382,0,0,0,0,2100,0
2840 data 159,382,320,0,0,0,8170,9600
2850 data 6187,342,362,0,0,0,2550,0
2860 data 6187,345,362,541,360,380,8303,10050
2870 data 3461,503,0,0,0,0,172,0
2880 data 3750,0,0,0,0,0,9900,0
2890 data 1528,0,0,0,0,0,9900,0
2900 data 4108,1143,1012,0,0,0,646,0
2910 data 6450,0,0,0,0,0,2853,0
2920 data 4510,66,0,0,0,0,2720,0
2930 data 4950,0,0,0,0,0,9750,0
2940 data 5114,0,0,0,0,0,10650,0
2950 data 7092,592,0,0,0,0,2745,0
2960 data 185,284,140,0,0,0,8156,10564
2970 data 4098,1054,0,0,0,0,647,17550
2980 data 4098,1053,0,0,0,0,647,17400
2990 data 4083,322,0,0,0,0,647,0
3000 data 4095,762,0,0,0,0,647,0
3010 data 195,782,921,0,0,0,2727,0
3020 data 195,762,261,0,0,0,2727,0
3030 data 6900,0,0,0,0,0,9450,0
3040 data 1526,602,0,0,0,0,2723,0
3050 data 1541,621,602,640,520,600,7853,8250
3060 data 195,782,661,0,0,0,2727,0
3070 data 7092,623,583,303,643,20,8700,0
3080 data 7092,0,0,0,0,0,3750,0
3090 data 200,722,220,0,0,0,10554,9600
3100 data 195,762,61,0,0,0,2727,0
3110 data 4050,0,0,0,0,0,10564,0
3120 data 1526,523,520,0,0,0,7800,0
3130 data 195,762,340,0,0,0,8126,8464
3140 data 195,782,360,0,0,0,8157,10564
3150 data 7530,404,242,1053,89,0,17250,0
3160 data 4800,0,0,0,0,0,450,0
3170 data 5868,103,200,69,60,0,4553,8700
3180 data 5868,68,0,0,0,0,494,0
3190 data 1546,146,0,0,0,0,4800,0
3200 data 1546,802,141,140,840,0,8302,0
3210 data 2746,841,840,140,0,0,8302,4950
3220 data 3496,802,0,0,0,0,811,0
3230 data 3496,841,840,140,0,0,811,8302
3240 data 7366,822,820,240,400,0,5305,9300
3250 data 5861,503,0,0,0,0,2100,0
3260 data 8411,501,500,140,0,0,5459,7833
3270 data 192,742,400,0,0,0,8170,9600
3280 data 201,404,88,420,240,242,8170,8071
3290 data 201,404,89,120,0,0,8170,9600
3300 data 7530,404,245,0,0,0,2737,0
3310 data 7530,404,912,0,0,0,2738,0
3320 data 7530,404,89,80,740,420,5908,9300
3330 data 7530,404,88,80,740,120,5910,9300
3340 data 7671,0,0,0,0,0,6000,0
3350 data 4553,903,0,0,0,0,6300,0
3360 data 1350,0,0,0,0,0,6000,0
3370 data 1510,62,60,0,0,0,7800,0
3380 data 5860,63,0,0,0,0,18000,0
3390 data 201,404,88,420,0,0,8170,9600
3400 data 186,284,360,0,0,0,8170,9600
3410 data 1539,482,242,0,0,0,1800,0
3420 data 1539,482,480,0,0,0,7904,16800
3430 data 194,682,300,0,0,0,8170,9600
3440 data 174,149,464,140,0,0,8751,0
3450 data 174,160,0,0,0,0,8751,0
3460 data 7800,444,940,921,952,0,10548,8014
3470 data 7800,124,921,0,0,0,7350,0
3480 data 7800,424,992,980,921,0,10553,7264
3490 data 8250,104,0,0,0,0,10505,9600
3500 data 7800,464,148,1140,921,1152,10553,7264
3510 data 1541,643,640,0,0,0,7800,0
3520 data 163,104,40,0,0,0,8170,9600
3530 data 6300,44,0,0,0,0,15450,0
3540 data 4534,583,0,0,0,0,4650,0
3550 data 6187,702,541,0,0,0,2713,16050
3560 data 5887,702,0,0,0,0,2713,0
3570 data 5887,0,722,0,0,0,2100,0
3580 data 198,1022,480,0,0,0,8170,9600
3590 data 157,2,24,40,0,0,8170,9600
3600 data 1510,44,60,40,80,85,7801,10800
3610 data 1532,302,208,300,0,0,7800,0
3620 data 1532,302,209,0,0,0,2813,0
3630 data 1532,305,0,0,0,0,10518,7564
3640 data 8411,841,840,140,0,0,8922,0
3650 data 165,1122,500,0,0,0,8170,9600
3660 data 1392,0,0,0,0,0,6000,0
3670 data 6300,284,0,0,0,0,16350,0
3680 data 8582,0,0,0,0,0,17700,0
3690 data 7800,921,209,302,200,0,8700,0
3700 data 7950,0,0,0,0,0,2700,0
3710 data 5908,621,1143,1000,0,0,4553,0
3720 data 5266,0,0,0,0,0,1800,0
3730 data 6300,224,0,0,0,0,17517,17850
3740 data 1200,0,0,0,0,0,17100,0
3750 data 6300,124,0,0,0,0,16350,0
3760 data 1050,208,1040,1060,0,0,10919,0
3770 data 6300,184,242,0,0,0,3600,0
3780 data 7800,921,160,140,0,0,7410,9000
3790 data 6300,0,0,0,0,0,450,0
3800 data aut,"go",*cli,*wal,"*run",*ent,*pac,"wai",say,sai
3810 data any,north,south,east,west,up,down,sta,pas,hal
3820 data "get",*tak,*cat,*pic,*rem,*wea,*pul,fly,dro,*rel
3830 data boo,bot,*rum,win,gam,mon,pir,aro,bag,*duf
3840 data *thr,*lea,*giv,dri,*eat,inv,sai,loo,*sho," "
3850 data "tor",off,mat,yoh,30,lum,rug,key,inv,dou
3860 data rea," ",yoh,sco,"sav",kil,*att,lig," ",ope
3870 data sai,fis,anc,sha,pla,cav,pat,doo,che,par
3880 data *sma,unl,hel,awa,*bun," ",qui,bui,*mak,wak
3890 data ham,nai,boa,*shi,she,cra,wat,*sal,lag,*tid
3900 data set,cas,dig,bur,fin,jum,emp,wei," "," "
3910 data pit,sho,*bea,map,pac,bon,hol,san,box,sne
3920 data 0,0,0,0,0,0," "
3930 data 0,0,0,0,0,0,london apartment
3940 data 0,0,0,0,0,1,"*I'M IN AN alcove"
3950 data 0,0,4,2,0,0,secret passageway
3960 data 0,0,0,3,0,0,musty attic
3970 data0,0,0,0,0,0,*i'm outside an open window on a ledge of a tall building
3980 data 0,0,8,0,0,0,sandy beach on a tropical isle
3990 data 0,12,13,14,0,11,maze of caves
4000 data 0,0,14,6,0,0,meadow
4010 data 0,0,0,8,0,0,grass shack
4020 data 10,24,10,10,0,0,*i'm in the ocean
4030 data 0,0,0,0,7,0,pit
4040 data 7,0,14,13,0,0,maze of caves
4050 data 7,14,12,19,0,0,maze of caves
4060 data 0,0,0,8,0,0,*i'm at the foot of cave-ridden hill.pathleads to top
4070 data 17,0,0,0,0,0,tool shed
4080 data 0,0,17,0,0,0,long hallway
4090 data 0,0,0,16,0,0,large cavern
4100 data 0,0,0,0,0,14,*i'm on top of a hill- below is pirates  island
4110 data 0,14,14,13,0,0,maze of caves
4120 data 0,0,0,0,0,0,*i'm aboard a pirate ship anchored off-  shore
4130 data 0,22,0,0,0,0,*i'm on the beach at treasure island
4140 data 21,0,23,0,0,0,spooky graveyard full of empty & broken rum bottles
4150 data 0,0,0,22,0,0,large barren field
4160 data10,6,6,6,0,0,shallow lagoon-to the north is the ocean
4170 data 0,0,0,23,0,0,sacked and deserted monastary
4180 data 0,0,0,0,0,0," "
4190 data 0,0,0,0,0,0," "
4200 data 0,0,0,0,0,0," "
4210 data 0,0,0,0,0,0," "
4220 data 0,0,0,0,0,0," "
4230 data 0,0,0,0,0,0," "
4240 data 0,0,0,0,0,0," "
4250 data 0,0,0,0,0,0,*welcome to never never land
4260 data" "
4270 data there's a strange sound
4280 data the name of the book is treasure island
4290 data nothing happens
4300 data there's something there. maybe i should
4310 data that's not very safe
4320 data you may need magic here
4330 data everything spins around and suddenly i'melsewhere...
4340 data torch is lit
4350 data i was wrong. i guess its not a mongoose cause the snakes bit it.
4360 data i'm snake bit
4370 data parrot attacks snakes and drives them   off
4380 data pirate won't let me
4390 data its locked
4400 data its open
4410 data there are a set of plans in it
4420 data not while i'm carrying it
4430 data crocs stop me
4440 data sorry i can't
4450 data wrong game you silly goose!
4460 data i don't have it
4470 data pirate grabs rum and scuttles off chort-ling
4480 data ...i think its me. hee hee.
4490 data its nailed to the floor!
4500 data -magic word-ho and a ...  (work on it.  you'll get it)
4510 data no. something is missing!
4520 data it was a tight squeeze!
4530 data something won't fit
4540 data since nothing is happening
4550 data i slipped and fell...
4560 data something falls out
4570 data"they're plans to build a ship-you'll    need hammer,nails,lumber"
4580 data i've no container
4590 data it soaks into the ground
4600 data too dry. fish vanish.
4610 data pirate awakens. says 'aye matey we be   casting off soon-he vanishes
4620 data what a waste...
4630 data i've no crew
4640 data pirate says 'aye matey-we be needing a  map first'
4650 data after a day at sea we anchor off a sandybeach. all ashore...
4660 data try 'weigh anchor'
4670 data there's a map in it
4680 data it's a map to treasure island. at bottomit says '30 paces and dig!'
4690 data"    *welcome to pirates adventure*"
4700 data its empty,i've no plans!,open it?,go there?,i found something!
4710 data i didn't find anything,i don't see it here,"ok,i walked 30 paces"
4720 data congratulations!!!  but your adventure  is not over yet...
4730 data reading expands the mind,the parrot crys,'check the bag matey'
4740 data'check the chest matey',from the other side!,open the book!
4750 data there's multiple exits here!,crocks eat fish and leave
4760 data i'm underwater.i can't swim. blub blub..
4770 data'pieces of eight',its stuck in the sand,use one word
4780 data pirate says'aye matey-we be waiting for the tide to come in'
4790 data the tide is out,the tide is coming in
4800 data about 60 pounds. try 'set sail','tides a changing matey'
4810 data note here 'i be liking parrots. they be smart matey'
4820 data pirate follows me ashore as if he is    waiting for something.
4830 data flight of stairs,1
4840 data open window,2,books in a bookcase,2,large leather-bound book/boo/,0
4850 data bookcase with secret passage behind it,0,pirate's duffel bag/bag/,4
4860 data sign on wall 'return treasures here-say score',1
4870 data empty bottle/bot/,0
4880 data unlit torch/tor/,4,lit torch/tor/,0,matches/mat/,0
4890 data small ship's keel and mast,6,wicked looking pirate,9
4900 data treasure chest/che/,9,mongoose/mon/,8,rusty anchor/anc/,24
4910 data grass shack,8,mean and hungry-looking crocodiles,11
4920 data locked door,11,open door with hall beyond,0,pile of sails/sai/,17
4930 data fish/fis/,10,*doubloons*/dou/,25,deadly mamba snakes/sna/,25
4940 data parrot/par/,9,bottle of rum/bot/,1,rug/rug/,0,ring of keys/key/,0
4950 data open treasure chest/che/,0,set of plans/pla/,0,rug,1
4960 data claw hammer/ham/,15,nails/nai/,0,pile of precut lumber/lum/,17
4970 data tool shed,17,locked door,16,open door with pit beyond,0
4980 data pirate ship,0,rock wall with narrow crack in it,18
4990 data narrow crack in the rock,17,salt water,10
5000 data sleeping pirate,0,bottle of salt water/bot/,0
5010 data pieces of broken rum bottles,4,non-skid sneakers/sne/,1,map/map/,0
5020 data shovel/sho/,15,mouldy old bones/bon/,0,sand/san/,6
5030 data bottles of rum/bot/,0,*rare old priceless stamps*/sta/,0,lagoon,6
5040 data the tide is out,24,the tide is coming in,0,water wings/win/,15
5050 data flotsam and jetsam,0
5060 data monastary,23
5070 data plain wooden box/box/,0
5080 data dead weasel,0," ",0," ",0
