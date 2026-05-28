// ============================================================
//  Drenador del write buffer hacia memoria principal.
//  Lee del write buffer y escribe en RAM cuando mem_busy=0.
//  Cada escritura ocupa WRITE_CYCLES ciclos de clk_mem.
// ============================================================

module wb_drain (
    input logic clk_mem,
    input logic reset,

    // write buffer
    input logic wb_empty,
    input logic [65:0] wb_data,    // {addr[31:0], size[1:0], wdata[31:0]}
    output logic wb_ren,

    // bloqueado cuando la memoria está siendo accesada (ej burst de lectura)
    input logic mem_busy,

    // interfaz con data_ram
    output logic ram_we,
    output logic [31:0] ram_addr,
    output logic [1:0]  ram_size,
    output logic [31:0] ram_wdata,

    // indica que este módulo está usando la memoria
    output logic busy
);

localparam logic [3:0] WRITE_CYCLES = 4'd9; // 1 ciclo de IDLE + 11 de write = 24 de procesador

localparam IDLE  = 1'b0;
localparam WRITE = 1'b1;

logic state;
logic [3:0]  count;
logic [31:0] lat_addr;
logic [1:0]  lat_size;
logic [31:0] lat_wdata;

always_ff @(posedge clk_mem or posedge reset)
    if (reset) begin
        state <= IDLE;
        count <= '0;
        lat_addr <= '0;
        lat_size <= '0;
        lat_wdata <= '0;
    end else
        case (state)
            IDLE:
                if (!wb_empty && !mem_busy) begin
                    lat_addr <= wb_data[65:34];
                    lat_size <= wb_data[33:32];
                    lat_wdata <= wb_data[31:0];
                    count <= '0;
                    state <= WRITE;
                end
            WRITE:
                if (count == WRITE_CYCLES - 1'b1)
                    state <= IDLE;
                else
                    count <= count + 1'b1;
            default: state <= IDLE;
        endcase

// pop del FIFO en el ciclo en que se detecta la condición de inicio
assign wb_ren = (state == IDLE) && !wb_empty && !mem_busy;

assign ram_we = (state == WRITE);
assign ram_addr = lat_addr;
assign ram_size = lat_size;
assign ram_wdata = lat_wdata;
assign busy = (state == WRITE);

endmodule
