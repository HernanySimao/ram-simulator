@echo off
echo Compilando...
nasm -f win64 utils.asm -o utils.obj
nasm -f win64 memoria.asm -o memoria.obj
nasm -f win64 display.asm -o display.obj
nasm -f win64 main.asm -o main.obj
gcc utils.obj memoria.obj display.obj main.obj -o simulador.exe
echo Pronto! Rodando...
simulador.exe