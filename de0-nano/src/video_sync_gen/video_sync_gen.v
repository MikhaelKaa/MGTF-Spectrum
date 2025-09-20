module video_sync_gen (
    input wire clk,           // Тактовый сигнал 14 MHz
    input wire reset,         // Сброс (активный высокий уровень)
    output reg h_sync,        // Строчный синхроимпульс
    output reg v_sync,        // Кадровый синхроимпульс
    output reg [14:0] pix_pos,  // Текущая координата пикселя
    output reg active_video   // Флаг активной зоны изображения
);

// Параметры горизонтальной развертки (центрированные)   
parameter H_ACTIVE  = 320;    // Активная область
parameter H_FP      = 32;     // Front porch 
parameter H_SYNC    = 33;     // Длительность синхроимпульса (4.7 мкс при 7 MHz)
parameter H_BP      = 63;     // Back porch
parameter H_TOTAL   = 448;    // Всего пикселей в строке

// Параметры вертикальной развертки (центрированные)
parameter V_ACTIVE  = 200;    // Активная область
parameter V_FP      = 46;     // Front porch
parameter V_SYNC    = 25;     // Длительность синхроимпульса
parameter V_BP      = 24;     // Back porch
parameter V_TOTAL   = 312;    // Всего строк в кадре

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
    end else if (pixel_clock) begin
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
        h_sync <= !(h_counter < H_SYNC);
    end
end

// Генерация кадрового синхроимпульса
always @(posedge clk or posedge reset) begin
    if (reset) begin
        v_sync <= 1;
    end else if (pixel_clock) begin
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
always @(posedge pixel_clock or posedge reset) begin
    if (reset) begin
        pix_pos <= 0;
    end else begin
        if (active_video) begin
            pix_pos <= pix_pos + 1'b1;
        end else begin
            if(~v_sync) begin
                pix_pos <= 0;
            end
        end
    end
end

endmodule