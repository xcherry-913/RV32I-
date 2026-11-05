clean:
	rm -rf csrc simv* ucli.key *.log *.fsdb \
	verdi* vdCovLog
com: clean
	vcs -full64 -sverilog +v2k +lint=TFIPC-L -debug_access+all -f flist.f

TEST ?= inst_txt/rv32ui-p-sh.txt
NAME := $(notdir $(basename $(TEST)))
sim_signle: com
	./simv +TEST="$(TEST)" \
	       +WAVE="waves/$(NAME).fsdb" \
	       -l "logs/$(NAME).log"
	
TESTS := $(filter-out inst_txt/rv32ui-p-fence_i.txt \
					  inst_txt/rv32ui-p-d%.txt \
					  inst_txt/rv32ui-p-m%.txt, \
         $(wildcard inst_txt/rv32ui-p-*.txt))

sim_all: com
	mkdir -p logs waves
	@for test_file in $(TESTS); do \
		name=$$(basename "$$test_file" .txt); \
		echo "Running $$name"; \
		./simv +TEST="$$test_file" \
			+WAVE="waves/$$name.fsdb" \
			-l "logs/$$name.log"; \
	done

all: sim_all

find_fail:
	grep -r -n FAIL logs/