runtime.s: runtime.ll test-main.ll
	cat runtime.ll test-main.ll | cpp -xc -P -E - | sed 's/NEWLINE/\n/g' | llc > runtime.s

runtime: runtime.s
	clang runtime.s -o runtime
	chmod +x runtime

all: runtime 

clean:
	rm runtime.s
	rm runtime

.PHONY:	all

