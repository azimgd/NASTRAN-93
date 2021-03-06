      SUBROUTINE NA1 2 A8 (*,A,N,B,NOTUSE)        
C        
      INTEGER         A(1),     B(2),    CDC        
      CHARACTER*1     C(1),     T(8)        
      CHARACTER*8     D(1)        
      CHARACTER*10    BLNK,     TEMP        
      COMMON /XREADX/ NOUT        
      COMMON /MACHIN/ MACH        
      EQUIVALENCE     (T(1),TEMP)        
      DATA            BLNK / '          '  /, CDC / 4  /        
C        
C     THESE ROUTTNES CONVERT N A1 BCD WORDS IN A, OR N A1 CHARACTERS IN 
C     C TO AN 8-BYTE BCD WORD IN B (CDC ONLY), (OR TO TWO 4-BYTE BCD    
C     WORDS IN B, ALL OTHER NON-CDC MACHINES), OR AN 8-CHARACTER WORD   
C     IN D, LEFT ADJUSTED.        
C     CALLING ROUTINE MUST NOT USE LOGICAL*1 FOR A-ARRAY.        
C     (NO SYSTEM ENCODE/DECODE FUNCTIONS ARE USED)        
C        
C     ENTRY POINTS   NA1 2 A8  (BCD-BYTE  VERSION)        
C                    NK1 2 K8  (CHARACTER VERSION)        
C        
C        
C     WRITTEN BY G.CHAN/SPERRY IN AUG. 1985        
C     PARTICULARLY FOR XREAD ROUTINE, IN SUPPORT OF ITS NEW FREE-FIELD  
C     INPUT FORMAT.  THIS SUBROUTINE IS MACHINE INDEPENDENT        
C        
C     LAST REVISED  8/1988        
C        
      IF (N .GT. 8) GO TO 40        
      TEMP = BLNK        
      CALL B2K (A,TEMP,N)        
      IF (MACH .NE. CDC) CALL KHRBC2 (TEMP,B(1))        
      IF (MACH .EQ. CDC) B(1) = ISWAP(TEMP)        
      RETURN        
C        
      ENTRY NK1 2 K8 (*,C,N,D,NOTUSE)        
C     ===============================        
C        
      IF (N .GT. 8) GO TO 40        
      TEMP = BLNK        
      DO 30 I = 1,N        
 30   T(I) = C(I)        
      D(1) = TEMP        
      RETURN        
C        
 40   WRITE  (NOUT,50) N        
 50   FORMAT ('   N.GT.8/NA12A8',I6)        
      J = NOTUSE        
      RETURN 1        
      END        
