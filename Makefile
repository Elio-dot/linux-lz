


all:bochs/disk.img

bochs/disk.img:
	dd if=boot/bootsect of=bochs/disk.img conv=notrunc 

bochs/disk.img:boot/bootsect

boot/bootsect:boot/bootsect.s
	as --32 -s boot/bootsect.s -o boot/bootsect.o
	ld -s -m elf_i386 --oformat=binary -Ttext=0x0000  -pic -N boot/bootsect.o -o boot/bootsect
	truncate -s 512 boot/bootsect

.PHONY:clean
clean:
	rm boot/bootsect