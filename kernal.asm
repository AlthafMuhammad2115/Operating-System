[BITS 64]
[ORG 0x200000]

start:

;  0-32 entry of Idt is fixed , for example 0th entry is for div by 0 exception, 
; below we initialized Idt 0th entry map to handler0 , So if zero exception trigered , handler0 code works
    mov rdi,Idt
    mov rax, handler0
    call SetHandler

; 32-255 entry of Idt is user defined interrupt,
; Below we intiasialzed 32nd entry of Idt as timer , if interrupt signal 'STI' started timer function trigger

    mov rdi, Idt+32*16
    mov rax, Timer
    call SetHandler

    mov rdi, Idt+32*16+7*16
    mov rax, SIRQ
    call SetHandler

    lgdt[Gdt64Ptr]
    lidt[IdtPtr]

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


    push 8
    push KernalEntry
    db 0x48
    retf
    
KernalEntry:
    mov byte[0xb8000],'k'
    mov byte[0xb8001],0xa

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

; started interrupt by sti

    ; sti



;For UserMode with DPL ==3 , usermode jump
    push 0x18 | 3
    push 0x7c00
    push 0x202
    push 0x10 | 3
    push UserEntry
    iretq

END:
    hlt
    jmp END

SetHandler:
    mov [rdi],ax
    shr rax,16
    mov [rdi+6],ax
    shr rax,16
    mov [rdi+8],eax
    ret

UserEntry:
    mov ax,cs
    and al,11b
    cmp al,3
    jne UserEnd
    mov byte[0xb8000],'U'
    mov byte[0xb8001],0xa

UserEnd:
    jmp UserEnd

handler0:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push rbp
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15

    mov byte[0xb8000],'D'
    mov byte[0xb8001],0xc

    jmp END

    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rbp
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    iretq

Timer:
; save and restore reg for context switch 
    push rax
    push rbx  
    push rcx
    push rdx  	  
    push rsi
    push rdi
    push rbp
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15

    mov byte[0xb8020],'T'
    mov byte[0xb8021],0xe
    jmp End
   
    pop	r15
    pop	r14
    pop	r13
    pop	r12
    pop	r11
    pop	r10
    pop	r9
    pop	r8
    pop	rbp
    pop	rdi
    pop	rsi  
    pop	rdx
    pop	rcx
    pop	rbx
    pop	rax

    iretq

SIRQ:
    push rax
    push rbx  
    push rcx
    push rdx  	  
    push rsi
    push rdi
    push rbp
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15

    mov al,11
    out 0x20,al
    in al, 0x20

    test al , (1<<7)
    jz .end

    mov al, 0x20
    out 0x20, al

.end:   
    pop	r15
    pop	r14
    pop	r13
    pop	r12
    pop	r11
    pop	r10
    pop	r9
    pop	r8
    pop	rbp
    pop	rdi
    pop	rsi  
    pop	rdx
    pop	rcx
    pop	rbx
    pop	rax
    iretq

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

Idt:
    %rep 256
        dw 0
        dw 0x8
        db 0
        db 0x8e
        dw 0
        dd 0
        dd 0
    %endrep

IdtLen: equ $-Idt
IdtPtr: dw IdtLen-1
        dq Idt

TSS:
    dd 0
    dq 0x150000
    times 88 db 0
    dd TSSLen

TSSLen: equ $-TSS