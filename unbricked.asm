INCLUDE "hardware.inc"

; Header
SECTION "Header", ROM0[$100]
    jp Entry
    ds $150 - @, 0 ; Header Room

Entry:
WaitVBlank:
    ; Wait until VBlank (y: 144)
    ld a, [rLY]
    cp 144
    jp c, WaitVBlank

    ; Turn off LCD
    xor a, a
    ld [rLCDC], a

LoadTiles:
    ld de, Tiles
    ld hl, _VRAM9000
    ld bc, TilesEnd - Tiles
CopyTiles:
    ; Copy all tiles recursively
    ld a, [de]
    ld [hli], a
    inc de ; Progress
    dec bc ; Decrese remaining
    ld a, b
    or a, c ; If bc not empty -> Repeat
    jp nz, CopyTiles
LoadTilemap:
    ld de, Tilemap
    ld hl, _SCRN0
    ld bc, TilemapEnd - Tilemap
CopyTilemap:
    ; Copy the tilemap recursively
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or a, c
    jp nz, CopyTilemap
LoadSprites:
    ld de, Sprites
    ld hl, _VRAM8000
    ld bc, SpritesEnd - Sprites
CopySprites:
    ; Copy the sprites recursively
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or a, c
    jp nz, CopySprites

PrepClearOAM:
    ld a, 0
    ld b, 160
    ld hl, _OAMRAM
ClearOAM:
    ld [hli], a
    dec b
    jp nz, ClearOAM
LoadOAM:
    ld hl, _OAMRAM
    ld a, 128 + 16 ; Y
    ld [hli], a
    ld a, 16 + 8 ; X
    ld [hli], a
    ld a, 0 ; SPRID & ATTRBS
    ld [hli], a
    ld [hl], a

EnableLCD:
    ld a, $E4
    ld [rBGP], a
    ld [rOBP0], a
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ld [rLCDC], a

Main:
    ; If not VBlank Loop
    ld a, [rLY]
    cp 144
    jp nc, Main
WaitVBlankMain:
    ; While VBlank
    ld a, [rLY]
    cp 144
    jp c, WaitVBlankMain

    ; Increment frame
    ld a, [wFrameCounter]
    inc a
    ld [wFrameCounter], a

    ; Check for 15th frame
    cp 15
    jp nz, Main

    ; Reset frame counter
    ld a, 0
    ld [wFrameCounter], a

    ; Increment X
    ld a, [_OAMRAM + 1]
    inc a
    ld [_OAMRAM + 1], a
    jp Main

INCLUDE "tiles/tiles.asm"
INCLUDE "tiles/tilemap.asm"
INCLUDE "tiles/sprites.asm"
INCLUDE "wram.asm"