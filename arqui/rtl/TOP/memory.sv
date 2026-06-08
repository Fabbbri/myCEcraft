module memory(
    input logic clk,
    input logic reset,

    input logic [1:0]  result_src,
    input logic        neather_wreg_src, w_memv, we_mem, size,
    input logic        we_reg, neather_mode, w_regv,
    input logic [31:0] alu_result, rd2, rdv2, pc_plus4,
    input logic [4:0]  instrD,

    output logic [1:0]  result_srcOUT,
    output logic        neather_wreg_srcOUT, we_regOUT, neather_modeOUT, w_regvOUT,
    output logic [31:0] rMemData, rvMemData, alu_resultOUT, pc_plus4OUT,
    output logic [31:0] rdataPass0v,
    output logic [4:0]  instrDOUT, instrMOUT_hz,
    output logic        we_reg_MEM_hz,
    output logic [31:0] ex_mem,
    output logic        stall_mem
);

// ==========================================================
//  CLK DIVIDER
// ==========================================================
logic clk_mem;
clk_divider clk_div(.clk(clk), .reset(reset), .clkdiv(clk_mem));

// ==========================================================
//  SEÑALES INTERNAS ENTRE MÓDULOS
// ==========================================================

logic is_write = we_mem;

// L1 → L2
logic        miss_l1,    hit_l1;
logic [31:0] l1_data_out;
logic        hit_l1_way;
logic        store_way_hit_l1;

// FIX 1: wire separado para dato_cpu de l1_con
// (l1_data_out ya está driven por l1d_cache.data_out;
//  no puede ser driven también por l1_con.dato_cpu)
logic [31:0] dato_cpu_l1_unused;

// L1 → l1d_cache (fill, inv)
logic        fill_en_l1;
logic        fill_way_l1;
logic [5:0]  fill_set_l1;
logic [20:0] fill_tag_l1;
logic [255:0] fill_line_l1;
logic        inv_en_l1;
logic        inv_way_l1;
logic [5:0]  inv_set_l1;

// L2 → L2 cache (fill, inv, store)
logic        fill_en_l2;
logic [1:0]  fill_way_l2;
logic [6:0]  fill_set_l2;
logic [19:0] fill_tag_l2;
logic [255:0] fill_line_l2;
logic        inv_en_l2;
logic [1:0]  inv_way_l2;
logic [6:0]  inv_set_l2;
logic        store_en_l2;
logic [31:0] store_addr_l2;
logic [31:0] store_data_l2;

// L2 cache → L2 con
logic        hit_l2;
logic [31:0] l2_data_out;
logic        hit_l2_wb;
logic [1:0]  hit_way_wb;
// para refill de L1 desde L2
logic [2:0]  l2_word_counter;
logic        l2_refill_active;
logic [31:0] l2_refill_rdata;
logic [1:0]  hit_way_l2;

// FIX 2: addr_set_l2 declarado con ancho correcto (7 bits)
logic [6:0]  addr_set_l2;
assign addr_set_l2 = alu_result[11:5];

// L2 con → mem_controller
logic        miss_l2;
logic [31:0] addr_to_mem;
logic [1:0]  size_to_mem;
logic        wb_write;
logic [31:0] wb_addr_mem, wb_data_mem;
logic [1:0]  wb_size_mem;
logic [31:0] addr_l2;
logic [1:0]  size_l2;

// mem_controller → L2 con (burst)
logic [2:0]   block_offset_counter;
logic [255:0] fill_line_burst;

// L2 con → pipeline
logic [31:0] dato_cpu_l2;
logic        stall_l2;

// mem_controller (backend)
logic        ram_we;
logic [1:0]  ram_size;
logic [31:0] ram_addr;
logic [31:0] ram_wdata;
logic        stall_mc;

// FIX 3: fill_line_to_caches solo driven por refill_regs
// l2_con.fill_line_out se captura en wire separado (no se reusa)
logic [255:0] fill_line_to_caches;
logic         fill_line_ready;
logic [255:0] fill_line_l2_raw;   // wire de descarte para l2_con.fill_line_out

// burst
logic        burst_active;
logic [2:0]  burst_counter;
logic [31:0] burst_rdata;
logic [31:0] ram_rdata_wire;

