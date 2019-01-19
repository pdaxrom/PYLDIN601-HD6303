; ***********************************************************
; *							    *
; *	      éèÖêÄñàéççÄ ëàëíÖåÄ    U n i D O S	    *
; *	    ß† Ø•∞±Æ≠†´•≠ ¨®™∞Æ™Æ¨Øæ≤∫∞ èöãÑàç 601	    *
; *							    *
; *    Copyright (C) 1988  çàèã "è∞Æ£∞†¨≠Æ Æ±®£≥∞ø¢†≠•"     *
; *							    *
; *		 (C) 1988  à¢Æ ç†©§•≠Æ¢ çÖçéÇ		    *
; *		 (C) 1988  é∞´®≠ Ñ®¨®≤∞Æ¢ òéèéÇ 	    *
; *							    *
; ***********************************************************
; *							    *
; *		      Command Interpreter		    *
; *		  Version 3.10 / 01-Apr-1990		    *
; *							    *
; ***********************************************************
;		list	off

; èêÖÑìèêÖÜÑÖçàÖ:
; í•™±≤† ≠† ÆØ•∞†∂®Æ≠≠†≤† ±®±≤•¨† ±• §†¢† ±†¨Æ ß† ±Ø∞†¢™†.
; Ç±ø™Æ §®∞•™≤≠Æ Æ°∞∫π•≠®• ™∫¨ ™Æ§† ®´® ¨Æ§®¥®∂®∞†≠• ≠†
; Ø∞Æ¨•≠´®¢®≤• ≠† ÆØ•∞†∂®Æ≠≠†≤† ±®±≤•¨† ≠†∞≥∏†¢† ™Æ≠∂•Ø∂®ø≤†
; ß† ±∫¢¨•±≤®¨Æ±≤ ± ∞†ß´®∑≠® ¢•∞±®®. çàèã "è∞Æ£∞†¨≠Æ Æ±®£≥∞ø¢†≠•"
; ±® ß†Ø†ß¢† Ø∞†¢Æ≤Æ §† Ø∞†¢® Ø∞Æ¨•≠® ¢ ™Æ§† ® Ø∞Æ¨•≠´®¢®≤• ≠†
; ÆØ•∞†∂®Æ≠≠†≤† ±®±≤•¨† ± ∂•´ ØÆ§Æ°∞•≠®• ≠† ¥≥≠™∂®Æ≠®∞†≠•≤Æ.
; ç• ±• ØÆ•¨† ≠®™†™¢† Æ≤£Æ¢Æ∞≠Æ±≤ ß† ≠•±∫¢¨•±≤®¨Æ±≤ ≠† Ø∞Æ£∞†¨≠®
; Ø∞Æ§≥™≤®, ≠•±Ø†ß®´® Ø∞Æ≤Æ™Æ´† ß† ®ßØÆ´ß¢†≠• ≠† ÆØ•∞†∂®Æ≠≠†≤†
; ±®±≤•¨† ± °∫§•π® ¢•∞±®®.
; é°∞∫π•≠®ø≤† ™∫¨ ÆØ•∞†∂®Æ≠≠†≤† ±®±≤•¨† ±´•§¢† §† ±• ®ß¢∫∞∏¢†≤
; ØÆ Ø∞Æ≤Æ™Æ´† ÆØ®±†≠ ¢ ∞∫™Æ¢Æ§±≤¢Æ≤Æ ß† ØÆ≤∞•°®≤•´ø.

;-------------------------------------------------
;UNIDOS command interpreter
;-------------------------------------------------
_NO_ERROR	=	0	       ;No error				  
_INV_FUNCTION	=	1	       ;Invalid function number
_INV_DRV	=	2	       ;Invalid drive
_WRT_PROT	=	3	       ;Disk write protected
_ADDR_ERR	=	4	       ;Address error
_DTA_ERR	=	5	       ;Data error
_GENERAL_ERR	=	6	       ;General failure
_INV_SECTOR	=	7	       ;Invalid sector
;Reserved	=	8	       ;Reserved
_BAD_DESCR	=	9	       ;Invalid media type
_FAT_ERROR	=      10	       ;FAT error
_INV_PATH	=      11	       ;Path not found
;Reserved	=      12	       ;Reserved
_NO_HANDLE	=      13	       ;Too many open files
_ACC_DENIED	=      14	       ;Access denied
_FILE_OPEN	=      15	       ;File already open
_INV_HANDLE	=      16	       ;Invalid file handle
_DISK_FULL	=      17	       ;Disk full
_FILE_LOST	=      18	       ;File lost in directory
_INV_NAME	=      19	       ;Invalid name
_DIR_FULL	=      20	       ;Root directory full
_DIR_EXIST	=      21	       ;Directory exist
_CUR_DIR	=      22	       ;Attempt to remove the current directory   ;atempt to delete current dir
_DIR_NOT_EMPTY	=      23	       ;Directory not empty
_BAD_POSITION	=      24	       ;Bad LSEEK position
;Reserved	=      25	       ;Reserved
_NOT_DISK_FILE	=      26	       ;Not disk file
_TOO_MANY_DRVRS =      27	       ;Too many drivers installed
_NOT_SAME_DEV	=      28	       ;Not same device
_FILE_EXIST	=      29	       ;File exist
_PRN_TIMEOUT	=      30	       ;Printer timeout
_PRN_ERROR	=      31	       ;Printer general failure
_PRN_PAPER_END	=      32	       ;Printer out of paper
_AUX_TIMEOUT	=      33
_AUX_PARITY	=      34
_AUX_OVERRUN	=      35
_AUX_FRAMING	=      36
N_ROM_ERRORS	=      36

_EOF		=     200
_RESERVED_CLU	=     201
_BAD_CLU	=     202

_INV_NUM_PARMS	=	64		;Invalid number of parameters
_BAD_CMD_FNAME	=	65		;Bad command or file name
_INSF_MEM	=	66		;Insuficient memory
_BAD_EXE_FILE	=	67		;Error in .PGM file
_NO_LANGUAGE	=	68		;Language not available
_CANT_EXEC_CMD	=	69		;Cannot execute .CMD file
_SRCDST_CONFL	=	70		;File cannot be copied onto itself
_OPEN_ERROR	=	71		;File opening error
_CREAT_ERROR	=	72		;File creation error
_NOT_FOUND	=	73		;File not found
_INV_PARM	=	74		;Invalid parameter
N_RAM_ERRORS	=	74

;fdcslct 	equ	$E6C0
;fdcstat 	equ	$E6D0		;ëå609
MEMPAGE_SEL	equ	$17

rom_vars1	=	$E700
rom_vars2	=	$E000

system_line	equ	$BFA0
configuration	equ	$ED02
disk_types	equ	$ED03
scrmode 	equ	$ED12
system_scrbase	equ	$ED20
fddparms	equ	$ED26

bios_version	equ	$FFE0
rtswix		equ	$FFE2
rtswib		equ	$FFE4
rtswia		equ	$FFE6
hard_version	equ	$FFE9		;destinct 601A

lomem_init	=	$100

maxfiles	=	32

min_bios_vers	=	$0201
max_bios_vers	=	$03FF

min_kernel_vers =	$0200
max_kernel_vers =	$03FF

;--------------------------------------------------------
;Zero page variables
;--------------------------------------------------------
indos		=	$80
swic		=	$84
swib		=	$85
swia		=	$86
swix		=	$87

hundreds	=	$98
seconds 	=	$99
minutes 	=	$9A
hours		=	$9B
day		=	$9C
month		=	$9D
year		=	$9E		; 2 bytes

a1		=	$78
x1		=	$79
x2		=	$7B


himem		=	$EE00 + $F*2
lomem		=	$EE00 + $E*2
resident	=	$EE00 + $D*2


;--------------------------------------------------------
;Directory entry
;--------------------------------------------------------
		section 0
dir_name	ds	8
dir_ext 	ds	3
dir_attribute	ds	1
dir_reserved	ds	10
dir_time	ds	2
dir_date	ds	2
dir_start_clust ds	2
dir_file_size	ds	4
		ends

;--------------------------------------------------------
;
;Block device driver header
;
;--------------------------------------------------------
		section 0
init_addr	ds	2
read_addr	ds	2
write_addr	ds	2
block_page	ds	1
fat_buff	ds	2
cur_dir_ptr	ds	2
fat_sec_no	ds	1
fat_modified	ds	1		;<>0 needs writing

n_open		ds	1

bps		ds	2		;bytes/sector
spc		ds	1		;sector/cluster
brs		ds	1		;boot&reserved sectors
nof		ds	1		;number of FAT
nde		ds	2		;max dir entries
tns		ds	2		;total number of sectors
med		ds	1		;media descriptor
spf		ds	1		;number of sectors in FAT
spt		ds	1		;sectors per track
heads		ds	1		;number of heads
header_size	=	*
		ends

;--------------------------------------------------------
;
;Char device driver header
;
;--------------------------------------------------------
		section 0
chr_name	ds	8
chr_read_ptr	ds	2
chr_write_ptr	ds	2
chr_init	ds	2
chr_page	ds	1
chr_next	ds	2
chr_head_size	=	*
		ends


;--------------------------------------------------------
;Character file handle description
;--------------------------------------------------------
		section 0
chr_hndl_mode	ds	1		;b0,b1 - mode, b2 - chr file

					;b7 - file modified
chr_hndl_read	ds	2
chr_hndl_write	ds	2
chr_hndl_page	ds	1
chr_hndl_eof	ds	1
chr_hndl_remain ds	1
		ends

;--------------------------------------------------------
;File handle description
;--------------------------------------------------------
		section 0
hndl_mode	ds	1			;0 - free, 1 - read, 2 - write, 3 - r/w
						;b0,b1 - mode, b2 - chr_file,
						;b3 - date&time changed,
						;b4 - text mode EOF, b5 - text mode CR detected
						;b7 - modified
hndl_dir_entry	ds	$20
hndl_drive	ds	1
hndl_dir_sec	ds	2
hndl_dir_pos	ds	1
hndl_buff	ds	2
hndl_file_pos	ds	4
hndl_cur_clust	ds	2
hndl_cur_sec	ds	1
hndl_sector	ds	2
		ends


;--------------------------------------------------------
;Buffer data
;--------------------------------------------------------
		section 0
buff_drive	ds	1
buff_sector	ds	2
buff_modified	ds	1
buff_n_files	ds	1
buff_length	=	*
		ends


;--------------------------------------------------------
;PCB { Program Control Block } structure
;--------------------------------------------------------
		section 0
parent_PCB	ds	2

pcb_job_file	ds	1	;bit 7 = 1  -  batch file; b0..b6 - batch file handle
pcb_internal	ds	1	;internal DOS command flag

pcb_stack	ds	2	;old stack
pcb_himem	ds	2
pcb_lomem	ds	2

pcb_indos	ds	1

pcb_macro	ds	3
pcb_break	ds	3	;address & page
pcb_error_hndl	ds	3
pcb_reset	ds	3

pcb_old_input	ds	1
pcb_old_output	ds	1

pcb_open_files	ds	maxfiles/8  ;Max. 32 files

pcb_argc	ds	1
pcb_argv_ptr	ds	2
pcb_argv	ds	$10*2

pcb_length	=	*
		ends

		section rom_vars1
fat_buf1	ds	$200
fat_buf2	ds	$200

current_drive	ds	1
first_chr_drv	ds	2
head_table	ds	16

file_handles	ds	2
n_handles	ds	1
		ends

		section rom_vars2
file_buf1	ds	$200
		ds	buff_length
file_buf2	ds	$200
		ds	buff_length

header_a	ds	header_size
header_b	ds	header_size

header_nul	ds	chr_head_size
header_prn	ds	chr_head_size
header_aux	ds	chr_head_size
header_con	ds	chr_head_size
		ends

		list	on
		section $EC00
current_PCB	ds	2

old_create_a	ds	2
old_create_p	ds	1
old_open_a	ds	2
old_open_p	ds	1
old17_a 	ds	2
old17_p 	ds	1
old5b_a 	ds	2		;expand handles
old5b_p 	ds	1
old2D_a 	ds	2		;move mem bug fix
old2D_p 	ds	1
savA1		ds	2
savA2		ds	2


exit_flag	ds	1
exec_hndl	ds	1
exec_x		ds	2

table		ds	6

tmps		ds	2

dir_entry	ds	$20
find_buff	ds	19

lint		ds	4

src_ptr 	ds	2
dst_ptr 	ds	2
parse_ptr	ds	2
parse_x 	ds	2
parse_argv_ptr	ds	2
calc_argv_x	ds	2
parse_cmp_end	ds	2

system_x	ds	2

build_pcb_x	ds	2

redir_in_ptr	ds	2
redir_out_ptr	ds	2
redir_double	ds	1

pr_entry_x	ds	2
date
time		ds	2
dec_flag	ds	1

exp_drive	ds	1
exp_name	ds	2
ex1		ds	2
ex2		ds	2

show_drive	ds	1

set_buff	ds	4

getline_buffer	ds	2

find_last_x	ds	2

last_drive	ds	1
tmps17		ds	2
table17 	ds	6

; relocatable file header structure:
exe_header
exe_magic	ds	2
exe_n_items	ds	2
exe_offset	ds	2
exe_length	ds	2
exe_entry	ds	2
exe_data_size	ds	2
exe_reserved	ds	4		;reserved

echo_flag	ds	1
pr_dec_flag	ds	1

int_68_table	ds	4

unpack_xsv	ds	2
unpack_reg	ds	1
unpack_x1	ds	2
unpack_x2	ds	2

file_counter	ds	2

cr_temp_end	ds	2
cr_temp_cntr	ds	1

;-----------
exp_x		ds	2
ret_addr	ds	2
exec_addr	ds	2
scr_addr	ds	2
my_x		ds	2

sp		ds	2
base		ds	2
count		ds	2
oldhimem	ds	2
oldlomem	ds	2
items_ptr	ds	2
ptr		ds	2

temp		ds	2
mnth		ds	3

drive_no	ds	1
rs_fmt		ds	1

src		ds	2
dst		ds	2
wild		ds	2
terminator	ds	1

fname_ptr	ds	2

drv		ds	1
copy_err	ds	1
copy_lng	ds	2

dest		ds	2
dst_wild	ds	2

hndl1		ds	1
hndl2		ds	1

buff_ptr	ds	2
buff_lng	ds	2

;dest		 ds	 2
;dst_wild	 ds	 2

old_himem	ds	2
err_buff	ds	2
err_b		ds	1

clock_save_sp	ds	2
clock_temp	ds	3

		error	*/$ED00
		ends
;		list	off



		org	$1000
relocate	proc
		bsr	*+2
		pulb
		pula
		cmpb	#$10
		bne	return
		cmpa	#2
		beq	location_ok
return
		ldx	#$100
		stx	lomem
		ldx	#3
		clrb
		int	$2a
		cpx	#0
		beq	exit_dos
		ldaa	#$3F
		staa	0, x
		ldaa	#$3A
		staa	1, x
		ldaa	#$39
		staa	2, x
		jmp	x
exit_dos	rts

check_b_tbl	dw	$0100
		db	1
		dw	$0000

location_ok
;		clr	fdcslct
;		inc	fdcslct

		ldx	#bad_bios_vers
		ldab	bios_version
		ldaa	bios_version+1

		cmpb	#/min_bios_vers
		bne	cmp1
		cmpa	#min_bios_vers
cmp1		bcs	bad_version

		cmpb	#/max_bios_vers
		bne	cmp2
		cmpa	#max_bios_vers
cmp2		bhi	bad_version

		int	$41
		ldx	#bad_ver_msg

		cmpb	#/min_kernel_vers
		bne	cmp3
		cmpa	#min_kernel_vers
cmp3		bcs	bad_version

		cmpb	#/max_kernel_vers
		bne	cmp4
		cmpa	#max_kernel_vers
cmp4		bhi	bad_version
		bra	ver_ok

