INCLUDE cs240.inc
INCLUDE demolib.inc

.8086
	
TERMINATE = 4C00h
DOS = 21h

.code
	
ticks BYTE 0

Tick PROC
	inc	ticks
	sti
	push	ax
	push	dx
	
	mov	dl, '!'
	mov	ah, 02h
	int	DOS
	pushf
	call	DWORD PTR [ClockVector]
	pop	dx
	pop	ax
	iret
Tick ENDP
	
HardwareTick PROC
	inc	ticks
	sti
	push	ax
	push	dx
	
	mov	dl, '?'
	mov	ah, 02h
	int	DOS
;	pushf
;	call	DWORD PTR [HardwareClockVector]
	
	pop	dx
	pop	ax
	iret
HardwareTick ENDP
	
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
	

KBD_INTERRUPT = 09h
CLK_INTERRUPT = 1Ch
BIOS_CLK_INTERRUPT = 1Ch
PROG_END_INTERRUPT = 22h
	
INTERRUPT = BIOS_CLK_INTERRUPT

ClockVector LABEL DWORD
ClockOffset WORD 0
ClockSegment WORD 0
	
HardwareClockVector LABEL DWORD
HardwareClockOffset WORD 0
HardwareClockSegment WORD 0
	
main PROC
;	mov	ax, @data		; Setup data segment
	mov	ax, cs
	mov	ds, ax
	
	mov	al, INTERRUPT
	mov	dx, offset ClockVector
	call	SaveVector
	mov	dx, Tick
	call	InstallHandler

	mov	al, CLK_INTERRUPT
	mov	dx, offset HardwareClockVector
	call	SaveVector
	mov	dx, HardwareTick
	call	InstallHandler
	
	mov	ax, 1
	call	Delay
	
	mov	al, INTERRUPT
	mov	dx, offset HardwareClockVector
	call	RestoreVector
	
	call	NewLine

	mov	al, INTERRUPT
	mov	dx, offset ClockVector
	call	RestoreVector
	
	mov	cx, 0830h
	mov	al, '$'
	call	ScreenChar
	
	
	mov	ax, TERMINATE		; Signal DOS we are done
	int	DOS
main ENDP

rowcol2index PROC
	;; ch - row
	;; cl - col
	;; return
	;; ax - index

	pushf
	push	cx
	
	mov	ax, 80
	mul	ch
	mov	ch, 0
	add	ax, cx
	shl	ax, 1
	
	pop	cx
	popf

	ret
rowcol2index ENDP

ScreenChar PROC
	;; ch - row
	;; cl - col
	;; al - character

	push	ax
	push	di
	push	es
	
	mov	di, 0B800h
	mov	es, di
	
	push	ax
	call	rowcol2index
	mov	di, ax
	pop	ax
	
	mov	ah, 10001111b
	mov	es:[di], ax
	
	pop	es
	pop	di
	pop	ax
	ret
ScreenChar ENDP

















































































































	




































OldVector WORD 0, 0


END main
