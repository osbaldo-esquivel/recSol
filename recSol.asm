TITLE A Recursive Solution(recSol.asm)

;// Author: Osbaldo Esquivel
;// Date: 27MAY2015
;// Description: The user will be shown a number of elements out of a set. They will then
;// provide an answer to how many combinations there can be for those elements.
;// The program will then calculate the number of combinations recursively and display
;// the answer to the user and confirm their answer.

Include Irvine32.inc

toDisplayString	MACRO	aString
push	edx
mov	edx, OFFSET aString
call WriteString
pop	edx
ENDM

LO = 1
MIN = 3
MAX = 12
STRINGMAX = 21

.data
intro	BYTE		"                              A Recursive Solution", 0ah, 0dh, 0
intro1	BYTE		"                                       by", 0ah, 0dh, 0
intro2	BYTE		"                                 Osbaldo Esquivel", 0ah, 0dh, 0
intro3	BYTE		"================================================================================", 0
instr1	BYTE		"This program will show you the number of elements out of a set.",0
instr2	BYTE		"You will then provide what you think is the correct number of combinations.", 0
instr3	BYTE		"It will then display if you are correct and what the correct answer is.",0
inName	BYTE		"Enter your name: ", 0
userEl	BYTE		"The size of the set: ", 0
userSet	BYTE		"The number of elements to choose from the set: ", 0
userAns	BYTE		"Using nCr, enter the possible combinations: ", 0
invalid	BYTE		"That is not a valid number, ", 0
useAns	BYTE		"Your answer for possible combinations: ", 0
theResult BYTE		"The result is: ", 0
period	BYTE		".", 0
correct	BYTE		"Nice job!", 0
wrong	BYTE		"That was not correct.", 0
again	BYTE		"Would you like another problem? Enter Y/N: ", 0
userVal	BYTE		STRINGMAX DUP (?)
check	BYTE		?
answer	DWORD	?
theNval	DWORD	?
theRval	DWORD	?
xVal		DWORD	0
result	DWORD	0
divide	DWORD	?

.code
main PROC
	call Randomize

	call SetColor

	call Introduction

	push theNval
	push theRval
	call ShowProblem

	push OFFSET userVal
	push OFFSET answer
	call GetData

	push OFFSET divide
	push theNval
	push theRval
	push OFFSET result
	call Combinations

	push theNval
	push theRval
	push answer
	push result
	call ShowResults

	exit
main ENDP

; --------------------------------------------------------------------
SetColor PROC
;// Set color of text and background
;// Receives: nothing
;// Returns: nothing
; --------------------------------------------------------------------
	mov	eax, white + (lightMagenta * 16)
	call SetTextColor
	call	Clrscr

	ret
SetColor ENDP

; --------------------------------------------------------------------
Introduction PROC
;// Displays introduction to user and instructions
;// Receives: nothing
;// Returns: nothing
; --------------------------------------------------------------------
	;// introduce program
	toDisplayString intro
	toDisplayString intro1
	toDisplayString intro2
	toDisplayString intro3

	;// give instructions
	toDisplayString instr1
	call Crlf
	toDisplayString instr2
	call Crlf
	toDisplayString instr3
	call Crlf
	call WaitMsg

	call Crlf
	call Crlf

	ret
Introduction ENDP

ShowProblem PROC
;// Generates random numbers in range and displays to the user to find the
;// number of combinations
;// Receives: r and n values
;// Returns: nothing
; --------------------------------------------------------------------
	push ebp
	mov	ebp, esp

;// generate random n value in range [3..12]
nVal :
	mov	eax, MAX
	sub	eax, MIN
	inc	eax
	call	RandomRange
	add	eax, MIN
	mov[ebp + 12], eax

;// generate randome r value in range [1..n]
rVal :
	mov	eax, [ebp + 12]
	sub	eax, LO
	inc	eax
	call RandomRange
	add	eax, LO
	mov[ebp + 8], eax

;// display n and r values to user
show :
	toDisplayString userEl
	mov	eax, [ebp + 12]
	call WriteDec

	call Crlf

	toDisplayString userSet
	mov	eax, [ebp + 8]
	call WriteDec

	call Crlf

	pop	ebp
	ret	8
ShowProblem ENDP

GetData PROC
;// Reads the user input as a string and loops to check if valid number. If not
;// an error message is shown and the user must enter another value.
;// Receives: Offset to userVal and answer
;// Returns: the users answer
; --------------------------------------------------------------------
	push	ebp
	mov	ebp, esp

	mov	eax, [ebp + 8]
	mov	DWORD PTR [eax], 0
