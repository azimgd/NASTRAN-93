      SUBROUTINE PLOT (MODE,BUF1,B1,SETID,DEFLST,NOFIND)        
C        
C     THIS PLOT ROUTINE IS CALLED ONLY BY PARAM        
C        
      EXTERNAL          ANDF        
      LOGICAL TAPBIT   ,STRESS   ,DISP        
      INTEGER ANDF     ,ANYDEF   ,AWRD(2)  ,BFRMS    ,B1       ,BUF1   ,
     1        BUFSIZ   ,CASECC   ,D1       ,D2       ,DEFBUF   ,DEFILE ,
     2        DEFID    ,DIRECT   ,DTYPE    ,DEFLST(2),EOR      ,ELSET  ,
     3        ERR(17)  ,GPSET    ,OES1     ,ORIGIN   ,FOR      ,PARM   ,
     4        PBUFSZ   ,PCON     ,PEDGE    ,PLABEL   ,PLTBUF   ,PLTNUM ,
     5        PLTTAP   ,PLTTYP   ,PORIG    ,PPEN     ,PRNT     ,PRJECT ,
     6        PSET     ,PSYMM    ,PSHAPE   ,PSYMBL   ,PVECTR   ,REW    ,
     7        SETID(1) ,SETD     ,SKPTTL   ,STEREO   ,SUBC(2)  ,SUBCAS ,
     8        TRA      ,WHERE    ,WORD     ,NAME(2)  ,SKPLOD   ,THLID  ,
     9        FSCALE   ,FVP      ,OFFSCL   ,ORG        
      INTEGER NF(2)    ,F1(10)   ,F2(20)   ,MSG1(19) ,MSG2(17) ,MF4(6) ,
     1        MSG7(13) ,MF3(3,3) ,USED(10)        
      INTEGER ALL      ,BOTH     ,CONTUR   ,DEFO     ,ELEM     ,EPID   ,
     1        KEYWD    ,GRID     ,GSPC     ,LAG(2)   ,MAGC(2)  ,TO     ,
     2        MF1(2,5) ,MF2(2,5) ,POIN     ,RANG     ,RQST(17) ,THRU   ,
     3        TIME        
      REAL    FRR(17)  ,MAXDEF        
      DOUBLE  PRECISION DWRD        
      CHARACTER         UFM*23   ,UWM*25        
      COMMON /XMSSG /   UFM      ,UWM        
CIBMI 6/93
      COMMON / PLTSCR / NCOR, PLTSC(50)
      COMMON /BLANK /   NGP      ,SKP11    ,NSETS    ,PRNT     ,PLTNUM ,
     1        NGPSET   ,ANYDEF   ,SKP12(3) ,PARM     ,GPSET    ,ELSET  ,
     2        CASECC   ,SKP21(3) ,DEFILE(3),MERR     ,SETD     ,SKP31  ,
     3        OES1        
      COMMON /SYSTEM/   BUFSIZ   ,NOUT     ,DUMMY(66),ISUBS        
      COMMON /OUTPUT/   TITLE(32,3)        
      COMMON /PLTDAT/   SKPPLT(20),SKPA(10),PLTTAP        
      COMMON /XXPARM/   PBUFSZ   ,CAMERA   ,BFRMS    ,SKPCAM(3),        
     1        PENPAP(30),SCALE(4),DEFMAX   ,VIEW(15) ,VANPNT(8),PRJECT ,
     2        PROJCT   ,FOR      ,ORG      ,NORG     ,ORIGIN(11),       
     3        SKPPAR(77),NCNTR   ,CNTR(50) ,ICNTVL   ,WHERE    ,DIRECT ,
     4        SUBCAS   ,FLAG     ,DATA     ,SKP19(19),ICOLOR   ,SKP235 ,
     5        OFFSCL        
      COMMON /DRWDAT/   PSET     ,PLABEL   ,PORIG    ,PPEN     ,PSHAPE ,
     1        PSYMBL(2),PSYMM(6) ,PVECTR   ,PCON     ,PEDGE    ,OFFLAG  
      COMMON /PLOTHD/   IUSED        
      EQUIVALENCE       (ERR(1),FRR(1))  , (WORD,AWRD(1),IWRD,FWRD,DWRD)
      EQUIVALENCE       (FSCALE,SCALE(3)), (FVP,VANPNT(1))        
CIBMI 6/93
      EQUIVALENCE       (SKP19(1), LASSET )
      DATA EOR , INPREW,NOREW,REW,SKPTTL,SKPLOD / 1000000,0,2,1,37,5 /  
      DATA SUBC/ 4HSUBC, 4HASES/        
      DATA NAME/ 4H  PL, 4HOT  /        
C        
      DATA NF  / 10, 20 /      ,        
     1     F1  / 4H(49X, 4H,4HP, 4HLOT,, 4HI9,2, 4HX,16, 4HHUND, 4HEFOR,
     2           4HMED , 4HSHAP, 4HE)   /       ,        
     3     F2  / 4H(10X, 4H,4HP, 4HLOT,, 4HI5,3, 4HX,2(, 4HA4,A, 4H3),I,
     4           4H6,10, 4HH - , 4HSUBC, 4HASE,, 4HI8,3, 4HH - , 4H,A4,,
     5           4H1P,E, 4H15.6, 4H,1X,, 4H6A4,, 4HE11., 4H3)  /        
C        
C     DATA FOR FORMAT F2 - ORDER CORRESPONDING TO DTYPE, +10=VEL,+20=ACC
C        
      DATA MF1 / 4HSTAT, 2HIC  , 4HFREQ, 1H.   , 4HTRAN,2HS.  ,        
     1           4HMODA, 1HL   , 4HCMOD, 2HAL  /       ,        
     2     MF2 / 4HDEFO, 3HRM. , 4HVELO, 1H.   , 4HACCE,2HL.  ,        
     3           4HSTRE, 2HSS  , 4HSTRA, 2HIN  /        
      DATA IMOD, LOAD  /         4HMODE, 4HLOAD/        
      DATA MF3 / 4H- FR, 4HEQUE, 4HNCY , 4H- EI, 4HGENV,4HALUE,        
     1           4H- TI, 2HME  , 1H    /       ,        
     2     MF4 / 4H PHA, 4HSE L, 4HAG  , 4H MAG, 4HNITU,2HDE  /        
