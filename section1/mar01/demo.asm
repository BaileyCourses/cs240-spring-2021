INCLUDE cs240.inc

.8086
	
TERMINATE = 4C00h
DOS = 21h

.data

msg	BYTE	"Hello, world!", 0

warray	DWORD	1A2B3C4Dh
	DWORD	80907040h
	
next	word	1
.code

main PROC
	mov	ax, @data		; Setup data segment
	mov	ds, ax

	mov	dx, OFFSET msg
	call	WriteString
	call	NewLine

	mov	cx, next - msg
	mov	bx, OFFSET msg
	call	DumpMem
	mov	ax, TERMINATE		; Signal DOS we are done
	int	DOS
main ENDP

END main
