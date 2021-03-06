      SUBROUTINE FFREAD (*,CARD)        
C        
C     THIS ROUTINE READS INPUT CARDS IN FREE FIELD OR FIXED FIELD       
C     FORMATS.        
C        
C     IF READFILE COMMAND IS ENCOUNTERED, IT SWITCHE THE INPUT FILE TO  
C     THE ONE SPECIFIED BY READFILE UNTIL EOF IS REACHED. THEN IT       
C     SWITCHES BACK TO THE NORMAL CARD READER. NESTED READFILE IS       
C     ALLOWED.        
C        
C     IT ALSO PRINTS THE INPUT CARDS IF UNSORTED ECHO FLAG IS ONE       
C        
C     ALL INTEGERS, BCD, AND REAL NUMBERS ARE LEFT ADJUSTED BEFORE      
C     RETURNING TO THE CALLER, XSORT2        
C        
C     IN BULK DATA SECTION -        
C     ALL INTEGERS ARE LIMITED TO 8 DIGITS. REAL NUMBERS CAN BE UP TO 12
C     DIGITS IF INPUT VIA FREE-FIELD, OR UP TO 8 DIGITS IF FIXED-FIELD. 
C     ALL REAL NUMBER MUST HAVE A DECIMAL POINT.  10E-6 OR 1+7 ARE      
C     NOT ACCEPTABLE        
C        
C     THREE WORDS ARE ATTACHED TO THE END OF AN INPUT CARD TO BE USED   
C     FOR ALPHA-NUMERIC SORTING        
C        
      LOGICAL         FP,       STAR,     PCT,      NOTYET,   TWODOT    
      INTEGER         FFFLAG,   INFLAG,   NONE,     SCREEN,   PROM,     
     1                UNIVC(11),XSORT,    WASFF        
      INTEGER         IB,       IC,       IE,       IS,       IL,       
     1                IR,       ID,       IP,       IM,       IG,       
     2                IA,       IH,       PT,       SP,       AII,      
     3                A1,       DOT,      AT,       A(94)        
      CHARACTER*1     CB,       CC,       CE,       CS,       CL,       
     1                CR,       CD,       CP,       CM,       CG,       
     2                CA,       CH,       CT,       C1,       C(80),    
     3                CX(94),   TMP,      QMARK,    DOTC        
      CHARACTER*4     PROMPT,   ON,       OFF,      YES,      TEMP4,    
     1                ECHO        
      CHARACTER*5     A5,       SEQGP,    SEQEP        
      CHARACTER*8     CARD(10), BLANK,    A8(10),   A81,      CANCEL,   
     1                SAVE,     RDFL,     SKFL,     DEND,     DBGN,     
     2                TEMP,     FROM,     SPILL,    LIST,     HELP,     
     3                STOP,     SCALE8,   SCALE1,   NOPRT,    SLASH,    
     4                A8X(12)        
      CHARACTER*48    A48        
      COMMON /XREADX/ SCREEN,   LOOP,     KOUNT,    PROM,     NOTYET,   
     1                STAR,     PCT,      JC(9),    L(9),     RC(9),    
     2                F(9)        
      COMMON /QMARKQ/ QMARK,    TMP(8),   SPILL,    SAVE(10)        
      COMMON /XECHOX/ FFFLAG,   IECHOU,   IECHOS,   IECHOP,   XSORT,    
     1                WASFF,    NCARD,    DUM(2),   NOECHO        
      COMMON /XXREAD/ INFLAG,   INSAVE,   LOOP4,    IBMCDC,   IERR      
      COMMON /MACHIN/ MACH        
      COMMON /SYSTEM/ IBUF,     NOUT,     NOGO,     IN        
      EQUIVALENCE     (C(1),CX(1),A8(1),A8X(1),A5,A48,A81),  (KKF,FKK), 
     1                (TEMP4,TEMP,TMP(1)),(A1,A(1))        
C        
      DATA            NONE,     PROMPT,   ON,       OFF,      YES     / 
     1                4HNONE,   'PROM',   'ON, ',   'OFF,',   'YES,'  / 
      DATA            BLANK,    DEND,     DBGN,     FROM,     SLASH   / 
     1                '      ','$   END ','$   ...',' FROM-', '/    ' / 
      DATA            CT,       XXXX,     CANCEL,   LIST,     LOUT    / 
     1                '.',      4HXXXX,   'CANCEL', 'LIST',   3       / 
      DATA            RDFL,               SKFL,     DOTC,     ECHO    / 
     1                'READFILE',        'SKIPFILE','.',      'ECHO'  / 
      DATA            HELP,     IWO,      SCALE8,   SCALE1,   STOP    / 
     1                'HELP',   60,      'SCALE/8','SCALE/10','STOP'  / 
      DATA            A,        IB,       NOPRT,    SEQGP,    SEQEP   / 
     1                94*1H ,   0,       'NOPRINT,','SEQGP',  'SEQEP' / 
      DATA            CB , CC , CE , CS , CL , CR , CD , CP , CM , CG / 
     1                ' ', ',', '=', '*', '(', ')', '$', '+', '-', '%'/ 
      DATA            L12, L94/ 10, 80 /, CA, CH, AT / '/', '!', 2H@  / 
      DATA            UNIVC   / 4H*ADD,   4H,E  ,   8*4H    ,  4H .   / 
