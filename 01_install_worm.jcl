//WORM JOB (SYS),'INSTALL WORM',CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             USER=IBMUSER,PASSWORD=SYS1,REGION=2048K
//* ********************************************************
//* *                                                      *
//* *        INSTALL THE 'WORM' TSO COMMAND                *
//* *                                                      *
//* ********************************************************
//ASM     EXEC PGM=IFOX00,PARM='NODECK,LOAD,TERM'
//SYSGO    DD  DSN=&&LOADSET,DISP=(MOD,PASS),SPACE=(CYL,(1,1)),
//             UNIT=VIO,DCB=(DSORG=PS,RECFM=FB,LRECL=80,BLKSIZE=800)
//SYSLIB   DD  DSN=SYS1.MACLIB,DISP=SHR
//SYSTERM  DD  SYSOUT=*
//SYSPRINT DD  SYSOUT=*
//SYSPUNCH DD  DSN=NULLFILE
//SYSUT1   DD  UNIT=VIO,SPACE=(CYL,(6,1))
//SYSUT2   DD  UNIT=VIO,SPACE=(CYL,(6,1))
//SYSUT3   DD  UNIT=VIO,SPACE=(CYL,(6,1))
//SYSIN    DD  *
WORM     TITLE ' A PROGRAM FOR TSO 3270 TERMINALS '
         ENTRY HALFTEST
         ENTRY HALFWORM
         ENTRY HW
         ENTRY QUARTEST
         ENTRY QUARTERW
         ENTRY QW
         ENTRY WORMTEST
***********************************************************************
*                                                                     *
*        WRITTEN OCTOBER 1986 BY GREG PRICE OF PRYCROFT SIX PTY LTD.  *
*                                                                     *
*        FOR USE UNDER TSO ON 3270-FAMILY VDU IN FULLSCREEN           *
*        MODE.  WORM SUPPORTS ALL SCREEN SIZES.                       *
*                                                                     *
*        OBJECT: FOR THE WORM TO EAT THE NUMBERS APPEARING ON         *
*        THE SCREEN WITHOUT COLLIDING WITH ITSELF OR THE BORDER       *
*        AROUND THE SCREEN.  WHEN A NUMBER IS EATEN (BY MOVING        *
*        THE WORM'S HEAD (DENOTED BY A '@') TO THE NUMBER'S           *
*        LOCATION) ANOTHER NUMBER WILL APPEAR AT A RANDOM VACANT      *
*        LOCATION.  THE VALUE OF THE EATEN NUMBER WILL BE ADDED       *
*        TO THE SCORE AND THE WORM'S LENGTH WILL ALSO INCREASE BY     *
*        THAT AMOUNT.  COLLISIONS ARE DENOTED BY A '+' THEN A '*'     *
*        ONE SECOND LATER, AND CAUSE THE WORM TO DIE DUE TO BRAIN     *
*        DAMAGE CAUSED BY SHOCKING HEAD INJURIES.                     *
*                                                                     *
*        METHOD: ONCE THE WORM IS MOVING TEN (10) TGETS ARE DONE      *
*        ONE-TENTH OF A SECOND APART.  IF NO INPUT IS RECEIVED        *
*        THE WORM IS MOVED ONE LOCATION IN THE CURRENT DIRECTION.     *
*        WHEN WORMOMATIC IS ACTIVE ONLY ONE (1) TGET IS DONE WHEN     *
*        IN BURST MODE, OR TWO (2) TGETS ONE-TENTH OF A SECOND        *
*        APART OTHERWISE.  THE CURRENT MEANING OF PF1 (DISPLAYED      *
*        IN THE TITLE LINE) AND THE MOVE SPEED INDICATE THE CURRENT   *
*        AUTOMATIC/MANUAL/BURST MODE STATUS.                          *
*                                                                     *
*        AN OPTIONAL PROGRAM PARAMETER OR TSO COMMAND OPERAND         *
*        (DEPENDING UPON THE METHOD OF INVOCATION) OF ONE OR TWO      *
*        DECIMAL DIGITS MAY BE SUPPLIED.  THIS SPECIFIES A TARGET     *
*        UPPER LIMIT TO TASK-TYPE CPU TIME CONSUMPTION BY WORMO-      *
*        MATIC EXPRESSED IN TERMS OF PERCENTAGE OF ELAPSED TIME.      *
*        THE DEFAULT OF ZERO MEANS THAT WORMOMATIC WILL NOT TRY       *
*        TO LIMIT ITS CPU SERVICE ABSORPTION RATE.                    *
*                                                                     *
***********************************************************************
         EJECT
***********************************************************************
*                                                                     *
*        INPUT:                                                       *
*        PA KEYS - REFRESH THE SCREEN IMAGE                           *
*        PF01/13 - WORMOMATIC - AUTOMATIC WORM PILOT SPEED            *
*        PF02/14  |ACTIVATE/DEACTIVATE DEBUG MODE WHEN      |         *
*                 |BURST MODE SWITCH IS ON (*NOW DISABLED*) |         *
*                 |             -OR-                        |         *
*                - ACTIVATE/DEACTIVATE REVERSE VIDEO MODE             *
*                 |WHEN BURST MODE SWITCH IS OFF (*IGNORE*) |         *
*        PF03/15 - END - END WITH SCORING                             *
*        PF04/16 - TOGGLE GRAPHIC "CHARACTER SETS"                    *
*        PF05/17 - ACTIVATE/DEACTIVATE "BURST" MODE                   *
*        PF06/18 - ACTIVATE/DEACTIVATE GRAPHIC CHARACTER MODE         *
*        PF07/19 - CHANGE THE CURRENT DIRECTION TO UP                 *
*                  AND MAKE A MOVE                                    *
*        PF08/20 - CHANGE THE CURRENT DIRECTION TO DOWN               *
*                  AND MAKE A MOVE                                    *
*        PF09/21 - MOVE UNCONDITIONALLY (UNLESS A NUMBER IS           *
*                  ENCOUNTERED) EIGHT (8) LOCATIONS IN THE            *
*                  CURRENT DIRECTION                                  *
*        PF10/22 - CHANGE THE CURRENT DIRECTION TO RIGHT              *
*                  AND MAKE A MOVE                                    *
*        PF11/23 - CHANGE THE CURRENT DIRECTION TO LEFT               *
*                  AND MAKE A MOVE                                    *
*        PF12/24 - CANCEL - END WITHOUT SCORING                       *
*                                                                     *
*        ENTER CAUSES A MOVE IN THE CURRENT DIRECTION TO BE           *
*        MADE IMMEDIATELY.  PA KEYS AND PF KEYS 1/13, 2/14, 4/16,     *
*        5/17 AND 6/18 ARE THE ONLY ONES WHICH WILL NOT STOP          *
*        WORMOMATIC WHILE IT IS ACTIVE.  ATTENTION INTERRUPT          *
*        (PA1) STOPS WORMOMATIC.                                      *
*                                                                     *
***********************************************************************
         EJECT
***********************************************************************
*                                                                     *
*        IF THE FILE ISPTABL (CAN BE CHANGED TO ANY PDS DD WHICH      *
*        EFFECTIVELY HAS UACC(UPDATE)) IS ALLOCATED THEN THE          *
*        HIGHEST SCORE IS KEPT AS USER DATA (PFD (NOT SPF) STATS)     *
*        OF MEMBER EWSBTA##  (REVIEW WILL SHOW PFD AND SPF STATS)     *
*        WHERE ## IS THE NUMBER OF LINES THAT THE SCREEN HAS.         *
*        FILE NAME PFDATTRS IS USED UNDER OSIV/F4.                    *
*                                                                     *
*        IF THE TERMINAL'S VTAM QUERY BIT IS ON THEN ARROWS ARE       *
*        USED FOR THE WORM INSTEAD OF LOWER CASE 'O'S (THIS ALSO      *
*        MEANS "UNWINDING" INFORMATION IS AVAILABLE TO THE            *
*        PLAYER), THE '@' FOR THE HEAD IS REPLACED BY A BLOB, AND     *
*        THE TARGET NUMBER WILL BE DISPLAYED IN REVERSE VIDEO.        *
*        AN ALTERNATE GRAPHIC DISPLAY MODE IS AVAILABLE WHICH         *
*        SHOWS THE WORM AS A CONTINUOUS LINE AND THE HEAD AS A BLOCK. *
*        LINE MODE IS SIMILATED IN NON-GRAPHIC MODE WITH DASHES ETC.  *
*        THE INITIAL WORM IS WHITE, BUT EACH WORM FOOD TARGET IS      *
*        ARTIFICIALLY COLOURED AT RANDOM.  NO PRESERVATIVES ADDED.    *
*        THE WORM WILL GRADUALLY TAKE ON THE COLOUR OF THE MOST       *
*        RECENTLY CONSUMED FOOD.  NO TWO CONSECUTIVE FOOD TARGETS     *
*        WILL HAVE THE SAME COLOUR.  7-COLOUR DISPLAYS ARE ONLY       *
*        TRANSMITTED IN "GRAPHIC" MODE.  PF6/18 IS AVAILABLE TO       *
*        ACTIVATE/DEACTIVATE "GRAPHIC" MODE, WHICH IS INITIALLY ON    *
*        ONLY IF THE VTAM QUERY BIT FOR THE TSO TERMINAL IS ON AND    *
*        THE QUERY INDICATED 7-COLOUR SUPPORT.  IF THE QUERY DOES     *
*        NOT INDICATE GRAPHICS ESCAPE SUPPORT THEN APL/GRAPHIC        *
*        CHARACTERS WILL NOT BE USED EVEN IF SEVEN COLOURS ARE.       *
*        REVERSE VIDEO MODE CAN BE ACTIVATED AND DEACTIVATED BY       *
*        PF2/14 INDEPENDENTLY OF GRAPHIC MODE.  (PF2/14 USED TO       *
*        ACTIVATE DEBUG MODE WHEN IN BURST MODE, BUT THIS HAS NOW     *
*        BEEN DISABLED.)                                              *
*                                                                     *
*        (IT REALLY DOESN'T LOOK MUCH LIKE A WORM IN "GRAPHIC"        *
*        MODE.  NORMAL MODE LOOKS BETTER ON A 3180 ANYWAY, AS WELL    *
*        AS REDUCING DATA TRAFFIC.  NOTE THAT "GRAPHIC" INFORMATION   *
*        IS NOT SENT TO THE TERMINAL FOR SCREEN RESHOW/REFRESH.)      *
*                                                                     *
***********************************************************************
         EJECT
***********************************************************************
*                                                                     *
*        TERMINAL I/O CAN BE SPEEDED UP WITH THE USE OF "BURST"       *
*        MODE.  INSTEAD OF ONE TPUT PER MOVE A DATA STREAM OF OVER    *
*        3K CAN BE ACCUMULATED AND SENT IN ONE TPUT.  EATING A        *
*        NUMBER ALSO TRIGGERS A TPUT.  "BURST" MODE IS ONLY USED      *
*        IN AUTOMATIC MODE.                                           *
*                                                                     *
*        IF INVOKED AS 'HALFWORM' OR 'HW' THEN ONLY THE TOP HALF      *
*        (INTEGER ARITHMETIC) OF THE SCREEN WILL BE USED.             *
*        NATURALLY A DIFFERENT SCOREBOARD MEMBER WILL BE USED.        *
*        SIMILARLY WITH 'QUARTERW' AND 'QW'.                          *
*                                                                     *
*        IF INVOKED AS 'WORMTEST' (FULL-SCREEN), 'HALFTEST' (HALF-    *
*        SCREEN) OR 'QUARTEST' (QUARTER-SCREEN) THEN FOOD-GENERATION  *
*        TEST MODE WILL BE ACTIVE AND A WORM WILL NOT BE PRODUCED.    *
*        SPEED AND COLOUR MODES ARE CONTROLLED AS DESCRIBED EARLIER.  *
*        INITIALLY THE SCREEN WILL BE FILLED UP WITH FOOD TARGETS,    *
*        BUT THEN PF4/16 WILL REQUEST GENERATION CONTINUATION         *
*        WITHOUT REGARD TO PREVIOUS OCCUPANCY OF THE SELECTED         *
*        POSITION.  IF THE SCREEN IS CLEARED AT THIS STAGE, RANDOM    *
*        NUMBER GENERATOR PECULIARITIES SUCH AS TIMER UNIT            *
*        GRANULARITY (LOW-ORDER BIT ALWAYS OFF PERHAPS) MAY           *
*        BECOME APPARENT.  PF3/15 THEN PF4/16 MAY BE DONE ANYTIME.    *
*                                                                     *
*        THE ABOVE HAS BEEN CHANGED SUCH THAT PF4/16 IS REPLACED      *
*        BY PF1-8/13-20.  PF1-7/13-19 SPECIFY THE COLOUR CODE TO      *
*        BE USED UNCONDITIONALLY.  PF8/20 REACTIVATES RANDOM COLOUR   *
*        GENERATION.  REMEMBER THAT THIS FUNCTION IS ONLY AVAILABLE   *
*        AT END-OF-TEST VIA PF3/15 OR VIA FULLY-COVERED SCREEN.       *
*                                                                     *
***********************************************************************
         EJECT
***********************************************************************
*                                                                     *
*        WORM REQUIRES MACROS FROM SYS1.MACLIB.                       *
*        WORM REQUIRES AMODE=24 AND RMODE=24.                         *
*        WORM IS NOT RE-ENTRANT NOR SERIALLY REUSEABLE.               *
*        WORM DOES NOT ISSUE ANY GETMAIN OR FREEMAIN MACROS.          *
*        WORM MUST MUST BE APF AUTHORIZED IF THE USER'S TPUT          *
*             AND TRANSACTION COUNTERS ARE TO BE DECREMENTED.         *
*             IN ANY EVENT, THIS DECREMENTING WILL ONLY BE            *
*             PERFORMED ON MVS (MVS/370 OR MVS/XA) SYSTEMS.           *
*                                                                     *
*        OSIV/F4 NOTE:                                                *
*             TGETS/TPUTS MAKE TASKS NON-DISPATCHABLE UNDER F4.       *
*             IN MVS, TASKS ARE PUT INTO A WAIT STATE.  HENCE,        *
*             TSS USERS DON'T TIMEOUT LIKE TSO USERS (S522 ABEND).    *
*             ALSO, TGET NOWAIT MACROS STOP THE TCBS UNTIL A TSS      *
*             TERMINAL KEYBOARD ATTENTION OCCURS.  THEREFORE, WORM    *
*             DOES NOT "TICK OVER" UNDER F4.  SO, NO TGETS ARE        *
*             ISSUED WHEN WORMOMATIC IS ACTIVE UNDER F4.  TO STOP     *
*             WORMOMATIC ON TSS ATTN/PA1 IS REQUIRED.  MVS WAS LIKE   *
*             THIS TOO, ORIGINALLY, WASN'T IT?  (PRE-3.7?  SVS?)      *
*                                                                     *
***********************************************************************
         SPACE 2
         GBLC  &SYSSPLV
&SYSSPLV SETC  '1'                THIS IS AN MVS/370 COMPATIBLE PROGRAM
         TITLE ' INITIALIZATION '
WORM     CSECT
WORMTEST DS    0D                 FULL-SCREEN RANDOM GENERATOR TEST
HALFTEST DS    0D                 HALF-SCREEN RANDOM GENERATOR TEST
HALFWORM DS    0D                 HALF-SCREEN VERSION ENTRY POINT
HW       DS    0D                 SHORT FORM (ALIAS) OF HALFWORM
QUARTEST DS    0D                 QUARTER-SCREEN RANDOM GENERATOR TEST
QUARTERW DS    0D                 QUARTER-SCREEN VERSION ENTRY POINT
QW       DS    0D                 SHORT FORM (ALIAS) OF QUARTERW
         STM   R14,R12,12(R13)    SAVE REGS
         LR    R11,R15            FIRST BASE
         LA    R12,2048(,R11)
         LA    R12,2048(,R12)     SECOND BASE
         LA    R7,2048(,R12)
         LA    R7,2048(,R7)       THIRD BASE
         USING WORM,R11,R12,R7    HOME BASE
         LR    R2,R1              SAVE PARAMETER LIST ADDRESS
         GTSIZE
         LTR   R0,R0              ZERO LINES?
         BNZ   HAVEVDU            NO, SHOULD MEAN 3270 CRT OR SIMILAR
         LA    R1,SORRYMSG        YES, PROBABLY ON A TTY
         LA    R0,L'SORRYMSG
LEAVEMSG TPUT  (1),(0),R          SORRY, BUT VDU IS REQUIRED
         LM    R14,R12,12(R13)    RESTORE REGS
         LA    R15,8              RETURN CODE EIGHT
         BR    R14                RETURN TO CALLER
         SPACE 2
HAVEVDU  CH    R0,=H'24'          LESS THAN TWENTY-FOUR LINES?
         BL    WACKYVDU           YES, I DON'T BELIEVE IT
         CH    R0,=H'99'          MORE THAN NINETY-NINE LINES?
         BH    WACKYVDU           YES, SCOREBOARD NAME WON'T WORK
         CH    R1,=H'40'          LESS THAN FORTY COLUMNS?
         BNL   SCREENOK           NO, ACCEPT THIS SCREEN SIZE
WACKYVDU LA    R1,WACKYMSG        YES, CAN'T BE AN HONEST-TO-GOD VDU
         LA    R0,L'WACKYMSG
         B     LEAVEMSG           TELL THE USER AND GO HOME
SCREENOK LR    R8,R0              SAVE LINES ON SCREEN
         LR    R9,R1              SAVE COLUMNS ON SCREEN
         L     R1,=V(WORMCMN)
         ST    R1,8(,R13)         CHAIN SAVE AREAS
         ST    R13,4(,R1)
         LR    R13,R1
         USING WORMCMN,R13
         MVI   WORMFLAG,0
         MVI   WORMFLG2,0         OR 'XHST' FOR OTHER LOOK-AHEAD MODE
         MVI   THISCOLR,0         START WITH RANDOM COLOUR SELECTION
*   LET PF2/14 AND PF6/18 TRY COLOUR AND HIGHLIGHTING IF NO QUERY DONE
         MVI   GRAFLAGS,COLR+HLIT+GEOK   ALSO ALLOW APL CHARS W/O QUERY
         L     R1,16              POINT TO THE CVT
         MVC   OSBITS,116(R1)     SAVE OPERATING SYSTEM FLAGS FOR LATER
         L     R1,540             POINT TO THE CURRENT TCB
         L     R1,0(,R1)          POINT TO THE ACTIVE RB
         L     R1,12(,R1)         POINT TO THE ACTIVE CDE
         CLC   12(4,R1),=C'TEST'  FOOD GENERATION TEST?
         BNE   NOTATEST           NO, PLAY THE GAME
         OI    WORMFLG2,TEST      YES, TURN ON THE TEST BIT
NOTATEST CLI   8(R1),C'H'         INVOKED AS HALFWORM?
         BE    HALFSIZE           NO, ONLY USE HALF OF THE LINES
         CLI   8(R1),C'Q'         INVOKED AS QUARTERW?
         BNE   HAVESIZE           NO, USE ALL OF THE SCREEN
         SRL   R8,1               HALF OF THE NUMBER OF LINES
HALFSIZE SRL   R8,1               HALF OF THE NUMBER OF LINES (AGAIN)
HAVESIZE DS    0H                 ACTIVATE VTAM FULL SCREEN MODE
         GTTERM PRMSZE=WASTE,ATTRIB=TERMATTR  GET TERMINAL ATTRIBUTES
         LTR   R15,R15            ACF/VTAM INSTALLED?
         BNZ   NONOEDIT           NO, GTTERM FAILED, NO QUERY SUPPORT
         TM    TERMATTR+3,X'01'   QUERY BIT ON?
         BO    NOEDITOK           YES, GET INTO NOEDIT INPUT MODE
NONOEDIT STFSMODE ON,INITIAL=YES  NO QUERY, AVOID NOEDIT INPUT MODE
         B     INFSMODE           NOW IN FULLSCREEN MODE
NOEDITOK DS    0H                 NOEDIT INPUT NEEDED FOR QUERY
         STFSMODE ON,INITIAL=YES,NOEDIT=YES
INFSMODE LA    R1,CLEARALL        POINT TO CLEAR SCREEN DATA STREAM
         LA    R0,L'CLEARALL      GET DATA STREAM LENGTH
         ICM   R1,X'8',=X'03'     LOAD FULLSCREEN FLAGS
         TPUT  (1),(0),R          CLEAR THE SCREEN
         STM   R8,R9,LINES        STORE SCREEN DIMENSIONS
         CVD   R8,WORK            GET THE DECIMAL NUMBER OF LINES
         OI    WORK+7,X'0F'           TO SUFFIX THE MEMBER NAME
         UNPK  BORDNAME+6(2),WORK+6(2)
         SH    R8,=H'2'           TWO BORDERS
         ST    R8,MOVLINES        GET HOW MANY LINES TO MOVE
         SH    R9,=H'2'           TWO BORDERS
         ST    R9,MOVECOLS        GET HOW MANY COLUMNS TO MOVE
         MVI   RTORLFT,X'96'      SAY WORM LAST WENT RIGHT
         MVI   UPORDN,X'A4'       SAY WORM LAST WENT UP (ARBITRARY)
         XC    ZEROAREA(ZEROLEN),ZEROAREA  ZERO A FEW VARIABLES
         MVC   DELAY,TEN          INITIALIZE STIMER DELAY
         TM    0(R2),X'80'        INVOKED AS PROGRAM OR TSO COMMAND?
         BO    PGMPARM            PROGRAM
         L     R2,0(,R2)          CP SO POINT TO THE COMMAND BUFFER
         LH    R3,2(,R2)          GET LENGTH OF PARSING DONE
         LA    R3,4(,R3)          GET OFFSET INTO COMMAND BUFFER
         LA    R1,0(R3,R2)        POINT TO FIRST NON-PARSED CHARACTER
         SH    R3,0(,R2)          SUBTRACT COMMAND BUFFER LENGTH TO GET
         BZ    TERMCHK            OPERAND LENGTH - IF ZERO, FORGET IT
         LPR   R3,R3              GET ABSOLUTE (POSITIVE) VALUE
         B     INITPARM           OPERAND SPECIFIED SO USE IT
PGMPARM  L     R2,0(,R2)          POINT TO PROGRAM PARAMETER
         CLI   1(R2),0            ZERO PROGRAM PARAMETER LENGTH?
         BE    TERMCHK            YES, SO NO INITIAL COMMAND
         LA    R1,2(,R2)          NO, POINT TO START OF PARAMETER TEXT
         LH    R3,0(,R2)          LOAD PARAMETER TEXT LENGTH
INITPARM LA    R0,2               GET MAXIMUM PARAMETER LENGTH
         CR    R3,R0              IS IT TOO LONG?
         BNH   PARMOKAY           NO
         LR    R3,R0              YES, REDUCE TO MAXIMUM ALLOWED
PARMOKAY SLR   R0,R0              ZERO ACCUMULATOR
         XC    WORK,WORK          ZERO WORK AREA
PARMLOOP CLI   0(R1),C'0'         NUMERIC PARAMETER?
         BL    PARMDONE           NO
         CLI   0(R1),C'9'         NUMERIC PARAMETER?
         BH    PARMDONE           NO
         MH    R0,TEN+2           PROMOTE PREVIOUS DIGIT
         MVC   WORK+3(1),0(R1)    COPY DIGIT
         NI    WORK+3,X'0F'       CONVERT TO BINARY
         A     R0,WORK            ADD TO ACCUMULATOR
         LA    R1,1(,R1)          POINT TO NEXT PARAMETER BYTE
         BCT   R3,PARMLOOP        PROCESS IT
PARMDONE ST    R0,TGTPCNT         SAVE TARGET TCB TIME PERCENTAGE
TERMCHK  TM    TERMATTR+3,X'01'   QUERY BIT ON?
         BZ    SKPQUERY           NO, CAN'T DO QUERY
         LA    R1,RESETAID        YES, RESET THE TERMINAL AID AND
         LA    R0,L'RESETAID           WAIT TILL THIS IS DONE
         ICM   R1,8,=X'0B'             BEFORE PROCEEDING
         TPUT  (1),(0),R          TPUT FULLSCR,WAIT,HOLD
         MVI   GRAFLAGS,0         ALL GRAPHIC FEATURES TO BE VERIFIED
         TPG   QUERY,L'QUERY,NOEDIT,WAIT
QUERYGET LA    R1,BUFFER          TEMPORARY TGET BUFFER FOR RESPONSE
         LA    R0,1024                      FROM READ PARTITION
         ICM   R1,8,TGETFLAG      FLAGS FOR TGET ASIS,WAIT
         TGET  (1),(0),R          TGET ASIS,WAIT
         CLI   BUFFER,X'6B'       VTAM RESHOW REQUEST (PA/CLEAR KEY)?
         BL    NOTGRAFC           NO, ASSUME QUERY NOT FUNCTIONAL
         CLI   BUFFER,X'6F'
         BL    QUERYGET           YES, IGNORE AND GET QUERY RESPONSE
         CLI   BUFFER,X'88'       QUERY RESPONSE AID?
         BNE   NOTGRAFC           NO, UNEXPECTED RESPONSE, FORGET QUERY
         SLR   R0,R0              CLEAR FOR INSERTS
         LA    R15,BUFFER         POINT TO THE AID
NOTSBFLD LA    R15,1(,R15)        IGNORE A BYTE
         BCT   R1,QUERYFIX        DECREMENT THE LENGTH
         B     NOTGRAFC           JUST IN CASE THAT WAS THE LAST BYTE
QUERYFIX TM    3(R15),X'80'       LOOK LIKE A VALID QCODE?
         BNO   NOTSBFLD           NO, SKIP A BYTE
         CLI   0(R15),0           LENGTH LESS THAN 256?
         BNE   NOTSBFLD           NO, SKIP A BYTE