C        
      DATA NMSG1,NMSG2,  NMSG7 / 19, 17, 13/   ,        
     1     MSG1/ 4H(33X, 4H,26H, 4HAN U, 4HNREC, 4HOGNI, 4HZABL, 4HE OP,
     2           4HTION, 4H (,2, 4HA4,3, 4H1H) , 4HWAS , 4HDETE, 4HCTED,
     3           4H ON , 4HA -P, 4HLOT-, 4H CAR, 4HD)  /       ,        
     4     MSG2/ 4H(34X, 4H,21H, 4HA NO, 4HN-EX, 4HISTE, 4HNT O, 4HRIGI,
     5           4HN,I7, 4H,31H, 4H  IS, 4H SPE, 4HCIFI, 4HED O, 4HN A ,
     6           4H-PLO, 4HT- C, 4HARD)/       ,        
     7     MSG7/ 4H(33X, 4H,41H, 4H*** , 4HINCO, 4HMPLE, 4HTE P, 4HLOT ,
     8           4HDUE , 4HTO I, 4HNPUT, 4H OR , 4HFILE, 4H.)  /        
C        
C     SET OPTIONS - FOLLOWING THE SET REQUEST(S)        
C        
      DATA RQST/ 4HSET , 4HORIG, 4HSHAP, 4HSYMB, 4HLABE, 4HVECT, 4HDENS,
     1           4HPEN , 4HSYMM, 4HANTI, 4HMAXI, 4HOUTL, 4HHIDD, 4HSHRI,
     2           4HNOFI, 4HFILL, 4HOFFS/        
C        
      DATA USED/ 4H(49X, 4H,6HO, 4HRIGI, 4HN,I7, 4H,19H, 4H  US, 4HED I,
     1           4HN TH, 4HIS P, 4HLOT)/        
C        
C     THE FOLLOWING ARE POSSIBLE OPTIONS ON THE PLOT CARD        
C        
      DATA DEFO/ 4HDEFO/, LORIG/ 0     /,        
     1     ALL / 3HALL /, TO   / 2HTO  /, THRU/ 4HTHRU/, RANG / 4HRANG/,
     2     TIME/ 4HTIME/, BOTH / 4HBOTH/, GRID/ 4HGRID/, POIN / 4HPOIN/,
     3     ELEM/ 4HELEM/, GSPC / 4HGSPC/, LAG / 4HPHAS , 4HLAG        /,
     4     MAGC/ 4HMAGN , 4HIT.        /, EPID/ 4HEPID/,CONTUR/ 4HCONT/ 
C        
CIBMNB 6/93
      NCNTR  = 10
      ICNTVL = 1
      WHERE  = 1
      LASSET = 0
      DIRECT = 2
      NCOR   = 50
      DO 1 I = 1, 50
      PLTSC(I) = 0
      CNTR(I)  = 0
1     CONTINUE
CIBMNE
      PLTBUF = B1 - PBUFSZ        
      DEFBUF = PLTBUF - BUFSIZ        
      IF (DEFBUF .LE. 0) GO TO 1400        
      V1     =-1.E+30        
      V2     =+1.E+30        
      PH     = 0.0        
      MAG    = 0        
      PCON   = 0        
      LOADID = 0        
      LPCON  = 0        
      FLAG   = 0.0        
      SUBCAS = 0        
      DEFID  = 0        
      DISP   =.FALSE.        
      STRESS =.FALSE.        
      TWOPI  = 8.0*ATAN(1.0)        
      NDEF   = 0        
      NOGO   = 0        
      CALL RDMODX (PARM,MODE,WORD)        
C        
   10 IF (MODE .LE. 0) CALL RDMODE (*10,*20,*40,MODE,WORD)        
   20 CALL RDWORD (MODE,WORD)        
C        
C     CHECK FOR A DEFORMATION TYPE        
C        
      DO 30 DTYPE = 1,5        
      IF (WORD .EQ. MF1(1,DTYPE)) GO TO 50        
   30 CONTINUE        
   40 DTYPE = 0        
      IF (WORD.NE.CONTUR .OR. MODE.GE.EOR) GO TO 180        
      PCON  = 1        
      PLTTYP= 1        
      GO TO 90        
C        
C     DEFORMATION TYPE SPECIFIED. CHECK IF ALL ARE TO BE PLOTTED        
C        
   50 PLTTYP = 1        
      IF (MODE .LE. 0) CALL RDMODE (*120,*60,*110,MODE,WORD)        
   60 CALL RDWORD (MODE,WORD)        
      DO 70 PLTTYP = 1,3        
      IF (WORD .EQ. MF2(1,PLTTYP)) GO TO 80        
   70 CONTINUE        
      PLTTYP = 1        
      IF (WORD .NE. CONTUR) GO TO 110        
      PCON = 1        
      GO TO 80        
C        
C     ACCEL, VELOCITY ONLY ALLOWED FOR TRANS OR FREQUENCY RESPONSE.     
C     NOTE THAT A COMPLEX  IGENVALUE WOULD BE NEEDED FOR -CMODAL-       
C        
   80 IF ((DTYPE.EQ.2 .OR. DTYPE.EQ.3) .OR. PLTTYP.EQ.1) GO TO 90       
      ERR(1) = 2        
      ERR(2) = AWRD(1)        
      ERR(3) = AWRD(2)        
      CALL WRTPRT (MERR,ERR,MSG1,NMSG1)        
      PLTTYP = 1        
   90 IF (MODE .LE. 0) CALL RDMODE (*120,*100,*110,MODE,WORD)        
  100 CALL RDWORD (MODE,WORD)        
  110 NDEF = 1        
      DEFLST(1) = ALL        
      GO TO 180        
