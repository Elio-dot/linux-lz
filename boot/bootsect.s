.code16

.org 0x00
.global _start
SYSSIZE  = 0x3000
SETUPLEN = 4				        # nr of setup-sectors
BOOTSEG  = 0x07c0			        # original address of boot-sector
INITSEG  = 0x9000			        # we move boot here - out of the way
SETUPSEG = 0x9020			        # setup starts here
SYSSEG   = 0x1000			        # system loaded at 0x10000 (65536).
ENDSEG   = SYSSEG + SYSSIZE		    # where to stop loading
OFFSET   = 0x7c00
ROOT_DEV =0x306
_start:
    movw $BOOTSEG, %ax              # set ds to 0x07c0 设置数据段寄存器为 0x07c0
    movw %ax, %ds
    movw $INITSEG,%ax               # set es to 0x9000 设置数据段寄存器为 0x9000
    movw %ax, %es

    movw $256,%cx                   # nr of words to move
    subw %si,%si                    # let di =0,ei =0 
    subw %di,%di 
    rep movsw                       # no specified src and dec, default src=ds:di dec =es:ei 
    ljmp $INITSEG,$go
go:
    movw %cs, %ax 
    movw %ax, %ds   
    movw %ax, %ss 
    movw $0xff00, %sp               # arbitrary value >> 512 

load_setup:
    movw $0x0000, %dx               # drive 0, head 0
    movw $0x0002, %cx               # track 0, sector 2
    movw $0x0200, %bx               # address=es:bx 
    movw $(0x0200+4), %ax           # ah=0x02, service 2 , read; al=nr of sectors to read
    int  $0x13
    jnc  ok_load_setup
    movw $0x0000, %dx 
    movw $0x0000, %ax               # reset the diskette
    int  $0x13 
    jmp  load_setup

ok_load_setup:
    movb $0x00, %dl  
    movw $0x0800, %ax 
    int  $0x13 
    movb $0x00, %ch                 # cl = nr of sectors/track
    movw %cx, sectors
    movw $INITSEG, %ax
    movw %ax, %es  

// print message:
    movb $0x03, %ah 
    xorb %bh, %bh 
    int  $0x10
    movw len, %cx 
    movw $0x0007, %bx 
    movw $msg, %bp 
    movw $0x1301, %ax 
    int  $0x10


// loading the system
    movw $SYSSEG, %ax 
    movw %ax, %es 
    call read_it


read_it:
    movw  %es, %ax 
    testw $0x0fff, %ax          # zf=1
die:jne die                     # jmp when zf=0
    xorw %bx,%bx                # bx is starting address within segment, bx 是段内起始地址
rp_read:
    movw %es, %ax 
    cmpw $ENDSEG, %ax           # have we read all yet? 
    jb   ok1_read               # jmp if ENDSEG>AX  else ret 
    ret 

ok1_read:
    movw sectors, %ax 
    subw sread, %ax 
    movw %ax, %cx               # 00000001
    shlw $9, %cx 
    addw %bx, %cx 
    jnc  ok2_read
ok2_read:

msg:        .ascii "\n\rLoading lz OS...\n\r"
len:        .word .- msg
sectors:    .word 0x0000           # nr of sectors/track set by the config file of bochs     
sread:      .word 1+SETUPLEN       # sectors read of current track 当前磁道已被读取的扇区数
head:       .word 0x0000           # current head    当前磁头
track:      .word 0x0000           # current track   当前磁道
root_dev:   .word ROOT_DEV
.org  510
.word 0xAA55
