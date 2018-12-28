;
; Check GPIO
;
; GPIO 0 - LED
; GPIO 1 - LED
; GPIO 2 - BUTTON to GND
; GPIO 3 - BUTTON to GND
;

	include ../DEVMAP.INC
	include ../ROM/BOOTMEM.INC
	include ../ROM/BOOTROM.INC

VPU_DATA	EQU	$E600
VPU_ADDR	EQU	$E602
VPU_CONFIG	EQU	$E604
VPU_AUTOOFFS	EQU	$E605
VPU_HSOFFS	EQU	$E60B
VPU_VSOFFS	EQU	$E60C

VPU_B_IRQ	EQU	$80
VPU_B_IEN	EQU	$40
VPU_B_GRF	EQU	$20
VPU_B_BLN	EQU	$08
VPU_B_CUR	EQU	$04
VPU_B_ID	EQU	$02
VPU_B_AUTO	EQU	$01

	org $100

	sei

	ldx	#hello
	jsr	F_UART_PUTS

	ldaa	#VPU_B_GRF|VPU_B_AUTO
	staa	VPU_CONFIG

	ldx	#0
	stx	VPU_ADDR

	ldx	#kim
loop	ldaa	0,x
	staa	VPU_DATA+1
	inx
;	inx
	cpx	#kim+8000
	bne	loop

	jmp	F_RESET

hello	db	'Hello, Graphics mode!', 10, 13, 0

kim	INCLUDE KIM.INC
