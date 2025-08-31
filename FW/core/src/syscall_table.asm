; Таблица системных вызовов
    ; db "syscall_table"
syscall_table:
    dw sys_open     ; 0 - открытие файла
    dw sys_close    ; 1 - закрытие файла
    dw sys_read     ; 2 - чтение из файла
    dw sys_write    ; 3 - запись в файл
    dw sys_seek     ; 4 - перемещение в файле
    dw sys_stat     ; 5 - информация о файле
    dw sys_unimpl   ; 6 - не реализовано
    dw sys_unimpl   ; 7 - не реализовано
    dw sys_unimpl   ; 8 - не реализовано
    dw sys_unimpl   ; 9 - не реализовано
    dw sys_fork     ; 10 - создание процесса
    dw sys_exit     ; 11 - завершение процесса
    dw sys_wait     ; 12 - ожидание процесса
    dw sys_exec     ; 13 - запуск программы
    dw sys_getpid   ; 14 - получить ID процесса
    dw sys_unimpl   ; 15 - не реализовано
    dw sys_unimpl   ; 16 - не реализовано
    dw sys_unimpl   ; 17 - не реализовано
    dw sys_unimpl   ; 18 - не реализовано
    dw sys_unimpl   ; 19 - не реализовано
    dw sys_brk      ; 20 - управление памятью
    dw sys_unimpl   ; 21 - не реализовано
    dw sys_unimpl   ; 22 - не реализовано
    dw sys_unimpl   ; 23 - не реализовано
    dw sys_unimpl   ; 24 - не реализовано
    dw sys_print    ; 25 - печать на экран
    dw sys_unimpl   ; 26 - не реализовано
    dw sys_unimpl   ; 27 - не реализовано
    dw sys_unimpl   ; 28 - не реализовано
    dw sys_unimpl   ; 29 - не реализовано
    dw sys_unimpl   ; 30 - не реализовано
    dw sys_unimpl   ; 31 - не реализовано