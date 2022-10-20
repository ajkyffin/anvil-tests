OVERSUBSCRIBE := $(shell mpirun --version | grep -q "Open MPI" && echo --oversubscribe)

all:
	mpicc -o mpi_hello_world-c mpi_hello_world.c
	mpif90 -o mpi_hello_world-f90 mpi_hello_world.f90

test:
	mpirun -np 4 ${OVERSUBSCRIBE} ./mpi_hello_world-c
	mpirun -np 4 ${OVERSUBSCRIBE} ./mpi_hello_world-f90

clean:
	rm -f mpi_hello_world-c mpi_hello_world-f90
