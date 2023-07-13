; main program code
;
; Formatting:
; - Width: 132 Columns
; - Tab Size: 4, using tab
; - Comments: Column 57

; reset handler
Reset:
		lda FDS_CTRL_MIRROR								; get setting previously used by FDS BIOS
		and #$f7										; and set for vertical mirroring
		sta FDS_CTRL
		
		jsr InitMemory
		jsr MoveSpritesOffscreen
		jsr InitNametables
		
		lda #$fd										; set VRAM buffer size to max value ($0302~$03ff)
		sta VRAM_BUFFER_SIZE
		
		lda #%00011110
		jsr UpdatePPUMask
		
		lda #%10000000									; enable NMIs & change background pattern map access
		jsr UpdatePPUCtrl
		
Main:

		inc NMIReady

-
		lda NMIReady
		bne -
		beq Main

; "NMI" routine which is entered to bypass the BIOS check
Bypass:
		lda #$00										; disable NMIs since we don't need them anymore
		sta PPU_CTRL
		
		lda #<NonMaskableInterrupt						; put real NMI handler in NMI vector 3
		sta NMI_3
		lda #>NonMaskableInterrupt
		sta NMI_3+1
		
		lda #$35										; tell the FDS that the BIOS "did its job"
		sta RST_FLAG
		lda #$ac
		sta RST_TYPE
		
		jmp ($fffc)										; jump to reset FDS
		
; NMI handler
NonMaskableInterrupt:
		pha
		lda NMIRunning
		beq +
		
		pla
		rti

+
		inc NMIRunning
		
		txa
		pha
		tya
		pha
		
		lda NMIReady
		beq NotReady
		
		jsr SpriteDMA
		jsr MoveSpritesOffscreen
		
		lda NeedPPUMask
		beq +
		
		lda PPU_MASK_MIRROR
		sta PPU_MASK
		dec NeedPPUMask

+
		dec NMIReady
		
		jsr ReadOrDownVerifyPads

NotReady:
		jsr SetScroll
		
		pla
		tay
		pla
		tax
		pla
		
		dec NMIRunning
		rti
		
; IRQ handler (unused for now)
InterruptRequest:
		rti

UpdatePPUMask:
		sta PPU_MASK_MIRROR
		lda #$01
		sta NeedPPUMask
		rts

UpdatePPUCtrl:
		sta PPU_CTRL
		sta PPU_CTRL_MIRROR
		rts

MoveSpritesOffscreen:
		lda #$ff										; fill OAM buffer with $ff to move offscreen
		ldx #$02
		ldy #$02
		jmp MemFill

InitMemory:
		lda #$00
		tax
		
-
		sta $00,x										; clear $00~$f0
		inx
		cpx #$f1
		bne -
		
		ldx #$04										; clear $0400~$0700
		ldy #$07
		jmp MemFill

InitNametables:
		lda #$20										; top-left
		jsr InitNametable
		lda #$24										; top-right

InitNametable:
		ldx #$00										; clear nametable & attributes for high address held in A
		ldy #$00
		jmp VRAMFill
		
Prepare

.org NMI_1
	.dw NonMaskableInterrupt
	.dw NonMaskableInterrupt
	.dw Bypass
	.dw Reset
	.dw InterruptRequest
