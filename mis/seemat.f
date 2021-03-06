      SUBROUTINE SEEMAT        
C        
C     SUBROUTINE SEEMAT IS THE DMAP DRIVER FOR UTILITY MODULE SEEMAT    
C     WHOSE DMAP CALL FOLLOWS        
C        
C     SEEMAT    A,B,C,D,E//C,N,PRINT(PLOT)/V,N,PFILE/C,N,FSIZE/        
C                          C,N,MODIDA/C,N,MODELA/C,N,PAPERX/C,N,PAPERY  
C        
C     INPUT DATA BLOCKS  - A,B,C,D,E ARE MATRICES, ANY OF WHICH MAY BE  
C                          PURGED.        
C        
C     OUTPUT DATA BLOCKS - NONE        
C        
C     PARAMETERS        
C       1. BCD, -PRINT- MEANS USE SYSTEM PRINTER (DEFAULT).        
C               -PLOT- MEANS USE SPECIFIED PLOTTER.        
C       2. INTEGER, PLOT COUNTER (INPUT + OUTPUT).        
C       3. INTEGER, FRAME SIZE = NUMBER OF CHARACTERS TO BE TYPED       
C                   IN AN ASSUMED SQUARE FRAME (DEFAULT=100).        
C       4. BCD, MODEL ID (DEFAULT=M).        
C       5. INTEGER, MODEL NUMBER (DEFAULT=1).        
C       6. REAL, X DIMENSION OF PLOT FRAME (DEFAULT=0.0).        
C       7. REAL, Y DIMENSION OF PLOT FRAME (DEFAULT=0.0).        
C      NOTE - PARAMETERS 2-7 ARE USED ONLY IF PARAMETER 1 = -PLOT-.     
C        
      EXTERNAL        ANDF,ORF        
      LOGICAL         TABLE,SQ,PLOTIT,PRNTIT,TAPBIT,NOBITS        
      INTEGER         NAME(5),GOBAC,BLANK,XSTAR,XDOLR,XDDDD,SEEMT(2),   
     1                A,B,C,IT(7),SYSBUF,EOL,EOR,IRO(10),IX(1),LBL(2),  
     2                ANDF,ORF,KPP(2),PLUS,BCOR,SYMBL(2),MODID(2),      
     3                TTL1(9),TTL2(4),TTL3(4),TTL4(3),LIN(25),        
     4                PP,PFILE,FSIZE,PLTTER,PLTYPE,PLOTER,PLTBUF,TWO    
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25,SWM*27,SIM*31        
      COMMON /XMSSG / UFM,UWM,UIM,SFM,SWM,SIM        
      COMMON /SYSTEM/ SYSBUF,NOUT,JAZZ1(6),NLINES,JAZZ2(2),LNCT,        
     1                JAZZ3(26),NBPC,NBPW,NCPW        
      COMMON /BLANK / PP(2),PFILE,FSIZE,MODIDA(2),MODELA,PAPERX,PAPERY  
CZZ   COMMON /ZZSEEM/ X(1)        
      COMMON /ZZZZZZ/ X(1)        
      COMMON /ZNTPKX/ Z(4),IZ,EOL,EOR        
      COMMON /PLTDAT/ MODEL,PLTTER,REGION(4),AXMAX,AYMAX,EDGE(12),      
     1                SKPA(9),PLTYPE,PLOTER        
      COMMON /XXPARM/ PLTBUF,KAMRAN,NBLFM,SKPARM(4),PAPSIZ(2)        
      COMMON /TWO   / TWO(32)        
      EQUIVALENCE     (X(1),IX(1)),(IRO(1),ICOL1),(IRO(2),IBLCU1),      
     1                (IRO(3),IBLCU2),(IRO(4),JBLCU1),(IRO(5),JBLCU2),  
     2                (IRO(6),A,IPIJ1),(IRO(7),B,IPIJ2),(IRO(8),C),     
     3                (IT(1),NAM ),(IT(2),NCOLS),(IT(3),NROWS),        
     4                (IT(5),ITYP)        
      DATA    NAME  , SEEMT /101,102,103,104,105,4HSEEM,4HAT   /        
      DATA    BLANK , NCC,XSTAR,XDOLR,XDDDD/1H ,100,1H*,1H$,1HD/        
      DATA    KPP   / 4HPLOT,4H    /        
      DATA    PLUS  / 4H+   /        
      DATA    TTL1  / 4HSEEM,4HAT D,4HISPL,4HAY O,4HF MA,4HTRIX,        
     1                4H DAT,4HA BL,4HOCK /        
      DATA    TTL2  / 4HNO. ,4HCOLU,4HMNS ,4H=   /        
      DATA    TTL3  / 4HNO. ,4H  RO,4HWS  ,4H=   /        
      DATA    TTL4  / 4H(TRA,4HNSPO,4HSED)/        
