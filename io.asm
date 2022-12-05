.MODEL SMALL
.STACK 100H

.DATA

CRLF DB 0DH, 0AH, "$"

BASE DW 10
LC DB ?

a  DW ?
b  DW ?
t  DW ?
i  DW ?
j  DW ?
k  DW ?       
n  DW ? 

arr1 DW 100 DUP (?)   
arr2 DW 100 DUP (?)

.CODE 

ENDL PROC  
    PUSH AX
    PUSH DX
    LEA DX, CRLF
    MOV AH, 9H
    INT 21H    
    POP DX 
    POP AX
    RET
ENDL ENDP       

; scan number into DX
; store last char scanned into AL
SCAN_NUM PROC  
    PUSH AX
    PUSH BX       
    PUSH CX

    XOR DX, DX 
    XOR CX, CX
REPEAT_SCAN:       
    MOV AH, 1
    INT 21H     
    
    MOV LC, AL
    
    CMP CL, 0 
    JNE CONTINUE_SCAN
    
    CMP AL, '-'
    JNE CONTINUE_SCAN
    
    MOV CH, 1
    JMP REPEAT_SCAN
    
CONTINUE_SCAN:              
    CMP AL, '0'
    JL EXIT_SCAN
    CMP AL, '9'
    JG EXIT_SCAN
    
    SUB AL, '0'
    XOR AH, AH
    
    MOV BX, AX
    MOV AX, DX
    
    MUL BASE
    ADD AX, BX
    MOV DX, AX
    
    INC CL                    
    JMP REPEAT_SCAN       
EXIT_SCAN:  

    TEST CH, 1
    JZ RETURN_SCAN
    ; invert sign
    NEG DX

RETURN_SCAN:

    POP CX            
    POP BX
    POP AX 
    MOV AL, LC     
    RET                 
SCAN_NUM ENDP           
                  
; Print number in AX in decimal                  
PRINT_NUM PROC  
    PUSH AX
    PUSH BX
    PUSH CX            
    PUSH DX     
    ; stack digits
    XOR DX, DX
    XOR CX, CX      
    ; check sign
    TEST AX, 8000H
    JZ REPEAT_PRINT_STACK    
    MOV BX, 1
    NEG AX
    
REPEAT_PRINT_STACK:
    DIV BASE
    PUSH DX
    XOR DX, DX
    INC CX
    CMP AX, 0
    JE  EXIT_PRINT_STACK
    JMP REPEAT_PRINT_STACK   
      
EXIT_PRINT_STACK:         

    MOV AH, 2 
    
    TEST BX, 1
    JZ LOOP_PRINT
    
    MOV DL, '-'
    INT 21H
    
LOOP_PRINT:        
    POP DX
    ADD DL, '0'
    INT 21H  
    LOOP LOOP_PRINT  
    
    POP DX                             
    POP CX
    POP BX
    POP AX  
    RET
PRINT_NUM ENDP     

; scan array into memory pointed by SI
; assume array size is never exceeded
; return size of array in DX
SCAN_ARR PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
                  
    XOR CX, CX
REPEAT_SCAN_ARR:
    CALL SCAN_NUM    
    MOV WORD PTR [SI], DX
    ADD SI, 2
    INC CX
    CMP AL, 0DH     
    JE EXIT_SCAN_ARR
    JMP REPEAT_SCAN_ARR
    
EXIT_SCAN_ARR:  
    
    MOV DX, CX
    
    POP SI
    POP CX
    POP BX
    POP AX   
    
    CALL ENDL    
    RET
SCAN_ARR ENDP

; print array pointed to my SI with size AX
PRINT_ARR PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    MOV CX, AX
LOOP_PRINT_ARR:
    MOV AX, [SI]
    CALL PRINT_NUM
    ADD SI, 2
    MOV DL, ' '
    MOV AH, 2
    INT 21H
    LOOP LOOP_PRINT_ARR
    
    CALL ENDL        
    
    POP SI
    POP DX    
    POP CX
    POP BX
    POP AX  
    RET 
PRINT_ARR ENDP

; pass array in SI, size in AX 
; output array in DI, sufficient size assumed
PARTIAL_MERGE PROC           
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX                    
    PUSH DI 
    PUSH SI  
    MOV a, SI
    MOV b, DI
    MOV n, AX
    ; loop counter
    MOV CX, 1     
LOOP_MERGE:  
    MOV BX, [SI]
    CMP BX, [SI + 2]       
    JG EXIT_LOOP_MERGE
    
    ADD SI, 2
    INC CX
    CMP CX, n
    JE EXIT_LOOP_MERGE
    JMP LOOP_MERGE      
    
EXIT_LOOP_MERGE:
    ; inv in CX
    ; i = 0, j = t
    ; k = 0
    ; while(i < t and j < n)
    ;   if A[i] < A[j]
    ;      B[k] = A[i]
    ;      i++
    ;   else
    ;      B[k] = A[j]
    ;      j++
    ;   k++
    ; while(i < CX)
    ;   B[k] = A[i]
    ;   i++
    ;   k++
    ; while(j < n)
    ;   B[k] = A[j]
    ;   j++     
    ;   k++               
    MOV t, CX 
    SHL CX, 1 ; offset
    MOV SI, a ; SI -> A[i]    
    ADD CX, SI; CX -> A[t]
    MOV BX, CX; BX -> A[j] = A[t]
    MOV DX, n
    SHL DX, 1
    ADD DX, SI; DX -> A[n]       
    MOV DI, b ; DI -> B[k]
WHILE_1_MERGE:
    CMP SI, CX
    JNL WHILE_2_MERGE
    CMP BX, DX
    JNL WHILE_2_MERGE
    MOV AX, [SI]
    CMP AX, [BX]
    JNL ELSE_MERGE
    MOV WORD PTR [DI], AX
    ADD SI, 2        
    ADD DI, 2
    JMP WHILE_1_MERGE
ELSE_MERGE:              
    MOV AX, [BX]
    MOV WORD PTR [DI], AX
    ADD BX, 2        
    ADD DI, 2
    JMP WHILE_1_MERGE
WHILE_2_MERGE:   
    CMP SI, CX
    JNL WHILE_3_MERGE
    MOV AX, [SI]
    MOV WORD PTR [DI], AX
    ADD SI, 2
    ADD DI, 2
    JMP WHILE_2_MERGE
WHILE_3_MERGE:       
    CMP BX, DX
    JNL RETURN_PARTIAL_MERGE
    MOV AX, [BX]
    MOV WORD PTR [DI], AX
    ADD BX, 2
    ADD DI, 2
    JMP WHILE_3_MERGE
RETURN_PARTIAL_MERGE:    
    POP SI      
    POP DI    
    POP DX
    POP CX
    POP BX        
    POP AX
    RET        
PARTIAL_MERGE ENDP

MAIN PROC      
    MOV AX, @DATA
    MOV DS, AX
    
    LEA SI, arr1
    CALL SCAN_ARR    
    MOV AX, DX      
    LEA SI, arr1
    LEA DI, arr2              
    CALL PARTIAL_MERGE
    LEA SI, arr2
    CALL PRINT_ARR
              
    MOV AH, 4CH
    INT 21H  
    
MAIN ENDP  

END MAIN