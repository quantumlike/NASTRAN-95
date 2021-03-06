      SUBROUTINE GFSWCH (FILE1,FILE2)
C
C     THE PURPOSE OF THIS SUBROUTINE IS TO INTERCHANGE THE NAMES OF
C     TWO FILES.  THIS IS ACCOMPLISHED BY THE DIRECT UPDATEING
C     OF THE FIAT AND THE FIST
C
      EXTERNAL         LSHIFT,RSHIFT,ANDF,ORF,COMPLF
      INTEGER          FILE1,FILE2,MODNAM(2),NAME(2),PSAVE1,PSAVE2,
     1                 ANDF,ORF,RSHIFT,COMPLF,UNIT,UNIT1,UNIT2,UNT
      CHARACTER        UFM*23,UWM*25,UIM*29,SFM*25
      COMMON  /XMSSG / UFM,UWM,UIM,SFM
      COMMON  /XFIAT / IFIAT(3)
      COMMON  /XFIST / IFIST(2)
      COMMON  /XPFIST/ IPFIST
      COMMON  /SYSTEM/ SYSBUF,NOUT,SKIP(21),ICFIAT
      DATA     MODNAM/ 4HGFSW,4HCH   /
C
      MASK   = LSHIFT(1,30) - 1
      MASK   = LSHIFT(RSHIFT(MASK,16),16)
      MASK1  = COMPLF(MASK)
      MASK2  = 32767
      MASK3  = COMPLF(MASK2)
      NUNIQE = IFIAT(1)*ICFIAT + 3
      MXE    = IFIAT(2)*ICFIAT + 3
      LASTWD = IFIAT(3)*ICFIAT + 3
C
C     LOCATE FILE POINTERS IN THE FIST
C
      NWD    = 2*IPFIST   + 2
      NACENT = 2*IFIST(2) + 2
      NFILES = NACENT - NWD
      PSAVE1 = 0
      PSAVE2 = 0
      DO 25 I = 1,NFILES,2
      IF (IFIST(NWD+I).NE.FILE1 .AND. IFIST(NWD+I).NE.FILE2) GO TO 25
      IF (IFIST(NWD+I) - FILE1) 10,15,10
   10 IF (IFIST(NWD+I) - FILE2) 25,20,25
   15 PSAVE1 = IFIST(NWD+I+1) + 1
      ILOC1  = I+NWD
      GO TO 25
   20 PSAVE2 = IFIST(NWD+I+1) + 1
      ILOC2  = I+NWD
   25 CONTINUE
C
C     CHECK THAT FILES ARE IN FIST
C
      IF (PSAVE1 .EQ. 0) CALL MESAGE (-1,FILE1,MODNAM)
      IF (PSAVE2 .EQ. 0) CALL MESAGE (-1,FILE2,MODNAM)
C
C     SWITCH THE FIST POINTERS
C
      IFLOC = IFIST(ILOC1+1)
      IFIST(ILOC1+1) = IFIST(ILOC2+1)
      IFIST(ILOC2+1) = IFLOC
C
C     SWITCH FILE NAMES IN FIAT
C
      NAME(1)= IFIAT(PSAVE1+1)
      NAME(2)= IFIAT(PSAVE1+2)
      UNIT1  = ANDF(MASK2,IFIAT(PSAVE1))
      UNIT2  = ANDF(MASK2,IFIAT(PSAVE2))
      NWD    = ICFIAT*IFIAT(3)-2
      LTU1   = ANDF(MASK,IFIAT(PSAVE1))
      LTU2   = ANDF(MASK,IFIAT(PSAVE2))
      IFIAT(PSAVE1  ) = ORF(ANDF(IFIAT(PSAVE1),MASK2 ),LTU2)
      IFIAT(PSAVE1+1) = IFIAT(PSAVE2+1)
      IFIAT(PSAVE1+2) = IFIAT(PSAVE2+2)
      IFIAT(PSAVE2  ) = ORF(ANDF(IFIAT(PSAVE2),MASK2),LTU1)
      IFIAT(PSAVE2+1) = NAME(1)
      IFIAT(PSAVE2+2) = NAME(2)
C
C     SWITCH STACKED DATA BLOCKS
C
      DO 100 I = 4,NWD,ICFIAT
      IF (PSAVE1.EQ.I .OR. PSAVE2.EQ.I) GO TO 100
      IF (IFIAT(I+1).EQ.0 .AND. IFIAT(I+2).EQ.0) GO TO 100
      UNIT = ANDF(MASK2,IFIAT(I))
      IF (UNIT.NE.UNIT1 .AND. UNIT.NE.UNIT2) GO TO 100
      IF (UNIT .EQ. UNIT1) UNT = UNIT2
      IF (UNIT .EQ. UNIT2) UNT = UNIT1
      IF (I .GT. NUNIQE) GO TO 70
C
C     DATA BLOCK RESIDES IN UNIQUE PART OF FIAT
C     MOVE ENTRY TO BOTTOM
C
      IF (LASTWD+ICFIAT .LE. MXE) GO TO 40
      WRITE  (NOUT,30) SFM
   30 FORMAT (A25,' 1021, FIAT OVERFLOW')
      CALL MESAGE (-37,0,MODNAM)
   40 IFIAT(LASTWD+1) = ORF(ANDF(IFIAT(I),MASK3),UNT)
      DO 50 K = 2,ICFIAT
   50 IFIAT(LASTWD+K) = IFIAT(I+K-1)
      LASTWD   = LASTWD   + ICFIAT
      IFIAT(3) = IFIAT(3) + 1
C
C     CLEAR OLD ENTRY IN UNIQUE PART
C
      IFIAT(I) = ANDF(IFIAT(I),MASK2)
      J1 = I + 1
      J2 = I + ICFIAT - 1
      DO 60 K = J1,J2
   60 IFIAT(K) = 0
      GO TO 100
C
C     DATA BLOCK RESIDES IN NON-UNIQUE PORTION OF FIAT
C     SWITCH UNIT NUMBERS
C
   70 IFIAT(I) = ORF(ANDF(IFIAT(I),MASK3),UNT)
  100 CONTINUE
      RETURN
      END
