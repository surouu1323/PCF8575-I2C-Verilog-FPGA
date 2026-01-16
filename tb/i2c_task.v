// ==== SLAVE HANDLE WRITE (Master writes to PCF8575) ====
task pcf8575_slave_handle_write();
    integer rdata;
    begin
        $display("=====pcf8575_slave_handle_write=====");
        slave_wait_start();

        slave_receive_byte(rdata); // address + W

        if (rdata == {I2C_PCF8575_SLAVE_ADDR, 1'b0}) begin
            // Correct address + WRITE
            $display("[PCF8575] Address matched: 7'h%h, WRITE operation",rdata[7:1]);
            slave_send_ack(1);

            slave_receive_byte(rdata); // MSB
            slave_send_ack(1);

            slave_receive_byte(rdata); // LSB
            slave_send_ack(0);
        end
        else if (rdata[7:1] == I2C_PCF8575_SLAVE_ADDR) begin
            // Address correct but R/W bit wrong
            $display("[PCF8575] Address matched but R/W bit incorrect (Expected WRITE)");
            slave_send_ack(0); // optional NACK
        end
        else begin
            // Address incorrect
            $display("[PCF8575] Address mismatch (Wrong slave address)");
            slave_send_ack(0); // optional NACK
        end


        slave_wait_stop();
    end
endtask


// ==== SLAVE HANDLE READ (Master reads from PCF8575) ====
task pcf8575_slave_handle_read(
        input [15:0] data
    );
    integer rdata;
    integer master_ack;
    begin
        $display("=====pcf8575_slave_handle_read=====");
        master_ack = 0;
        slave_wait_start();

        slave_receive_byte(rdata); // address + R
        
        if (rdata == {I2C_PCF8575_SLAVE_ADDR, 1'b1}) begin
            // Correct address + READ
            $display("[PCF8575] Address matched: 7'h%h, READ operation",rdata[7:1]);
            slave_send_ack(1);

            slave_transmit_byte(data[15:8]); // MSB
            slave_check_master_ack(master_ack);

            if (master_ack) begin
                slave_transmit_byte(data[7:0]); // LSB
                slave_check_master_ack(master_ack);
            end
        end
        else if (rdata[7:1] == I2C_PCF8575_SLAVE_ADDR) begin
            // Address correct but R/W bit wrong
            $display("[PCF8575] Address matched but R/W bit incorrect (Expected READ)");
            slave_send_ack(0); // optional: NACK wrong direction
        end
        else begin
            // Address incorrect
            $display("[PCF8575] Address mismatch (Wrong slave address)");
            slave_send_ack(0); // optional
        end


        slave_wait_stop();
    end
endtask


// ==== WAIT START CONDITION ====
task slave_wait_start();
    reg detect;
    begin
        $display("[%0t] [PCF8575] Waiting for START condition", $time);
        detect = 0;
        while (!detect) begin
            @(negedge tb.SDA_bus);
            if (tb.SCL_bus === 1'b1) begin
                $display("[%0t] [PCF8575] START detected", $time);
                detect = 1;
            end
        end
    end
endtask


// ==== WAIT STOP CONDITION ====
task slave_wait_stop();
    reg detect;
    begin
        $display("[%0t] [PCF8575] Waiting for STOP condition", $time);
        detect = 0;
        while (!detect) begin
            @(posedge tb.SDA_bus);
            if (tb.SCL_bus === 1'b1) begin
                $display("[%0t] [PCF8575] STOP detected", $time);
                detect = 1;
            end
        end
    end
endtask


// ==== SLAVE RECEIVE BYTE FROM MASTER ====
task slave_receive_byte(output [7:0] data);
    integer i;
    begin
        tb.sda_drive = 0; // release SDA
        for (i = 8; i > 0; i = i - 1) begin
            @(posedge tb.SCL_bus)
                data[i-1] = tb.SDA_bus;
        end
        $display("[%0t] [PCF8575] Received byte: 0x%02h", $time, data);
    end
endtask


// ==== SLAVE TRANSMIT BYTE TO MASTER ====
task slave_transmit_byte(input [7:0] data);
    integer i;
    begin
        $display("[%0t] [PCF8575] Transmitting byte: 0x%02h", $time, data);
        for (i = 8; i > 0; i = i - 1) begin
            @(negedge tb.SCL_bus)
                tb.sda_drive = ~data[i-1];
        end
    end
endtask


// ==== SLAVE SEND ACK/NACK ====
task slave_send_ack(input ack);
    begin
        @(negedge tb.SCL_bus) tb.sda_drive = ack;
        if (ack)
            $display("[%0t] [PCF8575] Send ACK", $time);
        else
            $display("[%0t] [PCF8575] Send NACK", $time);
        @(negedge tb.SCL_bus) tb.sda_drive = 0; // release SDA
    end
endtask


// ==== SLAVE CHECK MASTER ACK ====
task slave_check_master_ack(output ack);
    begin
        @(negedge tb.SCL_bus) tb.sda_drive = 0;
        @(posedge tb.SCL_bus) ack = tb.sda_drive;

        if (ack)
            $display("[%0t] [PCF8575] Master ACK received", $time);
        else
            $display("[%0t] [PCF8575] Master NACK received", $time);
    end
endtask
