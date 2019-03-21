; ***********************************************************
; *							    *
; *	      ОПЕРАЦИОННА СИСТЕМА    U n i D O S	    *
; *	    за персонален микрокомпютър ПЪЛДИН 601	    *
; *							    *
; *    Copyright (C) 1988  НИПЛ "Програмно осигуряване"     *
; *							    *
; *		 (C) 1988  Иво Найденов НЕНОВ		    *
; *		 (C) 1988  Орлин Димитров ШОПОВ 	    *
; *							    *
; ***********************************************************
; *							    *
; *			  File System			    *
; *		  Version 3.12 / 04-Apr-1991		    *
; *	  5 години от сватбата на YGP (дървена сватба)	    *
; *							    *
; ***********************************************************
		list	off

; ПРЕДУПРЕЖДЕНИЕ:
; Текста на операционната система се дава само за справка.
; Всяко директно обръщение към кода или модифициране на
; променливите на операционната система нарушава концепцията
; за съвместимост с различни версии. НИПЛ "Програмно осигуряване"
; си запазва правото да прави промени в кода и променливите на
; операционната система с цел подобрение на функционирането.
; Не се поема никаква отговорност за несъвместимост на програмни
; продукти, неспазили протокола за използване на операционната
; система с бъдещи версии.
; Обръщенията към операционната система следва да се извършват
; по протокола описан в ръководството за потребителя.

;------------------------------------------------------------
; КОНСТАНТИ:
		list	on
maxfiles	=	$20
handle_size	=	$30 + 2

;fdcslct 	equ	$e6c0
;fdcstat 	equ	$e6d0		;СМ609
;fdcdata 	equ	$e6d1
;rom_page	equ	$E6F0

MEMPAGE_SEL	equ	$17

code		equ	$C000

variables1	equ	$E700
variables2	equ	$E000

;Error return codes
_NO_ERROR	=	0	      ;No error
_INV_FUNCTION	=	1	      ;Invalid function number
_INV_DRV	=	2	      ;Invalid drive
_WRT_PROT	=	3	      ;Disk write protected
_ADDR_ERR	=	4	      ;Address error
_DTA_ERR	=	5	      ;Data error
_GENERAL_ERR	=	6	      ;General failure
_INV_SECTOR	=	7	      ;Invalid sector
;Reserved	=	8	      ;Reserved
_BAD_DESCR	=	9	      ;Invalid media type
_FAT_ERROR	=      10	      ;FAT error
_INV_PATH	=      11	      ;Path not found
;Reserved	=      12	      ;Reserved
_NO_HANDLE	=      13	      ;Too many open files
_ACC_DENIED	=      14	      ;Access denied
_FILE_OPEN	=      15	      ;File already open
_INV_HANDLE	=      16	      ;Invalid file handle
_DISK_FULL	=      17	      ;Disk full
_FILE_LOST	=      18	      ;File lost in directory
_INV_NAME	=      19	      ;Invalid name
_DIR_FULL	=      20	      ;Root directory full
_DIR_EXIST	=      21	      ;Directory exist
_CUR_DIR	=      22	      ;Attempt to remove the current directory
_DIR_NOT_EMPTY	=      23	      ;Directory not empty
_BAD_POSITION	=      24	      ;Bad LSEEK position
;Reserved	=      25	      ;Reserved
_NOT_DISK_FILE	=      26	      ;Not disk file
_TOO_MANY_DRVRS =      27	      ;Too many drivers installed
_NOT_SAME_DEV	=      28	      ;Not same device
_FILE_EXIST	=      29	      ;File exist
_PRN_TIMEOUT	=      30	      ;Printer timeout
_PRN_ERROR	=      31	      ;Priner general failure
_PRN_PAPER_END	=      32	      ;Printer out of paper

_EOF		=     200
_RESERVED_CLU	=     201
_BAD_CLU	=     202



;--------------------------------------------------------
;Zero page variables
;--------------------------------------------------------
indos		=	$28
equipment	=	$29

swic		=	$2C
swib		=	$2D
swia		=	$2E
swix		=	$2F

hundreds	=	$40
seconds 	=	$41
minutes 	=	$42
hours		=	$43
day		=	$44
month		=	$45
year		=	$46
century 	=	$47

himem		=	$EE00 + $F*2
lomem		=	$EE00 + $E*2
resident	=	$EE00 + $D*2

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
;Current dir buffer
;--------------------------------------------------------
		section 0
cur_dir_name	ds	$40
cur_dir_start	ds	2
cur_dir_size	=	*
		ends

;--------------------------------------------------------
;FindFirst & FindNext entry table
;--------------------------------------------------------
		section 0
find_name	ds	8
find_ext	ds	3
find_drive	ds	1
find_cluster	ds	2
find_sector	ds	1
find_position	ds	1
find_attr_req	ds	1
find_attr_inv	ds	1
find_wild_dis	ds	1
		ends

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


		list	on
a1		=	$60
a2		=	$61
x1		=	$62
x2		=	$64
tmps		=	$66

fat_drive	=	$68
rw_buff_drive	=	$69

open_name	=	$6A
open_buff	=	$6C
open_addr	=	$6E

rwf_addr	=	$70
rwf_hndl	=	$72


		section variables1
fat_buf1	ds	$200
fat_buf2	ds	$200

current_drive	ds	1
first_chr_drv	ds	2
head_table	ds	16		;Up to 8 disk device drivers

file_handles	ds	2		;Pointer to file handles area
n_handles	ds	1		;Maximum number of file handles

;a1		 ds	 1
;a2		 ds	 1
;x1		 ds	 2
;x2		 ds	 2
;tmps		 ds	 2

rw_fat_sva	ds	1
rw_fat_svb	ds	1
fat_head_addr	ds	2

;fat_drive	 ds	 1
get_fat_p	ds	1
fat_offset	ds	2
fat_value	ds	2

call_a		ds	1
call_b		ds	1
call_err	ds	1
call_x		ds	2

free_x		ds	2

free_n_clust	ds	2
free_clust	ds	2
spc2		ds	1

alloc_cnt	ds	2
alloc_n_clust	ds	2

;rw_buff_drive	 ds	 1
rw_buff_dta	ds	2
rw_buff_sec	ds	2
rw_buff_area	ds	1

calc_x		ds	2

find_x		ds	2
find_ofs	ds	2

ff_dir_buff	ds	2
ff_path 	ds	2
ff_path1	ds	2
ff_drive	ds	2
ff_table	ds	2
ff_attr_req	ds	1
ff_attr_inv	ds	1
ff_dis_wild	ds	1
ff_x		ds	2

media_err	ds	1
media_dir	ds	2

set_dir_path	ds	2
set_dir_ptr	ds	2

find_file_x	ds	2

;open_name	 ds	 2
;open_buff	 ds	 2
;open_addr	 ds	 2
open_mode	ds	1
open_sector	ds	2
open_handle	ds	1
open_dir_addr	ds	2
open_clust	ds	2
has_points	ds	1

;rwf_addr	 ds	 2
;rwf_hndl	 ds	 2
rwf_err 	ds	1
rwf_b		ds	1
rwf_remain	ds	2
rwf_n_bytes	ds	2
rwf_lng 	ds	2
rwf_buf_beg	ds	2
rwf_to_eos	ds	2
new_pos 	ds	4
alloc_new_clust ds	2

ae_req		ds	1
ae_inv		ds	1
ae_name 	ds	2
ae_x		ds	2
ae_drive	ds	2
parent_clust	ds	2

mark_sec	ds	1
mark_clust	ds	2

rd_x		ds	2

copy_x		ds	2

size_buff	ds	2

ren_drive	ds	1
ren_sector	ds	2
ren_position	ds	1
ren_entry_ptr	ds	2
ren_dir_entry	ds	$20

exp_cnt 	ds	1
exp_himem	ds	2

readln_table	ds	4
readln_x	ds	2
readln_hndl	ds	1
readln_cnt	ds	1


parm_addr	ds	2
head_addr	ds	2
int17table	ds	6
int17seek_table ds	6
int40table	ds	5
int42table	ds	6


find_buff	ds	19		;Find buff length
dir_entry_buff	ds	$20
;
		ERROR	*/$EC00
;
		ends	;variables1


		section variables2
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

cur_dir1	ds	cur_dir_size
cur_dir2	ds	cur_dir_size

drive_a_type	ds	1		;$80 - double step
drive_a_tracks	ds	1

drive_b_type	ds	1
drive_b_tracks	ds	1

drive_type_ptr	ds	2

param_str	ds	$81

con_buff_ptr	ds	2
con_buff	ds	80+1

trunc_x 	ds	2
cr_flag 	ds	1
eol_flag	ds	1

alloc_x1	ds	2
;
		ERROR	*/$E600        ;E5E0
;
		ends
;		list	on
;----------------------------------------------------------

		org	code
		dw	$A55A
		db	'UniDOS  '
		jmp	init_buffers
		jmp	print_version

		db	7
		dw	int_7

		db	$40
		dw	int_40

		db	$41
		dw	int_41

		db	$42
		dw	int_42

		db	$43
		dw	int_43

		db	$44
		dw	int_44

		db	$45
		dw	int_45

		db	$46
		dw	int_46

		db	$47
		dw	int_47

		db	$48
		dw	int_48

		db	$49
		dw	int_49

		db	$4a
		dw	int_4a

		db	$4b
		dw	int_4b

		db	$4c
		dw	int_4c

		db	$4d
		dw	int_4d

		db	$4e
		dw	int_4e

		db	$4f
		dw	int_4f

		db	$50
		dw	int_50

		db	$51
		dw	int_51

		db	$52
		dw	int_52

		db	$53
		dw	int_53

		db	$54
		dw	int_54

		db	$55
		dw	int_55

		db	$56
		dw	int_56

		db	$57
		dw	int_57

		db	$58
		dw	int_58

		db	$59
		dw	int_59

		db	$38
		dw	int_38			;terminate

		db	$5a
		dw	int_5a		;commit file

		db	$5b
		dw	int_5b

		db	$5c
		dw	int_5c

		db	$5d
		dw	int_5d

		db	$5e
		dw	int_5e

		db	$70
		dw	int_70		;lock unlock

		db	$6C
		dw	int_6C		;trunc. file

		db	$6B
		dw	int_6B		;create new file

		db	0
;		dw	0

version_no	db	3,12

version 	db	10, 'UniDOS (R) kernel  Version 3.12', 0
;copyright	 db	 10, '(c) Ivo Nenov & Orlin Shopov - Eagle software, 1988-89',10,0

print_version	proc
		ldx	#version
		int	$23
		rts
		endp

init_buffers	proc
		bsr	print_version


		ldaa	#$80
		oraa	equipment
		staa	equipment

		ldx	#0
		stx	first_chr_drv

		ldx	#0
		stx	file_handles
		clr	n_handles
		ldaa	#10
		int	$5B
		tsta
		beq	cont

		ldx	$FFFE			;Reset
		jmp	x
cont

		clr	current_drive
		ldx	#0
		stx	drive_a_type		;Note: drive_x_type &
		stx	drive_b_type		;drive_x_tracks са заедно

		ldx	#header_slides
		stx	x1
		ldx	#header_a
		stx	x2
		ldaa	#2*header_size + 4*chr_head_size
		clrb
		jsr	move_mem

		ldx	#head_table
		ldaa	#16
		clrb
		jsr	mem_set

		ldx	#header_a
		ldab	MEMPAGE_SEL
		int	$5D
		ldx	#header_b
		ldab	MEMPAGE_SEL
		int	$5D

		ldx	#header_nul
		ldab	MEMPAGE_SEL
		int	$5E
		ldx	#header_aux
		ldab	MEMPAGE_SEL
		int	$5E
		ldx	#header_prn
		ldab	MEMPAGE_SEL
		int	$5E
		ldx	#header_con
		ldab	MEMPAGE_SEL
		int	$5E

		ldx	#file_buf1+$200
		bsr	init_buff
		ldx	#file_buf2+$200
init_buff
		ldaa	#$FF
		staa	x, buff_drive
		clr	x, buff_sector
		clr	x, buff_sector+1
		clr	x, buff_modified
		clr	x, buff_n_files
		rts
		endp

buff1_addr	dw	file_buf1
buff2_addr	dw	file_buf2

header_slides
		dw	init_a, read_a, write_a
		db	0
		dw	fat_buf1, cur_dir1
		db	$ff, 0, 0
		dw	$200
		db	2, 1, 2
		dw	$70, 720
		db	$FD, 2, 9, 2

		dw	init_b, read_b, write_b
		db	0
		dw	fat_buf2, cur_dir2
		db	$ff, 0, 0
		dw	$200
		db	2, 1, 2
		dw	$70, 720
		db	$FD, 2, 9, 2

chr_slides
		db	'NUL     '
		dw	nul_read
		dw	nul_write
		dw	nul_init
		db	0, 0, 0

		db	'PRN     '
		dw	0
		dw	prn_write
		dw	prn_init
		db	0, 0, 0

		db	'AUX     '
		dw	aux_read
		dw	aux_write
		dw	aux_init
		db	0, 0, 0

		db	'CON     '
		dw	con_read
		dw	con_write
		dw	con_init
		db	0, 0, 0

all_files	db	'\*.*', 0

;		list	off


;----------------------------------------
;INT $5B - expand file handles
;	       A - n_handles
;----------------------------------------
int_5b		proc
;		cmpa	#maxfiles
;		bcs	valid
;		ldaa	#maxfiles

valid		cmpa	n_handles
		bls	return

		suba	n_handles
		staa	exp_cnt
		ldx	himem
		stx	exp_himem
main_loop	ldx	#file_handles
search_loop	stx	x1
		ldx	x
		bne	search_loop

		ldx	#handle_size
		ldab	#0
		int	$2A
		cpx	#0
		beq	err_no_mem
		stx	x2
		ldx	x1
		ldaa	x2+1
		ldab	x2
		staa	x,1
		stab	x

		ldx	x2
		ldaa	#handle_size
		clrb
		jsr	mem_set

		dec	exp_cnt
		bne	main_loop

		ldaa	swia
		staa	n_handles
		int	$2C
return		clr	swia
		rts
err_no_mem
		ldx	exp_himem
		int	$2B
		ldaa	exp_cnt
		staa	swia
		rts
		endp

;----------------------------------------
; Console device driver
;----------------------------------------
con_read	proc
		global	chr_return

		ldx	con_buff_ptr
		cpx	#con_buff
		bne	not_empty
		ldab	#80
		ldx	#con_buff
		int	$21
		ldaa	#10
		int	$22
not_empty
		ldx	con_buff_ptr
		ldaa	x
		beq	end_str
		inx
		stx	con_buff_ptr
		bra	return
end_str
		ldaa	#13
		ldx	#con_buff
		stx	con_buff_ptr
return
		clc
chr_return
		staa	swia
		tpa
		staa	swic
		rts
		endp

con_write	proc
		tst	eol_flag
		beq	not_eol
		cmpa	#' '
		bcs	control     ;>=
		psha
		ldaa	#10	;LF
		int	$22
		pula
		int	$22
		clr	eol_flag
		bra	chr_return
control
		int	$22
		ldaa	#1
		staa	cr_flag
		clr	eol_flag
		bra	chr_return
