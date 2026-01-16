module pcf8575 (
    input wire clk, rst_n,

    input wire [2:0] addr,
    input wire [15:0] wdata,
    output reg [15:0] rdata,

    inout wire SDA_bus,
    output wire SCL_bus,
    input wire int_sig
);

    localparam I2C_PCF8575_FIST_4B_SLAVE_ADDR = 4'b0100;

    reg scl_en, scl_drive;
    assign SCL_bus = (scl_drive)? 1'b0: 1'bz;

    always @(posedge clk , negedge rst_n) begin
        if(!rst_n) scl_drive <= 1'b0;
        else if (scl_en) scl_drive <= ~scl_drive;
        else scl_drive <= 1'b0;
    end

    
    
    reg [7:0] data_shift_out;
    reg sda_fsm_drive;
    assign SDA_bus = (sda_fsm_drive)? 1'b0: 1'bz;
    reg [4:0] data_shift_count;
        
    reg [3:0] state, next_state;

    reg[15:0] wdata_sub_reg, rdata_sub_reg;
    reg write_update;
    // assign write_update = (wdata_sub_reg != rdata_sub_reg);

    localparam
        ST_IDLE        = 4'd0,
        ST_START       = 4'd1,
        ST_SLAVE_ADDR  = 4'd2,
        ST_ADDR_ACK    = 4'd4,
        ST_WRITE_DATA  = 4'd5,
        ST_WRITE_ACK   = 4'd6,
        ST_READ_DATA   = 4'd7,
        ST_READ_ACK    = 4'd8,
        ST_STOP        = 4'd9;


    always @(negedge clk , negedge rst_n) begin
        if(!rst_n)begin
            state <= ST_IDLE;
            wdata_sub_reg <= 16'h0;
            rdata_sub_reg <= 0;
            data_shift_count <= 0;
            scl_en <= 0;
            sda_fsm_drive <= 0;
            write_update = 1'b0;
            rdata <= 0;
        end
        else begin
            case (state)
                ST_IDLE: begin
                    write_update <= (wdata_sub_reg != wdata);
                    // write_update <= 0;
                    sda_fsm_drive <= 0;
                    data_shift_count <= 0;
                    scl_en <= 0;
                    sda_fsm_drive <= 0;

                    if(write_update || !int_sig) begin
                        state <= ST_START;
                    end
                    else begin
                        state <= ST_IDLE;
                    end
                end 

                ST_START: begin
                    sda_fsm_drive <= 1;
                    scl_en <= 1;
                    state <= ST_SLAVE_ADDR;
                    data_shift_count <= 0;
                end

                ST_SLAVE_ADDR:begin
                    sda_fsm_drive <= 0;
                    if(data_shift_count <= 4'd3) sda_fsm_drive <= ~I2C_PCF8575_FIST_4B_SLAVE_ADDR[3'd3-data_shift_count[2:0]];
                    else if(data_shift_count <= 4'd6) sda_fsm_drive <= ~addr[3'd6-data_shift_count[2:0]];
                    else begin
                        if(write_update)        sda_fsm_drive <=  ~(1'b0);
                        else                    sda_fsm_drive <=  ~(1'b1);
                    end

                    if(!scl_drive)begin
                        data_shift_count <= data_shift_count +1'b1;
                    end
                    else data_shift_count <= data_shift_count ;
                    
                    if(data_shift_count <= 4'd7)begin
                        state <= ST_SLAVE_ADDR;
                    end
                    else begin
                        sda_fsm_drive <= 0;
                        state <= ST_ADDR_ACK;
                        // write_shift_start <= 0;
                    end
                end

                ST_ADDR_ACK:begin
                    if (!scl_drive) begin
                        if(SDA_bus) begin
                            state <= ST_STOP;
                        end
                        else begin
                            sda_fsm_drive <= 0;
                            data_shift_count <= 0;
                            if(write_update)  begin
                                state <= ST_WRITE_DATA;
                                wdata_sub_reg <= wdata;
                                data_shift_count <= 5'd17;
                            end
                            else if(!int_sig)    state <= ST_READ_DATA;
                            else state <= ST_STOP;
                            
                        end
                    end
                    else state <= ST_ADDR_ACK;
                end

                ST_WRITE_DATA: begin
                    // Mặc định drive SDA
                    sda_fsm_drive <= 1'b0;
                    // Byte thấp: count 17 -> 10 (bit 7 -> 0)
                    if (data_shift_count <= 5'd17 && data_shift_count >= 5'd10)
                        sda_fsm_drive <= ~wdata_sub_reg[data_shift_count - 5'd10];

                    // Byte cao: count 8 -> 1 (bit 15 -> 8)
                    else if (data_shift_count <= 5'd8 && data_shift_count >= 5'd1)
                        sda_fsm_drive <= ~wdata_sub_reg[data_shift_count + 5'd7];

                    // Truyền dữ liệu khi SCL = 0
                    if (!scl_drive) begin
                        data_shift_count <= data_shift_count - 1'b1;
                    end
                    else data_shift_count <= data_shift_count ;

                    // Hết 1 byte → sang ACK
                    if (data_shift_count == 5'd9 || data_shift_count == 5'd0) begin
                        sda_fsm_drive <= 1'b0; // nhả SDA
                        state <= ST_WRITE_ACK;
                    end
                    else begin
                        state <= ST_WRITE_DATA;
                    end
                end


                ST_WRITE_ACK: begin
                    sda_fsm_drive <= 1'b0; // nhả SDA để slave ACK

                    if (!scl_drive) begin
                        // Sau ACK byte thấp → gửi byte cao
                        if (data_shift_count == 5'd9) begin
                            data_shift_count <= 5'd8;
                            state <= ST_WRITE_DATA;
                        end
                        // Sau ACK byte cao → STOP
                        else if (data_shift_count == 5'd0) begin
                            state <= ST_STOP;
                            scl_en <= 1'b1;
                            sda_fsm_drive <= 1'b0;
                        end
                    end
                    else begin
                        state <= ST_WRITE_ACK;
                    end
                end


                ST_READ_DATA:begin
                    sda_fsm_drive <= 0;
                    if(!scl_drive)begin
                        data_shift_count <= data_shift_count +1'b1;
                        if(data_shift_count < 5'd8)   rdata_sub_reg <= {rdata_sub_reg[15:8],rdata_sub_reg[6:0],SDA_bus};
                        else if(data_shift_count < 5'd17)   rdata_sub_reg <= {rdata_sub_reg[14:8],SDA_bus,rdata_sub_reg[7:0]};
                        else  rdata_sub_reg <= rdata_sub_reg;
                    end
                    else data_shift_count <= data_shift_count ;
                    
                    if(data_shift_count == 5'd8 || data_shift_count == 5'd17)begin
                        if(data_shift_count == 5'd17) rdata <= rdata_sub_reg;
                        state <= ST_READ_ACK;
                        if(data_shift_count == 5'd8) sda_fsm_drive <= 1;
                        else sda_fsm_drive <= 0;
                    end
                    else begin
                        state <= ST_READ_DATA;
                    end
                end

                ST_READ_ACK: begin
                    // sda_fsm_drive <= 1;
                    if (!scl_drive) begin
                         if(SDA_bus) begin
                             state <= ST_STOP;
                         end
                         else begin
                            if(data_shift_count <= 5'd8) state <= ST_READ_DATA;
                            else begin
                                sda_fsm_drive <= 0;
                                state <= ST_STOP;
                                rdata <= rdata_sub_reg;
                                scl_en <= 1;
                            end
                            data_shift_count <= data_shift_count +1'b1;
                         end
                    end
                    else state <= ST_READ_ACK;

                end
                    
                ST_STOP:begin
                    sda_fsm_drive <= 1;
                    if(!scl_drive) begin
                        sda_fsm_drive <= 0;
                        state <= ST_IDLE;
                        scl_en <= 0;
                        write_update <= 0;
                    end 
                    else begin 
                        scl_en <= 0;
                    end
                    
                end    
                

                default: ;
            endcase
        end
    end


    
endmodule