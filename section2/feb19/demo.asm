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

	mov	bx, ax	; base
	mov	ax, 1	; intermediate product
	mov	cx, dx	; exponent (loop count)

	cmp	cx, 0
	je	done
	
top:

	imul	bx	; dx:ax = ax * bx
	call	DumpRegs
	loop	top

done:	
	mov	dx, ax
		
	pop	cx
	pop	bx
	pop	ax
	popf
	ret
pow ENDP

END
