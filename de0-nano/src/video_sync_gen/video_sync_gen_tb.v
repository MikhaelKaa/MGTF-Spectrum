`timescale 1ns/1ns

module video_sync_gen_tb;
    reg clk;
    reg reset;
    wire h_sync;
    wire v_sync;
    wire [10:0] x_pos;
    wire [10:0] y_pos;
    wire active_video;
    
    // Параметры для проверки
    parameter CLK_PERIOD = 71.4; // 14 MHz период (71.4 нс)
    parameter SIM_TIME = 50000000; // 50 мс симуляции
    
    // Instantiate the module
    video_sync_gen uut (
        .clk(clk),
        .reset(reset),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .x_pos(x_pos),
        .y_pos(y_pos),
        .active_video(active_video)
    );
    
    // Generate clock
    always begin
        clk = 0;
        #(CLK_PERIOD/2);
        clk = 1;
        #(CLK_PERIOD/2);
    end
    
    // Initialize and apply reset
    initial begin
        // Initialize signals
        reset = 1;
        
        // Open VCD file for waveform dumping
        $dumpfile("video_sync.vcd");
        $dumpvars(0, video_sync_gen_tb);
        
        // Release reset after a few clocks
        #(CLK_PERIOD * 10);
        reset = 0;
        
        // Run simulation for specified time
        #(SIM_TIME);
        
        $display("Simulation completed");
        $finish;
    end
    
    // Monitor for debugging
    integer frame_count = 0;
    integer last_v_counter = 0;
    
    always @(posedge clk) begin
        if (uut.pixel_clock) begin
            // Count frames
            if (uut.v_counter == 0 && uut.h_counter == 0) begin
                frame_count = frame_count + 1;
                $display("Frame %0d started at time %0t ns", frame_count, $time);
            end
            
            // Display active video pixels
            if (active_video) begin
                // $display("Active pixel: X=%0d, Y=%0d at time %0t ns", x_pos, y_pos, $time);
            end
            
            // Check for end of simulation
            if (frame_count >= 3) begin // Simulate 2 full frames
                $display("Simulated 3 full frames, ending simulation");
                $finish;
            end
        end
    end
    
endmodule