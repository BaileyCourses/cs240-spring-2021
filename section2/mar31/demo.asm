INCLUDE cs240.inc

.8086
	
TERMINATE = 4C00h
DOS = 21h

.code
	
comment !

SetInterruptVector PROC
	;; AL - interrupt number
	;; DS:DX - new handler
	
InstallHandler PROC
	;; AL - interrupt number
	;; CS:DX - new handler

GetInterruptVector PROC
	;; AL - interrupt number
	;; returns:
	;; ES:BX - interrupt

SaveVector PROC
	;; AL - handler number
	;; DX - offset of DWORD to store vector

RestoreVector PROC
	;; AL - handler number
	;; DX - offset of DWORD containing vector
	
WriteInterruptVector PROC
	;; ES:BX - interrupt vector to write

WriteSavedVector PROC
	;; DX - offset of DWORD containing vector
	
!

ticks BYTE 0

Tick PROC
	inc	ticks
	sti
	push	ax
	push	dx
	
	mov	dl, '!'
	mov	ah, 02h
	int	DOS
;	pushf
;	call	ds:ClockVector
;	popf
	pop	dx
	pop	ax
	iret
Tick ENDP
	
_delay PROC
	pushf
	mov	ticks, 0
	jmp	cond
top:
cond:
	cmp	ticks, 18
	jl	top
	popf
	ret
_delay ENDP

delay PROC
	;; ax - number of seconds
	pushf
	push	si
	
	mov	si, 0
	jmp	cond
top:
	call	_delay
	inc	si
cond:
	cmp	si, ax
	jl	top
	
	pop	si
	popf
	ret
delay ENDP
	

stall PROC
	mov	cx, 10
top:
	push	cx
	
	mov	cx, 65535
top1:
	push	cx
	pop	cx
	loop	top1
	
	pop	cx
	loop	top
	ret
stall ENDP

KBD_INTERRUPT = 09h
CLK_INTERRUPT = 1Ch
BIOS_CLK_INTERRUPT = 1Ch
PROG_END_INTERRUPT = 22h
	
INTERRUPT = BIOS_CLK_INTERRUPT

ClockVector LABEL DWORD
ClockOffset WORD 0
ClockSegment WORD 0
	
main PROC
;	mov	ax, @data		; Setup data segment
	mov	ax, cs
	mov	ds, ax
	
	
	;; Display the active vector
	mov	al, INTERRUPT
	mov	bx, 0
	mov	es, bx
	call	GetInterruptVector
	call	WriteInterruptVector
	
	;; Save the vector
	mov	al, INTERRUPT
	mov	dx, offset ClockVector
	call	SaveVector

	;; Display the saved vector
	mov	dx, offset ClockVector
	call	WriteSavedVector

	call	DumpRegs
	mov	al, INTERRUPT
	mov	dx, Tick
	call	InstallHandler

	;; Display the active vector
	mov	al, INTERRUPT
	mov	bx, 0
	mov	es, bx
	call	GetInterruptVector
	call	WriteInterruptVector
	mov	ax, 2
	call	delay
;	call	Stall
	
	;; Restore the saved vector
	mov	al, INTERRUPT
	mov	dx, offset ClockVector
	call	RestoreVector
	
	;; Display the active vector
	mov	al, INTERRUPT
	mov	bx, 0
	mov	es, bx
	call	GetInterruptVector
	call	WriteInterruptVector
	
	mov	ax, TERMINATE		; Signal DOS we are done
	int	DOS
main ENDP



















































































































	




































OldVector WORD 0, 0

SetInterruptVector PROC
	;; AL - interrupt number
	;; DS:DX - new handler

	push	ax
	
	mov	ah, 25h
	int	DOS
	
	pop	ax
	ret
SetInterruptVector ENDP

InstallHandler PROC
	;; AL - interrupt number
	;; CS:DX - new handler

	push	bx
	push	ds
	
	mov	bx, cs
	mov	ds, bx
	call	SetInterruptVector
	
	pop	ds
	pop	bx
	ret
InstallHandler ENDP

GetInterruptVector PROC
	;; AL - interrupt number
	;; returns:
	;; ES:BX - interrupt
	push	ax
	mov	ah, 35h
	int	DOS
	pop	ax
	ret
GetInterruptVector ENDP

SaveVector PROC
	;; AL - handler number
	;; DX - offset of DWORD to store vector
	push	bx
	push	si
	push	es

	call	GetInterruptVector
	mov	si, dx
	mov	[si], bx
	mov	[si + 2], es
	
	pop	es
	pop	si
	pop	bx
	ret
SaveVector ENDP

RestoreVector PROC
	;; AL - handler number
	;; DX - offset of DWORD containing vector
	
	push	dx
	push	si
	push	ds
	
	mov	si, dx
	mov	dx, [si]
	mov	ds, [si + 2]
	call	SetInterruptVector
	
	pop	ds
	pop	si
	pop	dx
	ret
RestoreVector ENDP

WriteInterruptVector PROC
	;; ES:BX - interrupt vector to write
	push	dx
	mov	dx, es
	call	WriteHexWord
	mov	dl, ':'
	call	WriteChar
	mov	dx, bx
	call	WriteHexWord
	call	NewLine
	pop	dx

	ret
WriteInterruptVector ENDP

WriteSavedVector PROC
	;; DX - offset of DWORD containing vector
	push	bx
	push	si
	push	es
	
	mov	si, dx
	mov	bx, [si]
	mov	es, [si + 2]
	call	WriteInterruptVector
	
	pop	es
	pop	si
	pop	bx
	ret
WriteSavedVector ENDP
	

END main
