    device ZXSPECTRUM48

; В макросах есть ошибки, нужно исправить.
    include "macros.asm"


begin:
    org 0x0000
    ; Запрещаем прерывания.
    di
    im 1
    jp start

    ; RST 8 - Системный вызов
    org 0x0008
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
    ld bc, 100
    call delay
    ; end int programm
    RESTORE_BASIC_CTX
    ei
    reti

    org 0x0100
start:
    ; Устанавливаем дно стека.
    ld sp, 0xffff
    ; Разрешаем прерывания.
    ei    

    ; Инициализация системы
    call sys_init

loop:
    halt
    ld a, 0b00000111
    out (0xfe), a
    jp loop 

; Обработчик системных вызовов
syscall_handler:
    ; Сохраняем полный контекст
    SAVE_FULL_CTX
    
    ; Здесь будет диспетчеризация системных вызовов
    ; Номер вызова передается в регистре A
    ; Аргументы - в других регистрах
    
    ; Простая заглушка - просто возвращаем управление
    ; В реальной ОС здесь будет выбор нужной функции по номеру в A
    
    ; Восстанавливаем контекст
    RESTORE_FULL_CTX
    ret

; Инициализация системы
sys_init:
    ; Здесь будет инициализация подсистем ОС
    ret

; Процедура задержки
delay:
    dec bc
    ld a, b
    or c
    jr nz, delay
    ret

end:
    ; Выводим размер банарника.
    display "code size: ", /d, end - begin
    SAVEBIN "build/core.bin", begin, 16384