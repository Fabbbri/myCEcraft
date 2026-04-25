module data_ram (
    input  logic        clk,
    input  logic        we_mem,
    input  logic [1:0]  size,     // 00=byte, 10=word ... ¿01 posible half?
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata
);

    // Se accede por byte (8bits)

    // 64 KB = 65536 bytes (celdas)
    logic [7:0] mem [0:65535];

    // Solo se usan 16 bits de dirección pues 2^16 = 65536
    // Con 2^32 se podría tener una memoria de 4 GB
    logic [15:0] addr_index;
    assign addr_index = addr[15:0];

    // Byte leído directamente (evita indexado doble en always_comb, no soportado por Icarus)
    logic [7:0] rd_byte;
    assign rd_byte = mem[addr_index];

    // Inicialización
    initial begin
        $readmemh("programs/data.hex", mem);
    end

    // LECTURA
    assign rdata = (size == 2'b00) ? {{24{rd_byte[7]}}, rd_byte}       // LB: sign extend de los 8 bits accedidos
                 : (size == 2'b10) ? {mem[addr_index + 3],
                                      mem[addr_index + 2],
                                      mem[addr_index + 1],
                                      mem[addr_index]}                  // LW
                 : 32'h0;                                               // default

    // ESCRITURA
    always_ff @(posedge clk) begin
        if (we_mem) begin
            case (size)

                2'b00: begin // SB
                    mem[addr_index] <= wdata[7:0];
                end

                2'b10: begin // SW
                    if (addr_index <= 16'hFFFC) begin
                        mem[addr_index]     <= wdata[7:0];
                        mem[addr_index + 1] <= wdata[15:8];
                        mem[addr_index + 2] <= wdata[23:16];
                        mem[addr_index + 3] <= wdata[31:24];
                    end
                end

                default: ; // no-op

            endcase
        end
    end

endmodule