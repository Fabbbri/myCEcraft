module tb_instr_rom;

    logic [31:0] addr;
    logic [31:0] instr;

    instr_rom uut (
        .addr(addr),
        .instr(instr)
    );

    initial begin
        $dumpfile("sim/waves/tb_instr_rom.vcd");
        $dumpvars(0, tb_instr_rom);

        addr = 0;
        #10;

        addr = 4;
        #10;

        addr = 8;
        #10;

        addr = 12;
        #10;

        $finish;
    end

endmodule