QUERYPRS CLI   2(R15),X'81'       QUERY REPLY ID?
         BNE   NOTSBFLD           NO, SKIP A BYTE
         CLI   3(R15),X'86'       QUERY REPLY COLOUR ID?
         BE    QUERYCLR           YES, PROCESS COLOUR SUPPORT
         CLI   3(R15),X'87'       QUERY REPLY HIGHLIGHTING ID?
         BE    QUERYHLT           YES, PROCESS HIGHLIGHTING SUPPORT
         CLI   3(R15),X'85'       QUERY REPLY SYMBOL SETS ID?
         BE    QUERYSYM           YES, PROCESS SYMBOL SETS SUPPORT
         CLI   3(R15),X'93'       QUERY REPLY PC ATTACHMENT ID?
         BE    QUERYPCA           YES, PROCESS PC/PS2 3270 EMULATION
         CLI   3(R15),X'A6'       QUERY REPLY IMPLICIT PARTITION ID?
         BE    QUERYIMP           YES
NXTSBFLD ICM   R0,3,0(R15)        NO, LOAD SUB-FIELD LENGTH
         SR    R1,R0              SUBTRACT IT FROM TGET DATA LENGTH
         BZ    NOTGRAFC           END OF QUERY, INITIALIZATION DONE
         BM    QUERYGET           QUERY CONTINUES IN NEXT BLOCK
         AR    R15,R0             POINT TO NEXT SUB-FIELD
         B     QUERYPRS           EXAMINE IT
QUERYCLR CLI   5(R15),8           AT LEAST EIGHT COLOUR PAIRS?
         BL    NXTSBFLD           NO, NO 7-COLOUR SUPPORT
         CLC   8(14,R15),=CL14'11223344556677' YES, ALL 7 SUPPORTED?
         BNE   NXTSBFLD           NO, DON'T RESTORE 7-COLOUR MODE
         OI    WORMFLAG,GRAF      YES, ENABLE WORM GRAPHIC MODE
         OI    GRAFLAGS,COLR      FLAG COLOUR SUPPORT CERTAINTY
         B     NXTSBFLD           EXTENDED CAPABILITY NOW FLAGGED
QUERYHLT CLI   4(R15),4           AT LEAST FOUR HIGHLIGHTING PAIRS?
         BL    NXTSBFLD           NO, SO DO NOT FLAG IT
         CLC   7(6,R15),=CL6'112244' YO, BLINK, REVERSE, UNDERSCORE OK?
         BNE   NXTSBFLD           NO
         OI    GRAFLAGS,HLIT      YES, FLAG HILIGHTING SUPPORT
         B     NXTSBFLD           EXTENDED CAPABILITY NOW FLAGGED
QUERYSYM OI    GRAFLAGS,SYMSET    SYMBOL SETS SUB-FIELD RETURNED
         TM    4(R15),X'80'       IS GRAPHICS ESCAPE SUPPORTED?
         BZ    NXTSBFLD           NO, SO DO NOT FLAG IT
         OI    GRAFLAGS,GEOK      YES, FLAG GRAPHICS ESCAPE SUPPORT
         B     NXTSBFLD           EXTENDED CAPABILITY NOW FLAGGED
QUERYPCA OI    GRAFLAGS,PCAF      FLAG PC ATTACHMENT FACILITY TERMINAL
         B     NXTSBFLD
QUERYIMP OI    GRAFLAGS,IMPLIC    FLAG IMPLICIT PARTITION SUB-FIELD
         B     NXTSBFLD
NOTGRAFC STFSMODE ON,NOEDIT=NO    TURN OFF NOEDIT INPUT MODE
SKPQUERY LA    R0,X'28'           ASSUME IBM SET ATTRIBUTE TO BE USED
         TM    OSBITS,X'13'       IBM OS?    (HOPE NO-ONE RUNS SVS)
         BO    HAVESETA           YES, ASSUME NOT FACOM VDU ON MVS
         TM    GRAFLAGS,SYMSET+PCAF+IMPLIC   NON-FUJITSU DATA?
         BNZ   HAVESETA           YES, CAN'T BE FACOM HARDWARE
         LA    R0,X'0E'           USE FACOM SET ATTRIBUTE ORDER CODE
HAVESETA STC   R0,CMSGHDR         PUT CORRECT SA IN DATA STREAMS
         STC   R0,REVERSE
         STC   R0,BLUE
         STC   R0,RED
         STC   R0,PINK
         STC   R0,GREEN
         STC   R0,TURQ
         STC   R0,YELLOW
         STC   R0,WHITE
         STC   R0,CMSGTRLR
         STC   R0,UNDERSCR
         STC   R0,NOHILITE
         STC   R0,BLINKING
         STC   R0,RESETSA
         MVI   DTLSTART,C'X'      TOP LEFT CORNER OF BORDER
         LA    R1,DTLSTART
         L     R3,COLUMNS
         EX    R3,CHAREPET        REPEAT X'S TO MAKE TOP BORDER
         MVC   BUFFER(HDRLEN),BUFHDR
         TM    WORMFLG2,TEST      IN FOOD GENERATION TEST MODE?
         BZ    TITLEOK            NO
         MVC   BUFFER+SCORTITL(12),=C'FOOD-COVERAG'
TITLEOK  M     R2,MOVLINES        COLS TIMES NUMBER OF BLANK LINES
         ST    R3,ELIGIBLS        SAVE FOR LATER (VERT BORDRS WEIGHTED)
         L     R2,MOVLINES        GET NUMBER OF BLANK LINES
         L     R3,MOVECOLS        GET NUMBER OF BLANKS BETWEEN BORDERS
         BCTR  R3,0               LESS 1 FOR EXECUTE
         A     R1,COLUMNS
         LA    R1,1(,R1)          POINT TO FIRST BLANK INSIDE BORDER
BLNKLOOP MVI   0(R1),C' '
         EX    R3,CHAREPET        BLANK OUT DETAIL LINE
         ALR   R1,R3
         MVC   1(2,R1),=C'XX'     BORDER
         LA    R1,3(,R1)          POINT PAST BORDER
         BCT   R2,BLNKLOOP        PROCESS NEXT LINE
         BCTR  R1,0               POINT TO BOTTOM LEFT CORNER
         ST    R1,LASTLOOK
         LA    R3,2(,R3)          GET COLUMNS MINUS ONE
         EX    R3,CHAREPET        COMPLETE THE BORDER
         MVC   1(ACRNMLEN,R1),ACRNMMSG
         LA    R2,ACRNMLEN+1(,R1) SAVE BASE ADDRESS FOR DSPMDMSG
         ST    R2,LIFEADDR        SAVE ADDR OF LIFETIME COUNTDOWN - 1
         LA    R1,1(R3,R1)        POINT PAST BOTTOM RIGHT CORNER
         MVI   0(R1),X'13'        MOVE THE CURSOR OUT OF THE WAY
         LA    R1,1(,R1)          POINT PAST INSERT CURSOR
         LA    R0,BUFFER          POINT TO WCC
         SLR   R1,R0              GET SCREEN IMAGE SIZE
         ST    R1,IMAGESIZ        STORE IT FOR LATER USE
         MVC   15(DSPMDLEN,R2),DSPMDMSG
         LA    R1,DTLSTART-1      GET CONCEPTUAL SCREEN IMAGE ORIGIN
         SLR   R2,R1              GET OFFSET OF LIFETIME COUNTDOWN
         STH   R2,TOLOC
         BAL   R14,CALCPOSI       GET CODE FOR LIFETIME BUFFER ADDR
         STH   R0,LIFEBFAD
         L     R1,COLUMNS
         M     R0,LINES           GET THE NUMBER OF SCREEN LOCATIONS
         LA    R1,DTLSTART+17(R1) POINT PAST SCREEN IMAGE BUFFER
         SRL   R1,3
         SLL   R1,3               ALIGN ON DOUBLEWORD BOUNDARY
         ST    R1,LOOKAHED        SAVE LOOK-AHEAD WORK AREA ADDRESS
         LA    R1,BUFFER          POINT TO SCREEN IMAGE START
         L     R0,IMAGESIZ        GET DATA STREAM LENGTH
         ICM   R1,X'8',=X'03'     LOAD FULLSCREEN FLAGS
         TPUT  (1),(0),R          DISPLAY ENTIRE SCREEN IMAGE
         MVI   UPDTSTRM,X'40'     NULL WCC
         TM    WORMFLG2,TEST      IN TEST MODE?
         BO    TESTINIT           YES, DON'T MAKE A WORM
         MVI   UPDTSTRM+1,X'11'   FIRST ORDER IS SBA
         L     R1,LINES
         SRL   R1,1
         BCTR  R1,0
         BCTR  R1,0               GET INITIAL LINE NUMBER
         M     R0,COLUMNS
         LA    R1,10(,R1)
         STH   R1,TOLOC           TAIL AT SCREEN LINE 11 COLUMN 11
         STH   R1,TAILLOC         SAVE TAIL LOCATION
         LA    R1,DTLSTART(R1)    POINT TO CORRESPONDING POSI IN BUFFER
         ST    R1,TAILADDR        SAVE TAIL ADDRESS
         MVI   0(R1),X'96'        TAIL LINKS TO THE RIGHT
         MVC   1(6,R1),0(R1)      FILL IN INITIAL WORM
         MVI   7(R1),C'@'         WORM'S HEAD
         LA    R1,7(,R1)          POINT TO WORM'S HEAD
         ST    R1,HEADADDR        SAVE HEAD ADDRESS
         LH    R1,TAILLOC         GET TAIL LOCATION
         LA    R1,7(,R1)          POINT TO WORM'S HEAD
         STH   R1,HEADLOC         SAVE HEAD LOCATION
         BAL   R14,CALCPOSI       GET CODE FOR LINE 11 COLUMN 11
         STCM  R0,X'3',UPDTSTRM+2
         TM    WORMFLAG,GRAF      IN GRAPHIC MODE?
         BZ    NORMWORM           NO
         MVC   UPDTSTRM+4(3),WHITE
         MVI   UPDTSTRM+7,X'3C'   REPEAT TO ADDRESS
         STH   R1,TOLOC
         BAL   R14,CALCPOSI       GET CODE FOR LINE 11 COLUMN 18
         STCM  R0,X'3',UPDTSTRM+8
         MVI   UPDTSTRM+10,X'96'  JUST IN CASE...
         TM    GRAFLAGS,GEOK      TRANSMIT GRAPHIC ESCAPE?
         BZ    NOGEWORM           NO, SEND STANDARD CHARACTERS
         MVC   UPDTSTRM+10(4),=X'088F08A3'
         MVC   UPDTSTRM+14(4),STRMTRLR   ADD TRAILER FOOTPRINT
         LA    R0,18              GET DATA STREAM LENGTH
         B     SHOWWORM
NORMWORM MVI   UPDTSTRM+4,X'96'   WORM'S TAIL
         MVC   UPDTSTRM+5(6),UPDTSTRM+4  MIDDLE
NOGEWORM MVI   UPDTSTRM+11,C'@'   WORM'S HEAD
         MVC   UPDTSTRM+12(4),STRMTRLR   ADD TRAILER FOOTPRINT
         LA    R0,16              GET DATA STREAM LENGTH
SHOWWORM LA    R1,UPDTSTRM        POINT TO WORM DATA STREAM START
         ICM   R1,X'8',=X'03'     LOAD FULLSCREEN FLAGS
         TPUT  (1),(0),R          DISPLAY INITIAL WORM
TESTINIT LA    R0,1               RESET ACCUMULATED
         STH   R0,TPUTLEN               UPDATE DATA STREAM
         TITLE ' GENERATE A NEW TARGET '
NEWTARGT TIME  TU                 GET "RANDOM NUMBER" FOR TARGET DTLS
         TM    WORMFLAG,NEXT      IS NEXT TARGET NEEDED AFTER A MEAL?
         BZ    DONENEXT           NO, MUST BE IN FOOD GEN TEST MODE
         NI    WORMFLAG,255-NEXT  RESET NEXT-TARGET-NEEDED FLAG
         MVI   STACKER+3,0        RESET STACKED MOVE COUNTER
         L     R2,MEALCNTR        GET THE NUMBER OF WORM MEALS SO FAR
         LA    R2,1(,R2)          INCREMENT IT
         ST    R2,MEALCNTR        (NOT COUNTER MEAL) AND SAVE IT AGAIN
         L     R2,EATMOVES        GET MOVE COUNT FOR PREVIOUS MEALS
         A     R2,THISTREK        ADD MOVES FOR THIS MEAL
         ST    R2,EATMOVES
         SLR   R2,R2
         ST    R2,THISTREK        RESET MOVES-SINCE-LAST-MEAL COUNTER
DONENEXT L     R2,FOODCNTR        GET FOOD GENERATION COUNTER
         TM    WORMFLG2,TEST      IN FOOD GENERATION TEST MODE?
         BO    SHOWFOOD           YES, SO THERE IS NO REAL SCORE
         LH    R2,SCORE           GET THE SCORE
SHOWFOOD CVD   R2,WORK
         OI    WORK+7,X'0F'
         UNPK  BUFFER+SCORPOSI(4),WORK+5(3)
         LH    R8,TPUTLEN         DATA STREAM LENGTH SO FAR
         LA    R9,UPDTSTRM(R8)    CURRENT BUFFER POINTER
         MVC   0(3,R9),=X'114050' SBA, LINE 1 COLUMN 17
         LA    R8,3(,R8)          ADJUST DATA STREAM LENGTH COUNTER
         LA    R9,3(,R9)          ADJUST BUFFER POINTER
         TM    WORMFLAG,GRAF      IN GRAPHIC MODE?
         BZ    GOTWHITE           NO
         MVC   0(3,R9),WHITE      SA,COLOUR
         LA    R8,3(,R8)          INCREASE DATA STREAM LENGTH COUNTER
         LA    R9,3(,R9)          ADJUST BUFFER POINTER
GOTWHITE MVC   0(4,R9),BUFFER+SCORPOSI
         LA    R8,4(,R8)          INCREASE DATA STREAM LENGTH COUNTER
         LA    R9,4(,R9)          ADJUST BUFFER POINTER
         MVC   WORMCOLR,COLRCHAR  TAKE ON COLOUR OF LATEST FOOD
         SLR   R2,R2
         ICM   R2,1,THISCOLR      USER SPECIFIED COLOUR?
         BZ    GETCOLOR           NO, MAKE RANDOM SELECTION
         STC   R2,COLRCHAR        YES, USE IT - ONLY IN TEST MODE
         OI    COLRCHAR,X'F0'     CONVERT TO 3270 COLOUR CODE
         IC    R2,COLRCHAR        GET COLOUR FOR LATER
         B     COLORNEW           CONTINUE
GETCOLOR SLR   R2,R2              CLEAR FOR DIVIDE
         LR    R3,R0              USE CURRENT TIMER UNITS FOR RANDOM NO
         LA    R6,7               DIVIDE TIMER UNITS BY SEVEN AND
         DR    R2,R6              CONVERT 0 TO 6 REMAINDER TO
         SR    R6,R2              A 7 TO 1 NUMBER
         STC   R6,COLRCHAR        STORE NUMBER
         OI    COLRCHAR,X'F0'     CONVERT TO 3270 COLOUR CODE
         IC    R2,COLRCHAR        GET COLOUR FOR LATER
         CLM   R2,X'1',WORMCOLR   DID THE COLOUR CHANGE?
         BNE   COLORNEW           YES
         CLI   COLRCHAR,X'F7'     NO, IS IT WHITE?
         BL    COLROKAY           NO
         LA    R2,X'F0'           YES, RESET COLOUR
COLROKAY LA    R2,1(,R2)          INCREMENT COLOUR
         STC   R2,COLRCHAR        SAVE NEXT COLOUR
COLORNEW TM    WORMFLAG,GRAF      IN GRAPHIC MODE?
         BZ    GOTCOLOR           NO
         MVC   0(2,R9),WHITE      SA,COLOUR
         STC   R2,2(,R9)          USE LATEST COLOUR
         MVC   3(3,R9),REVERSE    SA,HILITE,REVERSE
         LA    R8,6(,R8)          INCREASE DATA STREAM LENGTH COUNTER
         LA    R9,6(,R9)          ADJUST BUFFER POINTER
GOTCOLOR LA    R3,X'F1'
         SR    R2,R3              CONVERT COLOUR CODE TO 0 TO 6
         SLL   R2,1               MULTIPLY BY TWO FOR HALFWORD INDEX
         LA    R3,COLOURS(R2)     POINT TO COUNTER OF CHOSEN COLOUR
         LH    R2,0(,R3)
         LA    R2,1(,R2)          INCREMENT THE COUNTER OF THIS COLOUR
         STH   R2,0(,R3)          - EVEN IF COLOURS ARE NOT USED
         SLR   R2,R2              CLEAR FOR DIVIDE
         LR    R3,R0              USE CURRENT TIMER UNITS FOR RANDOM NO
         D     R2,ELIGIBLS        DIVIDE BY # ELIGIBLES + VERT BORDERS
         LA    R4,DTLSTART
         AL    R4,COLUMNS         POINT TO FIRST BUFFER LINE AFTER BRDR
         NI    WORMFLG2,255-SSSS  TURN OFF START-SCREEN-SPACE-SCAN FLAG
GETEMPTY LA    R3,0(R2,R4)        POINT TO THE SELECTED BUFFER LOCATION
         CL    R3,LASTLOOK        GONE PAST BOTTOM RIGHT CORNER?
         BL    LOOKOKAY           NO, PROCEED AS PLANNED
         SLR   R2,R2              YES, START AGAIN FROM TOP LEFT CORNER
         TM    WORMFLG2,SSSS      DONE A WHOLE SCAN OF THE SCREEN?
         BO    AMAZING            YES, AVOID INFINITE LOOP BY ENDING
         OI    WORMFLG2,SSSS      TURN ON START-SCREEN-SPACE-SCAN FLAG
         B     GETEMPTY           WRAP-AROUND TO START OF SCREEN IMAGE
LOOKOKAY CLI   0(R3),C' '         IS IT EMPTY?
TST4EVER BE    GOTEMPTY           YES
         LA    R2,1(,R2)          NO, TRY NEXT ONE
         B     GETEMPTY
         SPACE
AMAZING  MVC   BUFFER+TITLPOSI(56),AMAZEMSG
         LA    R1,BUFFER          AMAZING!  NOWHERE TO PUT THE NUMBER
         LA    R0,TITLPOSI+56
         ICM   R1,X'8',=X'03'     LOAD FULLSCREEN FLAGS
         TPUT  (1),(0),R
         STIMER WAIT,BINTVL==F'500'  WAIT 5 SECONDS
         B     END                FORCED TO END THE GAME
         SPACE
GOTEMPTY L     R5,COLUMNS         ADJUST FOR TOP BORDER/INFO LINE
         ALR   R5,R2
         STH   R5,TOLOC
         STH   R5,NUMBRLOC        SAVE LOCATION OF NUMBER
         SLR   R4,R4              CLEAR FOR DIVIDE
         LR    R5,R0              USE CURRENT TIMR UNTS FOR RANDOM NO.
         LA    R6,9               DIVIDE TIMER UNITS BY NINE AND
         DR    R4,R6              CONVERT 0 TO 8 REMAINDER TO
         SR    R6,R4              A 9 TO 1 NUMBER
         MVI   0(R9),X'11'
         STC   R6,3(,R9)          PUT IT IN DATA STREAM
         OI    3(R9),X'F0'        MAKE PRINTABLE NUMERIC CHARACTER
         MVC   0(1,R3),3(R9)      UPDATE INCORE SCREEN IMAGE "COPY"
         BAL   R14,CALCPOSI       GET CODE FOR TARGET LOCATION
         STCM  R0,X'3',1(R9)
         LA    R8,4(,R8)          FINAL LENGTH OF DATA STREAM
         STH   R8,TPUTLEN         ACCUMULATE DATA STREAM LENGTH
         A     R6,FOODVALU        ACCUMULATE FOOD VALUE
         ST    R6,FOODVALU
         LA    R0,1
         A     R0,FOODCNTR        INCREMENT FOOD GENERATION COUNTER
         ST    R0,FOODCNTR
         B     FORTUNE            ENSURE THE SCREEN IS UPDATED
         TITLE ' FULLSCREEN TERMINAL I/O '
TPUTSOME ICM   R5,X'F',STACKER    CURRENTLY RUNNING?
         BNZ   ACCUMPUT           YES, SHOW WHOLE SPRINT IN ONE TPUT
         CLC   TPUTLEN,MAXACCUM   IS THE DATA STREAM A BIT LONGISH?
         BH    FORTUNE            YES, BETTER SEND IT
         CLI   FUTRCOLR,X'F6'     CONDITION YELLOW?
         BH    FORTUNE            YES, BETTER SEND IT
         TM    WORMFLAG,AUTO+BURST IN BURST MODE? (BURST-MUST-COMPLETE)
         BO    ACCUMPUT           YES, DON'T DO A TPUT YET
FORTUNE  TM    WORMFLG2,FRTN      IN FORTUNE-TELLING MODE?
         BZ    FORCEPUT           NO
         LH    R8,TPUTLEN         GET CURRENT TPUT LENGTH
         LA    R9,UPDTSTRM(R8)    POINT TO CURRENT BUFFER POSITION
         MVI   0(R9),X'11'        SBA
         MVC   1(2,R9),LIFEBFAD
         LA    R0,3               EXTRA DATA STREAM LENGTH SO FAR
         L     R1,LIFEADDR        POINT TO COUNTER IN SCREEN IMAGE
         TM    WORMFLAG,GRAF      GRAPHIC MODE ON?
         BZ    NODEDCLR           NO, NO COLOUR FOR THE FUTURE
         MVC   3(2,R9),WHITE      SA,COLOUR
         MVC   5(1,R9),FUTRCOLR   SUPPLY THE PROMISE OF THINGS TO COME
         LA    R0,6               EXTRA DATA STREAM LENGTH SO FAR
         CLI   1(R1),C'X'         IS THERE A COUNTER?
         BNE   NODEDCLR           YES, DO NOT DEFAULT THE ATTRIBUTES
         STCM  R0,X'C',4(R9)      MAKE IT SA,NULL,NULL (SA,ALL,DEFAULT)
NODEDCLR ALR   R8,R0              ADJUST DATA STREAM LENGTH
         ALR   R9,R0              ADJUST BUFFER POINTER
         MVC   0(13,R9),1(R1)     LOAD IT INTO DATA STREAM
         LA    R8,13(,R8)         ADJUST DATA STREAM LENGTH
         STH   R8,TPUTLEN         ACCUMULATE DATA STREAM LENGTH
         CLI   1(R1),C'X'         IS THERE A COUNTER?
         BNE   FORCEPUT           YES, WELL WORTH SHOWING IT
         NI    WORMFLG2,255-FRTN  NO, DON'T BOTHER IN FUTURE
FORCEPUT TIME  BIN                GET THE TIME BEFORE THE TPUT STARTS
         LR    R2,R0              COPY IT
         LH    R1,TPUTLEN         GET DATA STREAM LENGTH SO FAR
         LA    R1,UPDTSTRM(R1)    POINT PAST END OF DATA STREAM
         MVC   0(4,R1),STRMTRLR   TACK ON DATA STREAM TRAILER FOOTPRINT
         LA    R0,4               LOAD DATA STREAM SUFFIX LENGTH
         LA    R1,UPDTSTRM        POINT TO WORM DATA STREAM START
         AH    R0,TPUTLEN         GET DATA STREAM LENGTH
         MVI   0(R1),X'40'        NULL WCC AS DEFAULT
         TM    WORMFLG2,LOCKED    IS THE KEYBOARD LOCKED?
         BZ    PUTREADY           NO, ISSUE UPDATES
         MVI   0(R1),X'C3'        YES, UNLOCK IT, RESET MDT AND AID
         NI    WORMFLG2,255-LOCKED     KEYBOARD WILL BE UNLOCKED
PUTREADY ICM   R1,X'8',=X'0B'     LOAD FULLSCREEN,HOLD FLAGS
         TPUT  (1),(0),R          DISPLAY LATEST SCREEN UPDATES
         BAL   R14,WOORM          CALL WOORM
         LA    R0,1               RESET ACCUMULATED
         STH   R0,TPUTLEN               UPDATE DATA STREAM
         TM    GRAFLAGS,RVRS      IN REVERSE? (VIDEO, NOT GEAR)
         BZ    ACCUMPUT           NO
         MVC   UPDTSTRM+1(3),REVERSE
         MVI   TPUTLEN+1,4        YES
ACCUMPUT ICM   R5,X'1',DIRCTION   GET DIRECTION - MOVING YET?
         BZ    STILSTIL           NO, DON'T ERASE INITIAL VALUE
         STC   R5,PREVMOVE        YES, REMEMBER LAST MOVE DIRECTION
         TM    WORMFLG2,ATTN      HAS THE ATTENTION BUTTON BEEN HIT?
         BO    STANDUP            YES, DEAL WITH IT
STILSTIL TM    WORMFLAG,NEXT      NEXT TARGET REQUIRED?
         BO    NEWTARGT           YES, GET IT
         TM    WORMFLG2,TEST      IN FOOD GENERATION TEST MODE?
         BO    TGETTEST           YES, FORGET ABOUT A MOVING WORM
         ICM   R5,X'F',STACKER    NO, CURRENTLY RUNNING?
         BNZ   SKIPTGET           YES, NO MANUAL INTERVENTION ALLOWED
TGETSOME LA    R5,10
         TM    WORMFLAG,AUTO      IN AUTO MODE?
         BZ    TGETLOOP           NO
         TM    OSBITS,X'13'       YES, IS THIS OS/VS2 MVS?
         BNO   AUTOPLOT           NO, TGET NOWAIT NOT SUPPORTED
         LA    R5,2               YES, MOVE A BIT FASTER FOR WORMOMATIC
TGETLOOP LA    R1,WORK
         LA    R0,8
         ICM   R1,X'8',TGETFLAG   LOAD TGET FLAGS
         TGET  (1),(0),R
         CH    R15,=H'4'          NO DATA BECAUSE OF NOWAIT?
         BNE   TGOTSOME           NO, LOOK AT DATA
         TM    WORMFLAG,AUTO+BLITZ    IN FAST AUTO MODE?
         BO    TPUTDECR           YES, SKIP WAIT
         STIMER WAIT,BINTVL=DELAY NO, WAIT A TENTH OF A SECOND
         BCT   R5,TGETLOOP        SEE IF ANY INPUT THIS TIME
