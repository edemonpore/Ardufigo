;title   <Ardufigo.ASM>
;
; fig-FORTH release 1.1 for the 8080 processor.
;
; ALL PUBLICATIONS OF THE FORTH INTEREST GROUP
; ARE PUBLIC DOMAIN. THEY MAY BE FURTHER
; DISTRIBUTED BY THE INCLUSION OF THIS CREDIT NOTICE:
;
; This publication has been made available by the
;   Forth Interest Group
;   P.O.Box 1105EXPECT
;   San Carlos, CA 94070
;   U.S.A.
;
; Implementation on 8080 by:
;   John Cassady
;   339 15th Street
;   Oakland, CA 94612
;   U.S.A
;   on 790528
; Modified by:
;   Kim Harris
; Acknowledgements:
;   George Flammer
;   Robt. D. Villwock
; -----------------------------------------------------------------------------
; The infrastructure of this code, cut and pasted from Dennis Lee Wilson"s
; website, has been retained. all of the machine code has been removed. The 
; code relevant to this project, the high-level functions and the link-fields
; and names have been slightly modified and will eventually be cleaned up to
; include neater references to the inter-word links. 
; kjc ~ 20170815 


;   Translation to get the code to compile on TASM

#define DW   .dw
#define defb .db
#define dc .TEXT
#define page .page

#define equ  .equ

.MSFIRST       ; make the code lo-endian - it"s good for looking at dumps if you like that kind of shit
       
