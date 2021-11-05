def GCC_version = ['4.8.5', '7']
def OPENMPI_version = ['1.1.5', '2.1.6']

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
                    ( cd openmpi;
                    mpicc -o openmpic openmpi.c;
                    ./openmpic;
                    mpicc -o openmpif openmpi.f90;
                    ./openmpif )
                    """
                }
            }
        }
    stage('Test openmpi') {
        echo 'Testing openmpi....'
    }
    stage('Test fftw') {
        echo 'Testing fftw..'
    }
    stage('Test fftw with openmpi') {
        echo 'Testing fftw with openmpi....'
    }
}