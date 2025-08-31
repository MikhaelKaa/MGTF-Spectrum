; Тут скорее всего море ощибок...
; Макрос для сохранения полного контекста процессора
    MACRO SAVE_FULL_CTX
    push af
    push bc
    push de
    push hl
    push ix
    push iy
    ex af, af'
    push af
    exx
    push bc
    push de
    push hl
    ENDM

; Макрос для восстановления полного контекста процессора  
    MACRO RESTORE_FULL_CTX
    pop hl
    pop de
    pop bc
    pop af
    exx
    ex af, af'
    pop iy
    pop ix
    pop hl
    pop de
    pop bc
    pop af
    ENDM

; Макрос для сохранения базового контекста (только основных регистров)
    MACRO SAVE_BASIC_CTX
    push af
    push bc
    push de
    push hl
    ENDM

; Макрос для восстановления базового контекста
    MACRO RESTORE_BASIC_CTX
    pop hl
    pop de
    pop bc
    pop af
    ENDM
