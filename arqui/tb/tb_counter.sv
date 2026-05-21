`timescale 1ns/1ps

module tb_counter;

    // Señales
    logic clk   = 0;
    logic reset = 1;
    logic en = 0;
    logic [3:0] count;

    // Instancia 
    counter #(.MAX(9)) dut (
        .clk(clk),
        .reset(reset),
        .en(en),
        .count(count)
    );

    // 100 MHz 
    always #5 clk = ~clk;

    // display 
    task show;
        $display("T=%0t | clk=%b reset=%b en=%b | count=%0d",
                  $time, clk, reset, en, count);
    endtask

    initial begin
        $dumpfile("tb_counter.vcd");
        $dumpvars(0, tb_counter);

        //  Reset activo 
        $display("\nReset activo");
        #1; show();

        // Liberar reset, en=0 no debe contar
        $display("\nReset liberado, en=0 (no debe contar)");
        #10; reset = 0;
        #1; show();

        // Habilitar conteo 
        $display("\n en=1, debe contar hasta 9 ");
        en = 1;
        repeat(10) begin
            @(posedge clk); #1;
            show();
        end

        $display("\n en=0, count debe congelarse");
        reset = 1;
        @(posedge clk); #1;
        reset = 0;
        en = 1;
        repeat(3) begin
            @(posedge clk); #1;
            show();
        end
        en = 0;
        $display("en=0 aqui, count debe congelarse");
        repeat(3) begin
            @(posedge clk); #1;
            show();
        end
        en = 1;
        $display("en=1 aqui, count debe seguir");
        repeat(3) begin
            @(posedge clk); #1;
            show();
        end

        // Reset en medio del conteo 
        $display("\n Reset en medio del conteo");
        reset = 1;
        @(posedge clk); #1;
        show();
        reset = 0;
        $display("reset, debe arrancar desde 0");
        repeat(3) begin
            @(posedge clk); #1;
            show();
        end

        $finish;
    end

endmodule