// req_to_mem: activa mem_controller solo cuando hay un miss real
//   Load:  miss_l2 ya está gateado por l2_con (load_state==ACCESS & ~hit_l2)
//   Store: write-through, pero solo si L1 ya evaluó el acceso (~hit_l1 confirma miss L1)
logic req_to_mem;
assign req_to_mem = is_write ? (miss_l1 & ~hit_l1)
                             : miss_l2;

// ==========================================================
//  L1D CACHE
// ==========================================================
l1d_cache L1D(
    .clk          (clk),
    .reset        (reset),
    .addr         (alu_result),
    .data_out     (l1_data_out),
    .hit          (hit_l1),
    .hit_way      (hit_l1_way),
    .fill_en      (fill_en_l1),
    .fill_way     (fill_way_l1),
    .fill_set     (fill_set_l1),
    .fill_tag     (fill_tag_l1),
    .fill_line    (fill_line_l1),
    .inv_en       (inv_en_l1),
    .inv_way      (inv_way_l1),
    .inv_set      (inv_set_l1),
    .is_write     (we_mem),
    .wdata        (rd2),
    .store_hit_l1 (store_way_hit_l1)
);

// ==========================================================
//  L1 CONTROLADOR
//  FIX 1: dato_cpu → wire separado (no l1_data_out)
//  FIX 4: l2_word_counter y l2_refill_active eliminados
//         (no son puertos de l1_con; los genera refill_regs)
// ==========================================================
l1_con L1Con(
    .clk                 (clk),
    .reset               (reset),
    .is_write            (we_mem),
    .addr                (alu_result),
    .size                ({size, 1'b0}),
    .wdata               (rd2),
    .fill_line           (fill_line_to_caches),
    .block_offset_counter(burst_counter),
    .hit_l1              (hit_l1),
    .l1_data_out         (l1_data_out),
    .fill_en             (fill_en_l1),
    .fill_way_out        (fill_way_l1),
    .fill_set            (fill_set_l1),
    .fill_tag            (fill_tag_l1),
    .fill_line_out       (fill_line_l1),
    .inv_en              (inv_en_l1),
    .inv_way             (inv_way_l1),
    .inv_set             (inv_set_l1),
    .dato_cpu            (dato_cpu_l1_unused),  // FIX 1: wire propio
    .miss_l1_out         (miss_l1),
    .hit_l1_out          (),
    .is_write_out        (),
    .wdata_out           (),
    .addr_out            (),
    .size_out            ()
);

// ==========================================================
//  L2 CACHE
//  FIX 2: l2_refill_set usa addr_set_l2 [6:0]
// ==========================================================
l2_cache L2(
    .clk              (clk),
    .reset            (reset),
    .addr             (alu_result),
    .data_out         (l2_data_out),
    .hit              (hit_l2),
    .hit_way          (hit_way_l2),
    .fill_en          (fill_en_l2),
    .fill_way         (fill_way_l2),
    .fill_set         (fill_set_l2),
    .fill_tag         (fill_tag_l2),
    .fill_line        (fill_line_to_caches),
    .inv_en           (inv_en_l2),
    .inv_way          (inv_way_l2),
    .inv_set          (inv_set_l2),
    .store_en         (store_en_l2),
    .store_addr       (store_addr_l2),
    .store_data       (store_data_l2),
    .hit_l2_wb        (hit_l2_wb),
    .hit_way_wb       (hit_way_wb),
    .l2_refill_word   (l2_word_counter),
    .l2_refill_way    (hit_way_l2),
    .l2_refill_set    (addr_set_l2),        // FIX 2: 7 bits
    .l2_refill_rdata  (l2_refill_rdata)
);

// ==========================================================
//  L2 CONTROLADOR
//  FIX 3: fill_line_out → fill_line_l2_raw (no fill_line_to_caches)
// ==========================================================
l2_con L2Con(
    .clk                (clk),
    .reset              (reset),
    .is_write           (we_mem),
    .miss_l1            (miss_l1),
    .hit_l1             (hit_l1),
    .addr               (alu_result),
    .size               ({size, 1'b0}),
    .wdata              (rd2),
    .burst_counter      (burst_counter),
    .burst_active       (burst_active),
    .burst_rdata        (burst_rdata),
    .hit_l2             (hit_l2),
    .l2_data_out        (l2_data_out),
    .hit_l2_wb          (hit_l2_wb),
    .fill_en            (fill_en_l2),
    .fill_way_out       (fill_way_l2),
    .fill_set           (fill_set_l2),
    .fill_tag           (fill_tag_l2),
    .fill_line_out      (fill_line_l2_raw), // FIX 3: wire separado
    .inv_en             (inv_en_l2),
    .inv_way            (inv_way_l2),
    .inv_set            (inv_set_l2),
    .store_en           (store_en_l2),
    .store_addr_out     (store_addr_l2),
    .store_data_out     (store_data_l2),
    .dato_cpu           (dato_cpu_l2),
    .stall              (stall_l2),
    .miss_l2_out        (miss_l2),
    .hit_l2_out         (),
    .addr_out           (addr_l2),
    .size_out           (size_l2),
    .wb_write_out       (wb_write),
    .wb_addr_out        (wb_addr_mem),
    .wb_data_out        (wb_data_mem),
    .wb_size_out        (wb_size_mem)
);

// ==========================================================
//  MEM CONTROLLER
// ==========================================================
mem_controller MemCtrl(
    .reset              (reset),
    .clk                (clk),
    .clk_mem            (clk_mem),
    .req                (req_to_mem),
    .we                 (wb_write),
    .addr               (addr_l2),
    .size               (size_l2),
    .wdata              (wb_data_mem),
    .ram_we             (ram_we),
    .ram_size           (ram_size),
    .ram_addr           (ram_addr),
    .ram_wdata          (ram_wdata),
    .ram_rdata          (ram_rdata_wire),
    .stall_mem          (stall_mc),
    .hit_l2             (hit_l2),
    .miss_l2            (miss_l2),
    .burst_mode         (burst_active),
    .burst_mode_counter (burst_counter),
    .burst_rdata        (burst_rdata)
);

// ==========================================================
//  REFILL_REGS
//  Produce fill_line_to_caches (único driver)
//  También produce l2_word_counter y l2_refill_active
// ==========================================================
refill_regs RefillRegs(
    .clk              (clk),
    .reset            (reset),
    .burst_active     (burst_active),
    .burst_counter    (burst_counter),
    .burst_rdata      (burst_rdata),
    .l2_refill_active (l2_refill_active),
    .l2_word_counter  (l2_word_counter),
    .l2_rdata         (l2_refill_rdata),
    .hit_l2           (hit_l2),
    .fill_line_out    (fill_line_to_caches), // único driver de este wire
    .fill_line_ready  (fill_line_ready)
);

// ==========================================================
//  DATA RAM
// ==========================================================
data_ram NormalRam(
    .clk   (clk_mem),
    .we_mem(ram_we),
    .size  (ram_size),
    .addr  (ram_addr),
    .wdata (ram_wdata),
    .rdata (ram_rdata_wire)
);

// ==========================================================
//  NEATHER RAM
// ==========================================================
logic we_memv_aux;
assign we_memv_aux = w_memv & neather_mode;

neather_ram VaultRam(
    .clk        (clk),
    .we_memV    (we_memv_aux),
    .addrV      (alu_result),
    .addrPortal (32'b0),
    .wdataV     (rdv2),
    .rdataV     (rvMemData),
    .rdataPass0V(rdataPass0v)
);

// ==========================================================
//  STALL
// ==========================================================
assign stall_mem = stall_l2 | stall_mc;

// ==========================================================
//  SEÑALES DE PASO
// ==========================================================
assign result_srcOUT      = result_src;
assign neather_wreg_srcOUT = neather_wreg_src;
assign we_regOUT          = we_reg;
assign neather_modeOUT    = neather_mode;
assign w_regvOUT          = w_regv;
assign alu_resultOUT      = alu_result;
assign pc_plus4OUT        = pc_plus4;
assign instrDOUT          = instrD;
assign instrMOUT_hz       = instrD;
assign we_reg_MEM_hz      = we_reg;
assign ex_mem             = alu_result;

assign rMemData = hit_l1 ? l1_data_out
                         : dato_cpu_l2;

endmodule