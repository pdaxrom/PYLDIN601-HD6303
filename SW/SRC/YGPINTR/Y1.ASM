;******************************************************************************
;*									      *
;*			       Ycode Interpreter			      *
;*									      *
;*                                Version 1.65                                *
;*				  (ROM bank 1)				      *
;*									      *
;*		       (c) 1989, 1990 Гео░ги Пе▓░ов /YGP/		      *
;*									      *
;*		Processor:		MC6800 (СМ 601) 		      *
;*		Computer:		П║лдин 601			      *
;*		Operating System:	UniDOS (R)			      *
;*									      *
;*		Language:		MC6800 Assembler		      *
;*									      *
;*	Спе╢иални благода░но▒▓и на	О░лин  Шопов /Eagle/		      *
;*					Иво    Ненов			      *
;*									      *
;*		       А ▒║╣о и на	Вале░и Т░и┤онов /YWY/		      *
;*                                      Леонид Калев /Lion/                   *
;*									      *
;******************************************************************************

                include rom_ram.def
		include PControl.def

		include interrup.inc
		include undocume.inc

		include Globals.Y	; global equates & Zero Page usage
                include SYS_page.Y      ; System Page usage
		include ErrorNo.Y	; Run Time Errors (description)

		ORG	bank1addr

                include ROMhead1.Y1     ; ROM bank1 header
                include Errors1.Y1      ; Bank 1 run time error handling
                include Misc.Y1         ; fill to page boundary

		ds	(0-*)&$ff,'Y'   ; align on page boundary

                include OpCodeAd.Y1   ; address tables for
                include StdLycRe.Y1   ; long instructions
                include CnstLoad.Y1     ; Constant loading
                include Variable.Y1    ; Load, Load Address, Store variables
                include RecordAr.Y1 ; Record and Arrays handling
                include Packed.Y1       ; Packed record & arrays handling
                include Arithmet.Y1   ; TOS Arithmetic
                include Comparis.Y1  ; integer, cardinal, longint, ...
                include Jumps.Y1        ; Conditional & Unconditional jumps
                include Strings.Y1      ; String handling procedures
                include PowerSet.Y1    ; Power Sets handling
                include DynamicM.Y1   ; Dynamic memory handling
                include FPinstr.Y1      ; Floating Point instructions

                include ProcCall.Y1    ; procedure/function calls
                include ProcExit.Y1    ; return/exit from proc/func
                include SegInitF.Y1 ; segment initialize/finit
                include Misc_.Y1        ; miscellaneous instructions
                                        ; the rest of MISC.Y1

Ycode1size	=	* - bank1addr

                include RAMcode.Y1      ; self modifing parts

ROMbank1size	=	Ycode1size + RAMcodeSize + CrightSize

		error	ROMbank1size / $2001 ; не по д║лго о▓ $2000

                section 0
Cright
                include cright.y1
CrightSize	=	* - Cright
                ends

filler          ds      $2000 - ROMbank1size, '·'
filler_size     =       * - filler

                error   ROMbank1size+ filler_size - $2000

                include cright.y1

		end. ROM Bank 1