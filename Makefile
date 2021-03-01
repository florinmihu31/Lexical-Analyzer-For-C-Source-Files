# Mihu Florin 334CC

build:
	flex lexical_analyzer_c.l
	gcc lex.yy.c -o exec

run:
	./exec input0.in input1.in input2.in

clean:
	rm exec
