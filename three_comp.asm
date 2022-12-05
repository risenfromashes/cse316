; find largest, 2nd largest, 3rd largest
.MODEL SMALL
.STACK 100H                             

.DATA           
equal_str db 'All equal', '$'
a db ?
b db ?
c db ?

.CODE
MAIN PROC
     MOV AX, @DATA
     MOV DS, AX    
     
     MOV DL, ','         
     ; input a
     MOV AH, 01H
     INT 21H
     MOV a, AL
     
     ; ,
     MOV AH, 02H
     INT 21H
     
     ; input b 
     MOV AH, 01H
     INT 21H   
     MOV b, AL
                
     ; ,
     MOV AH, 02H
     INT 21H      
          
     ; input c
     MOV AH, 01H
     INT 21H
     MOV c, AL   
     
     ; new line
     MOV AH, 02H
     MOV DL, 0DH
     INT 21H
     MOV DL, 0AH
     INT 21H
              
              
     MOV AL, a
     MOV BL, b
     MOV CL, c
                      
     CMP AL, BL
     JNE ABcomp
     CMP BL, CL
     JE  EQUAL               
         
     ; a > b?
ABcomp:
     CMP AL, BL
     JGE ACcomp
     ; swap a, b
     MOV DL, AL
     MOV AL, BL
     MOV BL, DL
     ; a > c?   
ACcomp:
     CMP AL, CL
     JGE BCcomp
     ; swap a, c
     MOV DL, AL
     MOV AL, CL
     MOV CL, DL
     ; now a is largest
     ; b > c
BCcomp:     
     CMP BL, CL
     JGE MID
     ; swap b, c
     MOV DL, BL
     MOV BL, CL
     MOV CL, DL 

MID:           
     MOV DL, BL
     MOV AH, 02H
     JMP PRINT     
EQUAL:  
     MOV AL, 09H
     LEA DX, equal_str    
PRINT:
     INT 21H           
            
     MOV AH, 4CH
     INT 21H
MAIN ENDP 
END MAIN