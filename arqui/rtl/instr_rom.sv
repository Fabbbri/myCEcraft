module instr_rom #(
    parameter DEPTH = 1024 // Tamaño de la memoria
)(
    input  logic        clk,
    input logic         stall,
    input  logic [31:0] addr, // Dirección en bytes (PC)
    output logic [31:0] instr // Instrucción de 32 bits
);

    // Se accede por palabra (32 bits, 4 bytes)

    // Memoria de instrucciones
    logic [31:0] memory [0:DEPTH-1];
    // Esto crea un arreglo de DPETH-1 celdas, donde cada celda guarda una palabra: 32 bits (4 bytes).

    // Inicialización
    initial begin
        integer i;

        // Inicialización segura con NOP (ADD x0, x0, x0 en Craft21)
        for (i = 0; i < DEPTH; i = i + 1)
            memory[i] = 32'h00580000; // 0x00580000 es NOP en Craft 21, en RISCV es 0x00000013;

        // Cargar programa
        $display("📥 Cargando programa...");
        $readmemh("programs/program.hex", memory);
    end

    // Acceso a memoria (alineado a palabra)
    always_ff @(posedge clk) begin
        if (!stall)
            instr <= (addr[31:2] < DEPTH) ? memory[addr[31:2]] : 32'h00580000;
    end

endmodule