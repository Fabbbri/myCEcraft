module l1d_cache (
    input  logic        clk,
    input  logic        reset,

    // Señales para obtener hit y data out
    input  logic [31:0] addr,
    output logic [31:0] data_out,
    output logic        hit,
    output logic        hit_way,

    // Señales de llenado - refill
    // Son para escribir una línea nueva en caché post miss
    input  logic         fill_en,
    input  logic         fill_way,
    input  logic [5:0]   fill_set,
    input  logic [20:0]  fill_tag,
    input  logic [255:0] fill_line,

    // Señales para invalidar líneas 
    input  logic        inv_en,
    input  logic        inv_way,
    input  logic [5:0]  inv_set,

    // Señales para WriteThrough
    input logic is_write,
    input logic [31:0] wdata
);

    localparam int NUM_SETS  = 64;
    localparam int LINE_BITS = 256;
    localparam int TAG_BITS  = 21;

    logic [TAG_BITS-1:0]  tag_mem  [NUM_SETS-1:0][0:1];
    logic [LINE_BITS-1:0] data_mem [NUM_SETS-1:0][0:1];
    logic                 valid    [NUM_SETS-1:0][0:1];

    // Lectura

    logic [20:0] addr_tag;
    logic [5:0]  addr_set;
    logic [2:0]  addr_word;

    assign addr_tag  = addr[31:11];
    assign addr_set  = addr[10:5];
    assign addr_word = addr[4:2];

    logic hit0, hit1;
    assign hit0 = valid[addr_set][0] && (tag_mem[addr_set][0] == addr_tag);
    assign hit1 = valid[addr_set][1] && (tag_mem[addr_set][1] == addr_tag);
    assign hit     = hit0 | hit1;
    assign hit_way = hit1;

    logic [LINE_BITS-1:0] sel_line;
    assign sel_line = hit1 ? data_mem[addr_set][1] : data_mem[addr_set][0];

    assign data_out = sel_line[addr_word*32 +: 32];

    // Determinar si hay que escribir o no en L1 
    logic hit_aux = hit0 | hit1;
    logic store_way_l1 = hit_aux && is_write; // si ambos cumplen, estamos en el camino de store hit way
    // habría que escribir todos los niveles
    // Si no se cumplen ambos, entonces solo se escribe en L2 (Store Miss Way)

    // Leer la línea actual del way que tuvo hit
    logic [LINE_BITS-1:0] updated_line;
    assign updated_line = hit1 ? data_mem[addr_set][1] : data_mem[addr_set][0];

    // Escritura

    integer s;
    always_ff @(posedge clk) begin
        if (reset) begin
            for (s = 0; s < NUM_SETS; s = s + 1) begin
                valid[s][0] <= 1'b0;
                valid[s][1] <= 1'b0;
            end

            // Si hay que hacer refill, se escribe datos y se activa la validez
        end else begin
            // Store hit: escribir solo la palabra dentro de la línea existente
            if (store_way_l1) begin // si estamos en hit way
                data_mem[addr_set][hit_way][addr_word*32 +: 32] <= wdata;
                // tag y valid no se tocan, la línea ya era válida (store hit way)
            end

            // escribir toda la linea tras un miss
            if (fill_en) begin
                tag_mem [fill_set][fill_way] <= fill_tag;
                data_mem[fill_set][fill_way] <= fill_line;
                valid   [fill_set][fill_way] <= 1'b1;
            end
            // Si el bit está inválido, se pone en bajo
            if (inv_en) begin
                valid[inv_set][inv_way] <= 1'b0;
            end
        end
    end

endmodule
