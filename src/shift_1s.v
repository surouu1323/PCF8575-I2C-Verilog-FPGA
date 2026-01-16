module shift_1s (
    input  wire        clk,      // 800 kHz
    input  wire        rst_n,
    output reg [15:0]  wdata
);

    // Counter đếm 1 giây
    reg [19:0] cnt;   // 2^20 = 1,048,576 > 800,000

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt   <= 20'd0;
            wdata <= 16'h00FF;      // initial value
        end else begin
            if (cnt == 20'd49_999) begin
                cnt <= 20'd0;

                // SHIFT VÒNG TRÁI 1 BIT
                wdata <= {wdata[14:0], wdata[15]};
            end else begin
                cnt <= cnt + 1'b1;
            end
        end
    end

endmodule
