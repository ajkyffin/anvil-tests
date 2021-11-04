def GCC_version = ['4.8.5', '7']

node {
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