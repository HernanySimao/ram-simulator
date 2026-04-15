extern init_memoria
extern alocar_memoria
extern desalocar_memoria
extern display_memoria
extern print_string
extern print_newline
extern read_int
extern printf
extern scanf

global main

section .data
    menu        db 10
                db "=== MENU ===", 10
                db "1. Ver memoria", 10
                db "2. Alocar memoria", 10
                db "3. Desalocar memoria", 10
                db "4. Sair", 10
                db "Escolha: ", 0

    msg_nome    db "Nome do processo (ex: ProcA): ", 0
    msg_blocos  db "Quantos blocos alocar (1-16): ", 0
    msg_desal   db "Nome do processo a desalocar: ", 0
    msg_invalid db "Opcao invalida!", 10, 0
    msg_bye     db "Encerrando simulador... Ate logo!", 10, 0

    fmt_str     db "%s", 0
    fmt_scan    db "%15s", 0

section .bss
    nome_buffer resb 16

section .text

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    call init_memoria
    call display_memoria

.loop_menu:
    lea rcx, [rel fmt_str]
    lea rdx, [rel menu]
    call printf

    ; ler opcao
    call read_int
    mov rbx, rax

    cmp rbx, 1
    je .ver_memoria

    cmp rbx, 2
    je .alocar

    cmp rbx, 3
    je .desalocar

    cmp rbx, 4
    je .sair

    lea rcx, [rel fmt_str]
    lea rdx, [rel msg_invalid]
    call printf
    jmp .loop_menu

.ver_memoria:
    call display_memoria
    jmp .loop_menu

.alocar:
    lea rcx, [rel fmt_str]
    lea rdx, [rel msg_nome]
    call printf

    lea rcx, [rel fmt_scan]
    lea rdx, [rel nome_buffer]
    call scanf

    lea rcx, [rel fmt_str]
    lea rdx, [rel msg_blocos]
    call printf

    call read_int
    mov r14, rax               

    ; alocar
    mov rcx, r14
    lea rdx, [rel nome_buffer]
    call alocar_memoria

    call display_memoria
    jmp .loop_menu

.desalocar:
    lea rcx, [rel fmt_str]
    lea rdx, [rel msg_desal]
    call printf

    lea rcx, [rel fmt_scan]
    lea rdx, [rel nome_buffer]
    call scanf

    ; desalocar
    lea rcx, [rel nome_buffer]
    call desalocar_memoria

    call display_memoria
    jmp .loop_menu

.sair:
    lea rcx, [rel fmt_str]
    lea rdx, [rel msg_bye]
    call printf

    xor eax, eax
    add rsp, 32
    pop rbp
    ret