C        
      NCC    = 100        
      PLOTIT =.FALSE.        
      PRNTIT =.TRUE.        
      NLNXX  = NLINES        
      IF (PP(1).NE.KPP(1) .OR. PP(2).NE.KPP(2)) GO TO 20        
      PLOTIT =.TRUE.        
      PRNTIT =.FALSE.        
      TABLE  =.FALSE.        
      NCC    = FSIZE        
      FNCC   = NCC        
      NLNXX  = NCC        
   20 LCOR   = KORSZ(X) - SYSBUF        
C        
      NCC1   = NCC/4        
      NCC5   = NCC - 5        
      LBLK   = (NCC*NLNXX-1)/32 + 3        
      IF (PRNTIT) GO TO 90        
C        
C     INITIALIZE PLOTTER        
C        
      MODID(1) = MODIDA(1)        
      MODID(2) = MODELA        
      CALL FNDPLT (PLTTER,MODEL,MODID)        
      PAPSIZ(1) = PAPERX        
      PAPSIZ(2) = PAPERY        
      KAMRAN = 3        
      NBLKFM = 0        
      CALL PLTSET        
      LCOR = LCOR - PLTBUF        
      KCOR = LCOR + SYSBUF + 1        
      IF (LCOR .LE. 0) CALL MESAGE (-8,SQ,SEEMT)        
      BCOR = LCOR - NCC1        
      IF (TAPBIT(PLOTER)) GO TO 70        
      WRITE  (NOUT,65) UWM,PLOTER        
   65 FORMAT (A25,' 1704, PLOT FILE -',A4,'- NOT SET UP')        
      GO TO 9999        
   70 IF (IABS(PLTYPE).NE.1) TABLE = .TRUE.        
      REGION(3) = AMIN1(AXMAX,AYMAX)        
      REGION(4) = REGION(3)        
      AXMAX = REGION(3)        
      AYMAX = REGION(4)        
      CALL MAPSET (0,0,1.01*FNCC,1.01*FNCC,0,0,AXMAX,AYMAX,2)        
      CALL MAP (0.005*FNCC,0.005*FNCC,BLLX,BLLY)        
      CALL MAP (1.005*FNCC,0.005*FNCC,BLRX,BLRY)        
      CALL MAP (1.005*FNCC,1.005*FNCC,BURX,BURY)        
      CALL MAP (0.005*FNCC,1.005*FNCC,BULX,BULY)        
      GO TO 90        
   85 CALL MESAGE (-1,PLOTER,SEEMT)        
   90 CONTINUE        
C        
      DO 9998 III = 1,5        