C        
C     THIS ROUTINE IS A PREPROCESSOR FOR THE XREAD ROUTINE IN NASTRAN   
C     WRITTEN BY G. CHAN/SPERRY,  APRIL 1985        
C        
C     FFFLAG IN /XECHOX/ MUST BE SET TO 1234 FOR FREE-FIELD INPUT.      
C     IECHOS IS SET TO -2 IN STAND-ALONE VERSION.        
C     MUST RESERVE 43 WORDS IN SEMINT FOR /XREADX/ IN ALL MACHINES.     
C        
C     FREE FIELD INPUT IS TRIGGERED BY THE PRESENCE OF COMMA (,) OR     
C     EQUAL SIGN (=) IN COLS. 1 THRU 10, AND AFTER BEGIN BULK CARD WAS  
C     READ.        
C        
C     FFREAD IS DESIGNED TO BE USER FRIENDLY -        
C     UNDER NO CIRCUMSTANCES SHOULD THE USER BE KICKED OUT OF THE       
C     COMPUTER DUE TO HIS OR HER STUPID INPUT ERROR(S).        
C        
C     DURING FREE-FIELD INPUT SESSION, FOUR CONTROL CARDS ARE ALLOWED - 
C        
C        ECHO  = SORT, UNSORT, BOTH, NONE, PUNCH, LINK1        
C        PROMPT= ON, OFF, YES    (YES = ON + GENERATED CARD ECHO)       
C        CANCEL= N, TO CANCEL N PREVIOUSLY GENERATED LINES        
C        LIST  =-N, TO   LIST N PREVIOUSLY GENERATED LINES        
C        (CANCEL AND LIST ARE AVAILABLE ONLY IN STAND-ALONE VERSION AND 
C         A SAVE FILE HAS BEEN REQUESTED)        
C        
C     WRITTEN BY G.CHAN/UNISYS ON A COLD DECEMBER MORNING, 1983        
C     REFERENCE - CHAN, G.C.: 'COSMIC/NASTRAN FREE-FIELD INPUT',        
C                 12TH NASTRAN USERS' COLLOQUIUM, MAY 1984        
C        
C     THIS ROUTINE WILL HANDLE COMPUTER WORD OF ANY SIZE, 32,36,60,64   
C     BITS, UPPER CASE AND LOWER CASE ASCII AND EBCDIT CHARACTER SETS.  
C        
C     VAX AND UNIX ONLY -        
C     (UNIVAC TOO, ONLY IF OPEN STATEMENT IS USED FOR LOGICAL UNIT 5)   
C     DURING FREE-FIELD SESSION, 94 COLUMNS, INSTEAD OF REGULARLY 80,   
C     ARE ALLOWED FOR AN INPUT CARD COMING FROM CARD READER OR READFILE 
C     (A MAXINUM OF 94 COLUMNS IS ALLOWED IN PRINT FORMAT 310)        
C        
C     THIS ROUTINE CALLS THE FOLLOWING SUPPORTING SUBROUTINES FOR BCD   
C     (LEFT ADJUSTED), INTEGER, AND F.P. NUMBER CONVERSION -        
C        
C        INT 2 K8  - DECODES INTEGER TO A8 CHAR.        
C        FP  2 K8  - DECODES F.P. NUMBER TO A8 CHAR.        
C        NK1 2 IF  - ENCODES N(A1) CHAR. TO INTEGER OR F.P. NUMBER      
C        NK1 2 K8  - ENCODES N(A1) CHARS. TO A A8 CHAR. WORD        
C        K8  2 INT - DECODES A8 CHAR. TO INTEGER        
C        K8  2 FP  - DECODES A8 CHAR. TO F.P. NUMBER        
C        UPCASE    - REPLACES ANY LOWER-CASE LETTER BY ITS UPPER CASE   
C        
C     THIS ROUTINE WILL ALSO HANDLE 'READFILE' AND 'SKIPFILE' CARDS.    
C     FILE NAME IS LIMITED UP TO 48 CHARACTERS,  8/91        
C        
C     THIS ROUTINE TRIES NOT TO USE SYSTEM ENCODE/DECODE FUNCTIONS,     
C     SHIFT, AND ANY NON-STANDARD CHARACTER FUNCTIONS.        
C        
C        
C     INPUT FILE LOGIC:        
C        
C     IN UNIVAC, INPUT CARDS ARE READ FROM CARD READER INFLAG, UNIT 5.  
C     ALL OTHER INPUT FILES, NESTED OR NOT, ARE DYNAMICALLY INSERTED IN-
C     TO INPUT STREAM (WITH THE E-O-F MARK STRIPPED OFF), AND READ INTO 
C     COMPUTER SYSTEM FROM UNIT 5 ALSO. IF AN E-O-F MARK ENCOUNTERED    
C     BEFORE ENDDATA CARD, IT IS FATAL. INFLAG=TWO=IN=5        
C        
C     IN ALL OTHER MACHINES, INPUT CARDS ARE READ FROM CARD READER      
C     INFLAG, UNIT 5. WHEN A READFILE CARD IS ENCOUNTERED, DATA ARE READ
C     INTO COMPUTER SYSTEM FROM UNIT INFLAG, WHICH BEGINS AT 60;        
C          INFLAG = IWO = 60 FOR THE FIRST FILE        
C          INFLAG = 61 FOR THE SECOND FILE        
C          INFLAG = 62 FOR THE THIRD  FILE, ETC.        
C     (NOTE, SINCE NASTRAN USES READFILE INTERNALLY TO READ RIGID FORMAT
C     FILE, NESTED READFILE IS NOT UNCOMMON)        
C     WHEN E-O-F IS ENCOUNTERED, CURRENT FILE IS CLOSED AND INFLAG IS   
C     DECREASE BY 1. INFLAG IS SET TO ZERO WHEN INFLAG .LE. IWO (END    
C     OF CURRENT NESTED FILE OPERATION). NEXT READFILE, NESTED OR NOT,  
C     IS ALLOWED.        
C        
C     ADD READFILE,NOPRINT OPTION.  2/2/1989        
C     LAST REVISED, 8/1989, IMPROVED EFFICIENCY BY REDUCING CHARACTER   
C     OPERATIONS (VERY IMPORTANT FOR CDC MACHINE)        
C     8/93, LIBERAL READFILE NOPRINT FORMATS:        
C           READFILE,NOPRINT  FILENAME        
C           READFILE,NOPRINT, FILENAME        
C           READFILE NOPRINT  FILENAME        
C           READFILE(NOPRINT) FILENAME        
C           (EMBEDDED BLANK, COMMA, BRACKETS, AND EQUAL-SIGN ALLOWED)   
C           READFILE = FILENAME        
C        
C     INITIALIZE THE FOLLOWING ITEMS SO THAT COMPILER WILL NOT COMPLAIN 
C        
      DATA   C1,I,II,JJ,KK / ' ', 4*0 /        
