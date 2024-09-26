; Disk Structure
	.org $0000
	
; Definitions
	.include "defs.asm"

; RAM definitions
	.include "ram.asm"

; Disk info + file amount blocks
	.db DiskInfoBlock
	.db "*NINTENDO-HVC*"
	.db 0												; manufacturer
	.db "EXA "											; game title + space for normal disk
	.db 0, 0, 0, 0, 0									; game version, side, disk, disk type, unknown
	.db FILE_COUNT										; boot file count
	.db $ff, $ff, $ff, $ff, $ff
	.db $34, $07, $13									; release date (Heisei year)
	.db $49, $61, 0, 0, 2, 0, 0, 0, 0, 0				; region stuff
	.db $34, $10, $08									; disk write date (Heisei year)
	.db 0, $80, 0, 0, 7, 0, 0, 0, 0						; unknown data, disk writer serial no., actual disk side, price

	.db FileAmountBlock
	.db FILE_COUNT

; CHR
	.db FileHeaderBlock
	.db $00, $00
	.db "GAMECHAR"
	.dw $0000
	.dw chr_length
	.db CHR
	
	.db FileDataBlock
	chr_start:
	.incbin "Jroatch-chr-sheet.chr"
	chr_length = $ - chr_start

; PRG
	.db FileHeaderBlock
	.db $01, $01
	.db "GAMEPRGM"
	.dw $6000
	.dw prg_length
	.db PRG
	
	.db FileDataBlock
	oldaddr = $
	.base $6000
	prg_start:
	.include "main.asm"
	prg_length = $ - prg_start
	.base oldaddr + prg_length
	
; kyodaku file
	.db FileHeaderBlock
	.db $02, $02
	.db "-BYPASS-"
	.dw PPU_CTRL
	.dw $0001
	.db PRG

	.db FileDataBlock
	.db $90 ; enable NMI byte loaded into PPU control register - bypasses "KYODAKU-" file check
	
	.pad 65500
