.MODEL SMALL
.STACK 100H

.DATA

.CODE

MAIN PROC    
    
    MOV AX, @DATA
    MOV DS, AX
          
    ; set input mode
    MOV AH, 1 
    ; USE CL to store min char
    MOV CL, 0FFH
  WHILE:
    INT 21H
    ; if AL < 'a', break
    CMP AL, 'a'
    JB  BREAK
    ; if AL > 'z', break
    CMP AL, 'z'
    JA BREAK
    ; if AL < CL (unsigned)
    CMP  AL, CL
    JNB  NEXT
    ; store min
    MOV CL, AL   
    
  NEXT:  
    JMP WHILE
    
  BREAK:      
    ; upper case
    SUB CL, 0020H
    ; print
    MOV AH, 2
    MOV DL, CL
    INT 21H
    
    MOV AH, 4CH
    INT 21H
        
MAIN ENDP
END  MAIN