not_eol
		tst	cr_flag
		beq	not_cr
		clr	cr_flag
		int	$22
		bra	chr_return
not_cr
		psha
		int	$14
		tab
		pula
		int	$22
		pshb
		int	$6D	;screen width
		deca
		tab		;width
		pula		;x pos
		sba
		bmi	not_eol1   ;A < B
		ldaa	#1
		staa	eol_flag
not_eol1
		clra
;		clc
		bra	chr_return
		endp

con_init	proc
		ldx	#con_buff
		stx	con_buff_ptr

		clr	eol_flag
		clr	cr_flag

		clra
;		clc
		bra	chr_return
		endp


;----------------------------------------
; Printer device driver
;----------------------------------------
prn_write	proc
		clrb
		int	$26
		bita	#1
		bne	error
		clra
;		clc
		bra	chr_return
error
		bita	#%00100000
		beq	no_pend
		ldaa	#_PRN_PAPER_END
		sec
		bra	chr_return
no_pend 	bita	#%01000000
		bne	timeout
		ldaa	#_PRN_ERROR
		sec
		bra	chr_return
timeout 	ldaa	#_PRN_TIMEOUT
		sec
		bra	chr_return
		endp


prn_init	proc
		ldab	#2		;init
		int	$26
		bita	#%01000000
		bne	no_err
		ldaa	#_PRN_ERROR
		sec
		bra	chr_return_
no_err		clra
;		clc
		bra	chr_return_
		endp

;----------------------------------------
; Nul & Aux device driver
;----------------------------------------
nul_read
nul_write
nul_init
aux_read
aux_write
aux_init
		clra
;		clc
chr_return_	jmp	chr_return


;----------------------------------------
; FLOPPY DISK DEVICE DRIVER
;----------------------------------------

init_a		proc
		ldx	#drive_a_type
		stx	drive_type_ptr
		ldx	#header_a
		ldaa	#0			;Drive
		bra	media_chk
		endp

init_b		proc
		ldx	#drive_b_type
		stx	drive_type_ptr
		ldx	#header_b
		ldaa	#1			;Drive
		bra	media_chk
		endp


;----------------------------------------------------------
;x - device driver header
;a - drive
;drive_type_ptr - ^drive_X_type
;----------------------------------------------------------
media_chk	proc
;check SPT & HEADS <> 0
;BPS = $200
		stx	x1
		staa	int17table		;drive
		clr	int17table+1		;track
		clr	int17table+2		;head
		ldaa	#1
		staa	int17table+3		;sector
		ldx	x, fat_buff
		stx	int17table+4		;buffer
		ldaa	#1			;read command
		ldx	drive_type_ptr
		oraa	x
		ldx	#int17table

		ldaa	0,x
		staa	2,x
		ldd	4,x
		std	0,x
		ldd	#0
		std	3,x

		ldaa	#$41
		int	$17

		jsr	make_error
		bcs	return

		ldaa	int17table+1
		ldab	int17table+0
		adda	#$b
		adcb	#0
		staa	x2+1
		stab	x2

		ldx	x2
		tst	x, 13		;spt
		beq	bad_descr
		tst	x, 15		;heads
		beq	bad_descr
		ldx	x		;bps
		cpx	#2		;$200
		bne	bad_descr

		sei
		sts	tmps
		ldx	x2
		txs
		ldx	x1
		pula
		staa	x, bps+1
		pula
		staa	x, bps
		pula
		staa	x, spc
		pula
		staa	x, brs
		pula
		pula
		staa	x, nof
		pula
		staa	x, nde+1
		pula
		staa	x, nde
		pula
		staa	x, tns+1
		pula
		staa	x, tns
		pula
		staa	x, med
		pula
		staa	x, spf
		pula
		pula
		staa	x, spt
		pula
		pula
		staa	x, heads

		lds	tmps
		cli
		bra	chk_drive_type
bad_descr
		sec
		ldaa	#_BAD_DESCR
return		jmp	chr_return

chk_drive_type				;Note that X = X1
		ldab	x, heads
		clra
mult_loop	adda	x, spt		;A := heads * spt
		decb
		bne	mult_loop
					;note B=0
		ldx	x, tns
		int	$29		;division
		stx	x1		;cylinders
		tst	x1
		bne	bad_descr
		ldx	drive_type_ptr
		ldaa	x1 + 1
		cmpa	x, 1		;previos num. of cylinders
		beq	ret_no_error

		clr	x		;drive_x_type
		staa	x, 1		;drive_x_cylinders
		cmpa	#40
		bhi	ret_no_error

		ldaa	int17table
		staa	int17seek_table
		ldaa	#2
		staa	int17seek_table+1
		clr	int17seek_table + 2		;head
		ldx	#int17seek_table

		ldaa	#$40		; init
		int	$17

		ldx	drive_type_ptr
		tsta
		bne	seek_error
		ldaa	#$80
		cmpb	#1
		beq	store
		clra
store		staa	x
ret_no_error	clra
		clc
		jmp	chr_return
seek_error	clr	x
		jsr	make_error
		bra	return
		endp


set_tbl 	proc
		stx	parm_addr
		staa	int17table		;drive
		ldx	x
		stx	int17table + 4		;buffer
		rts
		endp

;----------------------------------------------------------
;x - parameter table pointer from INT $40
;----------------------------------------------------------
read_a		proc
		ldaa	#$41
		int	$17
		bsr	make_error
		jmp	chr_return

;		bsr	set_tbl
;		ldx	#drive_a_type
;		stx	drive_type_ptr
;		ldx	#header_a
;		bra	read_log
		endp

;----------------------------------------------------------
;x - parameter table pointer from INT $40
;----------------------------------------------------------
read_b		proc
		ldaa	#$41
		int	$17
		bsr	make_error
		jmp	chr_return

;		ldaa	#1
;		bsr	set_tbl
;		ldx	#drive_b_type
;		stx	drive_type_ptr
;		ldx	#header_b
;		bra	read_log
		endp

;----------------------------------------------------------
;x - parameter table pointer from INT $40
;----------------------------------------------------------
write_a 	proc
		ldaa	#$42
		int	$17
		bsr	make_error
		jmp	chr_return

;		ldaa	#0
;		bsr	set_tbl
;		ldx	#drive_a_type
;		stx	drive_type_ptr
;		ldx	#header_a
;		bra	write_log
		endp

;----------------------------------------------------------
;x - parameter table pointer from INT $40
;----------------------------------------------------------
write_b 	proc
		ldaa	#$42
		int	$17
		bsr	make_error
		jmp	chr_return

;		ldaa	#1
;		bsr	set_tbl
;		ldx	#drive_b_type
;		stx	drive_type_ptr
;		ldx	#header_b
;		bra	write_log
		endp


read_log	proc
		bsr	log_to_abs
		bcs	return
		ldx	drive_type_ptr
		ldaa	x
		oraa	#1			;read command
		ldx	#int17table
		bsr	call17
		bsr	make_error
return		jmp	chr_return
		endp


write_log	proc
		bsr	log_to_abs
		bcs	return
		ldx	drive_type_ptr
		ldaa	x
		oraa	#2			;write command
		ldx	#int17table
		bsr	call17
		bsr	make_error
return		jmp	chr_return
		endp

;-----------------------------------------
; A - command
; X - table pointer
;-----------------------------------------
call17		proc
		staa	a1
		int	$17
		tsta
		beq	return
		ldaa	a1
		int	$17
return
		rts
		endp


;----------------------------------------------------------
;INPUT: a - error code returned by INT $17
;OUTPUT: a - UNIDOS error code
;----------------------------------------------------------
make_error	proc
		sec
		ldab	#_GENERAL_ERR
		bita	#%11000010
		bne	return
		ldab	#_ADDR_ERR
		bita	#%00111000
		bne	return
		ldab	#_DTA_ERR
		bita	#%00000100
		bne	return
		ldab	#_WRT_PROT
		bita	#%00000001
		bne	return
		ldab	#_NO_ERROR
		clc
return
		tba
		rts
		endp

log_to_abs	proc
		stx	head_addr
		ldx	x, tns
		stx	x1

		ldx	parm_addr
		ldaa	x, 3			;Sector high  byte
		cmpa	x1
		bne	label1
		ldaa	x, 4
		cmpa	x1+1
label1		bcc	error

		ldx	head_addr
		ldaa	x, spt
		clrb
		ldx	parm_addr
		ldx	x, 3			;Sector number
		int	$29
		inca
		staa	int17table + 3
		stx	x1
		ldx	head_addr
		ldaa	x, heads
		clrb
		ldx	x1
		int	$29
		staa	int17table + 2		;Head
		stx	x1
		ldaa	x1+1
		staa	int17table + 1		;Cylinder
		clc
		rts
error
		ldaa	#_INV_SECTOR
		sec
		rts
		endp

;---------------------------------------------------------
; INT_41 - return bios version in BA
;---------------------------------------------------------
INT_41		proc
;		cpx	#$A55A
;		bne	ver
;		ldx	#copyright
;		int	$23
ver		ldx	version_no
		stx	swib		;BA
		rts
		endp


;----------------------------------------------------------
;A - drive
;RETURN : X - header address
;----------------------------------------------------------
get_head_addr	proc
		cmpa	#7
		bhi	err_bad_drv
		asla
		staa	x1+1
		ldaa	#/head_table
		staa	x1
		ldx	x1
		ldx	x, head_table
		beq	err_bad_drv
		clc
		ldaa	#_NO_ERROR
		rts
err_bad_drv	ldaa	#_INV_DRV
		sec
		rts
		endp

;----------------------------------------------------------
; INT $40
;----------------------------------------------------------
;a=1 - read
;a=2 - write
;x - parameter table pointer
;    2b - buffer
;    1b - drive (0- A, 1- B ...)
;    2b - logical sector
;----------------------------------------------------------
int_40		proc
;		jsr	debug

		ldaa	x, 2		;drive no
		jsr	get_head_addr
		bcs	error

		ldab	x, block_page

		ldaa	swia
		deca
		beq	read
		deca
		beq	write
		ldaa	#_INV_FUNCTION
error		staa	swia
		rts

read		ldx	x, read_addr
		bra	do_it
write		ldx	x, write_addr
do_it
		ldaa	#$5F
		int	$2F

		ldx	swix
		int	$5F

		staa	swia
		rts
		endp


;------------------------------------------------
;IMPORT: A -   (1 - read, 2- write)
;	 XH - bit: 0 - Ignore allowed
;		   1 - Retry allowed
;		   2 - Fail allowed
;	 XL - Where is the sector
;		0 - DOS area
;		1 - FAT
;		2 - Directory area
;		3 - Data area
;	 Int40table - information to INT $40
;
;EXPORT: A - error code returned from INT $40
;	 B - not modified
;------------------------------------------------
call_disk_drv	proc
		stx	call_x
		stab	call_b
		anda	#3
		staa	call_a
call_40
		ldx	#Int40Table
		int	$40
		staa	call_err
		tsta
		beq	exit_b

		oraa	#$80
		ldab	call_x
		aslb
		aslb
		orab	call_x + 1
		aslb
		aslb
		orab	call_a
		int	$7			;Critical error

		tsta
		beq	ignore
		cmpa	#1
		beq	retry
		cmpa	#2
		beq	abort
fail
		ldab	#4
		bitb	call_x
		beq	abort
		ldaa	call_err
exit_b		ldab	call_b
		rts
ignore
		ldab	#1
		bitb	call_x
		beq	fail
		clra
		bra	exit_b
retry
		ldab	#2
		bitb	call_x
		beq	fail
		ldaa	call_a
		bra	call_40
abort
		clra
		int	$38

		endp

int_7		proc
		ldaa	#3		;Fail
		staa	swia
		rts
		endp
;-----------------------------------------
;FAT routines
;-----------------------------------------

;-----------------------------------------
;A - drive
;B - sector
;-----------------------------------------
read_fat_sec	proc
		staa	rw_fat_sva
		stab	rw_fat_svb

		jsr	get_head_addr
		bcs	return
		stx	fat_head_addr
		ldab	rw_fat_svb		;sector
		cmpb	x, fat_sec_no
		clc
		beq	return
		bsr	write_fat_sec1
		bcs	return
read
		ldab	rw_fat_svb
		ldx	fat_head_addr
		cmpb	x, spf
		bcc	fat_err
		addb	x, brs
		stab	int40table+4
		bcs	fat_err
		clr	int40table+3
		ldaa	rw_fat_sva
		staa	int40table+2
		ldx	x, fat_buff
		stx	int40table
		ldaa	#1
		ldx	#%011000000001	    ;Fail, Retry, FAT area
		jsr	call_disk_drv
		tsta
		bne	error
		ldx	fat_head_addr
		ldab	rw_fat_svb
		stab	x, fat_sec_no
		clc
		rts

fat_err 	ldaa	#_FAT_ERROR
error
		sec
return		rts
		endp


;-----------------------------------------
;A - drive
;-----------------------------------------
write_fat_sec	proc
		global	write_fat_sec1

		staa	rw_fat_sva
		jsr	get_head_addr
		bcs	return
		stx	fat_head_addr
write_fat_sec1
		ldx	fat_head_addr			   ;header
		tst	x, fat_modified
		beq	ret_no_err
		clr	x, fat_modified
		ldab	x, fat_sec_no
		addb	x, brs
		stab	int40table+4
		bcs	fat_err
		clr	int40table+3
		ldaa	rw_fat_sva
		staa	int40table+2
		ldab	x, nof
		ldx	x, fat_buff
		stx	int40table
loop		ldx	#%011100000001			    ;Fail, Retry, Ignore
		ldaa	#2
		jsr	call_disk_drv
		tsta
		bne	error

		ldx	fat_head_addr
		ldaa	x, spf
		adda	int40table + 4
		staa	int40table + 4
		bcs	fat_err
		decb
		bne	loop

ret_no_err	clc
		rts

fat_err 	ldaa	#_FAT_ERROR
error		sec
return		rts
		endp



;-----------------------------------------
;fat_drive - drive
;X - FAT field no.
;RETURN X - FAT field value
;	A - error no
;-----------------------------------------
get_fat_field	proc
		global	get_byte

		stx	x1
		ldaa	x1+1
		ldab	x1
		asla
		rolb
		adda	x1+1
		adcb	x1
		lsrb
		rora
		staa	fat_offset+1
		stab	fat_offset
		tpa
		staa	get_fat_p

		bsr	get_byte
		bcs	return
		staa	fat_value+1
		ldx	fat_offset
		inx
		stx	fat_offset
		bsr	get_byte
		bcs	return
		staa	fat_value

		ldaa	get_fat_p
		tap
		ldaa	fat_value+1
		ldab	fat_value
		bcs	odd
		andb	#$f
		stab	fat_value
		ldx	fat_value
		clc
		rts
odd		lsrb
		rora
		lsrb
		rora
		lsrb
		rora
		lsrb
		rora
		staa	fat_value+1
		stab	fat_value
		ldx	fat_value
		clc
		rts

get_byte	;fat_offset - byte offset
		;fat_drive - drive

		ldab	fat_offset
		lsrb
		ldaa	fat_drive
		jsr	read_fat_sec
		bcs	return

		ldx	fat_head_addr
		ldaa	fat_offset+1
		ldab	fat_offset
		andb	#1
		adda	x, fat_buff+1
		adcb	x, fat_buff
		staa	x1+1
		stab	x1
		ldx	x1
		ldaa	x
		clc
