.SILENT:    all
.PHONY:     all

LINKER :=   'ld'
DIR :=      'bin'
ASM :=      'nasm'
CC :=       'gcc'

all: build

build: kernel boot
	$(LINKER) -m elf_1386 -T link.ld -o $(DIR)/main

kernel:
	$(CC) -m32 -c test/kernel.c -o $(DIR)/kernel.o

boot:
	$(ASM) src/boot.asm -f elf32 -o $(DIR)/boot.o

debug: all
	qemu-system-i386 -kernel kernel
