      SUBROUTINE CASE        
C        
C     CASE READS THE CASE CONTROL DATA BLOCK AND WRITES A NEW        
C     DATA BLOCK WHICH CONTAINS ONLY THOSE RECORDS WHICH DESCRIBE THE   
C     CURRENT CASE IN THE LOOP. ADDITIONALLY, THE LOOP CONTROL PARAMETER
C     IS SET.        
C        
C        
      INTEGER         APP    ,COUNT  ,SYSBUF,CASECC,CASEXX,FILE  ,Z    ,
     1                BUF1   ,BUF2   ,RFMTS ,BRANCH,BUF   ,ERROR(2)     
      INTEGER         BUF3   ,PSDL        
      DIMENSION       NAM(2) ,BUF(20),MCB(7),RFMTS(40)        
      COMMON /BLANK / APP(2) ,COUNT  ,LOOP        
      COMMON /SYSTEM/ SYSBUF        
      COMMON /NAMES / RD     ,RDREW  ,WRT   ,WRTREW,CLSREW        
CZZ   COMMON /ZZCASE/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
C        
C     DATA DESCRIBING DATA BLOCK FILE NAMES AND POSITION        
C     OF PARAMETERS IN THE CASE CONTROL RECORD.        
C        
      DATA   CASECC / 101/ ,CASEXX /201/ ,IK2PP  /139/ ,IM2PP /141/ ,   
     1       IB2PP  / 143/ ,ITFL   / 15/ ,PSDL   /102/ ,IRAND /163/     
      DATA   ERROR  / 4HPSDL,4HCASE/        
      DATA   IFREQ  / 14/  ,IMETH  /  5/        
C        
C     DATA DEFINING RIGID FORMATS.        
C        
      DATA   NRIGDS / 10   /, RFMTS  /        
     1                4HSTAT,4HICS , 4HREIG,4HEN  , 4HDS0 ,4H    ,      
     2                4HDS1 ,4H    , 4HFREQ,4H    , 4HTRAN,4HSNT ,      
     3                4HBKL0,4H    , 4HBKL1,4H    , 4HCEIG,4HEN  ,      
     4                4HPLA ,4H    , 20*0  /        
C        
C     MISC DATA        
C        
      DATA   NAM    / 4HCASE,4H    /, MCB    / 7*0  /        
C        
C     PERFORM BUFFER ALLOCATION.        
C        
      BUF1  = KORSZ(Z) - SYSBUF + 1        
      BUF3  = BUF1 - SYSBUF        
      BUF2  = BUF3 - SYSBUF        
      IRY   = 0        
      M8    = -8        
      IF (COUNT .LE. 0) COUNT = 1        
      LOOP  = 1        
      IOCNT = COUNT        
C        
C     SET PARAMETER FOR APPROACH.        
C        
      N = 2*NRIGDS - 1        
      DO 20 I = 1,N,2        
      IF (RFMTS(I) .EQ. APP(1)) GO TO 30        
   20 CONTINUE        
      CALL MESAGE (30,75,APP)        
      I = 19        
   30 BRANCH = (I+1)/2        
C        
C     OPEN CASECC. SKIP RECORDS ALREADY PROCESSED. OPEN CASEXX.        
C     WRITE HEADER RECORD. THEN BRANCH ON APPROACH.        
C        
      FILE = CASECC        
      CALL OPEN (*130,CASECC,Z(BUF1),RDREW)        
      DO 40 I = 1,COUNT        
   40 CALL FWDREC (*140,CASECC)        
      FILE = CASEXX        
      CALL OPEN  (*130,CASEXX,Z(BUF2),WRTREW)        
      CALL FNAME (CASEXX,BUF)        
      CALL WRITE (CASEXX,BUF,2,1)        
      GO TO (120,50,120,120,50,100,120,120,50,120), BRANCH        
C        
C     COMPLEX EIGENVALUES OR FREQUENCY RESPONSE.        
C        
   50 CALL READ (*140,*60,CASECC,Z,BUF2,1,NCC)        
      CALL MESAGE (M8,0,NAM)        
   60 BUF(1) = Z(IK2PP  )        
      BUF(2) = Z(IK2PP+1)        
      BUF(3) = Z(IM2PP  )        
      BUF(4) = Z(IM2PP+1)        
      BUF(5) = Z(IB2PP  )        
      BUF(6) = Z(IB2PP+1)        
      BUF(7) = Z(ITFL)        
      IRSET  = Z(IRAND)        
      IFRQST = Z(IFREQ)        
      IMRQST = Z(IMETH)        
      IF (BRANCH.EQ.5 .AND. IRSET.NE.0) IRY = 1        
      IF (IRY .EQ. 0) GO TO 70        