TPUTDECR ICM   R5,X'F',TCTADDR    GET TCT ADDRESS IF APF AUTHORIZED
         BZ    DONEDECR           HAVEN'T GOT IT SO SKIP ALL THIS
         ICM   R0,X'F',TPUTHOLD   BEEN HERE BEFORE?
         BZ    FIRSTFIX           NO, SET THINGS UP FOR NEXT TIME
         CLC   TPUTHOLD,52(R5)    HAS THE TPUT COUNT INCREASED?
         BNL   DONEDECR           NO, NO FUDGING REQUIRED
         MODESET MF=(E,MDSTSUPZ)
         L     R1,52(,R5)         GET CURRENT TPUT COUNT
         BCTR  R1,0               DECREMENT IT
         ST    R1,52(,R5)         SAVE IT
         L     R1,DECRCNTR        GET DECREMENT COUNTER
         LA    R1,1(,R1)          INCREMENT DECREMENT COUNTER
         ST    R1,DECRCNTR        SAVE IT
         STNSM ENABINTZ+1,X'04'   DISABLE INTERRUPTS
         L     R1,548             POINT TO THE CURRENT ASCB
         L     R1,148(,R1)        POINT TO THE OUXB
         L     R5,88(,R1)         GET CURRENT TSO TRANSACTION COUNT
         BCTR  R5,0               DECREMENT IT
         ST    R5,88(,R1)         SAVE IT
ENABINTZ STOSM ENABINTZ+1,X'07'   ENABLE INTERRUPTS
         MODESET MF=(E,MDSTPRBN)
DONEDECR TM    WORMFLAG,AUTO      IN AUTO MODE?
         BO    AUTOPLOT           YES, CALL SUBROUTINE
         B     MOVETAIL           NO, A SECOND IS UP, GET MOVING
FIRSTFIX MVC   TPUTHOLD,52(R5)    SAVE CURRENT TPUT COUNT
         B     DONEDECR           DON'T DECREMENT IT THE FIRST TIME
         SPACE
SKIPTGET BCTR  R5,0               DECREMENT STACKED NUMBER
         ST    R5,STACKER         SAVE NEW VALUE
         B     MOVETAIL           GET MOVING
TGOTSOME OI    WORMFLG2,LOCKED    KEYBOARD NOW LOCKED
         CLI   WORK,X'6B'
         BL    NOTPAKEY
         CLI   WORK,X'6E'
         BH    NOTPAKEY           NOT PA1, PA2, PA3 OR CLEAR
RESHOW   SLR   R15,R15
         TM    WORMFLAG,GRAF      IN GRAPHIC MODE?
         BZ    DORESHOW           NO, JUST SHOW NORMAL CHARACTERS
         L     R15,IMAGESIZ       YES, GET SIZE OF NORMAL SCREEN IMAGE
         LA    R15,BUFFER(R15)    POINT TO AFTER NORMAL SCREEN IMAGE
         LH    R1,NUMBRLOC        GET FOOD LOCATION
         STH   R1,TOLOC
         BAL   R14,CALCPOSI       GET CODE FOR NUMBER LOCATION
         MVI   0(R15),X'11'       SET BUFFER ADDRESS
         STCM  R0,X'3',1(R15)
         MVC   3(3,R15),REVERSE   SA,HILITE,REVERSE
         MVC   6(2,R15),WHITE     SA,COLOUR
         MVC   8(1,R15),COLRCHAR  LOAD THE TARGET'S COLOUR
         LA    R1,DTLSTART(R1)    POINT TO NUMBER
         MVC   9(1,R15),0(R1)     LOAD NUMBER
         LA    R15,10             GET LENGTH OF EXTRA DATA
DORESHOW TM    WORMFLG2,TEST      IN FOOD GENERATION TEST MODE?
         BO    REDASHED           YES, RESHOW AS IT IS IN THE BUFFER
         TM    WORMFLAG,LINE      NO, IS LINE MODE ON?
         BZ    REDASHED           NO, RESHOW AS IT IS IN THE BUFFER
         L     R1,TAILADDR        YES, POINT TO TAIL IN BUFFER
OH2GO    CLI   0(R1),X'96'        LOWER CASE 'O'?
         BNE   ES2GO              NO
         MVI   0(R1),C'-'         YES, CHANGE TO A DASH
         LA    R1,1(,R1)          POINT TO NEXT POSITION
         B     OH2GO              CHECK THIS ONE
ES2GO    CLI   0(R1),X'A2'        LOWER CASE 'S'?
         BNE   SEE2GO             NO
         MVI   0(R1),C'_'         YES, CHANGE TO A DASH
         BCTR  R1,0               POINT TO NEXT POSITION
         B     OH2GO              CHECK THIS ONE
SEE2GO   CLI   0(R1),X'83'        LOWER CASE 'C'?
         BNE   YOU2GO             NO
         MVI   0(R1),C'|'         YES, CHANGE TO A LINE
         AL    R1,COLUMNS         POINT TO NEXT POSITION
         B     OH2GO              CHECK THIS ONE
YOU2GO   CLI   0(R1),X'A4'        LOWER CASE 'U'?
         BNE   REDASHED           NO, DISPLAY THE BUFFER
         MVI   0(R1),C'¦'         YES, CHANGE TO A LINE
         SL    R1,COLUMNS         POINT TO NEXT POSITION
         B     OH2GO              CHECK THIS ONE
REDASHED LA    R1,BUFFER          POINT TO SCREEN IMAGE START
         L     R0,IMAGESIZ        GET DATA STREAM LENGTH
         AR    R0,R15             ADD ANY EXTRA GRAPHIC DATA
         ICM   R1,X'8',=X'0B'     LOAD FULLSCREEN,HOLD FLAGS
         TPUT  (1),(0),R          REFRESH ENTIRE SCREEN IMAGE
         NI    WORMFLG2,255-LOCKED        KEYBOARD IS NOW UNLOCKED
         TM    WORMFLG2,TEST      IN FOOD GENERATION TEST MODE?
         BO    TGETTEST           YES, RESTART TEST INPUT CYCLE
         TM    WORMFLAG,LINE      NO, IS LINE MODE ON?
         BZ    TGETSOME           NO, RESTART INPUT CYCLE
         L     R1,TAILADDR        YES, POINT TO TAIL IN BUFFER
DASH2GO  CLI   0(R1),C'-'         DASH?
         BNE   USCR2GO            NO
         MVI   0(R1),X'96'        YES, CHANGE TO A LOWER CASE 'O'
         LA    R1,1(,R1)          POINT TO NEXT POSITION
         B     DASH2GO            CHECK THIS ONE
USCR2GO  CLI   0(R1),C'_'         DASH?
         BNE   BRKN2GO            NO
         MVI   0(R1),X'A2'        YES, CHANGE TO A LOWER CASE 'S'
         BCTR  R1,0               POINT TO NEXT POSITION
         B     DASH2GO            CHECK THIS ONE
BRKN2GO  CLI   0(R1),C'¦'         LINE?
         BNE   OR2GO              NO
         MVI   0(R1),X'A4'        YES, CHANGE TO A LOWER CASE 'U'
         SL    R1,COLUMNS         POINT TO NEXT POSITION
         B     DASH2GO            CHECK THIS ONE
OR2GO    CLI   0(R1),C'|'         LINE?
         BNE   TGETSOME           NO, RESTORE DONE - START INPUT CYCLE
         MVI   0(R1),X'83'        YES, CHANGE TO A LOWER CASE 'C'
         AL    R1,COLUMNS         POINT TO NEXT POSITION
         B     DASH2GO            CHECK THIS ONE
         SPACE
STANDUP  DS    0H                 ATTENTION HANDLER
         STFSMODE ON,NOEDIT=NO    RESTORE VTAM FULL SCREEN MODE
         NI    WORMFLAG,255-AUTO-BLITZ    ATTENTION STOPS WORMOMATIC
         NI    WORMFLG2,255-ATTN  RESET THE ATTENTION FLAG
         MVC   BUFFER+TITLPOSI(56),STARTHDR   RESTORE PFK HEADING
         L     R1,LIFEADDR        POINT TO LIFETIME-LEFT COUNTER
         MVC   1(13,R1),0(R1)     ERASE WITH X'S
         B     RESHOW             REFRESH THE ERASED SCREEN IMAGE
         SPACE
SHOWFAIL LA    R1,BUFFER          POINT TO SCREEN IMAGE START
         L     R0,IMAGESIZ        GET DATA STREAM LENGTH
         ICM   R1,X'8',=X'0B'     LOAD FULLSCREEN,HOLD FLAGS
         TPUT  (1),(0),R          REFRESH ENTIRE SCREEN IMAGE
         STIMER WAIT,BINTVL==F'6000'      WAIT A MINUTE FOR EXAMINATION
         DC    H'0'               CRASH
         SPACE
TGETTEST TM    OSBITS,X'13'       IS THIS OS/VS2 MVS?
         BO    TGETFOOD           YES
         TM    WORMFLAG,AUTO      NO, IN AUTO MODE?
         BO    NEWTARGT           YES, LOCKED IN
TGETFOOD LA    R5,2               TEST MODE TGETS DONE HERE
         LA    R1,WORK
         LA    R0,8
         ICM   R1,X'8',TGETFLAG   LOAD TGET FLAGS
         TGET  (1),(0),R
         CH    R15,=H'4'          NO DATA BECAUSE OF NOWAIT?
         BNE   TGOTTEST           NO, LOOK AT DATA
         TM    WORMFLAG,AUTO+BLITZ    IN FAST AUTO MODE?
         BO    NEWTARGT           YES, SKIP WAIT
         STIMER WAIT,BINTVL=DELAY NO, WAIT A TENTH OF A SECOND
         BCT   R5,TGETLOOP        SEE IF ANY INPUT THIS TIME
         B     NEWTARGT           TIME FOR MORE FOOD
TGOTTEST OI    WORMFLG2,LOCKED    KEYBOARD NOW LOCKED
         CLI   WORK,X'6B'
         BL    NOTPAKEY
         CLI   WORK,X'6F'
         BL    RESHOW             PA1, PA2, PA3 OR CLEAR
         SPACE
NOTPAKEY NI    WORK,X'0F'         FOLD PF KEYS (1-12 = 13-24)
         CLI   WORK,1             CAW?  (COMPUTER AIDED WORMING?)
         BE    AUTOMODE           YES, GET INTO AUTOMATIC MODE
         CLI   WORK,2             CHANGE DEBUG MODE?
         BE    DEBUG              YES
         CLI   WORK,3             END?
         BE    END                YES
         CLI   WORK,4             CHANGE GRAPHIC CHARACTERS?
         BE    GRAFLINE           YES
         CLI   WORK,5             CHANGE BURST MODE?
         BE    SPURT              YES
         CLI   WORK,6             CHANGE GRAPHIC MODE?
         BE    GRAPHIC            YES
         CLI   WORK,12            CANCEL?
         BE    CANCEL             YES
         TM    WORMFLG2,TEST      IN FOOD GENERATION TEST MODE?
         BO    NEWTARGT           YES, GO TEST IT
         TM    WORMFLAG,AUTO      IS WORMOMATIC ACTIVE?
         BZ    INMANUAL           NO, IN MANUAL MODE
         NI    WORMFLAG,255-AUTO-BLITZ  TERMINAL INPUT STOPS AUTO MODE
         MVC   BUFFER+TITLPOSI+2(4),STARTHDR+2 =C'AUTO'
         LH    R8,TPUTLEN         LENGTH OF DATA STREAM SO FAR
         LA    R9,UPDTSTRM(R8)    GET CURRENT BUFFER POINTER
         SLR   R1,R1              GET ZERO
         MVC   0(6,R9),PF1MSGBA   SBA,(1,23),SA,ALL,DEFAULT
         TM    WORMFLAG,GRAF      IN GRAPHIC MODE?
         BZ    NGTITLE1           NO
         LA    R1,3               EXTRA THREE, DON'T ERASE RESETSA
NGTITLE1 LA    R8,3(R1,R8)        INCREASE DATA STREAM LENGTH COUNTER
         LA    R9,3(R1,R9)        ADJUST BUFFER POINTER
         MVC   0(4,R9),BUFFER+TITLPOSI+2 =C'AUTO'
         LA    R8,4(,R8)          INCREASE DATA STREAM LENGTH COUNTER
         STH   R8,TPUTLEN         ACCUMULATE DATA STREAM LENGTH
         L     R1,LIFEADDR        POINT TO LIFETIME-LEFT COUNTER
         MVC   1(13,R1),0(R1)     ERASE WITH X'S
         TM    GRAFLAGS,RVRS      IN REVERSE? (VIDEO, NOT GEAR)
         BZ    INMANUAL           NO
         MVC   4(3,R9),REVERSE    YES, RESTORE IT
         LA    R8,3(,R8)          INCREASE DATA STREAM LENGTH COUNTER
         STH   R8,TPUTLEN         ACCUMULATE DATA STREAM LENGTH
INMANUAL CLI   WORK,7             UP?
         BE    UP                 YES
         CLI   WORK,8             DOWN?
         BE    DOWN               YES
         CLI   WORK,10            LEFT?
         BE    LEFT               YES
         CLI   WORK,11            RIGHT?
         BE    RIGHT              YES
MOVECHEK CLI   DIRCTION,0         CURRENTLY MOVING?
         BE    TGETLOOP           NO, WAIT FOR DIRECTION INTRUCTIONS
         CLI   WORK,9             RUN 8?
         BNE   MOVETAIL           NO
         MVI   STACKER+3,8        STACK UP EIGHT MOVES
         TITLE ' PERFORM A MOVE '
