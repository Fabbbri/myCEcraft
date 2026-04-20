module instr_rom #(
    parameter DEPTH = 256 // Tamaño de la memoria
)(
    input  logic [31:0] addr,   // Dirección en bytes (PC)
    output logic [31:0] instr   // Instrucción de 32 bits
);

    // Memoria de instrucciones
    logic [31:0] memory [0:DEPTH-1];
    // palabras de 32 bits (4 bytes). Memoria con Celdas DEPTH -1

    // Inicialización
    initial begin
        integer i;

        // Inicialización segura con NOP (ADDI x0, x0, 0 en Craft21)
        for (i = 0; i < DEPTH; i = i + 1) begin
            memory[i] = 32'h00000013;
        end

        // Cargar programa
        $display("📥 Cargando programa desde programs/program.hex...");
        $readmemh("programs/program.hex", memory);
    end

    // Acceso a memoria (alineado a palabra)
    assign instr = (addr[31:2] < DEPTH) ? memory[addr[31:2]] : 32'h00000013;
    // index = addr / 4, es lo mismo que shift 2

endmodule