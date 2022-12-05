.MODEL SMALL
.STACK 100H

.DATA

x DB ?
y DB ?


.CODE
MAIN PROC     
    
    MOV AX, @DATA
    MOV DS, AX    
    
    ; input x
    MOV AH, 1
    INT 21H    
    SUB AL, '0'
    MOV x, AL
    ; new line
    MOV AH, 2
    MOV DL, 0AH
    INT 21H
    MOV DL, 0DH
    INT 21H    
    ; input y
    MOV AH, 1
    INT 21H    
    SUB AL, '0'
    MOV y, AL
    ; new line
    MOV AH, 2
    MOV DL, 0AH
    INT 21H
    MOV DL, 0DH
    INT 21H
    
    ; sum in CX
    XOR CX, CX
    ; 2*x
    MOV AL, 2
    MUL x
    ADD CX, AX
    ; 3*y
    MOV AL, 3
    MUL y
    SUB CX, AX
    ; to char
    ADD CX, '0'
    MOV DL, CL
    MOV AH, 2
    INT 21H
     
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END  MAIN