; memoria.asm - Logica de alocacao e desalocacao

global init_memoria
global alocar_memoria
global desalocar_memoria
global get_bloco_status
global get_bloco_nome
global NUM_BLOCOS
global blocos_status
global blocos_nome

extern printf

NUM_BLOCOS equ 16
TAM_BLOCO  equ 64
TAM_NOME   equ 16

section .data
    msg_alocado     db "Memoria alocada com sucesso!", 10, 0
    msg_desalocado  db "Memoria desalocada com sucesso!", 10, 0
    msg_sem_espaco  db "Erro: Sem memoria livre!", 10, 0
    msg_invalido    db "Erro: Bloco invalido ou ja livre!", 10, 0
    fmt_printf      db "%s", 0

section .bss
    blocos_status   resb NUM_BLOCOS        ; 0=LIVRE, 1=OCUPADO
    blocos_nome     resb NUM_BLOCOS * TAM_NOME  ; nome de cada processo

section .text

;----------------------------------
; init_memoria - inicializa todos os blocos como LIVRE
;----------------------------------
init_memoria:
    push rbp
    mov rbp, rsp

    mov rcx, NUM_BLOCOS
    lea rdi, [rel blocos_status]
    xor al, al
    rep stosb                          ; preenche tudo com 0 (LIVRE)

    mov rcx, NUM_BLOCOS * TAM_NOME
    lea rdi, [rel blocos_nome]
    xor al, al
    rep stosb                          ; limpa todos os nomes

    pop rbp
    ret

;----------------------------------
; alocar_memoria - aloca N blocos consecutivos
; parametro: rcx = numero de blocos a alocar
;            rdx = endereco do nome do processo
; retorno:   eax = indice do primeiro bloco (-1 se falhar)
;----------------------------------
alocar_memoria:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    push rdi
    sub rsp, 32

    mov rbx, rcx               ; rbx = numero de blocos pedidos
    mov rsi, rdx               ; rsi = nome do processo

    ; procurar blocos livres consecutivos
    xor rcx, rcx               ; rcx = indice atual

.loop_busca:
    cmp rcx, NUM_BLOCOS
    jge .sem_espaco

    ; verificar se bloco rcx esta livre
    lea rdi, [rel blocos_status]
    mov al, [rdi + rcx]
    cmp al, 0
    jne .proximo

    ; contar blocos livres consecutivos a partir de rcx
    push rcx
    mov rdx, rcx               ; rdx = inicio
    xor r8, r8                 ; r8 = contador

.loop_conta:
    cmp rcx, NUM_BLOCOS
    jge .verifica
    lea rdi, [rel blocos_status]
    mov al, [rdi + rcx]
    cmp al, 0
    jne .verifica
    inc r8
    inc rcx
    cmp r8, rbx
    jl .loop_conta

.verifica:
    cmp r8, rbx
    jl .nao_suficiente

    ; temos blocos suficientes, alocar
    pop rcx                    ; rcx = indice inicial
    push rcx                   ; guardar para retorno

.loop_alocar:
    cmp r8, 0
    je .alocar_nome
    lea rdi, [rel blocos_status]
    mov byte [rdi + rcx], 1    ; marcar como OCUPADO
    inc rcx
    dec r8
    jmp .loop_alocar

.alocar_nome:
    pop rcx                    ; rcx = indice inicial
    push rcx

    ; copiar nome para cada bloco alocado
    mov r9, rcx                ; r9 = indice inicial
    mov r10, rbx               ; r10 = contador de blocos

.loop_nome:
    cmp r10, 0
    je .sucesso

    ; calcular endereco do nome deste bloco
    mov rax, r9
    mov r11, TAM_NOME
    mul r11
    lea rdi, [rel blocos_nome]
    add rdi, rax               ; rdi = destino do nome

    ; copiar nome (até TAM_NOME bytes)
    mov r8, rsi                ; r8 = fonte (nome)
    mov rcx, TAM_NOME

