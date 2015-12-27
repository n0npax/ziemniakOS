org 7C00H
; program załaduje się w 7C00H
start:
jmp wejscie
;resetuj dyskietke
resetDisk:
xor ax,ax
mov dl, 0x0 ;0 floppy 80 hda
int 13
ret
Pisz:
;info o systemie
mov eax, string_info
mov ch, 1
; ch kolor
mov ebx, 0B8000H + 718H
pisz2:
mov cl, [eax]
; znak
mov [ebx], cx
;
add ch, 1
; zmien kolor
and ch, 0x0F
add eax, 1
add ebx, 2
; wskazniki dla string I vga
cmp eax, string_end2
; czy koniec stringa
jg stop2
jmp pisz2
stop2:
ret
PiszErr:
;info o klawiszu
mov eax, string_err
mov ch, 1
mov ebx, 0B8000H + 718H
pisz3:
mov cl, [eax]
mov [ebx], cx
add ch, 1
and ch, 0x0F
add eax, 1
add ebx, 2
cmp eax, string_end2
jg stop3
jmp pisz3
stop3:
ret
title:
;wypisz nazwe
mov eax, string_start
mov ch, 1mov ebx, 0B8000H + 718H
print:
mov cl, [eax]
mov [ebx], cx
add ch, 1
and ch, 0x0F
add eax, 1
add ebx, 2
cmp eax, string_end
jg stop
jmp print
stop:
ret
string_start db 'ZiemniakOS '
string_end equ $ -1 ;przesuniecie by uniknac losowegp znaku
string_info db ' start'
string_end2 equ $ -1
string_err db ' ERROR blad czytania '
string_end3 equ $ -1
wejscie:
;odczytaj testowo jeden sektor
call resetDisk
mov ax, 8000h
xor bx, bx
mov es,ax
;ustawiam zeby czytalo do ES:BX=8000h:0000h
mov
ax, 0201h
; funkcja czytania sektorów - czytam jeden, czy sie uda
xor
dx, dx
; glowica 0, dysk 0 = A:
mov
cx, 1
; numer sektora
stc
int
13h
; czytaj
sti
jnc
czyt_ok
; sprawdz, czy blad
jmp err1
czyt_ok:
xor bh, bh
;zeruje bh
cmp ah, bh
;upewniam sie, czy na pewno w porzadku odczytano
jne err1
jmp CzytajKernel
err1:
call PiszErr
jmp err1
;zapetlam program wyswietlajac informacje o błędzie
;Wlasciwe czytanie
CzytajKernel:
call resetDisk
call title
;
cx - liczba sektorow do odczytu
secrd:mov ax,8000h
xor bx,bx
mov es,ax
;es:bx=8000h:0000h
mov ax,2
mov cx, 10h
;odczytaj 16 sektorow
etykSt:
pusha
dec ax
; z numerów 1-36 na 0-35
mov cl,36
; liczba sektorów na cylinder = 36
xor dx,dx
; zakladamy na poczatek: glowica 0, dysk 0 (a:)
div cl
; AX (numer sektora) dzielimy przez 36
mov ch,al
; AL=cylinder, AH=przesuniecie wzgledem
;
poczatku cylindra, czyli sektor
cmp ah,18
; czy numer sektora mniejszy od 18?
jb .sec_ok
; je?li tak, to nie robimy nic
sub ah,18
; jezli nie, to odejmujemy 18
inc dh
; i zmieniamy glowicy
.sec_ok:
mov cl, ah
; CL = numer sektora
mov ax,0201h ; odczytaj 1 sektor
inc cl
; zwieksz z powrotem z zakresu 0-17 do 1-18
stc
int 13h
; wykonaj czytanie
sti
popa
add bx, 512
inc ax
loop etykSt
xor ax,ax
int 16h
mov dx, 0
;wcisnij klawisz by wykonac skok
;przerwaniem 10 wyswietlam litere Z dla upewnienia się, czy
;system sie nie zaiwesił
mov bx, 0
mov ah, 2
int 10h
mov ah, 9
mov al, 'Z'
mov bx, 0xb
mov cx, 1
int 10h
jmp
8028h:0000h
;wykonuje skok do odczytanego kernela
times 510 - ($ - start) db 31
dw 0AA55h
; dopelnienie do 510 bajtów
; znacznik – MAGIC NUMBER