C        
C     THE DEFORMATIONS MAY BE EXPLICITLY LISTED AND/OR A RANGE MAY BE   
C     LISTED (I.E., N1,N2 AND/OR N1 -TO/THRU- N2)        
C        
  120 ASSIGN 130 TO TRA        
      GO TO 1450        
  130 NDEF = NDEF + 1        
      DEFLST(NDEF) = IWRD        
      CALL RDMODE (*1450,*140,*170,MODE,WORD)        
  140 CALL RDWORD (MODE,WORD)        
      IF (MODE.NE.0 .OR. (WORD.NE.TO .AND. WORD.NE.THRU)) GO TO 170     
      ASSIGN 150 TO TRA        
      CALL RDMODE (*1450,*160,*170,MODE,WORD)        
  150 DEFLST(NDEF+1) = TO        
      DEFLST(NDEF+2) = IWRD        
      NDEF = NDEF + 2        
      CALL RDMODE (*120,*160,*170,MODE,WORD)        
  160 CALL RDWORD (MODE,WORD)        
  170 IF (NDEF.NE.1 .OR. DEFLST(1).NE.0) GO TO 180        
      NDEF = 2        
      DEFLST(2) = ALL        
C        
C     ALL THE LISTED DEFORMATION ID-S HAVE BEEN READ        
C        
  180 DEFLST(NDEF+1) = 0        
      IF (MODE .GE. EOR) GO TO 340        
C        
C     TEST FOR CONTOUR REQUEST        
C        
  190 IF (WORD .NE. CONTUR) GO TO 240        
      IF (PCON .EQ.      0) GO TO 220        
  200 ERR(2) = AWRD(1)        
      ERR(3) = AWRD(2)        
  210 ERR(1) = 2        
      CALL WRTPRT (MERR,ERR,MSG1,NMSG1)        
      GO TO 320        
C        
  220 PCON = 1        
      IF (DTYPE .EQ. 0) PLTTYP = 1        
      IF (NDEF  .NE. 1) GO TO 230        
      NDEF = 0        
      GO TO 90        
  230 IF (MODE .GT. 0) GO TO 320        
      ERR(2) = SUBC(1)        
      ERR(3) = SUBC(2)        
      GO TO 210        
C        
C     TEST FOR RANGE / TIME  (UNITS=LAMDA,F, OR TIME)        
C        
  240 IF (WORD.NE.RANG .AND. WORD.NE.TIME) GO TO 270        
      IF (PCON.EQ.0 .AND. DTYPE.EQ.1) GO TO 200        
      ASSIGN 250 TO TRA        
      IF (MODE .GT. 0) GO TO 200        
      CALL RDMODE (*1490,*330,*340,MODE,WORD)        
  250 V1 = FWRD        
      ASSIGN 260 TO TRA        
      CALL RDMODE (*1490,*330,*340,MODE,WORD)        
  260 V2 = FWRD        
      GO TO 320        
C        
C     TEST FOR PHASE LAG (COMPLEX DATA)        
C        
  270 IF (WORD .NE. LAG(1)) GO TO 310        
      IF (DTYPE.NE.2 .AND. DTYPE.NE.5) GO TO 200        
      ASSIGN 300 TO TRA        
  280 IF (MODE .LE. 0) CALL RDMODE (*1490,*290,*340,MODE,WORD)        
  290 CALL RDWORD (MODE,WORD)        
      IF (WORD .EQ. LAG(2)) GO TO 280        
      GO TO 340        
  300 IF (MAG.EQ.0) PH = FWRD        
      GO TO 320        
C        
C     TEST FOR MAGNITUDE (COMPLEX DATA)        
C        
  310 IF (WORD .NE. MAGC(1)) GO TO 340        
      IF (DTYPE.NE.2 .AND. DTYPE.NE.5) GO TO 200        
      IF (PH .EQ. 0.0) MAG = 1        
      GO TO 320        
C        
  320 IF (MODE .LE. 0) CALL RDMODE (*320,*330,*340,MODE,WORD)        
  330 CALL RDWORD (MODE,WORD)        
      GO TO 190        
C        
C     READ THE REST OF THE PLOT CARD INTO STORAGE - DEFLST(N1-N2)       
C        
  340 N1 = NDEF + 1        
      N2 = N1 + 1        
      IF (MODE .LT. EOR) GO TO 350        
      DEFLST(N2) = MODE        
      N2 = N2 + 1        
      GO TO 400        
  350 N  = 0        
  360 DEFLST(N2+1) = AWRD(1)        
      DEFLST(N2+2) = AWRD(2)        
      N2 = N2 + 2        
      N  = N  + 1        
      IF (MODE .EQ. 0) GO TO 370        
      CALL RDWORD (MODE,WORD)        
      GO TO 360        
  370 N2 = N2 + 1        
      DEFLST(N1+1) = N        
  380 CALL READ (*1520,*390,PARM,DEFLST(N2),DEFBUF-N2+1,0,N)        
      GO TO 1400        
  390 N2 = N2 + N        
C        
C     SAVE LENGTH OF OPEN CORE USED IN IUSED FOR HDPLOT        
C        
      IUSED = N2 + NSETS        
      IF (DEFLST(N2-1) .EQ. 0) GO TO 380        
  400 N2 = N2 - 1        
C        
C     INITIATE THE PLOTS OF THE REQUESTED DEFORMATIONS.        
C        
      NPLOTS = 0        
      IF (PRNT .LT. 0) GO TO 420        
      IF (DTYPE.EQ.0 .AND. PCON.EQ.0) GO TO 410        
      ANYDEF = 1        
      GO TO 1430        
C        
C     DO THE UNDEFORMED PLOT        
C        
  410 DEFID  = 0        
      DEFBUF = DEFBUF + BUFSIZ        
      IF (ISUBS.EQ.0 .AND. .NOT.TAPBIT(PLTTAP)) GO TO 1520        
      GO TO 700        
  420 IF (DTYPE.EQ.0 .AND. PCON.EQ.0) GO TO 1430        
C        
C     DO THE DEFORMED PLOT        
C        
C     STRESS IS TRUE IF CONTOUR REQUEST IS FOR STRESS        
C        
      LPCON = PCON        
      IF (.NOT.TAPBIT(PLTTAP)) GO TO 1520        
      IF (PCON.NE.0 .AND. ICNTVL.LE. 9) STRESS = .TRUE.        
      IF (PCON.NE.0 .AND. ICNTVL.GT.13) STRESS = .TRUE.        
      IF ((PCON.NE.0 .AND. (ICNTVL.GT.9.AND.ICNTVL.LT.14)) .OR.        
     1    DTYPE.NE.0) DISP = .TRUE.        
      IF (.NOT.DISP) GO TO 470        
      MDEF = DEFILE(1)        
      IF (DTYPE .GT. 1) MDEF = DEFILE(2)        
      IF (DTYPE .GT. 0) GO TO 460        