bad_ver_msg	db	10, 7, 'Incorrect UniDOS kernel version',0
bad_bios_vers	db	10, 7, 'Incorrect BIOS version',0

bad_version
		int	$23
		int	$00
ver_ok
;		ldaa	fdcstat
;		anda	#%11000000
;		cmpa	#%10000000
;		bne	nofloppy	;no floppy

		ldx	#check_b_tbl
		ldaa	#$43		;seek
		int	$17
;		anda	#%00100000	;only bad_seek
		tab
		ldaa	configuration
		oraa	#1		;floppy A
		tstb
		bne	no_b
		oraa	#2		;floppy B
no_b		staa	configuration
		clr	disk_types
		ldaa	#$40
		int	$17		;reset floppies
		bra	floppyok
nofloppy
;		clr	configuration
		ldx	#0
		stx	head_table
		stx	head_table+2
floppyok	clr	last_drive

		ldx	#resident_end - resident_start
		stx	x1

		sei
		sts	tmps

		ldaa	MEMPAGE_SEL
		anda	#$F0		; //FIXME
		oraa	#$17		; Upper half of ram, page 7
		staa	MEMPAGE_SEL

		ldx	#start_move
		txs
		ldx	#$C000
		stx	x2
loop
		ldx	x2
		pula
		staa	x
		inx
		stx	x2
		ldx	x1
		dex
		stx	x1
		bne	loop
		lds	tmps
		cli
;--				; Make sure time is legal
		ldaa	seconds
		cmpa	#60
		bcc	reset_time
		ldaa	minutes
		cmpa	#60
		bcc	reset_time
		ldaa	hours
		cmpa	#24
		bcc	reset_time
		ldaa	day
		beq	reset_time
		cmpa	#32
		bcc	reset_time
		ldaa	month
		beq	reset_time
		cmpa	#13
		bcc	reset_time
		ldab	year
		ldaa	year+1
		cmpb	#/1980
		bne	c_year1
		cmpa	#1980
c_year1 	bcs	reset_time
		cmpb	#/2100
		bne	c_year2
		cmpa	#2100
c_year2 	bcs	time_ok
reset_time	clr	hundreds
		clr	seconds
		clr	minutes
		clr	hours
		ldaa	#1
		staa	day
		staa	month
		ldx	#1989
		stx	year
time_ok
;--
		ldx	#int1C_-int1C
		clrb
		int	$2A
		cpx	#0
		bne	ok1C
		jmp	sorry			;sleep
ok1C		clrb
		ldaa	#$1C
		int	$2F			;set vector
		sei
		sts	tmps
		lds	#int1C
		des
		ldab	#int1C_-int1C
int1C_loop	pula
		staa	x
		inx
		decb
		bne	int1C_loop
		lds	tmps
		cli

;--
		ldx	#int1D_-int1D
		clrb
		int	$2A
		cpx	#0
		bne	ok1D
		jmp	sorry			;sleep
ok1D		clrb
		ldaa	#$1D
		int	$2F			;set vector
		sei
		sts	tmps
		lds	#int1D
		des
		ldab	#int1D_-int1D
int1D_loop	pula
		staa	x
		inx
		decb
		bne	int1D_loop
		lds	tmps
		cli

;--
		ldx	#int1E_-int1E
		clrb
		int	$2A
		cpx	#0
		bne	ok1E
		jmp	sorry			;sleep
ok1E		clrb
		ldaa	#$1E
		int	$2F			;set vector
		sei
		sts	tmps
		lds	#int1E
		des
		ldab	#int1E_-int1E
int1E_loop	pula
		staa	x
		inx
		decb
		bne	int1E_loop
		lds	tmps
		cli

;--
		ldx	#int1F_-int1F
		clrb
		int	$2A
		cpx	#0
		bne	ok1F
		jmp	sorry			;sleep
ok1F		clrb
		ldaa	#$1F
		int	$2F			;set vector
		sei
		sts	tmps
		lds	#int1F
		des
		ldab	#int1F_-int1F
int1F_loop	pula
		staa	x
		inx
		decb
		bne	int1F_loop
		lds	tmps
		cli
;--
		ldx	#clock_-clock
		clrb
		int	$2A
		cpx	#0
		bne	okclock
		jmp	sorry			;sleep
okclock 	sei				;!!!
		ldab	MEMPAGE_SEL		;!!!
		ldaa	#6			;clock_int
		int	$2F			;set vector
		sei
		sts	tmps
		lds	#clock
		des
		ldab	#clock_-clock
clock_loop	pula
		staa	x
		inx
		decb
		bne	clock_loop
		lds	tmps
		cli
;--
		ldaa	#$67			; EditLine
		int	$2E
		cpx	#0
		bne	edit_ok
		ldaa	#$21			; if not available
		int	$2E			; make it like GetLine
		ldaa	#$67
		int	$2F
edit_ok
		ldaa	#$25			;prdec
		int	$2E
		cpx	#0
		bne	prhex_ok
		ldx	#int25_-int25
		clrb
		int	$2A
		cpx	#0
		bne	ok25
		jmp	sorry			;sleep
ok25		ldab	MEMPAGE_SEL
		ldaa	#$25
		int	$2F			;set vector
		sei
		sts	tmps
		lds	#int25
		des
		ldab	#int25_-int25
int25_loop	pula
		staa	x
		inx
		decb
		bne	int25_loop
		lds	tmps
		cli
prhex_ok
		ldaa	#$24			;prdec
		int	$2E
		cpx	#0
		bne	prdec_ok
		ldx	#int24_-int24
		clrb
		int	$2A
		cpx	#0
		bne	ok_24
		jmp	sorry
ok_24		ldab	MEMPAGE_SEL	;!!!
		ldaa	#$24
		int	$2F			;set vector
		sei
		sts	tmps
		lds	#int24
		des
		ldab	#int24_-int24
int24_loop	pula
		staa	x
		inx
		decb
		bne	int24_loop
		lds	tmps
		cli
prdec_ok
		ldaa	#$6D
		int	$2E
		cpx	#0
		bne	int_6Dok
		ldx	#int6D_-int6D
		clrb
		int	$2A
		cpx	#0
		bne	ok_6D
		jmp	sorry
ok_6D		ldab	MEMPAGE_SEL	;!!!
		ldaa	#$6D
		int	$2F			;set vector
		sei
		sts	tmps
		lds	#int6D
		des
		ldab	#int6D_-int6D
int6D_loop	pula
		staa	x
		inx
		decb
		bne	int6D_loop
		lds	tmps
		cli
int_6Dok
;---------------
		ldab	bios_version		; a bug in move mem (int_2D)
		ldaa	bios_version+1		; in versions < 2.50
		cmpb	#2
		bne	clow
		cmpa	#50
clow		bcc	int_2Dok

		ldaa	#$2D			; original vector
		int	$2E
		stx	old2D_a
		stab	old2D_p

		ldx	#int2D_-int2D
		clrb
		int	$2A
		cpx	#0
		bne	ok_2D
		jmp	sorry

ok_2D		ldab	#0
		ldaa	#$2D
		int	$2F			;set vector
		sei
		sts	tmps
		lds	#int2D
		des
		ldab	#int2D_-int2D
int2D_loop	pula
		staa	x
		inx
		decb
		bne	int2D_loop
		lds	tmps
		cli
int_2Dok
		ldx	#81
		clrb
		int	$2a
		cpx	#0
		bne	getline_ok
sorry		jmp	$F000		;monitor
getline_ok	stx	getline_buffer
		clr	x

		ldx	#9
		clrb
		int	$2A		;allocate
		cpx	#0
		beq	sorry
		sei
		sts	tmps
		lds	fddparms
		des
		stx	fddparms
		ldab	#9
p_loop		pula
		staa	x
		inx
		decb
		bne	p_loop
		lds	tmps
		cli
		int	$2C		;set resident

		tst	hard_version
		bpl	only_601

		ldx	#aux_header_ - aux_header
		clrb
		int	$2A		;allocate
		cpx	#0
		beq	sorry
		stx	x1
		sei
		sts	tmps
		lds	#aux_header
		des
		ldab	#aux_header_ - aux_header
p_loop1 	pula
		staa	x
		inx
		decb
		bne	p_loop1
		lds	tmps
		cli
		int	$2C	;set resident

		ldab	#7	; RAM ; //FIXME CHECKME
		ldx	x1
		int	$5E

only_601
		ldx	#terminate
		ldab	MEMPAGE_SEL
		ldaa	#$38
		int	$2F

		ldx	#system
		ldab	MEMPAGE_SEL
		ldaa	#$39
		int	$2F

		ldx	#int_3a
		ldab	MEMPAGE_SEL
		ldaa	#$3A
		int	$2F

		ldx	#reset
		ldab	MEMPAGE_SEL
		ldaa	#$1
		int	$2F

		ldx	#int_3b
		ldab	MEMPAGE_SEL
		ldaa	#$3b
		int	$2F

		ldx	#int_3c
		ldab	MEMPAGE_SEL
		ldaa	#$3c
		int	$2F

		ldx	#int_3F 	;create full path
		ldab	MEMPAGE_SEL
		ldaa	#$3F
		int	$2F

		ldx	#int_68
		ldab	MEMPAGE_SEL
		ldaa	#$68
		int	$2F

		ldx	#int_69
		ldab	MEMPAGE_SEL
		ldaa	#$69
		int	$2F

		ldx	#int_6A
		ldab	MEMPAGE_SEL
		ldaa	#$6A
		int	$2F

		ldx	#pr_pack
		ldab	MEMPAGE_SEL
		ldaa	#$78
		int	$2F

		ldaa	#$4a
		int	$2E
		stab	old_open_p
		stx	old_open_a

		ldaa	#$4b
		int	$2E
		stab	old_create_p
		stx	old_create_a

		ldaa	#$17
		int	$2E
		stab	old17_p
		stx	old17_a

		ldaa	#$5B
		int	$2E
		stab	old5B_p
		stx	old5B_a


		ldx	#new_open
		ldab	MEMPAGE_SEL
		ldaa	#$4A
		int	$2F

		ldx	#new_create
		ldab	MEMPAGE_SEL
		ldaa	#$4B
		int	$2F

;//FIXME
;		ldx	#new_17
;		tst	configuration
;		bne	ok_17
;		ldx	#false_17
;ok_17		clrb
;		ldaa	#$17
;		int	$2F

		ldx	#new_5B
		ldab	MEMPAGE_SEL
		ldaa	#$5B
		int	$2F

		ldx	#get_err_text
		ldab	MEMPAGE_SEL
		ldaa	#$3D
		int	$2F

		ldaa	#1
		staa	echo_flag
		ldx	#0
		stx	current_PCB
		ldx	#empty_string
		jsr	build_PCB
		tsta
		beq	set_break
		jmp	sorry
set_break
		ldx	#break1
		ldab	MEMPAGE_SEL
		ldaa	#4
		int	$2F

		ldaa	#7
		ldab	MEMPAGE_SEL
		ldx	#critical
		int	$2f

		ldx	#copyright
		int	$78
		jmp	start_dos
		endp			;relocate

;-----------------------------------------------------------
; INT 2D - move memory bug fix - collision with monitor vars
;-----------------------------------------------------------
int2d		proc

monA1		equ	$10
monA2		equ	$12

		ldx	monA1
		stx	savA1
		ldx	monA2
		stx	savA2

		ldx	old2D_a
		ldab	old2D_p
		bsr	original

		ldx	savA1
		stx	monA1
		ldx	savA2
		stx	monA2
		rts

original	int	$37		; chain interrupt
		rts			; just in case
		endp
int2D_
;-----------------------------------------------------------
; INT 6D - get max screen col & row   in A and B
;-----------------------------------------------------------
int6D		proc
		ldx	#scrmarg
		ldaa	scrmode
		beq	break
loop		inx
		inx
		deca
		bne	loop
break		ldab	1,x
		ldaa	0,x
		stab	swib
		ldab	scrmode
		andb	#3
		beq	ok
		tst	hard_version
		bpl	ok
		asla
ok		staa	swia
		rts
		endp
int6D_

;---------------
int24		proc
		ldab	swix
		ldaa	swix+1
		staa	lint
		stab	lint+1
		clr	lint+2
		clr	lint+3
		ldx	#lint
		jmp	pr_dec_24
		endp
int24_

int25		proc			; ®≠≤•∞∫Ø≤ ß† Ø•∑†≤†≠• ≠† °†©≤ ¢
prhex2		psha			; ¢ ∏•±≤≠†§•±•≤®∑•≠ ¥Æ∞¨†≤
		lsra
		lsra
		lsra
		lsra
		bsr	prhex1
		pula
prhex1		anda	#$f
		oraa	#$30
		cmpa	#$3a
		bcs	prhexz
		adda	#7
prhexz		int	$22
		rts
		endp
int25_

aux_header
		db	'AUX     '
		dw	aux_read
		dw	aux_write
		dw	aux_init
		db	0, 0, 0
aux_header_
;-----------------------------------------------------------
;-----------------------------------------
; GET SYSTEM TIME
;-----------------------------------------
;RETURN:
;	 BA - hh:mm
;	 X - sec:hundreds
;-----------------------------------------
int1C		proc
		sei
		ldaa	seconds
		staa	swix
		ldaa	hundreds
		staa	swix+1
		ldaa	minutes
		ldab	hours
		jmp	rtswib
		endp
int1C_

;-----------------------------------------
; SET SYSTEM TIME
;-----------------------------------------
;ENTER :
;	 BA - hh:mm
;	 X - sec:hundreds
;ret : A = FF	- invalid time
;-----------------------------------------
int1D		proc
		sei

		cmpb	#24
		bcc	dtm_error
		cmpa	#60
		bcc	dtm_error
		ldaa	swix
		cmpa	#60
		bcc	dtm_error
		ldaa	swix+1
		cmpa	#100
		bcc	dtm_error

		staa	hundreds
		ldaa	swix
		staa	seconds
		ldaa	swia
		staa	minutes
		stab	hours

		clr	swia
		rts
dtm_error
		ldaa	#$FF
		staa	swia
		rts
		endp
int1D_

;-----------------------------------------
; GET SYSTEM DATE
;-----------------------------------------
;RETURN:
;	 BA - dd:mm
;	 X - year
;-----------------------------------------
int1E		proc
		sei
		ldx	year
		ldaa	month
		ldab	day
		jmp	rtswix
		endp
int1E_

;-----------------------------------------
; SET SYSTEM DATE
;-----------------------------------------
;ENTER :
;	 BA - dd:mm
;	 X - year
;ret : A = FF	- invalid time
;-----------------------------------------
int1F		proc
		sei
		cmpb	#32
		bcc	dtm_error
		cmpa	#13
		bcc	dtm_error
		ldaa	swix+1
		suba	#1980
		bmi	dtm_error
		ldab	swix
		sbcb	#/1980
		bne	dtm_error

		ldx	swix
		stx	year
		ldaa	swia
		staa	month
		ldab	swib
		stab	day
		clr	swia
		rts
dtm_error
		ldaa	#$FF
		staa	swia
		rts
		endp
int1F_

;--------------------------------------
; CLOCK SHOW  interrupt driven ! //FIXME
;--------------------------------------
clock		proc
		sei
		ldaa	scrmode
		anda	#3
		bne	return

		ldx	#system_line
		ldaa	scrmode
		bne	clock1		;mode text 80
		ldaa	#$60
;;		staa	78,x		;attr. for int17 for text 40
clock1
		ldaa	scrmode
		beq	clock2_ 	;date not displayed in text 40

		ldab	$9c		;day
		bsr	conv
		cmpa	#'0'
		bne	day
		ldaa	#' '
