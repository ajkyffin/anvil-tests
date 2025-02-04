!    This file is part of ELPA.
!
!    The ELPA library was originally created by the ELPA consortium,
!    consisting of the following organizations:
!
!    - Max Planck Computing and Data Facility (MPCDF), formerly known as
!      Rechenzentrum Garching der Max-Planck-Gesellschaft (RZG),
!    - Bergische Universität Wuppertal, Lehrstuhl für angewandte
!      Informatik,
!    - Technische Universität München, Lehrstuhl für Informatik mit
!      Schwerpunkt Wissenschaftliches Rechnen ,
!    - Fritz-Haber-Institut, Berlin, Abt. Theorie,
!    - Max-Plack-Institut für Mathematik in den Naturwissenschaften,
!      Leipzig, Abt. Komplexe Strukutren in Biologie und Kognition,
!      and
!    - IBM Deutschland GmbH
!
!
!    More information can be found here:
!    http://elpa.mpcdf.mpg.de/
!
!    ELPA is free software: you can redistribute it and/or modify
!    it under the terms of the version 3 of the license of the
!    GNU Lesser General Public License as published by the Free
!    Software Foundation.
!
!    ELPA is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU Lesser General Public License for more details.
!
!    You should have received a copy of the GNU Lesser General Public License
!    along with ELPA.  If not, see <http://www.gnu.org/licenses/>
!
!    ELPA reflects a substantial effort on the part of the original
!    ELPA consortium, and we ask you to respect the spirit of the
!    license that we chose: i.e., please contribute any changes you
!    may have back to the original ELPA library distribution, and keep
!    any derivatives of ELPA under the same license that we chose for
!    the original distribution, the GNU Lesser General Public License.
!
!
!>
!> Fortran test programm to demonstrates the use of
!> ELPA 1 real case library.
!> If "HAVE_REDIRECT" was defined at build time
!> the stdout and stderr output of each MPI task
!> can be redirected to files if the environment
!> variable "REDIRECT_ELPA_TEST_OUTPUT" is set
!> to "true".
!>
!> By calling executable [arg1] [arg2] [arg3] [arg4]
!> one can define the size (arg1), the number of
!> Eigenvectors to compute (arg2), and the blocking (arg3).
!> If these values are not set default values (4000, 1500, 16)
!> are choosen.
!> If these values are set the 4th argument can be
!> "output", which specifies that the EV's are written to
!> an ascii file.
!>
program test_real_example