return		rts
		endp


;-----------------------------------------
;fat_drive - drive
;X - FAT field no.
;BA - FAT field value
;RETURN : A - error no.
;-----------------------------------------
set_fat_field	proc
		stx	x1
		staa	fat_value+1
		stab	fat_value

		ldaa	x1+1
		ldab	x1
		asla
		rolb
		adda	x1+1
		adcb	x1
		lsrb
		rora
		staa	fat_offset+1
		stab	fat_offset
		bcs	odd

		ldaa	fat_value
		anda	#$F
		staa	fat_value
		jsr	get_byte
		bcs	return
		ldaa	fat_value+1
		bsr	put_byte
		bcs	return
		ldx	fat_offset
		inx
		stx	fat_offset
		jsr	get_byte
		bcs	return
		anda	#$f0
		oraa	fat_value
		bsr	put_byte
		bcs	return
		rts
odd
		ldaa	fat_value+1
		ldab	fat_value
		asla
		rolb
		asla
		rolb
		asla
		rolb
		asla
		rolb
		staa	fat_value+1
		stab	fat_value
		jsr	get_byte
		bcs	return
		anda	#$f
		oraa	fat_value+1
		bsr	put_byte
		bcs	return
		ldx	fat_offset
		inx
		stx	fat_offset
		jsr	get_byte
		bcs	return
		ldaa	fat_value
		bsr	put_byte
		rts
put_byte
		staa	x
		ldaa	fat_drive
		jsr	get_head_addr
		bcs	return
		ldaa	#1
		staa	x, fat_modified
		clc
return		rts
		endp


;-----------------------------------------
;fat_drive - drive
;RETURN : A - error no.
;	  X - cluster_no
;-----------------------------------------
alloc_clust	proc
		ldx	#2
		stx	alloc_cnt
		clrb
		bsr	clust_to_sec
		bcs	alloc_ret
		stx	alloc_x1

		ldaa	fat_drive
		jsr	get_head_addr
		ldaa	x, tns+1
		suba	alloc_x1+1
		staa	alloc_x1+1
		ldaa	x, tns
		sbca	alloc_x1
		staa	alloc_x1

		ldaa	x, spc
		clrb
		ldx	alloc_x1
		int	$29
		stx	alloc_n_clust
loop
		ldx	alloc_cnt
		jsr	get_fat_field
		bcs	alloc_ret
		cpx	#0
		beq	found
		ldx	alloc_cnt
		inx
		stx	alloc_cnt
		cpx	alloc_n_clust
		bne	loop

		ldaa	#_DISK_FULL
		sec
		rts
found
		ldx	alloc_cnt
		ldaa	#$FF
		ldab	#$F
		jsr	set_fat_field
		bcs	alloc_ret
		ldx	alloc_cnt
		clc
alloc_ret	rts
		endp


;-----------------------------------------
; Calculate first logical sector number
; from cluster no.
;INPUT : X - cluster no.
;	 B - sector in cluster
;	 fat_drive - drive
;RETURN : X - logical sector
;	  A - error
;-----------------------------------------
clust_to_sec	proc
		stx	fat_value
		stab	rw_fat_svb
		cpx	#0
		bne	not_root_dir

		ldaa	fat_drive
		jsr	get_head_addr
		bcc	drv_ok
		rts
drv_ok
		ldab	x, nof
		clra
loopr
		adda	x, spf
		decb
		bne	loopr
		adda	rw_fat_svb
		adda	x, brs
		staa	x1+1
		clr	x1
		ldx	x1
		clc
		rts

not_root_dir	ldaa	fat_value+1
		ldab	fat_value
		suba	#2
		sbcb	#0
		staa	fat_value+1
		stab	fat_value

		ldaa	fat_drive
		jsr	get_head_addr
		bcs	return
		stx	fat_head_addr
		ldab	x, spc
		stab	x1+1
		clr	x1
		ldx	x1
		clra
		clrb
loop0		adda	fat_value+1
		adcb	fat_value
		dex
		bne	loop0
		staa	fat_value+1
		stab	fat_value
		ldx	fat_head_addr

		ldaa	x, nde+1
		ldab	x, nde
		lsrb
		rora
		lsrb
		rora
		lsrb
		rora
		lsrb
		rora
		adda	fat_value+1
		adcb	fat_value
		staa	fat_value+1
		stab	fat_value
		ldab	x, nof
		clra
loop1
		adda	x, spf
		decb
		bne	loop1
		adda	rw_fat_svb
		adda	x, brs

		adda	fat_value+1
		staa	fat_value+1
		bcc	cont1
		inc	fat_value
cont1
		ldx	fat_value
		clc
return		rts
		endp


;-----------------------------------------
;ENTER :
;	 X - cluster
;	 B - sector in cluster
;	 fat_drive - drive
;RETURN : A - error code
;	  X - cluster
;	  B - sector in cluster
;-----------------------------------------
calc_next_sec	proc
		stx	calc_x
		ldaa	fat_drive
		pshb
		jsr	get_head_addr
		pulb
		bcs	error
		stx	fat_head_addr

		incb
		cmpb	x, spc
		bcs	return

		ldx	calc_x
		jsr	get_fat_field
		bcs	error
		stx	calc_x
		clrb

		ldaa	calc_x
		cmpa	#$F
		bne	return
		ldaa	calc_x+1
		cmpa	#$F0
		bcs	return
		cmpa	#$F7
		bcs	reserved
		beq	bad
		bhi	eof
return
		ldx	calc_x
		clc
error		rts
eof		ldaa	#_EOF
		sec
		rts
reserved	ldaa	#_RESERVED_CLU
		sec
		rts
bad		ldaa	#_BAD_CLU
		sec
		rts
		endp


;-----------------------------------------
;fat_drive - drive
;BA - start cluster
;-----------------------------------------
free_chain	proc
		staa	x1+1
		stab	x1
		ldx	x1
		beq	return
		stx	free_x
loop		ldx	free_x
		jsr	get_fat_field
		bcs	error
		ldx	free_x
		staa	free_x+1
		stab	free_x
		clra
		clrb
		jsr	set_fat_field
		bcs	error

		ldab	free_x
		cmpb	#$F
		bne	loop
		ldaa	free_x+1
		cmpa	#$F0
		bcs	loop
		cmpa	#$F7
		bls	err
return		clc
		rts
err		ldaa	#_FAT_ERROR
error		sec
		rts
		endp

;-----------------------------------------
; Buffers routines
;-----------------------------------------


;-----------------------------------------
;ENTER : X - buffer pointer
;	 rw_buff_area - area
;EXIT : A - error code
;-----------------------------------------
write_buff	proc
		global	write_buff1

		stx	int40table
		stx	rw_buff_dta
		ldaa	#2
		adda	rw_buff_dta
		staa	rw_buff_dta
write_buff1
		ldx	rw_buff_dta
		tst	x, buff_modified
		beq	return
		clr	x, buff_modified
		ldaa	x, buff_drive
		staa	int40table+2
		ldx	x, buff_sector
		stx	int40table+3

		ldaa	rw_buff_area
		staa	x1+1
		ldaa	#7
		staa	x1
		ldx	x1

		ldaa	#2			;write sector
		jsr	call_disk_drv
		tsta
		bne	error
return		clc
		ldaa	#_NO_ERROR
		rts
error		sec
		rts
		endp


;-----------------------------------------
;ENTER : X - buffer pointer
;	 BA- sector
;	 rw_buff_drive- drive
;	 rw_buff_are - area
;EXIT : A - error code
;-----------------------------------------
read_buff	proc
		staa	rw_buff_sec+1
		stab	rw_buff_sec
		stx	rw_buff_dta
		stx	int40table

		ldaa	#2
		adda	rw_buff_dta
		staa	rw_buff_dta

		ldx	rw_buff_dta
		ldaa	rw_buff_drive
		cmpa	x, buff_drive
		bne	read_it
		ldx	x, buff_sector
		cpx	rw_buff_sec
		bne	read_it
no_err		ldaa	#_NO_ERROR
		clc
return		rts
read_it
		bsr	write_buff1
		bcs	return
		ldaa	rw_buff_drive
		staa	int40table+2
		ldx	rw_buff_sec
		stx	int40table+3

		ldaa	rw_buff_area
		staa	x1+1
		cmpa	#3		;Data area
		beq	ignore
		ldaa	#%0110
		bra	store_it
ignore		ldaa	#7
store_it
		staa	x1
		ldx	x1

		ldaa	#1
		jsr	call_disk_drv
		tsta
		bne	err

		ldx	rw_buff_dta
		ldaa	rw_buff_drive
		staa	x, buff_drive
		ldaa	rw_buff_sec
		staa	x, buff_sector
		ldaa	rw_buff_sec+1
		staa	x, buff_sector+1
		clc
		rts
err
		ldx	rw_buff_dta
		ldab	#$ff
		stab	x, buff_drive
		sec
		rts
		endp


;-----------------------------------------
;ENTER : X - buffer pointer
;-----------------------------------------
set_buff_modif	proc
		bsr	skip_buff_dta
		ldaa	#1
		staa	x, buff_modified
		rts
		endp

;-----------------------------------------
;X - buff pointer
;ret X - buff attrib addr
;-----------------------------------------
skip_buff_dta	proc
		stx	x1
		inc	x1
		inc	x1
		ldx	x1
		rts
		endp

;-----------------------------------------
; Directory routines
;-----------------------------------------


;-----------------------------------------
;A - position
;ret : X - addr in buff1
;-----------------------------------------
pos_to_addr	proc
		clrb
		asla
		rolb
		asla
		rolb
		asla
		rolb
		asla
		rolb
		asla
		rolb
		adda	buff1_addr+1
		adcb	buff1_addr
		stab	x1
		staa	x1+1
		ldx	x1
		rts
		endp

;-----------------------------------------
;ENTER : X1- first string (terminated by 0)
;	 X2- second string
;	 A - length
;	 B<>0 - disable widcard
;RETURN : CF=1 - not equal
;-----------------------------------------
compare_str	proc
		tsta
		beq	error
		staa	a1
loop
		ldx	x1
		ldaa	x
		beq	exit
		inx
		stx	x1
		ldx	x2

		tstb
		bne	no_wild
		cmpa	#'?'
		beq	inc
		cmpa	#'*'
		beq	return
no_wild 	cmpa	x
		bne	error
inc		inx
		stx	x2

		dec	a1
		bne	loop

return		clc
		rts
exit
		ldx	x2
loop1		ldaa	x
		cmpa	#' '
		bne	error
		inx
		dec	a1
		bne	loop1
		clc
		rts

error		sec
		rts
		endp


;-----------------------------------------
;ENTER : X - FindFirst & FindNext table pointer
;EXIT : A - error code
;	X - dir entry pointer
;-----------------------------------------
find_entry	proc
		global	rd_sec, calc_next
		stx	find_x
		jsr	rd_sec
		bcc	loop1
return1 	rts
error1		jmp	error

loop1		ldx	find_x
		ldaa	x, find_position
		cmpa	#$10
		bcs	compare 			;<
		clr	x, find_position
		jsr	calc_next
		bcc	read_sec
		cmpa	#200
		bcc	error1
		sec
		rts
read_sec	jsr	rd_sec
		bcs	return1
compare
		ldx	find_x
		ldaa	x, find_position
		jsr	pos_to_addr
		stx	find_ofs
		stx	x2
		ldx	find_x
		stx	x1

		ldx	find_ofs
		ldaa	x, dir_name
		beq	error
		cmpa	#5
		beq	inc_pos
		cmpa	#$E5
		beq	inc_pos

		ldaa	x, dir_attribute
		staa	a1
		ldx	find_x
		anda	x, find_attr_req
		cmpa	x, find_attr_req
		bne	inc_pos
		ldaa	a1
		anda	x, find_attr_inv
		bne	inc_pos
all_files
		ldab	x, find_wild_dis
		ldaa	#8
		jsr	compare_str
		bcs	inc_pos

		ldaa	find_x+1
		ldab	find_x
		adda	#8
		adcb	#0
		staa	x1+1
		stab	x1
		ldaa	find_ofs+1
		ldab	find_ofs
		adda	#8
		adcb	#0
		staa	x2+1
		stab	x2
		ldaa	#3
		ldx	find_x
		ldab	x, find_wild_dis
		jsr	compare_str
		bcc	found
inc_pos
		ldx	find_x
		inc	x, find_position
		jmp	loop1
error
		ldaa	#_INV_PATH
err_exit	sec
return		rts

found		ldx	find_ofs
		clc
		rts

calc_next	;find_x - Find table ptr
		ldx	find_x
		ldaa	x, find_drive
		staa	fat_drive
		ldab	x, find_sector
		ldx	x, find_cluster
		beq	root_dir
		jsr	calc_next_sec
		bcs	return
		stx	x1
		ldx	find_x
		stab	x, find_sector
		ldaa	x1
		staa	x, find_cluster
		ldaa	x1+1
		staa	x, find_cluster+1
		clc
		rts
root_dir
		pshb
		ldaa	fat_drive
		jsr	get_head_addr
		pulb
		bcs	return
		pshb
		ldaa	x, nde+1
		ldab	x, nde
		lsrb
		rora
		lsrb
		rora
		lsrb
		rora
		lsrb
		rora
		pulb
		incb
		staa	a1
		cmpb	a1
		bcc	eof
		ldx	find_x
		stab	x, find_sector
		clc
		rts
eof		ldaa	#_EOF
		sec
		rts


rd_sec
		ldx	find_x
		ldaa	x, find_drive
		staa	fat_drive
		ldab	x, find_sector
		ldx	x, find_cluster
		jsr	clust_to_sec
		bcs	return

		ldaa	fat_drive
		staa	rw_buff_drive
		stx	x1
		ldaa	#2		;DIR area
		staa	rw_buff_area
		ldaa	x1+1
		ldab	x1
		ldx	buff1_addr
		jmp	read_buff
		endp



;-----------------------------------------
;X1 - src (terminated by 0)
;X2 - dest
;-----------------------------------------
get_name	proc
		ldaa	x2+1
		ldab	x2
		adda	#8
		adcb	#0
		staa	find_x+1
		stab	find_x

		ldx	x1
		ldaa	x
		cmpa	#'.'
		bne	cont
		ldaa	x, 1
		bsr	cmp_end
		beq	one_p
		cmpa	#'.'
		bne	cont
		ldaa	x, 2
		bsr	cmp_end
		beq	two_p
cont
		ldab	#8
loop1		ldx	x1
		ldaa	x
		bsr	cmp_end
		beq	exit1
		cmpa	#'.'
		beq	exit_p
		inx
		stx	x1
		tstb
		beq	loop1
		decb
		ldx	x2
		staa	x
		inx
		stx	x2
		bra	loop1
exit_p		inx
		stx	x1
exit1
		ldx	x2
		clr	x

		ldab	#3
loop2		ldx	x1
		ldaa	x
		bsr	cmp_end
		beq	exit2
		inx
		stx	x1
		tstb
		beq	loop2
		decb
		ldx	find_x
		staa	x
		inx
		stx	find_x
		bra	loop2