day		bsr	store
		tba
		bsr	store
		ldaa	#' '
		bsr	store
		stx	clock_save_sp
		ldaa	$9D		;month
		asla
		asla
		clrb
		adda	#months
		adcb	#/months
		staa	clock_temp+1
		stab	clock_temp
		ldx	clock_temp
		ldaa	0,x
		staa	clock_temp
		ldx	1,x
		stx	clock_temp+1
		ldx	clock_save_sp
		ldaa	clock_temp
		bsr	store
		ldaa	clock_temp+1
		bsr	store
		ldaa	clock_temp+2
		bsr	store
		ldaa	#' '
		bsr	store
		ldab	$9F
		subb	#1900
		bsr	conv
		bsr	store
		tba
		bsr	store
		ldaa	#' '
		bsr	store
		bsr	store
		bsr	store
clock2_ 	bra	clock2

;---------------
store
		tst	scrmode 	;only text modes !
		bne	store80
;;		staa	61,x
		ldaa	#$60		;attribute
;;		staa	60,x
		inx
		inx
return		rts

store80 	;;staa	58,x
		inx
		rts

conv		clra
loop		cmpb	#10
		bcs	conv_done
		inca
		subb	#10
		cmpa	#10
		bne	loop
		clra
		bra	loop
conv_done	adda	#'0'
		addb	#'0'
		rts
;---------------
clock2
		ldab	$9b		;hours
		bsr	conv
		cmpa	#'0'
		bne	hours
		ldaa	#' '
hours		bsr	store
		tba
		bsr	store
		ldaa	#':'
		bsr	store
		ldab	$9a		;minutes
		bsr	conv
		bsr	store
		tba
		bsr	store
		ldaa	#':'
		bsr	store
		ldab	$99		;seconds
		bsr	conv
		bsr	store
		tba
		bsr	store

		sts	clock_save_sp
		lds	#system_line-1
		ldx	system_scrbase
		ldaa	hard_version
		beq	_601
		cmpa	#$80
		beq	_601a
		bra	done		;unknown hardware version

_601		ldab	#40
_601_loop	pula			;attr. ignored
		pula
;;		staa	42,x		;on 27-th line
		inx
		decb
		bne	_601_loop
		bra	done

_601a		ldab	#80
_601a_loop	pula
;;		staa	80,x		;on 27-th line
		inx
		decb
		bne	_601a_loop
done
		lds	clock_save_sp
		cli
		rts

		endp
clock_

;-----------------------------------------------------------
		checksum
author_text
		db	13,10,10
		db	'UniDOS (R) operating system and BIOS were written by',13,10
		db	'Ivo Nenov and Orlin Shopov - Eagle software at the',13,10
		db	'SOFTWARE Research & Development Laboratory - Sofia',13,10
;		db	'UniBIOS was written together with Leonid Kalev.',13,10
;		db	'UniPascal was written by George Petrov - YGP.',13,10
		db	10,10,0

		ds	10001 - $2000 + $1000 - *, $FF		;make size of
init_end		; file exactly 10001 bytes
start_move
		org	$C000
resident_start


commands	db	'DIR', 0
		dw	show_dir

		db	'COPY', 0
		dw	copy_files

		db	'REN', 0
		dw	rename_files
		db	'DEL', 0
		dw	delete
		db	'MD', 0
		dw	make_dir
		db	'RD', 0
		dw	remove_dir
		db	'CD', 0
		dw	change_dir
date_cmd	db	'DATE', 0
		dw	set_date
time_cmd	db	'TIME', 0
		dw	set_time
		db	'TYPE', 0
		dw	type
		db	'PRINT', 0
		dw	print
		db	'MON', 0
		dw	monitor
		db	'CLS', 0
		dw	clr_scr
		db	'EXIT', 0
		dw	exit_dos
		db	'VER', 0
		dw	pr_version
		db	'HANDLES', 0
		dw	handles
		db	'MODE', 0
		dw	mode
		db	'ECHO', 0
		dw	echo_cmd
		db	'PAUSE', 0
		dw	pause_cmd
		db	'REM', 0
		dw	exec_nothing

		db	0




;-------------------------------------------
;UniDOS entry point
;-------------------------------------------
start_dos	proc
		global	wait_cmd

		jsr	open_std_files

		ldx	#autoexec
		int	$39			;system call
		tsta
		beq	wait_cmd
		ldx	#date_cmd
		int	$39
		ldx	#time_cmd
		int	$39

wait_cmd
		ldx	current_pcb
		ldx	x, parent_pcb
		bne	not_first
		jsr	open_std_files
not_first
		ldx	current_pcb
		tst	x, pcb_job_file
		bpl	pr_newline
		tst	echo_flag
		beq	pr_prompt
pr_newline	jsr	writeln
pr_prompt	jsr	print_prompt

		ldx	current_PCB
		tst	x, pcb_job_file
		bpl	read_kbd
		bsr	read_line
		bra	do_cmd
read_kbd
		ldx	getline_buffer
		ldab	#80
		clra				;handle 0
		int	$57
		tst	x
		bne	do_cmd
		clra
		ldab	#1
		int	$58
		tstb
		beq	pr_prompt
		jsr	reopen_stdin
		bra	wait_cmd
do_cmd
		ldx	#break
		ldab	MEMPAGE_SEL
		ldaa	#4
		int	$2F

		ldx	getline_buffer
		int	$39			;System call

		psha
		ldx	current_PCB
		tst	x, pcb_job_file
		bmi	popa
		ldx	#break1 		;RTS
		ldab	MEMPAGE_SEL
		ldaa	#4
		int	$2F
popa		pula

		jsr	print_error
		tst	exit_flag
		beq	wait_cmd

		clr	exit_flag
		ldx	current_PCB
		ldx	x, parent_PCB
		beq	wait_cmd

		jsr	close_PCB
		clr	swia
		rts

console 	db	'CON:', 0
printer 	db	'PRN:', 0
auxilary	db	'AUX:', 0

autoexec	db	'AUTOEXEC.JOB', 0

read_line
		ldx	current_PCB
		ldaa	x, pcb_job_file
		ldab	#1		;text file
		anda	#$7F
		int	$58
		tsta
		bne	error
		tstb
		bne	end_file
		ldx	current_PCB
		ldaa	x, pcb_job_file
		anda	#$7F
		ldab	#80
		ldx	lomem
		int	$57
		tsta
		beq	expand_line
error
end_file	int	$38		;exit from .JOB file

expand_line
		ldx	lomem
		stx	x1
		ldx	getline_buffer
		stx	x2
		ldaa	#80
		staa	a1
exp_loop
		ldx	x1
		ldaa	x
		beq	end_str_found
		inx
		stx	x1
		cmpa	#'%'
		bne	put_it
		ldaa	x
		beq	end_str_found
		inx
		stx	x1
		suba	#'0'
		cmpa	#10
		bcc	exp_loop		;>=

		bsr	exp_copy_parm
		bra	exp_loop

put_it		bsr	getline_put
		bra	exp_loop

end_str_found
		ldx	x2
		clr	x
		tst	echo_flag
		beq	no_echo
		ldx	getline_buffer
		int	$23
;		jsr	writeln
no_echo 	rts

getline_put	proc
		tst	a1
		beq	return

		dec	a1
		ldx	x2
		staa	x
		inx
		stx	x2
return		rts
		endp

exp_copy_parm	proc
		asla
		adda	#pcb_argv
		staa	patch
		ldx	current_pcb
patch		=	* + 1
		ldx	x, 0
		beq	return
		stx	exp_x
loop		ldx	exp_x
		ldaa	x
		beq	return
		inx
		stx	exp_x
		bsr	getline_put
		bra	loop
return		rts
;exp_x		 ds	 2
		endp
;------------
reopen_stdin	clra
		int	$4E
		ldx	#console
		ldaa	#1
		bra	open_std

open_std_files
		clra
close_lp
		psha
		int	$4E
		pula
		inca
		cmpa	#5
		bne	close_lp

		ldx	#console
		ldaa	#1
		bsr	open_std		;stdin
		ldx	#console
		ldaa	#2
		bsr	open_std		;stdout
		ldx	#console
		ldaa	#2
		bsr	open_std		;stderr

		ldx	#auxilary
		ldaa	#3
		bsr	open_std		;stdaux

		ldx	#printer
		ldaa	#2
;		bsr	open_std		;stdprn
;		rts
open_std
		psha
		stx	x1
		ldx	lomem
		stx	x2
		jsr	str_copy
		pula
		ldx	lomem
		jmp	open_file
		endp


build_PCB	proc
		stx	build_pcb_x

		ldx	himem
		stx	x1

		clrb
		ldx	#pcb_length
		int	$2A		;Allocate memory
		cpx	#0
		bne	alloc_ok
		ldaa	#_INSF_MEM
		rts

alloc_ok	stx	x2

		sei
		sts	tmps
		clr	x, pcb_job_file
		lds	x1		;himem
		sts	x, pcb_himem
		lds	lomem
		sts	x, pcb_lomem
		lds	current_PCB
		sts	x, parent_PCB
		stx	current_PCB
		lds	#0
		sts	x, pcb_open_files
		sts	x, pcb_open_files+2
		lds	#$FFFF
		sts	x, pcb_old_input	;x, pcb_old_output
		ldaa	indos
		staa	x, pcb_indos
		lds	tmps
		cli

		tsx
		inx			;Skip return address
		inx
		stx	x1
		ldaa	himem+1
		ldab	himem
		suba	x1+1
		sbcb	x1
		ldx	x2
		staa	x, pcb_stack+1
		stab	x, pcb_stack

		ldaa	#4		;Break
		int	$2E
		stx	x1
		ldx	x2
		stab	x, pcb_break+2
		ldaa	x1+1
		ldab	x1
		staa	x, pcb_break+1
		stab	x, pcb_break

		ldaa	#7		;Critical error
		int	$2E
		stx	x1
		ldx	x2
		stab	x, pcb_error_hndl+2
		ldaa	x1+1
		ldab	x1
		staa	x, pcb_error_hndl+1
		stab	x, pcb_error_hndl

		ldaa	#1		;Reset
		int	$2E
		stx	x1
		ldx	x2
		stab	x, pcb_reset+2
		ldaa	x1+1
		ldab	x1
		staa	x, pcb_reset+1
		stab	x, pcb_reset

		ldaa	#$A		;Keyboard macro definitions
		int	$2E
		stx	x1
		ldx	x2
		stab	x, pcb_macro+2
		ldaa	x1+1
		ldab	x1
		staa	x, pcb_macro+1
		stab	x, pcb_macro

		ldx	build_pcb_x
		jsr	str_length
		tsta
		bne	allocate
		tstb
		bne	allocate
		ldx	#0
		bra	store_ptr
allocate
		adda	#3		;3 bytes more
		adcb	#0
		staa	x1+1
		stab	x1
		ldx	x1
		clrb
		int	$2A
store_ptr
		stx	x1
		ldx	x2
		ldaa	x1+1
		ldab	x1
		staa	x, pcb_argv_ptr+1
		stab	x, pcb_argv_ptr

		clra
		rts
		endp


close_PCB	proc
		pulb
		pula
		stab	ret_addr
		staa	ret_addr+1

		ldx	current_PCB
		stx	x2

		ldx	x, parent_PCB
		bne	cont
		ldx	$FFFE			;Reset vector
		jmp	x			;Cold boot
cont
		clra
		ldab	#1
		ldx	x2
close_loop	cmpa	#maxfiles
		beq	exitl1
		bitb	x, pcb_open_files+3	;LSB
		beq	inc_cnts
		psha
		int	$4E		;close file
		pula
inc_cnts	inca
		aslb
		bcc	close_loop
		ldab	#1
		dex
		bra	close_loop
exitl1
		ldx	x2
		ldaa	x, pcb_old_input
		bmi	close_out
		int	$59
close_out
		ldaa	x, pcb_old_output
		bmi	restore_indos
		int	$59
restore_indos
		ldaa	x, pcb_indos
		staa	indos

		ldab	x, pcb_break+2
		ldx	x, pcb_break
		ldaa	#4
		int	$2F

		ldx	x2
		ldab	x, pcb_error_hndl+2
		ldx	x, pcb_error_hndl
		ldaa	#7
		int	$2F

		ldx	x2
		ldab	x, pcb_reset+2
		ldx	x, pcb_reset
		ldaa	#1
		int	$2F

		ldx	x2
		ldab	x, pcb_macro+2
		ldx	x, pcb_macro
		ldaa	#$A
		int	$2F

		int	$13
		tsta
		beq	scrn_ok
		cmpa	#3
		bhi	scrn_ok

		int	$63
		stx	x1
		ldaa	resident+1
		ldab	resident
		cmpb	x1
		bne	diff1
		cmpa	x1+1
diff1		bls	scrn_ok
		int	$61
scrn_ok
		ldx	x2
		ldaa	himem+1
		ldab	himem
		suba	x, pcb_stack+1
		sbcb	x, pcb_stack
		staa	x1+1
		stab	x1
		ldx	x1
		txs

		ldx	x2
		ldx	x, parent_PCB
		stx	current_PCB

		ldx	x2
		ldx	x, pcb_lomem
		stx	lomem

		ldx	x2
		ldx	x, pcb_himem
		int	$2B
return
		ldx	ret_addr
		jmp	x

;ret_addr	 ds	 2
		endp


;-------------------------------------------
; INT $39  -  System call
;      IMPORT: X - command line pointer
;      EXPORT: A - error code
;-------------------------------------------
system		proc
		global	terminate		;Int $38

		stx	system_x

		clr	exit_flag
		bsr	test_mem
		bcs	ret_err

		ldx	system_x
		jsr	build_PCB
		tsta
		bne	ret_err

		ldx	#0
		stx	redir_in_ptr
		stx	redir_out_ptr
		clr	redir_double
		ldx	system_x
		jsr	parse_line
		stx	exec_addr

		bsr	redirect

		clrb
		ldx	#0
		ldaa	#$A			;Disable kbd. macros
		int	$2F

		ldx	current_PCB
		ldaa	#1
		staa	x, pcb_internal

		ldx	exec_addr
		bne	do_it			;Internal command ?

		ldaa	#$FF
		int	$3e
		tsta
		beq	return_address

		ldx	current_PCB
		clr	x, pcb_internal 	;external command
		jsr	execute
		tsta
		bne	internal_cmd
do_it
		jsr	x
return_address
		ldx	current_PCB
		tst	x, pcb_internal
		bne	internal_cmd
		clra
internal_cmd	staa	swia			;Error code by internal command
prog_exit	jsr	close_PCB
		rts

ret_no_err	clra
ret_err 	staa	swia
		rts
;exec_addr	 ds	 2

terminate					;Terminate program ( Int $38 )
		tsx
		ldaa	MEMPAGE_SEL
		staa	x, 2
		ldaa	#return_address
		staa	x, 9
		ldaa	#/return_address
		staa	x, 8
		rts
		endp

test_mem	proc
		sts	x1
		ldab	lomem
		ldaa	lomem+1
		addb	#6
		cmpb	x1
		bne	differ
		cmpa	x1+1
differ		bhi	no_mem
		clra
;		clc
		rts
no_mem		ldaa	#_INSF_MEM
		sec
		rts
		endp

redirect	proc
		ldx	redir_in_ptr
		beq	test_out
		clra		;ldaa	#0
		int	$59		;move hndl
		tsta
		bne	test_out
		ldx	current_pcb
		stab	x, pcb_old_input
		ldx	redir_in_ptr
		bsr	make_table
		ldaa	#1
		ldx	#table
		int	$4A
		tsta
		beq	test_out
		ldx	current_pcb
		ldaa	x, pcb_old_input	;recover old input
		int	$59
		ldaa	#$FF
		staa	x, pcb_old_input
test_out
		ldx	redir_out_ptr
		beq	return
		ldaa	#1
		int	$59
		tsta
		bne	return
		ldx	current_pcb
		stab	x, pcb_old_output
		tst	redir_double
		bne	append
create		ldx	redir_out_ptr
		bsr	make_table
		clra
		ldx	#table
		int	$4B
		tsta
		bne	rec_old
		bra	return