C        
C     USER SPECIFIED CONTOUR DISP AND NOT THE TYPE        
C     USE FIRST NON-NULL FILE        
C        
  430 CALL OPEN (*440,MDEF,DEFLST(DEFBUF),INPREW)        
      CALL SKPREC (MDEF,1)        
      GO TO 450        
  440 IF (MDEF .EQ. DEFILE(2)) CALL MESAGE (-1,MDEF,NAME)        
      MDEF = DEFILE(2)        
      GO TO 430        
C        
C     SET DTYPE BY MFILE        
C        
  450 CALL READ (*1390,*1390,MDEF,ERR(1),2,0,I)        
      MFILE = MOD(ERR(2),10)        
      DTYPE = MFILE        
      CALL CLOSE (MDEF,REW)        
  460 CONTINUE        
C        
C     CALCULATE HEADER WORD 2 NEEDED FOR PLOT FILE CHECK        
C        
      MFILE = DTYPE        
      IF (DTYPE .EQ. 3) MFILE = 3 + (PLTTYP-1)*10        
C        
C     OPEN OES1 AND MDEF        
C        
      IF (.NOT.DISP) GO TO 470        
      CALL OPEN (*1430,MDEF,DEFLST(DEFBUF),INPREW)        
      CALL SKPREC (MDEF,1)        
  470 IF (.NOT.STRESS) GO TO 500        
      CALL OPEN (*1390,OES1,DEFLST(B1),INPREW)        
      CALL SKPREC (OES1,1)        
      IF (.NOT.DISP) PLTTYP = 4        
      CALL FREAD  (OES1,I,1,0)        
      CALL BCKREC (OES1)        
      I = I/10        
      JAPP = I        
      IF (DTYPE .NE. 0) GO TO 475        
      IF (I.EQ.1 .OR. I.EQ.3 .OR. I.EQ.4 .OR. I.EQ.7 .OR. I.EQ.10)      
     1    DTYPE = 1        
      IF (I.EQ.2 .OR. I.EQ.8) DTYPE = 4        
      IF (I .EQ. 6) DTYPE = 3        
C        
C     FOR STRESS PLOTS SET -FLAG- SO FNDSET KNOWS WHICH WORD TO COMPARE 
C        
  475 IF (DTYPE .EQ. 1) GO TO 480        
      IF (DTYPE .GT. 1) FLAG = 1.0        
      IF (DTYPE .GT. 3) FLAG = 2.0        
  480 IF (DTYPE .EQ. 0) GO TO 1410        
      IF (.NOT.DISP) DEFBUF = DEFBUF + BUFSIZ        
C        
C     READ THE PLOT TITLES FOR EACH DEFORMED SHAPE TO BE DRAWN        
C        
  500 PCON = LPCON        
      IF (.NOT.DISP) GO TO 540        
  510 CALL READ  (*1385,*1385,MDEF,DEFID,1,0,I)        
      CALL FREAD (MDEF,N,1,0)        
      IF (N .EQ. MFILE) GO TO 515        
      CALL SKPREC (MDEF,1)        
      GO TO 530        
  515 CONTINUE        
      CALL FREAD (MDEF,LOADID,1,0)        
      CALL FREAD (MDEF,VALUE, 1,1)        
      IF (VALUE.LT.V1 .OR. VALUE.GT.V2) GO TO 530        
      DATA   = VALUE        
      SUBCAS = DEFID        
      N = 1        
  520 IF (DEFLST(N) .EQ. ALL) GO TO 540        
      CALL INTLST (DEFLST,N,I,D1,D2)        
      IF (DEFID.GE.D1 .AND. DEFID.LE.D2) GO TO 540        
      IF (N .LT. N1) GO TO 520        
  530 CALL SKPREC (MDEF,1)        
      GO TO 510        
C        
C     POSITION OES1 IF NEEDED        
C        
  540 IF (.NOT.STRESS) GO TO 660        
      IF (NPLOTS .NE. 0) CALL OPEN (*1390,OES1,DEFLST(B1),NOREW)        
  550 CALL READ (*1385,*1385,OES1,IAPP,1,0,I)        
C        
C     VERIFY OES1 IS FOR CURRENT DTYPE        
C        
      IAPP = IAPP/10        
      IF (IAPP .NE. JAPP) GO TO 1385        
      CALL FREAD (OES1,0,-2,0)        
      CALL FREAD (OES1,I,1,0)        
      IF (.NOT.DISP ) GO TO 570        
      IF (I.NE.DEFID) GO TO 620        
  570 SUBCAS = I        
      V = VALUE        
      CALL FREAD (OES1,ERR(1),4,0)        
      IF (DTYPE .EQ. 1) GO TO 575        
      IF (DTYPE .GE. 4) GO TO 580        
C        
C     TRANSIENT        
C        
      V = FRR(1)        
C        
C     STATICS        
C        
  575 J = ERR(4)        
      GO TO 590        
C        
C     MODAL        
C        
  580 J = ERR(1)        
      V = FRR(2)        
      IF (DTYPE.EQ.4 .AND. IAPP.EQ.2) V = SQRT(ABS(V))/TWOPI        
  590 IF (.NOT.DISP) GO TO 600        
C        
C     ACCOUNT FOR ROUNDOFF        
C        
      IF (ABS(V-VALUE) .GT. 1.0E-6) GO TO 620        
      DATA = VALUE        
      GO TO 650        
  600 IF (V.LT.V1 .OR. V.GT.V2) GO TO 620        
      DATA = V        
      N = 1        
  610 IF (DEFLST(N) .EQ. ALL) GO TO 650        
      CALL INTLST (DEFLST,N,I,D1,D2)        
      IF (SUBCAS.GE.D1 .AND. SUBCAS.LE.D2) GO TO 650        
      IF (N .LT. N1) GO TO 610        
C        
C     WRONG CASE        
C        
  620 CALL FWDREC (*1410,OES1)        
      CALL FWDREC (*1410,OES1)        
      GO TO 550        
C        
C     LOCATED CASE TO PLOT        
C        
  650 CALL BCKREC (OES1)        
      LOADID = J        
      DEFID  = SUBCAS        
      VALUE  = DATA        
