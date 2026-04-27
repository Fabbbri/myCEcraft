module neather_ram (
    input  logic        clk,
    input  logic        we_memV,
    input  logic [31:0] addrV,
    input  logic [31:0] wdataV,
    output logic [31:0] rdataV,
    output logic [31:0] rdataPass0V
);

    // Se accede por byte (8bits)

    // 64 KB = 65536 bytes (celdas)
    logic [7:0] mem [0:65535];

    // Solo se usan 16 bits de dirección pues 2^16 = 65536
    // Con 2^32 se podría tener una memoria de 4 GB
    logic [15:0] addr_index;
    assign addr_index = addrV[15:0];

    // Byte leído directamente (evita indexado doble en always_comb, no soportado por Icarus)
    logic [7:0] rd_byte;
    assign rd_byte = mem[addr_index];

    // Inicialización
    initial begin
        $readmemh("programs/neather.hex", mem);
    end

    // LECTURA
    assign rdataV = {mem[addr_index + 3],
                    mem[addr_index + 2],
                    mem[addr_index + 1],
                    mem[addr_index]} ;  // LW      

    // Lectura fija a dirección 0
    assign rdataPass0V = {mem[3], mem[2], mem[1], mem[0]};                                     

    // ESCRITURA
    always_ff @(posedge clk) begin
        if (we_memV) begin
            if (addr_index <= 16'hFFFC) begin
                        mem[addr_index]     <= wdataV[7:0];
                        mem[addr_index + 1] <= wdataV[15:8];
                        mem[addr_index + 2] <= wdataV[23:16];
                        mem[addr_index + 3] <= wdataV[31:24];
            end
        end
    end

endmodule