append
		ldx	redir_out_ptr
		bsr	make_table
		ldaa	#2
		ldx	#table
		int	$4A
		tsta
		beq	seek
		cmpa	#_INV_PATH
		beq	create

rec_old 	ldx	current_pcb
		ldaa	x, pcb_old_output	;recover old input
		int	$59
		ldaa	#$FF
		staa	x, pcb_old_output
return		rts

seek		ldx	#0
		stx	lint
		stx	lint+2
		ldaa	#1
		ldab	#2
		ldx	#lint
		int	$50
		rts

make_table	stx	table
		ldx	#($200 + buff_length)
		clrb
		int	$2A
		stx	table+2
		cpx	#0
		beq	ret
		stx	x1
		inc	x1
		inc	x1
		ldx	x1
		ldaa	#$FF
		staa	x, buff_drive
		clr	x, buff_modified
		clr	x, buff_n_files
ret		rts
		endp

;-------------------------------------------
; INT $3A  -  Exit to dos
;-------------------------------------------
int_3A		proc
		jsr	test_mem
		bcs	ret_err

		ldx	#empty_string
		jsr	build_PCB
		tsta
		bne	ret_err

		ldx	#break1 		;RTS
		ldab	MEMPAGE_SEL
		ldaa	#4
		int	$2F

		jsr	pr_version
		jmp	wait_cmd

ret_err 	staa	swia
		rts
		rts
		endp


;-------------------------------------------
; INT $3B  -  Argc
;     EXPORT: A - argc
;-------------------------------------------
int_3B		proc
		ldx	current_pcb
		ldaa	x, pcb_argc
		staa	swia
		rts
		endp


;ret:  X - current argv address
calc_argv_addr	proc
		ldaa	current_pcb+1
		ldab	current_pcb
		adda	#pcb_argv
		adcb	#0
		staa	calc_argv_x+1
		stab	calc_argv_x
		ldx	calc_argv_x
		rts
		endp


;-------------------------------------------
; INT $3C  -  Argv
;      IMPORT: A - parameter number
;	       X - buffer pointer (Max 81 bytes)
;-------------------------------------------
int_3C		proc
		clr	x
		stx	x2		;destination
		ldx	current_pcb
		cmpa	x, pcb_argc
		bcc	return		;>=

		bsr	calc_argv_addr
		ldaa	swia
loop		tsta
		beq	exitl
		inx
		inx
		deca
		bra	loop
exitl		ldx	x
		beq	return
		stx	x1
		jsr	str_copy
return		rts
		endp

;-------------------------------------------
; INT $3F  -  Full path
;      IMPORT:
;	       X - table
;		     1w - src
;		     1w - dest (lng = src_lng + 64b.)
;      EXPORT: A - error code
;-------------------------------------------
int_3F		proc
		ldx	x
		jsr	get_drive
		bcs	error

		int	$5C		;media check
		tsta
		bne	error

		ldx	swix
		ldx	x
		stx	x1
		ldx	swix
		ldx	x, 2
		stx	x2
		jsr	create_path
		ldx	swix
		ldx	x, 2
		jsr	upcase_str
		clra
error		staa	swia
		rts
		endp


new_5B		proc
		cmpa	#maxfiles
		bcs	valid
		ldaa	#maxfiles
valid		ldx	old5B_a
		ldab	old5B_p
		int	$37
		endp

new_open	proc
		global	open_it

		ldab	old_open_p
		ldx	old_open_a
		ldaa	#$5F
		int	$2F
open_it
		ldab	swib
		ldaa	swia
		ldx	swix
		int	$5F
		staa	swia
		stab	swib
		stx	swix
		tsta
		bne	exit

		cmpb	#maxfiles
		bcc	exit		;>=
		ldx	current_PCB
		ldaa	#1
loop		tstb
		beq	endl1
		asla
		bcc	decrb
		ldaa	#1
		dex
decrb		decb
		bra	loop
endl1
		oraa	x, pcb_open_files+3
		staa	x, pcb_open_files+3

exit		rts
		endp

new_create	proc
		ldab	old_create_p
		ldx	old_create_a
		ldaa	#$5F
		int	$2F
		bra	open_it
		endp

new_17		proc
		global	false_17
		tsta
		beq	direct
		cmpa	#$FF
		bne	not_direct
direct		ldab	old17_p
		ldx	old17_a
		int	$37

not_direct
		sei
		sts	tmps17
		lds	x
		sts	table17
		lds	x, 2
		sts	table17+2
		lds	x, 4
		sts	table17+4
		lds	tmps17
		cli

		ldaa	x		;drive
		bita	#%11111110
		bne	do_it
		ldab	configuration
		comb
		bitb	#3
		beq	do_it

		cmpa	last_drive
		beq	change_drive

		staa	last_drive
		ldx	#msg1
		int	$78
		adda	#'A'
		int	$22
		ldx	#msg2
		int	$78
		int	$20
		jsr	writeln

change_drive	ldaa	table17
		inca
		bita	configuration
		bne	do_it
		deca
		eora	#1
		staa	table17

do_it		ldab	old17_p
		ldx	old17_a
		ldaa	#$5F
		int	$2F

		ldaa	swia
		ldab	swib
		ldx	#table17
		int	$5F
		stab	swib
		db	$8c
false_17	ldaa	#$C0	;BAD_NEC + TIMEOUT
		staa	swia
		rts

;scr_addr	 ds	 2

msg1			;Insert diskette for drive
		dw	$D630,$5D01,$715B,$1914,$47C1,$8025,$2585,$02DF,$3B14,$00DE,$FF9B
msg2			;Strike any key when ready
		dw	$D630,$828B,$463A,$0645,$03F6,$9D13,$3598,$0235,$071A,$FDEC

		endp

break		proc
		global	break1
		clra
		int	$38
break1		rts
		endp

;------------------------------------------------
; A - mode
; X - file name
;------------------------------------------------
open_file	proc
		stx	table
		ldx	#0
		stx	table+2
		ldx	#table
		int	$4A
		rts
		endp


print_prompt	proc
		ldx	current_pcb
		tst	x, pcb_job_file
		bpl	cont
		tst	echo_flag
		beq	return
cont
		ldaa	#13
		int	$22

		int	$45
		staa	a1
		ldx	lomem
		int	$47

		ldaa	a1
		adda	#'A'
		int	$22
		ldaa	#':'
		int	$22

		tst	x
		bne	no_root
		ldaa	#'\'
		int	$22
		bra	end_prompt
no_root
		int	$23
end_prompt	ldaa	#'>'
		int	$22
return		rts
		endp


;---------------------------------------
;Parse command line
;   X - line pointer
;Ret: X - start addr
;---------------------------------------
parse_line	proc
		global	exec_nothing

		stx	src_ptr
		stx	parse_ptr

		ldx	current_pcb
		clr	x, pcb_argc
		ldx	x, pcb_argv_ptr
		beq	empty
		stx	parse_argv_ptr

		jsr	calc_argv_addr
		ldaa	#$10*2
		clrb
		jsr	mem_set

		ldx	src_ptr
		tst	x
		bne	not_empty
empty		ldx	#exec_nothing
exec_nothing	clra
		rts

not_empty
		ldx	parse_argv_ptr
		stx	dst_ptr

		ldx	#cmp_end1
		jsr	copy_parm
		ldx	current_pcb
		ldx	x, pcb_argv
		beq	empty
		ldx	parse_argv_ptr
		jsr	upcase_str

		ldx	src_ptr
		ldx	x
		cpx	#':' * 256
		bne	not_cdrv
		ldx	#change_drive
return1 	rts
not_cdrv
		ldx	#commands
		stx	parse_x
search_loop
;		ldx	parse_x
		stx	x2
		ldx	parse_argv_ptr
		stx	x1
		jsr	comp_str
		bcc	cmd_found

		ldx	parse_x
loopz		tst	x
		beq	exitz
		inx
		bra	loopz
exitz		inx
		inx
		inx
		stx	parse_x
		tst	x
		bne	search_loop
;command not found
		ldx	current_pcb
		clr	x, pcb_argc
		ldx	parse_ptr
		stx	src_ptr
		ldx	parse_argv_ptr
		stx	dst_ptr
		ldx	#0
;		stx	argv
		stx	parse_ptr
		bra	cont_parse
cmd_found
		ldx	parse_x
loopz1		tst	x
		beq	exitz1
		inx
		bra	loopz1
exitz1		inx
		ldx	x
		stx	parse_ptr
cont_parse
		bsr	skip_spaces
		tsta
		beq	ret_parse

		cmpa	#'<'
		bne	test_output
		ldx	dst_ptr
		stx	redir_in_ptr
		ldx	src_ptr
		inx
		stx	src_ptr
		bra	copy_fname

test_output	cmpa	#'>'
		bne	copy_
		ldx	src_ptr
		inx
		clr	redir_double
		ldaa	x
		cmpa	#'>'
		bne	single
		inc	redir_double
		inx
single		stx	src_ptr
		ldx	dst_ptr
		stx	redir_out_ptr

copy_fname	bsr	skip_spaces
		ldx	#cmp_end2
		stx	parse_cmp_end
		bsr	copy_it
		bra	cont_parse

copy_		ldx	#cmp_end2
		bsr	copy_parm
		bra	cont_parse
ret_parse
		ldx	parse_ptr
		rts

copy_parm	proc
		stx	parse_cmp_end
		bsr	skip_spaces
		tsta
		bne	cont
		rts
cont
		jsr	calc_argv_addr
		stx	x1
		ldx	current_pcb
		ldaa	x, pcb_argc
		inc	x, pcb_argc
		asla
		clrb
		adda	x1+1
		adcb	x1
		staa	x1+1
		stab	x1
		ldx	x1
		ldaa	dst_ptr+1
		ldab	dst_ptr
		staa	x, 1
		stab	x

		bra	copy_it
		endp


skip_spaces	proc
		ldx	src_ptr
loop_spc	ldaa	x
		cmpa	#9
		beq	inc_x
		cmpa	#' '
		bne	exit_spc
inc_x		inx
		bra	loop_spc
exit_spc	stx	src_ptr
		rts
		endp

copy_it 	proc
copy_loop	ldx	src_ptr
		ldaa	x
		ldx	parse_cmp_end
		jsr	x
		beq	exit_cl

		ldx	src_ptr
		inx
		stx	src_ptr

		ldx	dst_ptr
		staa	x
		inx
		stx	dst_ptr
		bra	copy_loop
exit_cl 	ldx	dst_ptr
		clr	x
		inx
		stx	dst_ptr
return		rts
		endp

cmp_end1	proc
		psha
		jsr	upcase_char

		cmpa	#'0'
		bcs	zero		;<
		cmpa	#'9'
		bls	one		;<=
		cmpa	#'A'
		bcs	zero		;<
		cmpa	#'Z'
		bhi	zero		;>
one		ldaa	#1
		pula
		rts
zero		clra
		pula
		rts
		endp

cmp_end2	proc
		tsta
		beq	return
		cmpa	#' '
		beq	return
		cmpa	#9		;tab
		beq	return
		cmpa	#'>'
		beq	return
		cmpa	#'<'
return		rts
		endp

		endp		;Parse line


;----------------------------------------
; Load program - file name in argv[0]
; A -  error code
;----------------------------------------
execute 	proc
		ldx	current_pcb
		ldx	x, pcb_argv
		stx	x1
		ldx	lomem
		stx	x2
		jsr	str_copy

		ldx	lomem
		jsr	upcase_str
		ldx	lomem
		jsr	find_last_name
loop1		ldaa	x
		beq	no_ext
		cmpa	#'.'
		beq	ext_found
		inx
		bra	loop1
ext_found
		stx	exec_x

		stx	x1
		ldx	#job_ext
		stx	x2
		jsr	comp_str
		bcs	cmp_pgm
		ldx	#exec_job
		bra	chk_file

cmp_pgm 	ldx	exec_x
		stx	x1
		ldx	#pgm_ext
		stx	x2
		jsr	comp_str
		bcs	set_to_cmd
		ldx	#exec_pgm
		bra	chk_file
set_to_cmd
		ldx	#exec_cmd
chk_file	stx	exec_x

		ldx	#zero_ext
		bsr	open_prog
		bcs	return
		tsta
		bne	bad_cmd
		ldx	exec_x
		jmp	x
no_ext
		ldx	#job_ext
		bsr	open_prog
		bcs	return
		tsta
		bne	chk_cmd
		jmp	exec_job
chk_cmd
		ldx	#cmd_ext
		bsr	open_prog
		bcs	return
		tsta
		bne	chk_pgm
		jmp	exec_cmd
chk_pgm
		ldx	#pgm_ext
		bsr	open_prog
		bcs	return
		tsta
		bne	bad_cmd
		jmp	exec_pgm
bad_cmd
		ldaa	#_BAD_CMD_FNAME
return		rts


open_prog	proc
		stx	x1
		ldx	lomem
loop		tst	x
		beq	exit1
		inx
		bra	loop
exit1
		stx	my_x
		stx	x2
		jsr	str_copy

		ldx	lomem
		ldaa	#1
		jsr	open_file
		tsta
		beq	return
		cmpa	#_INV_PATH		;Invalid path
		bne	error
		ldx	my_x
		clr	x
return		clc
		rts
error
		sec
		rts
;my_x		 ds	 2
		endp

exec_job	proc
		stab	exec_hndl
		tba
		ldx	#lint
		int	$51
		tsta
		beq	ok_size
		cmpa	#_NOT_DISK_FILE
		beq	bad_cmd
		rts
ok_size
		ldx	current_PCB
		ldaa	exec_hndl
		oraa	#$80
		staa	x, pcb_job_file
		jsr	writeln
		ldx	#wait_cmd
		clra
		rts
		endp

exec_cmd	proc
;B - file handle

		ldx	lomem
		cpx	#$100
		beq	ok_exec
		ldaa	#_CANT_EXEC_CMD
		rts
ok_exec
		stab	exec_hndl
		tba
		ldx	#lint
		int	$51
		tsta
		beq	ok_size
		cmpa	#_NOT_DISK_FILE
		beq	bad_cmd
		rts
ok_size 	ldx	lint
		bne	too_long
		sts	x1
		dec	x1
		ldaa	lint+3
		ldab	lint+2
		incb				;BA:= BA + $100
		cmpb	x1
		bne	differ
		cmpa	x1+1
differ		bls	ok_read

too_long	ldaa	#_INSF_MEM
fatal_error	rts

ok_read
		staa	x1+1
		stab	x1
		ldx	#$100
		stx	table
		ldx	lint+2
		stx	table+2
		ldaa	exec_hndl
		ldx	#table
		int	$4c		;read
		tsta
		bne	fatal_error

		ldaa	exec_hndl
		int	$4E
		tsta
		bne	fatal_error

		ldx	x1
		stx	lomem
		jsr	writeln

		clra
		ldx	#$100
		rts
		endp



exec_pgm	proc
;B - file handle

		stab	exec_hndl
		tba			;handle
		ldx	#lint
		int	$51
		tsta
		beq	size_ok
		cmpa	#_NOT_DISK_FILE
		beq	_bad_cmd1
_error		jmp	error
_bad_cmd1	jmp	bad_cmd

size_ok 	ldaa	exec_hndl
		ldx	#exe_header	    ;buffer
		stx	table
		ldx	#16		;REL header size
		stx	table+2
		ldx	#table
		int	$4c		;read file
		tsta
		bne	_error

		cpx	table+2
		beq	no_error_exe
		jmp	error_exe
no_error_exe
		ldx	exe_magic
		cpx	#$A55A
		beq	id_ok
		jmp	exec_cod
id_ok
		ldx	exe_n_items
		stx	count
		ldx	himem
		stx	oldhimem
		ldx	lomem
		stx	oldlomem

		ldaa	exe_data_size+1
		ldab	exe_data_size
		adda	exe_length+1
		adcb	exe_length
		staa	exe_data_size+1
		stab	exe_data_size

		ldx	exe_data_size
		ldab	#8		;page boundary
		int	$2a		;allocate
		cpx	#0
		bne	store
