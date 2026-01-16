module pcf8575 (
    input wire clk, rst_n,

    input wire [2:0] addr,
    input wire wr_en, rd_en,
    input wire [15:0] wdata,
    output wire [15:0] rdata,

    inout wire SDA_bus,
    inout wire SCL_bus,
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
    reg sda_shift_out_drive, sda_fsm_drive;
    assign SDA_bus = (sda_shift_out_drive || sda_fsm_drive)?  1'b0 : 1'bz;

    reg [2:0] data_shift_count;

    reg write_shift_start, write_shift_busy;
    reg shift_state;
    localparam  ST_SHIFT_IDLE  = 1'b0,
                ST_SHIFT_START = 1'b1;

    //write
    always @(negedge clk , negedge rst_n ) begin
        if(!rst_n) begin
            sda_shift_out_drive <= 1'b0;
            data_shift_count <= 0;
            data_shift_out <= 0;
            write_shift_busy <= 0;
            shift_state <= ST_SHIFT_IDLE;
        end
        else begin
            case (shift_state)
                ST_SHIFT_IDLE :  begin
                    data_shift_count <= 0;
                    sda_shift_out_drive <= 0;
                    if(write_shift_start) begin
                        shift_state <= ST_SHIFT_START;
                        write_shift_busy <= 1'b1;
                    end
                    else begin
                        write_shift_busy <= 1'b0;
                    end 
                end

                ST_SHIFT_START :  begin
                    sda_shift_out_drive <= ~data_shift_out[3'd7-data_shift_count];
                    if (!scl_drive) begin
                        data_shift_count <= data_shift_count + 1'b1;
                        if(data_shift_count == 3'd7) begin
                            shift_state <= ST_SHIFT_IDLE;
                            data_shift_count <= 0;
                            write_shift_busy <= 1'b0;
                            sda_shift_out_drive <= 0;
                        end
                    end 
                    else  data_shift_count <= data_shift_count;

                    
                end

                default: ;
            endcase
        

        end
    end
        
    reg [3:0] state, next_state;
    reg data_byte_count;

    reg[15:0] wdata_sub_reg, rdata_sub_reg;
    wire write_update;
    assign write_update = 1'b1;
// assign write_update = (wdata_sub_reg != rdata_sub_reg));

    localparam
        ST_IDLE        = 4'd0,
        ST_START       = 4'd1,
        ST_SLAVE_ADDR  = 4'd2,
        ST_HALT = 4'd3,
        ST_ADDR_ACK    = 4'd4,
        ST_WRITE_DATA  = 4'd5,
        ST_WRITE_ACK   = 4'd6,
        ST_READ_DATA   = 4'd7,
        ST_READ_ACK    = 4'd8,
        ST_STOP        = 4'd9;


    always @(posedge clk , negedge rst_n) begin
        if(!rst_n)begin
            state <= ST_IDLE;
            wdata_sub_reg <= 0;
            rdata_sub_reg <= 0;
            sda_fsm_drive <= 1'b0;
            write_shift_start <= 0;
            data_shift_count <= 0;
            data_byte_count <= 0;
            scl_en <= 0;
        end
        else begin
            case (state)
                ST_IDLE: begin
                    if(write_update || int_sig) begin
                        state <= ST_START;
                        
                        sda_fsm_drive <= 0;
                    end
                    else begin
                        state <= ST_IDLE;
                        sda_fsm_drive <= 0;
                    end
                end 

                ST_START: begin
                    sda_fsm_drive <= 1;
                    scl_en <= 1;
                    state <= ST_SLAVE_ADDR;
                    
                end

                ST_SLAVE_ADDR:begin
                    write_shift_start <= 1;
                    sda_fsm_drive <= 0;
                    if(!write_shift_busy) begin
                        // if(data_byte_count == 1) begin
                            
                            // data_byte_count <= 0;
                        // end
                        // else begin
                            // data_byte_count <= data_byte_count + 1'b1;
                            
                            state <= ST_ADDR_ACK;
                            if(write_update)   data_shift_out <= {I2C_PCF8575_FIST_4B_SLAVE_ADDR, addr, 1'b0};
                            else if(int_sig)   data_shift_out <= {I2C_PCF8575_FIST_4B_SLAVE_ADDR, addr, 1'b1};
                            else state <= ST_STOP;
                        // end
                    end
                    else begin
                        state <= ST_SLAVE_ADDR;
                        write_shift_start <= 0;
                        // write_shift_start <= 0;
                    end
                end

                ST_ADDR_ACK:begin
                    // if(SDA_bus) begin
                    //     state <= STOP;
                    // end
                    // else begin
                    if (scl_drive) begin
                        state <= ST_WRITE_DATA;
                    end
                        
                    // end
                end

                ST_WRITE_DATA:begin
                    write_shift_start <= 1;
                    if(!write_shift_busy ) begin
                        data_shift_out <= wdata[data_byte_count*8 +: 8];
                        // if (write_shift_start) 
                        state <= ST_WRITE_ACK;
                        // else state <= ST_WRITE_DATA;
                    end
                    else begin
                        state <= ST_WRITE_DATA;
                        write_shift_start <= 0;
                    end
                end

                ST_WRITE_ACK: begin
                    if (scl_drive) begin
                        // if(SDA_bus) begin
                        //     state <= ST_STOP;
                        // end
                        // else begin
                            if(data_byte_count == 1) begin
                                state <= ST_STOP;
                                data_byte_count <= 0;
                                write_shift_start <= 0;
                            end
                            else begin
                                state <= ST_WRITE_DATA;
                                data_byte_count <= data_byte_count + 1'b1;
                            end
                        // end
                    end
                end
                    
                ST_STOP:begin
                    if(!write_shift_busy) begin
                        sda_fsm_drive <= 1;
                        state <= ST_HALT;
                    end
                    else begin
                        sda_fsm_drive <= 0;
                    end
                    
                    // state <= ST_IDLE;
                end    

                ST_HALT: begin
                    state <= ST_HALT;
                    sda_fsm_drive <= 0;

                    wdata_sub_reg <= 0;
                    rdata_sub_reg <= 0;
                    sda_fsm_drive <= 1'b0;
                    write_shift_start <= 0;
                    data_shift_count <= 0;
                    data_byte_count <= 0;
                    scl_en <= 0;
                end 
                

                default: ;
            endcase
        end
    end


    
endmodule