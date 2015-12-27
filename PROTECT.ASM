.MODEL SMALL

.386P

.DATA
EXECUT EQU 10011010b
RDWRDATA EQU 10010010b
STACKSEG EQU 10010110b
STATUS_PORT EQU 64
A20_PORT EQU 0d1h
A20_ON EQU 0dfh
A20_OFF EQU 0ddh
KBD_PORT_A EQU 60

GblDT DW 0,0,0,0
DW 0,0,0,0
DW 0,0,0,0
DW 0,0,0,0
DW 0,0,0,0

GblDscTbl DW 5*8-1
DD 0

IDT DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW przerwanie, 10h, 8E00h, 0
DW ziemniak, 10h, 8E00h, 0
IntDscTbl DW 30*8-1
DD 0
RetIDT DW 0FFFFh
DD 0
;---------------------------------------------------------------------
.CODE
przerwanie PROC
NOP
IRETD
przerwanie ENDP
ziemniak PROC
mov byte ptr es:[eax], '-'
inc eax
inc eax
IRETD
ziemniak ENDP
SetDscrpt PROC
mov dl, ah
shl ax, 4; AX*16
shr dl, 4
mov WORD PTR [si], bx
mov WORD PTR [si+2], ax
mov BYTE PTR [si+4], dl
mov WORD PTR [si+5], cx
mov BYTE PTR [si+7], 0
ret
SetDscrpt ENDP
;----------------------------------------------------------------------------
STARTPOINT:
SSEG SEGMENT WORD STACK USE16 'STACK'
DB 1024 DUP (?)
SSEG ENDS
mov ax, SEG _DATA
mov ds, ax
mov si, OFFSET GblDT
push ax
add si, 8
mov bx, 0FFFFh
mov cx, RDWRDATA
call SetDscrpt
mov ax, SEG _TEXT
add si, 8
mov bx, 0FFFFh
mov cx, EXECUT
call SetDscrpt
mov ax, SEG SSEG
add si, 8
mov bx, 0FFFFh
mov cx, STACKSEG
call SetDscrpt
mov ax, 0B800h
add si, 8
mov bx, 0FFFFh
mov cx, RDWRDATA
call SetDscrpt
mov ax, SEG _DATA
mov dl, ah
shl ax, 4
shr dl, 4
sub dh, dh
add ax, OFFSET GblDT
adc  dl, 0
mov GblDscTbl+2, ax
mov GblDscTbl+4, dx
lgdt PWORD PTR GblDscTbl
mov ax,SEG _DATA
mov dl,ah
shl ax, 4
shr dl, 4
sub dh, dh
add ax, OFFSET IDT
adc dl, 0
mov IntDscTbl+2, ax
mov IntDscTbl+4,dx
lidt PWORD PTR IntDscTbl
cli
mov eax, CR0
or eax, 1
and eax, 07FFFFFFFh
mov CR0, eax 
DB 0EAh
DW ClearPF
DW 10h
ClearPF:
mov ax, 8
mov ds, ax
mov ax, 18h
mov ss,ax
mov ax, 20h
mov es, ax
;---------------------------------------------------
;TRYB CHRONIONY
;---------------------------------------------------
mov byte ptr es:[0], 'Z'
mov byte ptr es:[2], 'I'
mov byte ptr es:[4], 'E'
mov byte ptr es:[6], 'M'
mov byte ptr es:[8], 'N'
mov byte ptr es:[10], 'I'
mov byte ptr es:[12], 'A'
mov byte ptr es:[14], 'K'
mov byte ptr es:[16], ' '
mov byte ptr es:[18], 'O'
mov byte ptr es:[20], 'S'
mov eax, 22
mov ebx, 0
petla:
inc ebx
cmp ebx, 99999999 
jne petla
;---------------------------------------------------
mov eax, CR0
and eax, 07FFFFFFEh
mov CR0, eax
DB 0EAh
DW ClearPF2
DW _TEXT
ClearPF2:
mov ax, SEG DGROUP
mov ds, ax
mov ax, SEG SSEG
mov ss, ax
lidt PWORD PTR RetIDT
sti
;--------------------------------------------------------
mov ah, 4Ch
int 21H
END STARTPOINT


