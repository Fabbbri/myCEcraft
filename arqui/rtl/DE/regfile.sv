module regfile (
    input  logic        clk, // reloj global
    input  logic        we_reg,  // Write Enable (para reg)
    input  logic [4:0]  rs1, rs2, // Registros source
    input  logic [4:0]  rd, // Registro destino
    input  logic [31:0] wd, // Dato a escribir
    output logic [31:0] rd1, rd2 // Registros YA leídos
);

    // ----------------------------------------------------------
    // Logica Combinacional para lectura
    // ----------------------------------------------------------

    logic [31:0] regs [31:0]; // 32 registros de 32 bits

    // Lectura con bypass NO RESUELVE RAW
    // (condicion) ? 1 : 0
    // Si se cumple que WE=1 AND rd es igual a rs1 (RAW en el mismo ciclo),
    // entonces se toma wd

    assign rd1 = (we_reg && rd == rs1) ? wd : regs[rs1];
    assign rd2 = (we_reg && rd == rs2) ? wd : regs[rs2];

    // ----------------------------------------------------------
    // Logica Secuencial para escritura
    // ----------------------------------------------------------

    always_ff @(posedge clk) begin
        if (we_reg && rd != 0) // si WE =1 y rd es distinto de 0 (en x0 no se escribe)
            regs[rd] <= wd;
    end

    // Inicialización
    initial begin
        for (int i = 0; i < 32; i++)
            regs[i] = 0; // inicializa TODOS los registros en 0. x0 se mantiene en 0 siempre
    end

endmodule