MOVETAIL L     R2,THISTREK        GET MOVES-SINCE-LAST-MEAL COUNTER
         LA    R2,1(,R2)          LET'S HOPE A MOVE CLOSER TO THE NEXT
         ST    R2,THISTREK        (I'M HUNGRY!)
         LH    R8,TPUTLEN         LENGTH OF DATA STREAM SO FAR
         LA    R9,UPDTSTRM(R8)    GET CURRENT BUFFER POINTER
         ICM   R2,X'F',GROWSIZE   EATEN RECENTLY?
         BNZ   GROWTAIL           YES, GROW A BIT
         MVI   0(R9),X'11'        NO, SBA TO START DATA STREAM UPDATE
         LH    R2,TAILLOC         GET OLD TAIL LOCATION
         STH   R2,TOLOC
         BAL   R14,CALCPOSI       GET CODE FOR OLD TAIL LOCATION
         STCM  R0,X'3',1(R9)
         MVI   3(R9),C' '         BLANK OLD TAIL
         LA    R8,4(,R8)          INCREASE DATA STREAM LENGTH COUNTER
         LA    R9,4(,R9)          ADJUST BUFFER POINTER
         L     R1,TAILADDR        POINT TO TAIL IN BUFFER
         CLI   0(R1),X'A4'        TAIL TO GO UP?
         BE    TAILUP             YES
         CLI   0(R1),X'83'        TAIL TO GO DOWN?
         BE    TAILDOWN           YES
         CLI   0(R1),X'A2'        TAIL TO GO LEFT?
         BE    TAILLEFT           YES
         CLI   0(R1),X'96'        TAIL TO GO RIGHT?
         BE    TAILRITE           YES
         MVI   BUFFER+FLGPOS,C'1' TRAP ERROR
         B     SHOWFAIL           SHOW CURRENT STATUS
TAILRITE MVI   0(R1),C' '         BLANK OLD TAIL
         LA    R2,1(,R2)          ADD 1 TO LOCATION
         LA    R1,1(,R1)          POINT TO NEW TAIL
         B     TAILDONE           NEW TAIL POSITIONS NOW CALCULATED
TAILLEFT MVI   0(R1),C' '         BLANK OLD TAIL
         BCTR  R2,0               SUBTRACT 1 FROM LOCATION
         BCTR  R1,0               POINT TO NEW TAIL
         B     TAILDONE           NEW TAIL POSITIONS NOW CALCULATED
TAILDOWN MVI   0(R1),C' '         BLANK OLD TAIL
         AL    R2,COLUMNS         ADD A WHOLE LINE TO LOCATION
         AL    R1,COLUMNS         POINT TO NEW TAIL
         B     TAILDONE           NEW TAIL POSITIONS NOW CALCULATED
TAILUP   MVI   0(R1),C' '         BLANK OLD TAIL
         SL    R2,COLUMNS         SUBTRACT A WHOLE LINE FROM LOCATION
         SL    R1,COLUMNS         POINT TO NEW TAIL
TAILDONE ST    R1,TAILADDR        STORE NEW TAIL ADDRESS
         STH   R2,TAILLOC         STORE NEW TAIL LOCATION
         B     MOVEHEAD           NOW MOVE THE HEAD
         SPACE 2
GRAPHIC  DS    0H                 ALLOW QUERY BIT OVERRIDE
         XI    WORMFLAG,GRAF      TOGGLE GRAPHIC MODE BIT
         TM    WORMFLAG,GRAF      NOW ON?
         BZ    RESHOW             NO, ERASE GRAPHIC CHARACTERS
GRAFREFR LH    R8,TPUTLEN         LENGTH OF DATA STREAM SO FAR
         LA    R9,UPDTSTRM(R8)    GET CURRENT BUFFER POINTER
         MVI   0(R9),X'11'        SBA
         LH    R1,NUMBRLOC        GET FOOD LOCATION
         STH   R1,TOLOC
         BAL   R14,CALCPOSI       GET CODE FOR NUMBER LOCATION
         STCM  R0,X'3',1(R9)
         MVC   3(3,R9),REVERSE    SA,HILITE,REVERSE
         MVC   6(2,R9),WHITE      SA,COLOUR
         MVC   8(1,R9),COLRCHAR   LOAD THE TARGET'S COLOUR
         LA    R1,DTLSTART(R1)    POINT TO NUMBER
         MVC   9(1,R9),0(R1)      LOAD NUMBER
         LA    R0,10(,R8)         GET LENGTH OF DATA STREAM SO FAR
         CLI   TGETFLAG,X'81'     IS WORM IN THE STARTING POSITION?
         BNE   COLORNUM           NO, JUST REFRESH THE NUMBER
         TM    WORMFLG2,TEST      YES, IN FOOD GENERATION TEST MODE?
         BO    COLORNUM           YES, JUST REFRESH THE NUMBER
         TM    GRAFLAGS,GEOK      TRANSMIT GRAPHIC ESCAPE?
         BZ    RESHOW             NO, SEND STANDARD CHARACTERS
         MVC   TOLOC,TAILLOC      NO, GET TAIL LOCATION FOR RESHOW
         BAL   R14,CALCPOSI       GET CODE FOR INITIAL TAIL LOCATION
         MVI   10(R9),X'11'       SBA
         STCM  R0,X'3',11(R9)
         MVC   13(3,R9),NOHILITE  SA,HILITE,DEFAULT
         MVC   16(3,R9),WHITE     SA,COLOUR,WHITE (INIT COLOUR)
*        MVC   18(1,R9),WORMCOLR  INITIAL COLOUR OF WORM
         MVI   19(R9),X'3C'       REPEAT TO ADDRESS
         MVC   TOLOC,HEADLOC      YES, GET HEAD LOCATION FOR RESHOW
         BAL   R14,CALCPOSI       GET CODE FOR INITIAL HEAD LOCATION
         STCM  R0,X'3',20(R9)
         MVC   22(4,R9),=X'088F08A3'
         TM    WORMFLAG,LINE      IS GRAPHIC "LINE" MODE ON?
         BZ    INITWORM           NO, RESHOW INITIAL WORM WITH ARROWS
         MVI   23(R9),X'A2'       WORM'S BODYLINE (JUST NOT CRICKET)
         MVI   25(R9),X'C3'       WORM'S BLOCKHEAD
INITWORM LA    R0,26(,R8)         GET DATA STREAM LENGTH
COLORNUM LR    R1,R0              GET CALCULATED DATA STREAM LENGTH
         LA    R1,UPDTSTRM(R1)    POINT PAST END OF DATA STREAM
         MVC   0(4,R1),STRMTRLR   TACK ON DATA STREAM TRAILER FOOTPRINT
         LA    R1,4               LOAD DATA STREAM SUFFIX LENGTH
         AR    R0,R1              GET FINAL TPUT DATA STREAM LENGTH
         LA    R1,UPDTSTRM        POINT TO WORM DATA STREAM START
         ICM   R1,X'8',=X'0B'     LOAD FULLSCREEN,HOLD FLAGS
         TPUT  (1),(0),R          DISPLAY GRAPHIC MODE INITIAL WORM
         LA    R0,1               RESET ACCUMULATED
         STH   R0,TPUTLEN               UPDATE DATA STREAM
         TM    WORMFLG2,TEST      IN FOOD GENERATION TEST MODE?
         BO    TGETTEST           YES, RESTART TEST INPUT CYCLE
         TM    GRAFLAGS,RVRS      IN REVERSE? (VIDEO, NOT GEAR)
         BZ    TGETSOME           NO
         MVC   UPDTSTRM+1(3),REVERSE
         MVI   TPUTLEN+1,4        YES
         B     TGETSOME           GET ANOTHER CHANCE BEFORE A MOVE
         SPACE
GRAFLINE XI    WORMFLAG,LINE      TOGGLE GRAPHIC "CHARACTER SET" BIT
         TM    WORMFLG2,TEST      IN FOOD GENERATION TEST MODE?
         BO    TGETTEST           YES, NO CHANGE TO SCREEN IMAGE
         TM    WORMFLAG,GRAF      NO, IS GRAPHIC MODE ON?
         BO    GRAFREFR           YES, DO REFRESH FOR INITIAL WORM ONLY
         TM    WORMFLAG,LINE      NO, IS LINE MODE ON?
         BZ    DASHED             NO, RESHOW AS IT IS IN THE BUFFER
         L     R1,TAILADDR        POINT TO TAIL IN BUFFER
OHTOGO   CLI   0(R1),X'96'        LOWER CASE 'O'?
         BNE   ESTOGO             NO
         MVI   0(R1),C'-'         YES, CHANGE TO A DASH
         LA    R1,1(,R1)          POINT TO NEXT POSITION
         B     OHTOGO             CHECK THIS ONE
ESTOGO   CLI   0(R1),X'A2'        LOWER CASE 'S'?
         BNE   SEETOGO            NO
         MVI   0(R1),C'_'         YES, CHANGE TO A DASH
         BCTR  R1,0               POINT TO NEXT POSITION
         B     OHTOGO             CHECK THIS ONE
SEETOGO  CLI   0(R1),X'83'        LOWER CASE 'C'?
         BNE   YOUTOGO            NO
         MVI   0(R1),C'|'         YES, CHANGE TO A LINE
         AL    R1,COLUMNS         POINT TO NEXT POSITION
         B     OHTOGO             CHECK THIS ONE
YOUTOGO  CLI   0(R1),X'A4'        LOWER CASE 'U'?
         BNE   DASHED             NO, DISPLAY THE BUFFER
         MVI   0(R1),C'¦'         YES, CHANGE TO A LINE
         SL    R1,COLUMNS         POINT TO NEXT POSITION
         B     OHTOGO             CHECK THIS ONE
DASHED   LA    R1,BUFFER          POINT TO SCREEN IMAGE START
         L     R0,IMAGESIZ        GET DATA STREAM LENGTH
         ICM   R1,X'8',=X'0B'     LOAD FULLSCREEN,HOLD FLAGS
         TPUT  (1),(0),R          REFRESH ENTIRE SCREEN IMAGE
         NI    WORMFLG2,255-LOCKED        KEYBOARD IS NOW UNLOCKED
         L     R1,TAILADDR        POINT TO TAIL IN BUFFER
DASHTOGO CLI   0(R1),C'-'         DASH?
         BNE   USCRTOGO           NO
         MVI   0(R1),X'96'        YES, CHANGE TO A LOWER CASE 'O'
         LA    R1,1(,R1)          POINT TO NEXT POSITION
         B     DASHTOGO           CHECK THIS ONE
USCRTOGO CLI   0(R1),C'_'         DASH?
         BNE   BRKNTOGO           NO
         MVI   0(R1),X'A2'        YES, CHANGE TO A LOWER CASE 'S'
         BCTR  R1,0               POINT TO NEXT POSITION
         B     DASHTOGO           CHECK THIS ONE
BRKNTOGO CLI   0(R1),C'¦'         LINE?
         BNE   ORTOGO             NO
         MVI   0(R1),X'A4'        YES, CHANGE TO A LOWER CASE 'U'
         SL    R1,COLUMNS         POINT TO NEXT POSITION
         B     DASHTOGO           CHECK THIS ONE
ORTOGO   CLI   0(R1),C'|'         LINE?
         BNE   TGETSOME           NO, RESTORE DONE - READY FOR A MOVE
         MVI   0(R1),X'83'        YES, CHANGE TO A LOWER CASE 'C'
         AL    R1,COLUMNS         POINT TO NEXT POSITION
         B     DASHTOGO           CHECK THIS ONE
         SPACE
SPURT    XI    WORMFLAG,BURST     TOGGLE "BURST MODE" BIT
         B     TGETSOME           NO CHANGE TO SCREEN IMAGE
         SPACE
DEBUG    TM    WORMFLAG,BURST     IN BURST MODE?
*        BO    REVRSEIT           YES, NOT REALLY A DEBUG REQUEST
         B     REVRSEIT           DISABLE DEBUG MODE CAPABILITY
         XI    WORMFLAG,DBUG      NO, TOGGLE DEBUG MODE BIT
         B     TGETSOME           GET ANOTHER CHANCE BEFORE A MOVE
         SPACE
REVRSEIT TM    GRAFLAGS,HLIT      ABSENCE OF HILIGHT SUPPORT VERIFIED?
         BZ    TGETSOME           YES, DON'T CAUSE DATA STREAM ERRORS
         XI    GRAFLAGS,RVRS      TOGGLE REVERSE VIDEO BIT
         B     TGETSOME           GET ANOTHER CHANCE BEFORE A MOVE
         SPACE 2
GROWTAIL BCTR  R2,0               DECREMENT SIZE-TO-GROW COUNTER
         ST    R2,GROWSIZE
         SPACE
MOVEHEAD TM    WORMFLAG,GRAF      IN GRAPHIC MODE?
         BZ    GTWRMCLR           NO
         MVC   0(2,R9),WHITE      SA,COLOUR
         MVC   2(1,R9),WORMCOLR   SUPPLY COLOUR CODE
         LA    R8,3(,R8)          INCREASE DATA STREAM LENGTH COUNTER
         LA    R9,3(,R9)          ADJUST BUFFER POINTER
GTWRMCLR LH    R2,HEADLOC         GET OLD HEAD LOCATION
         STH   R2,TOLOC
         BAL   R14,CALCPOSI       GET CODE FOR OLD HEAD LOCATION
         MVI   0(R9),X'11'        SBA
         STCM  R0,X'3',1(R9)
         L     R1,HEADADDR        POINT TO HEAD IN BUFFER
         CLI   DIRCTION,X'A4'     CURRENTLY MOVING UP?
         BE    HEADUP
         CLI   DIRCTION,X'83'     CURRENTLY MOVING DOWN?
         BE    HEADDOWN
         CLI   DIRCTION,X'A2'     CURRENTLY MOVING LEFT?
         BE    HEADLEFT
         CLI   DIRCTION,X'96'     CURRENTLY MOVING RIGHT?
         BE    HEADRITE
         MVI   BUFFER+FLGPOS,C'2' TRAP ERROR
         B     SHOWFAIL           SHOW CURRENT STATUS
HEADRITE MVI   RTORLFT,X'96'      LATEST HORIZONTAL MOVE IS RIGHT
         MVI   3(R9),X'96'        OVERWRITE OLD HEAD
         MVI   0(R1),X'96'        OVERWRITE OLD HEAD IN BUFFER
         LA    R1,1(,R1)          POINT TO NEW HEAD ADDRESS
         ST    R1,HEADADDR
         LA    R2,1(,R2)          NO, MUST BE RIGHT, ADD 1 TO LOCATION
         STH   R2,HEADLOC         STORE NEW HEAD LOCATION
         CLI   0(R1),C' '         EMPTY SPOT?
         BE    RIGHTOK            YES
         CLI   0(R1),C'1'         TARGET?
         BL    CRASHED            NO, IT IS A CRASH
         OI    WORMFLAG,NEXT      NEED A NEW TARGET AFTER THIS
         SLR   R0,R0
         NI    0(R1),X'0F'        GET NUMERIC PART
         IC    R0,0(,R1)
         LR    R3,R0              NUMBER EATEN BY WORM
         A     R0,GROWSIZE        UPDATE COUNT-BEFORE-TAIL-MOVES
         ST    R0,GROWSIZE
         AH    R3,SCORE           UPDATE SCORE ACCUMULATED
         STH   R3,SCORE
RIGHTOK  MVI   0(R1),C'@'         YES, WRITE NEW HEAD
         MVI   4(R9),C'@'         SUPPLY NEW HEAD
         LA    R8,5(,R8)
         STH   R8,TPUTLEN         ACCUMULATE DATA STREAM LENGTH
         TM    GRAFLAGS,GEOK      TRANSMIT GRAPHIC ESCAPE?
         BZ    RITENOGE           NO, SEND STANDARD CHARACTERS
         TM    WORMFLAG,GRAF      IN GRAPHIC MODE?
         BO    RITEGRAF           YES
RITENOGE TM    WORMFLAG,LINE      IN LINE MODE?
         BZ    TPUTSOME           NO
         MVI   3(R9),C'-'         YES, ATTEMPT CONTINUOUS LINE
         CLI   PREVMOVE,X'96'     WAS PREVIOUS MOVE RIGHT?
         BE    TPUTSOME           YES, DATA STREAM COMPLETE
*        MVI   3(R9),C'+'         NO, INDICATE A CORNER
         MVI   3(R9),C'/'         NO, INDICATE A CORNER
         CLI   PREVMOVE,X'A4'     WAS PREVIOUS MOVE UP?
         BE    TPUTSOME           YES, DATA STREAM COMPLETE
         MVI   3(R9),C'\'         NO, IT MUST HAVE BEEN DOWN.
         B     TPUTSOME
RITEGRAF MVC   3(4,R9),=X'088F08A3'
         LA    R8,2(,R8)          ALLOW FOR 2 GRAPHICS ESCAPES
         STH   R8,TPUTLEN         ACCUMULATE DATA STREAM LENGTH
         TM    WORMFLAG,LINE      USING CONTINUOUS LINE DISPLAY?
         BZ    TPUTSOME           NO, DATA STREAM COMPLETE
         MVI   6(R9),X'C3'        YES, CHANGE TO BLOCK HEAD
         MVI   4(R9),X'A2'        SHOW HORIZONTAL LINE
         CLI   PREVMOVE,X'96'     WAS PREVIOUS MOVE RIGHT?
         BE    TPUTSOME           YES, DATA STREAM COMPLETE
         MVI   4(R9),X'C5'        NO, SHOW CORNER
         CLI   PREVMOVE,X'A4'     WAS PREVIOUS MOVE UP?
         BE    TPUTSOME           YES, DATA STREAM COMPLETE
         MVI   4(R9),X'C4'        NO, SHOW OTHER CORNER
         B     TPUTSOME
HEADLEFT MVI   RTORLFT,X'A2'      LATEST HORIZINTAL MOVE IS LEFT
         MVI   4(R9),X'96'        OVERWRITE OLD HEAD
         MVI   0(R1),X'A2'        OVERWRITE OLD HEAD IN BUFFER
         BCTR  R1,0               POINT TO NEW HEAD ADDRESS
         ST    R1,HEADADDR
         BCTR  R2,0
         STH   R2,HEADLOC         STORE NEW HEAD LOCATION
         STH   R2,TOLOC           WANT TO POINT TO PREVIOUS SPOT
         BAL   R14,CALCPOSI       GET CODE FOR NEW HEAD LOCATION
         STCM  R0,X'3',1(R9)
         CLI   0(R1),C' '         EMPTY SPOT?
         BE    LEFTOK             YES
         CLI   0(R1),C'1'         TARGET?
         BL    CRASHED            NO, IT IS A CRASH
         OI    WORMFLAG,NEXT      NEED A NEW TARGET AFTER THIS
         SLR   R0,R0
         NI    0(R1),X'0F'        GET NUMERIC PART
         IC    R0,0(,R1)
         LR    R3,R0              NUMBER EATEN BY WORM
         A     R0,GROWSIZE        UPDATE COUNT-BEFORE-TAIL-MOVES
         ST    R0,GROWSIZE
         AH    R3,SCORE           UPDATE SCORE ACCUMULATED
         STH   R3,SCORE
LEFTOK   MVI   0(R1),C'@'         YES, WRITE NEW HEAD
         MVI   3(R9),C'@'         SUPPLY NEW HEAD
         LA    R8,5(,R8)
         STH   R8,TPUTLEN         ACCUMULATE DATA STREAM LENGTH
         TM    GRAFLAGS,GEOK      TRANSMIT GRAPHIC ESCAPE?
         BZ    LEFTNOGE           NO, SEND STANDARD CHARACTERS
         TM    WORMFLAG,GRAF      IN GRAPHIC MODE?
         BO    LEFTGRAF           YES
LEFTNOGE TM    WORMFLAG,LINE      IN LINE MODE?
         BZ    TPUTSOME           NO
         MVI   4(R9),C'-'         YES, ATTEMPT CONTINUOUS LINE
         CLI   PREVMOVE,X'A2'     WAS PREVIOUS MOVE LEFT?
         BE    TPUTSOME           YES, DATA STREAM COMPLETE
*        MVI   4(R9),C'+'         NO, INDICATE A CORNER
         MVI   4(R9),C'\'         NO, INDICATE A CORNER
         CLI   PREVMOVE,X'A4'     WAS PREVIOUS MOVE UP?
         BE    TPUTSOME           YES, DATA STREAM COMPLETE
         MVI   4(R9),C'/'         NO, IT MUST HAVE BEEN DOWN.
         B     TPUTSOME
LEFTGRAF MVC   3(4,R9),=X'08A3089F'
         LA    R8,2(,R8)          ALLOW FOR 2 GRAPHICS ESCAPES
         STH   R8,TPUTLEN         ACCUMULATE DATA STREAM LENGTH
         TM    WORMFLAG,LINE      USING CONTINUOUS LINE DISPLAY?
         BZ    TPUTSOME           NO, DATA STREAM COMPLETE
         MVI   4(R9),X'C3'        YES, CHANGE TO BLOCK HEAD
         MVI   6(R9),X'A2'        SHOW HORIZONTAL LINE
         CLI   PREVMOVE,X'A2'     WAS PREVIOUS MOVE LEFT?
         BE    TPUTSOME           YES, DATA STREAM COMPLETE
         MVI   6(R9),X'D5'        NO, SHOW CORNER
         CLI   PREVMOVE,X'A4'     WAS PREVIOUS MOVE UP?
         BE    TPUTSOME           YES, DATA STREAM COMPLETE
         MVI   6(R9),X'D4'        NO, SHOW OTHER CORNER
         B     TPUTSOME
HEADDOWN MVI   UPORDN,X'83'       LATEST VERTICAL MOVE IS DOWN
         MVI   3(R9),X'96'        OVERWRITE OLD HEAD
         MVI   0(R1),X'83'        OVERWRITE OLD HEAD IN BUFFER
         AL    R1,COLUMNS         GET NEW HEAD ADDRESS
         AL    R2,COLUMNS         GET NEW HEAD LOCATION
         STH   R2,HEADLOC         STORE NEW HEAD LOCATION
         C     R1,LASTLOOK        COMPARE WITH BOTTOM LEFT CORNER
         BH    CRASHED            CRASHED INTO BOTTOM LINE
         B     UPORDOWN
HEADUP   MVI   UPORDN,X'A4'       LATEST VERTICAL MOVE IS UP
         MVI   3(R9),X'96'        OVERWRITE OLD HEAD
         MVI   0(R1),X'A4'        OVERWRITE OLD HEAD IN BUFFER
         SL    R1,COLUMNS         GET NEW HEAD ADDRESS
         SL    R2,COLUMNS         GET NEW HEAD LOCATION
         LA    R3,DTLSTART        POINT TO LOGICAL TOP LEFT CORNER
         AL    R3,COLUMNS         POINT TO LEFT BORDER OF 1ST PLAY LINE
         STH   R2,HEADLOC         STORE NEW HEAD LOCATION
         CR    R3,R1              COMPARE WITH NEW HEAD ADDRESS
         BH    CRASHED            CRASHED INTO INFO LINE
UPORDOWN ST    R1,HEADADDR
         STH   R2,TOLOC           WANT TO POINT TO PREVIOUS SPOT
         BAL   R14,CALCPOSI       GET CODE FOR NEW HEAD LOCATION
         MVI   4(R9),X'11'        SBA
         STCM  R0,X'3',5(R9)
         CLI   0(R1),C' '         EMPTY SPOT?
         BE    HEIGHTOK           YES
         CLI   0(R1),C'1'         TARGET?
         BL    CRASHED            NO, IT IS A CRASH
         OI    WORMFLAG,NEXT      NEED A NEW TARGET AFTER THIS
         SLR   R0,R0
         NI    0(R1),X'0F'        GET NUMERIC PART
         IC    R0,0(,R1)
         LR    R3,R0              NUMBER EATEN BY WORM
         A     R0,GROWSIZE        UPDATE COUNT-BEFORE-TAIL-MOVES
         ST    R0,GROWSIZE
         AH    R3,SCORE           UPDATE SCORE ACCUMULATED
         STH   R3,SCORE
HEIGHTOK MVI   0(R1),C'@'         YES, WRITE NEW HEAD
         MVI   7(R9),C'@'         SUPPLY NEW HEAD
         LA    R8,8(,R8)
         STH   R8,TPUTLEN         ACCUMULATE DATA STREAM LENGTH
         TM    GRAFLAGS,GEOK      TRANSMIT GRAPHIC ESCAPE?
         BZ    VERTNOGE           NO, SEND STANDARD CHARACTERS
         TM    WORMFLAG,GRAF      IN GRAPHIC MODE?
         BO    VERTGRAF           YES
VERTNOGE TM    WORMFLAG,LINE      IN LINE MODE?
         BZ    TPUTSOME           NO
         MVI   3(R9),C'|'         YES, ATTEMPT CONTINUOUS LINE
         CLI   PREVMOVE,X'83'     WAS PREVIOUS MOVE DOWN?
         BE    TPUTSOME           YES, DATA STREAM COMPLETE
         CLI   PREVMOVE,X'A4'     WAS PREVIOUS MOVE UP?
         BE    TPUTSOME           YES, DATA STREAM COMPLETE
*        MVI   3(R9),C'+'         NO, INDICATE A CORNER
         MVI   3(R9),C'/'         NO, INDICATE A CORNER
         CLI   DIRCTION,X'A4'     GOING UP?
         BE    VERTHIER           YES
         CLI   PREVMOVE,X'A2'     NO, WAS PREVIOUS MOVE LEFT?
         BE    TPUTSOME           YES
         B     OTHERWAY           NO, IT MUST HAVE BEEN RIGHT
VERTHIER CLI   PREVMOVE,X'96'     NO, WAS PREVIOUS MOVE RIGHT?
         BE    TPUTSOME           YES
OTHERWAY MVI   3(R9),C'\'         NO, IT MUST HAVE BEEN LEFT
         B     TPUTSOME
VERTGRAF ICM   R0,X'7',4(R9)      SAVE DATA
         MVC   3(2,R9),=X'088A'   GRAPHIC UP ARROW
         CLI   DIRCTION,X'A4'     GOING UP?
         BE    UPAROWOK           YES
         MVI   4(R9),X'8B'        NO, USE GRAPHIC DOWN ARROW
UPAROWOK STCM  R0,X'7',5(R9)      REPLACE DATA IN NEW LOCATION
         MVC   8(2,R9),=X'08A3'   WORM'S HEAD
         LA    R8,2(,R8)          ALLOW FOR 2 GRAPHICS ESCAPES
         STH   R8,TPUTLEN         ACCUMULATE DATA STREAM LENGTH
         TM    WORMFLAG,LINE      USING CONTINUOUS LINE DISPLAY?
         BZ    TPUTSOME           NO, DATA STREAM COMPLETE
         CLI   DIRCTION,X'A4'     YES, GOING UP?
         BE    UPLINE             YES
         MVI   9(R9),X'93'        CHANGE TO BLOCK HEAD
         MVI   4(R9),X'85'        SHOW VERTICAL LINE
         CLI   PREVMOVE,X'83'     WAS PREVIOUS MOVE DOWN?
         BE    PCAFLINE           YES, DO FINAL CHECK FOR PC EMULATION
         MVI   4(R9),X'D5'        NO, SHOW CORNER
         CLI   PREVMOVE,X'96'     WAS PREVIOUS MOVE RIGHT?
         BE    TPUTSOME           YES, DATA STREAM COMPLETE
         MVI   4(R9),X'C5'        NO, SHOW OTHER CORNER
         B     TPUTSOME
UPLINE   MVI   9(R9),X'94'        CHANGE TO BLOCK HEAD
         MVI   4(R9),X'85'        SHOW VERTICAL LINE
         CLI   PREVMOVE,X'A4'     WAS PREVIOUS MOVE UP?
         BE    PCAFLINE           YES, DO FINAL CHECK FOR PC EMULATION
         MVI   4(R9),X'D4'        NO, SHOW CORNER
         CLI   PREVMOVE,X'96'     WAS PREVIOUS MOVE RIGHT?
         BE    TPUTSOME           YES, DATA STREAM COMPLETE
         MVI   4(R9),X'C4'        NO, SHOW OTHER CORNER
         B     TPUTSOME
         SPACE
PCAFLINE TM    GRAFLAGS,PCAF      PC OR PS2 3270 EMULATION?
         BZ    TPUTSOME           NO, DATA STREAM COMPLETE
         MVI   3(R9),C'|'         YES, HIDE MISSING APL CODE POINT
         MVC   4(5,R9),5(R9)      SHIFT DATA STREAM UP ONE BYTE
         BCTR  R8,0               DECREMENT DATA STREAM LENGTH
         STH   R8,TPUTLEN         SAVE THE NEW VALUE
         B     TPUTSOME
         SPACE
UP       MVI   DIRCTION,X'A4'     CURRENT DIRECTION IS NOW UP
         CLI   TGETFLAG,X'91'     IS THE WORM MOVING?
         BE    MOVETAIL           YES
         BAL   R14,GETGOING       NO, START MOVING
         B     MOVETAIL
DOWN     MVI   DIRCTION,X'83'     CURRENT DIRECTION IS NOW DOWN
         CLI   TGETFLAG,X'91'     IS THE WORM MOVING?
         BE    MOVETAIL           YES
         BAL   R14,GETGOING       NO, START MOVING
         B     MOVETAIL
LEFT     MVI   DIRCTION,X'A2'     CURRENT DIRECTION IS NOW LEFT
         CLI   TGETFLAG,X'91'     IS THE WORM MOVING?
         BE    MOVETAIL           YES
         BAL   R14,GETGOING       NO, START MOVING
         B     MOVETAIL
RIGHT    MVI   DIRCTION,X'96'     CURRENT DIRECTION IS NOW RIGHT
         CLI   TGETFLAG,X'91'     IS THE WORM MOVING?
         BE    MOVETAIL           YES
         BAL   R14,GETGOING       NO, START MOVING
         B     MOVETAIL
         SPACE
CRASHED  MVC   TOLOC,HEADLOC      GET HEAD CRASH LOCATION
         BAL   R14,CALCPOSI       GET CODE FOR CRASH LOCATION
         STCM  R0,X'3',1(R9)      PUT CODE IN SCREEN UPDATE STREAM
         MVI   UPDTSTRM,X'C1'     WCC - DON'T UNLOCK THE KEYBOARD
         MVI   3(R9),C'+'         + MARKS THE SPOT
         MVC   4(4,R9),STRMTRLR   TACK ON DATA STREAM TRAILER FOOTPRINT
         LA    R1,UPDTSTRM        POINT TO DATA STREAM START
         LA    R0,8(,R8)          GET DATA STREAM LENGTH
         ICM   R1,X'8',=X'0B'     LOAD FULLSCREEN,HOLD FLAGS
         TPUT  (1),(0),R          DISPLAY CRASH SITE
         STIMER WAIT,BINTVL==F'100'  WAIT A SECOND
         MVI   3(R9),C'*'         * MARKS THE SPOT
         LA    R1,UPDTSTRM        POINT TO DATA STREAM START
         MVC   1(8,R1),0(R9)      JUST SHOW THE ASTERISK
         LA    R0,9               GET DATA STREAM LENGTH
         TM    WORMFLAG,GRAF      COLOUR REQUIRED?
         BZ    SPLAT              NO
         MVC   UPDTSTRM+4(2),WHITE      SA,COLOUR
         MVC   UPDTSTRM+6(1),WORMCOLR   COLOUR OF SPLAT
         MVI   UPDTSTRM+7,C'*'    * MARKS THE SPOT
         MVC   UPDTSTRM+8(4),STRMTRLR     TACK ON DATA STREAM TRAILER
         LA    R0,12              GET DATA STREAM LENGTH
SPLAT    ICM   R1,X'8',=X'03'     LOAD FULLSCREEN FLAGS
         TPUT  (1),(0),R          DISPLAY CRASH SITE
         TITLE ' TERMINATION - SCORING '
END      TIME  BIN                GET THE TIME
         ST    R0,BINTIMEN        REMEMBER WHEN THINGS STOPPED
         SLR   R5,R5              PREPARE FOR IC
         MVI   DIRCTION,0         CLEAR FOR LATER
         TM    WORMFLG2,TEST      TESTING RANDOM NUMBER GENERATOR?
         BO    DOAPAUSE           YES, DON'T EVEN TRY TO SCORE
         L     R4,540             GET POINTER TO CURRENT TCB
         L     R4,12(,R4)         POINT TO TIOT
         MVC   WORMUSER,0(R4)     GET USERID
         LA    R4,24(,R4)         POINT TO TIOELNGH
CHKDDNAM CLC   4(8,R4),WORMFILE+DCBDDNAM-IHADCB
         BE    OPENFILE           FILE EXISTS SO GO AND OPEN IT
         IC    R5,0(,R4)          GET TIOT ENTRY LENGTH
         AR    R4,R5              POINT TO NEXT TIOT ENTRY
         CLI   0(R4),0            ZERO LENGTH ENTRY?
         BNE   CHKDDNAM           NO, CHECK OUT THIS ENTRY
DOAPAUSE MVC   PAUSEMSG(10),=C'NO SCORING'
         B     WAITEXIT           YES, NOT IN TIOT SO FORGET SCOREBOARD
OPENFILE TIME  DEC                GET DATE AND TIME
         LR    R4,R0              SAVE TIME
         LR    R5,R1              SAVE DATE
         OPEN (WORMFILE,(UPDAT))  OPEN WORMFILE
         BLDL  WORMFILE,BORDBLDL  CHECK FOR MEMBER
         LA    R3,255             GET X'FF'
         NR    R15,R3             GET BLDL RETURN CODE - MEMBER THERE?
         BZ    GOTBOARD           YES
         CH    R15,=H'4'          NASTY PROBLEM?
         BH    EOPDSDIR           YES, FORGET THE WHOLE THING
         CLOSE (WORMFILE)         CLOSE THE FILE - NOTHING DONE YET
         OPEN (WORMFILE,(OUTPUT)) OPEN WORMFILE
GOTBOARD MVC   WORK(1),BORDC      GET ENTRY LENGTH CODE
         NI    WORK,X'7F'         TURN OFF ALIAS BIT
         CLI   WORK,15            SPF STATS?
         BE    RIGHTMEM           YES, SCOREBOARD CHECK IS ON
         CLI   WORK,14            PFD STATS?
         BE    RIGHTMEM           YES, SCOREBOARD CHECK IS ON
         MVI   BORDC,14           USER DATA OF PFD STATS
*        OK FOR REVIEW WITH X-RAY VISION BUT INVISIBLE TO SPF
         MVI   BORDV,1            WORM R1 - LATER RLSES MAY TEST THIS
         MVI   BORDM,0            NO UPDATES YET
         STCM  R5,X'F',BORDCR     SAVE CREATION DATE
         B     STOWREST           SAVE THE REMAINING NECESSARIES
RIGHTMEM MVC   DATEO,BORDCD       SAVE DATE OF PREVIOUS BEST
         MVC   TIMEO,BORDCT       SAVE TIME OF PREVIOUS BEST
         MVC   SCOREO,BORDMD      SAVE PREVIOUS BEST SCORE
         MVC   BESTWORM,BORDID    SAVE PREVIOUS BEST USERID
         CLC   SCORE,SCOREO       IS THIS A BETTER SCORE?
         BNH   EOPDSDIR           NO, DO NOT WRITE TO FILE
* COULD USE CONTENTS OF MEMBER TO LIST TOP 10 - LESS CHANCE OF CORUPTN
         SLR   R3,R3
         IC    R3,BORDM           GET UPDATE COUNTER
         LA    R3,1(,R3)          INCREMENT
         STC   R3,BORDM           SAVE IT AGAIN
STOWREST STCM  R5,X'F',BORDCD     SAVE CURRENT DATE
         STCM  R4,X'C',BORDCT     SAVE CURRENT TIME
         MVC   BORDMD,SCORE       SAVE NEW BEST SCORE
         MVC   BORDID,WORMUSER    SAVE NEW BEST WORM
         MVC   BORDK(USERLEN),BORDC    CHANGE FROM BLDL TO STOW FORMAT
         STOW  WORMFILE,BORDNAME,R ZAP IN NEW DETAILS QUICK
         STC   R15,DIRCTION       SAVE STOW RETURN CODE
EOPDSDIR CLOSE (WORMFILE)         CLOSE THE FILE - HOPE NO CORRUPTIONS
WAITEXIT MVC   BUFFER+TITLPOSI(56),PAUSEMSG
REPROMPT LA    R0,TITLPOSI+56     PUT PROMPT MESSAGE ON TOP LINE
ALLPAUSE LA    R1,BUFFER
         ICM   R1,X'8',=X'03'     LOAD FULLSCREEN FLAGS
         TPUT  (1),(0),R
         NI    WORMFLG2,255-LOCKED     KEYBOARD IS NOW UNLOCKED
         LA    R1,WORK
         LA    R0,8
         ICM   R1,X'8',=X'81'     LOAD ASIS,WAIT FLAGS
         TGET  (1),(0),R
         OI    WORMFLG2,LOCKED    KEYBOARD NOW LOCKED
         CLI   WORK,X'4D'
         BL    ENDORCAN           PF 22, 23 OR 24
         CLI   WORK,X'6B'
         BL    REPROMPT           UNEXPECTED AID
         CLI   WORK,X'6E'
         BH    ENDORCAN           NOT PA1, PA2, PA3 OR CLEAR
         L     R0,IMAGESIZ        RESHOW ENTIRE SCREEN IMAGE
         B     ALLPAUSE
GO4EVER  TM    WORMFLG2,TEST      IN TEST MODE?
         BZ    REPROMPT           NO, WAIT FOR APPROPRIATE INPUT
         OI    TST4EVER+1,X'F0'   MAKE THE BRANCH UNCONDITIONAL
         MVC   THISCOLR,WORK      USE AID TO SPECIFY COLOUR CODE
         NI    THISCOLR,7         TURN OFF INVALID COLOUR BITS
         MVC   BUFFER+TITLPOSI(56),NTMVSMSG       ASSUME NOT MVS
         TM    OSBITS,X'13'       IS THIS OS/VS2 MVS?
         BNO   F4LOOPYX           NO
         MVC   BUFFER+TITLPOSI(56),STARTHDR   RESTORE PFK HEADING
         TM    WORMFLAG,AUTO      IN AUTO MODE?
         BZ    F4LOOPYX           NO, SO PF1/13 STILL MEANS AUTO
         MVC   BUFFER+TITLPOSI+2(4),=C'SLOW'  RESTORE PF1 HEADING
         TM    WORMFLAG,BLITZ     FAST AUTO SPEED ON?
         BO    F4LOOPYX           YES, SO PF1/13 MEANS SLOW
         MVC   BUFFER+TITLPOSI+2(4),=C'FAST'  NO
F4LOOPYX LA    R1,BUFFER          RESTORE THE PFK HEADING ON SCREEN
         LA    R0,TITLPOSI+56
         ICM   R1,X'8',=X'0B'     LOAD FULLSCREEN,HOLD FLAGS
         TPUT  (1),(0),R
         B     NEWTARGT           GO AND LOOP FOREVER
         SPACE
FUJITSUX L     R1,532             POINT TO THE CURRENT ASCB
         LM    R0,R1,160(R1)      LOAD CURRENT TCB TIME
         SRDL  R0,12              CONVERT TO MICROSECONDS
         D     R0,=F'10000'       CONVERT TO CENTISECONDS
         ST    R1,TCBTIMEN        SAVE CURRENT TCB TIME
         B     CNCLTEST           CONTINUE WITH TERMINATION
         SPACE
ENDORCAN CLI   WORK,X'7D'         ENTER?
         BE    FAREWELL           YES, END
         NI    WORK,X'0F'         FOLD PF KEYS (1-12 = 13-24)
         CLI   WORK,9             PF1-8/13-20?
         BL    GO4EVER            YES
         CLI   WORK,12            PF12/24?
         BNE   REPROMPT           NO, UNEXPECTED PROGRAM FUNCTION KEY
CANCEL   OI    WORMFLG2,CNCL      YES
         TITLE ' TERMINATION - STATISTICS AND MESSAGE DISPLAY '
FAREWELL DS    0H
         CLI   TGETFLAG,X'91'     DID THE WORM MOVE?
         BNE   CNCLTEST           NO, DON'T EXAMINE TSO COUNTERS
         L     R1,540             POINT TO THE CURRENT TCB
         ICM   R1,X'F',164(R1)    POINT TO THE TIMING CONTROL TABLE
         BZ    CNCLTEST           SMF NOT ACTIVE SO FORGET IT
         MVC   TGETCNTN(8),48(R1) GET CURRENT TGET AND TPUT COUNTS
         TM    OSBITS,X'13'       IS THIS OSIV/F4?
         BNO   FUJITSUX           YES, DON'T EXAMINE TSO TRANSACTIONS
         L     R1,548             POINT TO THE CURRENT ASCB
         LM    R8,R9,64(R1)       LOAD CURRENT TCB TIME
         SRDL  R8,12              CONVERT TO MICROSECONDS
         D     R8,=F'10000'       CONVERT TO CENTISECONDS
         ST    R9,TCBTIMEN        SAVE CURRENT TCB TIME
         L     R1,148(,R1)        POINT TO THE OUXB
         MVC   XACTCNTN,88(R1)    GET CURRENT TSO TRANSACTION COUNT
         SPACE
CNCLTEST TM    WORMFLG2,CNCL      WAS CANCEL REQUESTED?
         BO    CLEANUP            YES, JUST EXIT
         MVC   UPDTSTRM(8),CLEARALL NO, CLEAR THE SCREEN FOR MESSAGES
         MVI   UPDTSTRM,X'C3'     WCC TO RESET MDT AND UNLOCK KEYBD
         MVC   UPDTSTRM+8(2),PROHIS    PROTECT THE STATS ON THE SCREEN
         LA    R8,10              DATA STREAM LENGTH SO FAR
         LA    R9,UPDTSTRM+10     CURRENT BUFFER POSITION
         TM    WORMFLAG,GRAF      IN GRAPHIC MODE?
         BZ    PINKYPOO           NO, SKIP PINK
         MVC   UPDTSTRM+10(3),PINK     SA,COLOUR,PINK
         MVC   UPDTSTRM+13(3),UNDERSCR SA,HILITE,UNDERSCR
         LA    R8,16              DATA STREAM LENGTH SO FAR
         LA    R9,UPDTSTRM+16     CURRENT BUFFER POSITION
         SPACE
PINKYPOO ICM   R0,X'F',TCBTIMEO   ANY TIMING STATISTICS TO REPORT?
         BZ    TSOSTATS           NO
         LA    R1,TIMEXPOS        LINE NUMBER FOR TIMEXMSG
         M     R0,COLUMNS         GET SCREEN LOCATION
         LA    R1,1(,R1)          START FROM THE SECOND COLUMN
         STH   R1,TOLOC
         BAL   R14,CALCPOSI       GET CODE FOR STATSMSG BUFFER ADDR
         MVI   0(R9),X'11'        SET BUFFER ADDRESS
         STCM  R0,X'3',1(R9)
         SLR   R0,R0
         L     R1,TPUTTIME        GET TOTAL TPUT ELAPSED TIME
         ICM   R15,X'F',TPUTCNTR  GET NUMBER OF HOLD=YES TPUTS
         BZ    TSOSTATS           DON'T DIVIDE BY ZERO
         DR    R0,R15             GET CENTISECONDS PER TPUT
         CVD   R1,WORK
         ED    TIMETPUT,WORK+6    SHOW SECONDS PER TPUT
         OI    TIMETPUT+1,X'F0'   SUPPLY LEADING DIGIT
         L     R1,TCBTIMEN        GET END TCB TIME
         SL    R1,TCBTIMEO        SUBSTRACT START TCB TIME
         L     R15,BINTIMEN       GET END TIME-OF-DAY
         S     R15,BINTIMEO       SUBTRACT START TIME-OF-DAY
         BP    BINTODOK           POSITIVE RESULT IS GOOD
         A     R15,=F'8640000'    CATER FOR MIDNIGHT WORMING
BINTODOK M     R0,=F'1000'        FOR PERCENTAGE AND ONE DECIMAL PLACE
         DR    R0,R15             GET TCB-TIME/ELAPSED PERCENTAGE
         CVD   R1,WORK
         ED    TIMETCB,WORK+6     SHOW IT
         MVC   3(TIMEXLEN,R9),TIMEXMSG
         LA    R8,TIMEXLEN+3(,R8) UPDATE DATA STREAM LENGTH
         LA    R9,TIMEXLEN+3(,R9) UPDATE BUFFER POINTER
         SPACE
TSOSTATS ICM   R3,X'F',TGETCNTN   ANY TSO STATISTICS TO REPORT?
         BZ    VALUEPUT           NO
         LA    R1,STATSPOS        LINE NUMBER FOR STATSMSG
         M     R0,COLUMNS         GET SCREEN LOCATION
         LA    R1,1(,R1)          START FROM THE SECOND COLUMN
         STH   R1,TOLOC
         BAL   R14,CALCPOSI       GET CODE FOR STATSMSG BUFFER ADDR
         MVI   0(R9),X'11'        SET BUFFER ADDRESS
         STCM  R0,X'3',1(R9)
         S     R3,TGETCNTO
         CVD   R3,WORK
         ED    TSOTGETS,WORK+4    SHOW WORM TSO TERMINAL GET COUNT
         L     R1,TPUTCNTN
         S     R1,TPUTCNTO
         CVD   R1,WORK
         ED    TSOTPUTS,WORK+4    SHOW WORM TSO TERMINAL PUT COUNT
         MVC   3(STATSF4L,R9),STATSMSG
         LA    R0,STATSF4L+3
         ICM   R3,X'F',XACTCNTN   ANY TSO TRANSACTIONS TO REPORT?
         BZ    STATSPUT           NO
         S     R3,XACTCNTO
         CVD   R3,WORK
         ED    TSOXACTS,WORK+4    SHOW WORM TSO TRANSACTION COUNT
         MVC   3(STATSLEN,R9),STATSMSG
         LA    R0,STATSLEN+3
         ICM   R1,X'F',DECRCNTR   ANY DECREMENTS?
         BZ    STATSPUT           NO
         CVD   R1,WORK
         ED    TSODECRS,WORK+4    SHOW DECREMENTS TO TCTLOUT & OUXBTRC
         MVC   3(FUDGELEN,R9),STATSMSG
         LA    R0,FUDGELEN+3
STATSPUT AR    R8,R0              UPDATE DATA STREAM LENGTH
         AR    R9,R0              UPDATE BUFFER POINTER
         SPACE
VALUEPUT LA    R1,VALUEPOS        LINE NUMBER FOR VALUEMSG
         M     R0,COLUMNS         GET SCREEN LOCATION
         LA    R1,1(,R1)          START FROM THE SECOND COLUMN
         STH   R1,TOLOC
         BAL   R14,CALCPOSI       GET CODE FOR VALUEMSG BUFFER ADDR
         MVI   0(R9),X'11'        SET BUFFER ADDRESS
         STCM  R0,X'3',1(R9)
         L     R1,FOODVALU        GET TOTAL GENERATED FOOD VALUE
         CVD   R1,WORK
         ED    VALUEMSG,WORK+5
         M     R0,=F'100'         TWO DECIMAL PLACES FOR AVERAGE
         D     R0,FOODCNTR        GET THE AVERAGE FOOD VALUE
         CVD   R1,WORK
         ED    VALUEAVG,WORK+6
         MVC   3(VALUELEN,R9),VALUEMSG
         LA    R8,VALUELEN+3(,R8) UPDATE DATA STREAM LENGTH
         LA    R9,VALUELEN+3(,R9) UPDATE BUFFER POINTER
         SPACE
         TM    WORMFLAG,GRAF      IN GRAPHIC MODE?
         BZ    NOCOLORS           NO, SKIP COLOR STATISTICS
         LA    R1,COLORPOS        LINE NUMBER FOR COLORMSG
         M     R0,COLUMNS         GET SCREEN LOCATION
         LA    R1,1(,R1)          START FROM THE SECOND COLUMN
         STH   R1,TOLOC
         BAL   R14,CALCPOSI       GET CODE FOR COLORMSG BUFFER ADDR
         MVI   0(R9),X'11'        SET BUFFER ADDRESS
         STCM  R0,X'3',1(R9)
         LH    R1,BLUES           REPORT NUMBER OF BLUE WORMS
         CVD   R1,WORK
         ED    BLUECNT,WORK+5
         LH    R1,REDS            REPORT NUMBER OF RED WORMS
         CVD   R1,WORK
         ED    REDCNT,WORK+5
         LH    R1,PINKS           REPORT NUMBER OF PINK WORMS
         CVD   R1,WORK
         ED    PINKCNT,WORK+5
         LH    R1,GREENS          REPORT NUMBER OF GREEN WORMS
         CVD   R1,WORK
         ED    GREENCNT,WORK+5
         LH    R1,TURQS           REPORT NUMBER OF TURQUOISE WORMS
         CVD   R1,WORK
         ED    TURQCNT,WORK+5
         LH    R1,YELLOWS         REPORT NUMBER OF YELLOW WORMS
         CVD   R1,WORK
         ED    YELLOCNT,WORK+5
         LH    R1,WHITES          REPORT NUMBER OF WHITE WORMS
         CVD   R1,WORK
         ED    WHITECNT,WORK+5
         MVC   3(COLORLEN,R9),COLORMSG
         LA    R8,COLORLEN+3(,R8) UPDATE DATA STREAM LENGTH
         LA    R9,COLORLEN+3(,R9) UPDATE BUFFER POINTER
         SPACE
NOCOLORS TM    WORMFLG2,TEST      IN FOOD GENERATION TEST MODE?
         BO    ASTERPUT           YES, DON'T DO THE COVERAGE RATING
         LA    R1,TREKPOS         LINE NUMBER FOR TREKMSG
         M     R0,COLUMNS         GET SCREEN LOCATION
         LA    R1,1(,R1)          START FROM THE SECOND COLUMN
         STH   R1,TOLOC
         BAL   R14,CALCPOSI       GET CODE FOR TREKMSG BUFFER ADDR
         MVI   0(R9),X'11'        SET BUFFER ADDRESS
         STCM  R0,X'3',1(R9)
         ICM   R1,X'F',MEALCNTR   GET THE TOTAL NUMBER OF MEALS
         BZ    COVERPUT           THE WORM HAS NOT EATEN
         L     R1,EATMOVES        GET TOTAL MOVES FOR ALL MEALS
         M     R0,=F'100'         TWO DECIMAL PLACES FOR AVERAGE
         D     R0,MEALCNTR        GET THE AVERAGE MOVES FOR A MEAL
         CVD   R1,WORK
         ED    TREKMSG,WORK+4
         MVC   3(TREKMLEN,R9),TREKMSG
         LA    R8,TREKMLEN+3(,R8) UPDATE DATA STREAM LENGTH
         LA    R9,TREKMLEN+3(,R9) UPDATE BUFFER POINTER
         SPACE
COVERPUT LA    R1,COVERPOS        LINE NUMBER FOR COVERMSG
         M     R0,COLUMNS         GET SCREEN LOCATION
         LA    R1,1(,R1)          START FROM THE SECOND COLUMN
         STH   R1,TOLOC
         BAL   R14,CALCPOSI       GET CODE FOR COVERMSG BUFFER ADDR
         MVI   0(R9),X'11'        SET BUFFER ADDRESS
         STCM  R0,X'3',1(R9)
         LH    R1,SCORE           GET SCORE
         LA    R1,8(,R1)          ADD INITIAL SIZE
         S     R1,GROWSIZE        SUBTRACT AMOUNT NOT GROWN YET
         M     R0,=F'10000'       PERCENTAGE AND TWO DECIMAL PLACES
         L     R3,MOVLINES
         M     R2,MOVECOLS        GET AREA OF PLAY
         DR    R0,R3              GET COVERAGE RATING
         CVD   R1,WORK
         ED    COVERMSG,WORK+5
         MVC   3(COVERLEN,R9),COVERMSG
         LA    R8,COVERLEN+3(,R8) UPDATE DATA STREAM LENGTH
         LA    R9,COVERLEN+3(,R9) UPDATE BUFFER POINTER
         SPACE
         CLI   DIRCTION,8         SCOREBOARD JUST CREATED?
         BE    SHOWSHOW           YES, GIVE THE GOOD NEWS
         CLI   BESTWORM,0         WAS THE SCOREBOARD FOUND?
         BE    ASTERPUT           NO, NO SCORING DETAILS TO REPORT
         SPACE
         LA    R1,PREVPOS         LINE NUMBER FOR PREVMSG
         M     R0,COLUMNS         GET SCREEN LOCATION
         LA    R1,1(,R1)          START FROM THE SECOND COLUMN
         STH   R1,TOLOC
         BAL   R14,CALCPOSI       GET CODE FOR PREVMSG BUFFER ADDR
         MVI   0(R9),X'11'        SET BUFFER ADDRESS
         STCM  R0,X'3',1(R9)
         LH    R1,SCOREO
         CVD   R1,WORK
         ED    PREVSCOR,WORK+5
         ED    PREVDATE,DATEO+1
         ICM   R1,X'6',TIMEO
         IC    R1,CHARZERO
         SRL   R1,4
         ST    R1,WORK+4
         UNPK  PREVTIME+1(4),WORK+5(3)
         MVC   PREVTIME(2),PREVTIME+1
         MVI   PREVTIME+2,C':'
         MVC   3(PREVMLEN,R9),PREVMSG
         LA    R8,PREVMLEN+3(,R8) UPDATE DATA STREAM LENGTH
         LA    R9,PREVMLEN+3(,R9) UPDATE BUFFER POINTER
         SPACE
         LA    R1,THISPOS         LINE NUMBER FOR THISMSG
         M     R0,COLUMNS         GET SCREEN LOCATION
         LA    R1,1(,R1)          START FROM THE SECOND COLUMN
         STH   R1,TOLOC
         BAL   R14,CALCPOSI       GET CODE FOR THISMSG BUFFER ADDR
         MVI   0(R9),X'11'        SET BUFFER ADDRESS
         STCM  R0,X'3',1(R9)
         LH    R1,SCORE
         CVD   R1,WORK
         ED    THISSCOR,WORK+5
         ST    R5,WORK+4
         ED    THISDATE,WORK+5
         ICM   R4,X'2',CHARZERO
         SRL   R4,12
         ST    R4,WORK+4
         UNPK  THISTIME+1(4),WORK+5(3)
         MVC   THISTIME(2),THISTIME+1
         MVI   THISTIME+2,C':'
         CLC   SCORE,SCOREO       HOW WAS THE SCORE?
         BNH   BADLUCK            BAD LUCK - JUST WASN'T GOOD ENOUGH
         MVC   BDLUKSUF,GDLUKSUF  GOOD LUCK -  CONGRATS
BADLUCK  MVC   3(THISMLEN,R9),THISMSG
         LA    R8,THISMLEN+3(,R8) UPDATE DATA STREAM LENGTH
         LA    R9,THISMLEN+3(,R9) UPDATE BUFFER POINTER
         SPACE
SHOWSHOW LA    R1,LUCKPOS         LINE NUMBER FOR APPROPRIATE MSG
         M     R0,COLUMNS         GET SCREEN LOCATION
         LA    R1,1(,R1)          START FROM THE SECOND COLUMN
         STH   R1,TOLOC
         BAL   R14,CALCPOSI       GET CODE FOR MESSAGE BUFFER ADDR
         MVI   0(R9),X'11'        SET BUFFER ADDRESS
         STCM  R0,X'3',1(R9)
         CLI   DIRCTION,8         SCOREBOARD JUST CREATED?
         BE    GOODGOOD           YES, GIVE THE GOOD NEWS
         CLC   SCORE,SCOREO       HOW WAS THE SCORE?
         BNH   BADSHOW            BAD LUCK - JUST WASN'T GOOD ENOUGH
GOODGOOD TM    WORMFLAG,GRAF      IN GRAPHIC MODE?
         BZ    GOODSHOW           NO, SKIP HIGHLIGHTING CHANGE
         MVC   3(3,R9),BLINKING   HIGHLIGHT PREVIOUS TOP WORMOGLODYTE
         MVC   6(3,R9),RED                  BEING DEPOSED
         LA    R8,6(,R8)          UPDATE DATA STREAM LENGTH
         LA    R9,6(,R9)          UPDATE BUFFER POINTER
GOODSHOW MVC   3(GDLUKLEN,R9),GDLUKMSG
         LA    R8,GDLUKLEN+3(,R8) UPDATE DATA STREAM LENGTH
         LA    R9,GDLUKLEN+3(,R9) UPDATE BUFFER POINTER
         B     DONELUCK
BADSHOW  CLC   BESTWORM,WORMUSER  IS THIS THE TOP WORMOGLODYTE?
         BE    OKAYLUCK           YES, DON'T WORRY
         MVC   3(BDLUKLEN,R9),BDLUKMSG
         LA    R8,BDLUKLEN+3(,R8) UPDATE DATA STREAM LENGTH
         LA    R9,BDLUKLEN+3(,R9) UPDATE BUFFER POINTER
         B     DONELUCK
OKAYLUCK MVC   3(URTOPLEN,R9),URTOPMSG
         LA    R8,URTOPLEN+3(,R8) UPDATE DATA STREAM LENGTH
         LA    R9,URTOPLEN+3(,R9) UPDATE BUFFER POINTER
         SPACE
DONELUCK TM    WORMFLAG,GRAF      YES, IN GRAPHIC MODE?
         BZ    CHEATCHK           NO, SKIP HIGHLIGHTING CHANGE
         SPACE
         MVC   0(3,R9),NOHILITE   RESET HIGHLIGHTING
         LA    R8,3(,R8)          UPDATE DATA STREAM LENGTH
         LA    R9,3(,R9)          UPDATE BUFFER POINTER
CHEATCHK TM    WORMFLAG,CHEAT     WAS WORMOMATIC USED?
         BZ    ASTERPUT           NO
         TM    WORMFLAG,GRAF      YES, IN GRAPHIC MODE?
         BZ    AUTOWIN            NO, SKIP HIGHLIGHTING CHANGE
         MVC   0(3,R9),BLUE       DON'T MAKE CRITICISM TOO LOUD
         LA    R8,3(,R8)          UPDATE DATA STREAM LENGTH
         LA    R9,3(,R9)          UPDATE BUFFER POINTER
AUTOWIN  LA    R1,CHEATPOS        YES, LET THEM KNOW WE KNOW
         M     R0,COLUMNS         GET SCREEN LOCATION
         LA    R1,1(,R1)          START FROM THE SECOND COLUMN
         STH   R1,TOLOC
         BAL   R14,CALCPOSI       GET CODE FOR CHEATMSG BUFFER ADDR
         MVI   0(R9),X'11'        SET BUFFER ADDRESS
         STCM  R0,X'3',1(R9)
         MVC   3(CHEATLEN,R9),CHEATMSG
         LA    R8,CHEATLEN+3(,R8) UPDATE DATA STREAM LENGTH
         LA    R9,CHEATLEN+3(,R9) UPDATE BUFFER POINTER
         SPACE
ASTERPUT LA    R1,ASTERPOS        LINE NUMBER FOR ASTERISKS
         M     R0,COLUMNS         GET SCREEN LOCATION
         LA    R1,1(,R1)          START FROM THE SECOND COLUMN
         STH   R1,TOLOC
         BAL   R14,CALCPOSI       GET CODE FOR CHEATMSG BUFFER ADDR
         MVI   0(R9),X'11'        SET BUFFER ADDRESS
         STCM  R0,X'3',1(R9)
         TM    WORMFLAG,GRAF      IN GRAPHIC MODE?
         BZ    STARSPUT           NO, SKIP RED INSERTION
         MVC   3(3,R9),RED        YES, ASTERISKS IN RED
         MVC   6(3,R9),NOHILITE   RESET ANY HIGHLIGHTING.
         LA    R8,6(,R8)          UPDATE DATA STREAM LENGTH
         LA    R9,6(,R9)          UPDATE BUFFER POINTER
STARSPUT MVC   3(ASTERLEN,R9),ASTERMSG
         LA    R8,ASTERLEN+3(,R8) UPDATE DATA STREAM LENGTH
*        LA    R9,ASTERLEN+3(,R9) UPDATE BUFFER POINTER  (NOT NEEDED)
         SPACE
FINALPUT LA    R1,UPDTSTRM        POINT TO TERMINATION MESSAGES
         LR    R0,R8              GET DATA STREAM LENGTH
         ICM   R1,X'8',=X'03'     LOAD FULLSCREEN FLAGS
         TPUT  (1),(0),R
         LA    R1,WORK
         LA    R0,8
         ICM   R1,X'8',=X'81'     LOAD ASIS,WAIT FLAGS
         TGET  (1),(0),R          END FOR ANY ALMOST ANY INPUT
         CLI   WORK,X'4D'
         BL    CLEANUP            PF 22, 23 OR 24
         CLI   WORK,X'6F'
         BL    FINALPUT           RESHOW IN CASE OF INTERCOM
         TITLE ' TERMINATION - EXIT '
CLEANUP  DS    0H
         CLI   TGETFLAG,X'91'     DID THE WORM GET MOVING?
         BNE   STAXOFF            NO, NO ATTENTION TRAP WAS SET
         TM    WORMFLG2,TEST      IN FOOD GENERATION TEST MODE?
         BO    STAXOFF            YES, NO ATTENTION TRAP WAS SET
         STAX  ,                  CANCEL THE ATTENTION TRAP
STAXOFF  DS    0H
         STLINENO LINE=1,MODE=OFF DEACTIVATE VTAM FULL SCREEN MODE
         TCLEARQ INPUT            FLUSH ANY RESIDUAL INPUT
         L     R13,SAVEAREA+4     POINT TO CALLER'S SAVE AREA
         LM    R14,R12,12(R13)    RESTORE REGS
         SLR   R15,R15            RETURN CODE 0
         BR    R14                RETURN TO CALLER
         TITLE ' INITIALIZATION - OPERATING SYSTEM AND STATISTICS '
GETGOING MVI   TGETFLAG,X'91'     NOW MOVING SO USE ASIS,NOWAIT TGETS
         TIME  BIN                GET THE TIME
         ST    R0,BINTIMEO        REMEMBER WHEN THINGS STARTED TO MOVE
         TM    WORMFLG2,TEST      IN FOOD GENERATION TEST MODE?
         BO    NOSTAXON           YES, DON'T SET AN ATTENTION TRAP
         STAX  MF=(E,STAXON)      ACTIVATE THE ATTENTION TRAP
NOSTAXON TM    OSBITS,X'13'       IS THIS OS/VS2 MVS?
         BNO   FUJITSU            NO, CATER FOR OSIV/F4
         L     R1,548             POINT TO THE CURRENT ASCB
         LM    R0,R1,64(R1)       LOAD CURRENT TCB TIME
         SRDL  R0,12              CONVERT TO MICROSECONDS
         D     R0,=F'10000'       CONVERT TO CENTISECONDS
         ST    R1,TCBTIMEO        SAVE CURRENT TCB TIME
         TESTAUTH FCTN=1          TEST FOR APF AUTHORIZATION
         LTR   R15,R15            AUTHORIZED?
         BNZ   TSTDAUTH           NO
         OI    WORMFLG2,AUTH      YES, FLAG SAME
TSTDAUTH L     R1,540             POINT TO THE CURRENT TCB
         ICM   R1,X'F',164(R1)    POINT TO THE TIMING CONTROL TABLE
         BZ    GOTGOING           SMF NOT ACTIVE SO FORGET IT
         MVC   TGETCNTO(8),48(R1) GET CURRENT TGET AND TPUT COUNTS
         TM    WORMFLG2,AUTH      APF AUTHORIZED UNDER MVS?
         BO    DISABLE            YES
         L     R1,548             POINT TO THE CURRENT ASCB
         L     R1,148(,R1)        POINT TO THE OUXB
         MVC   XACTCNTO,88(R1)    GET CURRENT TSO TRANSACTION COUNT
GOTGOING BR    R14                RETURN TO CALLER
         SPACE
DISABLE  ST    R14,WORK           SAVE THE RETURN ADDRESS
         ST    R1,TCTADDR         SAVE TCT ADDRESS (ONLY IF AC=1)
         MODESET MF=(E,MDSTSUP)   GET INTO SUPERVISOR STATE
         STNSM ENABINTS+1,X'04'   DISABLE INTERRUPTS
         L     R1,548             POINT TO THE CURRENT ASCB
         L     R1,148(,R1)        POINT TO THE OUXB
         L     R3,88(,R1)         GET CURRENT TSO TRANSACTION COUNT
ENABINTS STOSM ENABINTS+1,X'07'   ENABLE INTERRUPTS
         MODESET MF=(E,MDSTPRB)   GET INTO PROBLEM STATE
         ST    R3,XACTCNTO        STORE CURRENT TSO TRANSACTION COUNT
         L     R14,WORK           RESTORE RETURN ADDRESS
         B     GOTGOING
FUJITSU  TM    OSBITS,X'12'       IS THIS OSIV/F4?
         BNO   GOTGOING           NO, INDETERMINATE OPERATING SYSTEM
         MVC   WORMFILE+DCBDDNAM-IHADCB(8),PFDATTRS
         L     R1,532             POINT TO THE CURRENT ASCB
         LM    R0,R1,160(R1)      LOAD CURRENT TCB TIME
         SRDL  R0,12              CONVERT TO MICROSECONDS
         D     R0,=F'10000'       CONVERT TO CENTISECONDS
         ST    R1,TCBTIMEO        SAVE CURRENT TCB TIME
         L     R1,540             POINT TO THE CURRENT TCB
         ICM   R1,X'F',164(R1)    POINT TO THE TIMING CONTROL TABLE
         BZ    GOTGOING           SMF NOT ACTIVE SO FORGET IT
         MVC   TGETCNTO(8),48(R1) GET CURRENT TGET AND TPUT COUNTS
         B     GOTGOING           END OF MOVING INITIALIZATION
         TITLE ' WORMOMATIC - SITUATION EVALUATION '
AUTOMODE TM    WORMFLAG,AUTO      IS WORMOMATIC ALREADY ACTIVE?
         BZ    GOTOAUTO           NO, GET INTO AUTOMATIC MODE
         XI    WORMFLAG,BLITZ     YES, TOGGLE AUTO SPEED
GOTOAUTO OI    WORMFLAG,CHEAT+AUTO   INDICATE WORMOMATIC ACTIVATION
         MVC   BUFFER+TITLPOSI+2(4),=C'SLOW'
         TM    WORMFLAG,BLITZ     FAST AUTO SPEED ON?
         BO    GTPF1HDR           YES, SO PF1/13 MEANS SLOW
         MVC   BUFFER+TITLPOSI+2(4),=C'FAST'  NO
         TM    OSBITS,X'13'       IS THIS OS/VS2 MVS?
         BO    GTPF1HDR           YES
         MVC   BUFFER+TITLPOSI(56),NTMVSMSG
         LA    R0,TITLPOSI+56     PUT PROMPT MESSAGE ON TOP LINE
         LA    R1,BUFFER
         ICM   R1,X'8',=X'0B'     LOAD FULLSCREEN,HOLD FLAGS
         TPUT  (1),(0),R
         B     FLAGTEST
GTPF1HDR LH    R8,TPUTLEN         LENGTH OF DATA STREAM SO FAR
         LA    R9,UPDTSTRM(R8)    GET CURRENT BUFFER POINTER
         SLR   R1,R1              GET ZERO
         MVC   0(6,R9),PF1MSGBA   SBA,(1,23),SA,ALL,DEFAULT
         TM    WORMFLAG,GRAF      IN GRAPHIC MODE?
         BZ    NGTITLE2           NO
         LA    R1,3               EXTRA THREE, DON'T ERASE RESETSA
NGTITLE2 LA    R8,3(R1,R8)        INCREASE DATA STREAM LENGTH COUNTER
         LA    R9,3(R1,R9)        ADJUST BUFFER POINTER
         MVC   0(4,R9),BUFFER+TITLPOSI+2 =C'FAST'/=C'SLOW'
         LA    R8,4(,R8)          INCREASE DATA STREAM LENGTH COUNTER
         STH   R8,TPUTLEN         ACCUMULATE DATA STREAM LENGTH
         TM    GRAFLAGS,RVRS      IN REVERSE? (VIDEO, NOT GEAR)
         BZ    FLAGTEST           NO
         MVC   4(3,R9),REVERSE    YES, RESTORE IT
         LA    R8,3(,R8)          INCREASE DATA STREAM LENGTH COUNTER
         STH   R8,TPUTLEN         ACCUMULATE DATA STREAM LENGTH
FLAGTEST CLI   TGETFLAG,X'91'     IS THE WORM MOVING?
         BE    AUTOPLOT           YES
         BAL   R14,GETGOING       NO, START MOVING
AUTOPLOT TM    WORMFLG2,TEST      IN FOOD GENERATION TEST MODE?
         BO    NEWTARGT           YES, GO TEST IT
         SLR   R4,R4              ZERO POSSIBLE MOVE DETAILS
         ST    R4,MOVECNTR        RESET TEST MOVE COUNTER
         XC    POSPATHS,POSPATHS  NO POSSIBLE PATHS FOUND YET
         L     R0,COLUMNS
         L     R1,HEADADDR        GET CURRENT ADDRESS
         CLI   1(R1),C'0'         FOUND THE WORM FOOD?
         BH    RISOK              YES, RIGHT IS OKAY
         LA    R3,1(,R1)          NO, POINT TO "RIGHT" POSITION
         C     R3,TAILADDR        ADDRESS OF TAIL?
         BNE   RBLNKCHK           NO
         ICM   R3,X'F',GROWSIZE   YES, TAIL TO BE DELETED?
         BZ    RISOK              YES, RIGHT IS OKAY
RBLNKCHK CLI   1(R1),C' '         FOUND A BLANK?
         BNE   RISBAD             NO
RISOK    LA    R4,16+ROK(,R4)     YES, RIGHT IS POSSIBLE
         CLC   1(2,R1),=C' X'     NEXT TO SIDE BORDER AND NO FOOD?
         BNE   RISGOOD            NO, NO WORRIES
         LA    R3,DTLSTART        POINT TO CONCEPTUAL SCREEN ORIGIN
         AH    R3,NUMBRLOC        POINT TO FOOD
         CLI   1(R3),C'X'         FOOD ALSO IN SECOND-LAST COLUMN?
         BNE   RISBAD             NO, INHIBIT RIGHT IF POSSIBLE
RISGOOD  LA    R4,RGD(,R4)        RIGHT SHOULD NOT BE INHIBITED
RISBAD   BCTR  R1,0               POINT TO "LEFT" POSITION
         CLI   0(R1),C'0'         FOUND THE WORM FOOD?
         BH    LISOK              YES, LEFT IS OKAY
         C     R1,TAILADDR        ADDRESS OF TAIL?
         BNE   LBLNKCHK           NO
         ICM   R3,X'F',GROWSIZE   YES, TAIL TO BE DELETED?
         BZ    LISOK              YES, LEFT IS OKAY
LBLNKCHK CLI   0(R1),C' '         FOUND A BLANK?
         BNE   LISBAD             NO
LISOK    LA    R4,16+LOK(,R4)     YES, LEFT IS POSSIBLE
         LR    R3,R1              POINT TO "LEFT" POSITION
         BCTR  R3,0               POINT ONE MORE "LEFT"
         CLC   0(2,R3),=C'X '     NEXT TO SIDE BORDER AND NO FOOD?
         BNE   LISGOOD            NO, NO WORRIES
         LA    R3,DTLSTART        POINT TO CONCEPTUAL SCREEN ORIGIN
         AH    R3,NUMBRLOC        POINT TO FOOD
         BCTR  R3,0               POINT "LEFT" OF FOOD
         CLI   0(R3),C'X'         FOOD ALSO IN SECOND COLUMN?
         BNE   LISBAD             NO, INHIBIT LEFT IF POSSIBLE
LISGOOD  LA    R4,LGD(,R4)        LEFT SHOULD NOT BE INHIBITED
LISBAD   LA    R1,1(,R1)          GET CURRENT ADDRESS AGAIN
         SR    R1,R0              POINT TO "UP" POSITION
         LA    R3,DTLSTART        POINT TO LOGICAL TOP LEFT CORNER
         AL    R3,COLUMNS         POINT TO LEFT BORDER OF 1ST PLAY LINE
         CR    R3,R1              COMPARE WITH NEW HEAD ADDRESS
         BH    UISBAD             WOULD CRASH INTO INFO LINE
         CLI   0(R1),C'0'         FOUND THE WORM FOOD?
         BH    UISOK              YES, UP IS OKAY
         C     R1,TAILADDR        ADDRESS OF TAIL?
         BNE   UBLNKCHK           NO
         ICM   R3,X'F',GROWSIZE   YES, TAIL TO BE DELETED?
         BZ    UISOK              YES, UP IS OKAY
UBLNKCHK CLI   0(R1),C' '         FOUND A BLANK?
         BNE   UISBAD             NO
UISOK    LA    R4,16+UOK(,R4)     YES, UP IS POSSIBLE
UISBAD   AR    R1,R0              GET CURRENT ADDRESS AGAIN
         AR    R1,R0              POINT TO "DOWN" POSITION
         C     R1,LASTLOOK        COMPARE WITH BOTTOM BORDER ADDRESS
         BH    DISBAD             WOULD CRASH INTO INFO LINE
         CLI   0(R1),C'0'         FOUND THE WORM FOOD?
         BH    DISOK              YES, DOWN IS OKAY
         C     R1,TAILADDR        ADDRESS OF TAIL?
         BNE   DBLNKCHK           NO
         ICM   R3,X'F',GROWSIZE   YES, TAIL TO BE DELETED?
         BZ    DISOK              YES, DOWN IS OKAY
DBLNKCHK CLI   0(R1),C' '         FOUND A BLANK?
         BNE   DISBAD             NO
DISOK    LA    R4,16+DOK(,R4)     YES, DOWN IS POSSIBLE
DISBAD   LTR   R4,R4              ARE WE TRAPPED?
         BZ    MOVETAIL           YES, FACE IT LIKE A WORM
         STC   R4,DIRFLAGS        SAVE DIRECTION DETAILS
         SLL   R4,26              SHIFT OUT RGD AND LGD BITS
         SRL   R4,30              GET POSSIBLE MOVE COUNT IN LOW 2 BITS
         STH   R4,AUTOOPTS        SAVE NUMBER OF POSSIBLE MOVES
         STC   R4,AUTOOPTS        NOT-TO-BE-MODIFIED COPY OF SAME
PONDORNT LA    R15,DECNTABL       POINT TO DIRECTION DECISION TABLE
         ST    R15,DECNADDR                                   ENTRY
         SLR   R15,R15            ZERO MAX DEPTH TESTED FOR CHOICE
         STH   R15,HOLDEPTH            OF THIS ALGORITHM INVOCATION
         TM    AUTOOPTS+1,X'02'   MORE THAN ONE MOVE POSSIBLE?
         BO    PONDER             YES, DECISIONS, DECISIONS...
         TM    DIRFLAGS,DOK       DOWN IF IT WAS DOWN
         BO    GODOWN
         TM    DIRFLAGS,UOK       UP IF IT WAS UP
         BO    GOUP
         TM    DIRFLAGS,ROK       RIGHT IF IT WAS RIGHT
         BO    GORIGHT
         TM    DIRFLAGS,LOK       LEFT IF IT WAS LEFT
         BO    GOLEFT             (NOTHING SHOULD DROP THROUGH HERE)
         MVI   BUFFER+FLGPOS,C'3' TRAP ERROR
         B     SHOWFAIL           SHOW CURRENT STATUS
         TITLE ' WORMOMATIC - DECISION ALGORITHM '
PONDER   SLR   R4,R4              CLEAR FOR DIVIDE
         LH    R5,NUMBRLOC        GET LOCATION OF NUMBER
         DR    R4,R0              DIVIDE BY NUMBER OF COLUMNS
         STM   R4,R5,FOODX        STORE FOOD CO-ORDINATES
         SLR   R4,R4              CLEAR FOR DIVIDE
         LH    R5,HEADLOC         GET LOCATION OF HEAD
         DR    R4,R0              DIVIDE BY NUMBER OF COLUMNS
         STM   R4,R5,HEADX        STORE HEAD CO-ORDINATES
         L     R1,HEADADDR        GET CURRENT ADDRESS
         CLC   HEADY,FOODY        WHICH SIDE OF TARGET IS WORM'S HEAD?
         BH    CLIMB              BELOW THE NUMBER
         BE    RIGHTALT           ON THE SAME LINE AS THE NUMBER
         SPACE
DIVE     TM    DIRFLAGS,DOK       DOWN POSSIBLE?
         BZ    DIVISH             NO, CAN'T GO DOWN
         CLI   DIRCTION,X'83'     YES, CURRENTLY GOING DOWN?
         BE    GODOWN             YES, KEEP GOING DOWN
         TM    DIRFLAGS,RGD+LGD   NO, LEFT OR RIGHT POSSIBLE?
         BNZ   GODOWN             YES, NOT A CRUCIAL DECISION
         TM    DIRFLAGS,UOK       NO, IS UP POSSIBLE?
         BZ    GODOWN             NO, DOWN IS ONLY OPTION
MIDTREND CLI   DIRCTION,X'A2'     CURRENTLY GOING LEFT?
         BE    LFT2VERT           YES
         CLI   DIRCTION,X'96'     CURRENTLY GOING RIGHT?
         BNE   MIDWAY             NO
         CLI   1(R1),X'A4'        RIGHT BLOCKED BY "UP" WORM?
         BE    GODOWN             YES, GO DOWN
         CLI   1(R1),X'83'        NO, RIGHT BLOCKED BY "DOWN" WORM?
         BE    GOUP               YES, GO UP
         B     MIDWAY             NO
LFT2VERT LR    R3,R1              POINT TO CURRENT HEAD ADDRESS
         BCTR  R3,0
         CLI   0(R3),X'A4'        LEFT BLOCKED BY "UP" WORM?
         BE    GODOWN             YES, GO DOWN
         CLI   0(R3),X'83'        NO, LEFT BLOCKED BY "DOWN" WORM?
         BE    GOUP               YES, GO UP
MIDWAY   CLI   1(R1),C'X'         NEXT TO RIGHT BORDER?
         BE    VERTLUST           YES
         LR    R3,R1              POINT TO CURRENT HEAD ADDRESS
         BCTR  R3,0
         CLI   0(R3),C'X'         NEXT TO LEFT BORDER?
         BE    VERTLUST           YES
CENTREIT L     3,LINES
         SRL   3,1                GET HALF THE NUMBER OF SCREEN LINES
         C     3,HEADY            HEAD IN LOWER HALF OF SCREEN?
         BL    GOUP               YES, GO UP
         B     GODOWN             NO, GO DOWN
VERTLUST CLC   HEADY,FOODY        WHICH SIDE OF TARGET IS WORM'S HEAD?
         BH    GOUP               BELOW THE NUMBER
         BL    GODOWN             ABOVE THE NUMBER
         B     CENTREIT           ON THE SAME LINE AS THE NUMBER
DIVISH   TM    DIRFLAGS,RGD+LGD+UOK    NO, LEFT, RIGHT, UP POSSIBLE?
         BO    GOFORIT            YES, MUST BE IN THE OPEN
HORIZNTL TM    DIRFLAGS,RGD+LGD   NO, LEFT AND RIGHT POSSIBLE?
         BZ    GOVERT             NO, NEITHER
         BNO   GOHORIZ            NO, TAKE THE ONE THAT IS
         CLI   DIRCTION,X'83'     CURRENTLY GOING DOWN?
         BNE   UPOPP              NO
         LR    R3,R1              GET HEADADDR
         AL    R3,COLUMNS         POINT TO DOWN POSITION
HORIZOPP CLI   0(R3),X'96'        OBSTRUCTED BY "RIGHT" WORM?
         BE    GOLEFT             YES, SO GO LEFT
         CLI   0(R3),X'A2'        OBSTRUCTED BY "LEFT" WORM?
         BE    GORIGHT            YES, SO GO RIGHT
         B     GORTORLF           NOT OBSTRUCTED BY LEFT OR RIGHT WORM
UPOPP    CLI   DIRCTION,X'A4'     CURRENTLY GOING UP?
         BNE   GORTORLF           NO
         LR    R3,R1              GET HEADADDR
         SL    R3,COLUMNS         POINT TO UP POSITION
         B     HORIZOPP
GOHORIZ  TM    DIRFLAGS,RGD       ONLY ONE POSSIBLE, IS IT RIGHT?
         BO    GORIGHT            YES, DO IT
         B     GOLEFT             NO, IT MUST BE LEFT
GOVERT   TM    DIRFLAGS,UOK       ONLY ONE POSSIBLE, IS IT UP?
         BO    GOUP               YES, DO IT
         B     GODOWN             NO, IT MUST BE DOWN
         SPACE
RIGHTALT LR    R3,R1              GET HEADADDR
         CLI   DIRCTION,X'A4'     GOING UP?
         BE    RAUP               YES
         CLI   DIRCTION,X'83'     GOING DOWN?
         BE    RADWN              YES
         CLI   DIRCTION,X'A2'     GOING LEFT?
         BE    RALFT              YES
         TM    DIRFLAGS,RGD       NO, GOING RIGHT, IS RIGHT STILL OK?
         BO    GOFORIT            YES
         LA    R3,1(,R3)          POINT TO RIGHT POSITION
VERTIOPP CLI   0(R3),X'A4'        OBSTRUCTED BY "UP" WORM?
         BE    GODOWN             YES, SO GO DOWN
         CLI   0(R3),X'83'        OBSTRUCTED BY "DOWN" WORM?
         BE    GOUP               YES, SO GO UP
         B     GOFORIT            NOT OBSTRUCTED BY UP OR DOWN WORM
         SPACE
RALFT    TM    DIRFLAGS,LGD       GOING LEFT, IS LEFT STILL OK?
         BO    GOFORIT            YES
         BCTR  R3,0               POINT TO LEFT POSITION
         B     VERTIOPP
         SPACE
RADWN    TM    DIRFLAGS,DOK       GOING DOWN, IS DOWN STILL OK?
         BO    GOFORIT            YES
         AL    R3,COLUMNS         POINT TO DOWN POSITION
         B     HORIZOPP
         SPACE
RAUP     TM    DIRFLAGS,UOK       GOING UP, IS UP STILL OK?
         BO    GOFORIT            YES
         SL    R3,COLUMNS         POINT TO UP POSITION
         B     HORIZOPP
         SPACE
GOFORIT  CLC   HEADX,FOODX        WHICH SIDE OF TARGET IS WORM'S HEAD?
         BH    CRAWLEFT           RIGHT OF THE NUMBER
         TM    DIRFLAGS,RGD       RIGHT POSSIBLE?
         BO    GORIGHT            YES, GO RIGHT
GOUPORDN TM    DIRFLAGS,UOK+DOK   UP, DOWN POSSIBLE?
         BO    UPANDOWN           YES, BOTH
         BZ    GOHORIZ            NEITHER, ONLY ONE DIRECTION POSSIBLE
         TM    DIRFLAGS,UOK       NO, ONLY ONE, IS IT UP?
         BO    GOUP               YES, DO IT
         B     GODOWN             NO, IT MUST HAVE BEEN DOWN
UPANDOWN CLI   UPORDN,X'A4'       WAS LAST VERTICAL UP?
         BE    GOUP               YES, GO UP
         B     GODOWN             NO, IT WAS DOWN SO GO DOWN
CRAWLEFT TM    DIRFLAGS,LGD       LEFT POSSIBLE?
         BO    GOLEFT             YES, GO LEFT
         B     GOUPORDN           NO, MOVE VERTICALLY
         SPACE
GORTORLF LR    R3,R1              GET HEADADDR
ISRTBLKD LA    R3,1(,R3)          POINT TO NEXT RIGHT POSITION
         CLI   0(R3),C' '         BLANK TO THE RIGHT?
         BE    ISRTBLKD           YES
         CLI   0(R3),C'0'         NO, IS THE RIGHT BLOCKED BY FOOD?
         BH    GORIGHT            YES, GO RIGHT
         LR    R3,R1              NO
ISLFBLKD BCTR  R3,0               POINT TO POSITION TO THE LEFT
         CLI   0(R3),C' '         BLANK TO THE LEFT?
         BE    ISLFBLKD           YES
         CLI   0(R3),C'0'         NO, IS THE LEFT BLOCKED BY FOOD?
         BH    GOLEFT             YES, GO LEFT
         CLI   RTORLFT,X'96'      WAS LAST HORIZONTAL RIGHT?
         BE    GORIGHT            YES, GO RIGHT
         B     GOLEFT             NO, IT WAS LEFT SO GO LEFT
         SPACE
CLIMB    TM    DIRFLAGS,UOK       UP POSSIBLE?
         BZ    CLIMBISH           NO, CAN'T GO UP
         CLI   DIRCTION,X'A4'     YES, CURRENTLY GOING UP?
         BE    GOUP               YES, KEEP GOING UP
         TM    DIRFLAGS,RGD+LGD   NO, LEFT OR RIGHT POSSIBLE?
         BNZ   GOUP               YES, NOT A CRUCIAL DECISION
         TM    DIRFLAGS,DOK       NO, IS DOWN POSSIBLE?
         BZ    GOUP               NO, UP IS ONLY OPTION
         B     MIDTREND           NO, GO TOWARDS MIDDLE OF SCREEN
CLIMBISH TM    DIRFLAGS,RGD+LGD+DOK    NO, LEFT, RIGHT, DOWN POSSIBLE?
         BO    GOFORIT            YES, MUST BE IN THE OPEN
         B     HORIZNTL           NO, MAKE A HORIZONTAL MOVE
         SPACE
GODOWN   MVI   THISOPTN,DOK
         MVI   AUTOMOVE,X'83'
         B     TESTTEST
GOUP     MVI   THISOPTN,UOK
         MVI   AUTOMOVE,X'A4'
         B     TESTTEST
GOLEFT   MVI   THISOPTN,LOK
         MVI   AUTOMOVE,X'A2'
         B     TESTTEST
GORIGHT  MVI   THISOPTN,ROK
         MVI   AUTOMOVE,X'96'
TESTTEST ICM   R0,X'3',MAXDEPTH   ANY LOOK-AHEAD?
         BNZ   TESTMOVE           YES, DO IT
         MVC   DIRCTION,AUTOMOVE  NO, SUPPLY ALGORITHM'S DECISION
         B     MOVETAIL           AND TAKE IT
         TITLE ' WORMOMATIC - LOOK-AHEAD '
TESTMOVE MVC   DECISION,THISOPTN  GET PRE-DETERMINED INITIAL DECISION
         MVC   TESTGROW,GROWSIZE  COPY GROWSIZE FOR FUTURE PROJECTIONS
         MVI   FREEZER,0          INDICATE NO FOOD EATEN ON TRIAL YET
         MVI   FOODMOVE,0
         SLR   R0,R0
         STH   R0,DECDEPTH
         STH   R0,MOVDEPTH        RESET DEPTH MARKERS
         LH    R1,SCORE
         LA    R1,8+10(,R1)       GET MAXIMUM FORESEEABLE WORM LENGTH
         STH   R1,TGTDEPTH        NO POINT LOOKING BEYOND THIS
         L     R10,LOOKAHED       POINT TO TEST MOVES SAVE AREA
         L     R2,TAILADDR        POINT TO TAIL IN BUFFER
         L     R3,HEADADDR        POINT TO HEAD IN BUFFER
         B     TESTENTY           ENTRY POINT FOR FIRST TEST
         SPACE
TESTTAIL LA    R10,8(,R10)        POINT TO THIS TEST MOVE'S ENTRY
TESTENTY L     R1,MOVECNTR
         LA    R1,1(,R1)          INCREMENT TEST MOVE COUNTER
         ST    R1,MOVECNTR
         LH    R1,MOVDEPTH
         LA    R1,1(,R1)          INCREMENT DEPTH COUNTER
         STH   R1,MOVDEPTH
         CH    R1,HOLDEPTH        LOCAL MAXIMUM DEPTH?
         BNH   NOTNEWHI           NO
         STH   R1,HOLDEPTH        YES, SAVE IT
NOTNEWHI LR    R1,R2              SAVE TAIL ADDRESS
         ICM   R0,X'F',TESTGROW   EATEN RECENTLY?
         BNZ   GROWTEST           YES, GROW A BIT
         ICM   R1,X'8',0(R2)      SAVE TAIL CHARACTER
         CLI   0(R2),X'A4'        TAIL TO GO UP?
         BE    TTSTUP             YES
         CLI   0(R2),X'83'        TAIL TO GO DOWN?
         BE    TTSTDOWN           YES
         CLI   0(R2),X'A2'        TAIL TO GO LEFT?
         BE    TTSTLEFT           YES
         CLI   0(R2),X'96'        TAIL TO GO RIGHT?
         BE    TTSTRITE           YES
         MVI   BUFFER+FLGPOS,C'4' TRAP ERROR
         B     SHOWFAIL           SHOW CURRENT STATUS
TTSTRITE LA    R2,1(,R2)          TAIL TO GO RIGHT - POINT TO NEW TAIL
         B     TTSTDONE           NEW TAIL POSITION NOW CALCULATED
TTSTLEFT BCTR  R2,0               POINT TO NEW TAIL
         B     TTSTDONE           NEW TAIL POSITION NOW CALCULATED
TTSTDOWN AL    R2,COLUMNS         POINT TO NEW TAIL
         B     TTSTDONE           NEW TAIL POSITION NOW CALCULATED
TTSTUP   SL    R2,COLUMNS         POINT TO NEW TAIL
TTSTDONE MVI   0(R1),C' '         BLANK OLD TAIL
         B     TESTHEAD           NOW MOVE THE HEAD
GROWTEST BCTR  R0,0               DECREMENT SIZE-TO-GROW COUNTER
         ST    R0,TESTGROW
         SPACE
TESTHEAD ST    R1,0(,R10)         STORE OLD TAIL PARTICULARS
         ST    R3,4(,R10)         STORE OLD HEAD ADDRESS
         CLI   DECISION,UOK       CURRENTLY MOVING UP?
         BE    HTSTUP
         CLI   DECISION,DOK       CURRENTLY MOVING DOWN?
         BE    HTSTDOWN
         CLI   DECISION,LOK       CURRENTLY MOVING LEFT?
         BE    HTSTLEFT
         CLI   DECISION,ROK       CURRENTLY MOVING RIGHT?
         BE    HTSTRITE
         MVI   BUFFER+FLGPOS,C'5' TRAP ERROR
         B     SHOWFAIL           SHOW CURRENT STATUS
HTSTRITE MVI   0(R3),X'96'        OVERWRITE OLD HEAD IN BUFFER
         LA    R3,1(,R3)          POINT TO NEW HEAD ADDRESS
         B     TRIALHED
HTSTLEFT MVI   0(R3),X'A2'        OVERWRITE OLD HEAD IN BUFFER
         BCTR  R3,0               POINT TO NEW HEAD ADDRESS
         B     TRIALHED
HTSTDOWN MVI   0(R3),X'83'        OVERWRITE OLD HEAD IN BUFFER
         AL    R3,COLUMNS         GET NEW HEAD ADDRESS
         B     TRIALHED
HTSTUP   MVI   0(R3),X'A4'        OVERWRITE OLD HEAD IN BUFFER
         SL    R3,COLUMNS         GET NEW HEAD ADDRESS
TRIALHED MVI   FOODFLAG,0         CLEAR A BYTE
         CLI   0(R3),C' '         EMPTY SPOT?
         BE    TESTEVAL           YES
         CLI   0(R3),C'0'         TARGET NUMBER?
         BH    TESTFOOD           YES
         MVI   BUFFER+FLGPOS,C'¬' NO, CRASH IF CRASH (INVALID CHAR)
         B     SHOWFAIL           SHOW CURRENT STATUS
TESTFOOD MVI   FOODFLAG,X'40'     REMEMBER EATING FOOD
         MVI   FOODMOVE,X'40'     REMEMBER EATING FOOD AS A POSSIBILITY
         ST    R3,FREEZER         YES, SAVE THE WORM FOOD IN THE FRIDGE
         MVC   FREEZER(1),0(R3)
         SLR   R1,R1
         NI    0(R3),X'0F'        GET NUMERIC PART
         IC    R1,0(,R3)
         LA    R1,11(,R1)         CATER FOR NEW NUMBER(S) NEAR HERE
         A     R1,TESTGROW        UPDATE COUNT-BEFORE-TAIL-MOVES
         ST    R1,TESTGROW
         SPACE
TESTEVAL MVI   0(R3),C'@'         SUPPLY NEW HEAD IN BUFFER
         TM    WORMFLAG,DBUG      IN DEBUG MODE?
         BZ    SKPTSCRN           NO, SKIP SCREEN TEST DISPLAY
         MVI   BUFFER+FLGPOS,C'T' INDICATE TEST SCREEN IMAGE
         L     R4,LIFEADDR        POINT TO COUNTER IN SCREEN IMAGE
         LH    R0,MOVDEPTH        GET CURRENT DEPTH
         CVD   R0,WORK
         OI    WORK+7,X'0F'
         UNPK  6(3,R4),WORK+6(2)  SHOW MAXIMUM LIFETIME
         LH    R0,HOLDEPTH        GET DEEPEST SO FAR
         CVD   R0,WORK
         OI    WORK+7,X'0F'
         UNPK  11(3,R4),WORK+6(2) SHOW MAXIMUM LIFETIME
         LA    R1,BUFFER          POINT TO SCREEN IMAGE START
         L     R0,IMAGESIZ        GET DATA STREAM LENGTH
         ICM   R1,X'8',=X'0B'     LOAD FULLSCREEN,HOLD FLAGS
         TPUT  (1),(0),R          REFRESH ENTIRE SCREEN IMAGE
         MVI   BUFFER+FLGPOS,C'X' RESTORE DISPLAY TYPE INDICATOR
         MVC   6(8,R4),5(R4)      ERASE DISPLAY OF INTERNAL COUNTERS
*        STIMER WAIT,BINTVL=TEN   WAIT A DECISECOND
SKPTSCRN L     R1,COLUMNS
         SLR   R4,R4              ZERO POSSIBLE MOVE DETAILS
         LA    R15,1(,R3)
         CLR   R15,R2             ADDRESS OF TAIL?
         BNE   TSTRNTAL           NO
         ICM   R0,X'F',TESTGROW   TAIL TO BE DELETED?
         BZ    TSTRISOK           YES, RIGHT IS OKAY
         B     TSTRISBD           NO, RIGHT WILL CAUSE A COLLISION
TSTRNTAL CLI   1(R3),C'0'         FOUND THE WORM FOOD?
         BH    TSTRISOK           YES, RIGHT IS OKAY
         CLI   1(R3),C' '         FOUND A BLANK?
         BNE   TSTRISBD           NO
TSTRISOK LA    R4,16+ROK(,R4)     YES, RIGHT IS POSSIBLE
TSTRISBD BCTR  R3,0               POINT TO "LEFT" POSITION ADDRESS
         CLR   R3,R2              ADDRESS OF TAIL?
         BNE   TSTLNTAL           NO
         ICM   R0,X'F',TESTGROW   TAIL TO BE DELETED?
         BZ    TSTLISOK           YES, LEFT IS OKAY
         B     TSTLISBD           NO, LEFT WILL CAUSE A COLLISION
TSTLNTAL CLI   0(R3),C'0'         FOUND THE WORM FOOD?
         BH    TSTLISOK           YES, LEFT IS OKAY
         CLI   0(R3),C' '         FOUND A BLANK?
         BNE   TSTLISBD           NO
TSTLISOK LA    R4,16+LOK(,R4)     YES, LEFT IS POSSIBLE
TSTLISBD LA    R3,1(,R3)          GET CURRENT ADDRESS AGAIN
         SLR   R3,R1              POINT TO "UP" POSITION ADDRESS
         LA    R0,DTLSTART        POINT TO LOGICAL TOP LEFT CORNER
         AL    R0,COLUMNS         POINT TO LEFT BORDER OF 1ST PLAY LINE
         CR    R0,R3              COMPARE WITH NEW HEAD ADDRESS
         BH    TSTUISBD           WOULD CRASH INTO INFO LINE
         CLR   R3,R2              ADDRESS OF TAIL?
         BNE   TSTUNTAL           NO
         ICM   R0,X'F',TESTGROW   TAIL TO BE DELETED?
         BZ    TSTUISOK           YES, UP IS OKAY
         B     TSTUISBD           NO, UP WILL CAUSE A COLLISION
TSTUNTAL CLI   0(R3),C'0'         FOUND THE WORM FOOD?
         BH    TSTUISOK           YES, UP IS OKAY
         CLI   0(R3),C' '         FOUND A BLANK?
         BNE   TSTUISBD           NO
TSTUISOK LA    R4,16+UOK(,R4)     YES, UP IS POSSIBLE
TSTUISBD ALR   R3,R1              GET CURRENT ADDRESS AGAIN
         ALR   R3,R1              POINT TO "DOWN" POSITION ADDRESS
         C     R3,LASTLOOK        COMPARE WITH BOTTOM BORDER ADDRESS
         BH    TSTDISBD           WOULD CRASH INTO INFO LINE
         CLR   R3,R2              ADDRESS OF TAIL?
         BNE   TSTDNTAL           NO
         ICM   R0,X'F',TESTGROW   TAIL TO BE DELETED?
         BZ    TSTDISOK           YES, DOWN IS OKAY
         B     TSTDISBD           NO, DOWN WILL CAUSE A COLLISION
TSTDNTAL CLI   0(R3),C'0'         FOUND THE WORM FOOD?
         BH    TSTDISOK           YES, DOWN IS OKAY
         CLI   0(R3),C' '         FOUND A BLANK?
         BNE   TSTDISBD           NO
TSTDISOK LA    R4,16+DOK(,R4)     YES, DOWN IS POSSIBLE
TSTDISBD SLR   R3,R1              GET CURRENT ADDRESS AGAIN
         STC   R4,4(,R10)         SAVE DIRECTION DETAILS FOR THIS MOVE
         OC    4(1,R10),FOODFLAG  SET FOOD FLAG IF APPROPRIATE
         LTR   R4,R4              IS THE WORM TRAPPED?
         BNZ   MAXCHECK           NO, PRESS ON
         TM    WORMFLG2,XHST      YES, IN EXHAUSTIVE TEST MODE?
         BO    BACKOUT            YES, TAKE BACK THE PREVIOUS DECISION
         BAL   R14,UNDOTEST       NO, RESTORE BUFFER IMAGE
         L     R15,DECNADDR       POINT TO CURRENT DIRTBL ENTRY
         LA    R15,4(,R15)        POINT TO THE NEXT ONE
         ST    R15,DECNADDR       SAVE
         ICM   R15,X'3',DECDEPTH  ANY DECISIONS?
         BZ    YAEORNAY           NO, TUNNEL FAST PATH EXIT
         LA    R15,EODCNTBL       POINT TO END OF DECNTABL
         C     R15,DECNADDR       HAVE WE REACHED IT?
         BNE   TESTMOVE           NO, RETRY TEST WITH DIFFERENT ENTRY
         B     YAEORNAY           YES, JUDGEMENT TIME
MAXCHECK LA    R1,999             GET MAXIMUM LOOK-AHEAD CAPACITY
         CH    R1,MOVDEPTH        HAS IT BEEN REACHED?
         BE    TAKEPATH           YES, TERMINATE LOOK-AHEAD
         CLC   MOVDEPTH,TGTDEPTH  LOOKED BEYOND LENGTH OF WORM?
         BH    TAKEPATH           YES, THAT IS FAR ENOUGH
         TM    4(R10),X'20'       NO, MORE THAN ONE POSSIBILITY?
         BZ    CHOOSDIR           NO, IGNORE MAXDEPTH FOR TUNNELS
         TM    AUTOOPTS,X'02'     MORE THAN ONE ORIGINAL ALTERNATIVE?
         BO    CRUNCHON           YES, CONTINUE CRUNCHING
         MVI   FUTRCOLR,X'F1'     NO, CONDITION BLUE FOR QUICK THINKING
         MVI   REDORPNK+1,X'F2'   ENFORCE RED FOR NEXT CONDITION RED
         B     TRUEBLUE           TAKE THE ONLY POSSIBLE PATH
CRUNCHON LH    R1,DECDEPTH        GET CURRENT DECISION-POINT DEPTH
         LA    R1,1(,R1)          INCREMENT IT
         STH   R1,DECDEPTH        SAVE IT
         TM    WORMFLG2,XHST      IN EXHAUSTIVE TEST MODE?
         BZ    CHOOSDIR           NO, DECDEPTH IRRELEVANT
         CH    R1,MAXDEPTH        LOOKED AHEAD FAR ENOUGH?
         BNL   TAKEPATH           YES, HAPPY WITH THIS ONE
CHOOSDIR LA    R0,4               FOUR POSSIBLE DIRECTIONS
         L     R15,DECNADDR       POINT TO CURRENT DECISION TABLE ENTRY
DECNLOOP IC    R1,0(,R15)         LOAD TRIAL DECISION
         EX    R1,DIRNTEST        IS THIS DIRECTION POSSIBLE?
         BO    DECODDIR           YES, BUT WHICH WAY IS "THIS"?
         LA    R15,1(,R15)        POINT TO NEXT POSSIBLE CHOICE
         BCT   R0,DECNLOOP        TRY IT
         MVI   BUFFER+FLGPOS,C'6' TRAP ERROR
         B     SHOWFAIL           SHOW CURRENT STATUS
         SPACE
DIRNTEST TM    4(R10),X'00'       <<< EXECUTED >>>
         SPACE
DECODDIR STC   R1,WORK            EXAMINE DECISION CHOICE
         TM    WORK,ROK           IS RIGHT POSSIBLE FROM HERE?
         BO    DECIDER            YES, TAKE IT
         TM    WORK,LOK           IS LEFT POSSIBLE FROM HERE?
         BO    DECIDEL            YES, TAKE IT
         TM    WORK,DOK           IS DOWN POSSIBLE FROM HERE?
         BO    DECIDED            YES, TAKE IT
         TM    WORK,UOK           IS UP POSSIBLE FROM HERE?
         BO    DECIDEU            YES, TAKE IT
         MVI   BUFFER+FLGPOS,C'6' TRAP ERROR
         B     SHOWFAIL           SHOW CURRENT STATUS
         SPACE
DECIDEU  MVI   DECISION,UOK       TRY UP
         B     TESTTAIL
DECIDER  MVI   DECISION,ROK       TRY RIGHT
         B     TESTTAIL
DECIDEL  MVI   DECISION,LOK       TRY LEFT
         B     TESTTAIL
DECIDED  MVI   DECISION,DOK       TRY DOWN
         B     TESTTAIL
         SPACE
BACKOUT  MVI   0(R3),C' '         ERASE HEAD
         L     R3,4(,R10)         GET PREVIOUS HEAD ADDRESS
         CLI   0(R3),X'A4'        WAS THE DECISION UP?
         BE    DECNWASU           YES
         CLI   0(R3),X'83'        WAS THE DECISION DOWN?
         BE    DECNWASD           YES
         CLI   0(R3),X'A2'        WAS THE DECISION LEFT?
         BE    DECNWASL           YES
         CLI   0(R3),X'96'        WAS THE DECISION RIGHT?
         BE    DECNWASR           YES
         MVI   BUFFER+FLGPOS,C'7' TRAP ERROR
         B     SHOWFAIL           SHOW CURRENT STATUS
DECNWASU MVI   DECISION,UOK       UP
         B     FIXHEAD
DECNWASR MVI   DECISION,ROK       RIGHT
         B     FIXHEAD
DECNWASL MVI   DECISION,LOK       LEFT
         B     FIXHEAD
DECNWASD MVI   DECISION,DOK       DOWN
FIXHEAD  MVI   0(R3),C'@'         RESTORE HEAD
         ICM   R2,X'F',0(R10)     GET PREVIOUS TAIL ADDRESS
         BNM   SHRINK             WORM WAS GROWING SO TAIL NOT ERASED
         SLR   R1,R1              NOT GROWING SO ZERO TESTGROW
         STCM  R2,X'8',0(R2)      RESTORE ERASED TAIL
         B     BACKDOUT           BEFORE IMAGE RESTORED
SHRINK   L     R1,TESTGROW
         LA    R1,1(,R1)          TAIL DID NOT MOVE
BACKDOUT ST    R1,TESTGROW
         LA    R2,0(,R2)          RESTORE TAIL ADDRESS FORMAT
         LA    R3,0(,R3)          RESTORE HEAD ADDRESS FORMAT
         LH    R0,MOVDEPTH        GET CURRENT DEPTH
         BCTR  R0,0               DECREMENT FOR BACK-OUT
         STH   R0,MOVDEPTH        SAVE NEW DEPTH
         TM    4(R10),X'20'       WAS THIS A DECISION POINT?
         BZ    GOTDECPT           NO
         LH    R0,DECDEPTH        YES, GET CURRENT DECISION DEPTH
         BCTR  R0,0               DECREMENT FOR BACK-OUT
         STH   R0,DECDEPTH        SAVE NEW DECISION DEPTH
GOTDECPT TM    4(R10),X'40'       FOOD EATEN HERE?
         BZ    FOODISOK           NO
         ICM   R1,X'F',FREEZER    YES
         STCM  R1,X'8',0(R1)      RESTORE FOOD
FOODISOK MVI   0(R3),C'@'         SUPPLY NEW HEAD IN BUFFER
         TM    WORMFLAG,DBUG      IN DEBUG MODE?
         BZ    SKPBSCRN           NO, SKIP SCREEN TEST DISPLAY
         MVI   BUFFER+FLGPOS,C'B' INDICATE BACKED-OUT SCREEN IMAGE
         L     R4,LIFEADDR        POINT TO COUNTER IN SCREEN IMAGE
         LH    R0,MOVDEPTH        GET CURRENT DEPTH
         CVD   R0,WORK
         OI    WORK+7,X'0F'
         UNPK  6(3,R4),WORK+6(2)  SHOW MAXIMUM LIFETIME
         LH    R0,HOLDEPTH        GET DEEPEST SO FAR
         CVD   R0,WORK
         OI    WORK+7,X'0F'
         UNPK  11(3,R4),WORK+6(2) SHOW MAXIMUM LIFETIME
         LA    R1,BUFFER          POINT TO SCREEN IMAGE START
         L     R0,IMAGESIZ        GET DATA STREAM LENGTH
         ICM   R1,X'8',=X'0B'     LOAD FULLSCREEN,HOLD FLAGS
         TPUT  (1),(0),R          REFRESH ENTIRE SCREEN IMAGE
         MVI   BUFFER+FLGPOS,C'X' RESTORE DISPLAY TYPE INDICATOR
         MVC   6(8,R4),5(R4)      ERASE DISPLAY OF INTERNAL COUNTERS
*        STIMER WAIT,BINTVL=TEN   WAIT A DECISECOND
SKPBSCRN LA    R15,8              GET ENTRY SIZE
         SLR   R10,R15            POINT TO PREVIOUS ENTRY
         C     R10,LOOKAHED       DONE EVERY POSSIBLE BRANCH?
         BL    YAEORNAY           YES, JUDGEMENT TIME
         XC    4(1,R10),DECISION  INHIBIT PREVIOUSLY SELECTED DECISION
         TM    4(R10),X'0F'       ANY OTHER DECISIONS POSSIBLE?
         BZ    BACKOUT            NO, BACK-OUT ANOTHER MOVE
         B     CHOOSDIR           YES, TAKE A DIFFERENT PATH
         SPACE 2
YAEORNAY LA    R2,POSPATHS
GTPOSPTH CLI   2(R2),0            BEEN HERE BEFORE?
         BE    MTPOSPTH           NO, EMPTY POSSIBLE PATH ENTRY
         LA    R2,4(,R2)          YES, TRY NEXT ENTRY
         B     GTPOSPTH
MTPOSPTH MVC   0(2,R2),HOLDEPTH   GET POTENTIAL LIFETIME LEFT
         MVC   2(1,R2),AUTOMOVE   GET ORIGINAL MOVE
         L     R1,LOOKAHED
         MVC   3(1,R2),4(R1)      GET ORIGINAL MOVE'S STATS
         TM    WORMFLG2,XHST      IN EXHAUSTIVE TEST MOVE SEARCH MODE?
         BZ    INHIBNOT           NO, DON'T SHOW LOOK-AHEAD'S INFLUENCE
         OC    3(1,R2),FOODMOVE   YES, SET FOOD FLAG IF APPROPRIATE
         LH    R1,HEADLOC         GET HEAD LOCATION
         CLI   AUTOMOVE,X'A4'     IS DEADEND UP?
         BE    NOGOUP             YES
         CLI   AUTOMOVE,X'83'     IS DEADEND DOWN?
         BE    NOGODOWN           YES
         CLI   AUTOMOVE,X'A2'     IS DEADEND LEFT?
         BE    NOGOLEFT           YES
         CLI   AUTOMOVE,X'96'     IS DEADEND RIGHT?
         BE    NOGORITE           YES
         MVI   BUFFER+FLGPOS,C'8' TRAP ERROR
         B     SHOWFAIL           SHOW CURRENT STATUS
NOGORITE LA    R1,1(,R1)          RIGHT, ADD 1 TO LOCATION
         B     NOGOSIGN
NOGOLEFT BCTR  R1,0               LEFT, SUBTRACT 1 FROM LOCATION
         B     NOGOSIGN
NOGODOWN AL    R1,COLUMNS         DOWN, ADD NUMBER OF COLUMNS
         B     NOGOSIGN
NOGOUP   SL    R1,COLUMNS         UP, SUBTRACT NUMBER OF COLUMNS
NOGOSIGN STH   R1,TOLOC           INDICATE WHICH PATH WAS REJECTED
         BAL   R14,CALCPOSI
         LH    R8,TPUTLEN         GET CURRENT TPUT LENGTH
         LA    R9,UPDTSTRM(R8)    POINT TO CURRENT BUFFER POSITION
         MVI   0(R9),X'11'        SBA
         STCM  R0,X'3',1(R9)
         TM    GRAFLAGS,GEOK      TRANSMIT GRAPHIC ESCAPE?
         BZ    SHOWNOT            NO, SEND STANDARD CHARACTERS
         TM    WORMFLAG,GRAF      GRAPHIC MODE ON?
         BZ    SHOWNOT            NO
         MVC   3(5,R9),=X'28420008B6'
         MVC   5(1,R9),WORMCOLR   USE THE CURRENT COLOUR
         MVC   8(4,R9),STRMTRLR   TACK ON DATA STREAM TRAILER FOOTPRINT
         LA    R0,12(,R8)         GET DATA STREAM LENGTH
         B     SHOWNOGO
SHOWNOT  MVI   3(R9),C'¬'
         MVC   4(4,R9),STRMTRLR   TACK ON DATA STREAM TRAILER FOOTPRINT
         LA    R0,8(,R8)          GET DATA STREAM LENGTH
SHOWNOGO LA    R1,UPDTSTRM        POINT TO DATA STREAM START
         ICM   R1,X'8',=X'0B'     LOAD FULLSCREEN,HOLD FLAGS
         TPUT  (1),(0),R          DISPLAY "DISCARDED PATH" SIGN
         LA    R0,1               RESET ACCUMULATED
         STH   R0,TPUTLEN               UPDATE DATA STREAM
         TM    GRAFLAGS,RVRS      IN REVERSE? (VIDEO, NOT GEAR)
         BZ    INHIBNOT           NO
         MVC   UPDTSTRM+1(3),REVERSE
         MVI   TPUTLEN+1,4        YES
INHIBNOT TM    AUTOOPTS+1,X'02'   MORE THAN ONE MOVE POSSIBLE?
         BZ    DEADED             NO, OOOEEE GOOOEEE
         XC    DIRFLAGS,THISOPTN  YES, DELETE OPTION OF THIS PATH
         CLI   THISOPTN,ROK       DID WE DELETE RIGHT?
         BNE   THISNOTR           NO
         NI    DIRFLAGS,255-RGD   YES, ALSO RESET RIGHT-GOOD FLAG
         B     THISNOTL           OBVIOUSLY LEFT WASN'T DELETED
THISNOTR CLI   THISOPTN,LOK       DID WE DELETE LEFT?
         BNE   THISNOTL           NO
         NI    DIRFLAGS,255-LGD   YES, ALSO RESET LEFT-GOOD FLAG
THISNOTL LH    R0,AUTOOPTS        GET SAVED POSSIBLE MOVES COUNTER
         BCTR  R0,0               DECREMENT
         STH   R0,AUTOOPTS        RESTORE
         B     PONDORNT           EXAMINE ALTERNATE PATH
         SPACE
DEADED   LA    R1,POSPATHS        POINT TO CHOICE TABLE
REDORPNK MVI   FUTRCOLR,X'F2'     CONDITION RED - THE END IS NIGH
         XI    REDORPNK+1,X'01'   TOGGLE BLUE (TOGGLE RED AND PINK)
         TM    WORMFLG2,XHST      IN EXHAUSTIVE TEST MOVE SEARCH MODE?
         BZ    FOODLESS           NO, IGNORE SCORING POSSIBILITIES
         LA    R0,3               MAXIMUM NUMBER OF POSSIBLE DIRECTIONS
PTHCHOIC TM    3(R1),X'40'        CHANCE TO INCREASE SCORE HERE?
         BO    GO4SCORE           YES, TAKE IT (ALWAYS OFF IF XHST OFF)
         LA    R1,4(,R1)          NO, TRY NEXT ENTRY
         BCT   R0,PTHCHOIC
         LA    R1,POSPATHS        GO FOR LONGEST DURATION CHOICE
FOODLESS CLC   0(2,R1),POSPATHS+4 COMPARE FIRST WITH SECOND
         BNL   POSPOKAY
         LA    R1,POSPATHS+4      SECOND IS LONGER
POSPOKAY CLC   0(2,R1),POSPATHS+8 COMPARE LONGER WITH THIRD
         BNL   GO4SCORE           ALREADY HAVE LONGEST DEATH MARCH
         LA    R1,POSPATHS+8      THIRD IS LONGER
GO4SCORE MVC   DIRCTION,2(R1)     SUPPLY WORMOMATIC'S FINAL DECISION
         LH    R0,0(,R1)          GET MAXIMUM TIME LEFT
         CVD   R0,WORK
         OI    WORK+7,X'0F'
         LH    R15,PRVDEPTH       GET PREVIOUS MAX LIFE EXPECTANCY
         STH   R0,PRVDEPTH        SAVE FOR NEXT TIME
         L     R1,LIFEADDR        POINT TO COUNTER IN SCREEN IMAGE
         UNPK  1(3,R1),WORK+6(2)  SHOW MAXIMUM LIFETIME
         MVC   4(2,R1),=C'++'
         L     R0,MOVECNTR        GET THE NUMBER OF MOVES TESTED
         CVD   R0,WORK
         OI    WORK+7,X'0F'
         UNPK  6(8,R1),WORK+3(5)
         OI    WORMFLG2,FRTN      IN FORTUNE-TELLING MODE
         BCTR  R15,0              ADJUST PRVDEPTH FOR ONE MOVE LATER
         CH    R15,PRVDEPTH       ANY DRAMATIC DROP?
         BNH   MOVETAIL           NO, RETURN
         MVI   FUTRCOLR,X'F6'     YES, CONDITION YELLOW - LOOKING SICK
         B     MOVETAIL           RETURN
         SPACE
TAKEPATH MVI   FUTRCOLR,X'F4'     CONDITION GREEN - THE END IS NOT NIGH
TRUEBLUE BAL   R14,UNDOTEST       RESTORE BUFFER IMAGE
         MVC   DIRCTION,AUTOMOVE  SUPPLY WORMOMATIC'S FINAL DECISION
         LH    R1,HOLDEPTH        GET MIMIMUM MAXIMUM TIME LEFT
         STH   R1,PRVDEPTH        SAVE FOR NEXT TIME
         CVD   R1,WORK
         OI    WORK+7,X'0F'
         L     R1,LIFEADDR        POINT TO COUNTER IN SCREEN IMAGE
         UNPK  1(3,R1),WORK+6(2)  SHOW MAXIMUM LIFETIME
         MVC   4(2,R1),=C'++'
         L     R0,MOVECNTR        GET THE NUMBER OF MOVES TESTED
         CVD   R0,WORK
         OI    WORK+7,X'0F'
         UNPK  6(8,R1),WORK+3(5)
         OI    WORMFLG2,FRTN      IN FORTUNE-TELLING MODE
         TM    WORMFLAG,DBUG      IN DEBUG MODE?
         BZ    MOVETAIL           NO, RETURN
         MVI   BUFFER+FLGPOS,C'R' INDICATE RESTORED SCREEN IMAGE
         LA    R1,BUFFER          POINT TO SCREEN IMAGE START
         L     R0,IMAGESIZ        GET DATA STREAM LENGTH
         ICM   R1,X'8',=X'0B'     LOAD FULLSCREEN,HOLD FLAGS
         TPUT  (1),(0),R          REFRESH ENTIRE SCREEN IMAGE
         MVI   BUFFER+FLGPOS,C'X' RESTORE DISPLAY TYPE INDICATOR
*        STIMER WAIT,BINTVL=TEN   WAIT A DECISECOND
         B     MOVETAIL           LOGICAL END OF WORMOMATIC SUBROUTINE
         SPACE
UNDOTEST L     R0,LOOKAHED        GET ADDR OF LAST ENTRY TO BE RESTORED
         LA    R15,8              GET ENTRY SIZE
UNDOLOOP MVI   0(R3),C' '         ERASE HEAD
         L     R3,4(,R10)         GET PREVIOUS HEAD ADDRESS
         ICM   R1,X'F',0(R10)     GET PREVIOUS TAIL ADDRESS
         BNM   SHRINKIT           WORM WAS GROWING SO TAIL NOT ERASED
         STCM  R1,X'8',0(R1)      RESTORE ERASED TAIL
SHRINKIT SLR   R10,R15            POINT TO PREVIOUS ENTRY
         CLR   R0,R10             RESTORED FIRST ENTRY?
         BNH   UNDOLOOP           NOT YES, CONTINUE
         CLM   R3,X'7',HEADADDR+1 SUCCESSFUL RESTORE?
         BE    UNDONHED           YES
         MVI   BUFFER+FLGPOS,C'9' NO, TRAP ERROR
         B     SHOWFAIL           SHOW CURRENT STATUS
UNDONHED CLM   R1,X'7',TAILADDR+1 SUCCESSFUL RESTORE?
         BE    UNDOOKAY           YES
         MVI   BUFFER+FLGPOS,C'A' NO, TRAP ERROR
         B     SHOWFAIL           SHOW CURRENT STATUS
UNDOOKAY MVI   0(R3),C'@'         RESTORE HEAD (COSMETIC COMPLETENESS)
         SLR   R15,R15            ZERO RETURN CODE
         ICM   R1,X'F',FREEZER    ANY FOOD TO RESTORE?
         BNMR  R14                NO, RETURN
         STCM  R1,X'8',0(R1)      YES, RESTORE EATEN NUMBER
         LA    R15,X'40'          INDICATE THIS IN RETURN CODE
         BR    R14
         TITLE ' ENCODE SCREEN LOCATION TO 3270 BUFFER ADDRESS '
CALCPOSI LH    R0,TOLOC           GET CODE FOR 3270 BUFFER ADDRESS
         CH    R0,=H'4095'        LOCATION GREATER THAN 4K (12 BITS)?
         BHR   R14                YES, NO CONVERSION TO BE DONE
         STC   R0,WORK+1          NO, DO ORIGINAL 3270 ADDRESSING
         NI    WORK+1,B'00111111' GET LOW-ORDER SIX-BIT NUMBER
         SRL   R0,6
         STC   R0,WORK            GET HIGH-ORDER SIX-BIT NUMBER
         TR    WORK(2),TABLE      CONVERT TO 3270 DATA STREAM CHARS
         ICM   R0,X'3',WORK       SAVE IN BOTTOM TWO BYTES OF R0
         BR    R14                RETURN TO MAINLINE
         SPACE
CHAREPET MVC   1(0,R1),0(R1)      <<< EXECUTED >>>
         SPACE
TABLE    DC    X'40C1C2C3C4C5C6C7C8C94A4B4C4D4E4F'
         DC    X'50D1D2D3D4D5D6D7D8D95A5B5C5D5E5F'
         DC    X'6061E2E3E4E5E6E7E8E96A6B6C6D6E6F'
CHARZERO DC    X'F0F1F2F3F4F5F6F7F8F97A7B7C7D7E7F'
         SPACE
         DROP  R11,R12,R7         WORM
         TITLE ' ATTENTION EXIT AND MACRO LIST FORMS '
         USING ATTNEXIT,15
ATTNEXIT STM   R14,R12,12(R13)    SAVE REGISTERS
         L     R1,=V(WORMCMN)     POINT TO WORM DYNAMIC COMMON AREA
         OI    WORMFLG2-WORMCMN(R1),ATTN   TURN ON THE ATTENTION FLAG
         LM    R14,R12,12(R13)    RESTORE REGISTERS
         BR    R14                LEAVE ATTENTION EXIT
         DROP  15
         SPACE 3
STAXON   STAX  ATTNEXIT,MF=L
MDSTSUP  MODESET MODE=SUP,MF=L
MDSTSUPZ MODESET MODE=SUP,KEY=ZERO,MF=L
MDSTPRB  MODESET MODE=PROB,MF=L
MDSTPRBN MODESET MODE=PROB,KEY=NZERO,MF=L
         TITLE ' WORM OUTBOARD AND OCCUPANCY RESOURCE MEASUREMENT '
         USING WORM,R11,R12,R7
WOORM    DS    0H
         TIME  BIN                GET THE TIME AFTER THE TPUT
         LR    R1,R0              COPY IT
         SR    R1,R2              GET ELAPSED TIME OF TPUT
         BNM   OUTBRDTM           NON-NEGATIVE AS EXPECTED
         A     R1,=F'8640000'     HANDLE MIDNIGHT DURING TPUT
OUTBRDTM A     R1,TPUTTIME        ADD ACCUMULATED TPUT ELAPSED TIME
         ST    R1,TPUTTIME        SAVE NEW VALUE
         LA    R1,1
         A     R1,TPUTCNTR        INCREMENT TPUT HOLD=YES COUNTER
         ST    R1,TPUTCNTR        SAVE NEW VALUE
         SPACE
         TM    OSBITS,X'13'       OSIV/F4?
         BNO   FUJITSUT           YES
         L     R1,548             POINT TO THE CURRENT ASCB
         LM    R8,R9,64(R1)       LOAD CURRENT TCB TIME
         B     TCBCALC
FUJITSUT L     R1,532             POINT TO THE CURRENT ASCB
         LM    R8,R9,160(R1)      LOAD CURRENT TCB TIME
TCBCALC  SRDL  R8,12              CONVERT TO MICROSECONDS
         D     R8,=F'10000'       CONVERT TO CENTISECONDS
         LR    R8,R9              COPY CURRENT TCB CENTISECONDS
         L     R10,TCBTIME        GET PREVIOUS TCB TIME
         SR    R9,R10             GET CHANGE IN TCB TIME
         ST    R8,TCBTIME         SAVE CURRENT TCB TIME
         LR    R1,R0              COPY CURRENT TIME AGAIN
         S     R0,BINTIME         SUBTRACT PREVIOUS TIME
         ST    R1,BINTIME         SAVE CURRENT TIME
         LTR   R10,R10            FIRST TIME IN WOORM?
         BZR   R14                YES, SO RETURN
         SPACE
         LTR   R3,R0              TIME-OF-DAY DECREASED?
         BNM   NOPUMPKN           NO, GOOD
         A     R3,=F'8640000'     YES, MIDNIGHT HAS TRANSPIRED
         LA    R1,PMPKNMSG        WORMOGLODYTES BEWARE!
         LA    R0,L'PMPKNMSG
         TPUT  (1),(0),R          YOU MIGHT TURN INTO A PUMPKIN...
NOPUMPKN ICM   R0,X'F',TGTPCNT    IS TARGET TCB PERCENTAGE ZERO?
         BZR   R14                YES, SO HOG THAT CPU
         MVC   DELAY,TEN          NO, REINITIALIZE STIMER DELAY
         TM    WORMFLAG,AUTO      IN AUTO MODE?
         BZR   R14                NO, DON'T RETARD MANUAL MODE
         M     R8,=F'100'         YES, PREPARE FOR PERCENTAGE
         DR    R8,R0              GET TARGET ELAPSED TIME
         SR    R9,R3              SUBTRACT ACTUAL FROM TARGET ELAPSED
         BNPR  R14                TARGET NOT GREATER SO RETURN
         TM    WORMFLAG,BLITZ     IN FAST AUTO MODE?
         BO    WAITHERE           YES, ISSUE AN EXTRA WAIT
         TM    OSBITS,X'13'       OSIV/F4?
         BNO   WAITHERE           YES, ISSUE AN EXTRA WAIT
         SRL   R9,1               HALVE THE EXTRA TIME FOR EACH WAIT
         LA    R9,10(,R9)         INCLUDE BASE OF A DECISECOND
         ST    R9,DELAY           SUPPLY NEW TGET WAIT INTERVAL
         BR    R14                EXIT WOORM
WAITHERE ST    R9,WORK            YES, STORE CENTISECONDS TO WAIT
         STIMER WAIT,BINTVL=WORK  WAIT FOR THE ELAPSED TIME TO PASS
         BR    R14                EXIT WOORM
         TITLE ' LITERALS AND INITIALIZED VARIABLES '
CLEARALL DC    XL8'401140403C404000'      WCC,SBA,(1,1),RTA,(1,1),NULL
STRMTRLR DC    XL4'11404013'              SBA,(1,1),IC
TERMATTR DC    F'0'                       FILLED IN BY GTTERM
TEN      DC    F'10'                      A NUMBER BETWEEN 9 AND 11
MAXACCUM DC    AL2(L'UPDTSTRM-64)         DATA STREAM LENGTH THRESHOLD
WASTE    DC    H'0'                       FILLED IN BY GTTERM
MAXDEPTH DC    H'24' (>27 FOR FAST CPUS)  DEFAULT MAXIMUM LOOK-AHEAD
BORDBLDL DC    H'1',H'44'                 ONE 44 BYTE ENTRY
BORDNAME DC    CL8'EWSBTB00'              NAME OF SCOREBOARD MEMBER
BORDTTR  DC    XL3'000000'                FILLED IN BY BLDL/STOW
BORDK    DC    XL1'00'                    CONCATENATION CODE
BORDZ    DC    XL1'00'                    LOCATION CODE
BORDC    DC    XL1'00'
BORDV    DC    XL1'00'                    VERSION NUMBER
BORDM    DC    XL1'00'                    REVISION NUMBER
         DC    XL2'0000'                  NOT USED
BORDCR   DC    XL4'0000000F'              CREATION DATE
BORDCD   DC    XL4'0000000F'              LAST CHANGE DATE
BORDCT   DC    XL2'0000'                  LAST CHANGE TIME
BORDSI   DC    XL2'0000'                  NUMBER OF LINES CURRENTLY
BORDIN   DC    XL2'0000'                  NUMBER OF LINES INITIALLY
BORDMD   DC    XL2'0000'                  NUMBER OF LINES MODIFIED
BORDID   DC    XL8'0000000000000000'      USERID (10 BYTES FOR SPF)
USERLEN  EQU   *-BORDC                    USER DATA LENGTH + 1
PFDATTRS DC    CL8'PFDATTRS'              DDNAME FOR OSIV/F4
COLRCHAR DC    X'F7'                      START WITH WHITE
WORMCOLR DC    X'F0'                      START WITH NOTHING
FUTRCOLR DC    X'F4'                      START WITH GREEN
TGETFLAG DC    X'81'                      START WITH ASIS,WAIT TGET
DIRCTION DC    X'00'                      NO DIRECTION YET
PREVMOVE DC    X'96'                      AS IF PREVIOUS MOVE WAS RIGHT
RESETAID DC    X'27F1C3'                  ESCAPE,WRITE,WCC
QUERY    DC    X'F3000501FF02'            WRITE STRUCTURED FIELD,QUERY
SORRYMSG DC   C'SORRY, THIS PROGRAM USES 3270 FULL-SCREEN TERMINAL I/O'
WACKYMSG DC   C'WHAT SORT OF WACKY SCREEN HAVE YOU GOT, BOZO-FEATURES?'
PMPKNMSG DC    C' CAREFUL!!  YOU MIGHT TURN INTO A PUMPKIN...'
ACRNMMSG DC    C'(WORM=WONDERFUL-ONLINE-RESPONSE-MONITOR)'
ACRNMLEN EQU   *-ACRNMMSG
DSPMDMSG DC    C'(2,4,5&&6=DISPLAY-MODES)'
DSPMDLEN EQU   *-DSPMDMSG
AMAZEMSG DC    CL56'WOW!!!  END-OF-GAME FORCED BY A COMPLETELY FULL SCR+
               EEN!!'
PAUSEMSG DC    CL56'SCORING OK.  HIT <ENTER> FOR STATS OR PF12/24 TO CA+
               NCEL.'
NTMVSMSG DC    CL56'** THIS IS NOT MVS - YOU ARE LOCKED INTO WORMOMATIC+
               !! **'
TIMEXPOS EQU   2                          TERMINATION MESSAGE DETAILS
TIMEXMSG EQU   *
         DC    C' AVERAGE TPUT (HOLD=YES) ELAPSED TIME WAS'
TIMETPUT DC    X'40214B2020'
         DC    C' SECONDS.   '
TIMETCB  DC    X'4021204B20'
         DC    C'% TCB/ELAPSED. '
TIMEXLEN EQU   *-TIMEXMSG
STATSPOS EQU   4
STATSMSG EQU   *
TSOTGETS DC    X'4020202020202120'
         DC    C' TGETS   '
TSOTPUTS DC    X'4020202020202120'
         DC    C' TPUTS   '
STATSF4L EQU   *-STATSMSG
TSOXACTS DC    X'4020202020202120'
         DC    C' TRANSACTIONS   '
STATSLEN EQU   *-STATSMSG
TSODECRS DC    X'4020202020202120'
         DC    C' DECREMENTS '
FUDGELEN EQU   *-STATSMSG
VALUEPOS EQU   6
VALUEMSG DC    X'402020202120'
         DC    C' WAS THE VALUE OF ALL FOOD TARGETS  -  THE AVERAGE FOO+
               D VALUE WAS'
VALUEAVG DC    X'40214B2020'
         DC    C'. '
VALUELEN EQU   *-VALUEMSG
TREKPOS  EQU   8
TREKMSG  DC    X'4020202021204B2020'
         DC    C' WAS THE AVERAGE NUMBER OF MOVES FOR EACH MEAL. '
TREKMLEN EQU   *-TREKMSG
COVERPOS EQU   10
COVERMSG DC    X'402021204B2020'
         DC    C'% COVERAGE RATING FOR THIS SCREEN. '
COVERLEN EQU   *-COVERMSG
COLORPOS EQU   12
COLORMSG EQU   *
CMSGHDR  DC    X'2842F5'
         DC    C' RANDOM COLOUR SELECTIONS: '
REVERSE  DC    X'2841F2'     SET CHAR HIGHLIGHT TO REVERSE VIDEO
BLUE     DC    X'2842F1'
BLUECNT  DC    X'402020202120'
RED      DC    X'2842F2'
REDCNT   DC    X'402020202120'
PINK     DC    X'2842F3'
PINKCNT  DC    X'402020202120'
GREEN    DC    X'2842F4'
GREENCNT DC    X'402020202120'
TURQ     DC    X'2842F5'
TURQCNT  DC    X'402020202120'
YELLOW   DC    X'2842F6'
YELLOCNT DC    X'402020202120'
WHITE    DC    X'2842F7'
WHITECNT DC    X'402020202120'
CMSGTRLR DC    X'2842F6'
UNDERSCR DC    X'2841F4'     SET CHAR HIGHLIGHT TO UNDERSCORES
COLORLEN EQU   *-COLORMSG
PREVPOS  EQU   14
PREVMSG  DC    C' THE TOP WORMOGLODYTE WAS '
BESTWORM DC    XL8'0000000000000000'
         DC    C'WITH A SCORE OF'
PREVSCOR DC    X'402020202120'
         DC    C' ON'
PREVDATE DC    X'4021204B202020'
         DC    C' AT '
PREVTIME DC    C'HH:MM'
         DC    C'. '
PREVMLEN EQU   *-PREVMSG
THISPOS  EQU   16
THISMSG  DC    C' YOUR SCORE OF'
THISSCOR DC    X'402020202120'
         DC    C' ON'
THISDATE DC    X'4021204B202020'
         DC    C' AT '
THISTIME DC    C'HH:MM'
BDLUKSUF DC    C' DID NOT SURPASS THIS. '
THISMLEN EQU   *-THISMSG
GDLUKSUF DC    C' SURPASSES EVEN THIS!! '
LUCKPOS  EQU   18
BDLUKMSG DC    C' HAVE YOU TRIED WORMEX FOR BETTER, HEALTHIER, LONGER W+
               ORMS? '
BDLUKLEN EQU   *-BDLUKMSG
URTOPMSG DC    C' DON''T WORRY, YOU ARE STILL THE TOP WORMOGLODYTE. '
URTOPLEN EQU   *-URTOPMSG
GDLUKMSG DC   C' CONGRATULATIONS!!  YOU ARE THE NEW TOP WORMOGLODYTE! '
GDLUKLEN EQU   *-GDLUKMSG
CHEATPOS EQU   20
CHEATMSG DC    C' P.S.  TRY DOING IT ALL BY YOURSELF NEXT TIME!  WORMOM+
               ATIC IS FOR BEGINNERS. '
CHEATLEN EQU   *-CHEATMSG
ASTERPOS EQU   22
ASTERMSG DC    C'***'
         DC    X'1D40'       UNPROTECTED LOW-INTENSITY
         DC    X'13'         INSERT CURSOR
ASTERLEN EQU   *-ASTERMSG
NOHILITE DC    X'284100'     RESET CHAR HIGHLIGHT
BLINKING DC    X'2841F1'     SET CHAR HIGHLIGHT TO BLINKING
PF1MSGBA DC    X'1140D8'     BUFFER ADDRESS FOR PF1 MESSAGE
RESETSA  DC    X'280000'     RESET CHAR ATTRS (KEEP AFTER PF1MSGBA)
BUFHDR   DC    X'C3114040'
FLGPOS   EQU   *-BUFHDR
         DC    C'X'
PROHIS   DC    X'1DF8'       PROTECTED HIGH-INTENSITY FOR THE TITLE
SCORTITL EQU   *-BUFHDR
         DC    C'CURRENT-SCORE='
SCORPOSI EQU   *-BUFHDR
         DC    C'0000  '
TITLPOSI EQU   *-BUFHDR
STARTHDR DC    CL56'1=AUTO 3=END 7=UP 8=DOWN 9=RUN-8 10=LEFT 11=RIGHT 1+
               2=CAN'
         DC    X'1DF0'       MAKE THE REST OF THE BORDER LOW INTENSITY
HDRLEN   EQU   *-BUFHDR
         SPACE
         PRINT NOGEN
WORMFILE DCB   DSORG=PO,MACRF=(R,W),DDNAME=ISPTABL
         PRINT GEN
         SPACE
         LTORG
         SPACE
         DS    0F
DECNTABL DC    AL1(ROK,LOK,DOK,UOK)  WHAT I THINK ARE THE BEST 8 OUT
         DC    AL1(LOK,ROK,DOK,UOK)  OF ALL 24 POSSIBLE COMBINATIONS.
         DC    AL1(ROK,LOK,UOK,DOK)
         DC    AL1(LOK,ROK,UOK,DOK)  COULD ADD MORE ENTRIES WITHOUT
         DC    AL1(DOK,UOK,ROK,LOK)  CHANGING THE CODE FOR A SMALL
         DC    AL1(UOK,DOK,ROK,LOK)  GAIN IN INTELLIGENCE (AND PROBABLY
         DC    AL1(DOK,UOK,LOK,ROK)  A LARGE GAIN IN CPU TIME USAGE).
         DC    AL1(UOK,DOK,LOK,ROK)
EODCNTBL EQU   *
         SPACE
         DS    0D
         DC    C'   ANOTHER QUALITY PRODUCT FOR TSO BY GREG PRICE'
         DC    C' OF PRYCROFT SIX PTY LTD'
         DS    0D                 END OF CSECT
         TITLE ' UNINITIALIZED VARIABLES AND DSECTS '
WORMCMN  COM
SAVEAREA DS    18F
WORK     DS    D
WORMUSER DS    D
DELAY    DS    F
BINTIMEO DS    F
BINTIMEN DS    F
TGETCNTO DS    F
TPUTCNTO DS    F
XACTCNTO DS    F
TGETCNTN DS    F
TPUTCNTN DS    F
DECNADDR DS    F
LINES    DS    F
COLUMNS  DS    F
MOVLINES DS    F
MOVECOLS DS    F
ELIGIBLS DS    F
IMAGESIZ DS    F
LASTLOOK DS    F
LOOKAHED DS    F
LIFEADDR DS    F
HEADADDR DS    F
TAILADDR DS    F
MOVECNTR DS    F
TESTGROW DS    F
FREEZER  DS    F
FOODX    DS    F
FOODY    DS    F
HEADX    DS    F
HEADY    DS    F
DATEO    DS    F
ZEROAREA EQU   *                  THIS AREA ZEROED AT INITIALIZATION
TCTADDR  DS    F
TGTPCNT  DS    F
BINTIME  DS    F
TCBTIME  DS    F
TCBTIMEO DS    F
TCBTIMEN DS    F
TPUTTIME DS    F
TPUTCNTR DS    F
TPUTHOLD DS    F
DECRCNTR DS    F
XACTCNTN DS    F
GROWSIZE DS    F
FOODVALU DS    F
FOODCNTR DS    F
STACKER  DS    F
MEALCNTR DS    F
EATMOVES DS    F
THISTREK DS    F
COLOURS  EQU   *                  COLOUR COUNTERS MUST BE IN CODE ORDER
BLUES    DS    H
REDS     DS    H
PINKS    DS    H
GREENS   DS    H
TURQS    DS    H
YELLOWS  DS    H
WHITES   DS    H
SCORE    DS    H
ZEROLEN  EQU   *-ZEROAREA         END OF INITIALLY ZEROED AREA
SCOREO   DS    H
TIMEO    DS    H
TPUTLEN  DS    H
HEADLOC  DS    H
TAILLOC  DS    H
TOLOC    DS    H
NUMBRLOC DS    H
LIFEBFAD DS    H
MOVDEPTH DS    H
HOLDEPTH DS    H
TGTDEPTH DS    H
DECDEPTH DS    H
PRVDEPTH DS    H
AUTOOPTS DS    H
POSPATHS DS    CL12
AUTOMOVE DS    C
DECISION DS    C
UPORDN   DS    C
RTORLFT  DS    C
FOODMOVE DS    C
FOODFLAG DS    C
WORMFLAG DS    C
NEXT     EQU   X'80'
CHEAT    EQU   X'40'
AUTO     EQU   X'20'
GRAF     EQU   X'10'
DBUG     EQU   X'08'
BLITZ    EQU   X'04'
LINE     EQU   X'02'
BURST    EQU   X'01'
WORMFLG2 DS    C
LOCKED   EQU   X'80'
FRTN     EQU   X'40'
CNCL     EQU   X'20'
XHST     EQU   X'10'
SSSS     EQU   X'08'
AUTH     EQU   X'04'
TEST     EQU   X'02'
ATTN     EQU   X'01'
GRAFLAGS DS    C                  TERMINAL GRAPHIC CAPABILITY FLAGS
COLR     EQU   X'80'              AT LEAST SEVEN COLOURS SUPPORTED
HLIT     EQU   X'40'              BLINK, REVERSE, UNDERSCORES SUPPORTED
GEOK     EQU   X'20'              GRAPHICS ESCAPE SUPPORTED
SYMSET   EQU   X'10'              SYMBOL SETS SUB-FIELD RETURNED
PCAF     EQU   X'08'              PC ATTACHMENT FACILITY TERMINAL
IMPLIC   EQU   X'04'              IMPLICIT PARTITION SUB-FIELD RETURNED
RVRS     EQU   X'01'              USE REVERSE VIDEO ALL THE TIME
DIRFLAGS DS    C
RGD      EQU   X'80'
LGD      EQU   X'40'
ROK      EQU   X'08'
LOK      EQU   X'04'
UOK      EQU   X'02'
DOK      EQU   X'01'
THISOPTN DS    C
OSBITS   DS    C
THISCOLR DS    C
         DS    0D
UPDTSTRM DS    CL3584
BUFFER   DS    CL6
DTLSTART EQU   *
         ORG   WORMCMN+22000
         SPACE 2
         PRINT NOGEN
         DCBD  DSORG=PO,DEVD=DA
         PRINT GEN
         SPACE 2
R0       EQU   0
R1       EQU   1
R2       EQU   2
R3       EQU   3
R4       EQU   4
R5       EQU   5
R6       EQU   6
R7       EQU   7
R8       EQU   8
R9       EQU   9
R10      EQU   10
R11      EQU   11
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
         SPACE 2
         END
/*
//LKED    EXEC PGM=IEWL,PARM='MAP,LIST'
//SYSLIN   DD  DSN=&&LOADSET,DISP=(OLD,DELETE)
//         DD  *
  ALIAS HALFWORM,HW,QUARTERW,QW,WORMTEST,HALFTEST,QUARTEST
  NAME WORM(R)
/*
//SYSLMOD  DD  DSN=SYS2.CMDLIB,DISP=SHR
//SYSPRINT DD  SYSOUT=*
//SYSUT1   DD  UNIT=VIO,SPACE=(CYL,(5,2))
//
