[BITS 16]
[ORG 0x7c00]

START:
    XOR ax,ax
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov sp,0x7c00

TestDiskExtention:
    mov [DriveId],dl
    mov ah,0x41
    mov bx,0x55aa
    int 0x13
    jc NotSupport
    cmp bx,0xaa55
    jne NotSupport

LoadLoader:
    mov si,ReadPacket
    mov word[si],0x10
    mov word[si+2],5
    mov word[si+4],0x7e00
    mov word[si+6],0
    mov dword[si+8],1
    mov dword[si+0xc],0
    mov dl,[DriveId]
    mov ah,0x42
    int 0x13
    jc ReadError

    mov dl,[DriveId]
    jmp 0x7e00

ReadError:
NotSupport:
    mov ah,0x13
    mov al,1
    mov bx,0xa
    xor dx,dx
    mov bp,Message
    mov cx,MessageLen
    int 0x10

End:
    hlt
    jmp End

DriveId : db 0
Message : db "Error in Booting"
MessageLen : equ $-Message
ReadPacket: times 16 db 0

times(0x1be-($-$$))db 0

db 80h
db 0,2,0
db 0f0h
db 0ffh,0ffh,0ffh
dd 1
dd (20*26*63-1)

times(16*3)db 0

db 0x55
db 0xaa