;*******************************************************************************
;Filename: hex.asm
;Authors: Daniel Sebastian
;         Marshall Cottrell
;Date: September 16, 2011
;Description: This file contains a single function, which takes 3 arrays. They
;are: the 16 byte array containing the data to process, the 47 byte array that
;this function will populate with (ascii-encoded) hexadecimal characters, and
;the 16 byte array that will contain the ascii representation of the data found
;in the first array (with non-printable characters stored as: '.').
;*******************************************************************************

.DATA
ALIGN 16

;These values are mathematical constants and bitmasks used throughout the
;program.
fifteen OWORD 0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0FH
nine OWORD 09090909090909090909090909090909H
low_offset OWORD 30303030303030303030303030303030H
or_mask OWORD 07070707070707070707070707070707H
shiftmask_zero OWORD 0A800908800706800504800302800100H
shiftmask_one OWORD 0D0C800B0A8009088007068005048003H
shiftmask_two OWORD 800F0E800D0C800B0A80090880070680H
spacemask OWORD 00200000200000200000200000200000H
nonprinting_mask_low OWORD 1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1FH
nonprinting_mask_high OWORD 7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7EH
dotmask OWORD 2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2EH
spaces OWORD 20202020202020202020202020202020H

.CODE

;The hexConvert function. The only function in the file. See the header for
;details regarding its purpose.
hexConvert PROC hexDigits:QWORD, asciiData:QWORD, data:QWORD, byteCount:QWORD

;Move the data into three identical 128-bit XMM registers for faster
;processing. Make copies for obtaining the hex digits later.
MOVDQU XMM0, OWORD PTR [R8]
MOVDQU XMM1, XMM0
MOVDQA XMM8, XMM0

;Use masks to find values that are above the minimum and values that are above
;the maximum printable ASCII characters. XOR the results. values lower than
;both will be zero, as well as values higher than both. Thus, only the bits
;corresponding to printable characters will be set.
MOVDQA XMM9, XMM8
MOVDQA XMM10, XMM8
PCMPGTB XMM9, nonprinting_mask_low
PCMPGTB XMM10, nonprinting_mask_high
PXOR XMM9, XMM10

;Take the newly created mask and use it to zero-out the non-printable bytes,
;as well as transform the dotmask into something that may be ORed with the
;now zero input bytes. Place the ORed result in the asciiData variable.
;R9 tells us how many characters to read, so we'll place a null terminator at
;that location in the array.
PAND XMM8, XMM9
PANDN XMM9, dotmask
POR XMM8, XMM9
MOVDQU OWORD PTR [RDX], XMM8
MOV BYTE PTR [RDX+R9], 0

;Shifting the bits of one register to the right by 4 allows the code to process
;each 4-bit segment (one hex digit) in its own 8-bit wide register segment. The
;AND instructions zero-out the bits outside the 4-bit segments of interest.
PSRLQ XMM0, 4
ANDPD XMM0, fifteen
ANDPD XMM1, fifteen

;Complex comparison instruction. This instruction (used twice) takes 8-bit wide
;segments of each operand and compares them. If the value on the left is less
;than the value on the right, that particular 8-bit segment of the left operand
;is set to 0xFF. Otherwise, it is set to 0x00.
MOVDQA XMM2, XMM0
MOVDQA XMM3, XMM1
PCMPGTB XMM2, nine
PCMPGTB XMM3, nine

;These instructions are used to set the 8-bit segments of these registers to
;0x30 (offset of ASCII '0') if that hex digit was less than 10, or to 0x31
;(offset of ASCII 'A', minus the value of 0xA) of it was not.
PAND XMM2, or_mask
PAND XMM3, or_mask
POR XMM2, low_offset
POR XMM3, low_offset

;Add the offsets. The left operands now contain the ASCII representations of
;the hex digits of the bytes in the data array. Register XMM0 contains the
;high bytes of each pair. Register XMM1 contains the low bytes.
PADDB XMM0, XMM2
PADDB XMM1, XMM3

;Rearranges the bytes of the registers so they are in the order they are to be
;output. There is some overlap; Register XMM0 contains bytes 0 thru 7, XMM1
;contains bytes 4 thru 11, XMM2 contains bytes 8 thru 15.
MOVDQA XMM2, XMM0
PUNPCKLBW XMM0, XMM1
PUNPCKHBW XMM2, XMM1
MOVHLPS XMM1, XMM0
MOVLHPS XMM1, XMM2

;Extracts the byte (hex digit) pairs into new registers, leaving room for
;spaces. The spaces are then ORed into position. At this point, the hex digit
;data is fully processed.
PSHUFB XMM0, shiftmask_zero
PSHUFB XMM1, shiftmask_one
PSHUFB XMM2, shiftmask_two
MOVDQA XMM3, spacemask
POR XMM0, XMM3
PSRLDQ XMM3, 1
POR XMM1, XMM3
PSRLDQ XMM3, 1
POR XMM2, XMM3

;Output hex digit data.
MOVDQU OWORD PTR [RCX], XMM0
MOVDQU OWORD PTR [RCX+16], XMM1
MOVDQU OWORD PTR [RCX+32], XMM2

;Set all positions past the last valid byte to spaces. Don't bother doing
;anything if 16 bytes were read (the whole line is used.)
CMP R9, 16
JE done
MOV RDX, 3
MOV RAX, R9
MUL RDX
MOV R8, RAX
MOV RBX, 16
DIV RBX

MOVDQA XMM3, spaces

MOVDQU OWORD PTR [RCX+R8], XMM3
CMP RAX, 2
JL two_lines
MOV BYTE PTR [RCX+48], 0
RET
two_lines:
MOVDQU OWORD PTR [RCX+31], XMM3
CMP RAX, 0
JE one_line
RET
one_line:
MOVDQU OWORD PTR [RCX+16], XMM3

;Exactly what it says on the tin. We're done here.
done:
RET
hexConvert ENDP
	
END