_no_memory	jmp	no_memory
store		stx	base
		sts	sp

		ldx	lomem
		stx	table
		stx	items_ptr
		ldaa	exe_n_items+1
		ldab	exe_n_items
		asla
		rolb
		bcs	_error_exe
		staa	table+3
		stab	table+2
		adda	lomem+1
		adcb	lomem
		incb			; $100 bytes reserve
		cmpb	sp
		bne	cmplomem
		cmpa	sp+1
cmplomem	bcc	_no_memory
		decb
		staa	lomem+1
		stab	lomem
		ldx	#table
		ldaa	exec_hndl
		int	$4c
		tsta
		bne	error_
		cpx	table+2
		beq	seek
_error_exe	jmp	error_exe
seek
		ldx	#0
		stx	table
		ldx	exe_offset
		stx	table+2
		ldx	#table
		ldaa	exec_hndl      ;seek
		clrb
		int	$50
		tsta
		beq	seek_ok
error_		jmp	error
seek_ok
		ldx	base
		stx	table
		ldx	exe_length
		stx	table+2
		ldx	#table
		ldaa	exec_hndl
		int	$4c
		tsta
		bne	error_
		cpx	table+2
		bne	_error_exe

loop		ldx	count
		beq	call
		dex
		stx	count

		ldx	items_ptr
		ldaa	1,x
		ldab	0,x
		inx
		inx
		stx	items_ptr

		adda	base+1
		adcb	base
		bcs	error_exe
		staa	ptr+1
		stab	ptr
		cmpb	oldhimem
		bne	cmphimem
		cmpa	oldhimem+1
cmphimem	bcc	error_exe	; pointer is invalid
		ldx	ptr
		ldaa	x
		adda	base		;page
		staa	x
		bra	loop

call
		ldab	exe_entry
		ldaa	exe_entry+1
		cmpb	exe_length
		bne	cmpentry
		cmpa	exe_length+1
cmpentry	bcs	call_ok
		jmp	error_exe
call_ok 	adda	base+1
		adcb	base
		staa	ptr+1
		stab	ptr

		ldx	oldlomem
		stx	lomem

		ldaa	exec_hndl
		int	$4E			;close file
		tsta
		bne	error

		jsr	writeln

		clra
		ldx	ptr
		rts

no_memory	ldaa	#_INSF_MEM
		rts
error_exe	ldaa	#_BAD_EXE_FILE
error		rts
no_language	ldaa	#_NO_LANGUAGE
		rts

;sp		 ds	 2
;base		 ds	 2
;count		 ds	 2
;oldhimem	 ds	 2
;oldlomem	 ds	 2
;items_ptr	 ds	 2
;ptr		 ds	 2

exec_cod
		jsr	writeln
		ldaa	exec_hndl
		ldab	#$FF			;just in case no pascal
		cpx	#$C0DE
		beq	pascal
		int	$32
		bra	exec_cod1
pascal		int	$A0
exec_cod1	cmpb	#$FF
		beq	no_language
;		ldaa	exec_hndl
;		int	$4E			;close
;		tsta
;		bne	ret
		ldx	#ret
		clra
ret		rts

		endp


job_ext 	db	'.JOB', 0
cmd_ext 	db	'.CMD', 0
pgm_ext 	db	'.PGM'
zero_ext	db	0
		endp

;------------------------------------------
;	X - name pointer
;ret:	A<>0 - has wildcard
;------------------------------------------
expand_name	proc
		stx	exp_name
		jsr	upcase_str
		ldx	exp_name
		jsr	get_drive
