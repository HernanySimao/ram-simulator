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

;----------------------------------
; display_header - imprime o cabecalho
;----------------------------------
display_header:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    lea rcx, [rel header]
    call printf

    add rsp, 32
    pop rbp
    ret

;----------------------------------
; display_footer - imprime o rodape com estatisticas
;----------------------------------
display_footer:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    sub rsp, 32

    xor rbx, rbx       ; rbx = blocos livres
    xor rsi, rsi       ; rsi = indice

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
    ; blocos livres
    mov r9, rbx
    mov rax, NUM_BLOCOS
    sub rax, rbx       ; blocos ocupados

    ; bytes livres e ocupados
    mov r10, rbx
    imul r10, TAM_BLOCO

    mov r11, rax
    imul r11, TAM_BLOCO

    lea rcx, [rel fmt_stats]
    mov rdx, rbx           ; livres (blocos)
    mov r8, r10            ; livres (bytes)
    mov r9, rax            ; ocupados (blocos)
    ; 5o parametro vai na stack
    sub rsp, 8
    push r11
    call printf
    add rsp, 16

    lea rcx, [rel footer]
    call printf

    add rsp, 32
    pop rsi
    pop rbx
    pop rbp
    ret

;----------------------------------
; display_memoria - mostra todos os blocos
;----------------------------------
display_memoria:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 32

    call display_header

    xor rbx, rbx       ; rbx = indice do bloco

.loop_display:
    cmp rbx, NUM_BLOCOS
    jge .fim_display

    ; obter status do bloco
    mov rcx, rbx
    call get_bloco_status
    mov r12d, eax      ; r12 = status

    ; calcular endereco de memoria (rbx * 64)
    mov r13, rbx
    imul r13, TAM_BLOCO   ; r13 = endereco

    cmp r12d, 0
    je .mostrar_livre

.mostrar_ocupado:
    ; obter nome do processo
    mov rcx, rbx
    call get_bloco_nome    ; rax = endereco do nome

    lea rcx, [rel fmt_ocupado]
    mov rdx, r13           ; endereco hex
    mov r8, TAM_BLOCO      ; tamanho
    mov r9, rax            ; nome do processo
    call printf
    jmp .proximo

.mostrar_livre:
    lea rcx, [rel fmt_livre]
    mov rdx, r13           ; endereco hex
    mov r8, TAM_BLOCO      ; tamanho
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