C        
      IF (MACH .LT. 5) GO TO 40        
      L12 = 12        
      L94 = 94        
   40 IF (IB .NE. 0) GO TO 50        
      CALL K2B (CB,IB,1)        
      CALL K2B (CC,IC,1)        
      CALL K2B (CE,IE,1)        
      CALL K2B (CS,IS,1)        
      CALL K2B (CL,IL,1)        
      CALL K2B (CR,IR,1)        
      CALL K2B (CD,ID,1)        
      CALL K2B (CP,IP,1)        
      CALL K2B (CM,IM,1)        
      CALL K2B (CG,IG,1)        
      CALL K2B (CA,IA,1)        
      CALL K2B (CH,IH,1)        
      CALL K2B (CT,PT,1)        
      CALL K2B (DOTC,DOT,1)        
      CALL KHRFN1 (UNIVC(1),1,AT,1)        
C        
 50   IF (KOUNT  .NE. 0) GO TO 300        
 60   IF (INFLAG .EQ. 0) IF (FFFLAG-1234) 80,200,80        
      READ (INFLAG,65,END=150) (A8X(J),J=1,L12)        
 65   FORMAT (11A8,A6)        
C     NCARD = NCARD + 1        
      IF (IECHOS .EQ. -2) WRITE (LOUT,65) A8X        
      IF (A81 .EQ. RDFL) GO TO 4500        
      IF (A81.EQ.SKFL .AND. A8(2).EQ.BLANK) GO TO 130        
      IF (FFFLAG .EQ. 1234) GO TO 240        
      DO 70 I = 1,10        
      CARD(I) = A8(I)        
 70   SAVE(I) = A8(I)        
      GO TO 2800        
C        
C     10A8 INPUT        
C        
 80   READ (IN,90,END=150) CARD        
 90   FORMAT (10A8)        
      NCARD = NCARD + 1        
      IF (IECHOS .EQ. -2) WRITE (LOUT,90) CARD        
      CALL UPCASE (CARD,80)        
C        
      IF (CARD(1).EQ.SKFL .AND. CARD(2).EQ.BLANK) GO TO 130        
      IF (CARD(1) .NE. RDFL) GO TO 2000        
      DO 120 I = 1,10        
 120  A8(I) = CARD(I)        
      CALL K2B (A8,A,80)        
      GO TO 350        
C        
C     IT IS A SKIPFILE CARD - TO SKIP TO THE END OF INPUT FILE        
C        
 130  IF (INFLAG .EQ. 0) GO TO 5200        
 140  READ (INFLAG,90,END=5100) CARD        
      GO TO 140        
C        
C     CLOSE FILE, AND SET INFLAG BACK TO ZERO, OR PREVIOUS FILE OPENED  
C        
 150  IF (MACH .GE. 5) GO TO 154        
      GO TO (154,154,158,152), MACH        
