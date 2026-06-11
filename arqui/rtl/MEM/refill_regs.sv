// ============================================================
//  refill_regs.sv
// ============================================================

module refill_regs (
    input  logic        clk,
    input  logic        reset,

    input  logic        burst_active,
    input  logic [2:0]  burst_counter,
    input  logic [31:0] burst_rdata,

    input  logic        l2_refill_active,
    input  logic [2:0]  l2_word_counter,
    input  logic [31:0] l2_rdata,

    input  logic        hit_l2,

    output logic [255:0] fill_line_out,
    output logic         fill_line_ready
);

    logic [255:0] reg_mem;
    logic [255:0] reg_l2;

    // FIX: case explícito en lugar de variable part-select (Icarus bug)
    always_ff @(posedge clk) begin
        if (reset)
            reg_mem <= '0;
        else if (burst_active)
            case (burst_counter)
                3'd0: reg_mem[  31:  0] <= burst_rdata;
                3'd1: reg_mem[  63: 32] <= burst_rdata;
                3'd2: reg_mem[  95: 64] <= burst_rdata;
                3'd3: reg_mem[ 127: 96] <= burst_rdata;
                3'd4: reg_mem[ 159:128] <= burst_rdata;
                3'd5: reg_mem[ 191:160] <= burst_rdata;
                3'd6: reg_mem[ 223:192] <= burst_rdata;
                3'd7: reg_mem[ 255:224] <= burst_rdata;
                default: ;
            endcase
    end

    always_ff @(posedge clk) begin
        if (reset)
            reg_l2 <= '0;
        else if (l2_refill_active)
            case (l2_word_counter)
                3'd0: reg_l2[  31:  0] <= l2_rdata;
                3'd1: reg_l2[  63: 32] <= l2_rdata;
                3'd2: reg_l2[  95: 64] <= l2_rdata;
                3'd3: reg_l2[ 127: 96] <= l2_rdata;
                3'd4: reg_l2[ 159:128] <= l2_rdata;
                3'd5: reg_l2[ 191:160] <= l2_rdata;
                3'd6: reg_l2[ 223:192] <= l2_rdata;
                3'd7: reg_l2[ 255:224] <= l2_rdata;
                default: ;
            endcase
    end

    // reg_l2 nunca se escribe (l2_refill_active no tiene driver en memory.sv)
    // y hit_l2 se levanta justo al final del burst: el mux entregaba una
    // linea de ceros que pisaba el fill bueno. Siempre la linea del burst.
    assign fill_line_out = reg_mem;

    assign fill_line_ready = hit_l2 ? (l2_word_counter == 3'b111 && l2_refill_active)
                                    : (burst_counter    == 3'b111 && burst_active);

endmodule