exit2
		tstb
		beq	return
clear		ldx	find_x
		clr	x
return		rts
cmp_end
		tsta
		beq	return
		cmpa	#'\'
		rts

one_p		inx
		stx	x1
		ldaa	#'.'
		ldx	x2
		bra	one

two_p		inx
		inx
		stx	x1
		ldaa	#'.'
		ldx	x2
		staa	x
		inx
one
		staa	x
		inx
		clr	x
		bra	clear
		endp

;-----------------------------------------
;ENTER : ff_attr_req, ff_attr_inv - attributes
;	 ff_dis_wild - enable/disable wildcard
;	 ff_table - FindFirst & FindNext table ptr
;	 ff_dir_buff - dir entry buff.
;	 ff_path - path/name pointer
;	 ff_drive - drive
;EXIT : A - error code
;-----------------------------------------
find_first	proc
		ldx	ff_table
		ldaa	ff_drive
		staa	x, find_drive

		clr	x, find_position
		clr	x, find_sector
		clr	x, find_cluster
		clr	x, find_cluster+1
		ldx	ff_path
		ldaa	x
		cmpa	#'\'
		bne	curr_dir
		inx
		stx	ff_path
		bra	loop
curr_dir
		ldx	ff_table
		ldaa	x, find_drive
		jsr	get_head_addr
		bcs	return
		ldx	x, cur_dir_ptr
		ldaa	x, cur_dir_start+1
		ldab	x, cur_dir_start
		ldx	ff_table
		staa	x, find_cluster+1
		stab	x, find_cluster
loop
		ldx	ff_path
		stx	x1
		ldx	ff_table
		stx	x2
		jsr	get_name
		ldx	x1
		stx	ff_path
		tst	x
		beq	last_name
		ldx	ff_table
		ldaa	#1
		staa	x, find_wild_dis
		ldaa	#%10000 		;dir only
		ldab	#%1100
		bra	find_it
last_name
		ldx	ff_table
		ldaa	ff_dis_wild
		staa	x, find_wild_dis
		ldaa	ff_attr_req
		ldab	ff_attr_inv

find_it
		staa	x, find_attr_req
		stab	x, find_attr_inv
		jsr	find_entry
		bcs	return
		stx	x1
		ldx	ff_path
		tst	x
		beq	entry_found
		inx
		stx	ff_path

		ldx	x1
		ldaa	x, dir_start_clust
		ldab	x, dir_start_clust+1
		ldx	ff_table
		staa	x, find_cluster+1
		stab	x, find_cluster
		clr	x, find_position
		clr	x, find_sector
		bra	loop
entry_found
		ldx	ff_dir_buff
		stx	x2
		ldaa	#$20
		clrb
		jsr	move_mem
		clc
return		rts
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
		inx
		inx
		cmpa	#'a'
		bcc	low
		suba	#'A'
		rts
low		suba	#'a'
		rts
no_drive
		ldaa	current_drive
		rts
		endp

;*******************************************;
;	     W A R N I N G		    ;
;					    ;
;    These two procedures (Medea check and  ;
; Find first) are not independent !!!!	    ;
;					    ;
;*******************************************;


;-----------------------------------------
; INT $5C
;-----------------------------------------
;Media check
;INPORT: A - drive
;EXIT : A - error code
;-----------------------------------------
int_5c		proc
		staa	ff_drive
check_again
		ldaa	ff_drive
		jsr	get_head_addr
		bcc	valid_drv
		jmp	return
valid_drv
		tst	x, n_open
		beq	check_it
		jmp	no_check
check_it
		ldab	x, block_page
		ldx	x, init_addr
		ldaa	#$5F
		int	$2F

		int	$5F			;media check
		bcc	no_error
		jmp	media_error
no_error
		ldaa	ff_drive
		ldab	#$FF
		ldx	buff1_addr
		jsr	skip_buff_dta		;don'd modify A, B
		cmpa	x, buff_drive
		bne	chk_second
		stab	x, buff_drive
chk_second
		ldx	buff2_addr
		jsr	skip_buff_dta		;don't modify A, B
		cmpa	x, buff_drive
		bne	init_head
		stab	x, buff_drive
init_head
		ldaa	ff_drive
		jsr	get_head_addr
		ldaa	#$FF
		staa	x, fat_sec_no
		clr	x, fat_modified
		ldx	x, cur_dir_ptr
		stx	ff_path
		stx	ff_x
		tst	x
		beq	root_dir
		ldaa	ff_attr_req
		psha
		ldaa	ff_attr_inv
		psha
		ldaa	ff_dis_wild
		psha

		ldx	ff_dir_buff
		stx	media_dir
		ldx	#dir_entry_buff
		stx	ff_dir_buff

		ldaa	#%00010000
		staa	ff_attr_req
		clr	ff_attr_inv
		ldaa	#1
		staa	ff_dis_wild

		jsr	find_first
		pula
		staa	ff_dis_wild
		pula
		staa	ff_attr_inv
		pula
		staa	ff_attr_req

		ldx	media_dir
		stx	ff_dir_buff

		bcs	root_dir
		ldx	#dir_entry_buff
		ldaa	x, dir_attribute
		bita	#%00010000
		beq	root_dir

		ldaa	x, dir_start_clust
		ldab	x, dir_start_clust+1
		ldx	ff_x
		cmpa	x, cur_dir_start+1
		bne	root_dir
		cmpb	x, cur_dir_start
		beq	no_check
root_dir
		ldx	ff_x
		clr	x
		clr	x, cur_dir_start
		clr	x, cur_dir_start+1

no_check	clra
return
		staa	swia
		rts

media_error
		staa	media_err
		ldab	ff_drive
		stab	int40table+2
		oraa	#$80
		ldab	#%01100000		;Fail, Retry, DOS area
		ldx	#Int40Table
		int	$7

		tsta
		beq	fail
		cmpa	#1
		beq	retry
		cmpa	#2
		beq	abort
fail
		ldaa	media_err
		bra	return
retry
		jmp	check_again
abort
		clra
		int	$38
		endp

;-----------------------------------------
; INT $42
;-----------------------------------------
;Get first entry
;ENTER : A - required attr mask
;	 B - invalid attr mask (bit 7 - disable wildcard)
;	 X - parameters
;		1w - FindFirst & FindNext table ptr
;		1w - dir entry buff.
;		1w - path
;EXIT : A - error code
;-----------------------------------------
int_42		proc
		staa	ff_attr_req
		clra
		aslb
		rola
		lsrb
		staa	ff_dis_wild
		stab	ff_attr_inv
		stx	x1
		ldx	x, 2
		stx	ff_dir_buff
		ldx	x1
		ldx	x
		bne	ext_buff
		ldx	#find_buff
ext_buff
		stx	ff_table
		ldx	x1
		ldx	x, 4
		jsr	copy_parm
		bcs	return

		stx	ff_path1
		jsr	get_drive
		stx	ff_path1
		staa	ff_drive

		int	$5c		;Media check
		tsta
		bne	return

		ldx	ff_path1
		stx	ff_path
		jsr	find_first
		bcs	return
		clra
return
		staa	swia
		rts
		endp

;-----------------------------------------
; INT $43
;ENTER : X - parameters
;		1w - FindFirst & FindNext table ptr
;		1w - dir entry buff.
;EXIT : A - error code
;-----------------------------------------
;Get next entry
;-----------------------------------------
int_43		proc
		stx	x2
		ldx	x, 2
		stx	ff_dir_buff
		ldx	x2
		ldx	x
		bne	ext_buff
		ldx	#find_buff
ext_buff
		inc	x, find_position
		jsr	find_entry
		bcs	return
		stx	x1
		ldx	ff_dir_buff
		stx	x2
		ldaa	#$20
		clrb
		jsr	move_mem
		clra
return
		staa	swia
		rts
		endp

;-----------------------------------------
;ENTER : open_name - name pointer
;	 A - attr. req.
;	 B - inv
;EXIT : find_buff
;	X - entry ptr
;	B <> 0 - entry found
;	parent_clust - parrent dir start cluster
;		       (if B<>0 - invalid)
;	ae_name - name pointer
;-----------------------------------------
alloc_entry	proc
		staa	ae_req
		stab	ae_inv
		jsr	scan_name
		tsta
		bne	not_found
		ldaa	find_buff+find_position
		jsr	pos_to_addr

		ldab	#1
return		clc
		rts
not_found
		cmpa	#_INV_PATH
		bne	error1

		ldx	open_name
		jsr	get_drive
		staa	ae_drive			;drive

cont		stx	x1
		stx	x2

loop		ldaa	x
		beq	end_string
		cmpa	#'\'
		bne	inc_cnt
		stx	x1
inc_cnt 	inx
		bra	loop
end_string
		ldx	x1
		ldaa	#'\'
		cmpa	x
		bne	current
		clr	x
		inx
		stx	ae_name

		ldx	x2
		tst	x
		beq	root_dir

		ldaa	#%00010000
		ldab	#%10001011
		jsr	scan_name
		tsta
		beq	found
		sec
error1		jmp	error

found		ldaa	dir_entry_buff+dir_start_clust
		ldab	dir_entry_buff+dir_start_clust+1
		staa	parent_clust+1
		stab	parent_clust
		bra	find_entry
root_dir
		clr	parent_clust
		clr	parent_clust+1
		bra	find_entry
current
		stx	ae_name
		ldaa	ae_drive
		jsr	get_head_addr
		ldx	x, cur_dir_ptr
		ldx	x, cur_dir_start
		stx	parent_clust
find_entry
		ldx	ae_name
		tst	x
		bne	copy_it
		ldaa	#_INV_NAME
		bra	error1
copy_it 	stx	x1
		ldx	#find_buff+find_name
		stx	x2
		jsr	get_name

		ldx	#find_buff+find_name
		ldab	#8
		jsr	chk_str
		bcs	error1
		ldx	#find_buff+find_name+8
		ldab	#3
		jsr	chk_str
		bcs	error1

		ldx	parent_clust
		stx	find_buff+find_cluster
		ldx	#find_buff
		stx	find_x
		clr	x, find_sector
search_loop
		jsr	rd_sec
		bcs	error1
		clrb
		ldx	buff1_addr
		stx	x1
loop1
		ldx	x1
		ldaa	x
		beq	found_end
		cmpa	#$E5
		beq	found_free
		cmpa	#5
		beq	found_free
		ldaa	#$20
		adda	x1+1
		staa	x1+1
		bcc	not_inc
		inc	x1
not_inc 	incb
		cmpb	#$10
		bne	loop1

		jsr	calc_next
		bcc	search_loop
;allocate next cluster
		cmpa	#_EOF
		bne	error2

		stx	ae_x
		ldx	find_buff+find_cluster
		bne	subdir
		ldaa	#_DIR_FULL
error2		jmp	error
found_free
		stab	find_buff+find_position
		bra	return0
subdir
		ldaa	ae_drive
		staa	fat_drive
		jsr	alloc_clust
		bcs	error2
		stx	x1
		ldaa	x1+1
		ldab	x1
		ldx	find_buff+find_cluster
		staa	find_buff+find_cluster+1
		stab	find_buff+find_cluster
		jsr	set_fat_field
		bcs	error2
		clr	find_buff+find_sector
		jsr	rd_sec
		bcs	error2
		ldx	buff1_addr
		stx	x1
		clrb			;new position
found_end
		stx	ae_x
		stab	find_buff+find_position
		cmpb	#$F
		beq	mark_next_sec
		ldaa	#$20
		adda	x1+1
		staa	x1+1
		bcc	not_inc1
		inc	x1
not_inc1	ldx	x1
		clr	x
		ldx	buff1_addr
		jsr	set_buff_modif

return_x	ldx	ae_x
return0
		clrb
		clc
		rts
mark_next_sec
		ldab	find_buff+find_sector
		ldx	find_buff+find_cluster
		stab	mark_sec
		stx	mark_clust

		jsr	calc_next
		bcs	chk_error

		ldaa	ae_drive
		staa	fat_drive
		staa	rw_buff_drive
		ldab	find_buff+find_sector
		ldx	find_buff+find_cluster
		jsr	clust_to_sec
		bcs	error
		stx	x1

		ldab	mark_sec
		ldx	mark_clust
		stab	find_buff+find_sector
		stx	find_buff+find_cluster

		ldaa	#2		;DIR area
		staa	rw_buff_area
		ldaa	x1+1
		ldab	x1
		ldx	buff2_addr
		jsr	read_buff
		bcs	error

		ldx	buff2_addr
		clr	x
		jsr	set_buff_modif
		ldaa	#2		;DIR area
		staa	rw_buff_area
		ldx	buff2_addr
		jsr	write_buff
		bcs	error
		bra	return_x

chk_error	cmpa	#_EOF
		bne	error
		bra	return_x


error		cmpa	#_EOF
		bcs	cont1
		ldaa	#_FAT_ERROR
cont1		sec
		rts


chk_str
;B - length
;X - str pointer
loop_chk	ldaa	x
		beq	chk_ok
		cmpa	#$80
		bcc	chk_inv
		cmpa	#' '
		bls	chk_inv
		cmpa	#'?'
		beq	chk_inv
		cmpa	#'*'
		beq	chk_inv
		cmpa	#'.'
		beq	chk_inv
		inx
		decb
		bne	loop_chk
chk_ok		clc
		rts
chk_inv
		ldaa	#_INV_NAME
		sec
		rts
		endp


;-----------------------------------------
; INT $44 - Set current drive
;ENTER : A - new drivre
;EXIT : A - error code
;-----------------------------------------
int_44		proc
		psha
		jsr	get_head_addr
		pulb
		bcs	error
		stab	current_drive
		clra
error		staa	swia
		rts
		endp

;-----------------------------------------
; INT $45 - Get current drive
;ENTER : nothing
;EXIT : A - current drive
;-----------------------------------------
int_45		proc
		ldaa	current_drive
		staa	swia
		rts
		endp

;-----------------------------------------
; INT $46 - Set current directory
;ENTER :
;	 X - buffer pointer (64 bytes)
;EXIT : A - error code
;-----------------------------------------
int_46		proc
		jsr	copy_parm
		bcs	error1

		stx	set_dir_path
		jsr	get_drive
		stx	set_dir_path
		staa	ff_drive
		ldaa	x
		bne	cont
		jmp	inv_dir
cont		cmpa	#'\'
		bne	chk_path
		tst	x, 1
		beq	make_name
chk_path
		ldx	swix
		stx	int42table+4
		ldx	#find_buff
		stx	int42table
		ldx	#dir_entry_buff
		stx	int42table+2
		ldaa	#%10000 		;dir only
		ldab	#%10001100		;disable wildcard
		ldx	#int42table
		int	$42
		tsta
		beq	make_name
error1		jmp	error
make_name
		ldaa	ff_drive
		jsr	get_head_addr
		ldx	x, cur_dir_ptr
		stx	set_dir_ptr

		ldx	set_dir_path
		ldaa	x
		cmpa	#'\'
		bne	append
		inx
		stx	set_dir_path
		ldx	set_dir_ptr
		clr	x
