all: clean com sim

clean:
	rm -rf csrc simv* ucli.key novas*  verdiLog *.log

com:
	vcs -full64 -sverilog +v2k -debug_access+all -kdb -f flist.f
	
sim:
	./simv -l sim_vcs.log