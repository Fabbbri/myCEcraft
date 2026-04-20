module regfile (
    input  logic        clk, // reloj global
    input  logic        we,  // Write Enable (para reg)
    input  logic [3:0]  rs1, rs2, // Registros source
    input  logic [3:0]  rd, // Registro destino
    input  logic [31:0] wd, // Dato a escribir
    output logic [31:0] rd1, rd2 // Registros YA leídos
);

    // ----------------------------------------------------------
    // Logica Combinacional para lectura
    // ----------------------------------------------------------

    logic [31:0] regs [15:0]; // 16 registros de 32 bits

    // NO RESUELVE RAW
    assign rd1 = regs[rs1];
    assign rd2 = regs[rs2];

    // Lectura con bypass
    // assign rd1 = (we && rd == rs1) ? wd : regs[rs1];
    // assign rd2 = (we && rd == rs2) ? wd : regs[rs2];

    // ----------------------------------------------------------
    // Logica Secuencial para escritura
    // ----------------------------------------------------------

    always_ff @(posedge clk) begin
        if (we && rd != 0) // si WE =1 y rd es distinto de 0 (en x0 no se escribe)
            regs[rd] <= wd;
    end

    // Inicialización
    initial begin
        for (int i = 0; i < 16; i++)
            regs[i] = 0; // inicializa TODOS los registros en 0. x0 se mantiene en 0 siempre
    end

endmodule