EXE = controller
GCC = gcc -m32
OBJ = controller.o controller_asm.o

$(EXE): $(OBJ)
	$(GCC) -o $(EXE) $(OBJ)

controller.o: controller.c
	$(GCC) -c -o controller.o controller.c

controller_asm.o: controller_asm.s
	$(GCC) -c -o controller_asm.o controller_asm.s

clean:
	rm -f *.o $(EXE) core
