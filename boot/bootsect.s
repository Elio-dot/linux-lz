.code16

.org 0x00
.global _start
SYSSIZE  = 0x3000
SETUPLEN = 4				    # nr of setup-sectors
BOOTSEG  = 0x07c0			    # original address of boot-sector
INITSEG  = 0x9000			    # we move boot here - out of the way
SETUPSEG = 0x9020			    # setup starts here
SYSSEG   = 0x1000			    # system loaded at 0x10000 (65536).
ENDSEG   = SYSSEG + SYSSIZE		# where to stop loading
OFFSET   = 0x7c00
_start:
    movw $BOOTSEG, %ax           # set ds to 0x07c0 设置数据段寄存器为 0x07c0
    movw %ax, %ds
    movw $INITSEG,%ax           # set es to 0x9000 设置数据段寄存器为 0x9000
    movw %ax, %es

    movw $256,%cx                # nr of words to move
    subw %si,%si                 # let di =0,ei =0 
    subw %di,%di 
    rep movsw                    # no specified src and dec, default src=ds:di dec =es:ei 
    ljmp $INITSEG,$go
go:
    movw %cs, %ax 
    movw %ax, %ds   
    movw %ax, %ss 
    movw $0xff00, %sp  # arbitrary value >> 512 

load_setup:
    movw $0x0000, %dx 
    movw $0x0002, %cx 
    movw $0x0200, %bx 
    movw $(0x0200+4), %ax 
    int  $0x13
    jnc  ok_load_setup
    movw $0x0000, %dx 
    movw $0x0000, %ax 
    int  $0x13 
    jmp  load_setup

ok_load_setup:
    movb $0x00, %dl  
    movw $0x0800, %ax 
    int  $0x13 
    movb $0x00, %ch 
    movw %cx, sectors
    movw $INITSEG, %ax
    movw %ax, %es  

// print message:
    movb $0x03, %ah 
    xorb %bh, %bh 
    int  $0x10
    movw $21, %cx 
    movw $0x0007, %bx 
    movw $msg, %bp 
    movw $0x1301, %ax 
    int  $0x10

// load system
    movw $SYSSEG, %ax 
    movw %ax, %es 
    call read_it


read_it:
    movw  %es, %ax 
    testw $0x0fff, %ax 
die:
    jne die
    xorw %bx,%bx 


msg:     .ascii "\n\rLoading lz OS...\n\r"
len:     .word .-msg
sectors: .word 0x0000
sread:   .word 1+SETUPLEN
head:    .word 0x0000
track:   .word 0x0000
.org      510
.word 0xAA55
