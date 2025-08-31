; Обработчик системных вызовов
    ; db "syscall_handler"
syscall_handler:
    SAVE_FULL_CTX
    
    ; Вычисляем адрес обработчика
    ld hl, syscall_table
    add a, a        ; Умножаем A на 2 (A = номер вызова)
    ld e, a
    ld d, 0
    add hl, de      ; HL = адрес в таблице
    
    ; Загружаем адрес обработчика
    ld e, (hl)
    inc hl
    ld d, (hl)

    push hl
    ld hl, SCREEN_PIXELS+11
    ld(hl), 0x3
    pop hl

    ; Сохраняем адрес возврата и переходим к обработчику
    ld hl, .return
    push hl
    ex de, hl
    jp (hl)
.return:
    RESTORE_FULL_CTX
    ret



    

    
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

    push hl
    ld hl, SCREEN_PIXELS+12
    ld(hl), 0x5
    pop hl

    call print_string
    ret

; Заглушка для нереализованных системных вызовов
sys_unimpl:
    ; Устанавливаем флаг ошибки
    scf
    ; Код ошибки "функция не реализована"
    ld a, 0xFF
    ret