C        
  660 CALL GOPEN (CASECC,DEFLST(BUF1),INPREW)        
  670 CALL READ  (*690,*690,CASECC,N,1,0,I)        
      IF (N .EQ. DEFID) GO TO 675        
      CALL FREAD (CASECC,0,0,1)        
      GO TO 670        
  675 CALL FREAD (CASECC,0,-SKPLOD,0)        
      CALL FREAD (CASECC,THLID,1,0)        
      IF (LOADID .EQ. 0) LOADID = THLID        
      SKPTTL = 31        
      CALL FREAD (CASECC,0,-SKPTTL,0)        
      CALL FREAD (CASECC,TITLE,3*32,0)        
      CALL CLOSE (CASECC,REW)        
      GO TO 700        
  690 CALL CLOSE (CASECC,REW)        
      IF (.NOT.DISP) GO TO 550        
      CALL FREAD (MDEF,0,0,1)        
      GO TO 510        
C        
C     IDENTIFY THE PLOT        
C        
  700 PLTNUM = PLTNUM + 1        
      IF (STRESS) CALL CLOSE (OES1,NOREW)        
      CALL SOPEN (*1430,PLTTAP,DEFLST(PLTBUF),PBUFSZ)        
      NCNTR = -IABS(NCNTR)        
      IF (NPLOTS .EQ. 0) CALL PLTOPR        
      NPLOTS = NPLOTS + 1        
      STEREO = 0        
      MTYP   = 0        
      ERR(2) = PLTNUM        
      IF (.NOT.(DISP .OR. STRESS)) GO TO 720        
      ERR(3) = MF1(1,DTYPE)        
      ERR(4) = MF1(2,DTYPE)        
      IF (ICNTVL .EQ. 20) PLTTYP = 4        
      ERR(5) = MF2(1,PLTTYP)        
      ERR(6) = MF2(2,PLTTYP)        
      ERR(7) = DEFID        
      ERR(8) = LOADID        
      ERR(9) = LOAD        
      IF (DTYPE .NE. 1) GO TO 710        
      ERR(1) = 8        
      GO TO 730        
  710 ERR(1) = 12        
      IF (DTYPE .GT. 3) ERR(9) = IMOD        
      FRR(10) = VALUE        
      MTYP = 1        
      IF (DTYPE .EQ. 3) MTYP = 3        
      IF (DTYPE.EQ.4 .AND. LOADID.LT.0) MTYP = 2        
      IF (MTYP .EQ. 2) ERR(8) = -LOADID        
      ERR(11) = MF3(1,MTYP)        
      ERR(12) = MF3(2,MTYP)        
      ERR(13) = MF3(3,MTYP)        
      IF (DTYPE.EQ.3 .OR. DTYPE.EQ.4) GO TO 730        
      ERR(1) = 15        
      M = 0        
      IF (MAG .NE. 0) M = 3        
      ERR(14) = MF4(M+1)        
      ERR(15) = MF4(M+2)        
      ERR(16) = MF4(M+3)        
      IF (MAG .NE. 0) GO TO 730        
      ERR(1)  = 16        
      FRR(17) = PH        
      GO TO 730        
  720 ERR(1) = 1        
      CALL WRTPRT (MERR,ERR,F1,NF(1))        
      GO TO 740        
  730 CALL WRTPRT (MERR,ERR,F2,NF(2))        
  740 CALL STPLOT (PLTNUM)        
      CALL HEAD (DTYPE,PLTTYP,MTYP,ERR)        
C        
C     PLOT EACH SET REQUESTED. INTERPRET THE ASSOCIATED REQUESTS.       
C        
  750 CALL RDMODY (DEFLST(N1+1),MODE,WORD)        
      MODE   = 0        
      MAXDEF = 0.        
      PORIG  = 1        
      PPEN   = 1        
      PSET   = 0        
  760 PLABEL = -1        
      PCON   = LPCON        
      PSHAPE = 1        
      PVECTR = 0        
      OFFLAG = 0        
      PEDGE  = 0        
      PSYMBL(1) = 0        
      PSYMBL(2) = 0        
      PSYMM(1) = 1        
      PSYMM(2) = 1        
      PSYMM(3) = 1        
      PSYMM(4) = 1        
      PSYMM(5) = 1        
      PSYMM(6) = 1        
  780 IF (MODE .LE. 0) CALL RDMODE (*780,*790,*1180,MODE,WORD)        
  790 CALL RDWORD (MODE,WORD)        
C        
C     CHECK FOR THE KEYWORD. THIS MAY BE FOLLOWED BY QUALIFIERS        
C        
  800 CONTINUE        
      DO 802 KEYWD = 1,17        
      IF (WORD .EQ. RQST(KEYWD)) GO TO 804        
  802 CONTINUE        
      GO TO 1170        
  804 GO TO (1080, 910, 960, 990, 830,1060, 810, 810,1020,1020,        
     1        880,1140,1148,1142,1175, 805,1160), KEYWD        
C        
C             SET ORIG SHAP SYMB LABE VECT DENS  PEN SYMM ANTI        
C    1       MAXI OUTL HIDD SHRI NOFI FILL OFFS        
C        
C     FILL ELEMENTS BY SET HERE        
C     FILL PRESENTLY DOES NOT WORK TOGETHER WITH SHRINK AND HIDDEN      
C        
  805 PPEN  = PPEN + 31        
      PEDGE = 100        
      GO TO 780        
C        
C     DENSITY I, PEN I        
C        
  810 IF (MODE .NE. 0) GO TO 1170        
      ASSIGN 820 TO TRA        
      GO TO 1440        
  820 PPEN = IWRD        
      GO TO 780        
C        
C     LABEL GRID / ELEMENTS        
C        
  830 PLABEL = 0        
      IF (MODE .LE. 0) CALL RDMODE (*780,*840,*1180,MODE,WORD)        
  840 CALL RDWORD (MODE,WORD)        
      IF (WORD .EQ. BOTH) GO TO 870        
      IF (WORD .EQ. ELEM) GO TO 860        
      IF (WORD .NE. GRID) GO TO 872        
      IF (MODE .LE. 0) CALL RDMODE (*780,*850,*1180,MODE,WORD)        
  850 CALL RDWORD (MODE,WORD)        
      IF (WORD-POIN) 800,780,800        
  860 PLABEL = 3        
      GO TO 780        
  870 PLABEL = 6        
      GO TO 780        
  872 IF (WORD .EQ. GSPC) PLABEL = 1        
      IF (WORD .EQ. EPID) PLABEL = 4        
      IF (PLABEL .NE.  0) GO TO 780        
      GO TO 800        
