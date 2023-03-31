


AS = as 
LD = ld
all:bochs/disk.img

bochs/disk.img:boot/bootsect
	dd if=boot/bootsect of=bochs/disk.img conv=notrunc 

bochs/disk.img:boot/bootsect

boot/bootsect:boot/bootsect.s
	$(AS) --32 -s boot/bootsect.s -o boot/bootsect.o
	$(LD) -s -m elf_i386 --oformat=binary -Ttext=0x0000  -pic -N boot/bootsect.o -o boot/bootsect
	truncate -s 512 boot/bootsect

.PHONY:clean
clean:
	-rm boot/bootsect
	-rm -r boot/*.o