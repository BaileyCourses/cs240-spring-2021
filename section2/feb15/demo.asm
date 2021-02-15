INCLUDE cs240.inc

.8086
	
TERMINATE = 4C00h
DOS = 21h

.data

msg	BYTE	"Hello, world!", 0
coolmsg	BYTE	"Computer Science is Cool", 0

.code

doit PROC
     push	dx

     mov	dx, OFFSET coolmsg
     call	WriteString
     call	NewLine
     
     pop	dx

     ret
doit ENDP


main PROC
     mov	ax, @data		; Setup data segment
     mov	ds, ax

     mov	dx, 10
     call	doit

     ; ...
     call	DumpRegs

     mov	ax, TERMINATE		; Signal DOS we are done
     int	DOS
main ENDP

END main