C        
C     MAXIMUM DEFORMATION X.X        
C        
  880 CONTINUE        
      ASSIGN 900 TO TRA        
      IF (MODE .LE. 0) CALL RDMODE (*1490,*890,*1180,MODE,WORD)        
  890 CALL RDWORD (MODE,WORD)        
      IF (WORD.NE.DEFO .OR. MODE.NE.0) GO TO 800        
      GO TO 1480        
  900 MAXDEF = ABS(FWRD)        
      GO TO 780        
C        
C     ORIGIN I        
C        
  910 IF (MODE .NE. 0) GO TO 1170        
      ASSIGN 920 TO TRA        
      GO TO 1440        
  920 DO 930 I = 1,ORG        
      IF (ORIGIN(I) .EQ. IWRD) GO TO 940        
  930 CONTINUE        
      IF (STEREO .NE. 0) GO TO 780        
      ERR(1) = 1        
      ERR(2) = IWRD        
      CALL WRTPRT (MERR,ERR,MSG2,NMSG2)        
      GO TO 780        
  940 PORIG  = I        
      GO TO 780        
C        
C     SHAPE        
C        
  960 IF (PEDGE .NE. 0) GO TO 1170        
      IF ((.NOT.(DISP .OR. STRESS) .AND. DTYPE .NE. 0)) GO TO 1170      
      IF (.NOT.DISP) GO TO 780        
      PSHAPE = 2        
      DO 970 I = 1,NDEF        
      IF (DEFLST(I) .EQ. 0) GO TO 980        
  970 CONTINUE        
      GO TO 780        
  980 PSHAPE = 3        
      GO TO 780        
C        
C     SYMBOL I,I        
C        
  990 PSYMBL(1) = 1        
      IF (MODE .NE. 0) GO TO 1170        
      ASSIGN 1010 TO TRA        
      I = 0        
 1000 I = I + 1        
      GO TO 1440        
 1010 PSYMBL(I) = IWRD        
      IF (I-2) 1000,780,780        
C        
C     SYMMETRY B / ANTISYMMETRY B        
C        
 1020 N = 1        
      IF (KEYWD .EQ. 10) N = -1        
      IF (MODE  .LE.  0) GO TO 1170        
      CALL RDWORD (MODE,WORD)        
      CALL INTVEC (WORD)        
      IF (WORD.LT.1 .OR. WORD.GT.7) GO TO 1170        
      DO 1050 I = 1,3        
      PSYMM(I) = 1        
      IF (ANDF(WORD,2**(I-1)) .NE. 0) PSYMM(I) = -1        
      PSYMM(I+3) = N*PSYMM(I)        
 1050 CONTINUE        
      GO TO 780        
C        
C     VECTOR B        
C        
 1060 IF (.NOT.DISP .OR. MODE .EQ. 0) GO TO 1170        
      CALL RDWORD (MODE,WORD)        
      PVECTR = WORD        
      GO TO 780        
C        
C     SET -  SAVE FIRST ENCOUNTERED, DO PLOT WHEN EOR OR ANOTHER SET    
C        
 1080 IF (MODE .NE. 0) GO TO 1170        
      ASSIGN 1090 TO TRA        
      GO TO 1440        
 1090 IWRD = IABS(IWRD)        
      DO 1100 I = SETD,NSETS        
      IF (IWRD .EQ. SETID(I)) GO TO 1120        
 1100 CONTINUE        
      IF (STEREO .NE. 0) GO TO 1110        
      WRITE  (NOUT,1105) UFM,IWRD        
 1105 FORMAT (A23,' 700, SET',I9,' REQUESTED ON PLOT CARD HAS NOT BEEN',
     1       ' DEFINED.')        
      NOGO = 1        
 1110 IWRD = SETD        
      GO TO 1130        
 1120 IWRD = I        
 1130 IF (PSET .NE. 0) GO TO 1180        
      PSET = IWRD        
      GO TO 780        
C        
C     OUTLINE        
C        
 1140 IF (PSHAPE .NE. 1) GO TO 1170        
      IF (PCON   .EQ. 0) GO TO 780        
      PEDGE = 1        
      GO TO 1149        
C        
C     SHRINK        
C        
 1142 IF (PEDGE .NE. 2) PEDGE = 75        
      IF (PEDGE .EQ. 2) PEDGE = 75 + 200        
C                           SHRINK + HIDDEN        
C        
      IF (MODE .GT. 0) GO TO 780        
      CALL RDMODE (*1144,*1143,*1180,MODE,WORD)        
 1143 CALL RDWORD (MODE,WORD)        
      GO TO 1149        
 1144 IF (MODE.EQ.-2 .AND. FWRD.GT.0.0 .AND. FWRD.LE.1.0) GO TO 1147    
      WRITE  (NOUT,1145) UWM        
 1145 FORMAT (A25,', INPUT VALUE ERROR FOR SHRINK.  0.85 IS SUBSTITUED')
      IF (MODE .EQ. -1) WRITE (NOUT,1146) IWRD        
 1146 FORMAT (5X,'FOR INTEGER VALUE',I5)        
      FWRD = 0.85        
 1147 J = FWRD*100        
      IF (J .LT.  10) J =  10        
      IF (J .GT. 100) J = 100        
      IF (PEDGE .NE. 2) PEDGE = J        
      IF (PEDGE .EQ. 2) PEDGE = J + 200        
C                          SHRINK + HIDDEN        
C        
      GO TO 1149        
C        
C     HIDDEN        
C        
 1148 IF (PEDGE .LT. 10) PEDGE = 2        
      IF (PEDGE.GE.10 .AND. PEDGE.LE.100) PEDGE = 200 + PEDGE        
C                                              HIDDEN + SHRINK        
 1149 IF (.NOT.DISP) GO TO 780        
      DO 1150 I = 1,NDEF        
      IF (DEFLST(I) .EQ. 0) GO TO 1155        
 1150 CONTINUE        
      PSHAPE = 2        
      GO TO 780        
 1155 PSHAPE = 3        
      GO TO 780        