userAnswer :
	call Crlf

	;// ask user for answer and store
	toDisplayString userAns
	mov	edx, [ebp + 12]
	mov	ecx, STRINGMAX
	call ReadString
	cmp	eax, 10
	jg	valid

	;// convert string to ascii values and validate input
	mov	ecx, eax
	mov	esi, [ebp + 12]
L1:
	mov	ebx, [ebp + 8]
	mov  eax, [ebx]
	mov	ebx, 10
	mul	ebx
	mov	ebx, [ebp + 8]
	mov[ebx], eax
	mov	al, [esi]
	mov	eax, [esi]
	inc	esi
	sub	al, 48
	cmp	al, 0
	jl	valid
	cmp	al, 9
	jg	valid

	mov	ebx, [ebp + 8]
	add[ebx], al
	loop	L1

	pop	ebp
	ret	8

;// if not valid number display error message
valid:
	call	Crlf

	mov	al, 0
	mov	eax, 0
	mov	ebx, [ebp + 8]
	mov	[ebx], eax

	toDisplayString invalid

	call Crlf
	call Crlf

	jmp	userAnswer
GetData ENDP

Combinations PROC
;// Calculates number of combinations in conjunction with factorial procedure.
;// Receives: Offsets of divide and result and values of n and r
;// Returns: result
; --------------------------------------------------------------------
	push	ebp
	mov	ebp, esp

	;// push (n - r) onto stack and send to factorial procedure
	mov	eax, DWORD PTR [ebp + 16]
	sub	eax, DWORD PTR [ebp + 12]
	mov	ebx, eax
	push	ebx
	call Factorial

	mov	edx, DWORD PTR [ebp + 20]
	mov	[edx], eax

	;// push r on stack and send to factorial procedure
	mov	ebx, [ebp + 12]
	push ebx
	call Factorial

	;// multiply r! and (n - r)!
	mov	edx, DWORD PTR[ebp + 20]
	mov	ebx, [edx]
	mul	ebx
	mov	ebx, [ebp + 20]
	mov	[ebx], eax

	;// push n on stack and send to factorial procedure
	mov	ebx, [ebp + 16]
	push ebx
	call Factorial

	mov	edx, DWORD PTR[ebp + 20]
	mov	ebx, [edx]

	;// calculate n! / r!(n - r)! and store in result
	mov	edx, 0
	div	ebx
	mov	ebx, DWORD PTR [ebp + 8]
	mov	[ebx], eax

	call Crlf

	pop	ebp
	ret	16
Combinations ENDP

Factorial PROC
;// Takes in a value and returns the factorial using recursion
;// Receives: n and r and n - r
;// Returns: n!, r!, and (n-r)!
; --------------------------------------------------------------------
	push ebp
	mov	ebp, esp

	mov	eax, DWORD PTR [ebp + 8]
	cmp	eax, 0
	ja	L1
	mov	eax, 1
	jmp	L2
L1:
	dec	eax
	push	eax
	call Factorial
facRet:
	mov	ebx, DWORD PTR [ebp + 8]
	mul	ebx
L2:
	pop	ebp
	ret	4
Factorial ENDP

ShowResults PROC
;// Shows user if they were right or wrong and asks if they want to play again
;// Receives: Offsets to result and answer
;// Returns: nothing
; --------------------------------------------------------------------
	push	ebp
	mov	ebp, esp

	;// show user their answer
	toDisplayString useAns
	mov	eax, [ebp + 12]
	call WriteDec
	call Crlf

	;// show the result
	toDisplayString theResult
	mov	eax, DWORD PTR[ebp + 8]
	call WriteDec

	;// check if answer correct
	mov	eax, [ebp + 12]
	mov	ebx, [ebp + 8]
	cmp	eax, ebx
	jnz	wrongAns

	toDisplayString correct
	call Crlf
getOut:
	toDisplayString again
	call ReadChar

	;// check if user enters 'y' or 'y' to continue
	cmp	al, 121
	je	tryAgain
	cmp	al, 89
	je	tryAgain
	jne	theExit
theExit:
	call Crlf
	exit
;// loop to play again
tryAgain:
	call Crlf
	call Crlf

	push theNval
	push theRval
	call ShowProblem

	push OFFSET userVal
	push OFFSET answer
	call GetData

	push OFFSET divide
	push theNval
	push theRval
	push OFFSET result
	call Combinations

	push theNval
	push theRval
	push answer
	push result
	call ShowResults
wrongAns:
	call Crlf
	toDisplayString wrong
	call Crlf
	jmp getOut
ShowResults ENDP

END main
