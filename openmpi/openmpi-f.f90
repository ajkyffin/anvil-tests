! Hello world using openmpi in Fortran

PROGRAM hello_openmpi

    ! Prevent undeclared variables being used
    implicit none
    include 'mpif.h'

    integer rank, size, ierror, tag

    call MPI_INIT(ierror)
    !print *, ierror
    !print *, "Called MPI_INIT"

    call MPI_COMM_SIZE(MPI_COMM_WORLD, size, ierror)
    !print *, 'Size: ', size, ' Error: ', ierror
    !print *, MPI_COMM_WORLD

    call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierror)

    print *, 'Hello World from process: ', rank, 'of ', size
    call MPI_FINALIZE(ierror)

END PROGRAM