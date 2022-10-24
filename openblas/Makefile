all:
	${CC} -o cblas-test cblas-test.c -lopenblas
	${CC} -o lapacke-test lapacke-test.c -lopenblas

test:
	./cblas-test
	./lapacke-test

clean:
	rm -f cblas-test lapacke-test
