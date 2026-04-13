global display_memoria
global display_header
global display_footer

extern printf
extern get_bloco_status
extern get_bloco_nome

NUM_BLOCOS equ 16
TAM_BLOCO  equ 64

section .data
    header      db "================================", 10
                db "   SIMULADOR DE MEMORIA RAM     ", 10
                db "================================", 10, 0

    footer      db "================================", 10
                db " Total: 1024 bytes | Blocos: 16 ", 10
                db "================================", 10, 0

    fmt_livre   db "[0x%04X] [          ] LIVRE    (%d bytes)", 10, 0
    fmt_ocupado db "[0x%04X] [##########] OCUPADO  (%d bytes) <- %s", 10, 0
    fmt_stats   db "Livres: %d blocos (%d bytes) | Ocupados: %d blocos (%d bytes)", 10, 0

section .text

display_header:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    lea rcx, [rel header]
    call printf

    add rsp, 32
    pop rbp
    ret

display_footer:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    push r12
    push r13
    sub rsp, 48

    xor rbx, rbx
    xor rsi, rsi

.loop_stats:
    cmp rsi, NUM_BLOCOS
    jge .mostrar_stats

    mov rcx, rsi
    call get_bloco_status

    cmp eax, 0
    jne .prox_stats
    inc rbx

.prox_stats:
    inc rsi
    jmp .loop_stats

.mostrar_stats:
    mov r12, rbx              
    mov r13, NUM_BLOCOS
    sub r13, rbx              

    mov rax, r12
    imul rax, TAM_BLOCO        

    mov r11, r13
    imul r11, TAM_BLOCO       

    mov [rsp + 32], r11       
    lea rcx, [rel fmt_stats]
    mov rdx, r12               
    mov r8, rax                
    mov r9, r13              
    call printf

    lea rcx, [rel footer]
    call printf

    add rsp, 48
    pop r13
    pop r12
    pop rsi
    pop rbx
    pop rbp
    ret

display_memoria:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 32

    call display_header

    xor rbx, rbx

.loop_display:
    cmp rbx, NUM_BLOCOS
    jge .fim_display

    mov rcx, rbx
    call get_bloco_status
    mov r12d, eax

    mov r13, rbx
    imul r13, TAM_BLOCO

    cmp r12d, 0
    je .mostrar_livre

.mostrar_ocupado:
    mov rcx, rbx
    call get_bloco_nome

    lea rcx, [rel fmt_ocupado]
    mov rdx, r13
    mov r8, TAM_BLOCO
    mov r9, rax
    call printf
    jmp .proximo

.mostrar_livre:
    lea rcx, [rel fmt_livre]
    mov rdx, r13
    mov r8, TAM_BLOCO
    call printf

.proximo:
    inc rbx
    jmp .loop_display

.fim_display:
    call display_footer

    add rsp, 32
    pop rbx
    pop rbp
    ret