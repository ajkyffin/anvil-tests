program test
  
  use, intrinsic :: iso_c_binding
  include 'fftw3.h'
  include 'fftw3-mpi.f03'
  integer(C_INTPTR_T), parameter :: L = 100
  integer(C_INTPTR_T), parameter :: M = 100
  type(C_PTR) :: plan, cdata
  complex(C_DOUBLE_COMPLEX), pointer :: data(:,:)
  integer(C_INTPTR_T) :: i, j, alloc_local, local_M, local_j_offset
  integer ierror
  call MPI_init(ierror)
  call fftwl_mpi_init

!   get local data size and allocate (note dimension reversal)
  alloc_local = fftwl_mpi_local_size_2d(M, L, MPI_COMM_WORLD, &
                                       local_M, local_j_offset)
  cdata = fftwl_alloc_complex(alloc_local)
  call c_f_pointer(cdata, data, [L,local_M])

!   create MPI plan for in-place forward DFT (note dimension reversal)
  plan = fftwl_mpi_plan_dft_2d(M, L, data, data, MPI_COMM_WORLD, &
                              FFTW_FORWARD, FFTW_MEASURE)

! initialize data to some function my_function(i,j)
  do j = 1, local_M
    do i = 1, L
      data(i, j) = (0, 0)
    end do
  end do

! compute transform (as many times as desired)
  call fftwl_mpi_execute_dft(plan, data, data)

  call fftwl_destroy_plan(plan)
  call fftwl_free(cdata)
  call MPI_FINALIZE(ierror)
end
