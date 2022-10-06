def gcc_versions = [
    "centos7": ["4.8", "7", "8", "9", "10", "11"],
    "rocky8": ["8", "9", "10", "11"],
    "rocky9": ["11"],
    "focal": ["9", "10"],
    "jammy": ["11", "12"]
]

def jdk_versions = [
    "centos7": ["1.8.0", "11"],
    "rocky8": ["1.8.0", "11", "17"],
    "rocky9": ["1.8.0", "11", "17"],
    "focal": ["1.8.0", "11", "17"],
    "jammy": ["1.8.0", "11", "17"]
]

def openmpi_versions = [ "4.1" ]
def fftw_versions = [ "3.3.10" ]
def openblas_versions = [ "0.3.21" ]
def scalapack_versions = [ "2.2.1" ]

node (params.os_label) {

    stage("Checkout repo") {
        checkout scm
    }

    stage("GCC ${gcc_versions[os_label]}") {
        gcc_versions[os_label].each { gcc_ver ->
            catchError(stageResult: "FAILURE") {
                sh label: "GCC ${gcc_ver}", script: """
                    cd gcc
                    module load gcc/${gcc_ver}

                    gcc --version | head -n1 | grep 'gcc (.\\+) ${gcc_ver}\\.'
                    g++ --version | head -n1 | grep 'g++ (.\\+) ${gcc_ver}\\.'
                    cpp --version | head -n1 | grep 'cpp (.\\+) ${gcc_ver}\\.'
                    gfortran --version | head -n1 | grep 'GNU Fortran (.\\+) ${gcc_ver}\\.'

                    gcc -o gcc-test gcc-test.c
                    ./gcc-test

                    gfortran -o fortran fortran.f90
                    ./fortran
                """
            }
        }
    }

    stage("Intel Compilers") {
        catchError(stageResult: "FAILURE") {
            sh """
                module load intel_base

                icc --version
                icpc --version
                ifort --version

                icx --version
                icpx --version
                ifx --version
            """
        }
    }

    stage("IntelMPI") {
        catchError(stageResult: "FAILURE") {
            sh label: "intel", script: """
                module load intel intelmpi

                mpicc --version | head -n1 | grep '^icc'
                mpicxx --version | head -n1 | grep '^icpc'
                mpifc --version | head -n1 | grep '^ifort'
                mpif90 --version | head -n1 | grep '^ifort'

                mpiicc --version | head -n1 | grep '^icc'
                mpiicpc --version | head -n1 | grep '^icpc'
                mpiifort --version | head -n1 | grep '^ifort'
            """
        }

        catchError(stageResult: "FAILURE") {
            sh label: "intelx", script: """
                module load intelx intelmpi

                mpicc --version | head -n1 | grep 'oneAPI DPC++/C++'
                mpicxx --version | head -n1 | grep 'oneAPI DPC++/C++'
                mpifc --version | head -n1 | grep '^ifx'
                mpif90 --version | head -n1 | grep '^ifx'

                mpiicc --version | head -n1 | grep 'oneAPI DPC++/C++'
                mpiicxx --version | head -n1 | grep 'oneAPI DPC++/C++'
                mpiifort --version | head -n1 | grep '^ifx'
            """
        }
    }

    stage("JDK ${jdk_versions[os_label]}") {
        jdk_versions[os_label].each { jdk_ver ->
            catchError(stageResult: "FAILURE") {
                sh label: "JDK ${jdk_ver}", script: """
                    module load jdk/${jdk_ver}

                    java -version 2>&1 | head -n1 | grep 'openjdk version "${jdk_ver}[._]'
                    javac -version 2>&1 | head -n1 | grep 'javac ${jdk_ver}[._]'
                """
            }
        }
    }

    stage("Miniconda") {
        catchError(stageResult: "FAILURE") {
            sh """
                module load conda
            """
        }
    }

    stage("CUDA") {
        catchError(stageResult: "FAILURE") {
            sh """
                module load cuda
                nvcc --version
            """
        }
    }

    stage("OpenMPI ${openmpi_versions} - GCC") {
        openmpi_versions.each { mpi_ver ->
            gcc_versions[os_label].each { gcc_ver ->
                catchError(stageResult: "FAILURE") {
                    sh label: "OpenMPI ${mpi_ver} - GCC ${gcc_ver}", script: """
                        module load gcc/${gcc_ver} openmpi/${mpi_ver}
                        mpirun --version
                        cd openmpi
                        mpicc -o openmpi-c openmpi-c.c
                        mpirun ./openmpi-c
                        mpif90 -o openmpi-f openmpi-f.f90
                        mpirun ./openmpi-f
                    """
                }
            }

            catchError(stageResult: "FAILURE") {
                sh label: "OpenMPI ${mpi_ver} - Intel", script: """
                    module load intel openmpi/${mpi_ver}
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

    stage("FFTW ${fftw_versions} - OpenMPI - GCC") {
        fftw_versions.each { fftw_ver ->
            openmpi_versions.each { mpi_ver ->
                gcc_versions[os_label].each { gcc_ver ->
                    catchError(stageResult: "FAILURE") {
                        sh label: "FFTW ${fftw_ver} - OpenMPI ${mpi_ver} - GCC ${gcc_ver}", script: """
                            module load gcc/${gcc_ver} openmpi/${mpi_ver} fftw/${fftw_ver}
                            cd fftw

                            mpicxx -o fftw-test fftw-test.c -lfftw3_mpi -lfftw3
                            mpirun ./fftw-test

                            mpicc -o mpi-test mpi-test.c -lfftw3_mpi -lfftw3 -lm
                            mpirun ./mpi-test

                            mpif90  -I"\$FFTW_HOME/include" -o mpi-fortran-test mpi-fortran-test.f90 -lfftw3_mpi -lfftw3 -lm
                            mpirun ./mpi-fortran-test

                            gfortran -I"\$FFTW_HOME/include" -o fortran-test fortran-test.f90 -lfftw3
                            ./fortran-test
                        """
                    }
                }

                catchError(stageResult: "FAILURE") {
                    sh label: "FFTW ${fftw_ver} - OpenMPI ${mpi_ver} - Intel", script: """
                        module load intel openmpi/${mpi_ver} fftw/${fftw_ver}
                        cd fftw

                        mpicxx -o fftw-test fftw-test.c -lfftw3_mpi -lfftw3
                        mpirun ./fftw-test

                        mpicc -o mpi-test mpi-test.c -lfftw3_mpi -lfftw3 -lm
                        mpirun ./mpi-test

                        mpif90  -I"\$FFTW_HOME/include" -o mpi-fortran-test mpi-fortran-test.f90 -lfftw3_mpi -lfftw3 -lm
                        mpirun ./mpi-fortran-test

                        ifort -I"\$FFTW_HOME/include" -o fortran-test fortran-test.f90 -lfftw3
                        ./fortran-test
                    """
                }
            }

            catchError(stageResult: "FAILURE") {
                sh label: "FFTW ${fftw_ver} - IntelMPI", script: """
                    module load intel intelmpi fftw/${fftw_ver}
                    cd fftw

                    mpicxx -o fftw-test fftw-test.c -lfftw3_mpi -lfftw3
                    mpirun ./fftw-test

                    mpicc -o mpi-test mpi-test.c -lfftw3_mpi -lfftw3 -lm
                    mpirun ./mpi-test

                    mpif90  -I"\$FFTW_HOME/include" -o mpi-fortran-test mpi-fortran-test.f90 -lfftw3_mpi -lfftw3 -lm
                    mpirun ./mpi-fortran-test

                    ifort -I"\$FFTW_HOME/include" -o fortran-test fortran-test.f90 -lfftw3
                    ./fortran-test
                """
            }
        }
    }

    stage("OpenBLAS ${openblas_versions}") {
        openblas_versions.each { openblas_ver ->
            catchError(stageResult: "FAILURE") {
                sh label: "OpenBLAS ${openblas_ver}", script: """
                    module load openblas/${openblas_ver}
                    cd openblas
                    gcc -lgfortran -lopenblas -o openblas-test openblas-test.c
                    ./openblas-test
                """
            }
        }
    }

    stage("ScaLAPACK ${scalapack_versions}") {
        scalapack_versions.each { scalapack_ver ->
            openmpi_versions.each { mpi_ver ->
                gcc_versions[os_label].each { gcc_ver ->
                    catchError(stageResult: "FAILURE") {
                        sh label: "ScaLAPACK ${scalapack_ver} - OpenMPI ${mpi_ver} - GCC ${gcc_ver}", script: """
                            module load gcc/${gcc_ver} openmpi/${mpi_ver} scalapack/${scalapack_ver}
                            cd scalapack
                            mpifort -o scalapack-test scalapack-test.f -lscalapack -lopenblas
                            mpirun -np 6 --oversubscribe ./scalapack-test
                        """
                    }
                }
            }
        }
    }
}
