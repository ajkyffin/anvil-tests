all:
	${CC} -o hello_world-c hello_world.c
	${CXX} -o hello_world-cpp hello_world.cpp
	${FC} -o hello_world-f90 hello_world.f90

test:
	./hello_world-c
	./hello_world-cpp
	./hello_world-f90

clean:
	rm -f hello_world-c hello_world-cpp hello_world-f90