C        
C     OFFSET n        
C     TURN OFFSET PLOT ON  IF n IS .GE. 0. +n IS MAGNIFYING FACTOR      
C     TURN OFFSET PLOT OFF IF n IS .LT. 0        
C        
C        
 1160 IF (MODE .NE. 0) GO TO 1170        
      ASSIGN 1165 TO TRA        
      GO TO 1440        
 1165 OFFSCL = IWRD        
      IF (OFFSCL .GE. 0) PEDGE = 3        
      GO TO 780        
C        
C     UNRECOGNIZABLE OPTION ON THE -PLOT- CARD.        
C        
 1170 IF (STEREO .NE. 0) GO TO 780        
      ERR(1) = 2        
      ERR(2) = AWRD(1)        
      ERR(3) = AWRD(2)        
      CALL WRTPRT (MERR,ERR,MSG1,NMSG1)        
      GO TO 780        
C        
C     NOFIND        
C        
C     COMMENTS FROM G.CHAN/UNISYS  11/1990        
C     THE 'NOFIND' FEATURE IN NASTRAN PLOTTING COMMANDS IS REALLY NOT   
C     NEEDED. IT ONLY LIMITS TO PREVIOUS PLOT CASE. THE FOLLOWING TWO   
C     EXAMPLES GIVE EXACTLY THE SAME RESULT IN $ PLOT 2        
C        
C     $ PLOT 1                           $ PLOT 1        
C     FIND SCALE, ORIGIN 100, SET 2      FIND SCALE, ORIGIN 100, SET 2  
C     PLOT ORIGIN 100                    PLOT ORIGIN 100        
C     $ PLOT 2                           $ PLOT 2        
C     PLOT ORIGIN 100                    PLOT NOFIND        
C       :        
C     (NOTE - ORIGIN 100 IS STILL AVAILABLE        
C      IN ANY FOLLOWING PLOT)        
C     $ PLOT N        
C     PLOT ORIGIN 100        
C        
 1175 NOFIND = +1        
      IF (LORIG .EQ. 0) GO TO 1530        
      PORIG  = LORIG        
      GO TO 780        
C        
C        
 1180 IF (NOFIND .GE. 0) GO TO 1185        
      IF (FSCALE.NE.0 .OR. FOR.NE.0) GO TO 1182        
      IF (PRJECT.EQ.1 .OR. FVP.EQ.0) GO TO 1185        
 1182 FORG  = 1        
      FSCALE= 1        
      ISETD = SETD        
      SETD  = MAX0(SETD,PSET)        
      MODEX = MODE        
      MODE  = -1        
      ORG   = MAX0(1,ORG)        
      CALL FIND (MODE,BUF1,B1,SETID,DEFLST)        
      NOFIND= +1        
      SETD  = ISETD        
      MODE  = MODEX        
C        
C     PLOT THIS SET        
C        
 1185 IF (.NOT.DISP) GO TO 1210        
      IF (PVECTR.NE.0 .OR. PSHAPE.NE.1 .OR. PEDGE.NE.0) GO TO 1210      
      IF (PCON.NE.0 .AND. ICNTVL.GT. 9) GO TO 1210        
      IF (PCON.NE.0 .AND. ICNTVL.GT.13) GO TO 1210        
C        
C     CREATE A DEFAULT OF SHAPE OR SHAPE + UNDERLAY        
C        
      DO 1190 I = 1,NDEF        
      IF (DEFLST(I) .EQ. 0) GO TO 1200        
 1190 CONTINUE        
      PSHAPE = 2        
      GO TO 1210        
 1200 PSHAPE = 3        
 1210 PSET = MAX0(PSET,SETD)        
C        
C     DEFAULT OF FIRST DEFINED SET WILL BE USED        
C        
      CALL GOPEN  (GPSET,DEFLST(B1),INPREW)        
      CALL SKPREC (GPSET,PSET)        
      CALL FREAD  (GPSET,NGPSET,1,0)        
C        
C     TEST FOR CORE NEEDED FOR BOTH UNDEF, DEFOR PLOTS, GRID INDEX      
C        
      I1 = N2 + NGP + 1        
C        
C     UNDEFORMED COORDINATES        
C        
      I2 = I1 + 3*NGPSET        
C        
C     DEFORMATION VALUES        
C        
      I3 = I2 + 3*NGPSET        
C        
C     REDUCE CORE FOR UNDEFORMED PLOTS        
C        
      IF (DISP) GO TO 1230        
      I3 = I2        
      N  = 0        
      GO TO 1240        
C        
C     DEFORMED PLOTS NEED X-Y LOCATIONS OF RESULTANT DEFLECTIONS ON     
C     FRAME        
C        
 1230 N = 2*NGPSET        
C        
 1240 IF (I3+N-1 .GE. DEFBUF) GO TO 1400        
      IUSED = MAX0(I3+N-1,IUSED+NGP)        
C        
      CALL FREAD (GPSET,DEFLST(N2+1),NGP,0)        
      CALL CLOSE (GPSET,REW)        
      CALL FNDSET (DEFLST(N2+1),DEFLST(I1),BUF1-N2,0)        
C        
      CALL GOPEN (ELSET,DEFLST(B1),INPREW)        
      IF (PSET .EQ. 1) GO TO 1280        
      CALL SKPREC (ELSET,PSET-1)        
C        
 1280 IF (.NOT.STRESS) GO TO 1290        
      IF (ICNTVL.LT.4 .OR. DIRECT.NE.2) GO TO 1290        
      I = B1 + BUFSIZ        
      CALL CLOSE (PARM,NOREW)        
      CALL GOPEN (OES1,DEFLST(I),NOREW)        
C        
      CALL ROTAT (ELSET,BUF1-N2,DEFLST(N2+1),DEFLST(I1))        
C        
      CALL CLOSE (OES1,NOREW)        
      CALL GOPEN (PARM,DEFLST(I),NOREW)        
C        
 1290 IF (.NOT.DISP) GO TO 1320        
C        
C     CONVERSION FOR ACCEL OR VELOCITY        
C        
      CONV = 1.0        
      IF (PLTTYP .EQ. 1) GO TO 1310        
      IF (PLTTYP.EQ.3 .OR. PLTTYP.EQ.4) GO TO 1300        
