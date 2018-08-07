TITLE Matrix Multiplication                (MatMult.asm)
;Austin Draper
;5/12/16
;VISUAL STUDIO 2015	
;This program will use assembly to perform
;a static matrix multiplication
INCLUDE Irvine32.inc

.data		
	Mat_dataA       dword 1, 3, 5, 1, 1, -2, 4, -3, 2
	Mat_dataB		dword 3, 5, 7, 4, -3, 9, -1, 2, -6	
	Mat_A			dword 9 dup(0)	    ;matrix A
	Mat_B			dword 9 dup(0)	    ;matrix B	
	num_rows		dword 0
	num_cols		dword 0
	row_counter		dword 0             ;outer loop	
	col_counter		dword 0             ;inner loop
	counter			byte 0 
	sum				dword 0
	newmatrix		dword 1

	;code below for generating product
	working_row		dword 0             ;(0=1st row, 12=2nd row, 24=3rd row)
	working_col		dword 0             ;(0=1st col, 4=2nd col, 8=3rd col)
	matrix_size		= 2			        ;2= 3x3 matrix
	num_matrices	= 1			        ;generate matrices
	nextrow			= (matrix_size + 1) * 4        ;*dword
	
.code			

main PROC
	mov	ebx, num_matrices	            ;how many matrices to generate
	
;loops to create the next matrix
NextMatrix:
	call createA				        ;generate Mat_A
	call createB				        ;generate Mat_B
	call determinesize		            ;how many rows/col in matrix
	call multiplymatrix		            ;IMUL matricies
	
	inc	newmatrix
	mov	eax, newmatrix
	cmp	eax, num_matrices
	jle	NextMatrix
	
	call waitmsg
	exit
	
main ENDP


determinesize PROC
	mov	eax, matrix_size
	mov	ebx, nextrow
	IMUL ebx
	mov	num_rows, eax
	
	mov	eax, matrix_size
	mov	ebx, 4
	IMUL ebx
	mov	num_cols, eax
	ret
determinesize ENDP


createA PROC
	mov	esi, OFFSET Mat_A		        ;finds the start of the matrix
	mov ecx, 0
	call traversematrixA		        ;fills in the matrix
	ret
createA ENDP


createB PROC
	mov	esi, OFFSET Mat_B		
	mov ecx, 0
	call traversematrixB		
	ret
createB ENDP


;Set a value in the matrix to number from array
setvalueA PROC
	mov edi, OFFSET Mat_dataA
	mov eax, [edi + 4 * ecx]
	inc ecx
	
	mov	[esi], eax		                ;put value into array
	ret
setvalueA ENDP


setvalueB PROC
	mov edi, OFFSET Mat_dataB
	mov eax, [edi + 4 * ecx]
	inc ecx
	
	mov	[esi], eax		
	ret
setvalueB ENDP


;Print one value at a time to screen
printvalue PROC
	push eax
	call WriteInt		                ;print the value
	mov	al, ' '                         ;space for future value room
	call WriteChar		                
	pop	eax
	ret
printvalue ENDP


;Traverse each row
traversematrixA PROC
	call Crlf					
	mov	row_counter, 0			        ;set to first row
NewRow:
	mov	col_counter, 0			        ;set to first column

	;begin the loop
NewCol:
	call setvalueA				        ;put value in array
	call printvalue				        
	add	esi, 4					        
	
	inc	col_counter				        
	cmp	col_counter, matrix_size	
	jle	NewCol				  	        ;done after last col is set
	call Crlf
	inc	row_counter				        ;new row
	
	cmp	row_counter, matrix_size	    ;stop at 3rd row every time
	jle	NewRow
	ret
traversematrixA ENDP


traversematrixB PROC
	call Crlf					
	mov	row_counter, 0			
NewRow:
	mov	col_counter, 0			
NewCol:
	call setvalueB				
	call printvalue				
	add	esi, 4					
	
	inc	col_counter				
	cmp	col_counter, matrix_size		
	jle	NewCol					

	call Crlf
	inc	row_counter				
	
	cmp	row_counter, matrix_size			
	jle	NewRow
	ret
traversematrixB ENDP


;performing the matrix multiplication
addelements PROC
	mov	eax, working_row	
	mov	ebx, working_col	
	mov	row_counter, eax
	mov	col_counter, ebx
	
	mov	counter, 0
	mov	sum, 0
Next:
	call multiplyelements	
	add	sum, eax			            ;get the sum
	add	row_counter, 4		
	add	col_counter, nextrow
	
	inc	counter				
	
	cmp	counter, matrix_size			;stop at 3rd row every time
	jle	Next
	mov	eax, sum
	
	ret
addelements ENDP


;multiply the two matricies
multiplyelements PROC
	mov	esi, OFFSET Mat_A		        
	add	esi, row_counter	
	mov	eax, [esi]			            ;put Mat_A value into eax
	
	mov	esi, OFFSET Mat_B		
	add	esi, col_counter	
	mov	ebx, [esi]			            ;put Mat_B value into ebx
	
	IMUL ebx					
	
	ret
multiplyelements ENDP


multiplymatrix PROC
	call Crlf
	mov	working_row, 0		
	
NewRow:
	mov	working_col, 0		
NewCol:
	call addelements			
	call printvalue			
	
	add	working_col, 4		
	mov	eax, working_col	
	cmp	eax, num_cols                   ;check if end of row
	jle	NewCol
	call Crlf			
	add	working_row, nextrow
	mov	eax, working_row	
	cmp	eax, num_rows                   ;check if last row
	jle	NewRow
	
	call Crlf
	ret
multiplymatrix ENDP


END main