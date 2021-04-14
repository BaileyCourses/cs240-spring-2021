INCLUDE cs240.inc
	
TERMINATE=4C00h
DOS=21h
	
.386
	
PlayNoteString PROTO
NoteFrequencyToTimerCount PROTO
NoteDelay PROTO
InterNoteDelay PROTO

TIMER_DATA_PORT		= 42h
TIMER_CONTROL_PORT	= 43h
SPEAKER_PORT		= 61h
READY_TIMER		= 0B6h
	
.data
CE3K	BYTE	"4D 4E 4C 3C 3G ", 0
mhall   BYTE    "EDCDEEEDDDEEEEDCDEEEEDDEDC", 0
score	BYTE	1000 dup(0)		
scale BYTE "CDEFGAB"	, 0
ScoreFileName BYTE "score.dat", 0
.code

SpeakerMuted	BYTE	0
	
Mute PROC
	mov	cs:SpeakerMuted, 1
	ret
Mute ENDP
	
UnMute PROC
	mov	cs:SpeakerMuted, 0
	ret
UnMute ENDP
	
SpeakerOn PROC
	pushf
	push	ax

	test	cs:SpeakerMuted, 1
	jnz	muted
	
	in	al, SPEAKER_PORT		; Read the speaker register
	or	al, 03h				; Set the two low bits high
	out	SPEAKER_PORT, al		; Write the speaker register
	jmp	done
muted:	
	push	dx
	mov	dl, 02h
	call	WriteChar
	pop	dx
done:	
	pop	ax
	popf
	ret
SpeakerOn ENDP
	
SpeakerOff PROC

	pushf
	push	ax
	
	in	al, SPEAKER_PORT		; Read the speaker register
	and	al, 0FCh			; Clear the two low bits high
	out	SPEAKER_PORT, al		; Write the speaker register

	pop	ax
	popf
	ret
SpeakerOff ENDP
	
PlayFrequency PROC
	;; Frequency is found in DX

	pushf
	push	ax
	
	call	NoteFrequencyToTimerCount

	mov	al, READY_TIMER			; Get the timer ready
	out	TIMER_CONTROL_PORT, al

	mov	al, dl
	out	TIMER_DATA_PORT, al		; Send the count low byte
	
	mov	al, dh
	out	TIMER_DATA_PORT, al		; Send the count high byte
	
	call	NoteDelay
	call	SpeakerOff
;	call	InterNoteDelay
	call	SpeakerOn

	pop	ax
	popf
	ret
PlayFrequency ENDP
	
main PROC
	mov     ax, @data
        mov     ds, ax

;	call	Mute
	call	SpeakerOn

	mov	dx, offset ce3k
	call	PlayNoteString
	
	call	SpeakerOff
        mov     ax, TERMINATE
        int     DOS
main ENDP

END main        