C        
C     BUILD LIST OF UNIQUE LOAD ID-S        
C        
      FILE = PSDL        
      CALL OPEN (*68,PSDL,Z(BUF3),RDREW)        
      CALL FWDREC (*90,PSDL)        
      ILS  = BUF2        
      ILF  = BUF2 - 1        
   61 CALL READ (*90,*66,PSDL,Z(NCC+1),6,0,J)        
      IF (Z(NCC+1) .NE. IRSET) GO TO 61        
      J = 1        
      ILOAD = Z(NCC+2)        
      IF (ILS .EQ. ILF+1) GO TO 63        
   65 DO 62 I = ILS,ILF        
      IF (Z(I) .EQ. ILOAD) GO TO 64        
   62 CONTINUE        
C        
C     NEW LOAD ID        
C        
   63 ILS = ILS - 1        
      Z(ILS) = ILOAD        
   64 IF (J .EQ. 0) GO TO 61        
      J = 0        
      ILOAD = Z(NCC+3)        
      GO TO 65        
C        
C     END OF PSDL RECORD        
C        
   66 CALL CLOSE (PSDL,CLSREW)        
      IF (ILS .EQ. ILF+1) CALL MESAGE (-31,IRSET,ERROR(1))        
      BUF2 = ILS - 1        
      GO TO 70        
C        
C     NO PSDL IS EQUIVALENT TO NO RANDOM        
C        
   68 IRY = 0        
   70 CALL WRITE (CASEXX,Z,NCC,1)        
      COUNT = COUNT + 1        
      IF (IRY .EQ. 0) GO TO 71        
C        
C     CHECK  SUBCASE ID-S        
C        
      DO 72 I = ILS,ILF        
      IF (Z(1) .EQ. Z(I)) GO TO 74        
   72 CONTINUE        
      GO TO 71        
C        
C     MARK USED        
C        
   74 Z(I) = -Z(I)        
   71 CONTINUE        
      CALL READ (*90,*80,CASECC,Z,BUF2,1,NCC)        
      CALL MESAGE (M8,0,NAM)        
   80 IF (Z(IK2PP).NE.BUF(1) .OR. Z(IK2PP+1).NE.BUF(2) .OR.        
     1    Z(IM2PP).NE.BUF(3) .OR. Z(IM2PP+1).NE.BUF(4) .OR.        
     2    Z(IB2PP).NE.BUF(5) .OR. Z(IB2PP+1).NE.BUF(6)) GO TO 120       
      IF (Z(ITFL) .NE. BUF(7)) GO TO 120        
      IF (Z(IMETH).NE.0 .AND. Z(IMETH).NE.IMRQST) GO TO 120        
C        
C     TEST FOR CHANGED FREQUENCY SET        
C        
      IF (Z(IFREQ).NE.IFRQST .AND. BRANCH.EQ.5) GO TO 120        
      GO TO 70        
   90 COUNT = -1        
      GO TO 120        
C        
C     TRANSIENT RESPONSE.        
C        
  100 CALL READ (*140,*110,CASECC,Z,BUF2,1,NCC)        
      CALL MESAGE (M8,0,NAM)        
  110 CALL WRITE (CASEXX,Z,NCC,1)        
      COUNT = COUNT + 1        
      CALL READ (*90,*120,CASECC,Z,BUF2,1,NCC)        
      GO TO 120        
C        
C     CLOSE FILES. WRITE TRAILER. RETURN.        
C        
  120 CALL CLOSE (CASECC,CLSREW)        
      CALL CLOSE (CASEXX,CLSREW)        
      MCB(1) = CASEXX        
      MCB(2) = COUNT        
      CALL WRTTRL (MCB)        
      IF (COUNT.LE.1 .AND. IOCNT.EQ.1) LOOP = -1        
C        
C     CHECK ALL PSDL ACCOUNTED FOR        
C        
      IF (IRY .EQ. 0) GO TO 125        
      NOGO = 0        
      DO 121  I = ILS,ILF        
      IF (Z(I) .LT. 0) GO TO 121        
      NOGO = -1        
      CALL MESAGE (33,Z(I),NAM)        
  121 CONTINUE        
      IF (NOGO .LT. 0) CALL MESAGE (-7,0,NAM)        
  125 RETURN        
C        
C     FATAL FILE ERRORS.        
C        
  130 N = -1        
      GO TO 150        
  140 N = -2        
      FILE = CASECC        
  150 CALL MESAGE (N,FILE,NAM)        
      GO TO 150        
      END        
