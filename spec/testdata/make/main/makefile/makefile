O1 = ../obj/main.o
O2 = ../obj/main2.o

all: $(O1) $(O2)
	gcc $(O1) $(O2) -o ../project.exe

$(O1): objDir
	gcc -c ../src/main.c -o $(O1)

$(O2): objDir
	gcc -c ../src/main2.c -o $(O2)

objDir:
	mkdir -p ../obj

clean:
	rm -rf ../obj
	rm -f ../project.exe
