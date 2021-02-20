INCLUDE cs240.inc

.8086
	
TERMINATE = 4C00h
DOS = 21h

pow PROTO

.data

msg	BYTE	"Hello, world!", 0

.code

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
