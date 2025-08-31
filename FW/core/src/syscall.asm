; Обработчик системных вызовов
    db "syscall_handler"

; TODO: WARNING, самомодифицирующийся код, не пригодно для размещения в ROM в текущем виде.
; метка, хранящая opcode перехода
opcode_jp:
    db 0xc3
; Переменная для хранения адреса обработчика
handler_pointer:
    dw 0x0000

syscall_handler:
    push hl
    push de
    
    ; Вычисляем адрес обработчика в таблице
    add a, a        ; Умножаем A на 2 (A = номер вызова)
    ld e, a
    ld d, 0
    
    ld hl, syscall_table
    add hl, de      ; HL = адрес в таблице
    
    ; Загружаем адрес обработчика
    ld e, (hl)
    inc hl
    ld d, (hl)
    
    ; Сохраняем адрес обработчика во временную переменную
    ld (handler_pointer), de
    
    ; Восстанавливаем регистры
    pop de
    pop hl
    
    ; Переходим к обработчику
    jp opcode_jp

    
sys_open:
    push hl
    ld hl, SCREEN_PIXELS+16
    ld(hl), 0x5
    pop hl
    scf
    ld a, 0xff
    ret  
sys_close:
    scf
    ld a, 0xff
    ret 
sys_read:
    scf
    ld a, 0xff
    ret  
sys_write:
    scf
    ld a, 0xff
    ret 
sys_seek:
    scf
    ld a, 0xff
    ret  
sys_stat:
    scf
    ld a, 0xff
    ret  
sys_fork:
    scf
    ld a, 0xff
    ret  
sys_exit:
    scf
    ld a, 0xff
    ret  
sys_wait:
    scf
    ld a, 0xff
    ret  
sys_exec:
    scf
    ld a, 0xff
    ret  
sys_getpid:
    scf
    ld a, 0xff
    ret
sys_brk:
    scf
    ld a, 0xff
    ret

sys_print:
    ; d - x
    ; e - y
    ; hl - string pointer
    call print_string
    ret

; Заглушка для нереализованных системных вызовов
sys_unimpl:
    ; Устанавливаем флаг ошибки
    scf
    ; Код ошибки "функция не реализована"
    ld a, 0xFF
    ret