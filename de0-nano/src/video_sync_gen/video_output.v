module video_output_controller (
    input wire clk,               // Тактовый сигнал (14 MHz)
    input wire reset,             // Сброс (активный высокий уровень)
    
    // Линейные координаты от синхрогенератора
    input wire [14:0] pix_pos,
    
    // Синхросигналы
    input wire h_sync,
    input wire v_sync,
    input wire active_video,
    
    // Интерфейс с памятью
    output reg [15:0] mem_addr,   // Адрес для чтения из памяти
    input wire [7:0] mem_data,    // Данные из памяти (1 байт = 2 пикселя)
    output reg mem_read,          // Сигнал чтения памяти
    
    // Управление буферизацией
    input wire buffer_switch,     // Сигнал переключения буфера
    output reg current_buffer,    // Текущий отображаемый буфер (0 или 1)
    
    // Выходные сигналы
    output reg [3:0] rgbi,        // Выход RGBI (R, G, B, I)
    output reg h_sync_out,        // Синхросигналы с задержкой
    output reg v_sync_out,
    output reg active_video_out   // Флаг активной области с задержкой
);

// Параметры
parameter H_ACTIVE = 320;         // Активная область по горизонтали
parameter V_ACTIVE = 200;         // Активная область по вертикали
parameter BUFFER_SIZE = 32768;    // Размер одного буфера (32 КБ)

// Внутренние регистры
reg [15:0] base_addr;             // Базовый адрес текущего буфера
reg [7:0] pixel_data;             // Защелкнутые данные пикселя
reg pixel_selector;               // Выбор пикселя в байте
reg [1:0] pipeline_stage;         // Конвейерная задержка

// Выбор текущего буфера
always @(posedge clk or posedge reset) begin
    if (reset) begin
        current_buffer <= 0;
        base_addr <= 0;
    end else if (buffer_switch) begin
        current_buffer <= ~current_buffer;
        base_addr <= current_buffer ? BUFFER_SIZE : 0;
    end
end

// Вычисление адреса памяти
wire [15:0] pixel_address;
assign pixel_address = base_addr + pix_pos[14:1]; // Деление на 2 для байтовой адресации

// Чтение из памяти
always @(posedge clk or posedge reset) begin
    if (reset) begin
        mem_addr <= 0;
        mem_read <= 0;
        pixel_selector <= 0;
    end else begin
        // Читаем память только в активной области
        if (active_video) begin
            mem_addr <= pixel_address;
            mem_read <= 1;
            pixel_selector <= pix_pos[0]; // Младший бит определяет пиксель в байте
        end else begin
            mem_read <= 0;
        end
    end
end

// Защелкивание данных и формирование выходного сигнала
always @(posedge clk or posedge reset) begin
    if (reset) begin
        pixel_data <= 0;
        rgbi <= 0;
        h_sync_out <= 0;
        v_sync_out <= 0;
        active_video_out <= 0;
        pipeline_stage <= 0;
    end else begin
        // Конвейерная задержка для синхронизации
        pipeline_stage <= {pipeline_stage[0], active_video};
        
        // Защелкиваем данные из памяти
        if (mem_read) begin
            pixel_data <= mem_data;
        end
        
        // Формируем выход RGBI
        if (pipeline_stage[1]) begin
            // Выбираем нужные 4 бита из байта
            rgbi <= pixel_selector ? pixel_data[3:0] : pixel_data[7:4];
        end else begin
            rgbi <= 0; // Черный цвет вне активной области
        end
        
        // Задержка синхросигналов для согласования с конвейером
        h_sync_out <= h_sync;
        v_sync_out <= v_sync;
        active_video_out <= pipeline_stage[1];
    end
end

endmodule