append
		ldx	set_dir_path
		jsr	str_length
		staa	ff_path+1
		stab	ff_path
		ldx	set_dir_ptr
		jsr	str_length
		adda	ff_path+1
		adcb	ff_path
		tstb
		bne	inv_dir
		cmpa	#62
		bhi	inv_dir

		ldx	set_dir_path
		tst	x
		beq	root

		ldx	set_dir_ptr
loop1
		tst	x
		beq	exit1
		inx
		bra	loop1
exit1		ldaa	#'\'
		staa	x
		inx
		stx	x2
		ldx	set_dir_path
		stx	x1
		jsr	str_copy
;optimize path
optimize
		ldx	set_dir_ptr
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
exit2
		ldx	#dir_entry_buff
		ldaa	x, dir_start_clust
		ldab	x, dir_start_clust+1
		ldx	set_dir_ptr
		staa	x, cur_dir_start+1
		stab	x, cur_dir_start
no_err		clra
error		staa	swia
		rts
root
		ldx	set_dir_ptr
		clr	x, cur_dir_start
		clr	x, cur_dir_start+1
		bra	no_err
inv_dir
		ldaa	#_INV_NAME
		bra	error

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


;-----------------------------------------
; INT $47 - Get current directory
;ENTER : A - drive
;	 X - buffer pointer (64 bytes)
;EXIT : A - error code
;-----------------------------------------
int_47		proc
		jsr	get_head_addr
		bcs	error
		ldx	x, cur_dir_ptr
		stx	x1
		ldx	swix
		stx	x2
		jsr	str_copy
		clra
error		staa	swia
		rts
		endp


test_reopen	proc
		ldab	find_buff+find_drive
		stab	fat_drive
		ldx	find_buff+find_cluster
		ldab	find_buff+find_sector
		jsr	clust_to_sec
		stx	open_sector

		ldx	file_handles
		stx	x1
		ldab	n_handles
tst_loop
		ldx	x1
		inx
		inx
		ldaa	x
		beq	inc_hndl
		bita	#4
		bne	inc_hndl
		ldaa	find_buff+find_drive
		cmpa	x, hndl_drive
		bne	inc_hndl
		ldaa	find_buff+find_position
		cmpa	x, hndl_dir_pos
		bne	inc_hndl
		ldx	x, hndl_dir_sec
		cpx	open_sector
		bne	inc_hndl

		ldaa	n_handles
		sba
		tab
		ldaa	#_FILE_OPEN
		sec
		rts

inc_hndl	ldx	x1
		ldx	x
		stx	x1
decr_b		decb
		bne	tst_loop
		clc
		rts
		endp

;-----------------------------------------
;return X - buffer
;-----------------------------------------
find_file_buff	proc
		cpx	#0
		beq	find
		stx	find_file_x
		inc	find_file_x
		inc	find_file_x
		ldx	find_file_x
		ldaa	x, buff_drive
		jsr	get_head_addr
		bcs	cont1
		tst	x, n_open
		bne	cont1
		ldx	find_file_x
		ldaa	#$FF
		staa	x, buff_drive
cont1
		ldx	find_file_x
		bra	cont

find
		ldaa	buff1_addr+1
		ldab	buff1_addr
		addb	#2
		staa	x1+1
		stab	x1
		ldx	x1
		ldaa	x, buff_n_files
		staa	a1
		ldaa	buff2_addr+1
		ldab	buff2_addr
		addb	#2
		staa	x2+1
		stab	x2
		ldx	x2
		ldaa	x, buff_n_files
		cmpa	a1
		bcs	cont
		ldx	x1
cont
		inc	x, buff_n_files
		stx	x1
		dec	x1
		dec	x1
		ldx	x1
		rts
		endp


;-----------------------------------------
; INT $59 - Move file handle (Internal use only !!)
;ENTER : A - file handle
;EXIT : A - error code
;	B - new handle
;-----------------------------------------
int_59		proc
		bsr	find_handle
		bcs	error
		stab	swib
		tba
		bsr	calc_hndl_addr
		stx	x2
		ldaa	swia
		bsr	calc_hndl_addr
		stx	x1
		clrb
		ldaa	#$30
		jsr	move_mem
		ldaa	swia
		bsr	calc_hndl_addr
		clr	x
		clra
error		staa	swia
		rts
		endp

;-----------------------------------------
;ret B - handle
;    A - error
;-----------------------------------------
find_handle	proc
		ldx	file_handles
		stx	x1
		clrb
loop		ldx	x1
		inx
		inx
		tst	x
		beq	found
		ldx	x1
		ldx	x
		stx	x1
		incb
		cmpb	n_handles
		bne	loop
		ldaa	#_NO_HANDLE
		sec
		rts
found		clc
		rts
		endp


;-----------------------------------------
;A - handle
;ret X - address
;-----------------------------------------
calc_hndl_addr	proc
		cmpa	n_handles
		bcc	error		;>=
		ldx	#file_handles
loop		ldx	x
		tsta
		beq	found
		deca
		bra	loop
found
		inx
		inx
		clc
		rts
error		ldaa	#_INV_HANDLE
		sec
		rts
		endp


;-----------------------------------------
; INT $4A - open file
;ENTER : A - open mode (1 - ro, 2 - wo, 3 - rw)
;	 X - parameters
;		1w - path/name
;		1w - buffer pointer
;EXIT : A - error code
;	B - file handle
;-----------------------------------------
int_4a		proc
		global open_file1, open_char

		anda	#3
;		staa	open_mode
;		stx	x1
;		ldx	x, 2
;		stx	open_buff
;		ldx	x1
;		ldx	x
;		jsr	copy_parm
;		bcs	error1
;		stx	open_name
;
;		bsr	find_handle
;		bcs	error1
;		stab	open_handle

		jsr	o_c_common1
		bcs	error1

		jsr	open_char
		bcs	no_char
		staa	swia
		stab	swib
		rts
no_char
		clra
		ldab	#%10011000
		jsr	scan_name
		tsta
		bne	error1

		ldaa	open_mode
		bita	#2
		beq	tst_reopen
		ldaa	dir_entry_buff+dir_attribute
		bita	#3				;hiden, r/o
		beq	tst_reopen
		ldaa	#_ACC_DENIED
error1		jmp	error
open_file1
tst_reopen	jsr	test_reopen
		bcc	not_open
		staa	swia
		stab	swib
		rts
not_open
		ldx	open_buff
		jsr	find_file_buff
		stx	open_buff

		ldaa	open_handle
		jsr	calc_hndl_addr
		stx	open_addr

		ldaa	open_mode
		staa	x, hndl_mode
		ldaa	find_buff+find_drive
		staa	x, hndl_drive
		ldaa	find_buff+find_position
		staa	x, hndl_dir_pos
		ldaa	open_sector+1
		ldab	open_sector
		staa	x,hndl_dir_sec+1
		stab	x,hndl_dir_sec
		ldaa	dir_entry_buff+dir_start_clust
		ldab	dir_entry_buff+dir_start_clust+1
		staa	x,hndl_cur_clust+1
		stab	x,hndl_cur_clust
		clr	x,hndl_cur_sec
		clr	x,hndl_file_pos
		clr	x,hndl_file_pos+1
		clr	x,hndl_file_pos+2
		clr	x,hndl_file_pos+3

		inx
		stx	x2
		ldx	#dir_entry_buff
		stx	x1
		ldaa	#$20
		clrb
		jsr	move_mem


		ldx	open_addr
		ldaa	open_buff+1
		ldab	open_buff
		staa	x, hndl_buff+1
		stab	x, hndl_buff

		ldaa	x, hndl_drive
		staa	fat_drive
		ldx	x, hndl_cur_clust
		clrb
		jsr	clust_to_sec
		bcs	error
		stx	x1
		ldx	open_addr
		ldaa	x1+1
		staa	x, hndl_sector+1
		ldaa	x1
		staa	x, hndl_sector

		ldaa	x, hndl_cur_clust
		oraa	x, hndl_cur_clust+1
		bne	valid_clust
		ldaa	#$FF
		staa	x, hndl_cur_sec
valid_clust
		ldaa	x, hndl_drive
		jsr	get_head_addr
		inc	x, n_open

		clra
		ldab	open_handle
		stab	swib
error
		staa	swia
		rts


open_char
		ldx	open_name
		clr	has_points
chr_loop	ldaa	x
		beq	chr_exit
		cmpa	#':'
		bne	chr_incx
		tst	x, 1
		bne	no_chr
		clr	x
		ldaa	#1
		staa	has_points
		bra	chr_exit
chr_incx	inx
		bra	chr_loop
chr_exit
		ldx	first_chr_drv
		stx	open_addr
chr_loop1
		ldx	open_addr
		stx	x2
		ldx	open_name
		stx	x1
		ldaa	#8
		ldab	#1
		jsr	compare_str
		bcc	chr_found
		ldx	open_addr
		ldx	x, chr_next
		stx	open_addr
		bne	chr_loop1

		tst	has_points
		bne	chr_error
no_chr		sec
		rts
chr_error	ldaa	#_INV_NAME
		clc
		rts
chr_found
		ldaa	open_handle
		jsr	calc_hndl_addr
		stx	open_buff

		ldaa	open_mode
		oraa	#4
		staa	x, chr_hndl_mode
		ldx	open_addr
		ldaa	x, chr_read_ptr+1
		ldab	x, chr_read_ptr
		ldx	open_buff
		staa	x, chr_hndl_read+1
		stab	x, chr_hndl_read
		ldx	open_addr
		ldaa	x, chr_write_ptr+1
		ldab	x, chr_write_ptr
		ldx	open_buff
		staa	x, chr_hndl_write+1
		stab	x, chr_hndl_write
		ldx	open_addr
		ldaa	x, chr_page
		ldx	open_buff
		staa	x, chr_hndl_page

		clr	x, chr_hndl_eof
		clr	x, chr_hndl_remain
		clc
		clra
		ldab	open_handle
		rts
		endp


scan_name	proc
;A - req,  B - inv bits
;open_name - name ptr
;ret :	  find_buff, dir_entry_buff

		ldx	#find_buff
		stx	int42table
		ldx	#dir_entry_buff
		stx	int42table+2
		ldx	open_name
		stx	int42table+4
		ldx	#int42table
		int	$42				;find first entry
		rts
		endp


o_c_common1	proc
		staa	open_mode
		stx	x1
		ldx	x, 2
		stx	open_buff
		ldx	x1
		ldx	x
		jsr	copy_parm
		bcs	error1
		stx	open_name

		jsr	find_handle
		bcs	error1
		stab	open_handle
		clc
error1		rts
		endp

;-----------------------------------------
; INT $6B - create new file
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
int_6B		proc
		ldx	x
		stx	open_name
		clra
		ldab	#%10011000
		jsr	scan_name
		tsta
		bne	not_found
		ldaa	#_FILE_EXIST
error		staa	swia
		rts
not_found
		cmpa	#_INV_PATH
		bne	error
		ldaa	swia
		ldab	swib
		ldx	swix
;!!!!!! 	jmp	int_4B	   !!!!!!!!
		endp
;-----------------------------------------
; INT $4B - create file
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
int_4b		proc
		global	copy_name

		anda	#7
;		staa	open_mode
;		stx	x1
;		ldx	x, 2
;		stx	open_buff
;		ldx	x1
;		ldx	x
;		jsr	copy_parm
;		bcs	error1
;		stx	open_name
;
;		jsr	find_handle
;		bcs	error1
;		stab	open_handle

		jsr	o_c_common1
		bcs	error1

		ldaa	open_mode
		psha
		ldaa	#2
		staa	open_mode
		jsr	open_char
		bcs	no_char
		staa	swia
		stab	swib
		pula
		rts
no_char
		pula
		staa	open_mode

		clra
		ldab	#%10011000
		jsr	scan_name
		tsta
		bne	not_open
		jsr	test_reopen
		bcc	not_open
		staa	swia
		stab	swib
		rts
not_open
		clra
		ldab	#%10011000
		jsr	alloc_entry
		bcs	error
		stx	open_dir_addr
		tstb
		beq	make_entry

		ldaa	#3
		bita	x, dir_attribute
		beq	free_space
		ldaa	#_ACC_DENIED
error1		bra	error
free_space
		ldaa	ae_drive
		staa	fat_drive
		ldaa	x, dir_start_clust
		ldab	x, dir_start_clust+1
		jsr	free_chain
		bcs	error
make_entry
		ldx	#dir_entry_buff
		ldaa	#$20
		clrb
		jsr	mem_set

		ldaa	open_mode
		oraa	#$20
		staa	dir_entry_buff+dir_attribute

		ldx	#find_buff+find_name
		stx	x1
		ldx	#dir_entry_buff+dir_name
		stx	x2
		ldab	#8
		bsr	copy_name
		ldx	#find_buff+find_ext
		stx	x1
		ldx	#dir_entry_buff+dir_ext
		stx	x2
		ldab	#3
		bsr	copy_name

		ldaa	#2			;wo
		staa	open_mode
		jsr	open_file1
		tsta
		bne	error
		ldx	open_addr
		stx	rwf_hndl
		ldx	open_dir_addr
		stx	rwf_addr
		jsr	update_buffs
		bcs	error
		ldab	open_handle
		stab	swib
		clra
error		staa	swia
		rts

copy_name	;x1 - src
		;x2 - dest
		;B - num bytes

		ldx	x1
		ldaa	x
		bne	inc_it
		ldaa	#' '
		bra	store_it
inc_it		inx
		stx	x1
		jsr	upcase_char
store_it	ldx	x2
		staa	x
		inx
		stx	x2
		decb
		bne	copy_name
		rts
		endp


;-----------------------------------------
; INT $48 - create subdirectory
;ENTER : X - name pointer
;EXIT : A - error code
;-----------------------------------------
int_48		proc
		jsr	copy_parm
		bcs	error1

		stx	open_name
		ldaa	#%00010000
		ldab	#%10001000
		jsr	alloc_entry
		tstb
		beq	can_create
		ldaa	#_DIR_EXIST
error1		jmp	error
can_create
		stx	open_addr
		ldaa	#$20
		clrb
		jsr	mem_set

		ldx	#find_buff+find_name
		stx	x1
		ldx	open_addr
		stx	x2
		ldab	#8
		bsr	copy_name
		ldx	#find_buff+find_name+8
		stx	x1
		ldx	open_addr
		stx	x2
		ldaa	#8
		adda	x2+1
		staa	x2+1
		bcc	no_inc
		inc	x2
no_inc		ldab	#3
		bsr	copy_name

		ldaa	ae_drive
		staa	fat_drive
		jsr	alloc_clust
		bcs	error1
		stx	open_clust
		clrb
		jsr	clust_to_sec
		bcs	error1

		stx	x2
		ldx	buff2_addr
		jsr	skip_buff_dta			;don't modify X2
		ldaa	fat_drive
		staa	x, buff_drive
		ldaa	x2
		staa	x, buff_sector
		ldaa	x2+1
		staa	x, buff_sector+1

		ldx	buff2_addr
		ldaa	#$60
		clrb
		jsr	mem_set

		ldx	buff2_addr
		ldaa	#11
		ldab	#' '
		jsr	mem_set

		ldx	buff2_addr
		stx	x1
		ldaa	#$20
		adda	x1+1
		staa	x1+1
		bcc	no_inc1
		inc	x1
