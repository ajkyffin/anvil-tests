OVERSUBSCRIBE := $(shell mpirun --version | grep -q "Open MPI" && echo --oversubscribe)

all:
	${CC} -o fftw-test-c fftw-test.c -lfftw3 -lm
	${FC} -I"${FFTW_HOME}/include" -o fftw-test-f90 fftw-test.f90 -lfftw3
	mpicc -o fftw-mpi-test-c fftw-mpi-test.c -lfftw3_mpi -lfftw3 -lm
	mpif90 -I"${FFTW_HOME}/include" -o fftw-mpi-test-f90 fftw-mpi-test.f90 -lfftw3_mpi -lfftw3

test:
	./fftw-test-c
	./fftw-test-f90
	mpirun -np 4 ${OVERSUBSCRIBE} ./fftw-mpi-test-c
	mpirun -np 4 ${OVERSUBSCRIBE} ./fftw-mpi-test-f90

clean:
	rm -f fftw-test-c fftw-test-f90 fftw-mpi-test-c fftw-mpi-test-f90
