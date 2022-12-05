; bdsm hash

.MODEL SMALL
.STACK 100H

.DATA
 a DW ?
 b DW ?                
 equal_str DB 'Equal Hash', '$'
 unequal_str DB 'Not Equal Hash', '$'                
 
.CODE
MAIN PROC  
    MOV AX, @DATA
    MOV DS, AX
        
    MOV a, 0
    MOV b, 0
    ; Store index in BL
    MOV BL, 1 
    MOV BH, 0  
    
  WHILE:          
    MOV AH, 1   ; read char
    INT 21H   
    CMP AL, 0DH ; AL == \r   
    JNE SKIP    ; el: skip
    INC BH      ; if: BH++         
    MOV BL, 1   ; reset BL
             
    MOV AH, 2
    MOV DL, 0AH
    INT 21H     ; new line
    
    CMP BH, 2   ;     if BH == 2   
    JE  BREAK   ;          break
    JMP WHILE   ;     else continue
  SKIP:  
    SUB AL, 60H  
    MUL BL            
    INC BL      ; BL++
    
    CMP BH, 1
    JE  BINC
  AINC:        
    ADD a, AX   ; update CX if BH==0
    JMP WHILE
  BINC:          ; update DX if BH==1
    ADD b, AX      
    JMP WHILE
  BREAK: 
  
    MOV BX, a
    MOV CX, b
    CMP BX, CX
    JE  EQUALS
    
      
  NOT_EQUALS:
    LEA DX, unequal_str
    JMP PRINT
    
  EQUALS:  
    LEA DX, equal_str 
  
  PRINT:
    MOV AH, 9H
    INT 21H
    
    MOV AH, 4CH
    INT 21H        
MAIN ENDP
END MAIN