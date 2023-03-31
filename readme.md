
create a disk:
dd if=/dev/zero of=hd.img bs=1M count=32 


bochsrc:
```shell
romimage: file=$PROJECT_DIR/bochs/share/BIOS-bochs-latest
megs: 16
vgaromimage: file=$PROJECT_DIR/bochs/share/VGABIOS-lgpl-latest
floppya: 1_44="boot/bootsect", status=inserted
#ata0-master: type=disk, path="hdc-0.11.img", mode=flat, cylinders=204, heads=16, spt=38
ata0-master: type=disk, path=$PROJECT_DIR/bochs/disk.img, mode=flat, cylinders=80, heads=2, spt=18
boot: a
log:$PROJECT_DIR/bochs/bochsout.log
#parport1: enable=0
#vga_update_interval: 300000
#keyboard_serial_delay: 200
#keyboard_paste_delay: 100000
#floppy_command_delay: 50000
cpu: count=1, ips=4000000
mouse: enabled=0
private_colormap: enabled=0
fullscreen: enabled=0
screenmode: name="sample"
#i440fxsupport: enabled=0
```