C        
C     VELOCITY        
C        
      CONV = VALUE*TWOPI        
      GO TO 1310        
C        
C     ACCEL        
C        
 1300 CONV = (VALUE*TWOPI)**2        
 1310 I = 3*BUFSIZ + B1        
      PH1 = PH * TWOPI/360.0        
      CALL GETDEF (MDEF,PH1,MAG,CONV,PLTTYP,DEFLST(I),DEFLST(N2+1),     
     1             DEFLST(I2))        
C                  FILE PH  MAG   W   RESP   BUF(1)     GPLST        
C                  DEFLECTION        
C        
C     PRINT THE MAXIMUM FOUND ON THE PLOT FILE        
C        
      IF (MODE.GE.EOR .AND. ICOLOR.EQ.0) CALL HEAD (0,0,-1,DEFMAX)      
      ASSIGN 1320 TO INCOM        
      IF (MAXDEF .NE. 0.0) DEFMAX = MAXDEF        
      IF (DEFMAX.EQ.0.0 .OR. SCALE(4).EQ.0.0) GO TO 1420        
C        
C                GPLST       ,X         ,U         ,S         ,        
 1320 CALL DRAW (DEFLST(N2+1),DEFLST(I1),DEFLST(I2),DEFLST(I3),        
     1           DISP,STEREO,DEFBUF-(I3+N),BUF1-N2)        
C        
C     NOTE - THE NEXT TO LAST ARGUMENT, DEFBUF-(I3+N), IS THE SIZE OF   
C            AVAILABLE OPEN CORE. IT IS NOT A POINTER, AND IT IS NOT AN 
C            OPEN CORE ARRAY        
C        
C     OPEN CORE /ZZPLOT/        
C     SETID NSETS NDOF      NGP 3*NGPSET 3*NGPSET SCRATCH  N        
C     -----+-----+----+----+---+--------+--------+-------+--+--+-+-+-+-+
C          !          N1   N2  I1 (X)   I2 (U)   I3 (S)   DEFBUF ..BUF..
C          !(DEFLST)         /        
C                       (GPLST)                      N=2*NGPSET        
C        
      CALL CLOSE (ELSET,REW)        
      IF (MODE .GE. EOR) GO TO 1360        
      IF (.NOT.DISP) GO TO 1350        
      CALL BCKREC (MDEF)        
 1350 PSET = IWRD        
      IF (.NOT.STRESS) GO TO 760        
C        
C     POSITION OES1        
C        
      I = 1        
      ASSIGN 1360 TO INCOM        
      CALL FNDSET (DEFLST(N2+1),DEFLST(I1),BUF1-N2,I)        
      IF (I .EQ. 1) GO TO 760        
      GO TO 1420        
C        
C     END OF A DEFORMATION        
C        
 1360 CALL STPLOT (-1)        
      IF (PRJECT.NE.3 .OR. STEREO.NE.0) GO TO 1380        
      STEREO = 1        
      CALL SOPEN (*1430,PLTTAP,DEFLST(PLTBUF),PBUFSZ)        
      J = BFRMS        
      BFRMS = 2        
      CALL STPLOT (PLTNUM)        
      BFRMS  = J        
      PLTNUM = PLTNUM + 1        
      IF (.NOT.DISP) GO TO 1370        
      CALL BCKREC (MDEF)        
 1370 IF (.NOT.STRESS) GO TO 750        
C        
C     POSITION OES1        
C        
      I = 1        
      ASSIGN 1360 TO INCOM        
      CALL FNDSET (DEFLST(N2+1),DEFLST(I1),BUF1-N2,I)        
      IF (I .NE. 1) GO TO 1420        
      GO TO 750        
 1380 IF (DISP .OR. STRESS) GO TO 500        
C        
C     END OF THIS PLOT CARD.        
C        
 1385 IF (STRESS) CALL CLOSE (OES1,REW)        
 1390 IF (DISP  ) CALL CLOSE (MDEF,REW)        
      GO TO 1430        
C        
C     INSUFFICIENT CORE TO START PROCESSING        
C        
 1400 CALL MESAGE (-8,DEFBUF,NAME)        
C        
 1410 CONTINUE        
      GO TO 1385        
C        
C     INCOMPLETE PLOT RESULTED        
C        
 1420 ERR(1) = 0        
      CALL WRTPRT (MERR,ERR,MSG7,NMSG7)        
      GO TO INCOM, (1360,1320)        
C        
C     FINISHING ONE PLOT        
C     ECHO OUT WHICH ORIGIN WAS USED        
C        
 1430 IF (NOGO  .NE. 0) CALL MESAGE (-61,0,0)        
      IF (PORIG .EQ. 0) GO TO 1550        
      ERR(1) = 1        
      ERR(2) = ORIGIN(PORIG)        
      CALL WRTPRT (MERR,ERR,USED,10)        
      CALL WRITE (MERR,0,0,1)        
      LORIG = PORIG        
      PORIG = 0        
      GO TO 1550        
C        
C     READ AN INTEGER VALUE FROM THE -PLOT- CARD        
C        
 1440 CALL RDMODE (*1450,*790,*1180,MODE,WORD)        
 1450 IF (MODE .EQ. -1) GO TO 1470        
      IF (MODE .EQ. -4) GO TO 1460        
      IWRD = FWRD        
      GO TO 1470        
 1460 IWRD = DWRD        
 1470 GO TO TRA, (130,150,820,920,1010,1090,1165)        
C        
C     READ A REAL VALUE FROM THE -PLOT- CARD        
C        
 1480 CALL RDMODE (*1490,*790,*1180,MODE,WORD)        
 1490 IF (MODE .EQ. -4) GO TO 1500        
      IF (MODE .EQ. -1) FWRD = IWRD        
      GO TO 1510        
 1500 FWRD = DWRD        
 1510 GO TO TRA, (250,260,900,300)        
C        
 1520 WRITE  (NOUT,1525) UFM,PLTTAP        
 1525 FORMAT (A23,' 702, PLOT FILE ',A4,' DOES NOT EXIST.')        
      NOGO = 1        
      GO TO 1390        
 1530 WRITE  (NOUT,1535) UWM,LORIG        
 1535 FORMAT (A25,' 704, NO PREVIOUS PLOT TO INITIATE NOFIND OPERATION')
C        
 1550 RETURN        
      END        
