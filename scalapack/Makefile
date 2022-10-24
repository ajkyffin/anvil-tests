OVERSUBSCRIBE := $(shell mpirun --version | grep -q "Open MPI" && echo --oversubscribe)

all:
	mpif90 -o scalapack-test scalapack-test.f -lscalapack -lopenblas

test:
	mpirun -np 6 ${OVERSUBSCRIBE} ./scalapack-test

clean:
	rm -f scalapack-test