C        
      NAM = NAME(III)        
      CALL RDTRL (IT)        
      IF (NAM .LE. 0) GO TO 9998        
      CALL GOPEN (NAM,X(LCOR+1),0)        
      CALL FNAME (NAM,LBL)        
      SQ = .TRUE.        
      IF (NCOLS .NE. NROWS) SQ = .FALSE.        
      NBLKS = 0        
      NCOL1 = 0        
      IJMAX = MAX0(NCOLS,NROWS)        
      NROWS1= NROWS + 1        
      IF (PRNTIT) GO TO 95        
      IF (TABLE ) GO TO 92        
      PFILE = PFILE + 1        
      CALL SOPEN (*85,PLOTER,X(KCOR),PLTBUF)        
      CALL STPLOT (PFILE)        
      CALL MAP   (0.23*FNCC,0.50*FNCC,XXXX,YYYY)        
      CALL PRINT (XXXX,YYYY,1,TTL1,9,-1)        
      CALL PRINT (XXXX,YYYY,1,TTL1,9, 0)        
      CALL MAP   (0.60*FNCC,0.50*FNCC,XXXX,YYYY)        
      CALL PRINT (XXXX,YYYY,1,LBL,2,0)        
      CALL MAP   (0.75*FNCC,0.50*FNCC,XXXX,YYYY)        
      CALL PRINT (XXXX,YYYY,1,TTL4,3,0)        
      CALL MAP   (0.40*FNCC,0.40*FNCC,XXXX,YYYY)        
      CALL PRINT (XXXX,YYYY,1,TTL3,4,0)        
      CALL MAP   (0.40*FNCC,0.30*FNCC,XXXX,YYYY)        
      CALL PRINT (XXXX,YYYY,1,TTL2,4,0)        
      CALL MAP   (0.55*FNCC,0.40*FNCC,XXXX,YYYY)        
      CALL TYPINT (XXXX,YYYY,1,NROWS,0, 0)        
      CALL MAP   (0.55*FNCC,0.30*FNCC,XXXX,YYYY)        
      CALL TYPINT (XXXX,YYYY,1,NCOLS,0, 0)        
      CALL LINE (BLLX,BLLY,BULX,BULY,1,-1)        
      CALL LINE (BLLX,BLLY,BULX,BULY,1, 0)        
      CALL LINE (BULX,BULY,BURX,BURY,1, 0)        
      CALL LINE (BURX,BURY,BLRX,BLRY,1, 0)        
      CALL LINE (BLRX,BLRY,BLLX,BLLY,1, 0)        
      CALL STPLOT (-1)        
   92 CALL PAGE1        
      LNCT = LNCT + 5        
      WRITE  (NOUT,93) LBL(1),LBL(2),NCOLS,NROWS        
   93 FORMAT (//5X,'SEEMAT PLOT FOR TRANSPOSE OF', /22X,'MATRIX DATA ', 
     1       'BLOCK ',2A4,11X,'PLOT FILE ','    R','     C', /10X,      
     2       'SIZE =',I6,' ROWS BY',I6,' COLUMNS')        
      IF (TABLE) GO TO 95        
      WRITE  (NOUT,94) PFILE        
   94 FORMAT (1H0,62X,I5,2X,12HHEADER FRAME)        
   95 CONTINUE        
C        
C        
C     LOOP ON COLUMNS OF MATRIX        
C        
      NCOL = 1        
  100 CONTINUE        
      CALL INTPK (*2100,NAM,0,ITYP,0)        
C        
C     IF COLUMN IS NULL, RETURN FROM INTPK IS TO STATEMENT 2100        
C     ITY IS TYPE OF ELEMENT STORED IN Z, NOT USED IN THIS PROGRAM      
C     BLOCK IS DUMMY ENTRY NOT USED BY INTPK        
C        
C     LOOP ON ROWS OF MATRIX        
C        
      NROW = 1        
  200 CONTINUE        
      IF (EOL .NE. 0) GO TO 2100        
C        
C     READ ELEMENT OF MATRIX INTO /ZNTPKX/        
C        
      CALL ZNTPKI        
C        
C     COMPUTE BLOCK ID IN WHICH ELEMENT BELONGS        
C        
C     LOOK AT CURRENT BLOCK FIRST        
C        
      IF (NBLKS .LE. 0) GO TO 1045        
      IF (NCOL.LE.JBLCU1 .OR. NCOL.GT.JBLCU2 .OR. IZ.LE.IBLCU1 .OR.     
     1    IZ.GT.IBLCU2) GO TO 1020        
      NBLK = NBLCUR        
      GO TO 1050        