.loop_copia:
    mov al, [r8]
    mov [rdi], al
    inc r8
    inc rdi
    dec rcx
    cmp al, 0
    je .nome_copiado
    cmp rcx, 0
    jne .loop_copia

.nome_copiado:
    inc r9
    dec r10
    jmp .loop_nome

.sucesso:
    lea rcx, [rel fmt_printf]
    lea rdx, [rel msg_alocado]
    call printf

    pop rax                    ; eax = indice inicial
    jmp .fim

.nao_suficiente:
    pop rcx
    jmp .proximo

.proximo:
    inc rcx
    jmp .loop_busca

.sem_espaco:
    lea rcx, [rel fmt_printf]
    lea rdx, [rel msg_sem_espaco]
    call printf
    mov eax, -1

.fim:
    add rsp, 32
    pop rdi
    pop rsi
    pop rbx
    pop rbp
    ret

;----------------------------------
; desalocar_memoria - liberta os blocos de um processo
; parametro: rcx = endereco do nome do processo
; retorno:   eax = 0 (sucesso), -1 (falha)
;----------------------------------
desalocar_memoria:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    sub rsp, 32

    mov rbx, rcx               ; rbx = nome a desalocar
    xor rsi, rsi               ; rsi = indice
    xor r15, r15               ; r15 = contador de blocos libertados

.loop_desal:
    cmp rsi, NUM_BLOCOS
    jge .fim_desal

    ; verificar se bloco esta ocupado
    lea rdi, [rel blocos_status]
    mov al, [rdi + rsi]
    cmp al, 1
    jne .prox_desal

    ; comparar nome do bloco com o nome pedido
    mov rax, rsi
    mov r11, TAM_NOME
    mul r11
    lea rdi, [rel blocos_nome]
    add rdi, rax               ; rdi = nome do bloco atual

    mov r8, rbx                ; r8 = nome pedido
    mov rcx, TAM_NOME

.loop_cmp:
    mov al, [rdi]
    mov r9b, [r8]
    cmp al, r9b
    jne .prox_desal
    cmp al, 0
    je .match
    inc rdi
    inc r8
    dec rcx
    cmp rcx, 0
    jne .loop_cmp

.match:
    ; libertar este bloco
    lea rdi, [rel blocos_status]
    mov byte [rdi + rsi], 0

    ; limpar nome do bloco
    mov rax, rsi
    mov r11, TAM_NOME
    mul r11
    lea rdi, [rel blocos_nome]
    add rdi, rax
    mov rcx, TAM_NOME
.loop_limpa:
    mov byte [rdi], 0
    inc rdi
    dec rcx
    jne .loop_limpa

    inc r15

.prox_desal:
    inc rsi
    jmp .loop_desal

.fim_desal:
    cmp r15, 0
    je .erro_desal

    lea rcx, [rel fmt_printf]
    lea rdx, [rel msg_desalocado]
    call printf
    xor eax, eax
    jmp .ret_desal

.erro_desal:
    lea rcx, [rel fmt_printf]
    lea rdx, [rel msg_invalido]
    call printf
    mov eax, -1

.ret_desal:
    add rsp, 32
    pop rsi
    pop rbx
    pop rbp
    ret

;----------------------------------
; get_bloco_status - retorna status de um bloco
; parametro: rcx = indice do bloco
; retorno:   eax = 0 (LIVRE) ou 1 (OCUPADO)
;----------------------------------
get_bloco_status:
    push rbp
    mov rbp, rsp

    lea rax, [rel blocos_status]
    movzx eax, byte [rax + rcx]

    pop rbp
    ret

;----------------------------------
; get_bloco_nome - retorna endereco do nome de um bloco
; parametro: rcx = indice do bloco
; retorno:   rax = endereco do nome
;----------------------------------
get_bloco_nome:
    push rbp
    mov rbp, rsp

    mov rax, rcx
    mov r11, TAM_NOME
    mul r11
    lea rcx, [rel blocos_nome]
    add rax, rcx

    pop rbp
    ret