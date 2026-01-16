// `timescale 1ns/1ns

module tb;
    `include "../tb/i2c_task.v"
    // Signals
    reg clk_i2c, clk;
    reg sda_drive;   // master điều khiển SDA
    wire SDA_bus;        // SDA line (pull-up)
    // Pull-up giả lập bus
    pullup(SDA_bus);
    
    wire SCL_bus;
    pullup(SCL_bus);
    reg int_sig;
    reg rst;
    
    integer error;
    localparam 
        I2C_PCF8575_FIST_4B_SLAVE_ADDR = 4'b0100,
        I2C_PCF8575_SET_3B = 3'b000,
        I2C_PCF8575_SLAVE_ADDR = {I2C_PCF8575_FIST_4B_SLAVE_ADDR,I2C_PCF8575_SET_3B};
    // DUT instance


    wire rst_n;
    assign rst_n = ~rst;
    reg [2:0] addr;
    reg [15:0] wdata;
    wire [15:0]  rdata;

    pcf8575 u_pcf8575 (
        .clk        (clk_i2c),
        .rst_n      (rst_n),

        .addr       (addr),
        .wdata      (wdata),
        .rdata      (rdata),

        .SDA_bus    (SDA_bus),
        .SCL_bus    (SCL_bus),
        .int_sig    (int_sig)
    );


    // Dump waveform ra file VCD
    initial begin
    `ifdef WAVE
        $display("=== DUMP NORMAL VCD ===");
        $dumpfile("dump.vcd");
        $dumpvars(0,tb.u_pcf8575);
    `elsif DEC
        $display("=== DUMP DEC VCD ===");
        $dumpfile("dump_dec.vcd");
        $dumpvars(0,
            tb.SDA_bus,
            tb.SCL_bus
        );
    `endif
    end

    // Kết nối SDA: master có thể drive low hoặc nhả ra
    assign SDA_bus = (sda_drive) ? 1'b0 :  1'bz;

    // Clock 100 MHz
    initial begin
        clk_i2c = 0;
        forever #100 clk_i2c = ~clk_i2c;  // 100 MHz
    end

    // Test sequence
    initial begin
        // Initialize
        rst = 1;
        addr = 0;
        int_sig = 0;
        sda_drive = 0 ;
        wdata = 0;
        #2;
        rst = 0;
        #10;

        $display("run test");
        wdata = 16'hf55f;
        $display("Set wdata = 16'h%h", wdata);
        #10;
        pcf8575_slave_handle_write();
        #120;

        int_sig = 1;
        pcf8575_slave_handle_read(16'hffff);
        int_sig = 0;
        $display("Read rdata = 16'h%h", rdata);
        #120;
        $finish;
    end

    initial begin
        #1000000;
        $finish;
    end

endmodule