C        
C     SEARCH ALL BLOCKS TO FIND OLD ONE IN WHICH ELEMENT LIES        
C        
 1020 DO 1040 I2 = 1,NBLKS        
      IP  = LBLK*(I2-1) + 1        
      IP1 = IP + 2        
      IBLCU1 = IX(IP)        
      IBLCU2 = IBLCU1 + NCC        
      JBLCU1 = IX(IP+1)        
      JBLCU2 = JBLCU1 + NLNXX        
      IF (NCOL.LE.JBLCU1 .OR. NCOL.GT.JBLCU2 .OR. IZ.LE.IBLCU1 .OR.     
     1    IZ.GT.IBLCU2) GO TO 1040        
      NBLK = I2        
      GO TO 1050        
 1040 CONTINUE        
 1045 NBLK = -1        
 1050 IF (NBLK .GT. 0) GO TO 1100        
C        
C     SET UP NEW BLOCK IF THERE IS ROOM FOR IT IN CORE        
C        
      NBLKS1 = NBLKS + 1        
      IF (LBLK*NBLKS1 .LE. LCOR) GO TO 1070        
      WRITE  (NOUT,1060) SWM,NBLKS1        
 1060 FORMAT (A27,' 1701, AVAILABLE CORE EXCEEDED BY',I10,' LINE IMAGE',
     1       ' BLOCKS.')        
      NBLKS  = -1        
      GO TO 9960        
C        
C     SET BLOCK POINTERS AND BLANK OUT LINE IMAGE        
C        
 1070 IP  = LBLK*NBLKS + 1        
      IP1 = IP + 2        
      IP2 = IP + LBLK - 1        
      DO 1071 I = IP1,IP2        
 1071 IX(I) = 0        
      DO 1074 IJM = 1,IJMAX        
      IF (IJM*NCC .LT. IZ) GO TO 1074        
      IX(IP) = NCC*(IJM-1)        
      GO TO 1075        
 1074 CONTINUE        
      KERROR = 1074        
      GO TO 9950        
 1075 DO 1079 IJM = 1,IJMAX        
      IF (IJM*NLNXX .LT. NCOL) GO TO 1079        
      IX(IP+1) = NLNXX*(IJM-1)        
      GO TO 1080        
 1079 CONTINUE        
      KERROR = 1079        
      GO TO 9950        
 1080 IBLCU1 = IX(IP)        
      IBLCU2 = IBLCU1 + NCC        
      JBLCU1 = IX(IP+1)        
      JBLCU2 = JBLCU1 + NLNXX        
      NBLKS  = NBLKS1        
      NBLCUR = NBLKS        
      IF (NBLKS .LE. 0) GO TO 9997        
C        
C     INSERT BIT INTO PACKED LINE IMAGE BLOCK        
C        
 1100 A = NCC*(NCOL-IX(IP+1)-1) + (IZ-IX(IP))        
      B = (A-1)/32        
      C = IP1 + B        
      B = A - 32*B        
      IX(C) = ORF(IX(C),TWO(B))        
C        
C     END OF LOOP ON ROWS        
C        
      NROW = NROW + 1        
      IF (NROW .LE. NROWS1) GO TO 200        
      KERROR = 2000        
      GO TO 9950        
 2100 IF (NCOL-NCOL1 .LT. NLNXX) GO TO 3000        
C        
C     OUTPUT GROUP OF LINE IMAGE BLOCKS        
C        
      ASSIGN 2200 TO GOBAC        
      GO TO 9500        
 2200 NBLKS = 0        
      NCOL1 = NCOL1 + NLNXX        
C        
C     END OF LOOP ON COLUMNS        
C        
 3000 NCOL = NCOL + 1        
      IF (NCOL .LE. NCOLS) GO TO 100        
C        
C     OUTPUT RESIDUAL LINE IMAGE BLOCKS        
C        
      ASSIGN 3050 TO GOBAC        
      GO TO 9500        
 3050 NBLKS = 0        
      GO TO 9997        