C152  IF (INFLAG .EQ.   0) REWIND IN        
 152  IF (INFLAG .EQ.   0) RETURN 1        
      IF (INFLAG .GE. IWO) REWIND INFLAG        
      IERR = IERR + 1        
      IF (IERR-15) 156,156,3070        
 154  IF (INFLAG .EQ.   0) RETURN 1        
 156  CLOSE (UNIT=INFLAG)        
 158  INFLAG = INFLAG - 1        
      IF (INFLAG .LE. IWO) INFLAG = 0        
      CARD(1) = DEND        
      CARD(2) = RDFL        
      DO 160 J = 3,10        
 160  CARD(J) = BLANK        
      IF (IECHOS .EQ. -2) GO TO 60        
      CALL PAGE2 (-2)        
      NOECHO = NOECHO - 1        
      IF (NOECHO .GE. 0) WRITE (NOUT,165) NOECHO        
 165  FORMAT (12X,1H(,I4,' CARDS READ)')        
      WRITE  (NOUT,460) CARD        
      NOECHO = 0        
      GO TO 60        
C        
 170  LOOP  = 0        
      LOOP4 = LOOP - 4        
      KOUNT = 0        
      STAR  = .FALSE.        
      PCT   = .FALSE.        
      NOTYET= .FALSE.        
      DO 180 J = 1,9        
      L(J)  = 0        
 180  F(J)  = 0.0        
      IF (INFLAG-IWO) 200,60,60        
C        
C     FREE FIELD INPUT        
C        
 190  WRITE (NOUT,3020)        
      IERR = IERR + 1        
      IF (IERR .GT. 3) GO TO 3070        
      WRITE (SCREEN,3060) A8        
      IF (MACH.EQ.4 .AND. IN.EQ.5) REWIND IN        
 200  IF (PROM .NE. 0) WRITE (SCREEN,210)        
 210  FORMAT (7H ENTER )        
      READ   (IN,220,END=190) (CX(J),J=1,L94)        
 220  FORMAT (94A1)        
      NCARD = NCARD + 1        
      LASH  = 0        
 240  CALL UPCASE (CX,L94)        
      IF (IECHOS .EQ. -2) WRITE (LOUT,220) CX        
      CALL K2B (A8,A,L94)        
      IF (A1 .EQ. ID) GO TO 280        
C        
      IF (A81 .EQ. RDFL) GO TO 350        
      IF (A81.EQ.SKFL .AND. A8(2).EQ.BLANK) GO TO 130        
      IF (FFFLAG  .EQ. 1234) GO TO 260        
      DO 250 I = 1,10        
 250  CARD(I) = A8(I)        
      GO TO 2800        
 260  WASFF = +1        
      DO 270 I = 1,10        
      IF (A(I).EQ.IC .OR. A(I).EQ.IE) GO TO 300        
 270  CONTINUE        
 280  WASFF = -1        
      IF (IECHOU.EQ.0 .OR. XSORT.EQ.0) GO TO 288        
      CALL PAGE2 (-1)        
      WRITE  (NOUT,285) A        
 285  FORMAT (30X,94A1)        
 288  IF (A1 .EQ. ID) GO TO 60        
      J = 0        
      DO 290 I = 1,10        
      IF (A8(I) .NE. BLANK) J = 1        
 290  CARD(I) = A8(I)        
      LOOP  = -1        
      LOOP4 = LOOP - 4        
      IF (J.EQ.0 .AND. IECHOS.EQ.-2) GO TO 4700        
      GO TO 2000        
C        
 300  IF (IECHOS .EQ. -2) GO TO 340        
      IF (IECHOU.EQ.0 .OR. KOUNT.GE.1) GO TO 320        
      CALL PAGE2 (-1)        
      WRITE  (NOUT,310) A        
 310  FORMAT (30X,4H-FF-,4X,94A1)        
 320  IF (LOOP .EQ. -1) GO TO 340        
      DO 330 J = 1,10        
 330  CARD(J) = SAVE(J)        
 340  IF (KOUNT .NE. 0) GO TO 900        
 350  KE = 0        
      K  = 0        
      DO 380 J = 1,L94        
      AII = A(J)        
      IF (AII .NE. IB) GO TO 360        
      IF (KE  .EQ.  0) GO TO 380        
      IF (A(KE ).EQ.IC .OR. A(KE ).EQ.IL) GO TO 380        
      IF (A(J+1).EQ.IC .OR. A(J+1).EQ.IB) GO TO 380        
      IF (A(J+1).EQ.IR .AND.     K.EQ. 1) GO TO 370        
      AII = IC        
 360  IF (AII .EQ. ID) GO TO 390        
      KE = KE + 1        
      A(KE) = AII        
      C(KE) = C(J)        
      IF (AII .EQ. IC) C(KE) = CC        
      IF (AII .EQ. IL) K = K + 1        
      IF (AII .EQ. IR) K = K - 1        
      IF (K-1) 380,380,5000        
 370  K = 0        
 380  CONTINUE        
      IF (K  .GT. 0) GO TO 5000        
      IF (KE .EQ. 0) GO TO 4700        
 390  IF (A(KE) .EQ. IC) GO TO 400        
      KE = KE + 1        
      A(KE) = IC        
      C(KE) = CC        
 400  IF (A81 .NE. RDFL) GO TO 520        
C        
C     IT IS A READFILE CARD -        
C     CHECK NOPRINT OPTION, SET NOECHO = 1, IF FOUND.        
C     LOOK FOR FILE NAME. SET INFLAG TO UNIT IWO (OR IWO+ IF NESTED     
C     READFFILE), AND OPEN USERS FILE (NOT MEMBER OF A FILE AS IN IBM)  
C        
C     READFILE FORMAT - '(', ')', ',', AND '=' ARE IGNORED.        
C        
      NOECHO = 0        
      NOEC = 0        
      I    = 9        
 405  A(1) = IB        
      C(1) = CB        
      C(8) = CC        
      J = 0        
 410  I = I + 1        
      IF (I .GT. L94) GO TO 480        
      AII = A(I)        
      IF (AII .EQ. IB) GO TO 415        
      IF (AII.EQ.IL .OR. AII.EQ.IR .OR. AII.EQ.IC .OR. AII.EQ.IE)       
     1    IF (NOEC) 410,410,415        
      J = J + 1        
      IF (J .GT. 48) GO TO 480        
      A(J) = AII        
      C(J) = C(I)        
      IF (J.NE.7 .OR. A81.NE.NOPRT) GO TO 410        
      NOECHO = 1        
      NOEC = 1        
      GO TO 405        
 415  IF (J .EQ.  0) GO TO 410        
      IF (J .GE. 60) GO TO 422        
      J1 = J + 1        
      DO 420 I = J1,60        
      C(I) = CB        
 420  A(I) = IB        
C     J  = J - 1        
 422  IF (MACH .EQ. 3) GO TO 425        
      IF (INFLAG .LT. IWO) INFLAG = IWO - 1        
      INFLAG = INFLAG + 1        
      IF (IBMCDC.EQ.0) OPEN(UNIT=INFLAG,FILE=A8(1),STATUS='OLD',ERR=470)
      IF (IBMCDC.NE.0) OPEN(UNIT=INFLAG,FILE=A48  ,STATUS='OLD',ERR=470,
     1                      READONLY)        
C        
C     VAX - THE PARAMETER  'READONLY' IS NEEDED IF FILE PROTECTION IS   
C           SET FOR READ (=R) ONLY.        
C        
      IF (MACH .EQ. 4) REWIND INFLAG        
      GO TO 450        
C        
C     UNIVAC - USE SYSTEM FACSF ROUTINE, SO THAT IT CAN READ A FILE OR  
C              AN ELEMENT OF A FILE. INPUT UNIT IWO IS NOT USED        
C              MAKE SURE FILE NAME CONTAINS A DOT        
C        
 425  K = 0        
      DO 430 I = 1,48        
      IF (A(I) .EQ. DOT) GO TO 440        
      IF (A(I) .NE.  IB) K = 1        
      IF (K.EQ.1 .AND. A(I).EQ.IB) GO TO 435        
 430  CONTINUE        
      I = 49        
 435  A(I) = DOT        
 440  INFLAG = IN        
      IWO    = IN        
      READ (A48,445) (UNIVC(I),I=3,14)        
 445  FORMAT (12A4)        
      I = FACSF(UNIVC)        
      IF (I .NE. 0) GO TO 470        
C        
 450  CARD(1) = DBGN        
      CARD(2) = RDFL        
      CARD(3) = FROM        
      DO 455 J = 4,10        
 455  CARD(J) = A8(J-3)        
      IF (IECHOS .EQ. -2) GO TO 465        
      CALL PAGE2 (-1)        
      WRITE  (NOUT,460) CARD        
 460  FORMAT (5H0*** ,10A8)        
      GO TO 60        
 465  PROM = +1        
      GO TO 60        
C        
 470  WRITE  (NOUT,475) INFLAG,(A(I),I=1,J)        
 475  FORMAT (//,29H *** CAN NOT OPEN FILE (UNIT=,I3,4H) - ,48A1)       
      GO TO 500        
 480  J = J - 1        
      WRITE  (NOUT,485) (A(I),I=1,J)        
 485  FORMAT (//,23H *** FILE NAME ERROR - ,48A1)        
      IF (J .GE. 48) WRITE (NOUT,490)        
 490  FORMAT (5X,31HFILE NAME EXCEEDS 48 CHARACTERS)        
 500  NOGO = 1        
      IF (MACH.EQ.3 .OR. MACH.GE.5) WRITE (NOUT,505)        
 505  FORMAT (5X,38HSUGGESTION- CHECK USER ID OR QUALIFIER)        
      INFLAG = INFLAG - 1        
      IF (INFLAG .LE. IWO) INFLAG = 0        
      CARD(1) = BLANK        
      CARD(2) = BLANK        
C     GO TO 80        
      RETURN        
C        
C     HERE WE GO        
C        
 520  KK = 0        
      II = 0        
      JJ = 0        
      TWODOT = .FALSE.        
 530  IISAVE = JJ - 2        
 540  JJ = II + 1        
 550  II = II + 1        
      IF (II .GT. KE) GO TO 1500        
      AII = A(II)        
      IF (AII .EQ. IH) GO TO 540        
      IF (AII .EQ. IE) GO TO 700        
      IF (JJ  .GT.  1) GO TO 580        
      IF ((STAR .OR. PCT) .AND. LOOP.NE.-1) WRITE (NOUT,560)        
 560  FORMAT (' *** PREVIOUS CARD SETTING UP FOR DUPLICATION IS NOW ',  
     1        'ABANDONNED')        
      KOUNT = 0        
      LOOP  = 0        
      STAR  =.FALSE.        
      PCT   =.FALSE.        
      NOTYET=.FALSE.        
      DO 570 J = 1,9        
      L(J) = 0        
 570  F(J) = 0.0        
 580  IF (AII .EQ. IC) GO TO 600        
      IF (AII .EQ. IA) GO TO 650        
      IF (AII .EQ. IR) GO TO 1300        
      IF (AII.EQ.IS .OR. AII.EQ.IG) GO TO 1000        
      IF (AII .EQ. IL) GO TO 5400        
      GO TO 550        
C        
C ... COMMA (,):        
C        
 600  KK = KK + 1        
      IF (KK.EQ.1 .OR. KK.EQ.10) GO TO 620        
      JE = II - 1        
      IF (JE .LE. JJ) GO TO 620        
      I = 0        
      DO 610 J = JJ,JE        
      IF (A(J) .EQ. PT) I = I + 1        
 610  CONTINUE        
      IF (I .LE. 1) GO TO 620        
      IF (A5.NE.SEQGP .AND. A5.NE.SEQEP) GO TO 4400        
      TWODOT =.TRUE.        
      LOOP =-1        
 620  CALL NK12K8 (*3200,C(JJ),II-JJ,CARD(KK),1)        
      GO TO 530        
C        
C ... ECHO OR PROMPT:        
C        
 630  CALL NK12K8 (*3200,C(JJ),II-JJ,TEMP,1)        
      IF (TEMP.EQ.CANCEL .OR. TEMP.EQ.LIST) GO TO 1600        
      IF (TEMP4 .EQ.   ECHO) GO TO 4600        
      IF (TEMP4 .NE. PROMPT) GO TO 3000        
      CALL NK12K8 (*3200,C(II+1),4,TEMP,-1)        
      IF (TEMP4.NE.ON .AND. TEMP4.NE.OFF .AND. TEMP4.NE.YES) GO TO 3000 
      IF (TEMP4 .EQ. ON ) PROM =-1        
      IF (TEMP4 .EQ. OFF) PROM = 0        
      IF (TEMP4 .EQ. YES) PROM =+1        
      GO TO 60        
C        
C ... SLASH (/):        
C        
 650  IF (IISAVE .LE. 0) GO TO 660        
      A(II) = IH        
      C(II) = CH        
      II = II + 1        
      IF (A(II) .NE. IC) GO TO 655        
      A(II) = IH        
      C(II) = CH        
 655  II = IISAVE - 1        
      GO TO 540        
 660  IF (LASH.EQ.0 .AND. KK.EQ. 0) GO TO 680        
      J = KK + 1        
      WRITE  (NOUT,670) J        
 670  FORMAT (34H *** ILLEGAL USE OF SLASH IN FIELD,I3)        
      GO TO 540        
C        
C     A DELETE CARD (/) READ        
C        
 680  LASH = +1        
      GO TO 530        
C        
C ... EQUAL (=):        
C        
 700  IF (JJ .NE. II) GO TO 630        
      KK = KK + 1        
      II = II + 1        
      IF (II .GT. KE) GO TO 3600        
      AII = A(II)        
      IF (AII .EQ. IL) GO TO 750        
      IF (AII .EQ. IE) GO TO 730        
      IF (AII .EQ. IC) GO TO 530        
      GO TO 3600        
C        
 730  KK = 10        
      IF (TWODOT) GO TO 2400        
      IF (LOOP) 2000,2000,850        
C        
C ... DUPLICATE WITH INCREMENT, =(N):        
C        
 750  IF (KK .NE. 1) GO TO 3600        
      JJ = II + 1        
 800  II = II + 1        
      IF (II  .GT. KE) GO TO 3600        
      AII = A(II)        
      IF (AII .EQ. IR) GO TO 820        
      IF (AII.EQ.IC .OR. AII.EQ.IS .OR. AII.EQ.IE) GO TO 3000        
      GO TO 800        
 820  INT = 1        
      CALL NK12IF (*3800,C(JJ),II-JJ,LOOP,INT)        
      IF (LOOP .LE. 0) GO TO 4100        
      LOOP4 = LOOP - 4        
      II = II + 1        
      IF (II+1 .LT. KE) GO TO 530        
      IF (.NOT.STAR .AND. .NOT.PCT) GO TO 3300        
 850  KOUNT = 0        
      IF (.NOT.NOTYET) GO TO 900        
      NOTYET = .FALSE.        
      DO 880 KK = 2,9        
      IF (L(KK) .EQ. NONE) GO TO 860        
      IF (F(KK) .NE. XXXX) GO TO 870        
      F(KK) = 0.0        
      I = (L(KK)-JC(KK))/LOOP        
      IF (I*LOOP+JC(KK) .NE. L(KK)) GO TO 4200        
      L(KK) = I        
      GO TO 880        
 860  L(KK) = 0        
      F(KK) = (F(KK)-RC(KK))/FLOAT(LOOP)        
      GO TO 880        
 870  IF (L(KK) .NE.   0) JC(KK) = JC(KK) - L(KK)        
      IF (F(KK) .NE. 0.0) RC(KK) = RC(KK) - F(KK)        
 880  CONTINUE        
 900  KOUNT = KOUNT + 1        
      IF (KOUNT .GT. LOOP) GO TO 170        
      DO 950 KK = 2,9        
      IF (L(KK) .EQ. 0) GO TO 920        
      JC(KK) = JC(KK) + L(KK)        
      CALL INT2K8 (*3200,JC(KK),CARD(KK))        
      GO TO 950        
 920  IF (F(KK) .EQ. 0.0) GO TO 950        
      RC(KK) = RC(KK) + F(KK)        
      CALL FP2K8 (*3000,RC(KK),CARD(KK))        
 950  CONTINUE        
      IF (PROM.LT.0 .AND. KOUNT.EQ.LOOP) WRITE (SCREEN,970) LOOP,CARD   
 970  FORMAT (/,I5,' ADDITIONAL CARDS WERE GENERATED.  LAST CARD WAS-', 
     1        /1X,10A8)        
      GO TO 2000        
C        
C ... STAR (*), OR PERCENTAGE (%):        
C        
 1000 SP = AII        
      II = II + 1        
      IF (A(II) .NE. IL) GO TO 4000        
      JJ = II + 1        
      FP =.FALSE.        
      IF (STAR .OR. PCT) GO TO 1030        
      DO 1020 K = 1,9        
      L(K) = 0        
 1020 F(K) = 0.0        
 1030 IF (SP .EQ. IS) STAR =.TRUE.        
      IF (SP .EQ. IG) PCT  =.TRUE.        
 1050 II = II + 1        
      AII= A(II)        
      IF (II.GT.KE .OR. AII.EQ.IC) GO TO 4000        
      IF (AII .EQ. PT) FP =.TRUE.        
      IF (II.GT.JJ .AND. (AII.EQ.IP .OR. AII.EQ.IM)) FP =.TRUE.        
      IF (AII .NE. IR) GO TO 1050        
      IF (II  .LE. JJ) GO TO 4000        
      KK = KK + 1        
      IF (FP) GO TO 1070        
      INT = 1        
      CALL NK12IF (*3800,C(JJ),II-JJ,L(KK),INT)        
      CALL K82INT (*3100,SAVE(KK),8,JC(KK),INT)        
 1060 IF (SP  .EQ. IG) GO TO 1120        
      IF (LOOP .GT. 0) GO TO 1100        
      JC(KK) = JC(KK) + L(KK)        
      CALL INT2K8 (*3200,JC(KK),CARD(KK))        
      GO TO 1100        
 1070 INT =-1        
      CALL NK12IF (*3900,C(JJ),II-JJ,KKF,INT)        
      F(KK) = FKK        
      CALL K82FP  (*3100,SAVE(KK),8,RC(KK),INT)        
 1080 IF (SP  .EQ. IG) GO TO 1150        
      IF (LOOP .GT. 0) GO TO 1100        
      RC(KK) = RC(KK) + F(KK)        
      CALL FP2K8 (*3000,RC(KK),CARD(KK))        
 1100 II = II + 1        
      GO TO 530        
C        
 1120 IF (LOOP .GT. 0) GO TO 1130        
      F(KK) = XXXX        
      GO TO 1160        
 1130 I = (L(KK)-JC(KK))/LOOP        
      IF (I*LOOP+JC(KK) .NE. L(KK)) GO TO 4200        
      L(KK) = I        
      GO TO 1100        
 1150 IF (LOOP .GT. 0) GO TO 1180        
      L(KK)  = NONE        
 1160 NOTYET =.TRUE.        
      GO TO 1100        
 1180 F(KK) = (F(KK)-RC(KK))/FLOAT(LOOP)        
      GO TO 1100        
C        
C ... RIGHT BRACKET ):        
C        
 1300 IF (KK   .EQ.  0) GO TO 1450        
      IF (II+1 .GE. KE) GO TO 3400        
      AII = A(II+1)        
      IF (AII.EQ.IS .OR. AII.EQ.IE) GO TO 3400        
      J  = 10        
      INT= 1        
      IF (AII .NE. IP) CALL NK12IF (*3900,C(JJ),II-JJ,J,INT)        
      IF (J.LE.0 .OR. J.GT.10) GO TO 3700        
      IF (J .LE. KK) GO TO 1400        
      KK = KK + 1        
      DO 1350 K = KK,J        
 1350 CARD(K) = BLANK        
      KK = J        
 1400 IF (A(II+1) .EQ. IC) II = II + 1        
      JJ = II + 1        
 1420 II = II + 1        
      IF (II    .GT. KE) GO TO 1430        
      IF (A(II) .NE. IC) GO TO 1420        
 1430 CALL NK12K8 (*3000,C(JJ),II-JJ,CARD(J),1)        
      IF (KK .LT. 10) IF (II-KE) 530,1500,1500        
      GO TO 730        
 1450 KK = 1        
      CARD(KK) = SAVE(10)        
      II = II + 1        
      IF (II.GT.KE .OR. A(II).NE.IC) GO TO 3000        
      GO TO 530        
C        
C ... END OF CARD READ        
C        
 1500 IF (KK-10) 1550,730,3500        
 1550 KK = KK + 1        
      CARD(KK) = BLANK        
      IF (KK .LT. 10) GO TO 1550        
      GO TO 730        
C        
C ... CANCEL = N, LIST = +N        
C        
 1600 IF (IECHOS .NE. -2) GO TO 5300        
      CARD(1) = TEMP        
      JJ = II + 1        
 1650 II = II + 1        
      IF (A(II) .NE. IC) GO TO 1650        
      INT = 1        
      CALL NK12IF (*3800,C(JJ),II-JJ,JC(1),INT)        
      IF (TEMP.EQ.CANCEL .AND. JC(1).LE.0) GO TO 3800        
      IF (TEMP.EQ.  LIST .AND. JC(1).LE.0) GO TO 3800        
      CARD(3) = TEMP        
      GO TO 2800        
C        
C     PREPARE TO RETURN        
C        
 2000 IF (NOTYET) GO TO 60        
C        
C ... UPDATE CONTINUATION FIELDS IF WE ARE IN A DUPLICATION LOOP        
C        
      IF (LOOP .EQ. -1) GO TO 2400        
      IF (KOUNT.EQ.0 .AND. .NOT.STAR) GO TO 2400        
      KK = 10        
      IF (SAVE(KK) .EQ. BLANK) GO TO 2300        
 2100 TEMP = SAVE(KK)        
      IF (TMP(1) .NE. CP) GO TO 2300        
      JJ = 0        
      DO 2150 I = 3,8        
      IF (TMP(I) .EQ. CM) JJ = I        
      IF (TMP(I) .EQ. CB) GO TO 2200        
 2150 CONTINUE        
      I = 9        
 2200 IF (JJ .EQ. 0) GO TO 2300        
      INT = 1        
      CALL NK12IF (*4800,TMP(JJ+1),I-JJ-1,J,INT)        
      IF (MACH .EQ. 3) GO TO 2230        
      J = J + 1        
      CALL INT2K8 (*3800,J,TMP(JJ+1))        
      GO TO 2270        
C        
C ... UNIVAC USES NEXT 5 CARDS INSTEAD OF THE 3 ABOVE        
C        
 2230 CALL INT2K8 (*3800,J,SPILL)        
      J = 9 - JJ        
      DO 2250 I = 1,J        
      TMP(JJ+I) = TMP(8+I)        
 2250 CONTINUE        
 2270 J = 9        
      IF (TMP(J) .NE. CB) GO TO 4900        
      CARD(KK) = TEMP        
 2300 IF (KK .EQ. 1) GO TO 2400        
      KK = 1        
      GO TO 2100        
C        
 2400 IF (FFFLAG .NE. 1234) GO TO 2700        
      IF (LASH .EQ. +1) CARD(1) = SLASH        
      IF (PROM .NE. +1) GO TO 2500        
      IF (KOUNT.LT.7  .OR. KOUNT.GT.LOOP4) WRITE (SCREEN,2450) CARD     
      IF (KOUNT.EQ.7 .AND. KOUNT.LE.LOOP4) WRITE (SCREEN,2460)        
 2450 FORMAT (1X,10A8)        
 2460 FORMAT (9X,1H.,2(/,9X,1H.))        
 2500 IF (LOOP .EQ. -1) GO TO 2700        
      DO 2600 KK = 1,10        
 2600 SAVE(KK) = CARD(KK)        
 2700 IF (CARD(1).EQ.HELP .AND. CARD(2).EQ.BLANK .AND. IECHOS.EQ.-2)    
     1    CALL FFHELP (*60,*2900,2)        
      IF (CARD(1).EQ.STOP .AND. CARD(2).EQ.BLANK .AND. IECHOS.NE.-2)    
     1    GO TO 2900        
      IF (CARD(1).NE.SCALE8 .AND. CARD(1).NE.SCALE1) GO TO 2800        
      IF (CARD(1) .EQ. SCALE8) WRITE (NOUT,2710) (I,I=1,10)        
      IF (CARD(1) .EQ. SCALE1) WRITE (NOUT,2720) (I,I=1,8 )        
 2710 FORMAT (/1X,10(I5,3X),/1X,5('--------++++++++'))        
 2720 FORMAT (/1X,     8I10,/1X,8('1234567890'))        
      GO TO 60        
C        
 2800 RETURN        
 2900 STOP        
C        
C     ERRORS        
C        
 3000 WRITE  (SCREEN,3020)        
 3020 FORMAT (31H *** CARD ERROR - INPUT IGNORED)        
 3050 IF (IECHOS .EQ. -2) GO TO 170        
      IF (IERR   .LE. 15) WRITE (SCREEN,3060) A8        
 3060 FORMAT (5X,1H',10A8,1H',/)        
      NOGO = 1        
      IERR = IERR + 1        
      IF (IERR .LT. 30) GO TO 170        
 3070 WRITE  (SCREEN,3080)        
 3080 FORMAT (48H0*** JOB TERMINATED DUE TO TOO MANY INPUT ERRORS)      
      STOP        
 3100 JE = II - 1        
      WRITE  (SCREEN,3150) KK,CARD(KK),(A(J),J=JJ,JE)        
 3150 FORMAT (5X,5HFIELD,I3,2H (,A8,') OF PREVIOUS CARD SHOULD NOT BE ',
     1       'USED FOR', /5X,'INCREMENTATION (BY ',8A1,        
     2       ').  ZERO IS ASSUMED')        
      IF (INT .GT. 0) JC(KK) = 0        
      IF (INT .LT. 0) RC(KK) = 0.0        
      IF (INT) 1080,3000,1060        
 3200 JE = II - 1        
      WRITE  (SCREEN,3250) KK,(A(J),J=JJ,JE)        
 3250 FORMAT (5X,'FIELD',I3,' IS TOO LONG. ONLY 8 DIGITS ALLOWED - ',   
     1        16A1)        
      GO TO  3000        
 3300 WRITE  (SCREEN,3350)        
 3350 FORMAT (5X,44HPREVIOUS CARD WAS NOT SET UP FOR DUPLICATION)       
      GO TO  3000        
 3400 WRITE  (SCREEN,3450) A8        
 3450 FORMAT (35H *** INDEX ERROR.  NO VALUE AFTER ))        
      GO TO  3050        
 3500 WRITE  (SCREEN,3550)        
 3550 FORMAT (49H *** INPUT ERROR - TOO MANY FIELDS.  REPEAT INPUT)     
      GO TO  3050        
 3600 WRITE  (SCREEN,3650)        
 3650 FORMAT (37H *** INPUT ERROR AFTER EQUAL SIGN (=))        
      IF (IECHOS .EQ. -2) GO TO 60        
      WRITE  (SCREEN,3060) A8        
      NOGO = 1        
      GO TO  60        
 3700 WRITE  (SCREEN,3750)        
 3750 FORMAT (5X,'INDEX ERROR BEFORE RIGHT BRACKET )')        
      GO TO  3050        
 3800 JE = II - 1        
      WRITE  (SCREEN,3850) (A(J),J=JJ,JE)        
 3850 FORMAT (5X,18HINVALID INTEGER - ,16A1)        
      GO TO  3000        
 3900 JE = II - 1        
      WRITE  (SCREEN,3950) (A(J),J=JJ,JE)        
 3950 FORMAT (5X,22HINVALID F.P. NUMBER - ,16A1)        
      GO TO  3000        
 4000 WRITE  (SCREEN,4050)        
 4050 FORMAT (47H *** INPUT ERROR AFTER STAR (*), OR PERCENT (%))       
      GO TO  3050        
 4100 WRITE  (SCREEN,4150)        
 4150 FORMAT (41H *** ZERO LOOP COUNT.  NO CARDS GENERATED)        
      GO TO  3050        
 4200 WRITE  (SCREEN,4250) KK,L(KK),JC(KK),LOOP        
 4250 FORMAT (5X,5HFIELD,I3,2H (,I8,1H-,I8,21H) IS NOT DIVIDABLE BY,I4, 
     1       /5X,12HRESUME INPUT,/)        
 4300 IF (IECHOS .NE. -2) NOGO = 1        
      DO 4350 J = 1,10        
 4350 CARD(J) = SAVE(J)        
      GO TO  60        
 4400 WRITE  (SCREEN,4450) (A(J),J=JJ,JE)        
 4450 FORMAT (5X,27HMORE THAN ONE DEC. PT.,  - ,16A1)        
      GO TO  3000        
 4500 WRITE  (SCREEN,4550)        
 4550 FORMAT (39H *** WARNING- NESTED READFILE OPERATION)        
      GO TO  350        
 4600 WRITE  (SCREEN,4650)        
 4650 FORMAT (45H *** SO BE IT.  TO RUN NASTRAN LINK1 ONLY ***,/)       
      GO TO  60        
 4700 WRITE  (SCREEN,4750)        
 4750 FORMAT (23H *** BLANK LINE IGNORED)        
      GO TO  60        
 4800 WRITE  (SCREEN,4850) TEMP        
 4850 FORMAT (40H *** INTEGER ERROR IN CONTINUATION ID - ,A8)        
      IF (IECHOS .NE. -2) WRITE (SCREEN,3060) A8        
      GO TO  4300        
 4900 WRITE  (SCREEN,4950) (TMP(J),J=1,9)        
 4950 FORMAT (35H *** CONTINUATION FIELD TOO LONG - ,9A1, /5X,        
     1        25HLAST GENERATED CARD WAS -,/)        
      WRITE  (SCREEN,2450) SAVE        
      GO TO  4300        
 5000 WRITE  (SCREEN,5050)        
 5050 FORMAT (27H *** TOO MANY LEFT BRACKETS)        
      GO TO  3050        
 5100 WRITE  (NOUT,5150)        
 5150 FORMAT (/,20H *** EOF ENCOUNTERED )        
      IF (MACH.EQ.4 .AND. INFLAG.EQ.5) REWIND INFLAG        
      GO TO  60        
 5200 WRITE  (NOUT,5250)        
 5250 FORMAT (/,48H *** SKIPFILE IGNORED.  FILE HAS NOT BEEN OPENED)    
      GO TO  60        
 5300 WRITE  (NOUT,5350)        
 5350 FORMAT (/,26H *** FEATURE NOT AVAILABLE)        
      IF (IECHOS .NE. -2) WRITE (SCREEN,3060) A8        
      GO TO  60        
 5400 WRITE  (NOUT,5450)        
 5450 FORMAT (/,73H *** LEFT BRACKET ENCOUNTERED WITHOUT FIRST PRECEEDED
     1 BY '=', '*', OR '%')        
      GO TO  3000        
C        
      END        
