[BITS 64]
[ORG 0x200000]

start:
    lgdt[Gdt64Ptr]

    push 8
    push KernalEntry
    db 0x48
    retf
    
KernalEntry:
    mov byte[0xb8000],'k'
    mov byte[0xb8001],0xa

END:
    hlt
    jmp END

Gdt64:
    dq 0
    dq 0x0020980000000000

Gdt64Len: equ $-Gdt64

Gdt64Ptr: dw Gdt64Len-1
         dq Gdt64