;
;while x2^<>0 do
;  inc(x2);
;  if (x1^ = '.') and (x2^='\' or x2^=0) then str_copy
;  else if x2^='\' then inc(x2); x1:= x2;
;
		stx	ex1
		stx	ex2

cont
		bra	else
loop1
		tst	x
		beq	exit_l1
		inx
		stx	ex2
loop11		ldx	ex1
		ldaa	x
		inx
		cpx	ex2
		bne	else
		cmpa	#'.'
		bne	else
		ldx	ex2
		ldaa	x
		beq	copy0
		cmpa	#'\'
		beq	copy
		bra	else
		;x1 = '.' and (x2='\' or x2=0)
copy		inx
		stx	x1
		ldx	ex1
		stx	x2
		jsr	str_copy
		bra	loop11
copy0		ldx	ex1
		stx	x2
		ldx	#all_files+1
		bra	copy_ext
else
		ldx	ex2
		ldaa	x
		cmpa	#'\'
		bne	loop1
		inx
		stx	ex1
		stx	ex2
		bra	loop1
exit_l1
		ldaa	#%00010000
		ldab	#%10001000
		ldx	exp_name
		jsr	find_entry
		tsta
		beq	found
		cmpa	#_INV_PATH
		beq	chk_wild
		int	$38
found
		ldx	ex2
		stx	x2
		ldx	#all_files
copy_ext	stx	x1
		jsr	str_copy
		bra	exit_wild
chk_wild
		ldx	ex1
loopw		ldaa	x
		beq	no_wild
		cmpa	#'?'
		beq	exit_wild
		cmpa	#'*'
		beq	exit_wild
		inx
		bra	loopw
exit_wild
		ldaa	#1
		rts
no_wild
		ldx	exp_name
		jsr	get_drive
		stx	x2
		ldx	x
		cpx	#'\'*256
		bne	no_root
		inc	x2+1
		ldx	#all_files+1
		stx	x1
		jsr	str_copy
		bra	exit_wild

no_root 	clra
		rts
		endp

all_files	db	'\'
all		db	'*.*', 0



;------------------------------------------
;	X1 - src
;	X2 - dest
;------------------------------------------
create_path	proc
		ldx	x2
		stx	ex2
		ldx	x1
		jsr	get_drive
		stx	ex1
		staa	exp_drive
		adda	#'A'

		ldx	ex2
		staa	x
		inx
		ldaa	#':'
		staa	x
		inx
		stx	ex2
		stx	exp_name

		ldx	ex1
		ldaa	x
		cmpa	#'\'
		beq	copy_name

		ldaa	exp_drive
		ldx	ex2
		int	$47			;get current dir
		tsta
		beq	no_error
		int	$38
no_error
		ldx	ex2
loop1		tst	x
		beq	exit_l1
		inx
		bra	loop1
exit_l1 	ldaa	#'\'
		staa	x
		inx
		clr	x
		stx	ex2
copy_name
		ldx	ex2
		stx	x2
		ldx	ex1
		stx	x1
		jsr	str_copy

optimize
		ldx	exp_name
loop2		tst	x
		beq	exit2
		ldaa	x
		cmpa	#'\'
		bne	inc_x
		ldaa	x, 1
		cmpa	#'.'
		bne	inc_x
		ldaa	x, 2
		bsr	cmp_end
		beq	move_1
		cmpa	#'.'
		bne	inc_x
		ldaa	x, 3
		bsr	cmp_end
		beq	move_2
inc_x		inx
		bra	loop2
exit2		rts

cmp_end 	tsta
		beq	ret
		cmpa	#'\'
ret		rts

move_2		stx	x2
		inx
		inx
		inx
		stx	x1
		ldx	x2
		dex
loop3		ldaa	x
		cmpa	#'\'
		beq	exit3
		dex
		bra	loop3
exit3		stx	x2
move_it 	jsr	str_copy
		ldx	x2
		bra	loop2

move_1		stx	x2
		inx
		inx
		stx	x1
		bra	move_it
		endp

;------------------------------------------
;	       COMMANDS
;------------------------------------------

exit_dos	proc
		ldaa	#1
		staa	exit_flag
		clra
		rts
		endp

monitor 	proc
		int	$30
		clra
		rts
		endp

change_drive	proc
		ldx	current_pcb
		ldx	x, pcb_argv
		ldaa	x
		suba	#'A'
		int	$44
		rts
		endp

change_dir	proc
		ldx	current_pcb
		ldx	x, pcb_argv+2
		beq	inv_parm
		int	$46
		rts
		endp

make_dir	proc
		ldx	current_pcb
		ldx	x, pcb_argv+2
		beq	inv_parm
		int	$48
		rts
		endp

remove_dir	proc
		global	inv_parm
		ldx	current_pcb
		ldx	x, pcb_argv+2
		beq	inv_parm
		int	$49
		rts
inv_parm
		ldaa	#_INV_NUM_PARMS
		rts
		endp


type		proc
		jsr	writeln_stdout
		ldaa	#1
		bra	type_print
		endp

print		proc
		ldaa	#4	;std_prn
		endp
type_print	proc
		staa	a1

		ldx	current_pcb
		ldx	x, pcb_argv+2
		beq	inv_parm
		ldaa	#1
		jsr	open_file
		tsta
		bne	error
		stab	x1

loop		ldx	lomem
		stx	table
		ldx	#$200
		stx	table+2
		ldaa	x1
		ldx	#table
		int	$4C
		stx	table+2
		ldaa	a1
		ldx	#table
		int	$4D
		ldx	#$200
		cpx	table+2
		beq	loop

exit		clra
error		rts
		endp



;---------------------------------------
set_date	proc
		int	$1E
		jsr	store_buff

		ldx	current_pcb
		ldx	x, pcb_argv+2
		bne	enter

		ldx	#msg1
		int	$68

		ldaa	set_buff
		jsr	pr_dec2
		ldaa	#'-'
		int	$69

		ldaa	set_buff+1
		cmpa	#13
		bcs	m_ok
		clra
m_ok		asla
		asla
		clrb
		adda	#months
		adcb	#/months
		staa	temp+1
		stab	temp
		ldx	temp
		int	$68
		ldaa	#'-'
		int	$69

		ldx	set_buff+2
		ldaa	#100
		clrb
		int	$29		;division
		stx	x1
		staa	x1
		ldaa	x1+1
		jsr	pr_dec2
		ldaa	x1
		jsr	pr_dec2
again
		ldx	#msg2
		int	$68

		ldx	lomem
		ldab	#40
		int	$21

		ldx	lomem
enter
		jsr	value
		bcc	enter1
		jmp	exit
enter1
		stab	set_buff
		tsta
		bne	enter2
		jmp	end
enter2		ldaa	#'-'
		jsr	is_delimiter
		bne	error_
		inx

		ldaa	x
		anda	#$DF
		staa	mnth
		inx
		ldaa	x
		anda	#$DF
		staa	mnth+1
		inx
		ldaa	x
		anda	#$DF
		staa	mnth+2
		inx
		stx	temp

		ldx	#months
		ldab	#12
lp		ldaa	mnth
		cmpa	48,x
		bne	fail
		ldaa	mnth+1
		cmpa	49,x
		bne	fail
		ldaa	mnth+2
		cmpa	50,x
		beq	ok
fail		dex
		dex
		dex
		dex
		decb
		bne	lp
error_		bra	error

ok		stab	set_buff+1
		ldx	temp
		ldaa	x
		beq	end
		ldaa	#'-'
		jsr	is_delimiter
		bne	error
		inx

		jsr	value
		bcs	end
		psha
		clra
		cmpb	#80
		bcc	c1
		addb	#2000
		adca	#/2000
		bra	c0
c1		cmpb	#100
		bcc	c2
		addb	#1900
		adca	#/1900
		bra	c0
c2		addb	#1792
		adca	#/1792
c0		staa	set_buff+2
		stab	set_buff+3
		pula
		tsta
		bne	error

end		bsr	load_buff
		int	$1F
		cmpa	#$ff
		beq	error
exit		clra
		rts

error		ldx	#error_msg
		int	$78
		jmp	again

;temp		 ds	 2
;mnth		 ds	 3

msg1		db	13, 10, 'Current date is ', 0
msg2		db	13, 10, 'Enter new date: ', 0
error_msg				;Invalid date
		dw	$2D70,$DC4A,$09BE,$1A74,$06E0,$FADC
		endp

;---------------------------------------
load_buff
		ldab	set_buff
		ldaa	set_buff+1
		ldx	set_buff+2
		rts
store_buff
		staa	set_buff+1
		stab	set_buff
		stx	set_buff+2
		rts

;---------------------------------------
; A - default, X - pointer to compared char, return in Z result of compare

is_delimiter	proc
		cmpa	x
		beq	return
		ldaa	#'.'
		cmpa	x
		beq	return
		ldaa	#'/'
		cmpa	x
return		rts
		endp

;---------------------------------------
set_time	proc
		int	$1C
		bsr	store_buff

		ldx	current_pcb
		ldx	x, pcb_argv+2
		bne	enter

		ldx	#msg1
		int	$68

		ldaa	set_buff
		jsr	pr_dec2
		ldaa	#':'
		int	$69

		ldaa	set_buff+1
		jsr	pr_dec2
		ldaa	#':'
		int	$69

		ldaa	set_buff+2
		jsr	pr_dec2
		ldaa	#'.'
		int	$69

		ldaa	set_buff+3
		jsr	pr_dec2
again
		ldx	#msg2
		int	$68

		ldx	lomem
		ldab	#40
		int	$21

		ldx	lomem
enter
		jsr	value
		bcs	exit
		stab	set_buff
		clr	set_buff+1
		clr	set_buff+2
		clr	set_buff+3
		tsta
		beq	end
		ldaa	#':'
		jsr	is_delimiter
		bne	error
		inx

		jsr	value
		bcs	end
		stab	set_buff+1
		tsta
		beq	end
		ldaa	#':'
		jsr	is_delimiter
		bne	error
		inx

		jsr	value
		bcs	end
		stab	set_buff+2
		tsta
		beq	end
		cmpa	#'.'
		bne	error
		inx

		jsr	value
		bcs	end
		stab	set_buff+3
		tsta
		bne	error

end
		jsr	load_buff
		int	$1D
		cmpa	#$ff
		beq	error
exit		clra
		rts

error		ldx	#error_msg
		int	$78
		jmp	again

msg1		db	13, 10, 'Current time is ', 0
msg2		db	13, 10, 'Enter new time: ', 0
error_msg			  ;Invalid time
		dw	$2D70,$DC4A,$09BE,$1A74,$3B60,$FAD5
		endp

;-------------------------------
handles 	proc
		ldx	current_pcb
		ldx	x, pcb_argv+2
		beq	error
		jsr	value
		bcs	range
		tsta
		bne	range
		cmpb	#maxfiles
		bhi	range
		tba
		int	$5B			;set max handles
		rts

error		ldaa	#_INV_NUM_PARMS
		rts
range		ldaa	#_INV_PARM
		rts
		endp

;-------------------------------

disktype	proc
		ldx	current_pcb
		ldx	x, pcb_argv+2
		ldaa	x
		suba	#'A'
		staa	drive_no
		inx
		ldaa	x
		cmpa	#':'
		bne	inv_parm
		inx
		jsr	skip_spaces
		tsta
		bne	inv_parm

		ldaa	drive_no
		ldx	#head_table
		cmpa	#8
		bcc	err
loop		tsta
		beq	end_loop
		deca
		inx
		inx
		bra	loop
end_loop
		ldx	x
		bne	no_err
err		ldaa	#_INV_DRV
		rts

inv_num 	ldaa	#_INV_NUM_PARMS
		rts

inv_parm	ldaa	#_INV_PARM
		rts

no_err
		ldx	current_pcb
		ldx	x, pcb_argv+4
		beq	inv_num
		jsr	value
		bcs	inv_parm
		tsta
		bne	inv_parm
		ldaa	#0
		cmpb	#40
		beq	ok
		ldaa	#1
		cmpb	#80
		bne	inv_parm
ok		ldab	#1
lp1		dec	drive_no
		bmi	br1
		asla
		aslb
		bra	lp1
br1		comb
		andb	disk_types
		stab	disk_types
		oraa	disk_types
		staa	disk_types

		ldx	current_pcb
		ldx	x, pcb_argv+6
		beq	done
		jsr	value
		bcs	inv_parm
		tsta
		bne	inv_parm
		cmpb	#2
		bcs	inv_parm
		cmpb	#32
		bhi	inv_parm
		lsrb
		decb
		comb
		aslb
		aslb
		aslb
		aslb
		ldx	fddparms
		ldaa	#$0F
		anda	0,x
		staa	0,x
		orab	0,x
		stab	0,x

done		clra
		rts

;drive_no	 ds	 1
		endp

;-------------------------------------------

auxiliary	proc
		ldx	current_pcb
		ldx	x, pcb_argv+4
		beq	inv_num
		jsr	word_value
		bcs	inv_parm
		tst	x
		bne	inv_parm
		psha
		ldaa	#7
		staa	rs_fmt
		pula
		ldx	#baudrates
loop1		cmpb	0,x
		bne	cont1
		cmpa	1,x
		beq	break1		; that's it
cont1		inx
		inx
		dec	rs_fmt
		bpl	loop1

inv_parm	ldaa	#_INV_PARM
		rts

inv_num 	ldaa	#_INV_NUM_PARMS
		rts

break1
		ldx	current_pcb
		ldx	x, pcb_argv+6
		beq	inv_num
		jsr	value
		bcs	inv_parm
		tsta
		bne	inv_parm
		cmpb	#8		; word format no.
		bcc	inv_parm
		aslb
		aslb
		aslb
		orab	rs_fmt
		tba
		ldab	#4		; init call
		int	$27
		ldx	#aux_msg
		int	$23
		int	$25
		jsr	writeln
		clra
		rts

aux_msg 	db	13,10,'AUX: ',0

baudrates	dw	19200, 9600, 4800, 2400, 1200, 600, 300, 150

;rs_fmt 	 ds	 1
		endp

;-------------------------------------------

mode		proc
		ldx	current_pcb
		ldx	x, pcb_argv+2
		beq	inv_num
		jsr	upcase_str
		ldx	current_pcb
		ldx	x, pcb_argv+2
		ldaa	1,x
		cmpa	#':'
		bne	not_disk
		jmp	disktype
not_disk
		stx	x1
		ldx	#_aux
		stx	x2
		jsr	comp_str
		bcs	not_aux
		jmp	auxiliary
not_aux
; new modes to be inserted here

		ldx	current_pcb
		ldx	x, pcb_argv+2
		jsr	value
		bcs	error
		tsta
		bne	error
		cmpb	#40
		beq	mode0
		cmpb	#80
		beq	mode4
error		ldaa	#_INV_PARM
		rts

mode0		ldab	#0			;default attribute
		ldx	current_pcb
		ldx	x, pcb_argv+4
		beq	no_attr
		jsr	value
		bcs	error
		tsta
		bne	error
no_attr 	ldaa	#0
		int	$12
		clra
		rts

mode4		ldaa	#4
		clrb
		int	$12
		clra
		rts

inv_num 	ldaa	#_INV_NUM_PARMS
		rts

_aux		db	'AUX:',0

		endp

echo_cmd	proc
		ldx	current_pcb
		ldx	x, pcb_argv+2
		beq	print
		stx	parse_ptr
		stx	x1
		jsr	upcase_str
		ldx	#on
		stx	x2
		jsr	comp_str
		bcs	test_off
		ldaa	#1
echo_ret	staa	echo_flag
		clra
		rts

test_off	ldx	parse_ptr
		stx	x1
		ldx	#OFF
		stx	x2
		jsr	comp_str
		bcs	print
		clra
		bra	echo_ret
print
		jsr	writeln
		ldx	system_x
		inx
		inx
		inx
		inx
		tst	x
		beq	done
		inx
		int	$23
done		clra
		rts

on		db	'ON', 0
off		db	'OFF', 0
		endp


pause_cmd	proc
		ldx	#message
		int	$78
		int	$20
		jsr	writeln
		clra
		rts
message 				;Press any key to continue ...
		dw	$D630,$7608,$79BD,$57A8,$44D9,$03ED,$026C,$59DB
		dw	$58FC,$00DD,$59D1,$FF36
		endp


;-------------------------------------------
; x1 - wild   (*.*)
; x2 - dest
; dir_entry  - directory entry
;-------------------------------------------
copy_wild	proc
		ldaa	#'.'
		staa	terminator
		ldx	x1
		stx	wild
		ldx	#dir_entry
		stx	src
		ldx	x2
		stx	dst
		ldab	#8
		bsr	copy1

		ldx	wild
		tst	x
		beq	no_ext
		inx
		stx	wild

		ldx	#dir_entry+8
		tst	x
		beq	no_ext
		stx	src

		ldaa	#'.'
		bsr	put_dest
		ldab	#3
		clr	terminator
		bsr	copy1
no_ext
		clra
		bra	put_dest

;B - length
;terminator
copy1
		ldx	wild
		ldaa	x
		beq	return
		cmpa	terminator
		beq	return

		cmpa	#'?'
		bne	chk_star
		ldx	src
		ldaa	x
		cmpa	#' '
		beq	inc_wild
		tstb
		beq	inc_wild
		inx
		stx	src
		decb
		bra	put_sym

chk_star	cmpa	#'*'
		beq	star
put_sym
		bsr	put_dest
inc_wild	ldx	wild
		inx
		stx	wild
		bra	copy1
star
		ldx	wild
star_loop	ldaa	x
		beq	exit_sl
		cmpa	terminator
		beq	exit_sl
		inx
		bra	star_loop
exit_sl 	stx	wild
src_loop
		tstb
		beq	return
		ldx	src
		ldaa	x
		cmpa	#' '
		beq	return
		inx
		stx	src
		decb
		bsr	put_dest
		bra	src_loop

return		rts
put_dest
		ldx	dst
		staa	x
		inx
		stx	dst
		rts

;src		 ds	 2
;dst		 ds	 2
;wild		 ds	 2
;terminator	 ds	 1
		endp



delete		proc
		ldx	current_pcb
		ldx	x, pcb_argv+2
		bne	parm_found
		jmp	inv_parm
parm_found	stx	x1
		ldx	lomem
		stx	x2
		jsr	str_copy

		ldx	lomem
		jsr	expand_name

		ldx	lomem
		jsr	find_last_name

		stx	x1
		stx	fname_ptr

		ldx	#0
		stx	file_counter

		ldx	#all_files+1			;*.*
		stx	x2
		jsr	comp_str
		bcs	delete_files
;Are you sure
		ldx	#sure_msg
		int	$78
		int	$20
		tab
		jsr	writeln
		cmpb	#'Y'
		beq	delete_files
		cmpb	#'y'
		bne	exit_dloop
delete_files
		clra
		ldab	#%00011011
		ldx	lomem
		jsr	find_entry
		tsta
		beq	del_loop
		cmpa	#_INV_PATH
		bne	fatal_err
		ldaa	#_NOT_FOUND
fatal_err
		int	$38
del_loop
		ldx	#all_files+1		;*.*
		stx	x1
		ldx	fname_ptr
		stx	x2
		jsr	copy_wild

		ldx	#file
		int	$68
		ldx	lomem
		int	$68

		ldx	lomem
		int	$4F
		tsta
		bne	fatal_err

		ldx	file_counter
		inx
		stx	file_counter

		ldx	#table
		int	$43
		tsta
		beq	del_loop
		cmpa	#_INV_PATH
		bne	fatal_err
exit_dloop
		jsr	writeln_stdout
		jsr	writeln_stdout

		bsr	print_count
		ldx	#deleted
		int	$68
		clra
		rts

;fname_ptr	 ds	 2

file		db	13, 10, 'Deleting  ', 0
deleted 	db	'deleted', 0
sure_msg			;Are you sure ?
		dw	$D630,$75F9,$9C45,$0357,$73DB,$CE45,$FF47
		endp

print_count	proc
		ldaa	file_counter+1
		staa	lint
		ldaa	file_counter
		staa	lint+1
		clr	lint+2
		clr	lint+3
		ldx	#lint
		jsr	pr_dec
		ldx	#files_str
		int	$68
		rts
files_str	db	' File(s) ', 0
		endp

;---------------------------------
;  word_value
;  INPORT: X - pointer to ascii
;  EXPORT: BA - binary value
;	   X - new_pointer
;	   C set if error
;----------------------------------
word_value	proc
		bsr	skip_spaces
		clr	x1
		clr	x1+1

		tsta
		bne	loop
		sec			; if eoln
		rts

loop		ldaa	x
		cmpa	#'0'
		bcs	end
		cmpa	#'9'
		bhi	end
		suba	#'0'
		inx
		clrb
		asl	x1+1
		rol	x1
		adda	x1+1
		adcb	x1
		asl	x1+1
		rol	x1
		asl	x1+1
		rol	x1
		adda	x1+1
		adcb	x1
		staa	x1+1
		stab	x1
		bra	loop

end		bsr	skip_spaces
		ldaa	x1+1
		ldab	x1
		rts
		endp


;---------------------------------
;  value
;  INPORT: X - pointer to ascii
;  EXPORT: B - binary value
;	   X - new_pointer
;	   A - *new_pointer
;	   C set if error
;----------------------------------
value		proc
		global	skip_spaces

		bsr	skip_spaces
		clrb

		tsta
		bne	loop
		sec			; if eoln
		rts

loop		ldaa	x
		cmpa	#'0'
		bcs	end
		cmpa	#'9'
		bhi	end
		suba	#'0'
		inx

		aslb
		aba
		aslb
		aslb
		aba
		tab
		bra	loop
end
;--------------------------------
; skip spaces
; INPORT: X - pointer
; EXPORT: X - new_pointer
;	  A - *new_pointer
;	  C cleared
;--------------------------------
skip_spaces
skip_loop	ldaa	x
		cmpa	#' '
		bne	exit
		inx
		bra    skip_loop
exit		clc
		rts
		endp


;------------------------------------------------------
;X - dir entry pointer
;------------------------------------------------------
pr_entry	proc
		stx	pr_entry_x

		ldab	#8
		bsr	pr_name

		ldaa	#' '
		int	$69

		ldab	#3
		bsr	pr_name

		ldaa	#' '
		int	$69

		ldx	pr_entry_x
		ldaa	x, dir_attribute
		bita	#%10000
		bne	dir

		ldaa	#dir_file_size
		clrb
		adda	pr_entry_x+1
		adcb	pr_entry_x
		staa	x1+1
		stab	x1
		ldx	x1
		jsr	pr_dec
		bra	print_date
dir
		ldx	#dir_str
		int	$68
print_date
		ldaa	#' '
		int	$69
		int	$69

		ldx	pr_entry_x
		ldaa	x, dir_date
		ldab	x, dir_date+1
		jsr	pr_date

		ldaa	#' '
		int	$69
		int	$69

		ldx	pr_entry_x
		ldaa	x, dir_time
		ldab	x, dir_time+1
		jsr	pr_time

		jmp	writeln_stdout

dir_str 	db	'<DIR>   ', 0
		endp

;---------------------------------------
; X - name
; B - length
;---------------------------------------
pr_name 	proc
		ldaa	x
		int	$69
		inx
		decb
		bne	pr_name
		rts
		endp

clr_scr 	proc
		ldaa	#12
		int	$22
		clra
		rts
		endp

;--------------------------------------------
; Show directory
;--------------------------------------------
show_dir	proc
		ldx	current_pcb
		ldx	x, pcb_argv+2
		bne	arg_exist
		jsr	calc_argv_addr
		ldaa	#empty_string
		ldab	#/empty_string
		staa	x, 3
		stab	x, 2
arg_exist
		ldx	current_pcb
		ldx	x, pcb_argv+2
		jsr	get_drive
		bcs	error1
		ldx	lomem
		staa	show_drive
		adda	#'A'
		staa	x
		inx
		stx	x2
		ldx	#label_str
		stx	x1
		jsr	str_copy

		ldx	lomem
		ldaa	#%00001000		 ;volume label
		ldab	#%00000000
		jsr	find_entry
		psha

		jsr	writeln_stdout
		jsr	writeln_stdout
		ldx	#vol_msg
		int	$68
		ldaa	show_drive
		adda	#'A'
		int	$69
		ldx	#is_str
		int	$68

		pula
		tsta
		beq	print_label
		cmpa	#_INV_PATH
		beq	no_label
error1		jmp	error
print_label
		ldx	#dir_entry
		ldab	#11
		jsr	pr_name
no_label	jsr	writeln_stdout


		ldx	lomem
		stx	x2
		ldx	current_pcb
		ldx	x, pcb_argv+2
		stx	x1
		jsr	str_copy
		ldx	lomem
		jsr	expand_name

		ldx	lomem
		jsr	find_last_name

		tst	x
		bne	chk_name
		stx	x2
		ldx	#all_files
		stx	x1
		jsr	str_copy
		bra	full_path
chk_name
		ldaa	x
		beq	add_wild
		cmpa	#'.'
		beq	full_path
		inx
		bra	chk_name
add_wild
		stx	x2
		ldx	#all_ext
		stx	x1
		jsr	str_copy
full_path
		ldx	lomem
		stx	x1
		stx	x2
		inc	x2
		jsr	create_path

;-------------------------------------
; Print directory
;-------------------------------------
		ldx	#dir_str
		int	$68
		ldx	lomem
		stx	x1
		inc	x1
		ldx	x1

		jsr	find_last_name
		clr	x

		ldx	x1
		int	$68
		jsr	writeln_stdout
		jsr	writeln_stdout

		clr	file_counter
		clr	file_counter+1
		ldaa	#%00010000
		ldab	#%00001010
		bsr	show_files
		bcs	error

		ldaa	#%00000000
		ldab	#%00011010
		bsr	show_files
		bcs	error

		jsr	writeln_stdout

		jsr	print_count

		ldx	#lint
		ldaa	show_drive
		int	$52

		ldaa	lint
		ldab	lint+3
		staa	lint+3
		stab	lint
		ldaa	lint+1
		ldab	lint+2
		staa	lint+2
		stab	lint+1

		ldx	#lint
		jsr	pr_dec

		ldx	#bytes_free
		int	$68
		clra
		rts

error
		int	$38

show_files	proc
		ldx	lomem
		jsr	find_entry
floop		tsta
		bne	floop_exit
		ldx	#dir_entry
		jsr	pr_entry
		ldx	file_counter
		inx
		stx	file_counter
		ldx	#table
		int	$43
		bra	floop
floop_exit
		cmpa	#_INV_PATH
		bne	f_err
		clc
		rts
f_err		sec
		rts
		endp

vol_msg 	db	'Volume in drive ', 0
is_str		db	' is ', 0
dir_str 	db	'Directory of  ', 0
files_str	db	' File(s) ', 0
bytes_free	db	' bytes free', 13, 10
zero		db	0
label_str	db	':\'
all_files	db	'*'
all_ext 	db	'.*', 0
		endp

;------------------------------------------------
; A - Error code
;------------------------------------------------

print_error	proc
		tsta
		beq	return
		ldx	lomem
		int	$3D			;Get error text
		jsr	writeln
		ldx	lomem
		int	$23
		ldx	#point_newln
		int	$23
return		rts
		endp


;--------------------------------------------------
;X - path
;-------------------------------------------------
find_entry	proc
		stx	table+4
		ldx	#dir_entry
		stx	table+2
		ldx	#find_buff
		stx	table
		ldx	#table
		int	$42
		rts
		endp


;--------------------------------------------------
;COPY_FILES
;--------------------------------------------------
copy_files	proc
;		ldx	lomem
;		stx	X1
;		inc	X1
;		ldx	x1
;		stx	dest
;		inc	x1
;		ldx	x1
;		stx	dst_wild
		jsr	cr_common_1

		ldaa	x1+1
		ldab	x1
		adda	#$80
		adcb	#0
		staa	buff_ptr+1
		stab	buff_ptr

		sts	x1
		ldaa	x1+1
		ldab	x1
		suba	buff_ptr+1
		sbcb	buff_ptr
		andb	#$FE
		bne	mem_ok
		ldaa	#_INSF_MEM
		rts
mem_ok		stab	buff_lng
		clr	buff_lng+1

		ldx	current_pcb
		ldx	x, pcb_argv+2
		bne	parms_ok
		ldaa	#_INV_NUM_PARMS
error		rts

parms_ok	stx	X1
		ldx	lomem
		stx	x2
		jsr	str_copy
		ldx	lomem
		jsr	get_drive
		bcs	error
		staa	drv
		int	$5C			;media check

		ldx	current_pcb
		ldx	x, pcb_argv+4
		bne	store1
		ldx	#all
store1		stx	X1
		ldx	dest
		stx	x2
		jsr	str_copy
		ldx	dest
		jsr	get_drive
		bcs	error
		cmpa	drv
		beq	same_drives
		int	$5C			;media check
same_drives
		ldx	dest
		jsr	expand_name
		ldx	dest
		stx	x1
		ldx	buff_ptr
		stx	X2
		inc	x2
		jsr	create_path

		ldx	lomem
		jsr	expand_name
		ldx	lomem
		stx	x1
		ldx	buff_ptr
		stx	X2
		jsr	create_path

		ldx	buff_ptr
		stx	X1
		stx	X2
		inc	X2
		jsr	comp_str
		bcs	files_differ		 ; copy onto inself
		ldaa	#_SRCDST_CONFL
		rts

files_differ
		ldx	dest
		jsr	get_drive
		tst	x
		bne	dest_ok
		stx	x2
		ldx	#all
		stx	x1
		jsr	str_copy
dest_ok
		ldx	dest
		jsr	find_last_name
		stx	X1
		ldx	dst_wild
		stx	x2
		jsr	str_copy

;		jsr	writeln_stdout
;		ldx	#0
;		stx	file_counter
;		ldx	#find_buff
;		stx	table
;		ldx	#dir_entry
;		stx	table + 2
;		ldx	lomem
;		stx	table + 4
;		clra
;		ldab	#%00011010
;		ldx	#table
;		int	$42
		jsr	cr_common_2
		cmpa	#_INV_PATH
		beq	no_files

copy_loop	tsta
		beq	found
		cmpa	#_INV_PATH
		bne	next_file
		beq	no_more
found
;		ldx	lomem
;		jsr	find_last_name
;		stx	x2
;		ldx	#all
;		stx	x1
;		jsr	copy_wild
;
;		ldx	dest
;		jsr	find_last_name
;		stx	x2
;		ldx	dst_wild
;		stx	x1
;		jsr	copy_wild
		jsr	cr_common_3

		bsr	copy_it
next_file
;		ldx	#find_buff
;		stx	table
;		ldx	#dir_entry
;		stx	table + 2
;		ldx	#table
;		int	$43
		jsr	cr_common_4
		bra	copy_loop
no_files	bsr	copy_it
no_more
		jsr	writeln_stdout

		jsr	print_count

		ldx	#copied
		int	$68
		clra
		rts
;--------
copy_it
		ldaa	#$80
		staa	hndl1
		staa	hndl2

		ldx	#file
		int	$68
		ldx	lomem
		int	$68
		ldx	#to
		int	$68
		ldx	dest
		jsr	upcase_str
		ldx	dest
		int	$68
		jsr	writeln_stdout


next_block
		ldaa	hndl1
		bpl	file1_open
		ldx	lomem
		stx	table
		ldx	#0
		stx	table+2
		ldaa	#1
		ldx	#table
		int	$4A		;open file
		tsta
		beq	file_open
		cmpa	#_INV_PATH
		bne	err_open
		ldx	#_NOT_FOUND
		int	$38
err_open	ldaa	#_OPEN_ERROR
		int	$38

file_open	stab	hndl1
		ldx	file_counter
		inx
		stx	file_counter
file1_open
		ldx	buff_ptr
		stx	table
		ldx	buff_lng
		stx	table+2
		ldaa	hndl1
		ldx	#table
		int	$4C		;read file
		staa	copy_err
		stx	copy_lng
		cpx	#0
		beq	close_f2

		ldaa	hndl2
		bpl	file2_open
		ldx	dest
		stx	table
		ldx	#0
		stx	table+2
		clra
		ldx	#table
		int	$4B		;create
		tsta
		beq	create_ok
		ldaa	#_CREAT_ERROR	;File creation error
		int	$38

create_ok	stab	hndl2
file2_open
		ldx	buff_ptr
		stx	table
		ldx	copy_lng
		stx	table+2
		ldaa	hndl2
		ldx	#table
		int	$4D		;write file
		oraa	copy_err
		bne	close_f2
		jmp	next_block


close_f2	clra
		ldab	hndl1
		ldx	#lint
		int	$55
		tsta
		bne	not_disk
		ldaa	#1
		ldab	hndl2
		ldx	#lint
		int	$55
not_disk	ldaa	hndl2
		int	$4E
close_f1	ldaa	hndl1
		int	$4E
return		rts

;drv		 ds	 1
;copy_err	 ds	 1
;copy_lng	 ds	 2
;
;dest		 ds	 2
;dst_wild	 ds	 2
;
;hndl1		 ds	 1
;hndl2		 ds	 1
;
;buff_ptr	 ds	 2
;buff_lng	 ds	 2

file		db	'Copying  ', 0
copied		db	'copied', 0
		endp

to		db	'  to  ', 0

cr_common_4	proc
		ldx	#find_buff
		stx	table
		ldx	#dir_entry
		stx	table + 2
		ldx	#table
		int	$43
		rts
		endp

cr_common_3	proc
		ldx	lomem
		jsr	find_last_name
		stx	x2
		ldx	#all
		stx	x1
		jsr	copy_wild

		ldx	dest
		jsr	find_last_name
		stx	x2
		ldx	dst_wild
		stx	x1
		jmp	copy_wild
		endp

cr_common_1	proc
		ldx	lomem
		stx	X1
		inc	X1
		ldx	x1
		stx	dest
		inc	x1
		ldx	x1
		stx	dst_wild
		rts
		endp

cr_common_2	proc
		jsr	writeln_stdout
		ldx	#0
		stx	file_counter
		ldx	#find_buff
		stx	table
		ldx	#dir_entry
		stx	table + 2
		ldx	lomem
		stx	table + 4
		clra
		ldab	#%00011010
		ldx	#table
		int	$42
		rts
		endp

;--------------------------------------------------
;RENAME
;--------------------------------------------------
rename_files	proc
;		ldx	lomem
;		stx	X1
;		inc	X1
;		ldx	x1
;		stx	dest
;		inc	x1
;		ldx	x1
;		stx	dst_wild

		bsr	cr_common_1

		int	$3B
		cmpa	#2
		bcc	parms_ok
		ldaa	#_INV_NUM_PARMS
error		rts

parms_ok
		ldaa	#1
		ldx	lomem
		int	$3C

		ldaa	#1
		ldx	dest
		int	$3C

		ldaa	#2
		ldx	dst_wild
		int	$3C

		ldx	lomem
		jsr	get_drive
		bcs	error
		int	$5C			;media check

		ldx	dst_wild
loop		ldaa	x
		beq	name_ok
		cmpa	#':'
		beq	name_err
		cmpa	#'\'
		beq	name_err
		inx
		bra	loop
name_err
		ldaa	#_INV_PARM
		int	$38
name_ok
;		jsr	writeln_stdout
;		ldx	#0
;		stx	file_counter
;		ldx	#find_buff
;		stx	table
;		ldx	#dir_entry
;		stx	table + 2
;		ldx	lomem
;		stx	table + 4
;		clra
;		ldab	#%00011010
;		ldx	#table
;		int	$42
		bsr	cr_common_2
		cmpa	#_INV_PATH
		bne	ren_loop

		ldaa	#_NOT_FOUND
		int	$38

ren_loop	tsta
		beq	found
		cmpa	#_INV_PATH
		bne	next_file
		beq	no_more
found
;		ldx	lomem
;		jsr	find_last_name
;		stx	x2
;		ldx	#all
;		stx	x1
;		jsr	copy_wild
;
;		ldx	dest
;		jsr	find_last_name
;		stx	x2
;		ldx	dst_wild
;		stx	x1
;		jsr	copy_wild
		jsr	cr_common_3

		ldx	#file
		int	$68
		ldx	lomem
		int	$68
		ldx	#to
		int	$68
		ldx	dest
		jsr	upcase_str
		ldx	dest
		int	$68
		jsr	writeln_stdout

		ldx	lomem
		stx	table
		ldx	dest
		stx	table+2
		ldx	#table
		int	$56
		tsta
		beq	ren_ok

		ldx	dst_wild
		stx	x1
		inc	x1
		ldx	x1
		int	$3D
		int	$23
		jsr	writeln
		bra	next_file

ren_ok		ldx	file_counter
		inx
		stx	file_counter
next_file
;		ldx	#find_buff
;		stx	table
;		ldx	#dir_entry
;		stx	table + 2
;		ldx	#table
;		int	$43
		jsr	cr_common_4
		jmp	ren_loop

no_more
		jsr	writeln_stdout

		jsr	print_count
		ldx	#renamed
		int	$68
		clra
		rts


;dest		 ds	 2
;dst_wild	 ds	 2

file		db	'Renaming  ', 0
renamed 	db	'renamed', 0
		endp

;--------------------------------------------------
;X - path
;RET: X - pointer to last name
;--------------------------------------------------
find_last_name	proc
		bsr	get_drive

		stx	find_last_x
loop		ldaa	x
		beq	exitl
		inx
		cmpa	#'\'
		bne	loop
		stx	find_last_x
		bra	loop
exitl		ldx	find_last_x
		rts
		endp

;-----------------------------------------
;ENTER : X - path
;EXIT : A - drive
;	X - new position
;-----------------------------------------
get_drive	proc
		tst	x
		beq	no_drive
		ldaa	x, 1
		cmpa	#':'
		bne	no_drive
		ldaa	x
		anda	#$5F
		inx
		inx
		suba	#'A'
		staa	a1
		stx	x1
		ldx	#head_table
		cmpa	#8
		bcc	err
loop		tsta
		beq	end_loop
		deca
		inx
		inx
		bra	loop
end_loop
		ldx	x
		bne	no_err
err		ldaa	#_INV_DRV
		sec
		rts
no_err		ldx	x1
		ldaa	a1
		clc
		rts
no_drive
		int	$45
		clc
		rts
		endp

;--------------------------------------------------
;X1 - str1
;X2 - str1
;ret : CF = 1  -  not equal
;--------------------------------------------------
comp_str	proc
loop		ldx	x1
		ldaa	x
		ldx	x2
		ldab	x

		cba
		bne	error
		tsta
		beq	return
		tstb
		beq	return

		ldx	x1
		inx
		stx	x1
		ldx	x2
		inx
		stx	x2
		bra	loop

return		clc
		rts
error		sec
		rts
		endp

;-----------------------------------------
; X - string pointer
;-----------------------------------------
upcase_str	proc
loop		ldaa	x
		beq	return
		bsr	upcase_char
		staa	x
		inx
		bra	loop
return		rts
		endp


;---------------------------------------
; A - char
;---------------------------------------
upcase_char	proc
		cmpa	#'a'
		bcs	ret
		cmpa	#'z'
		bhi	ret
		suba	#$20
ret		rts
		endp


;-----------------------------------------
;ENTER : X - string
;EXIT : BA - length
;-----------------------------------------
str_length	proc
		clra
		clrb
loop		tst	x
		beq	return
		inx
		inca
		bcc	loop
		incb
		bra	loop
return		rts
		endp

;-----------------------------------------
; X1 - src
; X2 - dest
;-----------------------------------------
str_copy	proc
		ldx	x1
		bsr	str_length
		inca
		adcb	#0
		bra	move_mem
		endp


;-----------------------------------------
; X - ptr
; B - byte
; A - length
;-----------------------------------------
mem_set 	proc
loop		stab	x
		inx
		deca
		bne	loop
		rts
		endp


;-----------------------------------------
; X1 - src
; X2 - dest
; BA - length
;-----------------------------------------
move_mem	proc
		ldx	#x1
		int	$2d
		rts
		endp


pr_dec_24	proc
		ldaa	#1
		staa	pr_dec_flag
		bra	pr_dec_
		endp

;-----------------------------------------------------
;A - byte < 100
;-----------------------------------------------------
pr_dec2 	proc
loop1		cmpa	#100
		bcs	ok1
		suba	#100
		bra	loop1
ok1
		clrb
loop2		cmpa	#10
		bcs	ok2
		incb
		suba	#10
		bra	loop2
ok2
		psha
		tba
		bsr	ok3
		pula
ok3
		adda	#'0'
		int	$69
		rts
		endp

;----------------------------------------------------
; X - pointer to 4b negative byte sex unsigned integer
;----------------------------------------------------
pr_dec		proc
		global	pr_dec_

		clr	pr_dec_flag
pr_dec_
		stx	x1
		clr	dec_flag

		ldx	#_10000000
		bsr	subtract
		ldx	#_1000000
		bsr	subtract
		ldx	#_100000
		bsr	subtract
		ldx	#_10000
		bsr	subtract
		ldx	#_1000
		bsr	subtract
		ldx	#_100
		bsr	subtract
		ldx	#_10
		bsr	subtract

		ldaa	#1
		staa	dec_flag
		ldx	#_1
		bra	subtract

subtract
		clrb
		stx	x2

pr_loop 	ldx	x1
		ldaa	x
		ldx	x2
		suba	x
		psha

		ldx	x1
		ldaa	x, 1
		ldx	x2
		sbca	x, 1
		psha

		ldx	x1
		ldaa	x, 2
		ldx	x2
		sbca	x, 2
		psha

		ldx	x1
		ldaa	x, 3
		ldx	x2
		sbca	x, 3
		psha

		bcs	sorry
		ldx	x1
		pula
		staa	x, 3
		pula
		staa	x, 2
		pula
		staa	x, 1
		pula
		staa	x, 0
		incb
		bra	pr_loop
sorry
		ins
		ins
		ins
		ins
		ldaa	#'0'
		aba
		orab	dec_flag
		stab	dec_flag
		bne	pr_it
		ldaa	#' '
pr_it
		tst	pr_dec_flag
		bne	rom
		int	$69
		rts
rom		int	$22
		rts

;$0000 0001 = 1
;$0000 000A = 10
;$0000 0064 = 100
;$0000 03E8 = 1 000
;$0000 2710 = 10 000
;$0001 86A0 = 100 000
;$000F 4240 = 1 000 000
;$0098 9680 = 10 000 000

_10000000	db	$80,$96,$98,0
_1000000	db	$40,$42,$f,0
_100000 	db	$a0,$86,1,0
_10000		db	$10,$27,0,0
_1000		db	$E8,3,0,0
_100		db	$64,0,0,0
_10		db	$a,0,0,0
_1		db	1,0,0,0

		endp

;--------------------------------------------------
;BA - date
;--------------------------------------------------
pr_date 	proc
		global	months
		stab	date
		staa	date+1
		ldx	date
		beq	error

		anda	#%11111
		beq	error
		jsr	pr_dec2
		ldaa	#'-'
		int	$69

		ldaa	date+1
		ldab	date
		lsrb
		rora
		lsra
		lsra
		pshb
		anda	#%111100
		cmpa	#12*4
		bls	month_ok
		clra
month_ok
		clrb
		adda	#months
		adcb	#/months
		staa	x1+1
		stab	x1
		ldx	x1
		int	$68

		ldaa	#'-'
		int	$69

		pulb
		ldaa	#80
		aba
		jmp	pr_dec2
error
		ldab	#9
		ldaa	#' '
err_loop	int	$69
		decb
		bne	err_loop
		rts

;---------------------------------------

months		db	'???', 0
		db	'JAN', 0
		db	'FEB', 0
		db	'MAR', 0
		db	'APR', 0
		db	'MAY', 0
		db	'JUN', 0
		db	'JUL', 0
		db	'AUG', 0
		db	'SEP', 0
		db	'OCT', 0
		db	'NOV', 0
		db	'DEC', 0

		endp

;--------------------------------------------------
;BA - time
;--------------------------------------------------
pr_time 	proc
		stab	time
		staa	time+1
		ldx	time
		beq	error

		lsrb
		lsrb
		lsrb
		tba
		cmpa	#24
		bcc	error
		jsr	pr_dec2

		ldaa	#':'
		int	$69

		ldaa	time+1
		ldab	time
		asla
		rolb
		asla
		rolb
		asla
		rolb
		andb	#%111111
		tba
		cmpa	#60
		bcs	time_ok
		clra
time_ok 	jmp	pr_dec2

error
		ldab	#5
		ldaa	#' '
err_loop	int	$69
		decb
		bne	err_loop
		rts
		endp

reset		proc
		clr	$EE00
		ldx	$FFFE
		jmp	x
		endp

;--------------------------------------
; CRITICAL ERROR SUPPORT
;--------------------------------------
critical	proc
		stab	err_b
		jsr	writeln

		ldx	himem
		stx	old_himem

		ldx	#41
		clrb
		int	$2A			;allocate
		cpx	#0
		beq	no_mem

		stx	err_buff
		ldaa	swia
		anda	#$7F
		int	$3D
		ldx	err_buff
		int	$23

		ldx	old_himem
		int	$2B
no_mem
		ldx	#err_msg
		int	$23

		ldaa	swia
		bmi	disk_device
		ldaa	#' '
		int	$22
		ldab	#%01110000
		stab	err_b
		bra	pr_error
disk_device
		ldx	#read
		ldab	err_b
		bitb	#2
		beq	reading
		ldx	#write
reading 	int	$23

		ldx	swix
		ldaa	x, 2			;drive
		adda	#'A'
		staa	drive_let
		ldx	#drv
		int	$23
pr_error
		jsr	writeln

		ldab	err_b
		lsrb
		lsrb
		lsrb
		lsrb

		ldx	#abort
		int	$23
		bitb	#2
		beq	j1
		ldx	#retry
		int	$23
j1		bitb	#1
		beq	j2
		ldx	#ignore
		int	$23
j2		bitb	#4
		beq	j3
		ldx	#fail
		int	$23
j3		ldx	#prompt
		int	$23
get_answ
		int	$11
		anda	#%01011111	;upcase
		cmpa	#'A'
		beq	ret_abort
		cmpa	#'R'
		beq	ret_retry
		cmpa	#'I'
		beq	ret_ignore
		cmpa	#'F'
		beq	ret_fail
		bra	get_answ

ret_abort	ldab	#2
		bra	ret
ret_retry	bitb	#2
		beq	get_answ
		ldab	#1
		bra	ret
ret_ignore	bitb	#1
		beq	get_answ
		clrb
		bra	ret
ret_fail	bitb	#4
		beq	get_answ
		ldab	#3
ret		stab	swia
		int	$22
		jmp	writeln

;old_himem	 ds	 2
;err_buff	 ds	 2
;err_b		 ds	 1

abort		db	'Abort', 0
retry		db	', Retry', 0
ignore		db	', Ignore', 0
fail		db	', Fail', 0
prompt		db	'? ', 0
err_msg 	db	' error ', 0
read		db	'read', 0
write		db	'writ', 0

drv		db	'ing drive '
drive_let	db	'A: ', 0
		endp


;--------------------------------------
;INT $78
;X - packed string address
;--------------------------------------
pr_pack 	stx	unpack_x1
		ldx	#0
		stx	unpack_x2
		bra	unpack

;--------------------------------------
;INT $3D
;A - error code
;X - buffer address
;--------------------------------------
get_err_text	proc
		global	unpack

		ldx	#rom_errors
		cmpa	#N_ROM_ERRORS
		bls	search

		ldx	#ram_errors
		suba	#64
		cmpa	#N_RAM_ERRORS - 64
		bls	search

		ldx	#unknown
		bra	return

search		tsta
		beq	return
loop
		ldab	x
		cmpb	#$FA
		bcs	inc
		inx
		inx
		deca
		bra	search
inc		inx
		inx
		bra	loop

return		stx	unpack_x1
		ldx	swix
		stx	unpack_x2

unpack
unpack0 	proc
		ldaa	#$40
		staa	unpack_reg
		ldx	unpack_x1
loop		ldx	x
		clrb
		ldaa	#40
		int	$29
		bsr	store
		clrb
		ldaa	#40
		int	$29
		bsr	store
		clrb
		ldaa	#40
		int	$29
		cpx	#0
		bne	done
		bsr	store
		ldx	unpack_x1
		inx
		inx
		stx	unpack_x1
		bra	loop

store		stx	unpack_xsv
		cmpa	#32
		bcc	store_reg
		oraa	unpack_reg
		bita	#%10011111
		bne	storea
		ldaa	#32
storea
		ldx	unpack_x2
		bne	storeb
		int	$22
		bra	storez
storeb		staa	x
		inx
		stx	unpack_x2
		bra	storez
store_reg	anda	#7
		asla
		asla
		asla
		asla
		asla
		staa	unpack_reg
storez		ldx	unpack_xsv
		rts

done		ldx	unpack_x2
		beq	donez
		clr	x
donez		rts
		endp

unknown 	dw	$5D0D, $5FFB, $FC47
rom_errors
			;No error
		dw	$6346,$7148,$72EA,$FF9B
			;Invalid function number
		dw	$5D01,$4B3E,$00A9,$5ACE,$3B63,$023F,$5496,$714A,$FF9B
			;Invalid drive
		dw	$5D01,$4B3E,$00A9,$3B14,$FADE
			;Disk write protected
		dw	$3DBC,$01CB,$3B27,$00DC,$60A0,$139C,$19DC,$FF9B
			;Address failure
		dw	$1E79,$2214,$030B,$386E,$73D4,$FF7D
			;Data failure
		dw	$0BBC,$003C,$386E,$73D4,$FF7D
			;General failure
		dw	$24BF,$7156,$01E1,$386E,$73D4,$FF7D
			;Invalid sector
		dw	$5D01,$4B3E,$00A9,$139B,$72EC,$FF9B
			;Reserved
		dw	$24CA,$715B,$19DE,$FF9B
			;Invalid media type
		dw	$5D01,$4B3E,$00A9,$19D5,$0031,$67FC,$FF7D
			;FAT failure
		dw	$7D2E,$2AF8,$4C69,$2225,$FF9B
			;Path not found
		dw	$0BC8,$0154,$7F66,$5EB0,$1B45,$FF9B
			;Reserved
		dw	$24CA,$715B,$19DE,$FF9B
			;Too many open files
		dw	$634C,$514F,$9E71,$6658,$0235,$4C6E,$FCFD
			;Access denied
		dw	$1839,$778B,$1913,$3A75,$FAA5
			;File already open
		dw	$3DBE,$00D4,$7261,$192D,$5DD9,$5858,$FF9B
			;Invalid file handle
		dw	$5D01,$4B3E,$00A9,$4C6E,$3205,$1B31,$FAD4
			;Disk full
		dw	$3DBC,$01CB,$4E4E,$FF84
			;File lost in directory
		dw	$3DBE,$00D4,$7924,$3854,$190E,$2219,$60E3,$FDFA
			;Invalid name
		dw	$5D01,$4B3E,$00A9,$5176,$FF7D
			;Root directory full
		dw	$634A,$032F,$71EC,$7D7D,$9F1F,$8430,$FBEC
			;Directory exists
		dw	$3DBC,$139A,$72EC,$1F59,$7840,$FD0C
			;Attempt to remove the current directory
		dw	$8279,$521C,$0330,$026C,$521A,$22BF,$3520,$12C5,$7365,$7F35,$38E0,$139A,$72EC,$FF91
			;Directory not empty
		dw	$3DBC,$139A,$72EC,$5799,$032F,$660D,$FDFC
			;Bad LSEEK position
		dw	$0BBA,$D484,$2244,$01BD,$6063,$7E7B,$59E1,$FF9B
			;Reserved
		dw	$24CA,$715B,$19DE,$FF9B
			;Not disk file
		dw	$6346,$1914,$47C1,$3930,$FAD4
			;Too many drivers installed
		dw	$634C,$514F,$9E71,$7120,$22B9,$030A,$78F9,$4B3C,$19D4,$FF9B
			;Not same device
		dw	$6346,$76D4,$2149,$1FE0,$143E,$FF7D
			;File exists
		dw	$3DBE,$00D4,$3C05,$79F3,$FF9B
			;Printer timeout
		dw	$7608,$7F39,$02D5,$52BC,$859D,$FF8C
			;Printer general failure
		dw	$7608,$7F39,$02D5,$584F,$0915,$258C,$4C69,$2225,$FF9B
			;Printer out of paper
		dw	$7608,$7F39,$02D5,$8057,$27D8,$08C0,$7158,$FF9B
			;AUX: timeout
		dw	$9949,$0431,$3B83,$5E95,$FD35
			;AUX: parity
		dw	$9949,$0431,$08E3,$7E7A,$FF91
			;AUX: overrun
		dw	$9949,$0431,$8BFB,$7355,$FC45
			;AUX: framing
		dw	$9949,$0431,$7193,$3A49,$FB26
ram_errors
			;Invalid number of parameters
		dw	$5D01,$4B3E,$00A9,$5496,$714A,$27D8,$08C0,$517A,$2265,$FD0A
			;Bad command or file name
		dw	$0BBA,$12C4,$5357,$1B31,$72D8,$3930,$00D4,$5176,$FF7D
			;Insufficient memory
		dw	$5D01,$28DB,$142E,$5851,$5154,$5FCD,$FDFA
			;Failure in .PGM file
		dw	$0BBE,$8529,$00DA,$0239,$D6D1,$5268,$2AF8,$2129,$FF9B
			;Language not available
		dw	$0BC4,$8466,$2059,$5FF0,$0654,$387E,$0CB4,$FAD4
			;Cannot execute .CMD file
		dw	$0BBB,$5FFE,$1F54,$13A0,$2275,$5CA8,$51DA,$DAC4,$4C6E,$FF7D
			;File cannot be copied onto itself
		dw	$3DBE,$00D4,$57AB,$7F66,$1F90,$5E38,$20B8,$5DC4,$60EE,$7E68,$4BDB,$FF7E
			;File opening failure
		dw	$3DBE,$00D4,$21CF,$58F6,$2587,$4C69,$2225,$FF9B
			;File creation failure
		dw	$3DBE,$00D4,$2213,$3B61,$023F,$386E,$73D4,$FF7D
			;File not found
		dw	$3DBE,$00D4,$7F66,$5EB0,$1B45,$FF9B
			;Invalid parameter
		dw	$5D01,$4B3E,$00A9,$70B8,$2149,$715C,$FF9B
		endp

;-----------------------------------------------------------
aux_error	proc
		sec
		ldaa	#_aux_framing
		bitb	#%00010000
		bne	has
		ldaa	#_aux_overrun
		bitb	#%00100000
		bne	has
		ldaa	#_aux_parity
		bitb	#%01000000
		bne	has
		ldaa	#_aux_timeout
		bitb	#%10000000
		bne	has
		clra
;		clc
has		rts
		endp

aux_read	proc
		ldab	#3		;Mode
		ldaa	#1
		int	$27

		ldab	#1		;Receive
		int	$27
		staa	swia
		bsr	aux_error
		bcc	skip
		staa	swia
skip		tpa
		staa	swic

		ldab	#3		;Mode
		ldaa	#$41
		int	$27
		rts
		endp

aux_write	proc
		ldab	#2
		int	$27
		bsr	aux_error
		staa	swia
		tpa
		staa	swic
		rts
		endp

aux_init	proc
		clra
		staa	swia
		tpa
		staa	swic
		rts
		endp



;-----------------------------------------
; INT $6A - create temporary file
;ENTER : A - file attribute
;		0 - normal
;		1 - read-only
;		2 - hidden
;		4 - system
;	 X - parameters
;		1w - path/name
;		1w - buffer pointer
;EXIT : A - error code
;	B - file handle
;-----------------------------------------
int_6A		proc
		ldx	x
loop		tsta
		beq	exitl
		inx
		bra	loop
exitl
		stx	cr_temp_end
		ldaa	hundreds
		staa	cr_temp_cntr

main_loop	ldx	cr_temp_end
		ldaa	hours
		bsr	digit
		ldaa	minutes
		bsr	digit
		ldaa	seconds
		bsr	digit
		ldaa	cr_temp_cntr
		bsr	digit
		stx	x2
		ldx	#ext
		stx	x1
		jsr	str_copy

		ldaa	swia
		ldx	swix
		int	$6B
		tsta
		beq	exit
		cmpa	#_FILE_EXIST
		bne	exit
		inc	cr_temp_cntr
		bra	main_loop
exit
		staa	swia
		stab	swib
		rts

digit		staa	a1
		anda	#$F
		bsr	hex_digit
		staa	x
		inx
		ldaa	a1
		lsra
		lsra
		lsra
		lsra
		bsr	hex_digit
		staa	x
		inx
		rts

hex_digit	adda	#'0'
		cmpa	#'9'
		bls	hex_digit_rts
		adda	#'@'-'9'
hex_digit_rts	rts

ext		db	'.$$$', 0
		endp


;-----------------------------------------------------------
writeln_stdout	proc
		ldx	#crlf
		int	$68
		rts
		endp

point_newln	db	'.'
crlf		db	13, 10
empty_string	db	0

writeln 	proc
		ldaa	#10
		int	$22
		rts
		endp


test_redirect	proc
		ldx	file_handles
		ldx	x		;handle1
		inx
		inx
		ldaa	x, chr_hndl_page
		cmpa	header_con + chr_page
		bne	ret
		ldaa	x, chr_hndl_read
		cmpa	header_con + chr_read_ptr
		bne	ret
		ldaa	x, chr_hndl_read+1
		cmpa	header_con + chr_read_ptr + 1
ret		rts
		endp

int_69		proc		;print char on STDOUT
		global	int_68

		staa	char
		ldx	#char
int_68				;print string on STDOUT
		stx	int_68_table

		bsr	test_redirect
		bne	another_drv

		ldx	int_68_table
		int	$23
		rts
another_drv
		ldx	int_68_table
		jsr	str_length
		tstb
		bne	cut
		cmpa	#80
		bls	size_ok
cut		clrb
		ldaa	#80
size_ok
		ldx	getline_buffer
		stx	int_68_table+2
		ldx	#int_68_table
		int	$2D

		ldx	getline_buffer
		stx	int_68_table
		staa	int_68_table+3
		stab	int_68_table+2
		ldaa	#1
		ldx	#int_68_table
		int	$4D
		rts
char		db	0, 0
		endp

pr_version	proc
		ldx	#ver_str
		int	$78
		clra
		rts
		endp

scrmarg 				;screen right & bootom margin
		db	40,25
		db	10,25
		db	20,25
		db	40,25
		db	80,25

;-----------------------

		list	on
copyright	dw	$D680
ver_str 	dw	$E2B0,$A857,$32AB,$0535,$6CD6,$677F,$0BA1,$0000,$5D0D
		dw	$1E59,$0307,$D5E1,$3D7A,$D480,$24CE,$D14A,$76CE,$66B6  ;**version

		dw	$CFF0,$1818,$0189,$342C,$D007,$E150,$69D7,$6486,$5320
		dw	$0536,$6C95,$7740,$1168,$2148,$0071,$99F9,$9E60,$4390
		dw	$FF0A
		       ;10, 'è∫´§®≠ 601/601A   UniDOS (R)  Vers. 3.10'
		       ;10, '(C) çàèã "è∞Æ£∞†¨≠Æ Æ±®£≥∞ø¢†≠•" 1988-90', 10, 10

		error	*/$E000
		ds	$E000-*,$FF
resident_end
		end