;primative instructions
ppkey          .equ  0000h    ; KEY
ppemit         .equ  0001h    ; (EMIT3)
pnoop          .equ  0002h    ; NOOP
ppequals       .equ  0003h    ; =
ppmtwo         .equ  0004h    ; -2
ppmone         .equ  0005h    ; -1
pptwo          .equ  0006h    ; 2
ppone          .equ  0007h    ; 1
ppzero         .equ  0008h    ; 0
ppzeq          .equ  0009h    ; 0=
ppcstore       .equ  000Ah    ; C!
ppcfetch       .equ  000Bh    ; C@
ppstore        .equ  000Ch    ; ! <----------------------store
ppfetch        .equ  000Dh    ; @ <----------------------fetch
pprot          .equ  000Eh    ; ROT
ppdiv          .equ  000Fh    ; U/
ppmul          .equ  0010h    ; U*
ppsub          .equ  0011h    ; -
ppadd          .equ  0012h    ; +
ppover         .equ  0013h    ; OVER
ppswap         .equ  0014h    ; SWAP
ppdup          .equ  0015h    ; DUP
ppvoodoop      .equ  0016h    ; (DO)
pprfrom        .equ  0017h    ; R>
pptor          .equ  0018h    ; >R
ppbran         .equ  0019h    ; BRANCH
ppzbran        .equ  001Ah    ; 0BRANCH
pplit          .equ  001Bh    ; LIT
ppdocol        .equ  001Ch    ; :
ppsemi         .equ  001Dh    ; ;
ppeye          .equ  001Eh    ; I
ppjay          .equ  001Fh    ; J
ppkay          .equ  0020h    ; K
pprfetch       .equ  0021h    ; R@
ppdrop         .equ  0022h    ; DROP
pppindir       .equ  0023h    ; <P> ~ set GPIO pin direction
pppinsto       .equ  0024h    ; P! 
pppinfetch     .equ  0025h    ; P@
pphexintfig    .equ  0026h    ; for outputting formatted hex dumps
pphexecute     .equ  0027h    ; test this; I am not sure that this is not a circular reference
pponeplus      .equ  0028h    ; 1+
pponeminus     .equ  0029h    ; 1-
pptwoplus      .equ  002Ah    ; 2+
pptwominus     .equ  002Bh    ; 2-
pptdrop        .equ  002Ch    ; 2DROP
pptwotimes     .equ  002Dh    ; 2*
pptwodivby     .equ  002Eh    ; 2/
ppminus        .equ  002Fh    ; MINUS
ppdminus       .equ  0030h    ; DMINUS
ppor           .equ  0031h    ; OR
ppand          .equ  0032h    ; AND
ppxor          .equ  0033h    ; XOR
pstod          .equ  0034h    ; S->D
pmillis        .equ  0035h    ; MILLIS ~ access the timebase of the Arduino
pmess          .equ  0036h    ; (MESSAGE)
pqterm         .equ  0037h    ; ?TERMINAL primative
pzlt           .equ  0038h    ; 0<
ppaloop        .equ  0039h    ; (LOOP)
ppaploo        .equ  003Ah    ; (+LOOP)
pdousex        .equ  003Bh    ; USERX ~ routine for user variables with 16-bit offsets
pleave         .equ  003Ch    ; LEAVE
pcmove         .equ  003Dh    ; CMOVE
pdots          .equ  003Eh    ; .S ~ test routine to look at contents of parameter stack
pdotsl         .equ  003Fh    ; .SL ~ test routine to look at contents of loop stack
pdump          .equ  0040h    ; DUMP
pdouse         .equ  0041h    ; ;(USER) ~ didn't know how to type this, it's the run-time of USER
pfill          .equ  0042h    ; FILL
ptol           .equ  0043h    ; >L ~ pop parameter stack and push to loop stack
plfrom         .equ  0044h    ; L> ~ pop loop stack and push to parameter stack
pexpec         .equ  0045h    ; EXPECT
penclo         .equ  0046h    ; ENCLOSE
ppfind         .equ  0047h    ; (FIND)
plat           .equ  0048h    ; L@
pdstore        .equ  0049h    ; 2!
pdigit         .equ  004Ah    ; DIGIT
ptog           .equ  004Bh    ; TOGGLE
pless          .equ  004Ch    ; <
pgreat         .equ  004Dh    ; >
pdplus         .equ  004Eh    ; D+
pfnamesto      .equ  004Fh    ; FNAME!
plusstore      .equ  0050h    ; +!
pdovar         .equ  0051h    ; dovar
pdocon         .equ  0052h    ; docon
pcswap         .equ  0053h    ; CSWAP
pspat          .equ  0054h    ; SP@
pspsto         .equ  0055h    ; SP!
prpat          .equ  0056h    ; RP@
prpsto         .equ  0057h    ; RP!
ppick          .equ  0058h    ; PICK
pain           .equ  0059h    ; A@
ppupi          .equ  005Ah    ; PUPI
pfdot          .equ  005Bh    ; F.
pdtof          .equ  005Ch    ; D>F
pfslas         .equ  005Dh    ; F/
pftod          .equ  005Eh    ; F>D
pstof          .equ  005Fh    ; S>F
pftos          .equ  0060h    ; F>S
pfswap         .equ  0061h    ; FSWAP
pfdrop         .equ  0062h    ; FDROP
pfdup          .equ  0063h    ; FDUP
pfrot          .equ  0064h    ; FROT
pfstar         .equ  0065h    ; F*
pfplus         .equ  0066h    ; F+
pfsubb         .equ  0067h    ; F-
pfsin          .equ  0068h    ; FSIN
pfcos          .equ  0069h    ; FCOS
pftan          .equ  006Ah    ; FTAN
pfdots         .equ  006Bh    ; F.S
pfasin         .equ  006Ch    ; FASIN
pfacos         .equ  006Dh    ; FACOS
pfatan         .equ  006Eh    ; FATAN
pfatanto       .equ  006Fh    ; FATAN2
pfsqrt         .equ  0070h    ; FSQRT
pfover         .equ  0071h    ; FOVER
pfpow          .equ  0072h    ; FPOW
pfexp          .equ  0073h    ; FEXP
pfat           .equ  0074h    ; F@
pfstore        .equ  0075h    ; F!
pdlit          .equ  0076h    ; DLIT
pspaces        .equ  0077h    ; SPACES
ptype          .equ  0078h    ; TYPE
ppdotq         .equ  0079h    ; (.")
pastor         .equ  007Ah    ; A! ~ analog store (PWM)
pdodo          .equ  007Bh    ; DOES>
pfnamedot      .equ  007Ch    ; FNAME.  ~ output the name stored in the file name array/buffer
psdinit        .equ  007Dh    ; SDINIT  ~ initialize the SD card (find out if it's there too)
pfsize         .equ  007Eh    ; FSIZE   ~ return the size (32-bit) of the currently open file
pfopen         .equ  007Fh    ; FOPEN   ~ open the file named by buffer for either read or write
pfclose        .equ  0080h    ; FCLOSE  ~ close the currently open file
pfemit         .equ  0081h    ; FEMIT   ~ emit a single char into the currently open file
pfkey          .equ  0082h    ; FKEY    ~ retrieve the next char from the currently open file
pfseek         .equ  0083h    ; FSEEK   ~ move to the requested position within the file
pfpos          .equ  0084h    ; FPOS    ~ retrieve the position within the open file
pusere         .equ  0085h    ; USEREE  ~ EEPROM based user variables 
ppemit2        .equ  0086h    ; (EMIT2)
ppemit1        .equ  0087h    ; (EMIT1)
ppemit0        .equ  0088h    ; (EMIT0)
ppof           .equ  0089h    ; (OF) 
pfcells        .equ  008Ah    ; FCELLS
peyep          .equ  008Bh    ; I'
pjayp          .equ  008Ch    ; J'
pkayp          .equ  008Dh    ; K'
pfpstor        .equ  008Eh    ; F+!
pfourmod       .equ  008Fh    ; 4MOD
psxtmod        .equ  0090h    ; 16MOD
pfourslas      .equ  0091h    ; 4/
psxtslas       .equ  0092h    ; 16/
pflt           .equ  0093h    ; F<

pclit          .equ  0095h    ; CLIT

ppkey3         .equ  0097h    ; (KEY3)
ppkey2         .equ  0098h    ; (KEY2)
ppkey1         .equ  0099h    ; (KEY1)
ppkey0         .equ  009Ah    ; (KEY0)
ppsetbaud0     .equ  009Bh    ; (SETBAUD0)  
ppsetbaud1     .equ  009Ch    ; (SETBAUD1) 
ppsetbaud2     .equ  009Dh    ; (SETBAUD2) 
ppsetbaud3     .equ  009Eh    ; (SETBAUD3) 
plpat          .equ  009Fh    ; LP@
plpsto         .equ  00A0h    ; LP!
pfpat          .equ  00A1h    ; FP@
pfpsto         .equ  00A2h    ; FP!
pdofcon        .equ  00A3h    ; (DOFCON)

; -----------------------------------------------------------------------------
;
;   Release & Version numbers
;
figrel      equ   1         ;FIG RELEASE #
figrev      equ   1         ;FIG REVISION #ppkey          
usrver      equ   61h       ;USER VERSION # a by EHR
;
;Console & printer drivers are in external source named
;CONPRTIO.FTH & disc drivers in DISCIO.FTH. It has 4 screen
;buffers & end of memory is set to FBASE from locn. 0007H.
   page
;   ASCII characters used
;
abl      equ   20h          ;BLANK
acr      equ   0dh          ;CR
adot     equ   2eh          ;.
bell     equ   07h          ;^G
bsin     equ   08h          ;backspace chr = ^H
bsout    equ   08h
dle      equ   10h          ;^P
lf       equ   0ah          ;^J
ff       equ   0ch          ;^L
;
;   Memory allocation
;
smem      equ   8000h
emem      equ   ( smem + ( 5 * 1024 )); there 5k available SRAM in the Arduino version
;initdp    equ   smem+12h+13h ; lengths of FORTH+EMIT words
initbf    equ   smem+12h ; length of FORTH word
initdp    equ   initbf+16 ; length of BUF$ for Dynamixel receive bytes
bdoss     equ   0005h       ;/ system entry
nscr      equ   2           ;  # of 1024 byte screens kept in EEPROM
kbbuf     equ   128         ;  bytes/disc buffer
us        equ   40h         ;  user variables space
rts       equ   53h         ;  just term buff space since RS is in an array
co        equ   kbbuf+4     ;  Disc buff + 2 header + 2 tail
nbuf      equ   nscr*400h/kbbuf   ;  # of buffers
bufsiz    equ   co*nbuf     ;/ total disc buffer size
pstacklen equ   64
rstacklen equ   16

;   Aliases for Transplanted Code
;emit     equ     8019h

   page
;
;
;
;     start of the file
;                         _ 
;  _ __   __ _  __ _  ___/ |     The beginning of the FLASH data.
; | '_ \ / _` |/ _` |/ _ | |     The first bytes are stored
; | |_) | (_| | (_| |  __| |     here...
; | .__/ \__,_|\__, |\___|_|
; |_|          |___/        
;
         .ORG    0h

machine:
      DW    codetest           ; this is where the instruction pointer is loaded on reset


;rest of the source code follows
;
orig:
;   nop
      DW     cld               ; vector to cold start

      DW     wrm               ; vector to warm start
      defb   figrel            ; fig release #
      defb   figrev            ; fig revision #
      defb   usrver            ; user version #
      defb   0eh               ; implementation attributes
;
;
;
;   0eh = 0000:1110
;         ---------
; B +ORIGIN   ...W:IEBA
;
; W: 0=above sufficient
;    1=other differences exist
; I: Interpreter is   0=pre-
;         1=post incrementing
; E: Addr must be even: 0 yes
;         1 no
; B: High byte @   0=low addr.
;         1=high addr.
; A: CPU Addr.      0=BYTE
;         1=WORD
;
;

;
   DW   task-7            ;  topmost word in FORTH vocabulary
   DW   bsin              ;  backspace chr
upinit:   
   DW   emem-us           ;/ init (up)
;
; * Following used by COLD; must be in same order as user variables *
;
s0init:   DW   31             ;/ init (s0)
r0init:   DW   15             ;/ init (r0)
tibini:   DW   emem-us-rts    ;/ init (TIB)
   DW   1fh                   ;  init (WIDTH)
   DW   0                     ;  init (WARNING)
   DW   initdp                ;  init (FENCE)
   DW   initdp                ;  init (dp)
   ;DW   forth+8               ;  init (VOC-LINK)
   DW   smem+0Eh              ;  init (VOC-LINK)
;
; *  END DATA USED BY COLD *
;
   DW   32E3h,4A0Ch      ; ATMega256 CPU name (hw,lw)
               ; (32 bit base 36 integer)
   page
;
up:    DW   0             ;/ user area ptr
rpp:   DW   0             ;/ return stack ptr
buf1:  DW   0             ;/ address of 1st disc buffer
;
;
;   COMMENT CONVENTIONS:
;
;   ==   means "is equal to"
;   <--   means assignment
;   #NAME   =     value of name
;   NAME    =     contents @ name
;   (NAME)  =     contents of cell addressed by name
;   cfa   =     code field address
;   lfa   =     link field address
;   nfa   =     name field address
;   pfa   =     parameter field address
;   s1   =     1st word of parameter stack
;   s2   =     2nd -"-  of    -"-     -"-
;   r1   =     1st -"-  of return stack
;   r2   =     2nd -"-  of  -"-    -"-
; ( above Stack posn. valid b4 & after execution of any word, not during)
;
;   lsb   =     least significant bit
;   msb   =     most  significant bit
;   lb    =     low  byte
;   hb    =     high byte
;   lw    =     low  word
;   hw    =     high wordstore
; (May be used as suffix to above names)
   page
.byte    "Figduino"        ; this is my name 
;
;
;
dpush:
;   push   de
hpush:
;   push   hl                ; iy points here
next:

next1:

;
;
;#define  jnext       jp   (ix)

;
;#define  jhpush      jp   (iy)
;
   page
;   FORTH DICTIONARY
;   DICTIONARY FORMAT:
;
;            BYTE
;   ADDRESS NAME      CONTENTS
;   ------- ----      --------
;                  (MSB=1
;                  (P=PRECEDENCE BIT
;                  (S=SMUDGE BIT
;   NFA   NAME FIELD   1PS<LEN>   <NAME LENGTH
;            0<1CHAR>   MSB=0, NAME"S 1st CHAR
;            0<2CHAR>
;              ...
;            1<LCHAR>   MSB=1, NAME"S LAST CHAR
;   LFA   LINK FIELD   <LINKLB>   =PREVIOUS WORD"S NFA
;            <LINKHB>
;LABEL:   CFA   CODE FIELD   <CODELB>   =ADDR CPU CODE
;            <CODEHB>
;   PFA   PARAMETER   <1PARAM>   1st PARAMETER BYTE
;         FIELD       <2PARAM>
;                     ...
;
;   the Dictionary starts here
;
;                         ____  
;  _ __   __ _  __ _  ___|___ \ 
; | '_ \ / _` |/ _` |/ _   __) |
; | |_) | (_| | (_| |  __ / __/ 
; | .__/ \__,_|\__, |\___|_____|
; |_|          |___/  

.ORG     100h

dp0:
;
;----------------------------------------------------------------------------
;
   defb   84h               ; NOOP ~ no operation
   dc     "NOOP"
   DW     0
noop:
   DW     docol
   DW     semis
;
;----------------------------------------------------------------------------
;
   defb   84h               ; CLIT ~ Character Literal
   dc     "CLIT"
   DW     noop-7              ; lfa == 0 marks end of dictionary
clit:
   DW     $+2                 ; s1 <-- (ip)
   DW     pclit
;
;----------------------------------------------------------------------------
;

   defb   83h               ; LIT ~ Word Literal
   dc     "LIT"
   DW     clit-7              ; 
lit:
   DW     $+2                 ; s1 <-- (ip)
   DW     pplit
;
;----------------------------------------------------------------------------
;
   defb   84h               ; DLIT ~ Double (32-bit) Literal
   dc     "DLIT"
   DW     lit-6
dlit:
   DW     $+2
   DW     pdlit
;
;----------------------------------------------------------------------------
;
   defb   87h               ; EXECUTE
   dc     "EXECUTE"
   DW     dlit-7
exec:
   DW     $+2
   DW     pphexecute
;
;----------------------------------------------------------------------------
;
   defb   86h               ; BRANCH
   dc     "BRANCH"
   DW     exec-0ah
bran:
   DW     $+2                 ; ip += (ip)
bran1:
   DW     ppbran
;
;----------------------------------------------------------------------------
;
   defb   87h               ; 0BRANCH
   dc     "0BRANCH"
   DW     bran-9
zbran:
   DW     $+2
   DW     ppzbran
;
;----------------------------------------------------------------------------
;
   defb   86h               ; (LOOP)
   dc     "(LOOP)"
   DW     zbran-0ah
xloop:
   DW     $+2
   DW     ppaloop
;
;----------------------------------------------------------------------------
;
   defb   87h               ; (+LOOP)
   dc     "(+LOOP)"
   DW     xloop-9
xploo:
   DW     $+2
   DW     ppaploo
;
;----------------------------------------------------------------------------
;
   defb   84h               ;  (DO)
   dc     "(DO)"
   DW     xploo-0ah
xdo:
   DW     $+2
   DW     ppvoodoop
;
;----------------------------------------------------------------------------
;
   defb  84h               ; (OF)
   dc    "(OF)"
   DW    xdo-7
pof:
   DW    $+2
   DW    ppof
;
;----------------------------------------------------------------------------
;
   defb   82h               ; >L
   dc     ">L"
   DW     pof-7
tol:
   DW     $+2
   DW     ptol
;
;----------------------------------------------------------------------------
;
   defb   82h               ; L>
   dc     "L>"
   DW     tol-5
lfrom:
   DW     $+2
   DW     plfrom
;
;----------------------------------------------------------------------------
;
   defb   82h               ; L@
   dc     "L@"
   DW     lfrom-5
lat:
   DW     $+2
   DW     plat
;
;----------------------------------------------------------------------------
;
   defb   81h               ; I
   dc     "I"
   DW     lat-5
ido:
   DW     $+2
   DW     ppeye
;
;----------------------------------------------------------------------------
;
   defb  82h               ; I'
   dc    "I'"
   DW    ido-4
ipdo:
   DW    $+2
   DW    peyep
;
;----------------------------------------------------------------------------
;
   defb   81h               ; J
   dc     "J"
   DW   ipdo-5
jdo:
   DW   $+2
   DW    ppjay
;
;----------------------------------------------------------------------------
;
   defb  82h               ; J'
   dc    "J'"
   DW    jdo-4
jpdo:
   DW    $+2
   DW    pjayp
;
;----------------------------------------------------------------------------
;
   defb   81h               ; K
   dc     "K"
   DW   jpdo-5
kdo:
   DW   $+2
   DW    ppkay
;
;----------------------------------------------------------------------------
;
   defb  82h               ; K'
   dc    "K'"
   DW    kdo-4
kpdo:
   DW    $+2
   DW    pkayp
;
;----------------------------------------------------------------------------
;
   defb   85h               ; DIGIT
   dc     "DIGIT"
   DW   kpdo-5
digit:
   DW   $+2
   DW    pdigit                   
;
;----------------------------------------------------------------------------
;
   defb   86h               ; (FIND) (2-1)FAILURE ~ TOS> $addr, NFA
   dc   "(FIND)"          ;        (2-3)SUCCESS
   DW   digit-8
pfind:
   DW   $+2
   DW    ppfind
;
;----------------------------------------------------------------------------
;
   defb   87h               ; ENCLOSE
   dc   "ENCLOSE"
   DW   pfind-9
encl:
   DW   $+2
   DW    penclo
;
;----------------------------------------------------------------------------
;
   defb  8Ch               ; SERIAL.MODES
   dc  "SERIAL.MODES"
   DW    encl-10
sermod:
   DW    dovar
   dc  "SERIAL_5N1"   ;  1
   dc  "SERIAL_6N1"   ;  2
   dc  "SERIAL_7N1"   ;  3
   dc  "SERIAL_8N1"   ;  4
   dc  "SERIAL_5N2"   ;  5
   dc  "SERIAL_6N2"   ;  6
   dc  "SERIAL_7N2"   ;  7
   dc  "SERIAL_8N2"   ;  8  ; <--default
   dc  "SERIAL_5E1"   ;  9
   dc  "SERIAL_6E1"   ; 10
   dc  "SERIAL_7E1"   ; 11
   dc  "SERIAL_8E1"   ; 12
   dc  "SERIAL_5E2"   ; 13
   dc  "SERIAL_6E2"   ; 14
   dc  "SERIAL_7E2"   ; 15
   dc  "SERIAL_8E2"   ; 16
   dc  "SERIAL_5O1"   ; 17
   dc  "SERIAL_6O1"   ; 18
   dc  "SERIAL_7O1"   ; 19
   dc  "SERIAL_8O1"   ; 20
   dc  "SERIAL_5O2"   ; 21
   dc  "SERIAL_6O2"   ; 22
   dc  "SERIAL_7O2"   ; 23
   dc  "SERIAL_8O2"   ; 24
;
;----------------------------------------------------------------------------
;
   defb  8Ah               ; (SETBAUD0)
   dc  "(SETBAUD0)"
   DW    sermod-15
sbd0:
   DW    $+2
   DW    ppsetbaud0
;
;----------------------------------------------------------------------------
;
   defb  8Ah               ; (SETBAUD1)
   dc  "(SETBAUD1)"
   DW    sbd0-13
sbd1:
   DW    $+2
   DW    ppsetbaud1
;
;----------------------------------------------------------------------------
;
   defb  8Ah               ; (SETBAUD2)
   dc  "(SETBAUD2)"
   DW    sbd1-13
sbd2:
   DW    $+2
   DW    ppsetbaud2
;
;----------------------------------------------------------------------------
;
   defb  8Ah               ; (SETBAUD3)
   dc  "(SETBAUD3)"
   DW    sbd2-13
sbd3:
   DW    $+2
   DW    ppsetbaud3
;
;----------------------------------------------------------------------------
;
   defb   87h               ; (EMIT3)
   dc   "(EMIT3)"
   DW   sbd3-13
pemit3:
   DW   $+2
   DW    ppemit
;
;----------------------------------------------------------------------------
;
   defb   87h               ; (EMIT2)
   dc   "(EMIT2)"
   DW   pemit3-10
pemit2:
   DW   $+2
   DW    ppemit2
;
;----------------------------------------------------------------------------
;
   defb   87h               ; (EMIT1)
   dc   "(EMIT1)"
   DW   pemit2-10
pemit1:
   DW   $+2
   DW    ppemit1
;
;----------------------------------------------------------------------------
;
   defb   86h               ; (EMIT)
   dc   "(EMIT)"
   DW   pemit1-10
pemit:
   DW   $+2
   DW    ppemit0
;
;----------------------------------------------------------------------------
;
   defb   84h               ; EMIT 
   dc    "EMIT"
   DW   pemit-9
emit:
   DW    docol
   DW    sernum
   DW    at
   DW    exec
   DW    one
   DW    outt
   DW    pstor
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  86h               ; (KEY3)
   dc  "(KEY3)"
   DW    emit-7
pkey3:
   DW    $+2
   DW    ppkey3

;
;----------------------------------------------------------------------------
;
   defb  86h               ; (KEY2)
   dc  "(KEY2)"
   DW    pkey3-9
pkey2:
   DW    $+2
   DW    ppkey2
;
;----------------------------------------------------------------------------
;
   defb  86h               ; (KEY1)
   dc  "(KEY1)"
   DW    pkey2-9
pkey1:
   DW    $+2
   DW    ppkey1
;
;----------------------------------------------------------------------------
;
   defb  86h               ; (KEY0)
   dc  "(KEY0)"
   DW    pkey1-9
pkey0:
   DW    $+2
   DW    ppkey0
;
;----------------------------------------------------------------------------
;
   defb   83h               ; KEY
   dc   "KEY"
   DW    pkey0-9
;   DW   8012h            ; changed to the EMIT now in SRAM
key:
   DW   $+2
   DW    ppkey
;
;----------------------------------------------------------------------------
;
   defb   89h               ; ?TERMINAL
   dc   "?TERMINAL"
   DW   key-6
qterm:
   DW   $+2
   DW   pqterm
;
;----------------------------------------------------------------------------
;
   defb  82h               ; CR
   dc  "CR"
   DW    qterm-12
cr:
   DW    docol
   DW    lit, 0Dh
   DW    emit
   DW    zero
   DW    outt
   DW    store
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  82h               ; LF
   dc  "LF"
   DW    cr-5
llf:
   DW    docol
   DW    lit, 0Ah
   DW    emit
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  84h               ; CRLF
   dc  "CRLF"
   DW    llf-5
crlf:
   DW    docol
   DW    llf
   DW    cr
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  83h               ; CLS
   dc  "CLS"
   DW    crlf-7
cls:
   DW    docol
   DW    lit
   DW    0Ch
   DW    emit
   DW    zero
   DW    outt
   DW    store
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb   85h               ; CMOVE
   dc   "CMOVE"
   DW   cls-6
cmove:
   DW   $+2
   DW    pcmove
;
;----------------------------------------------------------------------------
;
   defb   86h               ; -CMOVE    ( from to count --- )
   dc   "-CMOVE"
   DW   cmove-8
bcmov:
   DW   $+2
   DW   0
;
;----------------------------------------------------------------------------
;
   defb   82h               ; U*   16*16 unsigned multiply
   dc   "U*"              ;      with 32 bit result
   DW   bcmov-9
ustar:
   DW   $+2
   DW   ppmul
;
;----------------------------------------------------------------------------
;
   defb   82h               ; U/   ( ud u1 -- urem uq )
   dc   "U/"
   DW   ustar-5
uslas:
   DW   $+2
   DW   ppdiv
;
;----------------------------------------------------------------------------
;
   defb   83h               ; AND
   dc   "AND"
   DW   uslas-5
andd:
   DW   $+2                 ; s1 <-- s1 AND s2
   DW   ppand
;
;----------------------------------------------------------------------------
;
   defb   82h               ; OR
   dc   "OR"
   DW   andd-6
orr:
   DW   $+2                 ; s1 <-- s1 OR s2
   DW   ppor
;
;----------------------------------------------------------------------------
;
   defb   83h               ; XOR
   dc   "XOR"
   DW   orr-5
xorr:
   DW   $+2                 ; s1 <-- s1 XOR s2
   DW   ppxor
;
;----------------------------------------------------------------------------
;
   defb  83h               ; NOT
   dc  "NOT" 
   DW    xorr-6
not:
   DW    docol
   DW    mone
   DW    xorr
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb   83h               ; SP@
   dc   "SP@"
   DW   not-6
spat:
   DW   $+2
   DW   pspat               ; s1 <-- sp
;
;----------------------------------------------------------------------------
;
   defb   83h               ; SP!
   dc   "SP!"
   DW   spat-6
spsto:
   DW   $+2                 ; sp <-- s0  (user variable)
   DW   pspsto
;
;----------------------------------------------------------------------------
;
   defb   83h               ; LP@
   dc   "LP@"
   DW   spsto-6
lpat:
   DW   $+2
   DW   plpat               ; s1 <-- sp
;
;----------------------------------------------------------------------------
;
   defb   83h               ; LP!
   dc   "LP!"
   DW   lpat-6
lpsto:
   DW   $+2                 ; sp <-- s0  (user variable)
   DW   plpsto
;
;----------------------------------------------------------------------------
;
   defb   83h               ; FP@
   dc   "FP@"
   DW   lpsto-6
fpat:
   DW   $+2
   DW   pfpat               ; s1 <-- sp
;
;----------------------------------------------------------------------------
;
   defb   83h               ; FP!
   dc   "FP!"
   DW   fpat-6
fpsto:
   DW   $+2                 ; sp <-- s0  (user variable)
   DW   pfpsto
;
;----------------------------------------------------------------------------
;
   defb  85h               ; DEPTH
   dc  "DEPTH"
   DW    fpsto-6
depth:
   DW    docol
   DW    spat
   DW    szero
   DW    at
   DW    swap
   DW    subb
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb   83h               ; RP@
   dc   "RP@"
   DW   depth-8
rpat:
   DW   $+2
   DW   prpat               ; s1 <-- rp
;
;----------------------------------------------------------------------------
;
   defb   83h               ; RP!
   dc   "RP!"
   DW   rpat-6
rpsto:
   DW   $+2                 ; rp <-- r0 (user variable)
   DW   prpsto
;
;----------------------------------------------------------------------------
;
   defb   82h               ; ;S
   dc   ";S"
   DW   rpsto-6
semis:
   DW   $+2                 ; ip <-- r1
   DW    ppsemi
;
;----------------------------------------------------------------------------
;
   defb   85h               ; LEAVE
   dc   "LEAVE"
   DW   semis-5
leave:
   DW   $+2                 ; limit <-- index
   DW    pleave
;
;----------------------------------------------------------------------------
;
   defb   82h               ; >R
   dc   ">R"
   DW   leave-8
tor:
   DW   $+2
   DW    pptor
;
;----------------------------------------------------------------------------
;
   defb   82h               ; R>
   dc   "R>"
   DW   tor-5
fromr:
   DW   $+2
   DW    pprfrom
;
;----------------------------------------------------------------------------
;
   defb   81h               ; R
   dc   "R"
   DW   fromr-5
rr:
   DW   $+2
   DW    pprfetch
;
;----------------------------------------------------------------------------
;
   defb   82h               ; R@
   dc   "R@"
   DW   rr-4
rat:
   DW   $+2
   DW    pprfetch
;
;----------------------------------------------------------------------------
;
   defb   82h               ; 0=
   dc   "0="
   DW   rat-5
zequ:
   DW   $+2
   DW    ppzeq
;
;----------------------------------------------------------------------------
;
   defb  83h                ;/ 0<>
   dc  "0<>"
   DW    zequ-5
znequ:
   DW    docol
   DW    zequ, zequ
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb   82h               ; 0<
   dc   "0<"
   DW   znequ-6
zless:
   DW   $+2
   DW    pzlt
;
;----------------------------------------------------------------------------
;
   defb   82h               ;/ 0>
   dc   "0>"
   DW   zless-5
zgt:
   DW   docol
   DW    dup
   DW    zequ
   DW    swap
   DW    zless
   DW    orr
   DW    mone
   DW    xorr
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb  87h               ; BETWEEN
   dc  "BETWEEN"
   DW    zgt-5
betw:
   DW    docol
   DW    rot
   DW    dup
   DW    tol 
   DW    great
   DW    swap
   DW    lfrom
   DW    less
   DW    andd
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb   81h               ; +
   dc   "+"
   DW   betw-10
plus:
   DW   $+2
   DW    ppadd
;
;----------------------------------------------------------------------------
;
   defb   82h               ; D+ ( d1l d1h d2l d2h -- d3l d3h)
   dc   "D+"
   DW   plus-4
dplus:
   DW   $+2
   DW    pdplus
;
;----------------------------------------------------------------------------
;
   defb   82h               ; D- ( d1l d1h d2l d2h -- d3l d3h)
   dc   "D-"
   DW   dplus-5
dsubb:
   DW   docol
   DW    dminu
   DW    dplus
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   85h               ; MINUS
   dc   "MINUS"
   DW   dsubb-5
minus:
   DW   $+2
   DW   ppminus
;
;----------------------------------------------------------------------------
;
   defb  86h                ; NEGATE
   dc  "NEGATE"
   DW    minus-8
negate:
   DW    $+2
   DW    ppminus
;
;----------------------------------------------------------------------------
;
   defb   86h               ; DMINUS
   dc   "DMINUS"
   DW   negate-9
dminu:
   DW   $+2
   DW   ppdminus
;
;----------------------------------------------------------------------------
;
   defb  87h                ; DNEGATE
   dc  "DNEGATE"
   DW    dminu-9
dneg:
   DW    $+2
   DW    ppdminus
;
;----------------------------------------------------------------------------
;
   defb   84h               ; OVER
   dc   "OVER"
   DW   dneg-10
over:
   DW   $+2
   DW    ppover         
;
;----------------------------------------------------------------------------
;
   defb   84h               ; DROP
   dc   "DROP"
   DW   over-7
drop:
   DW   $+2
   DW    ppdrop
;
;----------------------------------------------------------------------------
;
   defb   85h               ; 2DROP
   dc   "2DROP"
   DW   drop-7
twodrop:
   DW   $+2
   DW    pptdrop
;
;----------------------------------------------------------------------------
;
   defb   84h               ; SWAP
   dc   "SWAP"
   DW   twodrop-8
swap:
   DW   $+2
   DW    ppswap
;
;----------------------------------------------------------------------------
;
   defb   83h               ; DUP
   dc   "DUP"
   DW   swap-7
dup:
   DW   $+2
   DW    ppdup
;
;----------------------------------------------------------------------------
;
   defb   84h               ; TUCK     ( n1 n2 --- n2 n1 n2)
   dc   "TUCK"
   DW   dup-6
tuck:
   DW   docol
   DW    dup
   DW    mrot
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   83h               ; NIP      ( n1 n2 --- n2)
   dc   "NIP"
   DW   tuck-7
nip:
   DW   docol
   DW    swap
   DW    drop
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   84h               ; -ROT     ( n1 n2 n3 --- n3 n1 n2)
   dc   "-ROT"
   DW   nip-6
mrot:
   DW   docol
   DW    rot, rot
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   85h               ; CSWAP   ( n1 --- n1, bytes swapped)
   dc   "CSWAP"
   DW   mrot-7
cswap:
   DW   $+2
   DW   pcswap
;
;----------------------------------------------------------------------------
;
   defb   84h               ; PICK   ( nn...n0 k --- nn..n0 nk)
   dc   "PICK"
   DW   cswap-8
pick:
   DW   $+2
   DW    ppick
;
;----------------------------------------------------------------------------
;
   defb   84h               ; 2DUP
   dc   "2DUP"
   DW   pick-7
tdup:
   DW    docol
   DW    over
   DW    over
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  85h               ; 2SWAP
   dc  "2SWAP"
   DW    tdup-7
tswap:
   DW    docol
   DW    tol, tol
   DW    tor, tor
   DW    lfrom, lfrom
   DW    fromr, fromr
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb   82h               ; +! ( increment, address  - )
   dc   "+!"
   DW   tswap-8
pstor:
   DW    $+2
   DW    plusstore
;
;----------------------------------------------------------------------------
;
   defb   86h               ; TOGGLE
   dc   "TOGGLE"
   DW   pstor-5
toggl:
   DW   $+2
   DW    ptog
;
;----------------------------------------------------------------------------
;
   defb   81h               ; @
   dc   "@"
   DW   toggl-9
at:
   DW   $+2
   DW    ppfetch
;
;----------------------------------------------------------------------------
;
   defb   82h               ; C@
   dc   "C@"
   DW   at-4
cat:
   DW   $+2
   DW    ppcfetch
;
;----------------------------------------------------------------------------
;
   defb   82h               ; 2@
   dc   "2@"
   DW   cat-5
tat:
   DW    docol
   DW    dup                
   DW    twop
   DW    at
   DW    swap               
   DW    at
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb   81h               ; !
   dc   "!"
   DW   tat-5
store:
   DW   $+2
   DW    ppstore
;
;----------------------------------------------------------------------------
;
   defb   82h               ; C!
   dc   "C!"
   DW   store-4
cstor:
   DW   $+2
   DW    ppcstore
;
;----------------------------------------------------------------------------
;
   defb   82h               ; 2! ( d, a - )
   dc   "2!"
   DW   cstor-5
tstor:
   DW    docol
   DW    dup
   DW    twop
   DW    tol
   DW    store
   DW    lfrom
   DW    store
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb   0c1h              ; :
   dc   ":"
   DW   tstor-5
colon:
   DW   docol
   DW   qexec
   DW   scsp
   DW   curr
   DW   at
   DW   cont
   DW   store
   DW   creat
   DW   rbrac
   DW   pscod              ; (;CODE)
docol:
   DW   ppdocol
;
;----------------------------------------------------------------------------
;
   defb   0c1h              ; ;
   dc   ";"
   DW   colon-4
semi:
   DW   docol
   DW   qcsp
   DW   comp ; <-------------- this is where the 
   DW   semis ;                ";" code is appended
   DW   smudg
   DW   lbrac
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   88h               ; CONSTANT
   dc   "CONSTANT"
   DW   semi-4
con:
   DW   docol
   DW   creat
   DW   smudg
   DW   comma
   DW   pscod
docon:
   DW    pdocon
;
;----------------------------------------------------------------------------
;
   defb  88h                ; VARIABLE
   dc  "VARIABLE"
   DW    con-0bh
var:
   DW    docol
   DW    con
   DW    pscod
dovar:
   DW    pdovar
;
;----------------------------------------------------------------------------
;
   defb   84h               ; USER
   dc   "USER"
   DW   var-0bh
user:
   DW   docol
   DW   con
   DW   pscod
douse:
   DW   pdouse

dousex:
   DW   pdousex

dousee:
   DW   pusere
;
;----------------------------------------------------------------------------
;
   defb   81h               ; 0
   dc   "0"
   DW   user-7
zero:
   DW   $+2               
   DW    ppzero
;
;----------------------------------------------------------------------------
;
   defb   81h               ; 1
   dc   "1"
   DW   zero-4
one:
   DW   $+2               
   DW    ppone
;
;----------------------------------------------------------------------------
;
   defb   82h               ; -1
   dc   "-1"
   DW   one-4
mone:
   DW   $+2               
   DW    ppmone
;
;----------------------------------------------------------------------------
;
   defb   81h               ; 2
   dc   "2"
   DW   mone-5
two:
   DW   $+2                
   DW    pptwo
;
;----------------------------------------------------------------------------
;
   defb   82h               ; -2
   dc   "-2"
   DW   two-4
mtwo:
   DW   $+2                
   DW    ppmtwo
;
;----------------------------------------------------------------------------
;
   defb   81h               ; 3
   dc   "3"
   DW    mtwo-5
three:
   DW    docol                
   DW    lit
   DW    3
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb   82h               ; -3
   dc   "-3"
   DW    three-4
mthree:
   DW    docol                
   DW    lit, -3
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb   82h               ; BL ~ an ASCII blank
   dc   "BL"
   DW   mthree-5
bl:
   DW    docon
   DW    20h
;
;----------------------------------------------------------------------------
;
   defb   83h               ; C/L ~ the number of characters per line (editing/vlist)
   dc   "C/L"
   DW   bl-5
csll:
   DW    dousee
   defb  0FEh
;
;----------------------------------------------------------------------------
;
   defb   85h               ; FIRST
   dc   "FIRST"
   DW   csll-6
first:
   DW   docon
   DW   emem-us-rts-1-1024       
;
;----------------------------------------------------------------------------
;
   defb   85h               ; LIMIT
   dc   "LIMIT"
   DW   first-8
limit:
   DW   docon
   DW   emem-us-rts-1     
;
;----------------------------------------------------------------------------
;
   defb   85h               ; B/BUF
   dc   "B/BUF"
   DW   limit-8
bbuf:
   DW   dousee
   defb   0FCh
;
;----------------------------------------------------------------------------
;
   defb   85h               ; B/SCR
   dc   "B/SCR"
   DW   bbuf-8
bscr:
   DW   dousee
   defb   0FAh
;
;----------------------------------------------------------------------------
;
   defb  86h                ; VWIDTH
   dc    "VWIDTH"
   DW    bscr-8
vwidth:
   DW    dousee
   defb  0F8h
;
;----------------------------------------------------------------------------
;
   defb   87h               ; +ORIGIN
   dc   "+ORIGIN"
   DW   vwidth-9
porig:
   DW   docol
   DW   lit
   DW   orig
   DW   plus
   DW   semis
;
;--------------------   USER VARIABLES   ------------------------------------
;                    _   _               
;                   | | | |___  ___ _ __ 
;                   | | | / __|/ _ | '__|
;                   | |_| \__ |  __| |   
;                    \___/|___/\___|_|   

   defb   82h               ; F0 ~ Only one byte is necessary for these 4
   dc   "F0"                      ; variables ~ rewrite the code accordingly
   DW   porig-0ah                   ; 201711121511
fzero:
   DW   dousex
   DW   2
;

   defb   82h               ; L0
   dc   "L0"
   DW   fzero-5
lzero:
   DW   dousex
   DW   4
;

   defb   82h               ; S0
   dc   "S0"
   DW   lzero-5
szero:
   DW   dousex
   DW   6
;
;
   defb   82h               ; R0
   dc   "R0"
   DW   szero-5
rzero:
   DW   dousex
   DW   8
;
;
   defb   83h               ; TIB
   dc   "TIB"
   DW   rzero-5
tib:
   DW   douse
   defb   0ah
;
;
   defb   85h               ; WIDTH
   dc   "WIDTH"
   DW   tib-6
width:
   DW   douse
   defb   0ch
;
;
   defb   87h               ; WARNING
   dc   "WARNING"
   DW   width-8
warn:
   DW   douse
   defb   0eh
;
;
   defb   85h               ; FENCE
   dc   "FENCE"
   DW   warn-0ah
fence:
   DW   douse
   defb   10h
;
;
   defb   82h               ; DP
   dc   "DP"
   DW   fence-8
dp:
   DW   douse
   defb   12h
;
;
   defb   88h               ; VOC-LINK
   dc   "VOC-LINK"
   DW   dp-5
vocl:
   DW   dousex
   DW   14h
;
;
   defb   83h               ; BLK
   dc   "BLK"
   DW   vocl-0bh
blk:
   DW   douse
   defb   16h
;
;
   defb   82h               ; IN
   dc   "IN"
   DW   blk-6
inn:
   DW   douse
   defb   18h
;
;
   defb   83h               ; OUT
   dc   "OUT"
   DW   inn-5
outt:
   DW   douse
   defb   1ah
;
;
   defb   83h               ; SCR
   dc   "SCR"
   DW   outt-6
scr:
   DW   douse
   defb   1ch
;
;
   defb   86h               ; OFFSET
   dc   "OFFSET"
   DW   scr-6
ofset:
   DW   douse
   defb   1eh
;
;
   defb   87h               ; CONTEXT
   dc   "CONTEXT"
   DW   ofset-9
cont:
   DW   douse
   defb   20h
;
;
   defb   87h               ; CURRENT
   dc   "CURRENT"
   DW   cont-0ah
curr:
   DW   douse
   defb   22h
;
;
   defb   85h               ; STATE
   dc   "STATE"
   DW   curr-0ah
state:
   DW   douse
   defb   24h
;
;
   defb   84h               ; BASE
   dc   "BASE"
   DW   state-8
base:
   DW   douse
   defb   26h
;
;
   defb   83h               ; DPL
   dc   "DPL"
   DW   base-7
dpl:
   DW   douse
   defb   28h
;
;
   defb   83h               ; FLD
   dc   "FLD"
   DW   dpl-6
fld:
   DW   douse
   defb   2ah
;
;
   defb   83h               ; CSP
   dc   "CSP"
   DW   fld-6
cspp:
   DW   douse
   defb   2ch
;
;

   defb   82h               ; R#
   dc   "R#"
   DW   cspp-6
rnum:
   DW   douse
   defb   2eh
;
;

   defb   83h               ; HLD
   dc   "HLD"
   DW   rnum-5
hld:
   DW   dousex
   DW   30h
;
;
   defb  87h               ; VERBOSE ~ byte / used by the primatives to engage or suppress text feedback
   dc  "VERBOSE"
   DW    hld-6
verbo:
   DW    douse
   defb  32h
;
;
   defb  83h               ; CUB ~ current block
   dc  "CUB"
   DW    verbo-10
cub:
   DW    douse
   defb  33h
;
;
   defb  86h               ; UPDATE ~ byte / write buffer to block before loading another block?
   dc  "UPDATE"
   DW    cub-6
update:
   DW    douse
   defb  35h
;
;
   defb  86h               ; SHADOW ~ byte / are we displaying the documentation block?
   dc  "SHADOW"
   DW    update-9
shadow:
   DW    douse
   defb  36h
;
;
   defb  84h               ; CSUM ~ word / the summed, word-sized, inverted check-sum of the screen in memory
   dc  "CSUM"
   DW    shadow-9
csum:
   DW    douse
   defb  37h
;
;
   defb  84h               ; ROW# ~ byte
   dc  "ROW#"
   DW    csum-7
rownum:
   DW    douse
   defb  39h
;
;
   defb  84h               ; COL# ~ byte
   dc  "COL#"
   DW    rownum-7
colnum:
   DW    douse
   defb  3Ah

   defb  84h               ; COM# ~ byte
   dc  "COM#"
   DW    colnum-7
comnum:
   DW    douse
   defb  3Bh

   defb  84h               ; SER# ~ word
   dc  "SER#"
   DW    comnum-7
sernum:
   DW    douse
   defb  3Ch

   defb  88h               ; (SHADOW)
   dc  "(SHADOW)"
   DW    sernum-7
pshadow:
   DW    douse
   defb  3Eh
;
;---------------    END OF USER VARIABLES    --------------------------------
;
   defb   82h               ; 1+
   dc   "1+"
   DW   pshadow-11
onep:
   DW   $+2                 
   DW   pponeplus                 
;
;----------------------------------------------------------------------------
;
   defb   82h               ; 2+
   dc   "2+"
   DW   onep-5
twop:
   DW   $+2                 
   DW   pptwoplus                  
;
;----------------------------------------------------------------------------
;
   defb   82h               ; 1-
   dc   "1-"            
   DW   twop-5             
onemin:
   DW   $+2                
   DW   pponeminus             
;
;----------------------------------------------------------------------------
;
   defb   82h               ; 2-
   dc   "2-"              
   DW   onemin-5            
twomin:
   DW   $+2                  
   DW   pptwominus                  
;
;----------------------------------------------------------------------------
;
   defb   82h               ; 2*
   dc   "2*"               
   DW   twomin-5             
twosta:
   DW   $+2                 
   DW   pptwotimes                 
;
;----------------------------------------------------------------------------
;
   defb  82h               ; 4*
   dc  "4*"
   DW    twosta-5
foursta:
   DW    $+2
   DW    pfcells
;
;----------------------------------------------------------------------------
;
   defb   82h               ; 2/
   dc   "2/"               
   DW   foursta-5            
twosla:
   DW   $+2                 
   DW   pptwodivby
;
;----------------------------------------------------------------------------
;
   defb   84h               ; HERE
   dc   "HERE"
   DW   twosla-5
here:
   DW   docol
   DW   dp
   DW   at
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   85h               ; ALLOT
   dc   "ALLOT"
   DW   here-7
allot:
   DW   docol
   DW   dp
   DW   pstor
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb  84h               ; MEM? ~ what is the amount of program memory space?
   dc    "MEM?"
   DW    allot-8
memq:
   DW    docol
   DW    base
   DW    at
   DW    tor
   DW    dec
   DW    first
   DW    here 
   DW    subb
   DW    udot
   DW    pdotq
   defb  6
   dc    "bytes "
   DW    fromr
   DW    base
   DW    store
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  85h               ; TIME? ~ measures and displays the time between
   dc    "TIME?"           ;         two MILLIS events.
   DW    memq-7
timeq:
   DW    docol
   DW    crlf
   DW    base
   DW    at
   DW    tol
   DW    dec
   DW    tswap
   DW    dsubb
   DW    zero
   DW    ddotr
   DW    pdotq
   defb  3
   dc    "ms "
   DW    lfrom
   DW    base
   DW    store
   DW    semis   
;
;----------------------------------------------------------------------------
;
   defb   81h               ; ,
   dc   ","
   DW   timeq-8
comma:
   DW   docol
   DW   here
   DW   store
   DW   two
   DW   allot
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   82h               ; C,
   dc   "C,"
   DW   comma-4
ccomm:
   DW   docol
   DW   here
   DW   cstor
   DW   one
   DW   allot
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   81h               ; -
   dc   "-"
   DW   ccomm-5
subb:
   DW   $+2
   DW    ppsub
;
;----------------------------------------------------------------------------
;
   defb   81h               ; =
   dc   "="
   DW   subb-4
equal:
   DW   $+2                 
   DW    ppequals
;
;----------------------------------------------------------------------------
;
   defb   81h               ;  <
   dc   "<"
   DW   equal-4
less:
   DW   $+2
   DW   pless
;
;----------------------------------------------------------------------------
;
   defb   82h               ; U<  ( d1, d2 - f )
   dc   "U<"
   DW   less-4
uless:
   DW   docol
   DW    tol
   DW    zero
   DW    lfrom
   DW    zero
   DW    dsubb
   DW    drop
   DW    zless
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   81h               ; >
   dc   ">"
   DW   uless-5
great:
   DW   $+2
   DW   pgreat
;
;----------------------------------------------------------------------------
;
   defb   83h               ; ROT     ( n1 n2 n3 --- n2 n3 n1)
   dc   "ROT"
   DW   great-4
rot:
   DW   $+2
   DW    pprot
;
;----------------------------------------------------------------------------
;
   defb   85h               ; SPACE
   dc   "SPACE"
   DW   rot-6
space:
   DW   docol
   DW   bl
   DW   emit
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   84h               ; -DUP
   dc   "-DUP"
   DW   space-8
ddup:
   DW   docol
   DW    dup
   DW    zbran
   DW    ddup1
   DW    dup
ddup1:
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   88h               ; TRAVERSE
   dc   "TRAVERSE"
   DW   ddup-7
trav:
   DW   docol
   DW   swap
trav1:
   DW   over              ; begin
   DW   plus
   DW   lit
   DW   7fh
   DW   over
   DW   cat
   DW   less
   DW   zbran             ; until
   DW   trav1
   DW   swap
   DW   drop
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   86h               ; LATEST
   dc   "LATEST"
   DW   trav-0bh
lates:
   DW   docol
   DW   curr
   DW   at
   DW   at
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   83h               ; LFA         ( PFA -> LFA )
   dc  "LFA"
   DW    lates-9
lfa:
   DW    docol
   DW    lit, 04
   DW    subb
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  83h                ; CFA         ( PFA -> CFA )
   dc  "CFA"
   DW    lfa-6
cfa:     
   DW   $+2                  
   DW   pptwominus   
;
;----------------------------------------------------------------------------
;
   defb  83h                ; NFA         ( PFA -> NFA )
   dc  "NFA"
   DW    cfa-6
nfa:
   DW    docol
   DW    lit
   DW    5
   DW    subb
   DW    mone
   DW    trav
   DW    semis
;
;----------------------------------------------------------------------------
;
; : PFA ( nfa - pfa )
;   DUP C@ 31 AND + 5 + ;

   defb  83h                ; PFA         ( NFA -> PFA )
   dc  "PFA"
   DW    nfa-6
pfa:
   DW    docol
   DW    dup
   DW    cat
   DW    clit 
   defb  01Fh 
   DW    andd
   DW    plus
   DW    clit
   defb  5
   DW    plus
   DW    semis

;
;----------------------------------------------------------------------------
;
   defb  0C4h              ; SELF ~ this is a word to allow recursion by 
   dc  "SELF"            ; compiling the word being defined into the 
   DW    pfa-6             ; word being defined.
self:
   DW    docol
   DW    lates
   DW    pfa
   DW    cfa
   DW    comma
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb   84h               ; !CSP
   dc   "!CSP"
   DW   self-7
scsp:
   DW   docol
   DW   spat
   DW   cspp
   DW   store
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   86h               ; ?ERROR
   dc   "?ERROR"
   DW   scsp-7
qerr:
   DW   docol
   DW   swap
   DW   zbran             ; if
   DW   qerr1
   DW   error
   DW   bran              ; else
   DW   qerr2
qerr1:
   DW   drop              ; endif
qerr2:
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   85h               ; ?COMP
   dc   "?COMP"
   DW   qerr-9
qcomp:
   DW   docol
   DW   state
   DW   at
   DW   zequ
   DW   lit
   DW   11h
   DW   qerr
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   85h               ; ?EXEC
   dc   "?EXEC"
   DW   qcomp-8
qexec:
   DW   docol
   DW   state
   DW   at
   DW   lit
   DW   12h
   DW   qerr
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   86h               ; ?PAIRS
   dc   "?PAIRS"
   DW   qexec-8
qpair:
   DW   docol
   DW   subb
   DW   lit
   DW   13h
   DW   qerr
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   84h              ; ?CSP
   dc   "?CSP"
   DW   qpair-9
qcsp:
   DW   docol
   DW   spat
   DW   cspp
   DW   at
   DW   subb
   DW   lit
   DW   14h
   DW   qerr
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   88h               ; ?LOADING
   dc   "?LOADING"
   DW   qcsp-7
qload:
   DW   docol
   DW   blk
   DW   at
   DW   zequ
   DW   lit
   DW   16h
   DW   qerr
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb  84h               ; LOAD
   dc  "LOAD"
   DW    qload-11
load:
   DW    docol
   DW    zero, shadow, cstor ; I added "0 SHADOW C!" to avoid loading documentation.
   DW    blk, at, tor                                                 ; kjc
   DW    inn, at, tor
   DW    zero, inn, store
   DW    bscr, star
   DW    blk, store
   DW    inter
   DW    fromr, inn, store
   DW    fromr, blk, store
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  0C3h               ; -->
   dc  "-->"
   DW    load-7
nxtscr:
   DW    docol
   DW    qload
   DW    zero, shadow, cstor  ; I added "0 SHADOW C!" to get the proper screen
   DW    zero, inn, store                                              ; kjc
   DW    bscr, blk, at
   DW    over, modd, subb
   DW    blk, pstor
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb   87h               ; COMPILE
   dc   "COMPILE"
   DW   nxtscr-6
comp:
   DW   docol
   DW   qcomp
   DW   fromr
   DW   dup
   DW   twop
   DW   tor
   DW   at
   DW   comma
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   0c1h              ; [  ~ place the system in interpret mode
   dc   "["
   DW   comp-0ah
lbrac:
   DW   docol
   DW   zero
   DW   state
   DW   store
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   81h               ; ]  ~ place the system in compile mode
   dc   "]"
   DW   lbrac-4
rbrac:
   DW   docol
   DW   lit,0c0h
   DW   state,store
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   86h               ; SMUDGE
   dc   "SMUDGE"
   DW   rbrac-4
smudg:
   DW   docol
   DW   lates
   DW   lit
   DW   20h
   DW   toggl
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   83h               ; HEX
   dc   "HEX"
   DW   smudg-9
hex:
   DW   docol
   DW   lit
   DW   10h
   DW   base
   DW   store
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   87h               ; DECIMAL
   dc   "DECIMAL"
   DW   hex-6
dec:
   DW   docol
   DW   lit
   DW   0ah
   DW   base
   DW   store
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb  85h               ; OCTAL
   dc  "OCTAL"
   DW    dec-10
oct:
   DW    docol
   DW    lit
   DW    8
   DW    base
   DW    store 
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  86h               ; BINARY
   dc  "BINARY"
   DW    oct-8
bin:
   DW    docol
   DW    lit
   DW    2
   DW    base
   DW    store
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb   87h               ; (;CODE)
   dc   "(;CODE)"
   DW   bin-9
pscod:
   DW   docol
   DW   fromr
   DW   lates
   DW   pfa
   DW   cfa
   DW   store
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   0c5h              ; ;CODE
   dc   ";CODE"
   DW   pscod-0ah
semic:
   DW   docol
   DW   qcsp
   DW   comp
   DW   pscod
   DW   lbrac
   DW   smudg
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   87h               ; <BUILDS
   dc   "<BUILDS"
   DW   semic-8
build:
   DW   docol
   DW   zero
   DW   con
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   85h               ; DOES>
   dc   "DOES>"
   DW   build-0ah
does:
   DW   docol
   DW   fromr
   DW   lates
   DW   pfa
   DW   store
   DW   pscod
dodoe:
   DW   pdodo
;
;----------------------------------------------------------------------------
;
   defb   85h               ; COUNT  DUP 1+ SWAP C@ ;
   dc   "COUNT"
   DW   does-8
count:
   DW   docol
   DW   dup
   DW   onep
   DW   swap
   DW   cat
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   84h               ; TYPE
   dc   "TYPE"
   DW   count-8
type:
   DW    $+2
   DW    ptype

;   DW   docol
;   DW   ddup
;   DW   zbran             ; if
;   DW   type1
;   DW   over
;   DW   plus
;   DW   swap
;   DW   xdo               ; do
;type2:
;   DW   ido
;   DW   cat
;   DW   emit
;   DW   xloop             ; loop
;   DW   type2
;   DW   bran              ; else
;   DW   type3
;type1:
;   DW   drop              ; endif
;type3:
;   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   89h               ; -TRAILING
   dc   "-TRAILING"
   DW   type-7
dtrai:
   DW   docol
   DW   dup
   DW   zero
   DW   xdo               ; do
dtra1:
   DW   tdup              ;/
   DW   plus
   DW   onemin            ;/
   DW   cat
   DW   bl
   DW   subb
   DW   zbran             ; if
   DW   dtra2
   DW   leave
   DW   bran              ; else
   DW   dtra3
dtra2:
   DW   onemin            ;/
dtra3:
   DW   xloop             ; loop
   DW   dtra1
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   84h               ; (.")
   .byte  28h, 2Eh, 22h, 29h
   DW   dtrai-12
pdotq:
   DW    docol
   DW    rr
   DW    count
   DW    dup
   DW    onep
   DW    fromr
   DW    plus
   DW    tor
   DW    type
   DW    semis

;
;----------------------------------------------------------------------------
;
   defb   0c2h              ; ."
   .byte  2Eh, 22h
   DW   pdotq-7
dotq:
   DW   docol
   DW   lit
   DW   22h
   DW   state
   DW   at
   DW   zbran             ; if
   DW   dotq1
   DW   comp
   DW   pdotq
   DW   word
   DW   here
   DW   cat
   DW   onep
   DW   allot
   DW   bran              ; else
   DW   dotq2
dotq1:
   DW   word
   DW   here
   DW   count
   DW   type              ; endif
dotq2:
   DW   semis
;
;-------------------------------------------------------+
;                       Fig-Model                       |
;   : EXPECT                                            |
;     OVER + OVER                                       |
;     DO                                                |
;        KEY DUP 0E +ORIGIN @ =  ( is this a BS char? ) |
;           IF                                          |
;              DROP 08 OVER I = DUP R> 2 - + >R -       |
;           ELSE                                        |
;              DUP 0D = IF                              |
;                          LEAVE DROP BL 0              |
;                       ELSE                            |
;                          DUP                          |
;                       THEN                            |
;              I C! 0 I 1 + !                           |
;           THEN                                        |
;        EMIT                                           |
;     LOOP                                              |
;     DROP                                              |
;   ;                                                   |
;-------------------------------------------------------+
;
   defb   86h               ; EXPECT  ()
   dc   "EXPECT"
   DW   dotq-5
expec:
   DW   $+2
   DW   pexpec
;
;----------------------------------------------------------------------------
;
;   defb   86h         ; EXPECT
;   dc   "EXPECT"
;   DW   dotq-5
;expec:
;   DW   docol
;   DW   over
;   DW   plus
;   DW   over
;   DW   xdo         ; do
;expe1:
;   DW   key
;   DW   dup
;   ;DW   lit
;   ;DW   0eh
;   ;DW   porig
;   ;DW   at
;   DW    lit, 07Eh
;   DW   equal
;   DW   zbran         ; if
;   DW   expe2
;   DW   drop
;   DW   dup
;   DW   ido
;   DW   equal
;   DW   dup
;   DW   lfrom
;   DW   twomin         ;/
;   DW   plus
;   DW   tol
;   DW   zbran         ; if
;   DW   expe6
;   DW   lit
;   DW   bell
;   DW   bran         ; else
;   DW   expe7
;expe6:
;   DW   lit
;   DW   bsout         ; endif
;expe7:
;   DW   bran         ; else
;   DW   expe3
;expe2:
;   DW   dup
;   DW   lit
;   DW   acr         ;/
;   DW   equal
;   DW   zbran         ; if
;   DW   expe4
;   DW   leave
;   DW   drop
;   DW   bl
;   DW   zero
;   DW   bran         ; else
;   DW   expe5
;expe4:
;   DW   dup         ; endif
;expe5:
;   DW   ido
;   DW   cstor
;   DW   zero
;   DW   ido
;   DW   onep
;   DW   store         ; endif
;expe3:
;   DW   emit
;   DW   xloop         ; loop
;   DW   expe1
;   DW   drop
;   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   85h               ; QUERY
   dc   "QUERY"
   DW   expec-9
query:
   DW   docol
   DW   tib
   DW   at
   DW   lit
   DW   50h
   DW   expec
   DW   zero
   DW   inn
   DW   store
   DW   semis
;
;----------------------------------------------------------------------------------;
;                                                                                  
;  : null      ( --- )                                                             
;           BLK @       IF                                                         
;                          1 BLK +!                                                
;                          0 IN !                                                  
;                          BLK @                                                   
;                          B/SCR 1-                                                
;                          AND   0=                                                
;                             IF                                                   
;                                ?EXEC R> DROP                                     
;                             THEN                                                 
;                       ELSE                                                       
;                          R> DROP                                                 
;                       THEN  ;        IMMEDIATE                                   
;                                                                                  
;----------------------------------------------------------------------------------; 

   defb   0C1h              ; NULL  // notice that the "text" portion of the NFA is '0'
   defb   0                 ; because a '0' is what is parsed when ENCLOSE gets to the
   DW   query-8             ; the end of a buffer...
null:
   DW   docol
   DW   blk
   DW   at
   DW   zbran  ; if >---------------+
   DW   null1  ;                    |
   DW   one ;                       |
   DW   blk ;                       |
   DW   pstor ;                     |
   DW   zero ;                      |
   DW   inn ;                       |
   DW   store ;                     |
   DW   blk ;                       |
   DW   at ;                        |
   DW   bscr ;                      |
   DW   onemin ;                    |
   DW   andd ;                      |
   DW   zequ ;                      |
   DW   zbran ; if >------------+   |
   DW   null2 ;                 |   |
   DW   qexec ;                 |   |
   DW   fromr ;                 |   |
   DW   drop ; endif            |   |
null2: ; <----------------------+   |
   DW   bran ; else >-----+         |
   DW   null3 ;           |         |
null1: ; <----------------|---------+
   DW   fromr ;           |                      
   DW   drop ; endif      |                      
null3: ; <----------------+
   DW   semis ;
;
;----------------------------------------------------------------------------
;
   defb   84h               ; FILL
   dc   "FILL"
   DW   null-4
fill:
   DW   $+2
   DW   pfill
;
;----------------------------------------------------------------------------
;
   defb   85h               ; ERASE
   dc   "ERASE"
   DW   fill-7
erasee:
   DW   docol
   DW   zero
   DW   fill
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   86h               ; BLANKS
   dc   "BLANKS"
   DW   erasee-8
blank:
   DW   docol
   DW   bl
   DW   fill
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   84h               ; HOLD
   dc   "HOLD"
   DW   blank-9
hold:
   DW   docol
   DW   mone
   DW   hld
   DW   pstor
   DW   hld
   DW   at
   DW   cstor
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   83h               ; PAD
   dc   "PAD"
   DW   hold-7
pad:
   DW   docol
   DW   here
   DW   lit, 44h
   DW   plus
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   84h               ; WORD  ~ expects a delimiter on the rtop of the stack
   dc   "WORD"            ;       ~ which it uses to parse the next word from the 
   DW   pad-6               ;       ~ input stream
word:
   DW   docol
   DW   blk
   DW   at
   DW   zbran             ; if (this chooses either the terminal or mass storage as the input)
   DW   word1
   DW   blk
   DW   at
   DW   block
   DW   bran              ; else
   DW   word2
word1:
   DW   tib
   DW   at                ; endif
word2:
   DW   inn
   DW   at
   DW   plus
   DW   swap            ; put the delimiter on TOS

   DW   here            ; clear out space at HERE
   DW   lit, 22h
   DW   blank

   DW   encl            ; "enclose" the next delimiter surrounded word in the input stream

   DW   inn
   DW   pstor
   DW   over
   DW   subb
   DW   tol
   DW   lat
   DW   here
   DW   cstor
   DW   plus
   DW   here
   DW   onep
   DW   lfrom
   DW   cmove
   DW   semis
;
;----------------------------------------------------------------------------
;
;
; : NUMBER  ( addr_of_text_$, - d )
;    0 0 ROT DUP !+ C@ 0x2D = DUP >L
;    + -1
;    BEGIN
;       DPL ! (NUMBER) DUP C@ BL -
;    WHILE
;       DPL @ 0x2E - 0 ?ERROR 0
;    REPEAT
;  DROP L> IF DMINUS THEN
; ;

   defb   88h               ; (NUMBER)
   dc   "(NUMBER)"
   DW   word-7
pnumb:
   DW   docol
pnum1:
   DW   onep              ; begin
   DW   dup

   DW   tol             ; \
   DW   cat
   DW   base
   DW   at
   DW   digit
   DW   zbran             ; while
   DW   pnum2
   DW   swap
   DW   base
   DW   at
   DW   ustar
   DW   drop
   DW   rot
   DW   base
   DW   at
   DW   ustar
   DW   dplus
   DW   dpl
   DW   at
   DW   onep
   DW   zbran             ; if
   DW   pnum3
   DW   one
   DW   dpl
   DW   pstor             ; endif
pnum3:
   DW   lfrom           ; \
   DW   bran              ; repeat
   DW   pnum1
pnum2:
   DW   lfrom           ; \
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   86h               ; NUMBER
   dc   "NUMBER"
   DW   pnumb-0bh
numb:
   DW   docol
   DW   zero
   DW   zero
   DW   rot
   DW   dup
   DW   onep
   DW   cat
   DW   lit
   DW   2dh ; ASCII '-'
   DW   equal
   DW   dup
   DW   tol               ; push the +- flag to the loop stack 
   DW    one              ; mask it so it's either a 0 or 1 for stepping over the '-' if it exists
   DW    andd
   DW   plus
   DW   lit
   DW   -1
numb1:
   DW   dpl               ; begin
   DW   store
   DW   pnumb
   DW   dup
   DW   cat
   DW   bl
   DW   subb ; exit if it's an ASCII space  
   DW   zbran             ; while
   DW   numb2
   DW   dup
   DW   cat
   DW   lit
   DW   2eh ; ASCII '.'
   DW   subb
   DW   zero
   DW   qerr
   DW   zero
   DW   bran              ; repeat
   DW   numb1
numb2:
   DW   drop
   DW   lfrom            
   DW   zbran             ; if
   DW   numb3
   DW   dminu             ; endif
numb3:
   DW   semis
;
;----------------------------------------------------------------------------
;
;
; : -FIND       ( PFA, LEN, TRUE(FFFF)) <----found a match
;               ( FALSE(0000)) <-------------didn't find a match
;    BL  WORD         
;    HERE  CONTEXT  @  @  (FIND)
;    DUP  0=  IF  
;                DROP  HERE  LATEST  (FIND)  
;             ENDIF  
; ;
;
;----------------------------------------------------------------------------
;

   defb   85h               ; -FIND (0-3) SUCCESS
   dc   "-FIND"           ;       (0-1) FAILURE
   DW   numb-9
dfind:
   DW   docol
   DW   bl
   DW   word
   DW   here
   DW   cont
   DW   at
   DW   at
   DW   pfind
   DW   dup
   DW   zequ
   DW   zbran             ; if
   DW   dfin1
   DW   drop
   DW   here
   DW   lates
   DW   pfind             ; endif
dfin1:
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   87h               ; (ABORT)
   dc   "(ABORT)"
   DW   dfind-8
pabor:
   DW   docol
   DW   abort
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   85h               ; ERROR
   dc   "ERROR"
   DW   pabor-0ah
error:
   DW   docol
   DW   warn
   DW   at
   DW   zless
   DW   zbran         ; if
   DW   erro1
   DW   pabor         ; endif
erro1:
   DW   here
   DW   count
   DW   type
   DW   pdotq
   defb   2
   dc  "? "
   DW   mess
   DW   spsto
;   CHANGE FROM fig MODEL
;   DW   inn,at,blk,at
   DW   blk,at
   DW   ddup
   DW   zbran,erro2       ; if
   DW   inn,at
   DW   swap              ; endif
erro2:
   DW   quit
;
;----------------------------------------------------------------------------
; This model does not move the word in question to PAD. It types the word directly
; as there is no reason to clear any bits in the text.  It also recognizes 
; and prints the symbolic names "voc-link" and "null".

;   : ID.
;      DUP 1+ C@ DUP 0= SWAP BL = OR ( the two exceptional cases )
;      IF
;         1+ C@ 
;         CASE
;             0  OF ." null"       ENDOF
;            BL  OF ." voc-link"   ENDOF
;         ENDCASE
;      ELSE
;         DUP 1+ SWAP C@ 
;         0x1F AND TYPE SPACE
;      THEN
;   ;


   defb  83h               ; ID.
   dc  "ID."
   DW    error-8
iddot:
   DW    docol
   DW    dup
   DW    onep
   DW    cat
   DW    dup
   DW    zequ
   DW    swap
   DW    bl
   DW    equal
   DW    orr
   DW    zbran, iddot1
   DW    onep
   DW    cat
   DW    zero
   DW    pof, iddot2
   DW    pdotq
   defb  5
   dc  "null "
   DW    bran, iddot5 ; could go to iddot4 but 
iddot2:               ; iddot4 goes to iddot5 so - shorter leap
   DW    bl
   DW    pof, iddot3
   DW    pdotq
   defb  9
   dc  "voc-link "
   DW    bran, iddot5
iddot3:
   DW    drop
iddot4:
   DW    bran, iddot5
iddot1:
   DW    dup
   DW    onep
   DW    swap
   DW    cat
   DW    clit
   defb  01Fh
   DW    andd
   DW    type
   DW    space
iddot5:
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb   86h               ; CREATE
   dc   "CREATE"
   DW   iddot-6
creat:
   DW   docol
   DW   dfind
   DW   zbran             ; IF
   DW   crea1                 ; the requested name                 
   DW   drop                  ; already exists
   DW   nfa                   ; output the name just created
   DW   iddot                 ; and issue a message saying that 
   DW   lit                   ; the name has been redefined
   DW   4
   DW   mess
   DW   space             ; ENDIF
crea1:
   DW   here
   DW   dup
   DW   cat
   DW   width
   DW   at
   DW   min
   DW   onep
   DW   allot
   DW   dup
   DW   lit
   DW   0a0h
   DW   toggl
   ;DW   here ; these lines may not be consistent
   ;DW   onemin ; with the scanning system used 
   ;DW   lit ; on this system as there are no bits
   ;DW   80h ; set in the text of the NFA; only the
   ;DW   toggl ; count byte
   DW   lates                 ; install the LFA
   DW   comma
   DW   curr                  ; update pointers to recognize this new word
   DW   at
   DW   store
   DW   here                  ; set up the CFA as if a primative's address
   DW   twop                  ; is to follow
   DW   comma
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   0c9h              ; [COMPILE]
   dc   "[COMPILE]"
   DW   creat-9
bcomp:
   DW   docol
   DW   dfind
   DW   zequ
   DW   zero
   DW   qerr
   DW   drop
   DW   cfa
   DW   comma
   DW   semis
;
;----------------------------------------------------------------------------
;
; : LITERAL    STATE @ IF COMPILE LIT , THEN ;
;
;
;
   defb   0c7h              ; LITERAL
   dc   "LITERAL"
   DW   bcomp-12
liter:
   DW   docol
   DW   state
   DW   at
   DW   zbran, lite1             ; if
   DW    dup                 
   DW    abs              
   DW    lit, 080h            
   DW    less                
   DW    zbran, lite2
   DW    comp
   DW    clit
   DW    ccomm
   DW    semis          ; a homemade "else" cheat
lite2:
   DW   comp
   DW   lit
   DW   comma             ; endif
lite1:
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   0c8h              ; DLITERAL
   dc   "DLITERAL"
   DW   liter-0ah
dlite:
   DW   docol
   DW   state
   DW   at
   DW   zbran             ; if
   DW   dlit1
   DW    comp
   DW    dlit
   ;DW   swap
   DW    comma
   DW    comma            ; endif
dlit1:
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb  0C5h               ; ASCII
   dc  "ASCII"
   DW dlite-11
ascii:
   DW    docol
   DW    bl
   DW    word
   DW    here
   DW    onep
   DW    cat
   DW    state
   DW    at
   DW    zbran
   DW    ascii1
   DW    comp
   DW    lit
   DW    comma
ascii1:
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb   86h               ; ?STACK
   dc   "?STACK"
   DW   ascii-8
qstac:
   DW   docol
   DW   spat
   DW   szero
   DW   at
   DW   swap
   DW   uless
   DW   one
   DW   qerr
   DW   spat
   DW   here
   DW   lit
   DW   80h
   DW   plus
   DW   uless
   DW   lit
   DW   7
   DW   qerr
   DW   semis
;
;----------------------------------------------------------------------------
;

;   : INTERPRET   ( interpret of compile source input words )
;     BEGIN  -FIND
;        IF  ( found )  
;           STATE  @  <
;              IF  
;                 CFA  ,  
;              ELSE  
;                 CFA  EXECUTE  
;              ENDIF  
;           ?STACK
;        ELSE  
;           HERE  NUMBER  DPL  @  1+
;              IF  
;                 [COMPILE]  DLITERAL
;              ELSE   
;                 DROP  [COMPILE]  LITERAL  
;              ENDIF  
;           ?STACK
;        ENDIF  
;     AGAIN  
;   ;

   defb   89h               ; INTERPRET
   dc   "INTERPRET"
   DW   qstac-9
inter:
   DW   docol
inte1:
   DW   dfind             ; begin
   DW   zbran             ; if // it's not a word, is it a number?
   DW   inte2
   DW   state
   DW   at
   DW   less
   DW   zbran             ; if // are we executing? 
   DW   inte3
   DW   cfa
   DW   comma
   DW   bran              ; else
   DW   inte4
inte3:
   DW   cfa
   DW   exec              ; endif
inte4:
   DW   qstac
   DW   bran              ; else
   DW   inte5
inte2:
   DW   here
   DW   numb
   DW   dpl
   DW   at
   DW   onep
   DW   zbran             ; if
   DW   inte6
   DW   dlite
   DW   bran              ; else
   DW   inte7
inte6:
   DW   drop
   DW   liter             ; endif
inte7:
   DW   qstac             ; endif
inte5:
   DW   bran              ; again
   DW   inte1
;
;----------------------------------------------------------------------------
;
   defb   89h               ; IMMEDIATE
   dc   "IMMEDIATE"
   DW   inter-0ch
immed:
   DW   docol
   DW   lates
   DW   lit
   DW   40h
   DW   toggl
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   8ah               ; VOCABULARY
   dc   "VOCABULARY"
   DW   immed-0ch
vocab:
   DW   docol
   DW   build
   DW   lit
   DW   8120h
   DW   comma
   DW   curr
   DW   at
   DW   cfa
   DW   comma
   DW   here
   DW   vocl
   DW   at
   DW   comma
   DW   vocl
   DW   store
   DW   does
dovoc:
   DW   twop
   DW   cont
   DW   store
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   0c5h              ; FORTH
   dc   "FORTH"
   DW   vocab-0dh
forth:   
   DW    dodoe
   DW    dovoc

   defb  81h               ; count byte of pseudo-name field
   dc  " "               ; an ASCII blank 
   
   DW    task-7            ; pseudo-LFA cold start value only
                           ; changed aech time a def is appended
                           ; to the FORTH vocabulary
   DW   0                  ; end of vocabulary list ~ analogous to the LFA of '0' in LIT
;
;----------------------------------------------------------------------------
;
   defb   8bh               ; DEFINITIONS
   dc   "DEFINITIONS"
   DW   smem               ; point to 'moved' forth word
defin:
   DW   docol
   DW   cont
   DW   at
   DW   curr
   DW   store
   DW   semis
;
;----------------------------------------------------------------------------
;
; : (     ) WORD ;  IMMEDIATE 
;
   defb   0C1h              ; ( ~ and the following words (P, (F, and (L allow
   dc   "("                 ; more descriptive stack notation in the source 
   DW   defin-0eh           ; code 
paren:
   DW   docol
   DW   clit
   defb 29h
   DW   word
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb  0C2h               ; (P 
   dc    "(P"
   DW    paren-4
pparen:
   DW    docol
   DW    paren
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  0C2h               ; (F
   dc    "(F"
   DW    pparen-5
fparen:
   DW    docol
   DW    paren
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  0C2h               ; (L
   dc    "(L"
   DW    fparen-5
lparen:
   DW    docol
   DW    paren
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  0C2h               ; (R
   dc    "(R"
   DW    lparen-5
rparen:
   DW    docol
   DW    paren
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  0C1h              ; : \   IN @ 64 / 1+ 64 * IN ! ;    IMMEDIATE
   defb  5Ch
   DW    rparen-5
bkslas:
   DW    docol
   DW    inn
   DW    at
   DW    lit, 64
   DW    slash
   DW    onep
   DW    lit, 64
   DW    star
   DW    inn
   DW    store
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb   84h               ; QUIT
   dc   "QUIT"
   DW   bkslas-4
quit:
   DW   docol
   DW   zero
   DW   blk
   DW   store
   DW   lbrac
quit1:
   DW   rpsto             ; begin
   DW   crlf
   DW   query
   DW   inter
   DW   state
   DW   at
   DW   zequ
   DW   zbran             ; if
   DW   quit2
   DW   pdotq
   defb   2
   dc   "ok"            ; endif
   DW    cr
quit2:
   DW   bran              ; again
   DW   quit1
;
;----------------------------------------------------------------------------
;
   defb   85h               ; ABORT
   dc   "ABORT"
   DW   quit-7
abort:
   DW   docol
   DW   spsto
   DW   dec
   DW   qstac
   DW   cr
   ;DW   dotcpu
   ;DW   pdotq
   defb   0fh               ; count of chrs to follow
   dc   "figduino-FORTH "
   defb   figrel+30h,adot,figrev+30h,usrver
   ;DW   forth
   ;DW   defin
   DW   quit
;
;
wrm:   ;ld   bc,wrm1
;   jnext
wrm1:     DW   warm
;
;----------------------------------------------------------------------------
;
   defb   84h               ; WARM
   dc   "WARM"
   DW   abort-8
warm:
   DW   docol
;   DW   mtbuf
   DW   abort
;
;
cld:

cld1:   DW   cold
;----------------------------------------------------------------------------
;
   defb   84h               ; COLD
   dc   "COLD"
   DW   warm-7
cold:
   DW   docol
;   DW   mtbuf
;   DW   one,recadr        ; AvdH
;   DW   store
;   DW   lit,buf1
;   DW   at                ;/
;   DW   use,store
;   DW   lit,buf1
;   DW   at                ;/
;   DW   prev,store
;   DW   drzer
;   DW   zero              ;/
;   DW   lit,eprint
;   DW   cstor             ;/
;
   DW   lit
   DW   orig+12h
   DW   lit, up
   DW   at
   DW   lit, 6
   DW   plus
   DW   lit, 10h
   DW   cmove
   DW   lit, orig+0ch
   DW   at
   DW   lit, forth+6
   DW   store
cld2:
   DW   abort
;
;----------------------------------------------------------------------------
;
   defb   84h               ; S->D
   dc   "S->D"
   DW   cold-7
stod:     
   DW   $+2
   DW   pstod
;
;----------------------------------------------------------------------------
;
   defb   82h               ; +-
   dc   "+-"
   DW   stod-7
pm:
   DW   docol
   DW   zless
   DW   zbran, pm1        ; if
   DW   minus             ; endif
pm1:
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   83h             ; D+-
   dc   "D+-"
   DW   pm-5
dpm:
   DW   docol
   DW   zless
   DW   zbran             ; if
   DW   dpm1
   DW   dminu             ; endif
dpm1:
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   83h             ; ABS
   dc   "ABS"
   DW   dpm-6
abs:
   DW   docol
   DW   dup
   DW   pm
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   84h             ; DABS
   dc   "DABS"
   DW   abs-6
dabs:
   DW   docol
   DW   dup
   DW   dpm
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   83h             ; MIN
   dc   "MIN"
   DW   dabs-7
min:
   DW   docol
   DW   tdup
   DW   great
   DW   zbran             ; if
   DW   min1
   DW   swap              ; endif
min1:
   DW   drop
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   83h             ; MAX
   dc   "MAX"
   DW   min-6
max:   
   DW   docol
   DW   tdup
   DW   less
   DW   zbran             ; if
   DW   max1
   DW   swap              ; endif
max1:
   DW   drop
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   82h             ; M*   ( n1 n2 --- d)
   dc   "M*"
   DW   max-6
mstar:
   DW   docol
   DW    over
   DW    over
   DW    xorr
   DW    tol
   DW    abs
   DW    swap
   DW    abs
   DW    ustar
   DW    lfrom
   DW    dpm
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   82h               ; M/   ( d n1 --- nrem nquot)
   dc   "M/"
   DW   mstar-5
mslas:
   DW   docol
   DW    over
   DW    tol, tol
   DW    dabs
   DW    lat
   DW    abs
   DW    uslas
   DW    lfrom
   DW    lat
   DW    xorr
   DW    pm
   DW    swap
   DW    lfrom
   DW    pm
   DW    swap
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   81h               ; *   ( n1 n2 --- nproduct)
   dc   "*"
   DW   mslas-5
star:
   DW   docol
   DW    mstar
   DW    drop
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   84h               ; /MOD   ( n1 n2 --- nrem nquot)
   dc   "/MOD"
   DW   star-4
slmod:
   DW   docol
   DW    tol
   DW    stod
   DW    lfrom
   DW    mslas
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   81h               ; /
   dc   "/"
   DW   slmod-7
slash:
   DW   docol
   DW    slmod
   DW    nip
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   83h               ; MOD
   dc   "MOD"
   DW   slash-4
modd:
   DW   docol
   DW    slmod
   DW    drop
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   85h               ;/ */MOD
   dc   "*/MOD"
   DW   modd-6
ssmod:
   DW   docol
   DW    tol
   DW    mstar
   DW    lfrom
   DW    mslas
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   82h               ; */
   dc   "*/"
   DW   ssmod-8
ssla:
   DW   docol
   DW    ssmod
   DW    nip
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   85h               ; M/MOD
   dc   "M/MOD"
   DW   ssla-5
msmod:
   DW   docol
   DW   tol
   DW   zero
   DW   lat
   DW   uslas
   DW   lfrom
   DW   swap
   DW   tol
   DW   uslas
   DW   lfrom
   DW   semis
;
;----------------------------------------------------------------------------
;
;  :  BLOCK
;     OFFSET @ + >R PREV @ DUP @ R@ - DUP +
;     IF
;        BEGIN
;           +BUF 0= 
;              IF 
;                 DROP R@ BUFFER DUP R@ 1 R/W 2 - 
;              THEN
;           DUP @ R@ - DUP + 0=
;        UNTIL
;        DUP PREV !
;     THEN R> DROP 2+ 
;  ;
;
;----------------------------------------------------------------------------
;
; If CUB is already equal to the number that is being stored at the requested 
; screen there is no reason to update the information in the buffer.

   defb  85h
   dc  "BLOCK"              ; BLOCK ~ (p blk# - buffer_addr )
   DW    msmod-8
block:
   DW   docol

   DW    dup
   DW    cub, at, equal, not
   DW    shadow, cat, pshadow, cat
   DW    equal, not, orr
   DW    zbran, block3     ; IF

   DW    dup, cub, store   ; make a copy in cub (current block)
   DW    shadow, cat
   DW    pshadow, cstor
   DW    pblk              ; get the fseek address
   DW    readsd, fopen     ; open the SD for reading
   DW    fseek             ; go to the desired data
   DW    zero, csum, store ; setup to create checksum as screen is loaded
   DW    first, dup        ;
   DW    lit, 1024, plus   ;
   DW    swap              ;
   DW    xdo               ;
block1:
   DW    fkey, dup, csum, pstor
   DW    ido, cstor
   DW    xloop, block1
   DW    fclose
   DW    zero, update, cstor ; fresh file does not need updating

   DW    first             ; place the address for the interpreter
block2:
   DW   semis

block3:
   DW    drop
   DW    first
   DW    semis
; 
;----------------------------------------------------------------------------  
;
   defb  85h                  ; FLUSH
   dc  "FLUSH"
   DW    block-8
flush:
   DW    update, cat       ; is a flush necessary?
   DW    zbran, flush1     ;
   DW    sdwrite, fopen    ; open the file for writing
   DW    cub, at, pblk     ; select the proper location in the file
   DW    fseek
   DW    first, dup        ; point to the file buffer
   DW    lit, 1024, plus
   DW    swap
   DW    xdo
flush2:
   DW    ido, cat, femit   ; get the byte and save it
   DW    xloop, flush2     ; and loop 'till fin
   DW    fclose            ; close the file  
   DW    zero, update, cstor ; and update update to reflect the update
flush1:
   DW    semis
; 
;----------------------------------------------------------------------------  
;
   defb   86h               ; (LINE)
   dc   "(LINE)"
   DW   flush-8
pline:
   DW   docol
   DW   tor
   DW   lit
   DW   40h
   DW   bbuf
   DW   ssmod
   DW   fromr
   DW   bscr
   DW   star
   DW   plus
   DW   block
   DW   plus
   DW   lit
   DW   40h
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   85h               ; .LINE
   dc   ".LINE"
   DW   pline-9
dline:
   DW   docol
   DW   pline
   DW   dtrai
   DW   type
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb  89h               ; (MESSAGE)
   dc  "(MESSAGE)"
   DW    dline-8
messiah:
   DW    $+2
   DW    pmess
;
;----------------------------------------------------------------------------
;
   defb   87h               ; MESSAGE
   dc   "MESSAGE"
   DW   messiah-12
mess:
   DW   docol
   DW   warn
   DW   at
   DW   zbran             ; if
   DW   mess1
   DW   ddup
   DW   zbran             ; if
   DW   mess2
   DW   lit
   DW   4                 ; 1st message screen
   DW   ofset
   DW   at
   DW   bscr
   DW   slash
   DW   subb
   DW   dline
   DW   space             ; endif
mess2:
   DW   bran              ; else
   DW   mess3
mess1:
   ;DW   pdotq
   ;defb   6
   ;dc   "MSG # "
   DW   messiah  
   DW crlf                ; endif
mess3:   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   82h               ; P@ (a, - d)
   dc   "P@"
   DW   mess-0ah
ptat:
   DW   $+2
   DW    pppinfetch
;
;----------------------------------------------------------------------------
;
   defb   82h               ; P! (a, d - )
   dc   "P!"
   DW   ptat-5
ptsto:
   DW   $+2
   DW    pppinsto
;
;----------------------------------------------------------------------------
;
   defb   84h               ; PIN@ (a, - d)
   dc   "PIN@"
   DW   ptsto-5
piat:
   DW   $+2
   DW    pppinfetch
;
;----------------------------------------------------------------------------
;
   defb   84h               ; PIN! (a, d - )
   dc   "PIN!"
   DW   piat-7
pisto:
   DW   $+2
   DW    pppinsto
;
;----------------------------------------------------------------------------
;
   defb   83h               ; <P> (a, dir - ) port direction control
   dc   "<P>"
   DW   pisto-7
ptdir:
   DW   $+2
   DW    pppindir
;
;----------------------------------------------------------------------------
;
   defb  82h                ; A@ ~ analog input ~ valid addresses 0~15
   dc  "A@"
   DW    ptdir-6
ain:
   DW    $+2
   DW    pain
;
;----------------------------------------------------------------------------
;
   defb  82h                ; A! ~ analog output
   dc  "A!"
   DW    ain-5
astor:
   DW    $+2
   DW    pastor
;
;----------------------------------------------------------------------------
;
   defb  86h                ; OUTPUT 
   dc  "OUTPUT"
   DW    astor-5
output:
   DW    docol
   DW    lit, -1 
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  85h                ; INPUT
   dc  "INPUT"
   DW    output-9
input:
   DW    docol
   DW    lit, 0
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  84h
   dc  "HIGH"             ; HIGH
   DW    input-8
high:
   DW    docol
   DW    mone
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  83h
   dc  "LOW"             ; LOW
   DW    high-7
low:
   DW    docol
   DW    zero
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  86h               ; MILLIS ~ access the Arduino running counter
   dc  "MILLIS"
   DW    low-6
millis:
   DW    $+2
   DW    pmillis
;
;----------------------------------------------------------------------------
;
   defb   0c1h              ; " (tick)
   dc   "'"
   DW   millis-9
tick:
   DW   docol
   DW   dfind
   DW   zequ
   DW   zero
   DW   qerr
   DW   drop
   DW   liter
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb  85h               ; DEFER ~ used as a place holder for a word to be used prior to its compliation.
   dc  "DEFER"           ;         the word's CFA is inserted later with the aid of the following word "IS"
   DW    tick-4
defer:
   DW    docol
   DW    build
   DW    comma
   DW    does
   DW    at
   DW    exec
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  82h               ; IS
   dc  "IS"
   DW    defer-8
is:
   DW    docol
   DW    twop
   DW    tick
   DW    cfa
   DW    swap
   DW    store
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb   86h               ; FORGET
   dc   "FORGET"
   DW   is-5
forg:
   DW   docol
   DW   curr
   DW   at
   DW   cont
   DW   at
   DW   subb
   DW   lit
   DW   18h
   DW   qerr
   DW   tick
   DW   dup
   DW   fence
   DW   at
   DW   uless             ;/ FORGET >8000h nw o.k.
   DW   lit
   DW   15h
   DW   qerr
   DW   dup
   DW   nfa
   DW   dp
   DW   store
   DW   lfa
   DW   at
   DW   cont
   DW   at
   DW   store
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   84h               ; BACK
   dc   "BACK"
   DW   forg-9
back:
   DW   docol
   ;DW   here
   ;DW   subb              ; this line causes relative branches which this system does not use
   DW   comma
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   0c5h              ; BEGIN
   dc   "BEGIN"
   DW   back-7
begin:
   DW   docol
   DW   qcomp
   DW   here
   DW   one
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   0c5h              ; ENDIF
   dc   "ENDIF"
   DW   begin-8
endiff:
   DW   docol
   DW   qcomp
   DW   two
   DW   qpair
   DW   here
   DW   swap
   DW   store
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   0c4h              ; THEN
   dc   "THEN"
   DW   endiff-8
then:   
   DW   docol
   DW   endiff
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   0c2h              ; DO
   dc   "DO"
   DW   then-7
do:
   DW   docol
   DW   comp
   DW   xdo
   DW   here
   DW   three
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   0c4h              ; LOOP
   dc   "LOOP"
   DW   do-5
loop:
   DW   docol
   DW   three
   DW   qpair
   DW   comp
   DW   xloop
   DW   back
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   0c5h              ; +LOOP
   dc   "+LOOP"
   DW   loop-7
ploop:
   DW   docol
   DW   three
   DW   qpair
   DW   comp
   DW   xploo
   DW   back
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   0c5h              ; UNTIL
   dc   "UNTIL"
   DW   ploop-8
until:
   DW   docol
   DW   one
   DW   qpair
   DW   comp
   DW   zbran
   DW   back
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   0c3h              ; END
   dc   "END"
   DW   until-8
endd:
   DW   docol
   DW   until
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   0c5h              ; AGAIN
   dc   "AGAIN"
   DW   endd-6
again:
   DW   docol
   DW   one
   DW   qpair
   DW   comp
   DW   bran
   DW   back
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   0c6h              ; REPEAT
   dc   "REPEAT"
   DW   again-8
repea:
   DW   docol
   DW   tor
   DW   tor
   DW   again
   DW   fromr
   DW   fromr
   DW   twomin            
   DW   endiff
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   0c2h              ; IF
   dc   "IF"
   DW   repea-9
iff:
   DW   docol
   DW   comp
   DW   zbran
   DW   here
   DW   zero
   DW   comma
   DW   two                ; the ?pairs for IF, ELSE, THENs
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   0c4h              ; ELSE
   dc   "ELSE"
   DW   iff-5
elsee:
   DW   docol
   DW   two
   DW   qpair
   DW   comp
   DW   bran
   DW   here
   DW   zero
   DW   comma
   DW   swap
   DW   two
   DW   endiff
   DW   two
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   0c5h              ; WHILE
   dc   "WHILE"
   DW   elsee-7
while:
   DW   docol
   DW   iff
   DW   twop
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb  0C4h              ; CASE
   dc  "CASE"
   DW    while-8
case:
   DW    docol
   DW    qcomp       ; ?COMP
   DW    cspp        ; CSP
   DW    at          ; @
   DW    scsp        ; !CSP
   DW    lit, 4      ; 4
   DW    semis       ; ;S
;
;----------------------------------------------------------------------------
;
   defb  0C2h              ; OF
   dc  "OF"
   DW    case-7
of:
   DW    docol
   DW    lit, 4      ; 4
   DW    qpair       ; ?PAIRS
   DW    comp        ; COMPILE
   DW    pof         ; (OF)
   DW    here        ; HERE
   DW    zero        ; 0
   DW    comma       ; ,
   DW    lit, 5      ; 5
   DW    semis       ; ;S
;
;----------------------------------------------------------------------------
;
   defb  0C5h              ; ENDOF
   dc  "ENDOF"
   DW    of-5
endof:
   DW    docol       ; :
   DW    lit, 5      ; 5
   DW    qpair       ; ?PAIRS
   DW    comp        ; COMPILE
   DW    bran        ; BRANCH
   DW    here        ; HERE
   DW    zero        ; 0
   DW    comma       ; ,
   DW    swap        ; SWAP
   DW    two         ; 2
   ;DW    bcomp      ; [COMPILE]
   DW    endiff      ; ENDIF
   DW    lit, 4      ; 4
   DW    semis       ; ;S
;
;----------------------------------------------------------------------------
;
   defb  0C7h              ; ENDCASE
   dc  "ENDCASE"
   DW    endof-8
endcase:
   DW    docol       ; :
   DW    lit, 4      ; 4
   DW    qpair       ; ?PAIRS
   DW    comp        ; COMPILE
   DW    drop        ; DROP
ncas1:               ; BEGIN
   DW    spat        ; SP@
   DW    cspp        ; CSP
   DW    at          ; @
   DW    equal       ; =
   DW    zequ        ; 0=
   DW    zbran, ncas2 ; WHILE
   DW    two         ; 2
   ;DW    bcomp      ; [COMPILE]
   DW    endiff      ; ENDIF
   DW    bran, ncas1
ncas2:               ; WHILE
   DW    cspp        ; CSP
   DW    store       ; !  
   DW    semis       ; ;S
;
;----------------------------------------------------------------------------
;
   defb   86h              ; SPACES
   dc   "SPACES"
   DW   endcase-10
spacs:
   DW   $+2
   DW    pspaces
;
;----------------------------------------------------------------------------
;
   defb   82h               ; <#
   dc   "<#"
   DW   spacs-9
bdigs:
   DW   docol
   DW   pad
   DW   hld
   DW   store
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   82h               ; #>
   dc   "#>"
   DW   bdigs-5
edigs:
   DW   docol
   DW   drop
   DW   drop
   DW   hld
   DW   at
   DW   pad
   DW   over
   DW   subb
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   84h               ; SIGN
   dc   "SIGN"
   DW   edigs-5
sign:
   DW   docol
   DW   rot
   DW   zless
   DW   zbran             ; if
   DW   sign1
   DW   lit
   DW   2dh
   DW   hold              ; endif
sign1:
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   81h               ; #
   dc   "#"
   DW   sign-7
dig:
   DW   docol
   DW   base
   DW   at
   DW   msmod
   DW   rot
   DW   lit
   DW   9
   DW   over
   DW   less
   DW   zbran               ; if
   DW   dig1
   DW   lit
   DW   7
   DW   plus                ; endif
dig1:     
   DW   lit
   DW   30h
   DW   plus
   DW   hold
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   82h               ; #S
   dc   "#S"
   DW   dig-4
digs:
   DW   docol
digs1:
   DW   dig                 ; begin
   DW   tdup                ; /
   DW   orr
   DW   zequ
   DW   zbran               ; until
   DW   digs1
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   83h               ; D.R ()
   dc   "D.R"
   DW   digs-5
ddotr:
   DW   docol
   DW   tol
   DW   swap
   DW   over
   DW   dabs
   DW   bdigs
   DW   digs
   DW   sign
   DW   edigs
   DW   lfrom
   DW   over
   DW   subb
   DW   spacs
   DW   type
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   82h               ; .R
   dc   ".R"
   DW   ddotr-6
dotr:
   DW   docol
   DW   tor
   DW   stod
   DW   fromr
   DW   ddotr
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   82h               ; D.
   dc   "D."
   DW   dotr-5
ddot:
   DW   docol
   DW   zero
   DW   ddotr
   DW   space
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   81h               ; .
   dc   "."
   DW   ddot-5
dot:
   DW   docol
   DW   stod
   DW   ddot
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   81h               ; ?
   dc   "?"
   DW   dot-4
ques:
   DW   docol
   DW   at
   DW   dot
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   82h               ; U.
   dc   "U."
   DW   ques-4
udot:     DW   docol
   DW   zero
   DW   ddot
   DW   semis
;
;----------------------------------------------------------------------------
;
;   : VLIST
;      CRLF 0 OFFSET !
;      CONTEXT @ @ 
;      BEGIN
;         1 OFFSET +!
;         OUT @ C/L >
;         IF
;            CRLF 0 OUT !
;         THEN
;         DUP HEX. SPACE DUP ID.
;         0x20 OUT @ OVER MOD - SPACES
;         PFA LFA@ DUP 0=
;      UNTIL
;      DROP 
;      CRLF OFFSET ? ." Words."
;   ;


         
   defb   85h               ; VLIST
   dc   "VLIST"
   DW   udot-5
vlist:
   DW   docol
   DW   crlf
   DW   cont
   DW   at
   DW   at
vlis1:
   DW   outt              ; begin
   DW   at
   DW   csll
   DW   great
   DW   zbran             ; if
   DW   vlis2
   DW   crlf
   DW   zero
   DW   outt
   DW   store             ; endif
vlis2:
   DW   dup
   DW    hexdot
   ;DW    lit, 4, outt, pstor
   DW   space
   DW    dup
   DW   iddot

vlisloo:

   DW    vwidth
   DW    outt
   DW    at
   DW    over
   DW    modd
   DW    subb
   DW    spacs

   DW   pfa
   DW   lfa
   DW   at
   DW   dup
   DW   zequ
   ;DW   qterm
   ;DW   orr
   DW   zbran             ; until
   DW   vlis1
   DW   drop
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   84h             ; LIST
   dc   "LIST"
   DW   vlist-8
list:
   DW   docol
   DW    base, at, dec
   DW   crlf, dup
   DW   scr, store
   DW   pdotq
   defb   6
   dc   "SCR # "
   DW   dot
   DW   lit, 10h
   DW   zero, xdo
list1:
   DW   crlf, ido
   DW   three             ;/ was lit,3
   DW   dotr,space
   DW   ido,scr
   DW   at,dline
   ;DW   qterm
   ;DW   zbran,list2       ; if
   ;DW   leave
list2:
   DW   xloop,list1       ; endif
   DW   crlf
   DW    base, store
   DW   semis
; 
;----------------------------------------------------------------------------
;  
   defb  83h               ; USE
   dc  "USE"
   DW    list-7
use:
   DW   docol
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb  84h               ; PREV
   dc  "PREV"
   DW    use-6
prev:
   DW   docol
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   85H             ; INDEX
   dc   "INDEX"
   DW   prev-7
index:
   DW   docol
   DW   lit, ff
   DW   emit
   DW   crlf
   DW   onep, swap
   DW   xdo
inde1:
   DW   crlf, ido
   DW   three             ;/ was lit,3
   DW   dotr, space
   DW   zero, ido
   DW   dline
   ;, qterm
   ;DW   zbran, inde2       ; if
   ;DW   leave             ; endif
inde2:
   DW   xloop, inde1
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   85h               ; TRIAD
   dc   "TRIAD"
   DW   index-8
triad:
   DW   docol
   DW   lit,ff
   DW   emit
   DW   three             ;/ was lit,3
   DW   slash
   DW   three             ;/ was lit,3
   DW   star
   DW   three             ;/ was lit,3
   DW   over,plus
   DW   swap,xdo
tria1:
   DW   crlf, ido
   DW   list
   ;DW   qterm
   ;DW   zbran,tria2       ; if
   ;DW   leave
tria2:
   DW   xloop,tria1       ; endif
   DW   cr
   DW   lit,15
   DW   mess,cr
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb   84h              ; .CPU
   dc   ".CPU"
   DW   triad-8
dotcpu:
   DW   docol
   DW   base, at
   DW   lit, 36
   DW   base, store
   DW   lit, 22h
   DW   porig, tat
   DW   ddot
   DW   base, store
   DW   semis
;
;----------------------------------------------------------------------------
;
   defb  82h               ; .S
   dc  ".S"
   DW   dotcpu-7
dots:
   DW    $+2
   DW    pdots
;
;----------------------------------------------------------------------------
;
   defb  83h               ; .SL
   dc  ".SL"
   DW    dots-5
dotsl:
   DW    $+2
   DW    pdotsl
;
;----------------------------------------------------------------------------
;
   defb  84h               ; DUMP
   dc  "DUMP"
   DW    dotsl-6
dump:
   DW    $+2
   DW    pdump
;
;----------------------------------------------------------------------------
;
   defb  85h               ; BASE?
   dc  "BASE?"
   DW    dump-7
qbase:
   DW    docol
   DW    base, at
   DW    dup, dec
   DW    dot
   DW    base, store
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  84h               ; HEX. (does not increment OUT)
   dc  "HEX."
   DW    qbase-8
hexdot:
   DW    $+2
   DW    pphexintfig 
;
;----------------------------------------------------------------------------
;   
   defb  83h               ; HEN ~ input 4 hex digits, only works in base=16
   dc  "HEN"
   DW    hexdot-7
hexin:
   DW    docol
   DW    zero
   DW    lit, 4, zero
   DW    xdo
tt1:
   DW    lit, 16 
   DW    ustar, drop
   DW    key, dup, emit
   DW    lit, 16 
   DW    digit, drop
   DW    plus
   DW    xloop, tt1
   DW    semis
;
;----------------------------------------------------------------------------
;   _____ _             _   _             ____       _       _   
;  |  ___| | ___   __ _| |_(_)_ __   __ _|  _ \ ___ (_)_ __ | |_ 
;  | |_  | |/ _ \ / _` | __| | '_ \ / _` | |_) / _ \| | '_ \| __|
;  |  _| | | (_) | (_| | |_| | | | | (_| |  __| (_) | | | | | |_ 
;  |_|   |_|\___/ \__,_|\__|_|_| |_|\__, |_|   \___/|_|_| |_|\__|
;                                   |___/                        

   defb  84h               ; PUPI ( Push PI )
   dc  "PUPI"
   DW    hexin-6
pupi:
   DW    $+2
   DW    ppupi
;
;----------------------------------------------------------------------------
;
   defb  83h               ; PUE ~ push a 2.7182817 to the FP stack
   dc    "PUE"
   DW    pupi-7
pue:
   DW    dofcon
   defb  040h, 02Dh, 0F8h, 054h
;
;----------------------------------------------------------------------------
;
   defb   89h               ; FCONSTANT
   dc   "FCONSTANT"
   DW   pue-6
fcon:
   DW   docol
   DW   creat
   DW   smudg
   DW   fcomma
   DW   pscod
dofcon:
   DW    pdofcon

;
;----------------------------------------------------------------------------
;
   defb  82h               ; F.
   dc  "F."
   DW    fcon-12
fdot:
   DW    $+2
   DW    pfdot
;
;----------------------------------------------------------------------------
;
   defb  83h               ; D>F
   dc  "D>F"
   DW    fdot-5
dtof:
   DW    $+2
   DW    pdtof
;
;----------------------------------------------------------------------------
;
   defb  82h               ; F/
   dc  "F/"
   DW    dtof-6
fslas:
   DW    $+2
   DW    pfslas
;
;----------------------------------------------------------------------------
;
   defb  83h               ; F>D
   dc  "F>D"
   DW   fslas-5
ftod:
   DW    $+2
   DW    pftod
;
;----------------------------------------------------------------------------
;
   defb  83h               ; S>F
   dc  "S>F"
   DW    ftod-6
stof:
   DW    $+2
   DW    pstof
;
;----------------------------------------------------------------------------
;
   defb  83h               ; F>S
   dc  "F>S"
   DW    stof-6
ftos:
   DW    $+2
   DW    pftos
;
;----------------------------------------------------------------------------
;
   defb  85h               ; FSWAP
   dc  "FSWAP"
   DW    ftos-6
fswap:
   DW    $+2
   DW    pfswap
;
;----------------------------------------------------------------------------
;
   defb  85h               ; FOVER
   dc  "FOVER"
   DW    fswap-8
fover:
   DW    $+2
   DW    pfover
;
;----------------------------------------------------------------------------
;
   defb  85h               ; FDROP
   dc  "FDROP"
   DW    fover-8
fdrop:
   DW    $+2
   DW    pfdrop
;
;----------------------------------------------------------------------------
;
   defb  84h               ; FDUP
   dc  "FDUP"
   DW    fdrop-8
fdup:
   DW    $+2
   DW    pfdup
;
;----------------------------------------------------------------------------
;
   defb  84h               ; FROT
   dc  "FROT"
   DW    fdup-7
frot:
   DW    $+2
   DW    pfrot
;
;----------------------------------------------------------------------------
;
   defb  82h               ; F*
   dc  "F*"
   DW    frot-7
fstar:
   DW    $+2
   DW    pfstar
;
;----------------------------------------------------------------------------
;
   defb  82h               ; F+
   dc  "F+"
   DW    fstar-5
fplus:
   DW    $+2
   DW    pfplus
;
;----------------------------------------------------------------------------
;
   defb  82h               ; F-
   dc  "F-"
   DW    fplus-5
fsubb:
   DW    $+2
   DW    pfsubb
;
;----------------------------------------------------------------------------
;
   defb  86h               ; FMINUS  (f f - -f )
   dc  "FMINUS"
   DW    fsubb-5
fminus:
   DW    docol
   DW    mone
   DW    stof
   DW    fstar
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  87h               ; FNEGATE
   dc  "FNEGATE"
   DW    fminus-9
fneg:
   DW    docol
   DW    fminus
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  84h               ; FSIN
   dc  "FSIN"
   DW    fneg-10
fsin:
   DW    $+2
   DW    pfsin
;
;----------------------------------------------------------------------------
;
   defb  84h               ; FCOS
   dc  "FCOS"
   DW    fsin-7
fcos:
   DW    $+2
   DW    pfcos
;
;----------------------------------------------------------------------------
;
   defb  84h               ; FTAN
   dc  "FTAN"
   DW    fcos-7
ftan:
   DW    $+2
   DW    pftan
;
;----------------------------------------------------------------------------
;
   defb  83h               ; F.S
   dc  "F.S"
   DW    ftan-7
fdots:
   DW    $+2
   DW    pfdots
;
;----------------------------------------------------------------------------
;
; : FP>R      (f r, a - x, y ) ~ floating point polar to rectangular
;   FDUP FSIN FSWAP FCOS
;   FROT FDUP FROT F*
;   FSWAP FROT F* ;
;
   defb  84h               ; FP>R
   dc  "FP>R"
   DW    fdots-6
fptor:
   DW    docol
   DW    fdup
   DW    fsin
   DW    fswap
   DW    fcos
   DW    frot
   DW    fdup
   DW    frot
   DW    fstar
   DW    fswap
   DW    frot
   DW    fstar
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  84h               ; FR>P
   dc  "FR>P"
   DW    fptor-7
frtop:
   DW    docol
   DW    fover
   DW    fdup
   DW    fstar
   DW    fover
   DW    fdup
   DW    fstar
   DW    fplus
   DW    fsqrt
   DW    frot
   DW    frot
   DW    fatanto
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  85h               ; FASIN
   dc  "FASIN"
   DW    frtop-7
fasin:
   DW    $+2
   DW    pfasin
;
;----------------------------------------------------------------------------
;
   defb  85h               ; FACOS
   dc  "FACOS"
   DW    fasin-8
facos:
   DW    $+2
   DW    pfacos   
;
;----------------------------------------------------------------------------
;
   defb  85h               ; FATAN
   dc  "FATAN"
   DW    facos-8
fatan:
   DW    $+2
   DW    pfatan
;
;----------------------------------------------------------------------------
;
   defb  86h               ; FATAN2
   dc  "FATAN2"
   DW    fatan-8
fatanto:
   DW    $+2
   DW    pfatanto
;
;----------------------------------------------------------------------------
;
   defb  85h               ; FSQRT
   dc  "FSQRT"
   DW    fatanto-9
fsqrt:
   DW    $+2
   DW    pfsqrt
;
;----------------------------------------------------------------------------
;
   defb  84h               ; FD>R
   dc  "FD>R"
   DW    fsqrt-8
fdtor:
   DW    docol
   DW    lit
   DW    0B4h
   DW    stof
   DW    fslas
   DW    pupi
   DW    fstar
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  84h               ; FR>D
   dc  "FR>D"
   DW    fdtor-7
frtod:
   DW    docol
   DW    pupi
   DW    fslas
   DW    lit
   DW    0B4h
   DW    stof
   DW    fstar
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  84h               ; FPOW    (f base, exp - f ) 
   dc  "FPOW"
   DW    frtod-7
fpow:
   DW    $+2
   DW    pfpow
;
;----------------------------------------------------------------------------
;
   defb  84h               ; FEXP
   dc  "FEXP"
   DW    fpow-7
fexp:
   DW    $+2
   DW    pfexp
;
;----------------------------------------------------------------------------
;
   defb  82h               ; F@
   dc  "F@"
   DW    fexp-7
fat:
   DW    $+2
   DW    pfat
;
;----------------------------------------------------------------------------
;
   defb  82h               ; F!
   dc  "F!"
   DW    fat-5
fstore:
   DW    $+2
   DW    pfstore
;
;----------------------------------------------------------------------------
;
   defb  84h               ; F1/X
   dc  "F1/X"
   DW    fstore-5
frecip:
   DW    docol
   DW    one
   DW    stof
   DW    fswap
   DW    fslas
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  82h               ; F,
   dc  "F,"
   DW    frecip-7
fcomma:
   DW    docol
   DW    here
   DW    fstore
   DW    lit, 4
   DW    allot
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  85h               ; FCELL
   dc  "FCELL"
   DW    fcomma-5
fcell:
   DW    docon
   DW    4
;
;----------------------------------------------------------------------------
;
   defb  86h               ; FCELLS
   dc  "FCELLS"
   DW    fcell-8
fcells:
   DW    $+2
   DW    pfcells  
;
;----------------------------------------------------------------------------
;
   defb  83h               ; F+!
   dc  "F+!"
   DW    fcells-9
fpstor:
   DW    $+2
   DW    pfpstor
;
;----------------------------------------------------------------------------
;
   defb  82h               ; F<
   dc  "F<"
   DW    fpstor-6
flt:
   DW    $+2
   DW    pflt
;
;----------------------------------------------------------------------------
;
   defb  84h               ; D>F.
   dc  "D>F."
   DW    flt-5
dtofdot:
   DW    docol
   DW    dtof
   DW    dpl
   DW    at
   DW    ddup
   DW    zbran
   DW    dtofdot1
   DW    zero
   DW    xdo
dtofdot2:
   DW    clit
   defb  10
   DW    stof
   DW    fslas
   DW    xloop
   DW    dtofdot2
dtofdot1:
   DW    semis
;
;----------------------------------------------------------------------------
;

   defb  89h               ; CODETESTB
   dc  "CODETESTB"
   DW    dtofdot-7
codetestb:                    ; for checking the inner-interpreter on the Arduino
   DW    docol
   DW    lit, 0Ah          ; initialize and check user variables
   DW    lit, 93C0h        ; there are an additional 16 bytes of USER variables in this system
   DW    lit, 40h
   DW    cmove

   DW    lit, 0, blk, store
   DW    lit, 0, inn, store
   DW    zero, rnum, store          ; So the editor starts in the correct place
   DW    mone, cub, store           ; set current block (CUB) to an absurd value to prove virgin state

   DW    clit                       ; set up the offsets for COL# and ROW# for editor
   defb  7
   DW    colnum, cstor
   DW    clit
   defb  5
   DW    rownum, cstor

   DW    two, scr, store


   DW    three                      ; setup serial communication channel
   DW    comnum, cstor       
   DW    lit, pemit3
   DW    sernum, store              

   DW    vocl                       ; setup the vocabulary pointers
   DW    at
   DW    dup
   DW    cont 
   DW    store
   DW    curr
   DW    store
; move the FORTH word into SRAM
   DW    lit, forth-8      ; Source          
   DW    lit, 8000h        ; Destination
   DW    lit, defin-0eh             ; the word after (the distance 'twixt these words is the cmove len)
   DW    lit, forth-8
   DW    subb              ; Byte-count
   DW    cmove

   DW    clit
   defb  15
   DW    lzero, store

   DW    clit
   defb  15
   DW    fzero, store

   DW    mone, dpl, store
   DW    hex
   DW    lbrac                         ; ] ~ put the system in interpret mode

   DW    zero, shadow, cstor           ; initialize the editing and mass reference words
   DW    zero, pshadow, cstor
   DW    zero, update, cstor
   DW    zero, csum, store
   DW    zero, cub, store
;-----------------------------------------------------------------------------------------------------
   DW    lit, 42, lit, 22              ; THIS TESTS THE GPIO BY SETTING 20 OF THE PORT PINS TO OUTPUT
   DW    xdo
initloob:
   DW    output, ido                   ; I OUTPUT <P>
   DW    ptdir
   DW    low, ido                      ; HIGH I P! 
   DW    ptsto
   DW    xloop, initloob
;-----------------------------------------------------------------------------------------------------   
   DW    crlf
   DW    pdotq
   defb  18
   dc  "Ardufigo FIG-Forth"
   DW    crlf
   DW    pdotq
   defb  9
   dc  "codetestb"
   DW    crlf
   DW    crlf

   DW    spsto

reppieb:                                  ; the endless loop
   DW    quit
   DW    bran, reppieb
   DW    semis
;
;----------------------------------------------------------------------------
;
;   ____  ____    _                        
;  / ___||  _ \  / \   ___ ___ ___ ___ ___ 
;  \___ \| | | |/ _ \ / __/ __/ _ / __/ __|
;   ___) | |_| / ___ | (_| (_|  __\__ \__ \
;  |____/|____/_/   \_\___\___\___|___|___/

   defb  86h               ; FNAME!
   dc  "FNAME!"
   DW   codetestb-12
fnamesto:
   DW    $+2
   DW    pfnamesto
;
;----------------------------------------------------------------------------
;
   defb  86h               ; FNAME.
   dc  "FNAME."
   DW    fnamesto-9
fnamedot:
   DW    $+2
   DW    pfnamedot
;
;----------------------------------------------------------------------------
;
   defb  86h               ; SDINIT
   dc  "SDINIT"
   DW    fnamedot-9
sdinit:
   DW    $+2
   DW    psdinit
;
;----------------------------------------------------------------------------
;
   defb  84h               ; READ
   dc  "READ"
   DW    sdinit-9
readsd:
   DW    docon
   DW    0
;
;----------------------------------------------------------------------------
;
   defb  85h               ; WRITE
   dc  "WRITE"
   DW    readsd-7
sdwrite:
   DW    docon
   DW    -1
;
;----------------------------------------------------------------------------
;
   defb  86h               ; >FNAME ~ write a null terminated file name to 
   dc  ">FNAME"          ; the chararray in the form XXXXXXXX.YYY0
   DW    sdwrite-8
tofname:
   DW    docol
   DW    lit, 12, zero
   DW    xdo
tofname1:
   DW    key, dup, emit
   DW    ido, fnamesto
   DW    xloop, tofname1   ;
   DW    zero, lit, 12     ; finally write the terminating null
   DW    fnamesto          ; to the last position in the string
   DW    space
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  85h               ; FSIZE (p - d )
   dc  "FSIZE"
   DW    tofname-9
fsize:
   DW    $+2
   DW    pfsize
;
;----------------------------------------------------------------------------
;
   defb  87h                ; (FOPEN)
   dc  "(FOPEN)"
   DW    fsize-8
fopenp:
   DW    $+2
   DW    pfopen
;
;----------------------------------------------------------------------------
;
   defb  85h               ; FOPEN
   dc  "FOPEN"
   DW    fopenp-10
fopen:
   DW    docol
   DW    one
   DW    lit, 2Bh
   DW    pisto
   DW    fopenp
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  88h               ; (FCLOSE)
   dc  "(FCLOSE)"
   DW    fopen-8
fclosep:
   DW    $+2
   DW    pfclose
;
;----------------------------------------------------------------------------
;
   defb  86h               ; FCLOSE
   dc  "FCLOSE"
   DW    fclosep-11
fclose:
   DW    docol
   DW    zero
   DW    lit, 2Bh
   DW    pisto
   DW    fclosep
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  85h               ; FEMIT
   dc  "FEMIT"
   DW    fclose-9
femit:
   DW    $+2
   DW    pfemit
;
;----------------------------------------------------------------------------
;
   defb  84h               ; FKEY
   dc  "FKEY"
   DW    femit-8
fkey:
   DW    $+2
   DW    pfkey
;
;----------------------------------------------------------------------------
;
   defb  85h               ; FSEEK
   dc  "FSEEK"
   DW    fkey-7
fseek:
   DW    $+2
   DW    pfseek
;
;----------------------------------------------------------------------------
;
   defb  84h               ; FPOS
   dc  "FPOS"
   DW    fseek-8
fpos:
   DW    $+2
   DW    pfpos
;
;----------------------------------------------------------------------------
;  : (FLUSH)
;     WRITE FOPEN (BLOCK) SEEK
;     FIRST DUP 400 + SWAP
;     DO
;        I C@ FEMIT
;     LOOP
;     FCLOSE
;  ;
;
   defb  87h               ; (FLUSH)
   dc  "(FLUSH)"
   DW    fpos-7
pflus:
   DW    docol
   DW    sdwrite
   DW    fopen
   DW    pblk
   DW    fseek
   DW    first
   DW    dup
   DW    lit, 400h
   DW    plus
   DW    swap
   DW    xdo
pflus1:
   DW    ido
   DW    cat
   DW    femit
   DW    xloop, pflus1
   DW    fclose
   DW    semis
;
;----------------------------------------------------------------------------
;
;   __  __       _        _      ____             _   _                
;  |  \/  | __ _| |_ _ __(___  _|  _ \ ___  _   _| |_(_)_ __   ___ ___ 
;  | |\/| |/ _` | __| '__| \ \/ | |_) / _ \| | | | __| | '_ \ / _ / __|
;  | |  | | (_| | |_| |  | |>  <|  _ | (_) | |_| | |_| | | | |  __\__ \
;  |_|  |_|\__,_|\__|_|  |_/_/\_|_| \_\___/ \__,_|\__|_|_| |_|\___|___/

   defb  84h               ; 4MOD
   dc  "4MOD"
   DW    pflus-10
fourmod:
   DW    $+2
   DW    pfourmod
;
;----------------------------------------------------------------------------
;
   defb  82h               ; 4/
   dc  "4/"
   DW    fourmod-7
fourslas:
   DW    $+2
   DW    pfourslas
;
;----------------------------------------------------------------------------
;
   defb  85h               ; 16MOD
   dc  "16MOD"
   DW    fourslas-5
sxtmod:
   DW    $+2
   DW    psxtmod
;
;----------------------------------------------------------------------------
;
   defb  83h               ; 16/
   dc  "16/"
   DW    sxtmod-8
sxtslas:
   DW    $+2
   DW    psxtslas
;
;----------------------------------------------------------------------------
;
   defb  85h               ; (LUT) ~ a read only variable ;) for rotating matrix addresses
   dc  "(LUT)"
   DW    sxtslas-6
plut:
   DW    dovar
   defb  00h, 04h, 08h, 0Ch
   defb  01h, 05h, 09h, 0Dh
   defb  02h, 06h, 0Ah, 0Eh
   defb  03h, 07h, 0Bh, 0Fh,
;
;----------------------------------------------------------------------------
;
   defb  87h               ; TRANSAD ~ takes a 4x4 matrix linear address and rotates it
   dc  "TRANSAD"
   DW    plut-8
txad:
   DW    docol             ; converts this:     to this:
   DW    lit, 0Fh          ;   0 1 2 3          0 4 8 C
   DW    andd              ;   4 5 6 7          1 5 9 D
   DW    plut              ;   8 9 A B          2 6 A E
   DW    plus              ;   C D E F          3 7 B F
   DW    cat
   DW    semis

;
;----------------------------------------------------------------------------
;
   defb  86h               ; M4X4AD
   dc  "M4X4AD"
   DW    txad-10
mfxfad:
   DW    docol
   DW    tol
   DW    fcells
   DW    foursta
   DW    swap
   DW    fcells
   DW    lfrom
   DW    plus
   DW    plus
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  86h               ; M4X1AD
   dc  "M4X1AD"
   DW    mfxfad-9
mfxoad:
   DW    docol
   DW    swap
   DW    fcells
   DW    plus
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  87h               ; CLR4MAT
   dc  "CLR4MAT"
   DW    mfxoad-9
clr4mat:
   DW    docol
   DW    clit
   defb  16
   DW    erasee
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  87h               ; DIA4MAT
   dc  "DIA4MAT"
   DW    clr4mat-10
dia4mat:
   DW    docol
   DW    one
   DW    stof
   DW    tor
   DW    clit
   defb  4
   DW    zero
   DW    xdo
dia4mat1:
   DW    ido
   DW    dup
   DW    rat
   DW    mfxfad
   DW    fdup
   DW    fstore
   DW    xloop, dia4mat1
   DW    fromr
   DW    drop
   DW    fdrop
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  88h               ; PREP4MAT
   dc  "PREP4MAT"
   DW    dia4mat-10
pfmat:
   DW    docol
   DW    dup
   DW    clr4mat
   DW    dia4mat
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  88h               ; PREP3MAT
   dc  "PREP3MAT"
   DW    pfmat-11
ptmat:
   DW    docol
   DW    dup
   DW    clit
   defb  4
   DW    fcells
   DW    erasee
   DW    three
   DW    fcells   
   DW    plus
   DW    one
   DW    stof
   DW    fstore
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  85h               ; 4MAT. 
   dc  "4MAT."
   DW    ptmat-11
fmatdot:
   DW    docol
   DW    tor
   DW    clit
   defb  4
   DW    zero
   DW    xdo
fmatdot1:
   DW    crlf, crlf
   DW    clit
   defb  4
   DW    zero
   DW    xdo
fmatdot2:
   DW    ido
   DW    fcells
   DW    jdo
   DW    foursta
   DW    fcells
   DW    plus
   DW    rat
   DW    plus
   DW    fat
   DW    fdot
   DW    space
   DW    xloop, fmatdot2
   DW    xloop, fmatdot1
   DW    fromr
   DW    drop
   DW    space
   DW    crlf
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  85h               ; 3MAT.
   dc  "3MAT."
   DW    fmatdot-8
tmatdot:
   DW    docol
   DW    tor
   DW    clit
   defb  4
   DW    zero
   DW    xdo
tmatdot1:
   DW    crlf
   DW    ido
   DW    fcells
   DW    rat
   DW    plus
   DW    fat
   DW    fdot
   DW    crlf
   DW    xloop, tmatdot1
   DW    space
   DW    fromr
   DW    drop
   DW    crlf
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  85h               ; PANG!
   dc  "PANG!"
   DW    tmatdot-8
pangsto:
   DW    docol
   DW    rot
   DW    tol
   DW    fdup
   DW    fcos
   DW    fswap 
   DW    fsin
   DW    zequ
   DW    zbran, pangsto1
   DW    fneg
pangsto1:
   DW    fover
   DW    fover
   DW    zequ
   DW    zbran, pangsto2
   DW    fneg
pangsto2:
   DW    semis

;
;----------------------------------------------------------------------------
;
   defb  85h               ; ZANG!
   dc  "ZANG!"
   DW    pangsto-8
zangsto:
   DW    docol
   DW    zero, one, pangsto
   DW    one,  zero, lat,   mfxfad, fstore
   DW    zero, zero, lat,   mfxfad, fstore
   DW    zero, one,  lat,   mfxfad, fstore
   DW    one,  one,  lfrom, mfxfad, fstore
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  85h               ; YANG!
   dc  "YANG!"
   DW    zangsto-8
yangsto:
   DW    docol
   DW    one, zero, pangsto
   DW    two,  zero, lat,   mfxfad, fstore
   DW    zero, zero, lat,   mfxfad, fstore
   DW    zero, two,  lat,   mfxfad, fstore
   DW    two,  two,  lfrom, mfxfad, fstore
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  85h               ; XANG!
   dc  "XANG!"
   DW    yangsto-8
xangsto:
   DW    docol
   DW    zero, one, pangsto
   DW    two,  one,  lat,   mfxfad, fstore
   DW    one,  one,  lat,   mfxfad, fstore
   DW    one,  two,  lat,   mfxfad, fstore
   DW    two,  two,  lfrom, mfxfad, fstore
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  85h               ; M4XM4
   dc  "M4XM4"
   DW    xangsto-8
mfxfm:
   DW    docol
   DW    dup
   DW    clr4mat
   DW    clit
   defb  64
   DW    zero
   DW    xdo
mfxfm1:
   DW    rot
   DW    dup
   DW    ido
   DW    fourmod
   DW    ido
   DW    sxtslas
   DW    foursta
   DW    plus
   DW    fcells
   DW    plus
   DW    fat
   DW    rot
   DW    dup
   DW    sxtmod
   DW    txad
   DW    fcells
   DW    plus
   DW    fat
   DW    fstar
   DW    rot
   DW    dup
   DW    ido
   DW    fourslas
   DW    fcells
   DW    plus
   DW    fpstor
   DW    xloop, mfxfm1
   DW    twodrop
   DW    drop
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  85h               ; M3XM4
   dc  "M3XM4"
   DW    mfxfm-8
mtxfm:
   DW    docol
   DW    dup
   DW    clit
   defb  4
   DW    fcells
   DW    erasee
   DW    clit
   defb  16
   DW    zero
   DW    xdo
mtxfm1:
   DW    rot
   DW    dup
   DW    ido
   DW    fourmod
   DW    fcells
   DW    plus
   DW    fat
   DW    rot
   DW    dup
   DW    ido
   DW    fcells
   DW    plus
   DW    fat
   DW    fstar
   DW    rot
   DW    dup
   DW    ido
   DW    fourslas
   DW    fcells
   DW    plus
   DW    fpstor
   DW    xloop, mtxfm1
   DW    twodrop
   DW    drop
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  84h               ; DIST ~ Takes two 1x4 matrices addresses and 
   dc  "DIST"                     ; leaves the floating point distance
   DW    mtxfm-8                    ;  between the points 
dist:
   DW    docol
   DW    three
   DW    zero
   DW    xdo
dist1:
   DW    over
   DW    over
   DW    ido
   DW    fcells
   DW    plus
   DW    swap
   DW    ido
   DW    fcells
   DW    plus
   DW    fat
   DW    fat
   DW    fsubb
   DW    fdup
   DW    fstar
   DW    xloop, dist1
   DW    fplus
   DW    fplus
   DW    fsqrt
   DW    twodrop
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  86h               ; 3MAT3!
   dc    "3MAT3!"
   DW    dist-7
tmattsto:
   DW    docol
   DW    three
   DW    zero
   DW    xdo
tmattsto1:
   DW    two
   DW    ido
   DW    subb
   DW    fcells
   DW    over
   DW    plus
   DW    fstore
   DW    xloop, tmattsto1
   DW    drop
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  85h               ; 4MAT!
   dc    "4MAT!"
   DW    tmattsto-9
fmatsto:
   DW    docol
   DW    mfxfad
   DW    fstore
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  86h               ; ADDCOL
   dc    "ADDCOL"
   DW    fmatsto-8
addcol:
   DW    docol
   DW    clit
   defb  4
   DW    zero
   DW    xdo
addcol1:
   DW    over
   DW    ido
   DW    fcells
   DW    plus
   DW    fat
   DW    dup
   DW    three
   DW    swap
   DW    ido
   DW    swap
   DW    mfxfad
   DW    fstore
   DW    xloop, addcol1
   DW    twodrop
   DW    semis

;
;----------------------------------------------------------------------------
;
   defb  85h               ; 3MAT+
   dc    "3MAT+"
   DW    addcol-9
tmatp:
   DW    docol
   DW    clit
   defb  4
   DW    zero
   DW    xdo
tmatp1:
   DW    rot
   DW    dup
   DW    ido
   DW    fcells
   DW    plus
   DW    fat
   DW    rot
   DW    dup
   DW    ido
   DW    fcells
   DW    plus
   DW    fat
   DW    fplus
   DW    rot
   DW    dup
   DW    ido
   DW    fcells
   DW    plus
   DW    fstore  
   DW    xloop, tmatp1
   DW    twodrop
   DW    drop
   DW    semis
;
;----------------------------------------------------------------------------
;
;   ______   ___   _    _    __  __ _____  _______ _     
;  |  _ \ \ / | \ | |  / \  |  \/  |_ _\ \/ | ____| |    
;  | | | \ V /|  \| | / _ \ | |\/| || | \  /|  _| | |    
;  | |_| || | | |\  |/ ___ \| |  | || | /  \| |___| |___ 
;  |____/ |_| |_| \_/_/   \_|_|  |_|___/_/\_|_____|_____|
;
;
;----------------------------------------------------------------------------
;
   defb  83h               ; XMT ~ the primative that selects the XMT port
   dc  "XMT"
   DW    tmatp-8
xmt:
   DW    docol
   DW    one
   DW    clit
   defb  2Ah
   DW    pisto
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  84h               ; >MOT
   dc  ">MOT"
   DW    xmt-6
tomot:
   DW   $+2
   DW    ppemit1  
;
;----------------------------------------------------------------------------
;
   defb  82h               ; C+
   dc  "C+"
   DW    tomot-7
cplus:
   DW    docol
   DW    dup
   DW    rot
   DW    plus
   DW    swap
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  86h               ; C+>MOT
   dc  "C+>MOT"
   DW    cplus-5
cptomot:
   DW    docol
   DW    cplus
   DW    tomot
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  87h               ; 2C+>MOT
   dc  "2C+>MOT"
   DW    cptomot-9
tcptomot:
   DW    docol
   DW    dup
   DW    cswap
   DW    lit, 0FFh
   DW    andd
   DW    tor
   DW    lit, 0FFh
   DW    andd
   DW    cptomot
   DW    fromr
   DW    cptomot
   DW    semis 
;
;----------------------------------------------------------------------------
;
   defb  86h               ; xSTART
   dc  "xSTART"
   DW    tcptomot-10
xstart:
   DW    docol
   DW    xmt
   DW    zero
   DW    swap
   DW    mone
   DW    tomot
   DW    mone
   DW    tomot
   DW    cptomot
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  85h               ; xSTOP
   dc  "xSTOP"
   DW    xstart-9
xstop:
   DW    docol
   DW    mone
   DW    xorr
   DW    tomot
   DW    zero
   DW    clit
   defb  2Ah
   DW    pisto
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  84h               ; MOT!
   dc  "MOT!"
   DW    xstop-8
motsto:
   DW    docol
   DW    tol
   DW    tor
   DW    xstart
   DW    clit
   defb  4
   DW    cptomot
   DW    lfrom
   DW    cptomot
   DW    fromr
   DW    cptomot
   DW    swap
   DW    cptomot
   DW    xstop
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  85h               ; 2MOT!
   dc  "2MOT!"
   DW    motsto-7
tmotsto:
   DW    docol
   DW    tol
   DW    tor
   DW    xstart
   DW    clit
   defb  5
   DW    cptomot
   DW    lfrom
   DW    cptomot
   DW    fromr
   DW    cptomot
   DW    swap
   DW    tcptomot
   DW    xstop
   DW    semis    
;
;----------------------------------------------------------------------------
;
   defb  84h               ; MOT&
   dc  "MOT&"
   DW    tmotsto-8
motn:
   DW    docol
   DW    tol
   DW    tor
   DW    xstart
   DW    clit
   defb  4
   DW    cptomot
   DW    lfrom
   DW    cptomot
   DW    fromr
   DW    cptomot
   DW    one
   DW    cptomot
   DW    xstop
   DW    semis   
;
;----------------------------------------------------------------------------
;
   defb  85h               ; 2MOT&
   dc  "2MOT&"
   DW    motn-7
tmotn:
   DW    docol
   DW    tol
   DW    tor
   DW    xstart
   DW    clit
   defb  4
   DW    cptomot
   DW    lfrom
   DW    cptomot
   DW    fromr
   DW    cptomot
   DW    two
   DW    cptomot
   DW    xstop
   DW    semis  
;
;----------------------------------------------------------------------------
;
   defb  84h               ; LED!
   dc  "LED!"
   DW    tmotn-8
ledsto:
   DW    docol
   DW    clit
   defb  19h
   DW    three
   DW    motsto
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  84h               ; SRL!
   dc  "SRL!"
   DW    ledsto-7
srlsto:
   DW    docol
   DW    clit
   defb  10h
   DW    three
   DW    motsto
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  86h               ; SHAFT!
   dc  "SHAFT!"
   DW    srlsto-7
shaftsto:
   DW    docol
   DW    clit
   defb  1Eh
   DW    three
   DW    tmotsto
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  87h               ; TORQUE!
   dc  "TORQUE!"
   DW    shaftsto-9
torksto:
   DW    docol
   DW    clit
   defb  18h
   DW    three
   DW    motsto
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  86h               ; SPEED!
   dc  "SPEED!"
   DW    torksto-10
spedsto:
   DW    docol
   DW    clit
   defb  20h
   DW    three
   DW    tmotsto
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  86h               ; CWLIM!
   dc  "CWLIM!"
   DW    spedsto-9
cwlmsto:
   DW    docol
   DW    clit
   defb  6
   DW    three
   DW    tmotsto
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  86h               ; CCLIM!
   dc  "CCLIM!"
   DW    cwlmsto-9
cclmsto:
   DW    docol
   DW    clit
   defb  8
   DW    three
   DW    tmotsto
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  85h               ; TEMP&
   dc  "TEMP&"
   DW    cclmsto-9
tempn:
   DW    docol
   DW    clit
   defb  2Bh
   DW    two
   DW    motn
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  87h               ; MOVING&
   dc  "MOVING&"
   DW    tempn-8
movin:
   DW    docol
   DW    clit
   defb  2Eh
   DW    two
   DW    motn
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  86h               ; VOLTS&
   dc  "VOLTS&"
   DW    movin-10
voltn:
   DW    docol
   DW    clit
   defb  2Ah
   DW    two
   DW    motn
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  84h               ; POS&
   dc  "POS&"
   DW    voltn-9
posn:
   DW    docol
   DW    clit
   defb  24h
   DW    two
   DW    tmotn
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  84h               ; SRL&
   dc  "SRL&"
   DW    posn-7
srln:
   DW    docol
   DW    clit
   defb  10h
   DW    two
   DW    motn
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  84h               ; $BUF ~ this points to the SRAM, the first loc.
   dc    "$BUF"            ; so it's like a "remote" variable. 
   DW    srln-7
strbuf:
   DW    docon
   DW    initbf
;
;----------------------------------------------------------------------------
;
   defb  83h               ; RX$
   dc    "RX$"
   DW    strbuf-7
rxstr:
   DW    docol
   DW    strbuf
   DW    clit
   defb  16
   DW    erasee
   DW    zero
rxstr1:                    ; begin
   DW    pkey1
   DW    zequ
   DW    not
   DW    zbran, rxstr2     ; while
   DW    over
   DW    clit
   defb  15
   DW    andd
   DW    strbuf
   DW    plus
   DW    cstor
   DW    onep
   DW    bran, rxstr1      ; repeat
rxstr2:
   DW    drop
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  87h               ; RXBFLAG ~ examines the first two characters in
   dc    "RXBFLAG"         ; $BUF and returns a "TRUE" flag if they are both 
   DW    rxstr-6           ; 0xFF
rxbflag:
   DW    docol
   DW    strbuf
   DW    at 
   DW    mone
   DW    equal
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  87h               ; DYNAINC ~ floaing point 300/1024 ~ a constant
   dc    "DYNAINC"         ; often used in the 0h ~ 3FFh to
   DW    rxbflag-10        ; -4.9777374 ~ 185.1636000 remapping
dynainc:
   DW    dofcon
   defb  03Eh, 096h, 0, 0
;
;----------------------------------------------------------------------------
;
   defb  87h               ; DYNAOFS ~ floaing point 4.9777370 the difference
   dc    "DYNAOFS"                     ; between 1FF converted with steps and 
   DW    dynainc-10                    ; 90 degrees
dynaofs:
   DW    dofcon
   defb  042h, 06Eh, 0D4h, 000h
;
;----------------------------------------------------------------------------
;
   defb  85h               ; TEMP.
   dc    "TEMP."
   DW    dynaofs-10
tempdot:
   DW    docol
   DW    base
   DW    at
   DW    tol
   DW    dec
   DW    clit
   defb  9
   DW    clit
   defb  5
   DW    ssla
   DW    clit
   defb  32
   DW    plus
   DW    dot
   DW    lfrom
   DW    base
   DW    store
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  84h               ; DEG. ~ print out the range 0 ~ 3FF as 
   dc    "DEG."            ; -60 ~ 240 degrees. Vertical is 90 deg.
   DW    tempdot-8
degdot:
   DW    docol
   DW    stof
   DW    dynainc
   DW    fstar
   DW    dynaofs
   DW    fsubb
   DW    fdot
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  86h               ; VOLTS.
   dc    "VOLTS."
   DW    degdot-7
voltsdot:
   DW    docol
   DW    base
   DW    at
   DW    tol
   DW    dec
   DW    clit
   defb  10
   DW    slmod
   DW    zero
   DW    dotr
   DW    pdotq
   defb  1, 2Eh
   DW    zero
   DW    dotr
   DW    space
   DW    lfrom
   DW    base
   DW    store
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  84h               ; BUF.
   dc    "BUF."
   DW    voltsdot-9
bufdot:
   DW    docol
   DW    strbuf
   DW    dup
   DW    clit
   defb  16
   DW    plus
   DW    swap
   DW    xdo
bufdot1:
   DW    crlf
   DW    ido
   DW    udot
   DW    ido
   DW    cat
   DW    clit
   defb  5
   DW    dotr
   DW    xloop, bufdot1
   DW    crlf
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  88h               ; FULLROT!
   dc    "FULLROT!"
   DW    bufdot-7
fulrsto:
   DW    docol
   DW    zero
   DW    swap
   DW    tdup
   DW    cwlmsto
   DW    cclmsto
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  88h               ; PARTROT!
   dc    "PARTROT!"
   DW fulrsto-11
parrsto:
   DW    docol
   DW    zero
   DW    swap
   DW    dup
   DW    lit, 03FFh
   DW    swap
   DW    cclmsto
   DW    cwlmsto
   DW    semis

;
;----------------------------------------------------------------------------
;
;   _____    _ _ _             
;  | ____|__| (_| |_ ___  _ __ 
;  |  _| / _` | | __/ _ \| '__|
;  | |__| (_| | | || (_) | |   
;  |_____\__,_|_|\__\___/|_|   
;
;
;----------------------------------------------------------------------------
;

   defb  83h               ; VIG ~ a word to "build" two of the view box 
   dc    "VIG"             ; features.
   DW    parrsto-11
vig:
   DW    docol
   DW    build
   DW    ccomm
   DW    does
vig1:
   DW    at
   DW    clit
   defb  6
   DW    spacs
   DW    clit
   defb  40h
   DW    zero
   DW    xdo
vig2:
   DW    dup
   DW    ido
   DW    base
   DW    at
   DW    rot
   DW    exec
   DW    zero
   DW    dotr
   DW    xloop, vig2
   DW    drop
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  83h               ; VI0
   dc    "VI0"
   DW    vig-6
vi0:
   DW    dodoe
   DW    vig1
   DW    slash
;
;----------------------------------------------------------------------------
;
   defb  83h               ; VI1
   dc    "VI1"
   DW    vi0-6
vi1:
   DW    dodoe
   DW    vig1
   DW    modd
;
;----------------------------------------------------------------------------
;
   defb  83h               ; VI2
   dc    "VI2"
   DW    vi1-6
vi2:
   DW    docol
   DW    clit
   defb  4
   DW    spacs
   DW    clit
   defb  44h
   DW    zero
   DW    xdo
vi21
   DW    lit, 0FFh
   DW    emit
   DW    xloop, vi21
   DW    semis

;
;----------------------------------------------------------------------------
;
   defb  83h               ; VI3
   dc    "VI3"
   DW    vi2-6
vi3:
   DW    docol
   DW    dup
   DW    three
   DW    dotr
   DW    space
   DW    lit, 0FFh
   DW    dup
   DW    emit
   DW    emit      
   DW    clit
   defb  40h
   DW    star
   DW    first
   DW    plus
   DW    dup
   DW    clit
   defb  40h
   DW    plus
   DW    swap
   DW    xdo
vi32:
   DW    ido
   DW    cat
   DW    emit
   DW    xloop, vi32
   DW    lit, 0FFh
   DW    dup
   DW    emit
   DW    emit   
   DW    semis      
;
;----------------------------------------------------------------------------
;
   defb  84h               ; VIEW
   dc    "VIEW"
   DW    vi3-6
view:
   DW    docol
   DW    block
   DW    drop
   DW    crlf, vi0
   DW    crlf, vi1
   DW    crlf, vi2
   DW    clit
   defb  10h
   DW    zero
   DW    xdo
view1:
   DW    crlf, ido, vi3
   DW    xloop, view1
   DW    crlf, vi2
   DW    crlf
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  84h               ; -GEN
   dc    "-GEN"
   DW    view-7
dashgen:
   DW    docol
   DW    build
   DW    comma
   DW    comma
   DW    does
dashgen1:
   DW    dup
   DW    twop
   DW    at
   DW    swap
   DW    at
   DW    first
   DW    dup
   DW    lit, 400h
   DW    plus
   DW    swap
   DW    xdo
dashgen2:
   DW    tdup
   DW    ido
   DW    cat
   DW    betw
   DW    bran, dashgen3
   DW    bl
   DW    ido
   DW    cat
dashgen3:
   DW    xloop, dashgen2
   DW    twodrop
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  82h               ; -0
   dc    "-0"
   DW    dashgen-7
dashzero:
   DW    dodoe
   DW    dashgen1
   DW   -1
   DW    1 
;
;----------------------------------------------------------------------------
;
   defb  83h              ; -BS
   dc    "-BS"
   DW    dashzero-5
dashbs:
   DW    dodoe
   DW    dashgen1
   DW    01Fh
   DW    07Fh 
;
;----------------------------------------------------------------------------
;
   defb  87h               ; FACLIN1 ~ factored code from the line-based
   dc    "FACLIN1"         ; operations.
   DW    dashbs-6
faclin1:
   DW    docol
   DW    clit
   defb  0Fh
   DW    andd
   DW    clit
   defb  40h
   DW    star
   DW    first
   DW    plus
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  85h               ; >LINE ( line# - )
   dc    ">LINE"
   DW    dashbs-6
toline:
   DW    docol
   DW    faclin1
   DW    clit
   defb  40h
   DW    expec
   DW    dashzero
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  86h               ; >LINE> ( line#1, line#2 - )
   dc    ">LINE>"
   DW    toline-8
tolinefr:
   DW    docol
   DW    faclin1
   DW    swap
   DW    faclin1
   DW    swap
   DW    clit
   defb  40h
   DW    cmove
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  87h               ; BL>LINE
   dc    "BL>LINE"
   DW    tolinefr-9
bltoline:
   DW    docol
   DW    faclin1
   DW    clit
   defb  40h
   DW    blank
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  88h               ; INS>LINE
   dc    "INS>LINE"
   DW    bltoline-10
instoline:
   DW    docol
   DW    clit
   defb  0Fh
   DW    andd
   DW    onemin
   DW    dup
   DW    clit
   defb  0Eh
   DW    xdo
instoline1:
   DW    ido
   DW    dup
   DW    onep
   DW    tolinefr
   DW    mone
   DW    xploo, instoline1
   DW    onep
   DW    bltoline
   DW    semis 
;
;----------------------------------------------------------------------------
;
   defb  86h               ; BL>SCR
   dc    "BL>SCR"
   DW    instoline-11
bltoscr:
   DW    docol
   DW    first
   DW    lit, 400h
   DW    blank
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  88h               ; DEL>LINE
   dc    "DEL>LINE"
   DW    bltoscr-9
deltoline:
   DW    docol
   DW    clit
   defb  0Fh
   DW    swap
   DW    xdo
deltoline1:
   DW    ido
   DW    dup
   DW    onep
   DW    swap
   DW    tolinefr
   DW    xloop, deltoline1
   DW    clit
   defb  0Fh
   DW    bltoline
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  86h               ; GOTOXY
   dc  "GOTOXY"
   DW    deltoline-11
gotoxy:
   DW    docol
   DW    base
   DW    at
   DW    dec
   DW    tol
   DW    escbrk
   DW    zero
   DW    dotr
   DW    pdotq
   defb  01h, 3Bh       ; ;
   DW    zero
   DW    dotr
   DW    pdotq
   defb  01h, 66h       ; f
   DW    lfrom
   DW    base
   DW    store
   DW    semis

;
;----------------------------------------------------------------------------
;
   defb  84h               ; ESC[
   dc  "ESC["
   DW    gotoxy-9
escbrk:
   DW    docol
   DW    pdotq
   defb  02h, 1Bh, 5Bh
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  83h               ; C>S ~ expand a byte to a full word with sign
   dc  "C>S"                        ; extend.
   DW    escbrk-7
ctos:
   DW    docol
   DW    dup
   DW    lit, 80h
   DW    andd
   DW    zbran, ctos1
   DW    lit, 0FF00h
   DW    orr
ctos1:
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  87h               ; #GOTOXY
   dc  "#GOTOXY"
   DW    ctos-6
hashgoto:
   DW    docol
   DW    rnum
   DW    at
   DW    lit, 40h
   DW    slmod
   DW    rownum
   DW    cat
   DW    plus
   DW    swap
   DW    colnum
   DW    cat
   DW    plus
   DW    swap
   DW    gotoxy
   DW    semis
;
;----------------------------------------------------------------------------
;
chartab:
   defb  000h, 000h, 000h, 000h
   defb  001h, 0C0h, 000h, 000h
   defb  000h, 000h, 000h, 000h
   defb  000h, 000h, 000h, 000h
   defb  000h, 000h, 000h, 0FFh
   defb  000h, 000h, 000h, 000h
   defb  040h, 000h, 000h, 000h
   defb  000h, 000h, 000h, 000h
;
;----------------------------------------------------------------------------
;
   defb  86h               ; (COMM) ~ less than 0x20 command translation
   dc  "(COMM)"
   DW    hashgoto-10
pcomm:
   DW    docol
   DW    lit, chartab
   DW    plus
   DW    cat
   DW    ctos
   DW    rnum
   DW    pstor
   DW    rnum
   DW    at
   DW    lit, 3FFh
   DW    andd
   DW    rnum
   DW    store
   DW    hashgoto
   DW    semis

;
;----------------------------------------------------------------------------
;
   defb  86h               ; (RFSH)
   dc  "(RFSH)"
   DW    pcomm-9
prfsh:
   DW    docol
   DW    lit, 40h
   DW    star
   DW    first
   DW    plus
   DW    dup
   DW    lit, 40h
   DW    plus
   DW    swap
   DW    xdo
prfsh1:
   DW    ido
   DW    cat
   DW    emit
   DW    xloop
   DW    prfsh1
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  85h               ; RFSH1
   dc  "RFSH1"
   DW    prfsh-9
rfsh1:
   DW    docol
   DW    lit, 10h
   DW    zero
   DW    xdo
rfsh12:
   DW    ido
   DW    lit, 40h
   DW    star
   DW    rnum
   DW    store
   DW    hashgoto
   DW    ido 
   DW    prfsh
   DW    xloop
   DW    rfsh12
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  87h               ; RFSHSCR
   dc  "RFSHSCR"
   DW    rfsh1-8
rfshscr:
   DW    docol
   DW    rnum
   DW    at
   DW    rfsh1
   DW    noop
   DW    noop
   DW    hashgoto
   DW    semis
;
;----------------------------------------------------------------------------
;

   defb  88h               ; CHECKSUM (p - csum_of_sd_buffer)
   dc  "CHECKSUM"
   DW    rfsh1-8
cksum:
   DW    docol
   DW    zero
   DW    first
   DW    dup
   DW    lit, 1024
   DW    plus, swap
   DW    xdo
csum1:
   DW    ido, cat, plus
   DW    xloop, csum1
   DW    semis
;
;----------------------------------------------------------------------------
;
;
;    : (BLOCK)
;       2048 U* 1024. D- 
;       SHADOW C@ 
;       IF 
;          1024. D+ 
;       THEN ;

   defb  87h               ; (BLOCK)
   dc  "(BLOCK)"
   DW    cksum-11
pblk:
   DW    docol
   DW    lit, 2048
   DW    ustar
   DW    dlit, 0, 1024
   DW    dsubb
   DW    shadow, cat
   DW    zbran, pblk1
   DW    dlit, 0, 1024
   DW    dplus
pblk1:
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  86h               ; CURMOV ~ the ANSII cursor movememt build word
   dc    "CURMOV"
   DW    pblk-10
curmov:
   DW    docol
   DW    build
   DW    ccomm
   DW    does
curmov1:
   DW    escbrk
   DW    swap
   DW    zero
   DW    dotr
   DW    cat
   DW    emit 
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  83h               ; CUP ~ Esc[ValueA ~ "cursor up"
   dc    "CUP"
   DW    curmov-9
cup:
   DW    dodoe
   DW    curmov1
   dc    "A"
;
;----------------------------------------------------------------------------
;
   defb  83h               ; CDN ~ Esc[ValueB "cursor down"
   dc    "CDN"
   DW    cup-6
cdn:
   DW    dodoe
   DW    curmov1
   dc    "B"
;
;----------------------------------------------------------------------------
;
   defb  83h               ; CBK ~ Esc[ValueD "cursor back"
   dc    "CBK"
   DW    cdn-6
cbk:
   DW    dodoe
   DW    curmov1
   dc    "D"
;
;----------------------------------------------------------------------------
;
   defb  83h               ; CFW ~ Esc[ValueC "cursor forward"
   dc    "CFW"
   DW    cbk-6
cfw:
   DW    dodoe
   DW    curmov1
   dc    "C"
;
;----------------------------------------------------------------------------
;
   defb  85h               ; COLOR
   dc    "COLOR"
   DW    cfw-6
color:
   DW    docol
   DW    base
   DW    at
   DW    tol
   DW    dec
   DW    escbrk
   DW    pdotq
   defb  5
   dc    "38;5;"
   DW    zero
   DW    dotr
   DW    pdotq
   defb  1
   dc    "m"
   DW    lfrom
   DW    base
   DW    store
   DW    semis

;
;----------------------------------------------------------------------------
;
   defb  87h               ; PUTCHAR
   dc    "PUTCHAR"
   DW    color-8
putchar:
   DW    docol
   DW    dup
   DW    emit
   DW    rnum
   DW    at
   DW    first
   DW    plus
   DW    cstor
   DW    clit
   defb  4
   DW    pcomm
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  87h               ; COMMAND
   dc    "COMMAND"
   DW    putchar-10
command:
   DW    docol
   DW    clit
   defb  7Fh
   DW    andd
   DW    twosta
   DW    lit, 0C100h
   DW    plus
   DW    at
   DW    exec
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  85h               ; KEYIN
   dc    "KEYIN"
   DW    command-10
keyin:
   DW    docol
   DW    dup
   DW    bl
   DW    less
   DW    over
   DW    clit
   defb  7Fh
   DW    equal
   DW    orr
   DW    zbran, keyin1
   DW    command
   DW    semis
keyin1:
   DW    putchar
   DW    semis

;
;----------------------------------------------------------------------------
;
   defb  85h               ; SCRID
   dc    "SCRID"
   DW    keyin-8
scrid:
   DW    docol
   DW    lit, 82h
   DW    color
   DW    clit
   defb  42h
   DW    clit
   defb  16h
   DW    gotoxy
   DW    pdotq
   defb  5
   dc    "scr# "
   DW    scr
   DW    ques
   DW    pdotq
   defb  2
   dc    "  "
   DW    clit
   defb  55h
   DW    color
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  84h               ; BCUP
   dc    "BCUP"
   DW    scrid-8
bcup:
   DW    docol
   DW    clit
   defb  5
   DW    pcomm
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  84h               ; BCDN
   dc    "BCDN"
   DW    bcup-7
bcdn:
   DW    docol
   DW    clit
   defb  18h
   DW    pcomm
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  84h               ; BCFW
   dc    "BCFW"
   DW    bcdn-7
bcfw:
   DW    docol
   DW    clit
   defb  4
   DW    pcomm
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  84h               ; BCBK
   dc    "BCBK"
   DW    bcfw-7
bcbk:
   DW    docol
   DW    clit
   defb  13h
   DW    pcomm
   DW    semis

edotab:  ; The jump table for vectored execution
;        0     1     2     3     4     5     6     7
DW    noop, noop, noop, noop, bcfw, bcup, noop, noop
;        8     9     A     B     C     D     E     F
DW    noop, noop, noop, noop, noop, noop, noop, noop
;       10    11    12    13    14    15    16    17
DW    noop, noop, noop, bcbk, noop, noop, noop, noop
;       18    19    1A    1B    1C    1D    1E    1F
DW    bcdn, noop, noop, noop, noop, noop, noop, noop
;       20    21    22    23    24    25    26    27   
DW    noop, noop, noop, noop, noop, noop, noop, noop
;       28    29    2A    2B    2C    2D    2E    2F
DW    noop, noop, noop, noop, noop, noop, noop, noop
;       30    31    32    33    34    35    36    37
DW    noop, noop, noop, noop, noop, noop, noop, noop
;       38    39    3A    3B    3C    3D    3E    3F
DW    noop, noop, noop, noop, noop, noop, noop, noop

;       40    41    42    43    44    45    46    47
DW    noop, noop, noop, noop, noop, noop, noop, noop
;       48    49    4A    4B    4C    4D    4E    4F
DW    noop, noop, noop, noop, noop, noop, noop, noop
;       50    51    52    53    54    55    56    57
DW    noop, noop, noop, noop, noop, noop, noop, noop
;       58    59    5A    5B    5C    5D    5E    5F
DW    noop, noop, noop, noop, noop, noop, noop, noop
;       60    61    62    63    64    65    66    67
DW    noop, noop, noop, noop, noop, noop, noop, noop
;       68    69    6A    6B    6C    6D    6E    6F
DW    noop, noop, noop, noop, noop, noop, noop, noop
;       70    71    72    73    74    75    76    77    
DW    noop, noop, noop, noop, noop, noop, noop, noop
;       78    79    7A    7B    7C    7D    7E    7F
DW    noop, noop, noop, noop, noop, noop, noop, noop

;       80    81    82    83    84    85    86    87
DW    noop, noop, noop, noop, noop, noop, noop, noop
;       88    89    8A    8B    8C    8D    8E    8F
DW    noop, noop, noop, noop, noop, noop, noop, noop
;       90    91    92    93    94    95    96    97    
DW    noop, noop, noop, noop, noop, noop, noop, noop
;       98    99    9A    9B    9C    9D    9E    9F
DW    noop, noop, noop, noop, noop, noop, noop, noop
;       A0    A1    A2    A3    A4    A5    A6    A7
DW    noop, noop, noop, noop, noop, noop, noop, noop
;       A8    A9    AA    AB    AC    AD    AE    AF
DW    noop, noop, noop, noop, noop, noop, noop, noop
;       B0    B1    B2    B3    B4    B5    B6    B7
DW    noop, noop, noop, noop, noop, noop, noop, noop
;       B8    B9    BA    BB    BC    BD    BE    BF
DW    noop, noop, noop, noop, noop, noop, noop, noop


;       C0    C1    C2    C3    C4    C5    C6    C7
DW    noop, noop, noop, noop, noop, noop, noop, noop
;       C8    C9    CA    CB    CC    CD    CE    CF
DW    noop, noop, noop, noop, noop, noop, noop, noop
;       D0    D1    D2    D3    D4    D5    D6    D7
DW    noop, noop, noop, noop, noop, noop, noop, noop
;       D8    D9    DA    DB    DC    DD    DE    DF
DW    noop, noop, noop, noop, noop, noop, noop, noop
;       E0    E1    E2    E3    E4    E5    E6    E7
DW    noop, noop, noop, noop, noop, noop, noop, noop
;       E8    E9    EA    EB    EC    ED    EE    EF
DW    noop, noop, noop, noop, noop, noop, noop, noop
;       F0    F1    F2    F3    F4    F5    F6    F7
DW    noop, noop, noop, noop, noop, noop, noop, noop
;       F8    F9    FA    FB    FC    FD    FE    FF
DW    noop, noop, noop, noop, noop, noop, noop, noop

;
;----------------------------------------------------------------------------
;
   defb  84h               ; ESC>
   dc    "ESC>"
   DW    bcbk-7
escfrom:
   DW    docol
   DW    dup
   DW    clit
   defb  7Eh   ;( an ASCII ~ )
   DW    equal
   DW    swap
   DW    clit
   defb  40h   ;( ASCII A -1 )
   DW    clit
   defb  5Bh   ;( ASCII Z +1 )
   DW    betw
   DW    orr
   DW    semis
;
;----------------------------------------------------------------------------
;
   defb  84h               ; ESC#
   dc    "ESC#"
   DW    escfrom-7
escnum:
   DW    docol
   DW    pad
   DW    clit
   defb  5
   DW    erasee
   DW    pad
escnum1:
   DW    key
   DW    dup
   DW    tol
   DW    over
   DW    cstor
   DW    onep
   DW    lfrom
   DW    escfrom
   DW    zbran, escnum1
   DW    drop
   DW    pad
   DW    onep
   DW    cat
   DW    cswap
   DW    pad
   DW    twop
   DW    cat
   DW    orr
   DW    semis
;
;----------------------------------------------------------------------------
;
;   _____ _   _ ____
;  | ____| \ | |  _ \ 
;  |  _| |  \| | | | |
;  | |___| |\  | |_| |
;  |_____|_| \_|____/ 
;
;
;----------------------------------------------------------------------------
;
   defb  84h              ; TASK
   dc    "TASK"
   DW    escnum-7
task:
   DW    docol
   DW    semis
;
;----------------------------------------------------------------------------
;


;
;end of the source code

.ORG     $3C00
codetest:                     ; for checking the inner-interpreter on the Arduino

   DW    codetestb            ; for checking the inner-interpreter on the Arduino



.ORG    $3fff  ;fill up 16k
.BYTE   0
.END


; to get the missing END directive from showing up in the listing just put a 
; bunch of stuff after the listing such as what I am doing here.
;
; I finally wrote the EXPECT routine in C++. Debugging the Forth was too buggy.
; The only thing wrong with it so far is the mis-aligned backspace pointer and
; not wiping out characters that have been backspaced over.
; kjc 27aug2017
;
;
;




; 04sep2017 ~ wrote working (FIND) routine and repaired all of the open links in the list.
; 06sep2017 ~ am using system to execute a word at a time to do system building/testing.
; 20170909 ~  fixed problem with execute not properly processing docol
; 20170920 ~ everything is working with the exception of compilation. I think that the 
;   problem there is with the pointers. I moved the FORTH word into the beginning of the SRAM.
;   I think that it belongs there since the LFA, afaict, is modified to reflect the extension
;   of the library by each new word that is defined.


 
