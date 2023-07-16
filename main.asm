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
		
		lda RST_TYPE_MIRROR								; retrieve the reset type we saved earlier
		sta RST_TYPE
		lda #$53										; and queue the soft reset type for next time
		sta RST_TYPE_MIRROR
		
		jsr InitMemory
		jsr MoveSpritesOffscreen
		jsr InitNametables
		
		lda #$fd										; set VRAM buffer size to max value ($0302~$03ff)
		sta VRAM_BUFFER_SIZE
		
		lda #%00011110									; enable sprites/background and queue it for next NMI
		jsr UpdatePPUMask
		
		lda #%10000000									; enable NMIs & change background pattern map access
		sta PPU_CTRL
		sta PPU_CTRL_MIRROR
		
Main:
		jsr SpriteHandler
		inc NMIReady

-
		lda NMIReady									; the usual NMI wait loop
		bne -
		beq Main										; unconditional branch back to main loop

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
		sta RST_TYPE_MIRROR								; save reset type to mirror as it will be clobbered
		
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
		
		lda NeedDMA
		beq +
		
		jsr SpriteDMA
		jsr MoveSpritesOffscreen
		dec NeedDMA
		
+
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

MoveSpritesOffscreen:
		lda #$ff										; fill OAM buffer with $ff to move offscreen
		ldx #$02
		ldy #$02
		jmp MemFill

InitObject:
		ldy #$00
		sty TestObject									; render flag
		sty TestObject+5								; animation frame
		sty TestObject+8								; object flags
		sty TestObject+9								; palette
		sty TestObject+11								; object index in OAM
		
		lda #$78										; position object at centre of screen
		sta ObjectY
		sta ObjectX
		
		lda #>TestObjectTiles							; tile arrangement pointer
		sta TestObject+6
		lda #<TestObjectTiles
		sta TestObject+7
		
		lda #$22										; height/width in tiles
		sta TestObject+10
		
		inc ObjectActive								; set active flag
		
		rts

SpriteHandler:
		lda ObjectActive								; skip object init if already active
		bne +

		jsr InitObject

+
		jsr MoveObject									; move and position object
		lda ObjectY
		sta TestObject+1
		lda ObjectX
		sta TestObject+3

		lda #<TestObject								; put object pointer into ($00)
		sta temp
		lda #>TestObject
		sta temp+1
		jsr UploadObject								; and call BIOS routine to upload it to the OAM buffer
		
		lda #$01										; queue OAM DMA for the next NMI
		sta NeedDMA
		rts

TestObjectTiles:
	.db $d0, $d2, $d1, $d3

MoveObject:
		lda #$00										; reset speed variables
		sta ObjectXSpeed
		sta ObjectYSpeed
		
		lda Buttons+2									; leave early if no directions held
		and #BUTTON_LEFT | #BUTTON_RIGHT | #BUTTON_UP | #BUTTON_DOWN
		bne MoveX
		
		rts

MoveX:													; move object horizontally, clamping within screen
		lda Buttons+2
		and #BUTTON_LEFT
		beq +
		
		lda ObjectX
		beq +
		
		lda #$ff
		sta ObjectXSpeed
		
+
		lda Buttons+2
		and #BUTTON_RIGHT
		beq +
		
		lda ObjectX
		cmp #$f0
		bcs +
		
		lda #$01
		sta ObjectXSpeed
		
+
		lda ObjectX
		clc
		adc ObjectXSpeed
		sta ObjectX

MoveY:													; move object vertically, clamping within screen
		lda Buttons+2
		and #BUTTON_UP
		beq +
		
		lda ObjectY
		beq +
		
		lda #$ff
		sta ObjectYSpeed
		
+
		lda Buttons+2
		and #BUTTON_DOWN
		beq +
		
		lda ObjectY
		cmp #$e0
		bcs +
		
		lda #$01
		sta ObjectYSpeed

+
		lda ObjectY
		clc
		adc ObjectYSpeed
		sta ObjectY
		
		rts

InitMemory:
		lda #$00
		tax
		
-
		sta $00,x										; clear $00~$f0
		inx
		cpx #$f1
		bne -
		
		ldx #$03										; clear $0300~$0700
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

.org NMI_1
	.dw NonMaskableInterrupt
	.dw NonMaskableInterrupt
	.dw Bypass											; default NMI vector
	.dw Reset
	.dw InterruptRequest
