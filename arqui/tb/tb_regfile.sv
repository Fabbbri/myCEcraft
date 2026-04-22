`timescale 1ns/1ps

module regfile_tb;

    // Señales
    logic clk;
    logic we;
    logic [4:0] rs1, rs2, rd;
    logic [31:0] wd;
    logic [31:0] rd1, rd2;

    // Instancia del DUT (Device Under Test)
    regfile uut (
        .clk(clk),
        .we_reg(we),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );

    // Clock: 10ns periodo
    always #5 clk = ~clk;

    // Task para mostrar estado
    task show;
        $display("T=%0t | we=%b rd=%0d wd=%0d | rs1=%0d rd1=%0d | rs2=%0d rd2=%0d",
                  $time, we, rd, wd, rs1, rd1, rs2, rd2);
    endtask

    initial begin
        $dumpfile("sim/waves/regfile_tb.vcd");
        $dumpvars(0, regfile_tb);

        // Inicialización
        clk = 0;
        we  = 0;
        rs1 = 0;
        rs2 = 0;
        rd  = 0;
        wd  = 0;

        #10;

        // =========================
        // TEST 1: Escritura básica
        // =========================
        $display("\nTEST 1: Escritura básica");
        rd = 1;
        wd = 32'd42;
        we = 1;
        #10; // flanco de reloj
        we = 0;

        rs1 = 1;
        #1;
        show();

        // =========================
        // TEST 2: Lectura doble
        // =========================
        $display("\nTEST 2: Lectura doble");
        rd = 2;
        wd = 32'd100;
        we = 1;
        #10;
        we = 0;

        rs1 = 1;
        rs2 = 2;
        #1;
        show();

        // =========================
        // TEST 3: Bypass
        // =========================
        $display("\nTEST 3: Bypass");
        rd  = 3;
        wd  = 32'd77;
        rs1 = 3; // leer mismo que escribo
        we  = 1;

        #1; // SIN esperar clock → bypass debería activarse
        show();

        #9; // completar ciclo
        we = 0;

        // =========================
        // TEST 4: Registro 0
        // =========================
        $display("\nTEST 4: Registro 0 (debe ser 0)");
        rd = 0;
        wd = 32'd999;
        we = 1;
        #10;
        we = 0;

        rs1 = 0;
        #1;
        show();

        // =========================
        // TEST 5: Varias escrituras
        // =========================
        $display("\nTEST 5: Varias escrituras");

        for (int i = 4; i < 8; i++) begin
            rd = i;
            wd = i * 10;
            we = 1;
            #10;
        end
        we = 0;

        // Leerlos
        for (int i = 4; i < 8; i++) begin
            rs1 = i;
            #1;
            show();
        end

        $display("\nFIN DEL TEST");
        #10;
        $finish;
    end

endmodule