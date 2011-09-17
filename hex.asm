;Filename: hex.asm
;Authors: Daniel Sebastian
;         Marshall Cottrell
;Date: September 16, 2011
;Description: This file contains a single function, which takes 3 arrays. They
;are: the 16 byte array containing the data to process, the 47 byte array that
;this function will populate with (ascii-encoded) hexadecimal characters, and
;the 16 byte array that will contain the ascii representation of the data found
;in the first array (with non-printable characters stored as: '.').
.DATA
ALIGN 16
fifteen OWORD 0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0FH
nine OWORD 09090909090909090909090909090909H
xor_mask OWORD 71717171717171717171717171717171H
low_offset OWORD 30303030303030303030303030303030H
.CODE

;The hexConvert function. The only function in the file. See the header for
;details.
hexConvert PROC uses RBX RCX, data:QWORD, hexDigits:QWORD, asciiData:QWORD

;Move the data into two identical 128-bit XMM registers for faster processing.
MOVDQU XMM0, OWORD PTR data
MOVDQU XMM1, OWORD PTR data

;Shifting the bits of one register to the right by 4 allows the code to process
;each 4-bit segment (one hex digit) in its own 8-bit wide register segment. The
;AND instructions zero-out the bits outside the 4-bit segments of interest.
PSRLDQ XMM0, 4
ANDPD XMM0, fifteen
ANDPD XMM1, fifteen

;Complex comparison instruction. This instruction (used twice) takes 8-bit wide
;segments of each operand and compares them. If the value on the left is less
;than the value on the right, that particular 8-bit segment of the left operand
;is set to 0xFF. Otherwise, it is set to 0x00.
MOVAPD XMM2, XMM0
MOVAPD XMM3, XMM1
PCMPGTB XMM2, nine
PCMPGTB XMM3, nine

;These instructions are used to set the 8-bit segments of these registers to
;0x30 (offset of ASCII '0') if that hex digit was less than 10, or to 0x41
;(offset of 'A') of it was not.
PANDN XMM2, xor_mask
PANDN XMM3, xor_mask
XORPD XMM2, low_offset
XORPD XMM3, low_offset

;Add the offsets. The left operands now contain the ASCII representations of
;the hex digits of the bytes in the data array.
PADDB XMM0, XMM2
PADDB XMM1, XMM3

mov RBX, hexDigits
MOVUPD OWORD PTR [RBX], XMM0
MOVUPD OWORD PTR [RBX+16], XMM1

;TODO: Interleave the spaces between digit pairs.
;PUNPCKHBW shuffle high bytes
;PUNPCKLBW shuffle low bytes

RET
hexConvert ENDP
END