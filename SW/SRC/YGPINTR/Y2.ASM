;******************************************************************************
;*									      *
;*			       Ycode Interpreter			      *
;*									      *
;*                                Version 1.65                                *
;*				  (ROM bank 2)				      *
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
;*                                                                            *
;******************************************************************************

                include rom_ram.def
		include PControl.def

                .define addr_offs       ; оп▓имиза╢ии на ▓ема паме▓
                .define date_time       ; оп▓имиза╢ии на ▓ема паме▓
                .define use_32x16       ; да ▒е ползва ли sub п░и div (str2val)
                .define shorten_TBL     ; да ▒е ▒к║▒┐▓ ли ▓абли╢и▓е на LYC

                .ifNdef PControler
                 .define show_segload    ; show segmentation (·) at clock line
                .endif

		include interrup.inc
		include undocume.inc

		include Globals.Y	; global equates & Zero Page usage

; ▓ези п░оменливи ▒е използ│ва▓ ▒амо по в░еме на ▒в║░зване (link) и за▓ова
; мога▓ ▒покойно да ▒е по▒▓ав┐▓ в║░╡│ н┐кой неизполз│вани п░ез ▓ова в░еме
; ░еги▒▓░и на ин▓е░п░е▓а▓о░а

__GLOBSEG	equ	stat
__CurModInfo	equ	ipc
__Fhandle	equ	ProcNo
__ProgHandle	equ	SlotNo
__Extrnl	equ	lcl
__NoLibFile	equ	gbl
__power_2       equ     gbl+1
__BDYpath	equ	MS

__Ph		equ	FParea		; 32 bytes buffer

                include SYS_page.Y      ; System Page usage
		include ErrorNo.Y	; Error numbers
                include IOerrorN.Y2    ; IO error numbers

		ORG	bank2addr

                include ROMhead2.Y2     ; ROM bank 2 header
                include main2sub.Y2    ; ROM bank 2 common used subroutines

                include LYCodes2.Y2
                include FillMove.Y2     ; Fill and Move standard procs
                include DateTime.Y2     ; Get date/time procs
                include strings2.Y2     ; Miscellaneous string proc/funcs
                include special2.Y2     ; Special proc/funcs

                include StrVal.Y2       ; String <-> Value

                include FileMgr.Y2      ; Main file manager definitions
                include OpenClos.Y2    ; Initialize, Open and close files
                include Write.Y2        ; file writing
                include Read.Y2         ; read from file
                include OtherIO.Y2      ; eof, eoln, Block read/write, ...
                include MiscIO.Y2       ; Miscellaneous proc/funcs

                include Overlay.Y2      ; Segment loading
                include LinkUp.Y2       ; On the fly linker
                include StartUp.Y2      ; Start program execution
                include ExitYcod.Y2    ; Exit Ycode interpreter

                include errors2.Y2      ; Errors & Error handling

                section 0
Cright
                include cright.y2
CrightSize	=	* - Cright
                ends

ROMbank2size	=	* - bank2addr + CrightSize

		error	ROMbank2size / $2001 ; не по д║лго о▓ $2000

                ds      $2000 - ROMbank2size, '·'

                include cright.y2
		end ROM bank 2.

; Забележка: доб░е е да ▒е нап░ави п░о╢ед│░ка за за╡апване на addr + offset
;  	     за╣о▓о е ╖е▒▓о използ│вано не╣о.