no_inc1 	ldx	x1
		stx	ae_x
		ldaa	#11
		ldab	#' '
		jsr	mem_set

		ldx	open_addr
		ldaa	open_clust
		staa	x, dir_start_clust+1
		ldaa	open_clust+1
		staa	x, dir_start_clust
		bsr	make_entry

		ldx	buff2_addr
		ldaa	#'.'
		staa	x
		ldaa	open_clust
		staa	x, dir_start_clust+1
		ldaa	open_clust+1
		staa	x, dir_start_clust
		bsr	make_entry

		ldx	ae_x
		ldaa	#'.'
		staa	x
		staa	x, 1
		ldaa	parent_clust
		staa	x, dir_start_clust+1
		ldaa	parent_clust+1
		staa	x, dir_start_clust
		bsr	make_entry

		ldx	buff1_addr
		jsr	set_buff_modif
		ldx	buff2_addr
		jsr	set_buff_modif

		ldaa	#2		;DIR area
		staa	rw_buff_area
		ldx	buff1_addr
		jsr	write_buff
		bcs	error
		ldaa	#2		;DIR area
		staa	rw_buff_area
		ldx	buff2_addr
		jsr	write_buff
		bcs	error

		ldaa	ae_drive
		jsr	write_fat_sec
		bcs	error
		clra
error		staa	swia
		rts

make_entry
		stx	open_buff
		ldaa	#%00010000
		staa	x, dir_attribute
		jsr	pack_sys_time
		ldx	open_buff
		staa	x, dir_time
		stab	x, dir_time+1

		jsr	pack_sys_date
		ldx	open_buff
		staa	x, dir_date
		stab	x, dir_date+1
		rts
		endp

;-----------------------------------------
; INT $4C - read file
;ENTER : A - file handle
;	 X - parameters
;		1w - buffer pointer
;		1w - number of bytes
;EXIT : A - error code
;	X - number of bytes read
;-----------------------------------------
int_4c		proc
		ldab	#1
		jsr	rwf_get_parms
		bcc	acc_ok
error		staa	swia
		rts
acc_ok
		ldaa	#4
		bita	x, hndl_mode
		beq	disk_file

		ldx	rwf_remain
		stx	rwf_n_bytes

		ldx	rwf_hndl
		tst	x, chr_hndl_eof
		bne	chr_ret

		ldab	x, chr_hndl_page
		ldx	x, chr_hndl_read
		beq	chr_bad_acc
		ldaa	#$5F
		int	$2F

chr_loop	ldx	rwf_remain
		beq	chr_ret
		ldx	rwf_hndl
		ldaa	x, chr_hndl_remain
		bne	put_it
retry		int	$5F
		bcc	put_it
		staa	rwf_err
		int	$7
		cmpa	#1
		beq	retry
		tsta
		beq	put_it
		cmpa	#2
		bne	fail
		clra
		int	$38
fail		ldaa	rwf_err
		bra	chr_err

put_it		ldx	rwf_addr
		staa	x
		inx
		stx	rwf_addr
		ldx	rwf_remain
		dex
		stx	rwf_remain
		ldx	rwf_hndl
		tst	x, chr_hndl_remain
		bne	rem_ret
		cmpa	#$1A			;^Z
		beq	read_eof
		cmpa	#13
		bne	chr_loop
		ldaa	#10
		ldx	rwf_hndl
		staa	x, chr_hndl_remain
		bra	chr_loop

rem_ret 	clr	x, chr_hndl_remain
chr_ret
		clra
		jmp	valid_err
chr_bad_acc	ldaa	#_ACC_DENIED
chr_err 	jmp	valid_err
read_eof
		ldx	rwf_hndl
		ldaa	#1
		staa	x, chr_hndl_eof
		bra	chr_ret

disk_file
		ldaa	x, hndl_file_pos+3
		adda	rwf_remain+1
		staa	new_pos+3
		ldaa	x, hndl_file_pos+2
		adca	rwf_remain
		staa	new_pos+2
		ldaa	x, hndl_file_pos+1
		adca	#0
		staa	new_pos+1
		ldaa	x, hndl_file_pos
		adca	#0
		staa	new_pos

		ldaa	x, hndl_dir_entry+dir_file_size+3
		cmpa	new_pos
		bne	differ1
		ldaa	x, hndl_dir_entry+dir_file_size+2
		cmpa	new_pos+1
		bne	differ1
		ldaa	x, hndl_dir_entry+dir_file_size+1
		cmpa	new_pos+2
		bne	differ1
		ldaa	x, hndl_dir_entry+dir_file_size
		cmpa	new_pos+3
differ1 	bcc	valid_num			;>=

		ldaa	x, hndl_dir_entry+dir_file_size
		suba	x, hndl_file_pos+3
		staa	rwf_remain+1
		ldaa	x, hndl_dir_entry+dir_file_size+1
		sbca	x, hndl_file_pos+2
		staa	rwf_remain
valid_num
		ldx	rwf_remain
		stx	rwf_n_bytes
		beq	exit
read_loop
		jsr	rwf_calc_vars

		ldaa	rwf_remain
		cmpa	rwf_to_eos
		bne	differ
		ldaa	rwf_remain+1
		cmpa	rwf_to_eos+1
differ		bcc	long_read			;>=

		ldx	rwf_remain
		jsr	move_dta
		bcs	read_err
		bra	exit
long_read
		ldx	rwf_buf_beg
		bne	read_to_eos

		ldx	rwf_addr
		stx	int40table
		ldx	rwf_hndl
		ldaa	x, hndl_drive
		staa	int40table+2
		ldx	x, hndl_sector
		stx	int40table+3
		ldaa	#1
		ldx	#%011100000011			    ;Fail, Retry, Ignore, Data area
		jsr	call_disk_drv
		tsta
		bne	read_err
		ldx	#$200
		jsr	inc_fpos
		jsr	rwf_calc_next
		bcs	read_err
		bra	chk_cond
read_to_eos
		ldx	rwf_to_eos
		bsr	move_dta
		bcs	read_err
		jsr	rwf_calc_next
		bcs	read_err
chk_cond
		ldx	rwf_remain
		bne	read_loop
exit		clra
read_err
		cmpa	#200
		bcs	valid_err
		cmpa	#_EOF
		bne	bad_fat
		clra
		ldx	rwf_remain
		beq	valid_err
bad_fat 	ldaa	#_FAT_ERROR
valid_err	staa	swia
		ldaa	rwf_n_bytes+1
		suba	rwf_remain+1
		staa	swix+1
		ldaa	rwf_n_bytes
		sbca	rwf_remain
		staa	swix
		rts




move_dta	; X - number of bytes
		jsr	move_dta_read
		bcs	move_ret
		ldx	rwf_hndl
		ldaa	rwf_buf_beg+1
		ldab	rwf_buf_beg
		adda	x, hndl_buff+1
		adcb	x, hndl_buff
		staa	x1+1
		stab	x1
		ldx	rwf_addr
		stx	x2
		ldaa	rwf_lng+1
		ldab	rwf_lng
		jsr	move_mem
		ldx	rwf_lng
		jsr	inc_fpos
		clc
move_ret	rts
		endp


rwf_get_parms	proc
		stab	rwf_b
		stx	x1
		ldx	x
		stx	rwf_addr
		ldx	x1
		ldx	x, 2
		stx	rwf_remain

		jsr	calc_hndl_addr
		bcs	return
		stx	rwf_hndl
		tst	x, hndl_mode
		bne	file_open
		ldaa	#_INV_HANDLE
		sec
return		rts
file_open	ldaa	rwf_b
		bita	x, hndl_mode
		bne	acc_ok
		ldaa	#_ACC_DENIED
		sec
		rts
acc_ok		clc
		rts
		endp

;-----------------------------------------
; INT $4D - write file
;ENTER : A - file handle
;	 X - parameters
;		1w - buffer pointer
;		1w - number of bytes
;EXIT : A - error code
;	X - number of bytes written
;-----------------------------------------
int_4d		proc
		global	inc_fpos, move_dta_read, rwf_calc_vars, rwf_calc_next, calc_sec, copy_fpos_fsize
		ldab	#2
		bsr	rwf_get_parms
		bcc	acc_ok
error		staa	swia
		rts
acc_ok
		ldaa	#4
		bita	x, hndl_mode
		beq	disk_file

		ldx	rwf_remain
		stx	rwf_n_bytes

		ldx	rwf_hndl
		ldab	x, chr_hndl_page
		ldx	x, chr_hndl_write
		beq	chr_bad_acc
		ldaa	#$5F
		int	$2F

chr_loop	ldx	rwf_remain
		beq	chr_ret

		ldx	rwf_hndl

		ldx	rwf_addr
		ldaa	x

retry		int	$5F
		bcc	write_ok
		staa	rwf_err
		int	$7
		cmpa	#1
		beq	retry
		tsta
		beq	write_ok
		cmpa	#2
		bne	fail
		clra
		int	$38
fail		ldaa	rwf_err
		bra	chr_err

write_ok	ldx	rwf_addr
		inx
		stx	rwf_addr
		ldx	rwf_remain
		dex
		stx	rwf_remain
		bra	chr_loop
chr_ret
		clra
		bra	chr_err
chr_bad_acc	ldaa	#_ACC_DENIED
chr_err
		staa	swia
		ldaa	rwf_n_bytes+1
		suba	rwf_remain+1
		staa	swix+1
		ldaa	rwf_n_bytes
		sbca	rwf_remain
		staa	swix
		rts
disk_file
		ldx	rwf_remain
		stx	rwf_n_bytes
		bne	write_loop
		jmp	exit
write_loop
		jsr	rwf_calc_vars

		ldaa	rwf_remain
		cmpa	rwf_to_eos
		bne	differ
		ldaa	rwf_remain+1
		cmpa	rwf_to_eos+1
differ		bcc	long_write			;>=

		jsr	allocate
		bcs	write_err
		ldx	rwf_remain
		jsr	move_dta
		bcs	write_err
		bra	exit
long_write
		ldx	rwf_buf_beg
		bne	write_to_eos


		jsr	allocate
		bcs	write_err
		ldx	rwf_addr
		stx	int40table
		ldx	rwf_hndl
		ldaa	x, hndl_drive
		staa	int40table+2
		ldx	x, hndl_sector
		stx	int40table+3
		ldaa	#2
		ldx	#%011100000011		    ;Fail, Retry, Ignore, Data area
		jsr	call_disk_drv
		tsta
		bne	write_err
		ldx	#$200
		jsr	inc_fpos
		bsr	rwf_calc_next
		bcs	write_err
		bra	chk_cond
write_to_eos
		ldx	rwf_to_eos
		jsr	move_dta
		bcs	write_err
		bsr	rwf_calc_next
		bcs	write_err
chk_cond
		ldx	rwf_remain
		beq	exit
		jmp	write_loop
exit		clra
write_err
		staa	swia
		ldaa	rwf_n_bytes+1
		suba	rwf_remain+1
		staa	swix+1
		ldaa	rwf_n_bytes
		sbca	rwf_remain
		staa	swix

		ldx	swix			;bytes written
		beq	return
		ldx	rwf_hndl
		ldaa	#$80			;file modified
		oraa	x, hndl_mode
		staa	x, hndl_mode

		ldaa	x, hndl_file_pos
		cmpa	x, hndl_dir_entry+dir_file_size+3
		bne	not_equ
		ldaa	x, hndl_file_pos+1
		cmpa	x, hndl_dir_entry+dir_file_size+2
		bne	not_equ
		ldaa	x, hndl_file_pos+2
		cmpa	x, hndl_dir_entry+dir_file_size+1
		bne	not_equ
		ldaa	x, hndl_file_pos+3
		cmpa	x, hndl_dir_entry+dir_file_size
not_equ 	bls	return
copy_fpos_fsize 		;!!!!
		ldaa	x, hndl_file_pos
		staa	x, hndl_dir_entry+dir_file_size+3
		ldaa	x, hndl_file_pos+1
		staa	x, hndl_dir_entry+dir_file_size+2
		ldaa	x, hndl_file_pos+2
		staa	x, hndl_dir_entry+dir_file_size+1
		ldaa	x, hndl_file_pos+3
		staa	x, hndl_dir_entry+dir_file_size

return		rts


rwf_calc_next
		ldx	rwf_hndl
		ldaa	x, hndl_drive
		staa	fat_drive
		ldab	x, hndl_cur_sec
		ldx	x, hndl_cur_clust
		jsr	calc_next_sec
		bcc	calc_sec
		cmpa	#200
		bcs	calc_ret
		cmpa	#_EOF
		bne	fat_err
		ldaa	#$FF
		ldx	rwf_hndl
		staa	x, hndl_cur_sec
		clc
		rts
fat_err 	ldaa	#_FAT_ERROR
		sec
		rts

calc_sec	;X- cluster
		;B- sector in cluster

		stx	x1
		ldx	rwf_hndl
		stab	x, hndl_cur_sec
		ldaa	x1
		staa	x, hndl_cur_clust
		ldaa	x1+1
		staa	x, hndl_cur_clust+1
		ldaa	x, hndl_drive
		staa	fat_drive
		ldx	x1
		jsr	clust_to_sec
		bcs	calc_ret
		stx	x1
		ldx	rwf_hndl
		ldaa	x1
		staa	x, hndl_sector
		ldaa	x1+1
		staa	x, hndl_sector+1
		clc
calc_ret	rts


allocate	;allocate next cluster
		ldx	rwf_hndl
		tst	x, hndl_cur_sec
		bpl	alloc_ok
		ldaa	x, hndl_drive
		staa	fat_drive
		jsr	alloc_clust
		bcs	alloc_ret
		stx	alloc_new_clust
		ldx	rwf_hndl
		ldx	x, hndl_cur_clust
		beq	set_first

		ldaa	alloc_new_clust+1
		ldab	alloc_new_clust
		jsr	set_fat_field
		bcs	alloc_ret
		bra	set_cur
set_first
		ldx	rwf_hndl
		ldaa	alloc_new_clust
		staa	x, hndl_dir_entry+dir_start_clust+1
		ldaa	alloc_new_clust+1
		staa	x, hndl_dir_entry+dir_start_clust

set_cur 	ldx	rwf_hndl
		ldaa	alloc_new_clust
		staa	x, hndl_cur_clust
		ldaa	alloc_new_clust+1
		staa	x, hndl_cur_clust+1
		clrb
		stab	x, hndl_cur_sec
		ldx	alloc_new_clust
		bra	calc_sec
alloc_ok
		clc
alloc_ret	rts


move_dta	; X - number of bytes

		bsr	move_dta_read
		bcs	move_ret

		ldx	rwf_hndl
		ldaa	rwf_buf_beg+1
		ldab	rwf_buf_beg
		adda	x, hndl_buff+1
		adcb	x, hndl_buff
		staa	x2+1
		stab	x2
		ldx	rwf_addr
		stx	x1
		ldaa	rwf_lng+1
		ldab	rwf_lng
		jsr	move_mem

		ldx	rwf_hndl
		ldx	x, hndl_buff
		jsr	set_buff_modif

		ldx	rwf_lng
		bsr	inc_fpos
		clc
move_ret	rts

