***************************************************************************
* This is the 'take the piss out of ST Formats "assembly experts" demo'   *
***************************************************************************

***************************************************************************
* Otherwise known as................                                      *
*                                                                         *
*               THE ST FLOORMAT demo by THE SENIOR DADS!                  *
*                                                                         *
*                  (Atari STFM/STE/Falcon 030, 512K+)                     *
*                                                                         *
***************************************************************************

 * This demo actually pre-dates the Senior Dads "Air Dirt", and was written 
 * for another demo completely, by another coder who subsequently joined the
 * Senior Dads as Colostomy Bag. So this demo was re-purposed for the Senior
 * Dads, adding a "Presents..." title, an intro text, and a crash screen at
 * the end. We also added Falcon compatibility measures, as nearly all our
 * previous demos were Falcon-only. If you want see the original version of
 * this demo before we re-purposed it, look in the folder 'OLD/'.

	opt	d-

	include	includes\genmacro.s

start
		clr.l	-(sp)
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,oldstack
		lea	mystack,a7
		bsr	check_falcon
		bsr	save_palette
		bsr	save_mfp
		bsr	save_screen
		bsr	save_vectors	
		bsr	kill_system		
		bsr	senior_intro
		bsr	draw_pic
		bsr	set_my_inters

		bsr	Fear_of_the_dark	; Iron Maiden rule!!!!!!!!!!
end
		bsr	restore_palette
		bsr	restore_mfp
		bsr	restore_vectors
		bsr	restore_screen
		bsr	enable_system
		move.b	#2,$ff820a
		move.w	#0,$ff8240+6	
		move.w	#$fff,$ff8240		; fix stupid bug!	
		move.b	#0,$ff820f
quit
 		move.l	oldstack,-(sp)
		move	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		clr.l	(sp)
		trap	#1

	ds.l	200
mystack	ds.l	1
oldstack
	ds.l	1

cookie_jar	equ	$5a0

machine_cookie	equ	'_MCH'
falcon_machine	equ	3

check_falcon
	sf	falcon
	move.l	#machine_cookie,d0
	bsr	search_cookie
	tst.l	d0
	beq.s	.nope
	cmpi.l	#'NULL',d0
	beq.s	.nope
	swap	d0
	cmpi.l	#falcon_machine,d0
	bne.s	.nope
	st	falcon
.nope	rts

search_cookie
	move.l	cookie_jar.w,d1
	tst	d1
	beq.s	.null
.search	move.l	d1,a0
.loop	move.l	(a0)+,d1
	cmpi.l	#'NULL',d1		< End of cookie jar
	beq.s	.null
	tst.l	d1			< Unofficial 'end'
	beq.s	.null
	cmp.l	d0,d1
	beq.s	.found
	addq.l	#4,a0
	bra.s	.loop
.found	move.l	(a0)+,d0
	bra.s	.exit
.null	move.l	d1,d0
.exit	rts

falcon	ds.b	1
	even

senior_intro
	jsr	senior_fanfare
;	if_false.s	falcon,.st_modechange
	clr.w	-(sp)
	pea	-1
	pea	-1
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
;	bra.s	.ok
;.st_modechange
;	clr.b	$ffff8260.w
.ok	move.l	$70.w,-(sp)
	move.l	#wait_shit,$70.w
	move.w	#4-1,$468.w
.wait_adjust
	tst.w	$468.w
	bne.s	.wait_adjust
	move.l	$44e.w,a1
	move.l	a1,a2
	lea	senior_presents+2,a0
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.w	#(32000/4)-1,d0
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop	
	move.l	a2,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w
	move.w	#(10*50)-1,$468.w
.loop1	cmp.b	#$39,$fffffc02.w
	beq.s	.stloop2
	tst.w	$468.w
	bne.s	.loop1
