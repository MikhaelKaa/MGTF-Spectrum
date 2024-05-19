module epm3512_igp_orig (
    // Main Clock
    input 	CLK_14MHZ,

    // CPU signals
    input 	CPU_IORQ,
    input 	CPU_MREQ,
    input 	CPU_WR,
    input 	CPU_RD,
    input 	CPU_M1,
    input 	CPU_RFSH,
    input 	CPU_RESET,

    output 	CPU_CLK,
    output 	CPU_INT,
    output 	CPU_BUSRQ,
    output 	CPU_WAIT,
    output 	CPU_NMI,
    
    // CPU address & data
    inout  [7:0] D,	
    input [15:0] A,
    
    // BBSRAM
    output BBSRAM_RD,
    output BBSRAM_WR,
    output BBSRAM_MREQ,

    // Main RAM 1024k
    output WR_RAM,
    output CS_RAM1,
    output CS_RAM0,
    inout [7:0] MD,
    output [18:0]MA,
    
    // ROM
    output ROM_A14, // TODO: ROM_A_H[5],
    output ROM_A15,
    output ROM_A16,
    output ROM_A17,
    output ROM_A18,
    output WR_ROM,
    output RD_ROM,
    output CS_ROM,
    
    // Video output
    output [7:0]VGA, //TODO -2
    output HS,
    output VS,
    output SGI,
    
    // DOS
    output 	C_DOS,
    output 	C_IODOS,

    // 
    input 	C_IORQGE,
    output 	C_BLK,

    // ext ram 32k
    output [14:0]VA,
    inout [7:0]VD, // [5:0] ->> [7:0] ?
    output VWR,

    // Port FE
    output BEEP,
    output TAPE_OUT,
    input TAPE_IN,
    
    // Joystick select
    output RD_1F,

    // USB/PS2/SEGAGP controller
    input 	C_MAGIC,
    input 	C_PNT,
    input 	C_TURBO,
    // SPI 
    input 	KBD_DI,
    input 	KBD_CS,
    input 	KBD_CLK,

    // stm32 bluepill device
    input STM32_BUSRQ, 	// EXT0,
    input EXT1,				// RESET. The signal passes by. Disabling requires hardware modification of the hat, do not use this pin (signal) !
    
    // EXT pins.
    output EXT2,  // LED
    output EXT3

    // PSG
    //output AYCLK,
    //output BDIR,
    //output BC1,
);


assign ROM_A15 = 1'b0;
assign ROM_A16 = 1'b0;
assign ROM_A17 = 1'b0;
assign ROM_A18 = 1'b0;

assign CPU_BUSRQ 	= 1'b1;
assign CPU_WAIT 	= 1'b1;
assign CPU_NMI 	= 1'b1;