move_dta_read	stx	rwf_lng 		;read sector
		ldx	rwf_hndl
		ldaa	x, hndl_drive
		staa	rw_buff_drive
		ldaa	#3		;Data area
		staa	rw_buff_area
		ldaa	x, hndl_sector+1
		ldab	x, hndl_sector
		ldx	x, hndl_buff
		jsr	read_buff
		rts


inc_fpos
		stx	x1
		ldx	rwf_hndl
		ldaa	x1+1
		adda	x, hndl_file_pos+3
		staa	x, hndl_file_pos+3
		ldaa	x1
		adca	x, hndl_file_pos+2
		staa	x, hndl_file_pos+2
		ldaa	x, hndl_file_pos+1
		adca	#0
		staa	x, hndl_file_pos+1
		ldaa	x, hndl_file_pos
		adca	#0
		staa	x, hndl_file_pos

		ldaa	x1+1
		adda	rwf_addr+1
		staa	rwf_addr+1
		ldaa	x1
		adca	rwf_addr
		staa	rwf_addr

		ldaa	rwf_remain+1
		suba	x1+1
		staa	rwf_remain+1
		ldaa	rwf_remain
		sbca	x1
		staa	rwf_remain
		rts

rwf_calc_vars
		ldx	rwf_hndl
		ldaa	x, hndl_file_pos+3
		staa	rwf_buf_beg+1
		ldaa	x, hndl_file_pos+2
		anda	#1
		staa	rwf_buf_beg

		clra
		suba	rwf_buf_beg+1
		staa	rwf_to_eos+1
		ldaa	#2
		sbca	rwf_buf_beg
		staa	rwf_to_eos
		rts
		endp


;-----------------------------------------
; INT $50 - LSEEK
;ENTER : A - file handle
;	 B - method
;	       0 - from the begining
;	       1 - from current pos
;	       2 - from the end of file
;	 X - buff pointer (4 bytes)
;EXIT : A - error code
;	X - new position
;-----------------------------------------
int_50		proc
		stab	rwf_b
		stx	rwf_addr
		psha
		ldaa	x
		staa	new_pos
		ldaa	x, 1
		staa	new_pos+1
		ldx	x, 2
		stx	new_pos+2
		pula

		jsr	find_f_hndl
		bcs	error1
		stx	rwf_hndl

disk_file
		ldab	rwf_b
		beq	chk_pos
		decb
		beq	current
		decb
		beq	from_eof
		ldaa	#_INV_FUNCTION
		bra	error1
current
		ldaa	x, hndl_file_pos + 3
		adda	new_pos+3
		staa	new_pos+3
		ldaa	x, hndl_file_pos + 2
		adca	new_pos+2
		staa	new_pos+2
		ldaa	x, hndl_file_pos + 1
		adca	new_pos+1
		staa	new_pos+1
		ldaa	x, hndl_file_pos
		adca	new_pos
		staa	new_pos
		bra	chk_pos
from_eof
		ldaa	x, hndl_dir_entry+dir_file_size
		suba	new_pos+3
		staa	new_pos+3
		ldaa	x, hndl_dir_entry+dir_file_size+1
		sbca	new_pos+2
		staa	new_pos+2
		ldaa	x, hndl_dir_entry+dir_file_size+2
		sbca	new_pos+1
		staa	new_pos+1
		ldaa	x, hndl_dir_entry+dir_file_size+3
		sbca	new_pos
		staa	new_pos
chk_pos
		ldaa	new_pos
		cmpa	x, hndl_dir_entry+dir_file_size+3
		bne	differ
		ldaa	new_pos+1
		cmpa	x, hndl_dir_entry+dir_file_size+2
		bne	differ
		ldaa	new_pos+2
		cmpa	x, hndl_dir_entry+dir_file_size+1
		bne	differ
		ldaa	new_pos+3
		cmpa	x, hndl_dir_entry+dir_file_size
differ		bls	pos_ok
		ldaa	#_BAD_POSITION
error1		jmp	error
pos_ok
		ldaa	new_pos
		staa	x, hndl_file_pos
		ldaa	new_pos+1
		staa	x, hndl_file_pos+1
		ldaa	new_pos+2
		staa	x, hndl_file_pos+2
		ldaa	new_pos+3
		staa	x, hndl_file_pos+3



		ldaa	x, hndl_dir_entry+dir_start_clust
		staa	x, hndl_cur_clust + 1
		ldab	x, hndl_dir_entry+dir_start_clust+1
		stab	x, hndl_cur_clust
		tsta
		bne	valid_clust
		tstb
		beq	exit_loop
valid_clust
		clr	x, hndl_cur_sec

		ldx	x, hndl_cur_clust
		clrb
		jsr	calc_sec
		bcs	error

		lsr	new_pos
		ror	new_pos+1
		ror	new_pos+2			;new_pos div $200
loop
		ldaa	new_pos
		oraa	new_pos+1
		oraa	new_pos+2
		beq	exit_loop
calc
		jsr	rwf_calc_next
		bcs	error

		ldaa	new_pos+2
		suba	#1
		staa	new_pos+2
		ldaa	new_pos+1
		sbca	#0
		staa	new_pos+1
		ldaa	new_pos
		sbca	#0
		staa	new_pos
		bra	loop
exit_loop
		ldx	rwf_addr
		stx	x2
		ldaa	#hndl_file_pos
		clrb
		adda	rwf_hndl+1
		adcb	rwf_hndl
		staa	x1+1
		stab	x1
		ldaa	#4
		clrb
		jsr	move_mem
		clra
error		staa	swia
		rts
		endp

;-----------------------------------------
; INT $4E - close file
;ENTER : A - file handle
;EXIT : A - error code
;-----------------------------------------
int_4e		proc
		jsr	calc_hndl_addr
		bcs	ret_inv
		stx	rwf_hndl
		tst	x, hndl_mode
		bne	file_open
		ldaa	#_INV_HANDLE
ret_inv 	staa	swia
		rts
file_open
		ldaa	#4
		bita	x, hndl_mode
		beq	disk_file
		clr	x, hndl_mode
		clr	swia
		rts
disk_file
		tst	x, hndl_mode
		bpl	return			;file is not modified

		jsr	close_read_dir
		bcs	error
		bsr	update_buffs
		bcs	error
return
		clra
error		staa	swia
		ldx	rwf_hndl
		clr	x, hndl_mode
		inc	x, hndl_buff
		inc	x, hndl_buff
		ldx	x, hndl_buff
		dec	x, buff_n_files
		ldx	rwf_hndl
		ldaa	x, hndl_drive
		jsr	get_head_addr
		dec	x, n_open
		rts
		endp

update_buffs	proc
		ldx	rwf_hndl
		inx
		stx	x1
		ldx	rwf_addr
		stx	x2
		ldaa	#$20
		clrb
		jsr	move_mem

		ldx	rwf_hndl
		ldaa	x, hndl_mode
		bita	#%1000
		bne	no_modif
		jsr	pack_sys_time
		ldx	rwf_addr
		staa	x, dir_time
		stab	x, dir_time+1

		jsr	pack_sys_date
		ldx	rwf_addr
		staa	x, dir_date
		stab	x, dir_date+1
no_modif
		ldx	buff1_addr
		jsr	set_buff_modif

		ldaa	#2		;DIR area
		staa	rw_buff_area
		ldx	buff1_addr
		jsr	write_buff
		bcs	error

		ldx	rwf_hndl
		ldaa	x, hndl_drive
		jsr	write_fat_sec
		bcs	error

		ldx	rwf_hndl
		ldx	x, hndl_buff
		stx	x1
		inc	x1
		inc	x1
		ldx	x1
		ldaa	x, buff_drive
		ldx	rwf_hndl
		cmpa	x, hndl_drive
		bne	return
		ldaa	#3		;Data area
		staa	rw_buff_area
		ldx	x, hndl_buff
		jsr	write_buff
error		rts
return		clc
		rts
		endp

close_read_dir	proc
		ldaa	x, hndl_drive
		staa	rw_buff_drive
		ldaa	#2		;DIR area
		staa	rw_buff_area
		ldaa	x, hndl_dir_sec+1
		ldab	x, hndl_dir_sec
		ldx	buff1_addr
		jsr	read_buff
		bcs	error

		ldx	rwf_hndl
		ldaa	x, hndl_dir_pos
		inx				;x:= x+hndl_dir_entry
		stx	x2
		jsr	pos_to_addr		;don't modify X2

		stx	x1
		stx	rwf_addr
		ldaa	#11
		ldab	#1			;no wild
		jsr	compare_str
		bcc	entry_found
		ldaa	#_FILE_LOST
error		sec
		rts
entry_found	clra
		rts
		endp


pack_sys_time	proc
;return: BA - time

		ldaa	seconds
		lsra
		anda	#$1F
		staa	x1+1

		ldaa	minutes
		clrb
		asla
		asla
		asla
		rolb
		asla
		rolb
		asla
		rolb
		oraa	x1+1
		staa	x1+1
		stab	x1

		ldaa	hours
		asla
		asla
		asla
		oraa	x1

		tab
		ldaa	x1+1
		rts
		endp

pack_sys_date	proc
;return: BA - date

		ldaa	day
		anda	#$1F
		staa	x1+1

		ldaa	month
		clrb
		asla
		asla
		asla
		asla
		asla
		rolb
		oraa	x1+1
		staa	x1+1
		stab	x1

		ldaa	year+1
		suba	#1980
		asla
		oraa	x1

		tab
		ldaa	x1+1
		rts
		endp


;-----------------------------------------
; INT $5A - Commit file
;ENTER :
;	 A - file handle
;EXIT:	A - error code
;-----------------------------------------
int_5a		proc
		jsr	find_f_hndl
		bcs	error
		stx	rwf_hndl

		tst	x, hndl_mode
		bpl	return

		jsr	close_read_dir
		bcs	error
		jsr	update_buffs
		bcs	error
return		clra
error		staa	swia
		rts
		endp


;-----------------------------------------
; INT $4F - delete file
;ENTER : X - file name
;EXIT : A - error code
;-----------------------------------------
int_4f		proc
		global	delete_entry, err_del

		jsr	copy_parm
		bcs	err_del
		stx	open_name
		clra
		ldab	#%10011000
		jsr	scan_name
		tsta
		bne	err_del
		jsr	test_reopen
		bcs	err_del

delete_entry
		ldaa	find_buff+find_position
		jsr	pos_to_addr

		ldaa	#3
		bita	x, dir_attribute
		bne	acc_denied
		ldaa	#$E5
		staa	x, dir_name

		ldaa	find_buff+find_drive
		staa	fat_drive
		ldaa	x, dir_start_clust
		ldab	x, dir_start_clust+1
		jsr	free_chain
		bcs	err_del

		ldx	buff1_addr
		jsr	set_buff_modif

		ldaa	#2		;DIR area
		staa	rw_buff_area
		ldx	buff1_addr
		jsr	write_buff
		bcs	err_del

		ldaa	fat_drive
		jsr	write_fat_sec
		bcs	err_del

		clra
err_del 	staa	swia
		rts
acc_denied	ldaa	#_ACC_DENIED
		bra	err_del
		endp


;-----------------------------------------
; INT $49 - remove directory
;ENTER : X - directory name
;EXIT : A - error code
;-----------------------------------------
int_49		proc
		jsr	copy_parm
		bcs	err_del

		stx	open_name
loop		tst	x
		beq	exit_loop
		inx
		bra	loop
exit_loop
		stx	rd_x
		stx	x2
		ldx	#all_files
		stx	x1
		jsr	str_copy

		clra
		clrb
		jsr	scan_name
		tsta
		bne	dir_empty
scan_loop
		ldaa	#'.'
		cmpa	dir_entry_buff+dir_name
		bne	dir_full

		ldx	#int42table
		int	$43
		tsta
		beq	scan_loop
dir_empty
		cmpa	#_INV_PATH
		bne	err_del

		ldx	rd_x
		clr	x
		ldaa	#%00010000
		ldab	#%10001000
		jsr	scan_name
		tsta
		bne	err_del

		ldaa	find_buff+find_drive
		jsr	get_head_addr
		ldx	x, cur_dir_ptr
		ldaa	dir_entry_buff+dir_start_clust
		ldab	dir_entry_buff+dir_start_clust+1
		cmpa	x, cur_dir_start+1
		bne	no_err
		cmpb	x, cur_dir_start
		bne	no_err
		ldaa	#_CUR_DIR
		bra	err_del
no_err
		jmp	delete_entry

dir_full	ldaa	#_DIR_NOT_EMPTY
error		jmp	err_del
		endp

;-----------------------------------------
; A - handle
;ret X - handle addr
;-----------------------------------------
find_f_hndl	proc
		jsr	calc_hndl_addr
		bcc	cont
error		sec
		rts
cont
		ldaa	x, hndl_mode
		beq	inv_hndl
		bita	#4
		beq	disk_file
		ldaa	#_NOT_DISK_FILE
		sec
		rts
inv_hndl	ldaa	#_INV_HANDLE
		sec
		rts
disk_file
		clc
		rts
		endp


;-----------------------------------------
; INT $51 - File size
;ENTER :
;	 A - file handle
;	 X - buff_addr
;-----------------------------------------
int_51		proc
		stx	size_buff

		jsr	find_f_hndl
		bcs	error
		stx	rwf_hndl

		ldaa	x, hndl_dir_entry+dir_file_size+3
		ldx	size_buff
		staa	x
		ldx	rwf_hndl
		ldaa	x, hndl_dir_entry+dir_file_size+2
		ldx	size_buff
		staa	x, 1
		ldx	rwf_hndl
		ldaa	x, hndl_dir_entry+dir_file_size+1
		ldx	size_buff
		staa	x, 2
		ldx	rwf_hndl
		ldaa	x, hndl_dir_entry+dir_file_size
		ldx	size_buff
		staa	x, 3

		clra
error		staa	swia
		rts
		endp

;-----------------------------------------
; INT $53 - File position
;ENTER :
;	 A - file handle
;	 X - buff_addr
;-----------------------------------------
int_53		proc
		stx	size_buff

		jsr	find_f_hndl
		bcs	error
		stx	rwf_hndl

		sei
		sts	tmps
		lds	x, hndl_file_pos
		ldaa	x, hndl_file_pos+3
		ldab	x, hndl_file_pos+2
		ldx	size_buff
		sts	x
		staa	x, 3
		stab	x, 2
		lds	tmps
		cli
		clra
error		staa	swia
		rts
		endp


;-----------------------------------------
; INT $57 - Readln text file
;ENTER :
;	 A - file handle
;	 B - buffer length
;	 X - buff_addr
;EXIT:	A - error code
;-----------------------------------------
int_57		proc
		stx	readln_table
		ldx	#1
		stx	readln_table+2
		staa	readln_hndl
		decb
		stab	readln_cnt

		jsr	calc_hndl_addr
		bcs	error
		stx	readln_x

		ldaa	x, hndl_mode
		bita	#%00010000		;check EOF
		bne	return
loop
		ldx	#readln_table
		ldaa	readln_hndl
		int	$4C			;read file
		tsta
		bne	error
		cpx	#0
		beq	return

		ldx	readln_table
		ldaa	x
		cmpa	#$1A
		beq	eot
		cmpa	#$0D
		beq	cr
