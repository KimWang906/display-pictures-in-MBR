BITS 16 ; 16 Bits bootloader, we will work in protected mode, easier to work with BIOS interrupts
org 0x7c00 ; Bootloader magic number, check pixels wideo quick detail of "byte/number"

; let's start clearing the segments
segments_clear: 
    cli ; clear any interrupts
    xor ax, ax ; set ax register to = 0, so we will use it to clear other registers
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti ; set interrupt flag, this will allow ths processer to respond to maskable hardware interrupts

; we have ended the segments
; not let's prepare the screen

start:
    mov ax, 0x12 ; remember, this mode allows us to use 256 colors with a resolution 320x200(기억하세요, 이 모드는 320x200의 해상도와 함께 256가지의 색을 사용할 수 있습니다.)
    ; optimal to write some pictures, and limited to 64k pixels(최대 64k(64000)까지의 pixel로 제한됩니다.)
    int 0x10

    ; now, we have a issue, we need to print a picture, which is kinds
    ; exactly the number of pixels we can print, So in this case if it is 64KB, we must read sectors
    ; to store this picture. We will use the interrupt 0x13, and not the ah byte 0x02, since it wont
    ; allow to read extended sectors, so we will use 0x42, which allows us.

read_disk:
    mov ah, 0x42 ; read extended sectors
    mov si, bootdap ; necessary information to read the disk correctly
    int 0x13

    jmp $

bootdap:
    db 0x10 ; size of the DAP, which is 16 decimal, 0x10 in hexadecimal
    db 0 ; reversed 0, check the wiki
    dw (filled - image) ; how many sectors we are going to read (the total size of the binary minus the image, them we divide this by 512 and we get the size is sectors)
    dw 0x0000, 0xB000 ; we are going to directly write info the video memory 0xA000, lockup about the basic info in the pixels video.
    dq 1 ; the picture will be located next right to our bootloader.

; and this should be enough.

; in case that something went wrong

boot_error:
    ; let's just display "X" in case that we get an error
    mov ah, 0x0e ; tty mode
    mov al, "X" ; Set al register with X
    int 0x10 ; take that al register and print
    jmp stop

stop:
    hlt ; halt the system

; now let's prepare the entire binary
times 510 - ($ - $$) db 0 ; fill the rest of the sector with 0
dw 0xaa55 ; make it booteable sector

; set our image data
image: incbin "idata.vad"
filled: times 512 - ($ - $$) % 512 db 0 ; fill the reset of the binary with 0 correctly to be fit.
align 512