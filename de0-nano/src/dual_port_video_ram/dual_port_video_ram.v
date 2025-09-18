module dual_port_video_ram (
    input wire clk,
    // Порт записи (процессор)
    input wire [15:0] addr_a,
    input wire [7:0] data_a,
    input wire we_a,
    // Порт чтения (видеоконтроллер)
    input wire [15:0] addr_b,
    output reg [7:0] data_b
);

// Двухпортовая память
reg [7:0] memory [0:65535];

// Порт A (запись)
always @(posedge clk) begin
    if (we_a) begin
        memory[addr_a] <= data_a;
    end
end

// Порт B (чтение)
always @(posedge clk) begin
    data_b <= memory[addr_b];
end

endmodule