.stloop2
.fuck		cmp.b	#$39,$fffffc02.w
		beq.s	.fuck
	move.l	(sp),$70.w
	move.l	#$7770777,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	move.w	$ffff8240.w,d0
	swap	d0
	movem.l	d0-d7,$ffff8240.w
	pea	.important_message
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#(15*50)-1,$468.w
	move.l	#wait_shit,$70.w
.loop2	cmp.b	#$39,$fffffc02.w
	beq.s	.end
	tst.w	$468.w
	bne.s	.loop2
.end	move.l	(sp)+,$70.w
	rts

.important_message
;	dc.b	'0123456789012345678901234567890123456789'
	dc.b	27,'E',27,'b1'
	dc.b	'   YES!!!! THE TRUTH CAN BE TOLD!!!',13,10,10
	dc.b	'The SENIOR DADS did a demo especially',13,10
	dc.b	'for ST FLOORMAT when they did their',13,10
	dc.b	'Oxember 1884 feature: "Demos- are they',13,10
	dc.b	'a load of crap or what?" and asked for',13,10
	dc.b	'contribution from REAL demo coders! So',13,10
	dc.b	'how could we refuse? Unfortunately not',13,10
	dc.b	'only did they fabricate a quote from',13,10
	dc.b	'ace demo coder Bungle Tiny from the',13,10
	dc.b	'Cathode Triplets, but they fiddled about',13,10
	dc.b	'with our demo!! Unfortunately what with',13,10
	dc.b	'the contract we signed for them, it''s',13,10
	dc.b	'only now that they''ve folded that the',13,10
	dc.b	'TRUTH can be told... The following demo',13,10
	dc.b	'is by US! (Old Fart & Doddering Git!)',13,10,10
	dc.b	'Press SPACE or wait a little bit!',0

	even

wait_shit
	movem.l	d0-a6,-(sp)
	jsr	senior_fanfare+8
	movem.l	(sp)+,d0-a6
	subq.w	#1,$468.w
	rte

* Do bombs. Plots the old system bomb bitmap to the screen. Converted
; from a similar procedure in "Colonic Irrigation". Assumes ST lo-res
; screen. d0= no of bombs

do_bombs
	move.l	front,a1		; Get to front of screen
	adda.l	#100*160,a1		; Go halfway down it.
	lea	bomb_dat,a0		; Get bomb bitmap ready