C        
C     OUTPUT GROUP OF LINE IMAGE BLOCKS        
C        
 9500 CONTINUE        
      IF (NBLKS .LE. 0) GO TO 9699        
      DO 9650 I = 1,NBLKS        
      IP = LBLK*(I-1) + 1        
      IF (PRNTIT) CALL PAGE1        
      I1 = IX(IP)        
      J100 = I1 + NCC        
      DO 9510 IJ = 1,10        
 9510 IRO(IJ) = I1 + 10*IJ        
      IF (PRNTIT) WRITE (NOUT,9520) (IRO(IJ),IJ=1,10)        
 9520 FORMAT (13H0TRANSPOSE OF,9X,8HCOLUMN..,10I10)        
      IF (PRNTIT) WRITE (NOUT,9530) LBL(1),LBL(2)        
 9530 FORMAT (8H MATRIX ,2A4,7X,3HROW,4X,10(9X,1H.),        
     1        /23X,3H...,4X,100(1H.)/24X,1H.)        
      ICOL1 = IX(IP+1)        
      I100  = ICOL1 + NLNXX        
      IP1   = IP - NCC1 + 1        
      IF (PRNTIT) GO TO 9535        
      PFILE = PFILE + 1        
      CALL SOPEN (*85,PLOTER,X(KCOR),PLTBUF)        
      CALL STPLOT (PFILE)        
      CALL TIPE (XXXX,YYYY,1,PLUS,1,-1)        
      IPAK  = (NCC+99)/100        
      IJA   = 5*IPAK        
      IJB   = NCC - IJA        
      FNCCY = 1.005*FNCC        
      DO 9531 IJ = IJA,IJB,IJA        
      FIJ = FLOAT(IJ)        
      CALL MAP (FIJ,FNCCY,XXXX,YYYY)        
 9531 CALL TIPE (XXXX,YYYY,1,PLUS,1,0)        
      FNCCX = 1.005*FNCC        
      DO 9532 IJ = IJA,IJB,IJA        
      FIJ = FNCC - FLOAT(IJ)        
      CALL MAP (FNCCX,FIJ,XXXX,YYYY)        
 9532 CALL TIPE (XXXX,YYYY,1,PLUS,1,0)        
      FNCCY = 0.005*FNCC        
      DO 9533 IJ = IJA,IJB,IJA        
      FIJ = FNCC - FLOAT(IJ)        
      CALL MAP (FIJ,FNCCY,XXXX,YYYY)        
 9533 CALL TIPE (XXXX,YYYY,1,PLUS,1,0)        
      FNCCX = 0.005*FNCC        
      DO 9534 IJ = IJA,IJB,IJA        
      FIJ = FLOAT(IJ)        
      CALL MAP (FNCCX,FIJ,XXXX,YYYY)        
 9534 CALL TIPE (XXXX,YYYY,1,PLUS,1,0)        
 9535 DO 9600 IJ = 1,NLNXX        
      IP1   = IP1 + NCC1        
      IPIJ1 = IP1 + 1        
      IPIJ2 = IP1 + NCC1        
      IB    = NCC*(IJ-1)        
      IW    = IB/32        
      IB    = IB - 32*IW        
      IW    = IW + IP + 2        
      NOBITS= .TRUE.        
      IF (PLOTIT) GO TO 9570        
      DO 9536 JJ = 1,NCC1        
 9536 LIN(JJ) = BLANK        
      DO 9540 JJ = 1,NCC        
      IB = IB + 1        
      IF (IB .LE. 32) GO TO 9537        
      IB = 1        
      IW = IW + 1        
 9537 IF (ANDF(IX(IW),TWO(IB)).EQ.0) GO TO 9540        
      NOBITS = .FALSE.        
      B   = (JJ-1)/4 + 1        
      C   = JJ - 4*(B-1)        
      IXX = XSTAR        
      IF (IX(IP+1)+IJ.EQ.NCOLS .OR. IX(IP)+JJ.EQ.NROWS) IXX = XDOLR     
      IF (SQ .AND. IX(IP+1)+IJ.EQ.IX(IP)+JJ) IXX = XDDDD        
      LIN(B) = KHRFN1(LIN(B),C,IXX,1)        
 9540 CONTINUE        
      IF (NOBITS) GO TO 9560        
      IF (MOD(IJ,5) .EQ. 0) GO TO 9550        
      WRITE  (NOUT,9545) (LIN(JJ),JJ=1,NCC1)        
 9545 FORMAT (28X,2H. ,25A4)        
      GO TO 9600        
 9550 ICOL1 = ICOL1 + 5        
      WRITE  (NOUT,9555) ICOL1,(LIN(JJ),JJ=1,NCC1)        
 9555 FORMAT (16X,I10,4H .. ,25A4)        
      GO TO 9600        
 9560 IF (MOD(IJ,5) .EQ. 0) GO TO 9565        
      WRITE (NOUT,9545)        
      GO TO 9600        
 9565 ICOL1 = ICOL1 + 5        
      WRITE (NOUT,9555) ICOL1        
      GO TO 9600        
 9570 FIJ = 101.0 - FLOAT(IJ)        
      DO 9580 JJ = 1,NCC        
      IB = IB + 1        
      IF (IB .LE. 32) GO TO 9577        
      IB = 1        
      IW = IW + 1        
 9577 IF (ANDF(IX(IW),TWO(IB)) .EQ. 0) GO TO 9580        
      NOBITS = .FALSE.        
      FJJ = FLOAT(JJ)        
      CALL MAP (FJJ,FIJ,XXXX,YYYY)        
      IF (SQ .AND. IX(IP+1)+IJ.EQ.IX(IP)+JJ) GO TO 9579        
      IF (IX(IP+1)+IJ.EQ.NCOLS .OR. IX(IP)+JJ.EQ.NROWS) GO TO 9578      
      CALL TIPE (XXXX,YYYY,1,XSTAR,1,0)        
      GO TO 9580        
 9578 CALL TIPE (XXXX,YYYY,1,XDOLR,1,0)        
      GO TO 9580        
 9579 CALL TIPE (XXXX,YYYY,1,XDDDD,1,0)        
 9580 CONTINUE        
 9600 CONTINUE        
      IF (PRNTIT) WRITE (NOUT,9640)        
 9640 FORMAT (1H0,29X,100(1H.)/30X,10(9X,1H.))        
      IF (PRNTIT) GO TO 9650        
      CALL STPLOT (-1)        
      LNCT = LNCT + 1        
      IF (LNCT .GT. NLINES) CALL PAGE1        
      WRITE  (NOUT,9645) PFILE,I100,J100        
 9645 FORMAT (1H ,62X,I5,2I6)        
 9650 CONTINUE        
