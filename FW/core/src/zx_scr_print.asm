
font_data:
    INCBIN "font_en.ch8"

; d - x (0-31)
; e - y (0-23)
; hl - string
print_string:
; Вычисляем адрес на экране для координат (X, Y)
    ld a, d
    and 7
    rra
    rra
    rra
    rra
    or e
    ld e,a
    ld a,d
    and 24
    or 64
    ld d,a
    ; Теперь DE содержит адрес на экране
print_string_loop:
    ld a, (hl)
    and a
    ret z
    push hl
    ld h, 0x0
    ld l, a
    add hl, hl
    add hl, hl
    add hl, hl
    ld bc, font_data - 256;
    add hl, bc
    push de
    call print_char
    pop de
    pop hl
    inc hl
    inc de
    jp print_string_loop
    
    ; Печатает символ 8x8 пикселей
    ; HL - указатель на данные символа в шрифте
    ; DE - адрес в видеопамяти
print_char:
    ld b, 0x8
pchar_loop:
    ld a, (hl)
    ld (de), a
    inc d
    inc hl
    djnz pchar_loop
    ret


    ; Константы
SCREEN_PIXELS:  equ 16384  ; Начало пиксельной области
SCREEN_ATTR:    equ 22528  ; Начало области атрибутов
PIXEL_SIZE:     equ 6144   ; Размер пиксельной области
ATTR_SIZE:      equ 768    ; Размер области атрибутов
ATTR_VALUE:     equ 0b00000111

; Процедура очистки экрана
clear_screen:
    push af
    push bc
    push de
    push hl
    
    ; Очищаем пиксельную область (заполняем нулями)
    ld hl, SCREEN_PIXELS   ; Начало экрана
    ld de, SCREEN_PIXELS+1 ; Следующий байт
    ld bc, PIXEL_SIZE-1    ; Количество байтов для копирования
    ld (hl), 0             ; Записываем 0 в первый байт
    ldir                   ; Заполняем всю область
    
    ; Устанавливаем атрибуты
    ld hl, SCREEN_ATTR     ; Начало атрибутов
    ld de, SCREEN_ATTR+1   ; Следующий байт
    ld bc, ATTR_SIZE-1     ; Количество байтов для копирования
    ld (hl), ATTR_VALUE    ; Записываем значение атрибута
    ldir                   ; Заполняем всю область атрибутов
    
    pop hl
    pop de
    pop bc
    pop af
    ret
