
RUNTIME = $(addsuffix .ll, core number bool string io math error array)
CPP = cpp

out/out.s: out/out.ll 
	mkdir -p out/
	llc -opaque-pointers out/out.ll -o out/out.s

out/out.ll : out/runtime.ll main.ll
	mkdir -p out/
	cat out/runtime.ll main.ll  > out/out.ll

out/runtime.ll: ${RUNTIME}
	mkdir -p out/
	cat ${RUNTIME} separator.txt | ${CPP} -xc -P -E - | sed 's/NEWLINE/\n/g' > out/runtime.ll

out/out: out/out.s
	mkdir -p out/
	clang -lm out/out.s -o out/out 
	chmod +x out/out

all: out/out

clean:
	rm -rf out/

.PHONY:	all clean

