call {$fsdbDumpfile("dump.fsdb")}
call {$fsdbDumpvars(0, reset_synchronizer_tb, "+all)}

run
