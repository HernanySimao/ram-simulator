; utils.asm - Funções auxiliares

extern printf
extern scanf
extern getchar

global print_string
global print_int
global print_newline
global read_int

section .data
    fmt_string  db "%s", 0
    fmt_int     db "%d", 0
    fmt_newline db 10, 0
    fmt_read    db "%d", 0

section .text

;----------------------------------
; print_string - imprime uma string
; parametro: rcx = endereco da string
;----------------------------------
print_string:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    mov rdx, rcx
    lea rcx, [rel fmt_string]
    call printf

    add rsp, 32
    pop rbp
    ret

;----------------------------------
; print_int - imprime um inteiro
; parametro: rcx = valor inteiro
;----------------------------------
print_int:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    mov rdx, rcx
    lea rcx, [rel fmt_int]
    call printf

    add rsp, 32
    pop rbp
    ret

;----------------------------------
; print_newline - imprime uma linha nova
;----------------------------------
print_newline:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    lea rcx, [rel fmt_newline]
    call printf

    add rsp, 32
    pop rbp
    ret

;----------------------------------
; read_int - lê um inteiro do utilizador
; retorno: eax = valor lido
;----------------------------------
read_int:
    push rbp
    mov rbp, rsp
    sub rsp, 48

    lea rdx, [rbp - 4]
    lea rcx, [rel fmt_read]
    call scanf

    ; limpar buffer
    call getchar

    mov eax, [rbp - 4]

    add rsp, 48
    pop rbp
    ret