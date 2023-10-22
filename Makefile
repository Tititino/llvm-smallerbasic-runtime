
RUNTIME = $(addsuffix .ll, core number bool string io math error)

out.s: ${RUNTIME} main.ll
	cat ${RUNTIME} separator.txt main.ll | cpp -xc -P -E - | sed 's/NEWLINE/\n/g' | llc -opaque-pointers > out.s

out.ll : ${RUNTIME}
	cat ${RUNTIME} | cpp -xc -P -E - | sed 's/NEWLINE/\n/g' > out.ll

# this exists because the compiler wants to know the 
# filetype of the input and passing it from stdin does not work really well
# and manually invoking `as' is a pain in the ass
out: out.s
	clang out.s -o out
	chmod +x out

all: out

clean:
	-rm out.ll
	-rm out.s
	-rm out

.PHONY:	all clean

