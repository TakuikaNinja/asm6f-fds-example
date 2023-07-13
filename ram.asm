; RAM

; zeropage
.enum $0000
temp .dsb 16 ; temp memory used by FDS BIOS

; controller states
enum $00f1
Exp_Transitions .dsb 4 ; up->down transitions for Pad1, Pad2, Exp1, Exp2 used by ReadDownExpPads
Buttons .dsb 4 ; Usage depends on polling routine

; FDS BIOS register mirrors
.enum $00f9
FDS_EXT_MIRROR .dsb 1
FDS_CTRL_MIRROR .dsb 1
JOY1_MIRROR .dsb 1
PPU_Y_SCROLL_MIRROR .dsb 1
PPU_X_SCROLL_MIRROR .dsb 1
PPU_MASK_MIRROR .dsb 1
PPU_CTRL_MIRROR .dsb 1

; stack
; FDS BIOS vector flags
.enum $0100
NMI_FLAG .dsb 1 ; (bits 6 & 7)
IRQ_FLAG .dsb 1 ; (bits 6 & 7)
RST_FLAG .dsb 1 ; $35 = skip BIOS
RST_TYPE .dsb 1 ; $ac = first boot, $53 = soft-reset

; OAM buffer
.enum $0200
OAM_BUFFER .dsb $ff

; FDS BIOS VRAM buffer
.enum $0300
VRAM_BUFFER_SIZE .dsb 1 ; default = $7d, max = $fd
VRAM_BUFFER_END .dsb 1 ; holds end index of the buffer
VRAM_BUFFER .dsb $fd ; actual buffer

; rest of memory
.enum $0400