C        
 9699 GO TO GOBAC, (2200,3050)        
C        
 9950 WRITE  (NOUT,9952) SWM,KERROR        
 9952 FORMAT (A27,' 1705, LOGIC ERROR AT STATEMENT',I5,        
     1       ' IN SUBROUTINE SEEMAT.')        
 9960 WRITE  (NOUT,9962) SIM,LBL        
 9962 FORMAT (A31,' 1702, UTILITY MODULE SEEMAT WILL ABANDON ',        
     1       'PROCESSING DATA BLOCK ',2A4 )        
 9997 CALL CLOSE (NAM,1)        
      IF (PRNTIT) GO TO 9998        
      IF (TABLE ) GO TO 9998        
      PFILE = PFILE + 1        
      CALL SOPEN (*85,PLOTER,X(KCOR),PLTBUF)        
      CALL STPLOT (PFILE)        
      CALL LINE (BLLX,BLLY,BURX,BURY,1,-1)        
      CALL LINE (BLLX,BLLY,BURX,BURY,1, 0)        
      CALL LINE (BULX,BULY,BURX,BURY,1, 0)        
      CALL LINE (BULX,BULY,BLRX,BLRY,1, 0)        
      CALL LINE (BLRX,BLRY,BLLX,BLLY,1, 0)        
      CALL LINE (BLLX,BLLY,BULX,BULY,1, 0)        
      CALL LINE (BURX,BURY,BLRX,BLRY,1, 0)        
      SYMBL(1) = 3        
      SYMBL(2) = 6        
      CALL MAP (0.505*FNCC,0.505*FNCC,XXXX,YYYY)        
      CALL SYMBOL (XXXX,YYYY,SYMBL,-1)        
      CALL SYMBOL (XXXX,YYYY,SYMBL, 0)        
      CALL STPLOT (-1)        
      LNCT = LNCT + 1        
      WRITE  (NOUT,9996) PFILE        
 9996 FORMAT (63X,I5,2X,13HTRAILER FRAME)        
 9998 CONTINUE        
 9999 RETURN        
C        
      END        
