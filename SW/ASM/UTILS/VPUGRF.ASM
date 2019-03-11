;
; Check GPIO
;
; GPIO 0 - LED
; GPIO 1 - LED
; GPIO 2 - BUTTON to GND
; GPIO 3 - BUTTON to GND
;

	include ../../DEVMAP.INC

	org $100

;	sei

	ldaa	VPU_CONFIG
	psha
	oraa	#VPU_B_GRF|VPU_B_AUTO
	staa	VPU_CONFIG

	ldx	VPU_VADDR
	pshx

	ldx	#0
	stx	VPU_VADDR
	ldx	#0
	stx	VPU_ADDR

	ldx	#kim
loop	ldd	0,x
	staa	VPU_DATA
	stab	VPU_DATA
	inx
	inx
	cpx	#kim+8000
	bne	loop

	int	$20

	pulx
	stx	VPU_VADDR
	pula
	staa	VPU_CONFIG

	rts

kim	INCLUDE KIM.INC
