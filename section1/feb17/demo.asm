INCLUDE cs240.inc

.8086
	
TERMINATE = 4C00h
DOS = 21h

.data

msg	BYTE	"Hello, world!", 0

.code

pow PROC
	; AX = base
	; DX = exponent
	; Return:
	; DX = AX ^ DX
	pushf
	push	ax
	push	bx
	push	cx

	mov	bx, ax	; Base
	mov	ax, 1	; Intermediate result
	mov	cx, dx	; Loop counter (exponent)

top:
	imul	bx	; dx:ax = ax * bx
	call	DumpRegs
	loop	top

	mov	dx, ax

	pop	cx
	pop	bx
	pop	ax
	popf
	ret
pow ENDP

main PROC
	mov	ax, @data		; Setup data segment
	mov	ds, ax

	mov	ax, 2
	mov	dx, 0
	call	DumpRegs
	call	pow
	call	DumpRegs

	mov	ax, TERMINATE		; Signal DOS we are done
	int	DOS
main ENDP

END main
