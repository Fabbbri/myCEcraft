module neather_regfile (
    input  logic        clk, // reloj global
    input  logic        we_regV,  // Write Enable (para reg Vault)
    input  logic [4:0]  rv2, // Registro source
    input  logic [4:0]  rdv, // Registro destino
    input  logic [31:0] wdV, // Dato a escribir

    output logic [31:0] rdv2 // Registro YA leídos
);

    // ----------------------------------------------------------
    // Logica Combinacional para lectura
    // ----------------------------------------------------------

    logic [31:0] regs [31:0]; // 32 registros de 32 bits

    // Registro READ
    // Lectura con bypass NO RESUELVE RAW
    // (condicion) ? 1 : 0
    // Si se cumple que WE=1 AND rd es igual a rs (RAW en el mismo ciclo),
    // entonces se toma wd

    assign rdv2 = (we_regV && rdv == rv2) ? wdV : regs[rv2];

    // ----------------------------------------------------------
    // Logica Secuencial para escritura
    // ----------------------------------------------------------

    always_ff @(posedge clk) begin
        if (we_regV) // si WE =1 y rdestino es distinto de 0 (en x0 no se escribe)
            regs[rdv] <= wdV;
    end

    // Inicialización
    initial begin
        for (int i = 0; i < 32; i++)
            regs[i] = 0; // inicializa TODOS los registros en 0. x0 se mantiene en 0 siempre
    end

endmodule