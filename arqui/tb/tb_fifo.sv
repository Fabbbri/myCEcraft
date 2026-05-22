`timescale 1ns/1ps

module tb_fifo;

    logic clk   = 0;
    logic reset = 1;
    logic [7:0] data_in = 0;
    logic wr_en = 0;
    logic rd_en = 0;
    logic [7:0] data_out;
    logic full;
    logic empty;

    always #5 clk = ~clk;

    fifo #(.WIDTH(8), .DEPTH(4)) uut (
        .clk (clk),
        .reset(reset),
        .data_in (data_in),
        .wr_en (wr_en),
        .rd_en (rd_en),
        .data_out(data_out),
        .full (full),
        .empty (empty)
    );

    task show;
        $display("T=%0t | wr_en=%b rd_en=%b | data_in=0x%02X data_out=0x%02X | full=%b empty=%b",
                  $time, wr_en, rd_en, data_in, data_out, full, empty);
    endtask

    initial begin
        $dumpfile("tb_fifo.vcd");
        $dumpvars(0, tb_fifo);

        #10; reset = 0;

    
        // estado inicial
    
        $display("\n--- Estado inicial ---");
        #1; show();

    
        // escribir AA
    
        $display("\n--- Escribir 0xAA ---");
        data_in = 8'hAA; wr_en = 1;
        @(posedge clk); #1; wr_en = 0;
        show();

    
        // escribir BB
    
        $display("\n--- Escribir 0xBB ---");
        data_in = 8'hBB; wr_en = 1;
        @(posedge clk); #1; wr_en = 0;
        show();

    
        // escribir CC
        $display("\n--- Escribir 0xCC ---");
        data_in = 8'hCC; wr_en = 1;
        @(posedge clk); #1; wr_en = 0;
        show();

    
        // escribir DD - llena el FIFO
        $display("\n--- Escribir 0xDD (FIFO lleno) ---");
        data_in = 8'hDD; wr_en = 1;
        @(posedge clk); #1; wr_en = 0;
        show();

    
        // escribir con full 
        $display("\n--- Escribir 0xFF con full=1 (debe ignorarse) ---");
        data_in = 8'hFF; wr_en = 1;
        @(posedge clk); #1; wr_en = 0;
        show();

    
        // leer AA
        $display("\n--- Leer (esperado 0xAA) ---");
        rd_en = 1; #1; show();
        @(posedge clk); #1; rd_en = 0;

    
        // leer BB
        $display("\n--- Leer (esperado 0xBB) ---");
        rd_en = 1; #1; show();
        @(posedge clk); #1; rd_en = 0;

    
        // leer CC
        $display("\n--- Leer (esperado 0xCC) ---");
        rd_en = 1; #1; show();
        @(posedge clk); #1; rd_en = 0;

    
        // leer DD - vacía el FIFO
        $display("\n--- Leer (esperado 0xDD, FIFO queda vacio) ---");
        rd_en = 1; #1; show();
        @(posedge clk); #1; rd_en = 0;
        show();

    
        // leer con empty 
        $display("\n--- Leer con empty=1 (debe ignorarse) ---");
        rd_en = 1;
        @(posedge clk); #1; rd_en = 0;
        show();

    
        // reset 
        $display("\n--- Escribir 0x11 y 0x22, luego reset ---");
        data_in = 8'h11; wr_en = 1; @(posedge clk); #1; wr_en = 0;
        data_in = 8'h22; wr_en = 1; @(posedge clk); #1; wr_en = 0;
        $display("Antes del reset:");
        show();
        reset = 1; @(posedge clk); #1; reset = 0;
        $display("Despues del reset:");
        show();
        $finish;
    end

endmodule