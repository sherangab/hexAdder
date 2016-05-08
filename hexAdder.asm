;***********************************************
;*    Program Name: hexAdder.asm
;*    Name: <Sheranga B>
;*    Date: <November 4, 2014>
;*
;*    Prompts for 2 two digit numbers
;*    Checks whether input is legal hex digits (0-9,a-f,A-F)
;*    otherwise waits for another character
;*    Adds the two numbers together and displays the result
;*
;************************************************

;*Initialization of values
NULL:     EQU   $00         ;End of text
printf:   EQU   $EE88       ;Output message
getchar:  EQU   $EE84       ;Read ASCII character
putchar:  EQU   $EE86       ;Put ASCII character to screen
out2hex:  EQU   $EE9C       ;Put HEX character to screen
CR:       EQU   $0D         ;Carriage Return
LF:       EQU   $0A         ;Line Feed
ShiftHex: EQU   $10         ;Shift hex factor

;* Define the data
          ORG   $1000
MSGName:  DB    CR, LF
          FCC   "Author: Sheranga Balasuriya"
          DB    CR, LF
          FCC   "Description: Adds two 2 digit hex numbers"
          DB    NULL
MSG1:     DB    CR, LF
          FCC   "Enter Hex Digit, (0-1,a-f,A-F), Silent on Error"
          DB    NULL
MSGNum1:  DB    CR, LF
          FCC   "Enter 1st hex number: "
          DB    NULL
MSGNum2:  DB    CR, LF
          FCC   "Enter 2nd hex number: "
          DB    NULL

MSGSum1:  DB    CR, LF
          FCC   "%x + %x = "
          DB    NULL
          
MSGSum2:  DB    CR, LF
          FCC   "%x + %x = 1"
          DB    NULL

MSG2:     DB    CR, LF, CR, LF, NULL

Digit1:   DB    $0
Digit2:   DB    $0
Num1:     DB    $0
Num2:     DB    $0

;* Start of the program

          ORG   $2000
          LDS   #$3C00             ;Initialize SP to end of RAM

          LDD   #MSGName
          JSR   [printf-*-4,PC]

          LDD   #MSG2
          JSR   [printf-*-4,PC]
          
          LDD   #MSG1
          JSR   [printf-*-4,PC]

          ;Display prompt message and get first number
          LDD   #MSGNum1
          JSR   [printf-*-4,PC]
          JSR   getHexNumber
          STAB  Num1
          
          ;Display prompt message and get second number
          LDD   #MSGNum2
          JSR   [printf-*-4,PC]
          JSR   getHexNumber
          STAB  Num2

          LDAA  Num1

          ABA                      ;Add accumulators

          ;Check for carry
          BCS   SumWithCarry

          ;Display message and sum with no carry
          PSHA
          
          ;Push on to stack both numbers
          CLRA
          LDAB   Num2
          PSHD
          CLRA
          LDAB   Num1
          PSHD
          
          LDD   #MSGSum1
          JSR   [printf-*-4,PC]
          
          ;Clean up stack
          PULD
          PULD
          
          PULB
          BRA   Finish

SumWithCarry:
          ;Display message and sum with carry
          PSHA
          
          ;Push on to stack both numbers
          CLRA
          LDAB   Num2
          PSHD
          CLRA
          LDAB   Num1
          PSHD
          
          LDD   #MSGSum2
          JSR   [printf-*-4,PC]

          ;Clean up stack
          PULD
          PULD
          
          PULB

Finish:
          ;Display sum
          call  [out2hex-*-4,PC]

          LDD   #MSG2
          JSR   [printf-*-4,PC]

          SWI

;***************************************************************************
;
;     Subroutine Name: getHexNumber
;     This subroutine takes 2 legal hex digit inputs from user and combines
;     to make a 2 digit hex number which it returns
;
;     Inputs:     None
;
;     Outputs:    Accumulator B contains 2 digit hex number
;
;****************************************************************************
getHexNumber:
          ;Display prompt message and get character
GetDigit1:
          JSR   [getchar-*-4,PC]
          JSR   isxdigit             ;Check whether valid digit
          CMPB  #0
          BLE   GetDigit1            ;If not valid digit repeat
          STAB  Digit1               ;If valid store in Digit1


          ;Display prompt message and get character
GetDigit2:
          JSR   [getchar-*-4,PC]
          JSR   isxdigit             ;Check whether valid digit
          CMPB  #0
          BLE   GetDigit2            ;If not valid digit repeat
          STAB  Digit2               ;If valid store in Digit2
          
          ;Shift first digit and combine with second digit
          LDAA  Digit1
          LDAB  #ShiftHex
          MUL
          ADDB  Digit2
          
          RTS

;***************************************************************************
;
;     Subroutine Name: isxdigit
;     This subroutine checks whether a given character is a valid hex digit
;     and returns the hex value
;
;     Inputs:     Accumulator B contains the character
;
;     Outputs:    Accumulator B contains 0 if invalid digit
;                 Otherwise Accumulator B contains given hex digit
;
;****************************************************************************
isxdigit:                   ; int isxdigit(int c);
          ;Check whether valid hex digit
          CLRA
          CMPB  #$30           ;'0'
          BLO   isx_false
          CMPB  #$3A           ;'9'+1
          BLO   exit_isxdigit
          CMPB  #$41           ;'A'
          BLO   isx_false
          CMPB  #$47           ;'G'
          BLO   exit_isxdigit
          CMPB  #$61           ;'a'
          BLO   isx_false
          CMPB  #$67           ;'g'
          BLO   exit_isxdigit
Isx_false:
          CLRB
          BRA   Done
          
          ;Convert ASCII to hex
exit_isxdigit:
          JSR   [putchar-*-4,PC]
          CMPB  #$3A           ;'9'+1
          BLO   Conv1
          CMPB  #$47           ;'G'
          BLO   Conv2
          CMPB  #$67           ;'g'
          BLO   Conv3
Conv1:
          SUBB  #$30           ;'1'-$1
          BRA   Done
Conv2:
          SUBB  #$37           ;'A'-$A
          BRA   Done
Conv3:
          SUBB  #$20           ;'a'-'A'
          SUBB  #$37           ;'A'-$A
          BRA   Done

Done:
          RTS

          END