!-------------------------------------------------------------------------------
! Standard eigenvalue problem - REAL version
!
! This program demonstrates the use of the ELPA module
! together with standard scalapack routines
!
! Copyright of the original code rests with the authors inside the ELPA
! consortium. The copyright of any additional modifications shall rest
! with their original authors, but shall adhere to the licensing terms
! distributed along with the original code in the file "COPYING".
!
!-------------------------------------------------------------------------------

   use iso_c_binding

   use elpa
   use mpi
   implicit none

   !-------------------------------------------------------------------------------
   ! Please set system size parameters below!
   ! na:   System size
   ! nev:  Number of eigenvectors to be calculated
   ! nblk: Blocking factor in block cyclic distribution
   !-------------------------------------------------------------------------------

   integer           :: nblk
   integer                          :: na, nev

   integer                          :: np_rows, np_cols, na_rows, na_cols

   integer                          :: myid, nprocs, my_prow, my_pcol, mpi_comm_rows, mpi_comm_cols
   integer                          :: i, mpierr, my_blacs_ctxt, sc_desc(9), info, nprow, npcol

   integer, external                :: numroc

   real(kind=c_double), allocatable :: a(:,:), z(:,:), ev(:)

   integer                          :: iseed(4096) ! Random seed, size should be sufficient for every generator

   integer                          :: STATUS
   integer                          :: success
   character(len=8)                 :: task_suffix
   integer                          :: j

   integer, parameter               :: error_units = 0

   class(elpa_t), pointer           :: e
   !-------------------------------------------------------------------------------


   ! default parameters
   na = 1000
   nev = 500
   nblk = 16

   call mpi_init(mpierr)
   call mpi_comm_rank(mpi_comm_world,myid,mpierr)
   call mpi_comm_size(mpi_comm_world,nprocs,mpierr)

   do np_cols = NINT(SQRT(REAL(nprocs))),2,-1
     if(mod(nprocs,np_cols) == 0 ) exit
   enddo
   ! at the end of the above loop, nprocs is always divisible by np_cols

   np_rows = nprocs/np_cols

   ! initialise BLACS
   my_blacs_ctxt = mpi_comm_world
   call BLACS_Gridinit(my_blacs_ctxt, 'C', np_rows, np_cols)
   call BLACS_Gridinfo(my_blacs_ctxt, nprow, npcol, my_prow, my_pcol)

   if (myid==0) then
     print '(a)','| Past BLACS_Gridinfo.'
   end if
   ! determine the neccessary size of the distributed matrices,
   ! we use the scalapack tools routine NUMROC

   na_rows = numroc(na, nblk, my_prow, 0, np_rows)
   na_cols = numroc(na, nblk, my_pcol, 0, np_cols)


   ! set up the scalapack descriptor for the checks below
   ! For ELPA the following restrictions hold:
   ! - block sizes in both directions must be identical (args 4 a. 5)
   ! - first row and column of the distributed matrix must be on
   !   row/col 0/0 (arg 6 and 7)

   call descinit(sc_desc, na, na, nblk, nblk, 0, 0, my_blacs_ctxt, na_rows, info)

   if (info .ne. 0) then
     write(error_units,*) 'Error in BLACS descinit! info=',info
     write(error_units,*) 'Most likely this happend since you want to use'
     write(error_units,*) 'more MPI tasks than are possible for your'
     write(error_units,*) 'problem size (matrix size and blocksize)!'
     write(error_units,*) 'The blacsgrid can not be set up properly'
     write(error_units,*) 'Try reducing the number of MPI tasks...'
     call MPI_ABORT(mpi_comm_world, 1, mpierr)
   endif

   if (myid==0) then
     print '(a)','| Past scalapack descriptor setup.'
   end if

   allocate(a (na_rows,na_cols))
   allocate(z (na_rows,na_cols))

   allocate(ev(na))

   ! we want different random numbers on every process
   ! (otherwise A might get rank deficient):

   iseed(:) = myid
   call RANDOM_SEED(put=iseed)
   call RANDOM_NUMBER(z)

   a(:,:) = z(:,:)

   if (myid == 0) then
     print '(a)','| Random matrix block has been set up. (only processor 0 confirms this step)'
   endif
   call pdtran(na, na, 1.d0, z, 1, 1, sc_desc, 1.d0, a, 1, 1, sc_desc) ! A = A + Z**T

   !-------------------------------------------------------------------------------

   if (elpa_init(20171201) /= elpa_ok) then
     print *, "ELPA API version not supported"
     stop
   endif
   e => elpa_allocate()

   ! set parameters decribing the matrix and it's MPI distribution
   call e%set("na", na, success)
   call e%set("nev", nev, success)
   call e%set("local_nrows", na_rows, success)
   call e%set("local_ncols", na_cols, success)
   call e%set("nblk", nblk, success)
   call e%set("mpi_comm_parent", mpi_comm_world, success)
   call e%set("process_row", my_prow, success)
   call e%set("process_col", my_pcol, success)

   success = e%setup()

   call e%set("solver", elpa_solver_1stage, success)


   ! Calculate eigenvalues/eigenvectors

   if (myid==0) then
     print '(a)','| Entering one-step ELPA solver ... '
     print *
   end if

   call mpi_barrier(mpi_comm_world, mpierr) ! for correct timings only
   call e%eigenvectors(a, ev, z, success)

   if (myid==0) then
     print '(a)','| One-step ELPA solver complete.'
     print *
   end if

   call elpa_deallocate(e)
   call elpa_uninit()

   call blacs_gridexit(my_blacs_ctxt)
   call mpi_finalize(mpierr)

end
