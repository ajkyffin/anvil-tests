def GCC_version = [ '4.8.5', '7' ]
def OPENMPI_version = [ '1.10.0', '2.1.6' ]
def FFTW_version = [ '3.3.10' ]
def OpenBLAS_version = [ '0.3.17' ]
def ScaLAPACK_version = [ '2.1.0' ]

node {
    stage('Checkout repo') {
        git 'https://github.com/ral-facilities/anvil-tests.git'
    }
    GCC_version.each { ver ->
        stage("GCC " + ver) {
            sh """
                module load gcc/${ver}
                gcc --version | grep " ${ver}"
                cd gcc
                gcc -o gcc-test gcc-test.c
                ./gcc-test
                gfortran -o fortran fortran.f90
                ./fortran
            """
        }
    }
    GCC_version.each { GCC_ver ->
        OPENMPI_version.each { OPENMPI_ver ->
            stage("OpenMPI ${OPENMPI_ver} - GCC ${GCC_ver}") {
                sh """
                module load gcc/${GCC_ver}
                gcc --version | grep " ${GCC_ver}"
                module load openmpi/${OPENMPI_ver}
                mpirun --version
                cd openmpi
                mpicc -o openmpi-c openmpi-c.c
                mpirun ./openmpi-c
                mpif90 -o openmpi-f openmpi-f.f90
                mpirun ./openmpi-f
                """
            }
        }
    }
    withEnv (
        ['FFTW_HOME=/opt/modules-sl7/software/']
    ){
        GCC_version.each { GCC_ver ->
            OPENMPI_version.each { OPENMPI_ver ->
                FFTW_version.each { FFTW_ver ->
                    stage("OpenMPI ${OPENMPI_ver} - GCC ${GCC_ver} - FFTW ${FFTW_ver}") {
                        sh """
                        module load gcc/${GCC_ver}
                        gcc --version | grep " ${GCC_ver}"
                        module load openmpi/${OPENMPI_ver}
                        mpirun --version
                        module load fftw/${FFTW_ver}
                        cd fftw

                        mpicxx -o fftw-test fftw-test.c -lfftw3_mpi -lfftw3
                        mpirun ./fftw-test

                        mpicc -o mpi-test mpi-test.c -lfftw3_mpi -lfftw3 -lm
                        mpirun ./mpi-test

                        mpif90  -I"$FFTW_HOME/fftw/${FFTW_ver}-gcc-${GCC_ver}-openmpi-${OPENMPI_ver}/include" -o mpi-fortran-test mpi-fortran-test.f90 -lfftw3_mpi -lfftw3 -lm
                        mpirun ./mpi-fortran-test

                        gfortran -I"$FFTW_HOME/fftw/${FFTW_ver}-gcc-${GCC_ver}-openmpi-${OPENMPI_ver}/include" -o fortran-test fortran-test.f90 -lfftw3
                        ./fortran-test
                        """
                    }
                }
            }
        }
    }
    stage("OpenBLAS " + OpenBLAS_version) {
            sh """
                module load "gcc/${GCC_version[0]}"
                gcc --version | grep " ${GCC_version[0]}"
                cd openblas
                source /opt/modules-common/lmod/lmod/init/profile
                export MODULEPATH=/opt/modules-sl7/modulefiles/Core
                module load openblas
                gcc -lgfortran -lopenblas -o openblas-test openblas-test.c
                ./openblas-test
            """
        }
    OPENMPI_version.each { OPENMPI_ver ->
    stage("ScaLAPACK " + ScaLAPACK_version) {
            sh """
                    module load "gcc/${GCC_version[0]}"
                    gcc --version | grep " ${GCC_version[0]}"
                    module load openmpi/${OPENMPI_ver}
                    mpirun --version
                    source /opt/modules-common/lmod/lmod/init/profile
                    export MODULEPATH=/opt/modules-sl7/modulefiles/Core
                    module load openblas
                    module load scalapack/${ScaLAPACK_version}-gcc-${GCC_version[0]}
                    cd scalapack
                    mpifort -o scalapack-test scalapack-test.f -lscalapack -lopenblas 
                    mpirun -np 6 ./scalapack-test
            """
        }
    }
}