`timescale 1ns/1ps

module tb_data_ram;

    logic        clk;
    logic        we;
    logic [1:0]  size;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [31:0] rdata;

    data_ram dut (
        .clk(clk), .we_mem(we), .size(size),
        .addr(addr), .wdata(wdata), .rdata(rdata)
    );

    always #5 clk = ~clk;

    task automatic do_write(
        input [31:0] a,
        input [31:0] d,
        input [1:0]  s
    );
        @(posedge clk); #1;
        addr = a; wdata = d; size = s; we = 1;
        @(posedge clk); #1;
        we = 0;
        addr = 0; wdata = 0; size = 2'bxx; // neutral exit state
    endtask

    initial begin
        $dumpfile("sim/waves/tb_data_ram.vcd");
        $dumpvars(0, tb_data_ram);

        clk = 0; we = 0; size = 2'b10; addr = 0; wdata = 0;
        $display("🚀 Iniciando test de Data RAM...");
        #10;

        // TEST 1: SW + LW
        $display("\n🧪 TEST 1: SW + LW");
        do_write(32'h00000010, 32'h12345678, 2'b10);
        size = 2'b10; addr = 32'h00000010;
        if (rdata !== 32'h12345678)
            $error("❌ ERROR en LW: %h", rdata);
        else
            $display("✅ OK LW");

        // TEST 2: SB + LB positivo
        $display("\n🧪 TEST 2: SB + LB (positivo)");
        do_write(32'h00000020, 32'h0000007F, 2'b00);
        size = 2'b00; addr = 32'h00000020;
        if (rdata !== 32'h0000007F)
            $error("❌ ERROR en LB positivo: %h", rdata);
        else
            $display("✅ OK LB positivo");

        // TEST 3: SB + LB negativo
        $display("\n🧪 TEST 3: SB + LB (negativo)");
        do_write(32'h00000021, 32'h000000FF, 2'b00);
        size = 2'b00; addr = 32'h00000021;
        if (rdata !== 32'hFFFFFFFF)
            $error("❌ ERROR en LB negativo: %h", rdata);
        else
            $display("✅ OK LB negativo (sign extend)");

        // TEST 4: Endianness
        $display("\n🧪 TEST 4: Endianness");
        do_write(32'h00000030, 32'hAABBCCDD, 2'b10);
        size = 2'b00;
        #1; // let size settle
        addr = 32'h00000030; #1; if (rdata !== 32'hFFFFFFDD) $error("❌ Byte 0 incorrecto: %h", rdata);
        addr = 32'h00000031; #1; if (rdata !== 32'hFFFFFFCC) $error("❌ Byte 1 incorrecto: %h", rdata);
        addr = 32'h00000032; #1; if (rdata !== 32'hFFFFFFBB) $error("❌ Byte 2 incorrecto: %h", rdata);
        addr = 32'h00000033; #1; if (rdata !== 32'hFFFFFFAA) $error("❌ Byte 3 incorrecto: %h", rdata);
        $display("✅ OK Endianness (little endian)");

        // TEST 5: Sobrescritura parcial
        $display("\n🧪 TEST 5: SB sobre SW");
        do_write(32'h00000040, 32'h11223344, 2'b10);
        do_write(32'h00000041, 32'h000000FF, 2'b00);
        size = 2'b10; addr = 32'h00000040; #1;
        if (rdata !== 32'h1122FF44)
            $error("❌ ERROR en mezcla SB/SW: %h", rdata);
        else
            $display("✅ OK mezcla SB/SW");

        $display("\n🎉 TODOS LOS TESTS COMPLETADOS");
        #10; $finish;
    end

endmodule
