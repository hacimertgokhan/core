BITS 16
ORG 0x7C00

start:
    cli
    mov si, boot_msg
    call print_string

    lgdt [gdt_desc]
    mov eax, cr0
    or  eax, 1
    mov cr0, eax
    jmp CODE_SEG:init_protected_mode

print_string:
    mov ah, 0x0E
.loop:
    lodsb
    or al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    ret

[SECTION .bss]
align 16
stack resb 4096

[SECTION .data]
boot_msg db "Rust Kernel Loading...", 0
gdt_start:
    dq 0x0000000000000000
    dq 0x00CF9A000000FFFF
    dq 0x00CF92000000FFFF
gdt_end:
gdt_desc:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_start - gdt_start
DATA_SEG equ gdt_start - gdt_start + 8

[SECTION .text]
BITS 32
init_protected_mode:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, stack + 4096
    call rust_kernel
    cli
    hlt

rust_kernel:
    jmp 0x100000
