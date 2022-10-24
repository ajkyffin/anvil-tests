program test

use, intrinsic :: iso_c_binding 
include 'fftw3.f03'

INTEGER, parameter :: N = 100

double complex in, out
        dimension in(N), out(N)
        integer*8 plan

        call dfftw_plan_dft_1d(plan,N,in,out,FFTW_FORWARD,FFTW_ESTIMATE)
        call dfftw_execute_dft(plan, in, out)
        call dfftw_destroy_plan(plan)
end
