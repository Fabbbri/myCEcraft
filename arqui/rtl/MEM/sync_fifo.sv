// ============================================================
//  sync_fifo.sv
//  FIFO síncrono genérico parametrizado
//  Usado por request_queue y write_buffer en l2_con
// ============================================================

module sync_fifo #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 8
)(
    input  logic                    clk,
    input  logic                    reset,

    // Push
    input  logic                    push,
    input  logic [DATA_WIDTH-1:0]   din,

    // Pop
    input  logic                    pop,
    output logic [DATA_WIDTH-1:0]   dout,   // cabeza de la cola (combinacional)

    // Estado
    output logic                    full,
    output logic                    empty
);

    localparam int PTR_BITS  = $clog2(DEPTH);
    // COUNT_BITS necesita un bit extra para distinguir 0 (empty) de DEPTH (full)
    // PTR_BITS'(DEPTH) trunca a PTR_BITS bits: para DEPTH=8, PTR_BITS=3,
    // 3'(8)=0, haciendo full==empty. Se usa (PTR_BITS+1) bits en count.
    localparam int COUNT_BITS = PTR_BITS + 1;

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    logic [PTR_BITS-1:0]   wptr, rptr;
    logic [COUNT_BITS-1:0] count;

    assign full  = (count == COUNT_BITS'(DEPTH));
    assign empty = (count == '0);
    assign dout  = mem[rptr];

    always_ff @(posedge clk) begin
        if (reset) begin
            wptr  <= '0;
            rptr  <= '0;
            count <= '0;
        end else begin
            case ({push & ~full, pop & ~empty})
                2'b10: begin                        // solo push
                    mem[wptr] <= din;
                    wptr      <= wptr + 1'b1;
                    count     <= count + 1'b1;
                end
                2'b01: begin                        // solo pop
                    rptr  <= rptr + 1'b1;
                    count <= count - 1'b1;
                end
                2'b11: begin                        // push + pop simultáneo
                    mem[wptr] <= din;
                    wptr      <= wptr + 1'b1;
                    rptr      <= rptr + 1'b1;
                    // count no cambia
                end
                default: ;                          // ninguno
            endcase
        end
    end

endmodule