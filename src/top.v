module top (
    input wire clk_27Mhz, rst,
    input wire int_sig,
    inout wire SDA_bus,
    inout wire SCL_bus
);

    wire clk_800Khz;
    wire rst_n;
    assign rst_n = ~rst;

    wire [15:0] wdata;
    wire [15:0] rdata;


//   assign clk_800Khz = clk_27Mhz;
      pll_24Mhz_800Khz your_instance_name(
          .clkout(), //output clkout
          .clkoutd(clk_800Khz), //output clkoutd
          .reset(rst), //input reset
          .clkin(clk_27Mhz) //input clkin
      );

//       assign wdata = 16'hf55f;
     shift_1s u_shift_1s (
         .clk   (clk_800Khz),
         .rst_n (rst_n),
         .wdata (wdata)
     );

//    always @(posedge clk_800Khz, negedge rst_n) begin
//        if(!rst_n) wdata <= 0;
//        else wdata <= {~rdata[7:0], 8'hFF};
//        else wdata <= {8'hff, 8'h00};
//    end
//    assign wdata = 16'h00ff;

    pcf8575 u_pcf8575 (
        .clk        (clk_800Khz),
        .rst_n      (rst_n),

        .addr       (3'b0),
        .wdata      (wdata),
        .rdata      (rdata),

        .SDA_bus    (SDA_bus),
        .SCL_bus    (SCL_bus),
        .int_sig    (int_sig)
    );


    
endmodule