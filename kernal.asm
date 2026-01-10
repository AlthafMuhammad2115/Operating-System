section .data

Gdt64:
    dq 0
    dq 0x0020980000000000
    dq 0x0020F80000000000
    dq 0x0000F20000000000
TSSDesc:
    dw TSSLen-1
    dw 0
    db 0
    db 0x89
    db 0
    db 0
    dq 0

Gdt64Len: equ $-Gdt64

Gdt64Ptr: dw Gdt64Len-1
         dq Gdt64

TSS:
    dd 0
    dq 0x150000
    times 88 db 0
    dd TSSLen

TSSLen: equ $-TSS


section .text

extern KMain
global start

start:
    lgdt[Gdt64Ptr]

SetTSS:
    mov rax,TSS
    mov [TSSDesc+2], ax
    shr rax,16
    mov [TSSDesc+4], al
    mov [TSSDesc+7],ah
    shr rax, 16
    mov [TSSDesc+8], eax

    mov ax, 0x20
    ltr ax
    
; for user defined Interrupt , init program interrupt timer PIT , we control timer were actal clock freq is 1.2MHz , 
; we changed the freq to 100Hz by giving an intial value of the timer register as 11931 , it will decrease till 0, do it continuesly

InitPIT:
    mov al,(1<<2)|(3<<4)
    out 0x43,al

    mov ax,11931
    out 0x40,al
    mov al,ah
    out 0x40,al

; Program interrupt controller is responsible for control Interrupt,  

InitPIC:
    mov al,0x11
    out 0x20,al
    out 0xa0,al

    mov al,32
    out 0x21,al
    mov al,40
    out 0xa1,al

    mov al,4
    out 0x21,al
    mov al,2
    out 0xa1,al

    mov al,1
    out 0x21,al
    out 0xa1,al

    mov al,11111110b
    out 0x21,al
    mov al,11111111b
    out 0xa1,al

    push 8
    push KernalEntry
    db 0x48
    retf
    
KernalEntry:
    mov rsp,0x200000
    call KMain
    
END:
    hlt
    jmp END


