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
def elpa_versions = [ "2022.05.001" ]

node (params.os_label) {

    stage("Checkout repo") {
        checkout scm
    }

    stage("GCC ${gcc_versions[os_label]}") {
        gcc_versions[os_label].each { gcc_ver ->
            catchError(stageResult: "FAILURE") {
                sh label: "GCC ${gcc_ver}", script: """
                    module load gcc/${gcc_ver}

                    \$CC --version | head -n1 | grep 'gcc (.\\+) ${gcc_ver}\\.'
                    \$CXX --version | head -n1 | grep 'g++ (.\\+) ${gcc_ver}\\.'
                    \$FC --version | head -n1 | grep 'GNU Fortran (.\\+) ${gcc_ver}\\.'

                    cd hello-world
                    make clean
                    make
                    make test
                """
            }
        }
    }

    stage("Intel Compilers") {
        catchError(stageResult: "FAILURE") {
            sh """
                module load intel

                \$CC --version | head -n1 | grep 'oneAPI DPC++/C++'
                \$CXX --version | head -n1 | grep 'oneAPI DPC++/C++'
                \$FC --version | head -n1 | grep 'IFX'

                cd hello-world
                make clean
                make
                make test
            """
        }
    }

    stage("IntelMPI") {
        catchError(stageResult: "FAILURE") {
            sh label: "intel", script: """
                module load intel intelmpi

                mpicc --version | head -n1 | grep 'oneAPI DPC++/C++'
                mpicxx --version | head -n1 | grep 'oneAPI DPC++/C++'
                mpifc --version | head -n1 | grep 'IFX'
                mpif90 --version | head -n1 | grep 'IFX'

                mpiicc --version | head -n1 | grep 'oneAPI DPC++/C++'
                mpiicpc --version | head -n1 | grep 'oneAPI DPC++/C++'
                mpiifort --version | head -n1 | grep 'IFX'

                cd mpi-hello-world
                make clean
                make
                make test
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

    stage("OpenMPI ${openmpi_versions}") {
        openmpi_versions.each { mpi_ver ->
            gcc_versions[os_label].each { gcc_ver ->
                catchError(stageResult: "FAILURE") {
                    sh label: "OpenMPI ${mpi_ver} - GCC ${gcc_ver}", script: """
                        module load gcc/${gcc_ver} openmpi/${mpi_ver}

                        cd mpi-hello-world
                        make clean
                        make
                        make test
                    """
                }
            }

            catchError(stageResult: "FAILURE") {
                sh label: "OpenMPI ${mpi_ver} - Intel", script: """
                    module load intel openmpi/${mpi_ver}

                    cd mpi-hello-world
                    make clean
                    make
                    make test
                """
            }
        }
    }

    stage("FFTW ${fftw_versions}") {
        fftw_versions.each { fftw_ver ->
            openmpi_versions.each { mpi_ver ->
                gcc_versions[os_label].each { gcc_ver ->
                    catchError(stageResult: "FAILURE") {
                        sh label: "FFTW ${fftw_ver} - OpenMPI ${mpi_ver} - GCC ${gcc_ver}", script: """
                            module load gcc/${gcc_ver} openmpi/${mpi_ver} fftw/${fftw_ver}

                            cd fftw
                            make clean
                            make
                            make test
                        """
                    }
                }

                catchError(stageResult: "FAILURE") {
                    sh label: "FFTW ${fftw_ver} - OpenMPI ${mpi_ver} - Intel", script: """
                        module load intel openmpi/${mpi_ver} fftw/${fftw_ver}

                        cd fftw
                        make clean
                        make
                        make test
                    """
                }
            }

            catchError(stageResult: "FAILURE") {
                sh label: "FFTW ${fftw_ver} - IntelMPI", script: """
                    module load intel intelmpi fftw/${fftw_ver}

                    cd fftw
                    make clean
                    make
                    make test
                """
            }
        }
    }

    stage("OpenBLAS ${openblas_versions}") {
        openblas_versions.each { openblas_ver ->
            gcc_versions[os_label].each { gcc_ver ->
                catchError(stageResult: "FAILURE") {
                    sh label: "OpenBLAS ${openblas_ver} - GCC ${gcc_ver}", script: """
                        module load gcc/${gcc_ver} openblas/${openblas_ver}

                        cd openblas
                        make clean
                        make
                        make test
                    """
                }
            }

            catchError(stageResult: "FAILURE") {
                sh label: "OpenBLAS ${openblas_ver} - Intel", script: """
                    module load intel openblas/${openblas_ver}

                    cd openblas
                    make clean
                    make
                    make test
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
                            make clean
                            make
                            make test
                        """
                    }
                }

                catchError(stageResult: "FAILURE") {
                    sh label: "ScaLAPACK ${scalapack_ver} - OpenMPI ${mpi_ver} - Intel", script: """
                        module load intel openmpi/${mpi_ver} scalapack/${scalapack_ver}

                        cd scalapack
                        make clean
                        make
                        make test
                    """
                }
            }

            catchError(stageResult: "FAILURE") {
                sh label: "ScaLAPACK ${scalapack_ver} - IntelMPI", script: """
                    module load intel intelmpi scalapack/${scalapack_ver}

                    cd scalapack
                    make clean
                    make
                    make test
                """
            }

            catchError(stageResult: "FAILURE") {
                sh label: "MKL - IntelMPI", script: """
                    module load intel intelmpi

                    cd scalapack
                    make clean
                    make mkl
                    make test
                """
            }
        }
    }

    stage("ELPA ${elpa_versions}") {
        elpa_versions.each { elpa_ver ->
            openmpi_versions.each { mpi_ver ->
                gcc_versions[os_label].each { gcc_ver ->
                    catchError(stageResult: "FAILURE") {
                        sh label: "ELPA ${elpa_ver} - OpenMPI ${mpi_ver} - GCC ${gcc_ver}", script: """
                            module load gcc/${gcc_ver} openmpi/${mpi_ver} elpa/${elpa_ver}

                            cd elpa
                            make clean
                            make
                            make test
                        """
                    }
                }

                catchError(stageResult: "FAILURE") {
                    sh label: "ELPA ${elpa_ver} - OpenMPI ${mpi_ver} - Intel", script: """
                        module load intel openmpi/${mpi_ver} elpa/${elpa_ver}

                        cd elpa
                        make clean
                        make
                        make test
                    """
                }
            }

            catchError(stageResult: "FAILURE") {
                sh label: "ELPA ${elpa_ver} - IntelMPI", script: """
                    module load intel intelmpi elpa/${elpa_ver}

                    cd elpa
                    make clean
                    make
                    make test
                """
            }
        }
    }
}