//
wire [1:0] cpu_a15a14 = {A[15], A[14]};
wire n_cpu_a_0000_3fff = ~(cpu_a15a14 == 2'b00);
wire n_cpu_a_4000_7fff = ~(cpu_a15a14 == 2'b01);
wire n_cpu_a_8000_bfff = ~(cpu_a15a14 == 2'b10);
wire n_cpu_a_c000_ffff = ~(cpu_a15a14 == 2'b11);

//
wire n_vcs_cpu = CPU_MREQ | n_cpu_a_0000_3fff;
wire n_vrd = ( (n_vcs_cpu == 0 && CPU_RD == 0) || screen_read == 1)? 1'b0 : 1'b1;
wire n_vwr = ( (n_vcs_cpu == 0 && CPU_WR == 0) && screen_read == 0)? 1'b0 : 1'b1;

//
wire cpu_or_dis = ~screen_read;


//  /********** ext RAM W24257AK-20 32kb ************/ 
// wire ext_ram_cs =  cpu_or_dis? (CPU_MREQ | ~(A[15] | A[14]))	:(n_vcs_cpu);// | (A == 16'h4005) ; // 4000
// wire ext_ram_rd =  cpu_or_dis? (CPU_RD   | ext_ram_cs)			:(n_vrd);
// wire ext_ram_wr =  cpu_or_dis? (CPU_WR   | ext_ram_cs)			:(n_vwr);
 
// assign VA  = cpu_or_dis? (A[14:0])									:(screen_addr);
// assign D   = cpu_or_dis? ((ext_ram_rd == 1'b0) ? VD : 8'bZ)	:(8'bZ);
// assign VD  = cpu_or_dis? ((ext_ram_wr == 1'b0) ? D  : 8'bZ)	:(8'bZ);
// assign VWR = cpu_or_dis? (ext_ram_wr)								:(1'b1);

assign VWR = 1'b1;
assign VD = 8'bz;
assign VA  = 15'bz;

/***************** RAM 1024k ********************/	
wire main_ram_cs =  cpu_or_dis? (CPU_MREQ | ~n_cpu_a_0000_3fff)	:(n_vcs_cpu);
wire main_ram_rd =  cpu_or_dis? (CPU_RD   | main_ram_cs)			:(n_vrd);
wire main_ram_wr =  cpu_or_dis? (CPU_WR   | main_ram_cs)			:(n_vwr);

assign MA = cpu_or_dis? ( {3'b1, A[15:0]}	)							:({3'b1, vbank, screen_addr});
assign D  = cpu_or_dis? ((main_ram_rd == 1'b0) ? MD : 8'bZ)		:(8'bZ);
assign MD = cpu_or_dis? ((main_ram_wr == 1'b0) ? D  : 8'bZ)		:(8'bZ);
assign WR_RAM  = cpu_or_dis? (main_ram_wr) :(1'b1);
assign CS_RAM0 = main_ram_cs;
assign CS_RAM1 = main_ram_cs;




wire n_romcs = CPU_MREQ | n_cpu_a_0000_3fff; // 0000

/* SCREEN CONTROLLER */
localparam H_AREA         = 256;
localparam V_AREA         = 192;
localparam SCREEN_DELAY   = 8;
localparam H_TOTAL        = 448;
localparam V_TOTAL        = 320;

reg [8:0] vc;
reg [9:0] hc0;
wire [8:0] hc = hc0[9:1];

wire hc0_reset = hc0 == (H_TOTAL<<1) - 1'b1 ;
wire vc_reset = vc == V_TOTAL - 1'b1 ;

always @(posedge CLK_14MHZ) begin
    if (hc0_reset) begin
        hc0 <= 0;
        if (vc_reset) begin
            vc <= 0;
        end
        else begin
            vc <= vc + 1'b1;
        end
    end 
    else begin
        hc0 <= hc0 + 1'b1;
    end
end

reg [4:0] blink_cnt;
wire blink = blink_cnt[4];
always @(posedge CPU_INT) begin
    blink_cnt <= blink_cnt + 1'b1;
end

reg [2:0] border;
reg [7:0] bitmap, attr, bitmap_next, attr_next;
wire pixel 			= bitmap[7];
wire attr_read 	= screen_read & ~hc0[0];
wire bitmap_read 	= screen_read & hc0[0];
wire [14:0] bitmap_addr = { 2'b10, vc[7:6], vc[2:0], vc[5:3], hc[7:3] };
wire [14:0] attr_addr 	= { 5'b10110, vc[7:3], hc[7:3] };
wire [14:0] screen_addr = bitmap_read? bitmap_addr : attr_addr;
wire screen_show 		= (vc < V_AREA) && (hc >= SCREEN_DELAY) && (hc < H_AREA + SCREEN_DELAY);
wire screen_update 	= (vc < V_AREA) && (hc < H_AREA) && hc0[3:0] == 4'b1111;
wire border_update 	= (hc0[3:0] == 4'b1111) || (screen_show == 0);

reg screen_read;
wire n_iorq0 = CPU_IORQ | screen_read;

always @(posedge CLK_14MHZ) begin
    screen_read <= CPU_MREQ == 1'b1 && CPU_IORQ == 1'b1;

    if (attr_read)
        attr_next 	<= MD;
    if (bitmap_read)
        bitmap_next 	<= MD;

    if (screen_update)
        attr <= attr_next;
    else if (border_update)
        attr[7:3] <= {2'b00, border};

    if (screen_update)
        bitmap <= {bitmap_next[7] ^ (attr_next[7] & blink), bitmap_next[6:0]};
    else if (hc0[0])
        bitmap <= {bitmap[6] ^ (attr[7] & blink), bitmap[5:0], 1'b0};
end


/* VIDEO OUTPUT */
// blank range: [320-400)
wire blank = (vc[7:4] == 4'b1111) || (hc[8:6] == 3'b101) || (hc[8:4] == 5'b11000);
reg g, r, b, i;
always @(posedge CLK_14MHZ) if (hc0[0]) begin
    if (blank)
        {g, r, b, i} = 4'b0000;
    else begin
        {g, r, b} = pixel? attr[2:0] : attr[5:3];
        i = (g | r | b) & attr[6];
    end
end

// hsync range: [328-360)
wire hsync0 = hc[8:5] == 4'b1010;
wire vsync0 = vc[7:3] == 5'b11111;
reg hsync1;
reg csync;
always @(posedge CLK_14MHZ) if (hc[3]) begin
    csync <= ~(vsync0 ^ hsync0);
    hsync1 <= ~hsync0;
end


/* INT GENERATOR */
reg cpu_interrupt;
assign CPU_INT = cpu_interrupt;
always @(posedge CLK_14MHZ)
    cpu_interrupt <= ~(vc == 239 && hc[8:6] == 3'b101);


/* CLOCK */
assign CPU_CLK = clkcpu;
wire clkcpu;
assign clkcpu = hc[0];


/* PORT #FE */
wire port_fe_cs = CPU_M1 == 1 && n_iorq0 == 0 && A[0] == 0;

wire [7:0] port_fe_data = {1'b1, /*tape_in*/1'b1, 1'b1, /*kd[4:0]*/5'b1};
reg port_fe_rd;
always @(posedge CLK_14MHZ)
    port_fe_rd <= port_fe_cs && CPU_RD == 0;

//reg tape_out0;
//assign tape_out = tape_in ^ tape_out0;
always @(posedge CLK_14MHZ or negedge CPU_RESET) begin
    if (!CPU_RESET) begin
        //beeper <= 0;
        //tape_out0 <= 0;
        border <= 0;
    end
    else if (port_fe_cs && CPU_WR == 0) begin
        //beeper <= xd[4];
        //tape_out0 <= xd[3];
        border <= D[2:0];
    end
end


/* PORT #7FFD */
wire port_7ffd_cs = CPU_M1 == 1 && n_iorq0 == 0 && A == 16'h7ffd;
reg [2:0] rambank;
reg rombank, vbank, lock_7ffd;
always @(posedge CLK_14MHZ or negedge CPU_RESET) begin
    if (!CPU_RESET) begin
        rambank 	<= 0;
        vbank 		<= 0;
        rombank 	<= 0;
        lock_7ffd <= 0;
    end
    else if (port_7ffd_cs && CPU_WR == 0 && lock_7ffd == 0) begin
        rambank 	<= D[2:0];
        vbank 		<= D[3];
        rombank 	<= D[4];
        lock_7ffd <= 0;//<= D[5];
    end
end

	// io
	// wire iowr = n_iorq0 | CPU_WR ;//| ~m1;
	// wire iord = n_iorq0 | CPU_RD ;//| ~m1;
	// // Port 0x7ffd
	// reg [7:0] port_0x7ffd = 8'b0;
	// // write 0x7ffd
	// always @(negedge iowr or negedge CPU_RESET) begin
	// 	if(!CPU_RESET) port_0x7ffd <= 8'b0;
	// 	else begin
	// 		if(A == 16'h7ffd) port_0x7ffd <= D;
	// 	end		
	// end
	// read 0x7ffd
	//assign D = (iord == 0 && A == 16'h7ffd)?(port_0x7ffd):(8'bz);


/* MEMORY CONTROLLER */
// 7ffe a15-14 va16-14
//  xxx   01     010   bank 2
//  xxx   10     101   bank 5
//  000   11     000   bank 0
//  001   11     001   bank 1 | contended
//  010   11     010   bank 2
//  011   11     011   bank 3 | contended
//  100   11     100   bank 4
//  101   11     101   bank 5 | contended (video)
//  110   11     110   bank 6
//  111   11     111   bank 7 | contended (video alt)
// 7ffe a15-14  ra14
//    0   00       0   rom0
//    1   00       1   rom1


/*
wire n_vcs_cpu = n_mreq | ~(a15 | a14);
assign n_vrd = ((n_vcs_cpu == 0 && n_rd == 0) || screen_read == 1)? 1'b0 : 1'b1;
assign n_vwr = ((n_vcs_cpu == 0 && n_wr == 0) && screen_read == 0)? 1'b0 : 1'b1;
assign n_romcs = n_mreq | a15 | a14;

assign ra14 = rombank;

assign va[16:0] = 
	screen_read? {1'b1, vbank, screen_addr} :
	a15 & a14? {rambank, {14{1'bz}}} :
	{a14, a15, a14, {14{1'bz}}};

assign vd[7:0] = 
	port_fe_rd? port_fe_data :
	n_iorq0 == 0 && (n_rd == 0 | n_m1 == 0)? {8{1'b1}} :
	{8{1'bz}};
*/


wire ra14;
assign ra14 = rombank;

//assign va[15:0] = 
    //screen_read? {1'b0, screen_addr} :
    //A[15:0];


assign SYNC = csync;
assign R = r;
assign G = g;
assign B = b;
assign I = i;


    wire R, G, B, I, SYNC;
    assign VGA = {1'b0, I, G, 1'b0, I, R, I, B};
    // Vertical sync
    
    assign VS = SYNC;
    // TODO: in Jasper this pin use to enable scart
    assign HS = 1'b1;
    // Not used.
    assign SGI = 1'b0;


endmodule