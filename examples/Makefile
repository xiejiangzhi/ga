
test: clean test.o robot_tester.o
	g++ -o test test.o robot_tester.o
	./test

sharedlib: clean robot_tester.o
	g++ -shared -Wall -o librt.so robot_tester.o

clean:
	rm -f *.o *.so test

robot_tester.o: robot_tester.cpp
	g++ -Wall -c robot_tester.cpp

test.o: test.cpp
	g++ -c test.cpp

