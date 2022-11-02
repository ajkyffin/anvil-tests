all:
	${CC} -o fftw-test-c fftw-test.c -lfftw3 -lm
	${FC} -I$(subst :, -I,${CPATH}) -o fftw-test-f90 fftw-test.f90 -lfftw3
	mpicc -o fftw-mpi-test-c fftw-mpi-test.c -lfftw3_mpi -lfftw3 -lm
	mpif90 -I$(subst :, -I,${CPATH}) -o fftw-mpi-test-f90 fftw-mpi-test.f90 -lfftw3_mpi -lfftw3

test:
	./fftw-test-c
	./fftw-test-f90
	mpirun ./fftw-mpi-test-c
	mpirun ./fftw-mpi-test-f90

clean:
	rm -f fftw-test-c fftw-test-f90 fftw-mpi-test-c fftw-mpi-test-f90