put_it
		tst	readln_cnt
		beq	loop
		dec	readln_cnt
		ldx	readln_table
		inx
		stx	readln_table
		bra	loop
cr
		ldx	#readln_table
		ldaa	readln_hndl
		int	$4C			;read file
		bra	return
eot
		ldx	readln_x
		ldaa	#%00010000
		oraa	x, hndl_mode
		staa	x, hndl_mode

return		clra
error		staa	swia
		ldx	readln_table
		clr	x
		rts
		endp


;-----------------------------------------
; INT $58 - Return EOF
;ENTER :
;	 A - file handle
;	 B - mode: B = 0  - binary
;		   B = 1  - text
;EXIT:	A - error code
;	B <> 0	 - EOF
;-----------------------------------------
int_58		proc
		jsr	calc_hndl_addr
		bcs	error
		ldaa	x
		beq	inv_hndl
		bita	#4
		beq	disk_file
		ldab	x, chr_hndl_eof
		bra	ret_b
disk_file	ldaa	x, hndl_file_pos
		cmpa	x, hndl_dir_entry+dir_file_size+3
		bne	differ
		ldaa	x, hndl_file_pos+1
		cmpa	x, hndl_dir_entry+dir_file_size+2
		bne	differ
		ldaa	x, hndl_file_pos+2
		cmpa	x, hndl_dir_entry+dir_file_size+1
		bne	differ
		ldaa	x, hndl_file_pos+3
		cmpa	x, hndl_dir_entry+dir_file_size
		bne	differ
		ldab	#1
		bra	ret_b
differ
		tst	swib
		beq	ret_no_eof
		ldab	x, hndl_mode
		andb	#%00010000
		bra	ret_b
ret_no_eof
		clrb
ret_b		stab	swib
		clr	swia
		rts
inv_hndl	ldaa	#_INV_HANDLE
error		staa	swia
		rts
		endp

;-----------------------------------------
; INT $55 - Get/set file date&time
;ENTER :
;	 B - file handle
;	 X - buff_addr
;	     1w - packed date
;	     1w - packed time
;	 A=0 - get
;	 A=1 - set
;-----------------------------------------
int_55		proc
		stx	size_buff
		cmpa	#1
		bls	cont
		ldaa	#_INV_FUNCTION
		bra	error
cont
		tba
		jsr	find_f_hndl
		bcs	error
		stx	rwf_hndl
		ldaa	#4
		bita	x
		beq	disk_file
		ldaa	#_NOT_DISK_FILE
		bra	error

disk_file	tst	swia
		bne	set_it
		ldaa	x, hndl_dir_entry+dir_date
		ldab	x, hndl_dir_entry+dir_date+1
		ldx	size_buff
		staa	x, 1
		stab	x
		ldx	rwf_hndl
		ldaa	x, hndl_dir_entry+dir_time
		ldab	x, hndl_dir_entry+dir_time+1
		ldx	size_buff
		staa	x, 3
		stab	x, 2
		bra	return
set_it
		ldx	size_buff
		ldaa	x
		ldab	x, 1
		ldx	rwf_hndl
		staa	x, hndl_dir_entry+dir_date+1
		stab	x, hndl_dir_entry+dir_date
		ldx	size_buff
		ldaa	x, 2
		ldab	x, 3
		ldx	rwf_hndl
		staa	x, hndl_dir_entry+dir_time+1
		stab	x, hndl_dir_entry+dir_time
		ldaa	x, hndl_mode
		oraa	#%10001000		    ;date&time modified
		staa	x, hndl_mode

return		clra
error		staa	swia
		rts
		endp


;-----------------------------------------
; INT $54 - Get/set file attributes
;ENTER :
;	 X - file path name
;	 B - file attributes
;	 A=0 - get attributes
;	 A=1 - set attributes
;-----------------------------------------
int_54		proc
		cmpa	#1
		bls	testb
		ldaa	#_INV_FUNCTION
		bra	error
testb		bitb	#%11011000
		beq	cont
		ldaa	#_ACC_DENIED
		bra	error
cont
		jsr	copy_parm
		bcs	error
		stx	open_name
		clra
		ldab	#%10011000
		jsr	scan_name
		tsta
		bne	error
		jsr	test_reopen
		bcs	error

		ldaa	find_buff+find_position
		jsr	pos_to_addr

		tst	swia
		bne	set_attr
		ldaa	x, dir_attribute
		staa	swib
		bra	return
set_attr
		ldaa	swib
		staa	x, dir_attribute
		ldx	buff1_addr
		jsr	set_buff_modif
		ldaa	#2		;DIR area
		staa	rw_buff_area
		ldx	buff1_addr
		jsr	write_buff
		bcs	error
return
		clra
error		staa	swia
		rts
		endp


;-----------------------------------------
; INT $56 - Rename file
;ENTER :
;	 X - table
;	     1w - first name
;	     1w - second name
;-----------------------------------------
int_56		proc
		ldx	x
		jsr	get_drive
		psha
		ldx	swix
		ldx	x, 2
		stx	open_name
		jsr	get_drive
		tab
		pula
		cba
		beq	cont1
		ldaa	#_NOT_SAME_DEV
error1		jmp	error
cont1
		clra
		ldab	#%10011000
		jsr	scan_name
		tsta
		bne	cont2
		ldaa	#_FILE_EXIST
		bra	error1
cont2		cmpa	#_INV_PATH
		bne	error1

		ldx	swix
		ldx	x
		stx	int42table+4			;name
		ldx	#find_buff
		stx	int42table
		ldx	#ren_dir_entry
		stx	int42table+2
		ldx	#int42table
		clra
		ldab	#%10011011
		int	$42				;find first entry
		tsta
		bne	error1

		ldx	buff1_addr
		jsr	skip_buff_dta
		ldaa	x, buff_drive
		ldx	x, buff_sector
		staa	ren_drive
		stx	ren_sector
		ldaa	find_buff+find_position
		staa	ren_position

		ldx	swix
		ldx	x, 2
		stx	open_name
		clra
		ldab	#%10011000
		jsr	alloc_entry
		bcs	error
		stx	ren_entry_ptr

		ldx	#find_buff+find_name
		stx	x1
		ldx	#ren_dir_entry+dir_name
		stx	x2
		ldab	#8
		jsr	copy_name
		ldx	#find_buff+find_ext
		stx	x1
		ldx	#ren_dir_entry+dir_ext
		stx	x2
		ldab	#3
		jsr	copy_name

		ldx	#ren_dir_entry
		stx	x1
		ldx	ren_entry_ptr
		stx	x2
		ldaa	#$20
		clrb
		jsr	move_mem

		ldx	buff1_addr
		jsr	set_buff_modif
		ldaa	#2		;DIR area
		staa	rw_buff_area
		ldx	buff1_addr
		jsr	write_buff
		bcs	error

		ldaa	ren_drive
		staa	rw_buff_drive
		ldaa	#2		;DIR area
		staa	rw_buff_area
		ldx	buff1_addr
		ldaa	ren_sector+1
		ldab	ren_sector
		jsr	read_buff
		bcs	error
		ldaa	ren_position
		jsr	pos_to_addr
		ldaa	#$E5
		staa	x
		ldx	buff1_addr
		jsr	set_buff_modif
		ldaa	#2		;DIR area
		staa	rw_buff_area
		ldx	buff1_addr
		jsr	write_buff
		bcs	error

		clra
error		staa	swia
		rts
		endp


;-----------------------------------------
; INT $52 - Disk free space
;ENTER :
;	 A - drive
;	 X - buff_addr
;-----------------------------------------
int_52		proc
		stx	free_x
		clr	x
		clr	x, 1
		clr	x, 2
		clr	x, 3

		staa	fat_drive

		int	$5c		;Media check
		tsta
		bne	error

;??????????	ldaa	fat_drive		; commented 30.Jun.1990
		ldx	#2
		clrb
		jsr	clust_to_sec
		bcs	error
		stx	free_n_clust

		ldaa	fat_drive
		jsr	get_head_addr
		ldaa	x, tns+1
		suba	free_n_clust+1
		staa	free_n_clust+1
		ldaa	x, tns
		sbca	free_n_clust
		staa	free_n_clust

		ldaa	x, spc
		staa	spc2
		clrb
		ldx	free_n_clust
		int	$29
		inx
		inx
		stx	free_n_clust	;num of clusters

		ldx	#2
		stx	free_clust
		asl	spc2
loop
		cpx	free_n_clust
		beq	exit_loop

		jsr	get_fat_field
		bcs	error
		cpx	#0
		bne	inc_cnt

		ldx	free_x
		ldaa	spc2
		adda	x, 2
		staa	x,2
		ldaa	#0
		adca	x, 1
		staa	x, 1
		ldaa	#0
		adca	x
		staa	x
inc_cnt
		ldx	free_clust
		inx
		stx	free_clust
		bra	loop
exit_loop
		clra
error		staa	swia
		rts
		endp


;-----------------------------------------
; INT $38 - Terminate program
;-----------------------------------------
int_38		proc
loop		int	$30		   ;monitor
		bra	loop
		endp

;-----------------------------------------
; INT $5D - Install block device driver
;ENTER :
;	 B - page
;	 X - header addr
;-----------------------------------------
int_5D		proc
		ldx	#head_table
		stx	x1
loop
		ldx	x1
		ldx	x
		beq	found
		ldx	x1
		inx
		inx
		stx	x1
		cpx	#head_table+16
		bne	loop

		ldaa	#_TOO_MANY_DRVRS
		staa	swia
		rts
found
		sei
		sts	tmps
		ldx	x1
		lds	swix
		sts	x
		lds	tmps
		cli

		ldx	swix
		stab	x, block_page
		clr	x, n_open
		ldaa	#$FF
		staa	x, fat_sec_no
		clr	x, fat_modified
		ldx	x, cur_dir_ptr
		clr	x
		clr	x, cur_dir_start
		clr	x, cur_dir_start+1
		clr	swia
		rts
		endp

;-----------------------------------------
; INT $5E - Install char device driver
;ENTER :
;	 B - page
;	 X - header addr
;RETURN: A - error code
;-----------------------------------------
int_5E		proc
;		global	install_no_err
		sei
		sts	tmps
		lds	first_chr_drv
		sts	x, chr_next
		lds	tmps
		cli

		ldx	swix
		stx	first_chr_drv
		stab	x, chr_page
		ldx	x, chr_init
		beq	no_err
		ldaa	#$5F
		int	$2F
		int	$5F
		bcs	error

no_err		clra
error		staa	swia
		rts
		endp

;-----------------------------------------
; INT $70 - Lock/Unlock file
;ENTER :
;	 A - file handle
;EXIT:	A - error code
;-----------------------------------------
int_70		proc
		jsr	find_f_hndl
		bcs	exit
		clra
exit		staa	swia
		rts
		endp


;-----------------------------------------
; INT $6C - Truncate file
;ENTER :
;	 A - file handle
;EXIT:	A - error code
;-----------------------------------------
int_6C		proc
		jsr	find_f_hndl
		bcs	error
		stx	rwf_hndl
		ldaa	#2
		bita	x, hndl_mode
		bne	acc_ok
		ldaa	#_ACC_DENIED
		bra	error
acc_ok
		ldaa	x, hndl_drive
		staa	fat_drive

		ldaa	x, hndl_file_pos
		oraa	x, hndl_file_pos+1
		oraa	x, hndl_file_pos+2
		oraa	x, hndl_file_pos+3
		beq	start_file

		ldx	x, hndl_cur_clust
		jsr	get_fat_field
		bcs	error
		stx	trunc_x

		ldaa	trunc_x+1
		ldab	trunc_x
		cmpb	#$F
		bne	set_eof
		cmpa	#$F0
		bcc	update_dir	; >=
set_eof
		ldx	rwf_hndl
		ldx	x, hndl_cur_clust
		ldaa	#$FF
		ldab	#$F
		jsr	set_fat_field
		bcs	error

		ldaa	trunc_x+1
		ldab	trunc_x
		bra	erase_chain
start_file
		sei
		sts	tmps
		ldaa	x, hndl_dir_entry+dir_start_clust
		ldab	x, hndl_dir_entry+dir_start_clust+1
		lds	#0
		sts	x, hndl_dir_entry+dir_start_clust
		sts	x, hndl_cur_clust
		clr	x, hndl_cur_sec       ;ldaa	#$FF
		dec	x, hndl_cur_sec       ;staa	x, hndl_cur_sec
		lds	tmps
		cli
		tsta
		bne	erase_chain
		tstb
		beq	update_dir
erase_chain
		jsr	free_chain
		bcs	error
update_dir
		ldx	rwf_hndl
		jsr	copy_fpos_fsize
;		ldaa	x, hndl_file_pos
;		staa	x, hndl_dir_entry+dir_file_size+3
;		ldaa	x, hndl_file_pos+1
;		staa	x, hndl_dir_entry+dir_file_size+2
;		ldaa	x, hndl_file_pos+2
;		staa	x, hndl_dir_entry+dir_file_size+1
;		ldaa	x, hndl_file_pos+3
;		staa	x, hndl_dir_entry+dir_file_size
		ldaa	#$80
		oraa	x, hndl_mode
		staa	x, hndl_mode
		clra
error		staa	swia
		rts
		endp


;-----------------------------------------
; X - string pointer
;ret : CF=1, A=_INV_NAME if str length > $80
;      X - #param_str
;-----------------------------------------
copy_parm	proc
		stx	copy_x
		bsr	str_length
		tstb
		bne	error
		cmpa	#$80
		bcc	error

		ldx	copy_x
		stx	x1
		ldx	#param_str
		stx	x2
		bsr	str_copy

		ldx	#param_str
		bsr	upcase_str
		ldx	#param_str
		clc
		rts
error
		ldaa	#_INV_NAME
		sec
		rts
		endp


;-----------------------------------------
; X - string pointer
;-----------------------------------------
upcase_str	proc
loop		ldaa	x
		bne	upcase
		rts
upcase		bsr	upcase_char
		staa	x
		inx
		bra	loop
		endp


;-----------------------------------------
; A - char
;-----------------------------------------
upcase_char	proc
		cmpa	#'a'
		bcs	return
		cmpa	#'z'
		bhi	return
		suba	#$20
return		rts
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
;str_copy	 proc
;		 sei
;		 sts	 tmps
;		 ldx	 x1
;		 txs
;		 ldx	 x2
;loop
;		 pula
;		 staa	 x
;		 inx
;		 tsta
;		 bne	 loop
;		 lds	 tmps
;		 cli
;		 rts
;		 endp

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
		int	$2D
		rts
		endp


;-----------------------------------------
; X1 - src
; X2 - dest
; BA - length
;-----------------------------------------
;move_mem	 proc
;		 sei
;		 sts	 tmps
;		 ldx	 x1
;		 txs
;		 stab	 x1
;		 staa	 x1+1
;loop
;		 ldx	 x2
;		 pula
;		 staa	 x
;		 inx
;		 stx	 x2
;		 ldx	 x1
;		 dex
;		 stx	 x1
;		 bne	 loop
;
;		 lds	 tmps
;		 cli
;		 rts
;		 endp


		list	on
		checksum
		ds	code + $2000 - *, $FF

;---------------------------------------------
		end
