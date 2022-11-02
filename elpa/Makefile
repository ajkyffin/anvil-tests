all:
	mpif90 -I$(subst :, -I,${CPATH}) -o test_real test_real.f90 -lelpa -lscalapack

test:
	mpirun ./test_real

clean:
	rm -f test_real