.loop					; For d0 bombs do...
bi	set	0
bj	set	0
	REPT	16			 
	move.w	bi(a0),bj(a1)		{
	move.w	bi(a0),bj+2(a1)		{ --- Copy bomb bitmap to screen
	move.w	bi(a0),bj+4(a1)		{     (all planes ie colour 15)
	move.w	bi(a0),bj+6(a1)		{
bi	set	bi+2
bj	set	bj+160
	ENDR
	addq.l	#8,a1			;   Go to position of next bomb
	dbf	d0,.loop		; Next bomb.
	rts

* Bitmap pattern for "bomb". Copied out of ST Internals BIOS listing.

bomb_dat
	dc.w	%0000011000000000
	dc.w	%0010100100000000
	dc.w	%0000000010000000
	dc.w	%0100100001000000
	dc.w	%0001000111110000
	dc.w	%0000000111110000
	dc.w	%0000011111111100
	dc.w	%0000111111111110
	dc.w	%0000111111111110
	dc.w	%0001111111111111
	dc.w	%0001111111101111
	dc.w	%0000111111101110
	dc.w	%0000111111011110
	dc.w	%0000011111111100
	dc.w	%0000001111111000
	dc.w	%0000000011100000

save_palette
		movem.l	d0-a7,-(sp)
	
		lea	$ff8240,a1		; palette base
		lea	old_cols,a0		; save palette buffer
		moveq.l	#7,d0
save_em
		move.l	(a1)+,(a0)+
		dbf	d0,save_em
	
		movem.l	(sp)+,d0-a7
		rts
	
restore_palette
		movem.l	d0-a7,-(sp)
	
		lea	$ff8240,a0		; palette base
		lea	old_cols,a1		; save palette buffer
		moveq.l	#7,d0
restore_em
		move.l	(a1)+,(a0)+
		dbf	d0,restore_em

		movem.l	(sp)+,d0-a7
		rts

save_mfp
		move.b	$fffa07,old_inter1	
		move.b	$fffa09,old_inter2
		rts
restore_mfp
	jsr	crash_sound
	jsr	crash_sound+8
	move	#$2700,sr
	;movem.l	d0-a6,-(sp)
	;jsr	music+12
	;movem.l	(sp)+,d0-a6
		move.b	old_inter1,$fffa07	
		move.b	old_inter2,$fffa09
		bset	#3,$fffa17	; automatic end of interrupt	
	move	#$2300,sr
		rts
save_screen
		move.b	$ff8201,old_screen+1
		move.b	$ff8203,old_screen+2
		;move.b	$ff820d,old_screen+3	; ste only register
		;move.b	$ff8265,smooth_scrl	; ste only register
		;move.b	$ff820f,plane_mod	; ste only register
		move.b	$ff8260,old_res	
		if_false.s	falcon,.end
		getphys	oldphys
		getlog	oldlog
		getrez_falc	old_falcrez
.end		rts

old_falcrez	ds.w	1
oldphys		ds.l	1
oldlog		ds.l	1

restore_screen
		move.b	old_screen+1,$ff8201
		move.b	old_screen+2,$ff8203
		;move.b	old_screen+3,$ff820d	; ste only register
		;move.b	smooth_scrl,$ff8265	; ste only register
		;move.b	plane_mod,$ff820f	; ste only register
		move.b	old_res,$ff8260	
		jsr	music+4
		if_false.s	falcon,.exit
		setrez_falc	old_falcrez,oldphys,oldlog
.exit		rts
	
kill_system
		move.b	#0,$fffa07		; die nasty timers
		move.b	#0,$fffa09
		move.w	sr,old_sr		; save the status register
		;move.w	#$2000,sr
		rts
enable_system
		move.w	old_sr,sr		 
		rts				
	
save_vectors
		move.l	(sp),d0
		lea	$64,a1			; is that the first vector??
		lea	vec_buffer,a0
		moveq.l	#7,d1
get_em
		move.l	(a1)+,(a0)+
		dbf	d1,get_em	
		move.l	d0,(sp)
		rts

restore_vectors
		move.l	(sp),d0
		lea	$64,a0	
		lea	vec_buffer,a1
		moveq.l	#7,d1
get_em2
		move.l	(a1)+,(a0)+
		dbf	d1,get_em2	
		move.l	d0,(sp)
		bsr	waste_time
		rts
set_my_inters
	move	#$2700,sr
	;movem.l	d0-a6,-(sp)
	;moveq	#1,d0
	;jsr	music
	;jsr	music+4
	;movem.l	(sp)+,d0-a6
		move.l	#my_vbl,$70		
		
		move.l	#timer_b,$120
		bclr	#3,$fffa17	; automatic end of interrupt	
		move.b	#4,$fffa21		
	move	#$2300,sr
		rts			

draw_pic
		move.l	(sp),-(sp)	
	move.l	$70.w,-(sp)
	move.l	#wait_shit,$70.w
;		move.b	$44e+1,$ff8201
;		move.b	$44e+2,$ff8202
		move.l	$44e.w,d0
		lsr	#8,d0
		move.l	d0,$ffff8200.w
		
		lea	sys_pal,a0
		lea	$ff8240,a1
		
		rept	16
		move.w	(a0)+,(a1)+
		endr
		
		move.l	#intro_pic+34,a1
		move.l	$44e,a0
		
		move.l	#(32000/200)-1,d0
crappy_pic
		rept	200
		move.b	(a1)+,(a0)+
		endr
		move.	#3-1,d6
.loop1		move	$468.w,d7
.loop		cmp.w	$468.w,d7
		beq.s	.loop
		dbf	d6,.loop1
		dbf	d0,crappy_pic
		
		move.l	#intro_pic+2,a0
		move.l	#$ff8240,a1
		rept	16
		move.w	(a0)+,(a1)+
		endr	
		
.fuck		cmp.b	#$39,$fffffc02.w
		beq.s	.fuck
		move.w	#(10*50)-1,$468.w
munch
		cmp.b	#$39,$fffffc02.w
		beq.s	.emunch
	tst.w	$468.w
	bne.s	munch
.emunch	move.l	(sp)+,$70.w
		jsr	music
		bset	#0,$484.w
		
		move.l	(sp)+,(sp)
		rts
			
waste_time
		move.l	#5-1,d0
		bsr	do_bombs
.fuck		cmp.b	#$39,$fffffc02.w
		beq.s	.fuck
		move	#(2*50)-1,d7
.loop		cmp.b	#$39,$fffffc02.w
		beq.s	.exit
		move.w	$468.w,d6
.wait		cmp.w	$468.w,d6
		beq.s	.wait
		dbf	d7,.loop
.exit		rts

***************************************************************************
*                    This is my wait vblank routine                       *
***************************************************************************
			  
my_vbl
		addq.w	#1,vbl_count	
		clr.b	$fffffa1b
		move.b	#8,$fffffa1b		; restart timer B
		move.w	#$fff,$ff8242
		move.w	#0,$ff8240
		move.l	#col_list,col_pointer
		move.w	col_list,$ff8242
		addq.l	#2,col_pointer
		move.l	#scrolls_cols_point-4,scrolls_cols_point
		movem.l	d0-a6,-(sp)
		jsr	music+8
		bsr	cycle
		cmp.b	#16,$fffc02
		bne.s	not_overscan
		eor.b	#2,$ff820a
not_overscan
		movem.l	(sp)+,d0-a6
		subq.w	#1,$468.w
		rte
		
***************************************************************************
*                   This is my timer b routine                            * 
***************************************************************************

timer_b
		move.l	a5,-(sp)
		move.l	col_pointer,a5
		move.w	(a5)+,$ff8242
		
		move.l	a5,col_pointer
		move.l	scrolls_cols_point,a5
		move.w	(a5),$ff8244
		move.w	(a5),$ff8246
		subq.l	#2,scrolls_cols_point
		move.l	(sp)+,a5
		rte
		
* colour cycling

cycle	lea	pic2+2,a0
	movem.l	(a0),d0-d7
	move	d0,(15*2)(a0)
	movem.l	d1-d7,2(a0)
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts
	
		
***************************************************************************		
*		      This is the my demo init code                       *
***************************************************************************	

set_up_stuff
		move.l	(sp),-(sp)
		move.l	#end_code,d0
		addi.l	#256,d0
		clr.b	d0
		move.l	d0,a0
		move.l	d0,front
		addi.l	#32000,d0
		move.l	d0,back
		moveq	#0,d0
		move.l	#((32000*2)/4)-1,d1
.loop		move.l	d0,(a0)+
		dbf	d1,.loop
		
		bsr	vblank			; to stop the screen going	
						; wacky after res change
		clr.b	$ff8260			; low res please
		move.b	front+1,$ff8201
		move.b	front+2,$ff8203
		move.b	front+3,$ff820d
	
		;lea	sys_pal,a0
		;lea	$ff8240,a1
		
		;rept	16
		;move.w	(a0)+,(a1)+
		;endr
	
		move.l	#(8000/60)-1,d0
		move.l	#pic2+34,a0
		move.l	front,a1
draw
		rept	60
		move.l	(a0)+,(a1)+
		endr
		movem.l	d6/d7,-(sp)
		move.	#3-1,d6
.loop1		move	$468.w,d7
.loop		cmp.w	$468.w,d7
		beq.s	.loop
		dbf	d6,.loop1
		movem.l	(sp)+,d6/d7
		dbf	d0,draw
		
		bsr	vblank	
		
		rept	500
		bsr	vblank
		endr
		
		lea	pic2+2,a0
		lea	$ff8240,a1
		
		rept	16
		move.w	(a0)+,(a1)+
		endr
		
		move.l	(sp)+,(sp)
		
		rts

***************************************************************************
*       This routine checks to see if the space bar has been pressed      *
***************************************************************************

key
		cmp.b	#57,$fffc02	; scan code for space bar	
		beq	end
		rts

***************************************************************************		
*		      This is the my wait vblank rout                     *
***************************************************************************	

vblank
		clr.w	vbl_count
		move.w	vbl_count,d0
		addq.w	#1,d0
wait_for_vbl
		cmp.w	vbl_count,d0
		bne.s	wait_for_vbl
		rts	
		
***************************************************************************		
*		      This is the main loop of my code                    *
***************************************************************************		
		
Fear_of_the_dark
		bsr	set_up_stuff
		or.b	#1,$fffffa07	; enable timer B
		or.b	#1,$fffffa13
Somewhere_in_time
		;move.w	#$333,$ff8240		; measure raster time
		;jsr	vblank
		jsr	vert_scrolly
		;move.w	#0,$ff8240		; measure raster time
yet
		jsr	key
		;movem.l	d0-a6,-(sp)
		;jsr	music+8
		;movem.l	(sp)+,d0-a6
		
		jmp	Somewhere_in_time	; a bit faster than jmp 	
		
		

		
***************************************************************************
*        This is the code that swaps physical and logical  screeens       *
***************************************************************************			

swap
		move.b	front+1,$ff8201
		move.b	front+2,$ff8203
		move.b	front+3,$ff820d
		
		rts 
		
***************************************************************************
*                      This is my scrolltext routine                      *
***************************************************************************

vert_scrolly
		move.l	(sp),-(sp)
		
		bsr	update_scroll
		cmp.w	#32,vert_counter
		beq	get_new_char
mince	
		addq.w	#1,vert_counter		
		
		move.l	(sp)+,(sp)
		rts
		
update_scroll
		move.l	(sp),-(sp)
		move.l	front,a1
		move.l	#31,d7
lines
offset		set	152		; maybe 44?
		move.b	#0,ccr
		
		rept	20			
		roxl.w	offset(a1)
offset		set	offset-8
		endr	
		
		add.l	#160,a1
		
		dbf	d7,lines
		
		move.l	(sp)+,(sp)
		rts
		
get_new_char
		clr.w	vert_counter
		bsr	vblank
		bsr	vblank
find_char
		move.l	char_pointer,a0
		moveq.l	#0,d0
		move.b	(a0)+,d0
		
		cmp.b	#' ',d0
		beq	load_spaces
		
		cmp.b	#0,d0
		bne.s	calm
		
		move.l	#text,char_pointer
		bra.s	find_char		
calm
		move.l	a0,char_pointer
		move.l	#space,d1
		sub.b	#$60,d0			; is that right?
		lsl	#2,d0
		add.l	d0,d1
		move.l	d1,a0
		move.l	(a0),bitmap_pointer
		
		move.l	front,a0
		move.l	bitmap_pointer,a2
		
offset		set	152-8

		rept	32
		move.w	(a2),offset(a0)
		move.w	2(a2),offset+8(a0)
		add.l	#40,a2
		
offset		set	offset+160
		
		endr
		
		bra	mince		
		
load_spaces
		move.l	#space_buffer,bitmap_pointer
		move.l	a0,char_pointer
		bra	mince
		
		
		rts
		
		
		
				
***************************************************************************
*                This is my variables and my screen data                  *
***************************************************************************

old_cols		ds.l	8
old_screen		dc.l	0
old_inter1		dc.b	0
old_inter2		dc.b	0
smooth_scrl		dc.b	0
plane_mod		dc.b	0
old_res			dc.b	0
		even
bitmap_pointer		dc.l	0
vert_counter		dc.w	32
char_pointer		dc.l	text
old_sr			dc.w	0
vec_buffer		ds.l	8
vbl_count			dc.w	0
horiz_count		dc.w	2
buffer			dc.l	0
front			dc.l	0
back			dc.l	0
col_pointer		dc.l	col_list+2



	even
	
col_list
	REPT	5
	
	dc.w	$770
	dc.w	$777
	dc.w	$700
	dc.w	$007
	
	;dc.w	0,$100,$200,$300,$400,$500,$600,$700
	;dc.w	$710,$720,$730,$740,$750,$760,$770
	;dc.w	$670,$570,$470,$370,$270,$170,$70
	;dc.w	$71,$72,$73,$74,$75,$76,$77
	;dc.w	$177,$277,$377,$477,$577,$677,$777
	;dc.w	$767,$757,$747,$737,$727,$717,$707
	;dc.w	$607,$507,$407,$307,$207,$107,7
	;dc.w	6,5,4,3,2,1,0
	ENDR

scrolls_cols_point	dc.l	scrolls_cols_point-4



scroll_font	incbin	graphics\myfont.dat

font_pointers

space		dc.l	scroll_font+36		; points to a space
a		dc.l	scroll_font
b		dc.l	scroll_font+4
c		dc.l	scroll_font+8
d		dc.l	scroll_font+12
e		dc.l	scroll_font+16
f		dc.l	scroll_font+20
g		dc.l	scroll_font+24
h		dc.l	scroll_font+28
i		dc.l	scroll_font+32
j		dc.l	scroll_font+(40*32)
k		dc.l	scroll_font+(40*32)+4
l		dc.l	scroll_font+(40*32)+8
m		dc.l	scroll_font+(40*32)+12
n		dc.l	scroll_font+(40*32)+16
o		dc.l	scroll_font+(40*32)+20
p		dc.l	scroll_font+(40*32)+24
q		dc.l	scroll_font+(40*32)+28
r		dc.l	scroll_font+(40*32)+32
s		dc.l	scroll_font+(80*32)
t		dc.l	scroll_font+(80*32)+4
u		dc.l	scroll_font+(80*32)+8
v		dc.l	scroll_font+(80*32)+12
w		dc.l	scroll_font+(80*32)+16
x		dc.l	scroll_font+(80*32)+20
y		dc.l	scroll_font+(80*32)+24
z		dc.l	scroll_font+(80*32)+28
		dc.l	0

		dc.b	$61+30
text		
		dc.b	'press q to kill top and bottom borders      '
		dc.b	'      hello to everybody reading this cool demoscreen     anyone who said we were complete lamers are extremely silly sadcases       '
		dc.b	'this is wank and piss who proudly present their new screen called            the wank and piss demo screen           '
		dc.b	'coded in less than twelve days by toby wankstain and ronny pissawful              '
		dc.b	'and now a few words about this cool screen              '
		dc.b	'coding this demo was a bit of an adventure for us because this is the first time we have ever entered into the scary world of hardware registers        '
		dc.b	'we usually use the operating system for everything but as us demo coder knows you can write faster code if you write directly to the hardware             '
		dc.b	'getting this screen to run as fast as we could was very difficult so we hope you enjoy it as it was very hard to code          ' 
		dc.b	'we are easily the best coders on the scene         '
		dc.b	'we are the best sixty eight thousand coders in the world           '
		dc.b	'and now the credits for this wonderful masterpiece of coding      '
		dc.b	'all code by ronny pissawful and toby wankstain    music by the vincent lentil the midi expert from st floormat    '
		dc.b	'and last but not least this demo was designed by adrian catflap who used his vast coding experience of writing on the spectrum to '
		dc.b	'create cool speccy like rasters           '
		dc.b	'our next production will be falcon only and will feature forty two one plane sprites on screen  a blitter processed soundtracker tune wich will be a techno remix of this cool tune          '
		dc.b	'we will endevour to produce more speccy like rasters using the forty six bit pallete of the falcon      '
		dc.b	'we think we are the firstr demo coders on the scene that are not sad anorak wearers who have no social life and this is a message to powerman            '
		dc.b	'give up because we rule the st scene now                '
		dc.b	'look out for an unbiased review of our cool demo in a later issue of st floormat                  '
		dc.b	'when we showed this screen to libby alien he cracked up laughing and then said that he could write a faster version of this screen in gw basic running on pc ditto                 '
		dc.b	'we didn t get the reason as why he pissed himself laughing when we showed him this screen but we assumed he was laughing at this extremely weel wrotten and witty scrolly       '
		dc.b	'we are the best because we dont resort to wibbly grafics and manic bleep chip music           '
		dc.b	'we are looking for new coders to augment our impressive plethora of coding talent so we were a bit annoyed when libby alien called us fucking useless lamers with no redeeming features whatsoever      '
		dc.b	'he is just jealous because he knows we are better than him            '
		dc.b	'we dont code in stos we code in pure eight oh eight six assembly language so there          '
		dc.b	'a message to all coders on the scene          '
		dc.b	'give up cause you know it makes sense         '
		dc.b	' we are the mega mighty bloody super hell raising best in the whole universe         '
		dc.b	'we know this because it says so in the pages of st floormat        '
		dc.b	'sorry for swearing back there but we felt strong language is flaming good             '
		dc.b	'mega greets go to     dominik diamond     bob hay   dont give up cause you havnt caught anybody yet         '
		dc.b	'kelly sumner for leading atari through a particularly tough time          '
		dc.b	'greets also go to james boulton who was in our opinion the greatest coder on the scene before we took that title       '
		dc.b	'all at fast        keep up the good work raiding legitimate pd libraries            '
		dc.b	'all at ocean      for the cool games you release on the st                '
		dc.b	'our mothers for puting up with all of us for so many years         '
		dc.b	'we will move out soon    we promise                  '
		dc.b	'the silents   kefrens  red sector international  bamiga sector one    quartex  and all the other coders who make cool demos on the st       '
		dc.b	'and last but not least     mega greetings go to jay miner for designing the st          '
		dc.b	'by the way we heard that atari are going to go into business making aftsershave         '
		dc.b	'we know this because they are said to be making                lynx                       '
		dc.b	'remember you saw it here first                     '
		dc.b	'now to deal with some rumours             '
		dc.b	'people we have spoken to claim that st floormat is a crap magazine that is totally in the pocket of atari        '
		dc.b	'well frankly that is not the case             '
		dc.b	'we say what we want   when we want and how we want             '
		dc.b	'however  we never feel the need to critisise atari        '
		dc.b	'atari are the best company in the whole wide world and have never done anything that warrants our critisism       '
		dc.b	'another rumour that is flying around is that none of us with the exception of libby alien have a clue about anything on the st scene and that we know bugger all about the st in general          '
		dc.b	'well let me tell you that that is simply not the case            '
		dc.b	'we have all got at least twenty years experience using the st and we are all qualified to answer any question anybody might put to us regarding the st                  '
		dc.b	'for instance me and toby wankstain are simply the best coders on the st at the moment as you must be forced to agree after seing this cool intro and we know the st inside and out             '
		dc.b	'some nasty person is also claiming that the article on the falcon was made up                     '
		dc.b	'now that really agravates me in the extreme                '
		dc.b	'we don t like people to find out things like this as it damages our reputation        '
		dc.b	'anyway the last thing that needs to be said is we are not the sad degenerate plonkers that the scene thinks we are and we can really code better than anybody else    so there             '
		dc.b	'well bye bye now as we must reactivate this super scroller now so          cheerio               '                 
		dc.b	0	
		
		
		even
		
		
		
		
space_buffer
		dcb.l	40*32,0
		
sys_pal		incbin	graphics\syspal.dat
senior_presents	incbin	graphics\senior.pi1
intro_pic	incbin	graphics\wnkpss1.pi1
pic2		incbin	graphics\wnkpss2.pi1
senior_fanfare	incbin	sound\senior.thk
music		incbin	sound\popcorn.thk
crash_sound	incbin	sound\crash.thk

end_code
