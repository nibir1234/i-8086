
.MODEL SMALL
.STACK 100H

.DATA
MSG1 DB 'Enter the time in seconds up to 65535 = $\'
MSG2 DB 0DH,0AH,'Time in hh:mm:ss format = $\'
SPACE DB ' : $\'
.CODE
MAIN PROC
MOV AX,@DATA 
MOV DS,AX
LEA DX,MSG1 
MOV AH,9
INT 21H

CALL INPUT_PROC 
PUSH AX 
LEA DX,MSG2 
MOV AH,9
INT 21H

POP AX 
XOR DX,DX 
MOV CX,3600 
DIV CX ;set AX=DX:AX\\CX , DX=DX:AX%CX

CMP AX,10 
JGE HOURS 
PUSH AX 
MOV AX,0 
CALL OUTPUT_PROC 
POP AX 


HOURS: 

CALL OUTPUT_PROC 
MOV AX,DX 
PUSH AX 
LEA DX,SPACE 
MOV AH,9
INT 21H

POP AX 
XOR DX,DX 
MOV CX,60 
DIV CX ;set AX=DX:AX\\CX , DX=DX:AX%CX
CMP AX,10 
JGE MINUTES 
PUSH AX 
MOV AX,0 
CALL OUTPUT_PROC 

POP AX 


MINUTES:    

CALL OUTPUT_PROC 
MOV BX,DX 
LEA DX,SPACE 
MOV AH,9
INT 21H

MOV AX,BX 
CMP AX,10 
JGE SECONDS 
PUSH AX 
MOV AX,0 
CALL OUTPUT_PROC 
POP AX


SECONDS:    

CALL OUTPUT_PROC 
MOV AH,4CH 
INT 21H
MAIN ENDP




INPUT_PROC PROC
    
PUSH BX 
PUSH CX 
PUSH DX 
JMP READ 


SKIP_BACKSPACE:    

MOV AH,2 
MOV DL,20H ;set DL=' \'
INT 21H 


READ:  

XOR BX,BX 
XOR CX,CX 
XOR DX,DX 
MOV AH,1 
INT 21H 
CMP AL,"-" 
JE MINUS 
CMP AL,"+" 
JE PLUS 
JMP SKIP_INPUT 


MINUS:              

MOV CH,1 
INC CL 
JMP INPUT 


PLUS:             

MOV CH,2 

INC CL 


INPUT:     

MOV AH,1 
INT 21H  


SKIP_INPUT:    

CMP AL,0DH 
JE JUMP_TO_END_INPUT                            

CMP AL,8H 
JNE BACKSPACE_NOT 

CMP CH,0 
JNE CHECK_REMOVE_MINUS 

CMP CL,0 
JE SKIP_BACKSPACE 

JMP MOVE_BACK 

JUMP_TO_END_INPUT:
JMP END_INPUT 


CHECK_REMOVE_MINUS:  

CMP CH,1
JNE CHECK_REMOVE_PLUS 
CH!=1

CMP CL,1 
JE REMOVE_PLUS_MINUS 
                
                
CHECK_REMOVE_PLUS: 

CMP CL,1 
JE REMOVE_PLUS_MINUS 
JMP MOVE_BACK 


REMOVE_PLUS_MINUS:            

MOV AH,2  
MOV DL,20H  
INT 21H  
MOV DL,8H  
INT 21H  
JMP READ    


MOVE_BACK:            

MOV AX,BX  
MOV BX,10  
DIV BX 
MOV BX,AX
MOV AH,2  
MOV DL,20H ;set DL=\' \'
INT 21H  
MOV DL,8H  
INT 21H  
XOR DX,DX  
DEC CL  
JMP INPUT  
                 
                 
BACKSPACE_NOT: 

INC CL  
CMP AL,30H ;compare AL with 0
JL ERROR 
CMP AL,39H 
JG ERROR
AND AX,000FH ;convert ascii to decimal code
PUSH AX 
MOV AX,10 
MUL BX 
MOV BX,AX
POP AX 
ADD BX,AX 
JC ERROR
CMP CL,5
JG ERROR
JMP INPUT 
ERROR:
MOV AH,2 
MOV DL,7H 
INT 21H 
XOR CH,CH 
      
      
CLEAR:

MOV DL,8H 
INT 21H 
MOV DL,20H 
INT 21H 
MOV DL,8H 
INT 21H 
LOOP CLEAR 
JMP READ     


END_INPUT:         

CMP CH,1 
JNE EXIT 
NEG BX 


EXIT:

MOV AX,BX 
POP DX 
POP CX 
POP BX 
RET 
INPUT_PROC ENDP




OUTPUT_PROC PROC 
    
PUSH BX 
PUSH CX 
PUSH DX 
CMP AX,0 
JGE START 
PUSH AX 
MOV AH,2 
MOV DL,"-" 
INT 21H 
POP AX 
NEG AX 


START:       

XOR CX,CX
MOV BX,10 


OUTPUT:
XOR DX,DX 
DIV BX
PUSH DX 
INC CX 
OR AX, AX
JNE OUTPUT 
MOV AH,2 


DISPLAY:      

POP DX 
OR DL, 30H 
INT 21H 

LOOP DISPLAY 
POP DX 
POP CX 
POP BX 
RET
OUTPUT_PROC ENDP

END MAIN