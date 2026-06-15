`timescale 1ns/1ps

module tb_clk_divider;

    logic clk = 0;
    logic reset = 1;
    logic clkdiv;

    always #5 clk = ~clk;

    clk_divider uut (
        .clk (clk),
        .reset (reset),
        .clkdiv (clkdiv)
    );

    task show;
        $display("T=%0t | clk=%b reset=%b | clkdiv=%b",
                  $time, clk, reset, clkdiv);
    endtask

    // medir período de clkdiv en ciclos de clk
    integer last_rise_cycle = 0;
    integer cycle = 0;

    always @(posedge clk) cycle = cycle + 1;

    always @(posedge clkdiv) begin
        if (last_rise_cycle != 0)
            $display("T=%0t | periodo clkdiv = %0d ciclos clk",
                      $time, cycle - last_rise_cycle);
        last_rise_cycle = cycle;
    end

    initial begin
        $dumpfile("tb_clk_divider.vcd");
        $dumpvars(0, tb_clk_divider);


        // estado inicial con reset

        $display("\n--- Reset activo ---");
        #1; show();


        // liberar reset
        $display("\n--- Liberar reset, clkdiv debe alternar ---");
        #10; reset = 0;
        #1; show();


        // observar varios ciclos
        $display("\n--- Alternancia clkdiv (100MHz -> 50MHz) ---");
        repeat(8) begin
            @(posedge clk); #1;
            show();
        end


        // reset
        $display("\n--- Reset (clkdiv vuelve a 0) ---");
        reset = 1;
        @(posedge clk);
        show();
        $finish;
    end

endmodule