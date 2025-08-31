    device ZXSPECTRUM48

    include "macros.asm"

code_start:
    org 0x0000
    ; Запрещаем прерывания.
    di
    jp start

    ; RST 8 - Системный вызов
    org 0x0008
    ; call print_string
    jp syscall_handler

    ; RST 16 (0x10) - Дополнительный системный вызов
    org 0x0010
    ret

    ; RST 24 (0x18) - Дополнительный системный вызов  
    org 0x0018
    ret

    ; RST 32 (0x20) - Дополнительный системный вызов
    org 0x0020
    ret

    ; RST 40 (0x28) - Дополнительный системный вызов
    org 0x0028
    ret

    ; RST 48 (0x30) - Дополнительный системный вызов
    org 0x0030
    ret

    ; INT
    org 0x0038
    di
    SAVE_BASIC_CTX
    ; start int programm
    ld a, 0b00000000
    out (0xfe), a
    ld bc, 512
    call delay
    ; end int programm
    RESTORE_BASIC_CTX
    ei
    reti

    ; NMI
    org 0x0066
    di
    SAVE_BASIC_CTX
    ; start int programm
    ld a, 0b00000010
    out (0xfe), a
    call clear_screen
    ld bc, 100
    call delay
    ; end int programm
    RESTORE_BASIC_CTX
    ei
    reti


    include "syscall_table.asm"

    org 0x0100
    ; db "start"
start:
    ; Режим работы прерывания
    im 1
    ; Устанавливаем стек.
    ld sp, 0xffff
    ; Разрешаем прерывания.
    ei    

    call clear_screen
    ld d, 0x00
    ld e, 0x00
    ld hl, hello_str
    call print_string

    ; Инициализация системы
    call sys_init

    ld a, 0
    rst 8

loop:
    halt
    ld a, 0b00000111
    out (0xfe), a
    jp loop 

    include "syscall.asm"

hello_str:
    db "hello!", 0
rst_str:
    db "rst 8 ok!", 0   
; Инициализация системы
sys_init:
    ld de, 0x0100
    ld hl, rst_str
    ld a, 25
    rst 8
    ret


    org 0x300; TODO для отладки
    include "zx_scr_print.asm"

; Процедура задержки
delay:
    dec bc
    ld a, b
    or c
    jr nz, delay
    ret


code_end:

    org 0xc000
data_start:   
    ; data section
myvar:
    db 1
data_end:

    ; Выводим размер банарника.
    display "code start: ", /h, code_start
    display "code size: ", /d, code_end - code_start
    display "data start: ", /h, data_start
    display "data size: ", /d, data_end - data_start
    SAVEBIN "build/core.bin", code_start, 16384