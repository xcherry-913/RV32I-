clean:
	rm -rf csrc simv* ucli.key novas*   *.log *.fsdb

com: clean
	vcs -full64 -sverilog +v2k +lint=TFIPC-L -debug_access+all -f flist.f
	
sim: com
	./simv -l sim_vcs.log

all: sim