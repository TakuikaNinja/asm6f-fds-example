; RAM

; zeropage
	.enum $0000
	temp .dsb 16 ; temp memory used by FDS BIOS
	NMIRunning .dsb 1
	NMIReady .dsb 1
	NeedDraw .dsb 1
	NeedPPUMask .dsb 1
	NeedDMA .dsb 1
	ObjectActive .dsb 1
	ObjectX .dsb 1
	ObjectY .dsb 1
	ObjectXSpeed .dsb 1
	ObjectYSpeed .dsb 1
	FrameCount .dsb 2
	BGMode .dsb 1
	DisplayToggle .dsb 1
	DMCToggle .dsb 1
	DMCRate .dsb 1

; controller states
	.enum $00f1
	ExpTransitions .dsb 4 ; up->down transitions for Pad1, Pad2, Exp1, Exp2 (used by ReadDownExpPads)
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
	
	RST_TYPE_MIRROR .dsb 1 ; temporary mirror to preserve the reset type
	
	TestObject .dsb 12

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
	
	.ende
