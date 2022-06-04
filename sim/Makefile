all: clean print

TEST_DIR = ../test

TESTBENCH_SOURCES = $(wildcard $(TEST_DIR)/*_tb.v)
TESTBENCHES = $(shell echo $(TESTBENCH_SOURCES) | sed 's:$(TEST_DIR)/::g' | sed 's:\.v::g')

T ?= $(shell echo $(TESTBENCHES))

RUN_TARGETS = $(addsuffix .x, $(T))
RUN_GUI_TARGETS = $(addsuffix .dve, $(T))
VERDI_TARGETS = $(addsuffix .vd, $(T))

VCS = vcs -full64 -LDFLAGS -Wl,--no-as-needed +nospeicy +notimingcheck

print:
	@echo "Build Targtes [$(TESTBENCHES)]"
	@echo "RUN CLI Targets [$(RUN_TARGETS)]"
	@echo "RUN DVE Targtes [$(RUN_GUI_TARGETS)]"
	@echo "VERDI Targets [$(VERDI_TARGETS)]"

%_tb:
	$(VCS) -timescale=1ns/100ps -nc -debug_acc+all -debug_region+cell+encrypt +lint=TFIPC-L -fsdb -l comp_log -f $(TEST_DIR)/$@.list -top $@ -o $@

elab: $(TESTBENCHES)

%.x: %
	./$* -l $*_run_log

%.dve: %
	./$* -gui -l $*_run_log &

%.vd: %
	@echo -e 'call {$$fsdbDumpfile("$*.fsdb")}\ncall {$$fsdbDumpvars(0, $*, "+all")}\nrun' > run.tcl
	./$* -l $*_run_log -ucli -i run.tcl
	verdi -f $(TEST_DIR)/$*.list -nolog -top $* -ssf $*.fsdb &

run: $(RUN_TARGETS)

rung: $(RUN_GUI_TARGTES)

verdi: $(VERDI_TARGETS)

clean: 
	rm -rf csrc simv.* *.vpd ucli.key *_log $(T)* *.fsdb verdiLog *.conf *.log DVEfiles *.daidir *.rc *.tcl
