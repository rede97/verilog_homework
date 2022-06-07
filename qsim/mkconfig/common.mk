
V ?= @

RUN_DIR = $(shell pwd)
LOG_DIR = $(shell pwd)/sim/log
OUT_DIR = $(shell pwd)/sim/out

WORK_DIR = ../rtl
TEST_DIR = ../test
WORK_SOURCES = $(wildcard $(WORK_DIR)/*.v)
TEST_SOURCES = $(wildcard $(TEST_DIR)/*.v) $(wildcard $(TEST_DIR)/*.sv) 

TESTBENCH_SOURCES = $(shell ls $(TEST_DIR)/*_tb.v)
TESTBENCHES = $(shell echo $(TESTBENCH_SOURCES) | sed 's:$(TEST_DIR)/::g' | sed 's:\.v::g')

all: make_out_dir print_testbenches

make_out_dir:
	$(V)mkdir -p $(LOG_DIR)
	$(V)mkdir -p $(OUT_DIR)

print_work_sources:
	@echo $(WORK_SOURCES)

print_test_sources:
	@echo $(TEST_SOURCES)
	
print_testbenches:
	@echo $(TESTBENCHES)

clean: sim_clean
	$(V)rm -rfv sim
