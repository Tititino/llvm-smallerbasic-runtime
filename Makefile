
RUNTIME = $(addsuffix .ll, core number bool string io math error)
CPP = cpp

out.s: out/out.ll 
	mkdir -p out/
	llc -opaque-pointers out/out.ll -o out/out.s

out.ll : out/runtime.ll main.ll
	mkdir -p out/
	cat out/runtime.ll separator.txt main.ll  > out/out.ll

runtime.ll: ${RUNTIME}
	mkdir -p out/
	cat ${RUNTIME} | ${CPP} -xc -P -E - | sed 's/NEWLINE/\n/g' > out/runtime.ll

out: out.s
	mkdir -p out/
	clang out/out.s -o out/out
	chmod +x out/out

all: out

clean:
	rm -rf out/

.PHONY:	all clean

