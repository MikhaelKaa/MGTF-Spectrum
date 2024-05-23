    ; указываем ассемблеру, что целевая платформа - spectrum48, хотя это и не так, но похуй...
    device ZXSPECTRUM48
    ;SIZE 32768
begin:
    org 0x0000
    ; Запрещаем прерывания.
    di

    jp start

    org 0x0038 ; 56 
    di
    push af
    push bc
    push hl
    push de
    ;int programm
    ld a, 0b00000000
    out (0xfe), a
    ;end int programm
    pop de
    pop hl
    pop bc
    pop af
    ei
    reti

    org 0x100
start:
    
    ; Устанавливаем дно стека.
    ld sp, 16300 
    di



    ld  hl, target
    ld  de, 0x6000
    ld  bc, target_end-target
    ldir
    call 0x6000
    

    
main_loop:

    jp main_loop


cash_on:
    in a, (0xfb) ; включить cash
    ret

cash_off:
    in a, (0x7b) ; выключить cash
    ret

; Процедура задержки
; bc - время
delay:
    dec bc
    ld a, b
    or c
    jr nz, delay
    ret


target:
    incbin "build/umt.bin"
target_end:


end:
    ; Выводим размер банарника.
    display "target size: ", /d, target_end - target
    display "code size: ", /d, end - begin
    SAVEBIN "build/out.bin", begin, 16384;  размер бинарного файла для прошивки ПЗУ\ОЗУ