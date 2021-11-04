pipeline {
    agent any
    def GCC_version = ['4.8.5', '7'];
    stages {
        GCC_version.each { ver ->
                stage("GCC " + ver) {
                    steps {
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
            }
        }
        stage('Test openmpi') {
            steps {
                echo 'Testing openmpi....'
            }
        }
        stage('Test fftw') {
            steps {
                echo 'Testing fftw..'
            }
        }
        stage('Test fftw with openmpi') {
            steps {
                echo 'Testing fftw with openmpi....'
            }
        }
    }
}