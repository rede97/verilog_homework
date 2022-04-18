call {$fsdbDumpfile("dump.fsdb")}
call {$fsdbDumpvars(0, sync_fifo_tb, "+all)}

run
