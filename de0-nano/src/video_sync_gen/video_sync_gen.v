module video_sync_gen (
    input wire clk,           // Тактовый сигнал 14 MHz
    input wire reset,         // Сброс (активный высокий уровень)
    output reg h_sync,        // Строчный синхроимпульс
    output reg v_sync,        // Кадровый синхроимпульс
    output reg [10:0] x_pos,  // Текущая координата X (пиксель)
    output reg [10:0] y_pos,  // Текущая координата Y (строка)
    output reg active_video   // Флаг активной зоны изображения
);

// Параметры горизонтальной развертки (центрированные)   
parameter H_ACTIVE  = 320;    // Активная область
parameter H_FP      = 32;     // Front porch 
parameter H_SYNC    = 33;     // Длительность синхроимпульса (4.7 мкс при 7 MHz)
parameter H_BP      = 63;     // Back porch
parameter H_TOTAL   = 448;    // Всего пикселей в строке

// Параметры вертикальной развертки (центрированные)
parameter V_ACTIVE  = 240;    // Активная область
parameter V_FP      = 36;     // Front porch
parameter V_SYNC    = 25;     // Длительность синхроимпульса
parameter V_BP      = 34;     // Back porch
parameter V_TOTAL   = 312;    // Всего строк в кадре
//parameter V_TOTAL   = 320;    // Всего строк в кадре


// Внутренние счетчики
reg [10:0] h_counter = 0;
reg [10:0] v_counter = 0;
reg pixel_clock = 0;          // Тактовый сигнал 7 MHz

// Делитель частоты 14 MHz -> 7 MHz
always @(posedge clk or posedge reset) begin
    if (reset) begin
        pixel_clock <= 0;
    end else begin
        pixel_clock <= ~pixel_clock;
    end
end

// Счетчик горизонтальной позиции (работает на 7 MHz)
always @(posedge clk or posedge reset) begin
    if (reset) begin
        h_counter <= 0;
    end else if (pixel_clock) begin  // Обновляем только при pixel_clock = 1
        if (h_counter == H_TOTAL - 1) begin
            h_counter <= 0;
        end else begin
            h_counter <= h_counter + 1;
        end
    end
end

// Счетчик вертикальной позиции (работает на 7 MHz)
always @(posedge clk or posedge reset) begin
    if (reset) begin
        v_counter <= 0;
    end else if (pixel_clock && h_counter == H_TOTAL - 1) begin
        if (v_counter == V_TOTAL - 1) begin
            v_counter <= 0;
        end else begin
            v_counter <= v_counter + 1;
        end
    end
end

// Генерация строчного синхроимпульса
always @(posedge clk or posedge reset) begin
    if (reset) begin
        h_sync <= 1;
    end else if (pixel_clock) begin
        // Активный низкий уровень в течение H_SYNC тактов
        h_sync <= !(h_counter < H_SYNC);
    end
end

// Генерация кадрового синхроимпульса
always @(posedge clk or posedge reset) begin
    if (reset) begin
        v_sync <= 1;
    end else if (pixel_clock) begin
        // Активный низкий уровень в течение V_SYNC строк
        v_sync <= !(v_counter < V_SYNC);
    end
end

// Генерация флага активной видеообласти
always @(posedge clk or posedge reset) begin
    if (reset) begin
        active_video <= 0;
    end else if (pixel_clock) begin
        active_video <= (h_counter >= H_SYNC + H_BP) && 
                       (h_counter < H_SYNC + H_BP + H_ACTIVE) &&
                       (v_counter >= V_SYNC + V_BP) && 
                       (v_counter < V_SYNC + V_BP + V_ACTIVE);
    end
end

// Вычисление координат пикселя
always @(posedge clk or posedge reset) begin
    if (reset) begin
        x_pos <= 0;
        y_pos <= 0;
    end else if (pixel_clock) begin
        // Вычисляем координаты только в активной области
        if (h_counter >= H_SYNC + H_BP && 
            h_counter < H_SYNC + H_BP + H_ACTIVE &&
            v_counter >= V_SYNC + V_BP && 
            v_counter < V_SYNC + V_BP + V_ACTIVE) begin
            x_pos <= h_counter - (H_SYNC + H_BP);
            y_pos <= v_counter - (V_SYNC + V_BP);
        end else begin
            x_pos <= 0;
            y_pos <= 0;
        end
    end
end

endmodule