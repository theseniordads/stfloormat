***************************************************************************
* This is the 'take the piss out of ST Formats "assembly experts" demo'   *
***************************************************************************

start
		clr.l	-(sp)
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,oldstack
		lea	mystack,a7
		bsr	save_palette
		bsr	save_mfp
		bsr	save_screen
		bsr	draw_pic
		bsr	save_vectors	
		bsr	kill_system		
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
		rts

restore_screen
		move.b	old_screen+1,$ff8201
		move.b	old_screen+2,$ff8203
		;move.b	old_screen+3,$ff820d	; ste only register
		;move.b	smooth_scrl,$ff8265	; ste only register
		;move.b	plane_mod,$ff820f	; ste only register
		move.b	old_res,$ff8260	
		jsr	music+4
		rts
	
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
		move.l	#4000-1,d7
.loopy		bsr	waste_time
		dbf	d7,.loopy
		move.l	d0,(sp)
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
		clr.b	$ff8260
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
		
		move.l	#31999/20,d0
crappy_pic
		rept	20
		move.b	(a1)+,(a0)+
		endr
		rept	10
		bsr	waste_time
		endr
		dbf	d0,crappy_pic
		
		move.l	#intro_pic+2,a0
		move.l	#$ff8240,a1
		rept	16
		move.w	(a0)+,(a1)+
		endr	
munch
		cmp.b	#57,$fffc02
		bne.s	munch
		jsr	music
		bset	#0,$484.w
		
		move.l	(sp)+,(sp)
		rts
			
waste_time
		rept	100
		mulu	#41000,d1
		endr
		rts

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
	
		move.l	#7999/10,d0
		move.l	#pic2+34,a0
		move.l	front,a1
draw
		rept	10
		move.l	(a0)+,(a1)+
		endr
		rept	20
		bsr	waste_time
		endr
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



scroll_font	incbin	myfont.dat

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
		dc.b	'this is wank and piss who proudly present their new screen called            the wank and piss demo screen           coded in less than twelve days by tony wagstaff and roger peason              '
		dc.b	'and now a few words about this cool screen              '
		dc.b	'coding this demo was a bit of an adventure for us becuase this is the first time we have ever entered into the scary world of hardware registers        '
		dc.b	'we usually use the operating system for everything but as us demo coder knows you can write faster code if you write directly to the hardware             '
		dc.b	'getting this screen to run as fast as we could was very difficult so we hope you enjoy it as it was very hard to code          ' 
		dc.b	'we are easily the best coders on the scene         '
		dc.b	'we are the best sixty eight thousand coders in the world           '
		dc.b	'and now the credits for this wonderful masterpiece of coding      '
		dc.b	'all code by roger peason and tony wagstaff    music by the midi expert from st format    and last but not least this demo was designed by andy hutchison who used his vast coding experience of writing on the spectrum to '
		dc.b	'create cool speccy like rasters           '
		dc.b	'our next production will be falcon only and will feature forty two one plane sprites on screen  a blitter processed soundtracker tune wich will be a techno remix of this cool tune          '
		dc.b	'we will endevour to produce more speccy like rasters using the forty six bit pallete of the falcon      '
		dc.b	'we think we are the firstr demo coders on the scene that are not sad anorak wearers who have no social life and this is a message to powerman            '
		dc.b	'give up becuase we rule the st scene now                '
		dc.b	'look out for an unbiased review of our cool demo in a later issue of st format                  '
		dc.b	'when we showed this screen to billy allen he cracked up laughing and then said that he could write a faster version of this screen in gw basic running on pc ditto                 '
		dc.b	'we didn t get the reason as why he pissed himself laughing when we showed him this screen but we assumed he was laughing at this extremely weel wrotten and witty scrolly       '
		dc.b	'we are the best becuase we dont resort to wibbly grafics and manic bleep chip music           '
		dc.b	'we are looking for new coders to augment our impressive plethora of coding talent so we were a bit annoyed when billy allen called us fucking useless lamers with no redeeming features whatsoever      '
		dc.b	'he is just jealous becuase he knows we are better than him            '
		dc.b	'we dont code in stos we code in pure eight oh eight six assembly language so there          '
		dc.b	'a message to all coders on the scene          '
		dc.b	'give up cause you know it makes sense         '
		dc.b	' we are the mega mighty bloody super hell raising best in the whole universe         '
		dc.b	'we know this because it says so in the pages of st format        '
		dc.b	'sorry for swearing back there but we felt strong language is flaming good             '
		dc.b	'mega greets go to     dominik diamond     bob hay   dont give up cause you havn t caught anybody yet         '
		dc.b	'kelly sumner for leading atari through a particularly tough time          '
		dc.b	'greets also go to james boulton who was in our opinion the greatest coder on the scene before we took that title       '
		dc.b	'all at fast        keep up the good work raiding legitimate pd libraries            '
		dc.b	'all at ocean      for the cool games you release on the st                '
		dc.b	'our mothers for puting up with all of us for so many years         '
		dc.b	'we will move out soon    we promise                  '
		dc.b	'the silents   kefrens  red sector international  bamiga sector one    quartex  and all the other coders who make cool demos on the st       '
		dc.b	'and last but not least     mega greetings go to jay miner for designing the st          '
		dc.b	'by the way we heard that atari are going to go into business making aftsershave         '
		dc.b	'we know this becuase they are said to be making lynx                       '
		dc.b	'remember you saw it here first                     '
		dc.b	'now to deal with some rumours             '
		dc.b	'people we have spoken to claim that st format is a crap magazine that is totally in the pocket of atari        '
		dc.b	'well frankly that is not the case             '
		dc.b	'we say what we want   when we want and how we want             '
		dc.b	'however  we never feel the need to critisise atari        '
		dc.b	'atari are the best company in the whole wide world and have never done anything that warrants our critisism       '
		dc.b	'another rumour that is flying around is that none of us with the exception of billy allen have a clue about anything on the st scene and that we know bugger all about the st in general          '
		dc.b	'well let me tell you that that is simply not the case            '
		dc.b	'we have all got at least twenty years experience using the st and we are all qualified to answer any question anybody might put to us regarding the st                  '
		dc.b	'for instance me and tony wagstaff are simply the best coders on the st at the moment as you must be forced to agree after seing this cool intro and we know the st inside and out             '
		dc.b	'some nasty person is also claiming that the article on the falcon was made up                     '
		dc.b	'now that really agravates me in the extreme                '
		dc.b	'we don t like people to find out things like this as it damages our reputation        '
		dc.b	'anyway the last thing that needs to be said is we are not the sad degenerate plonkers that the scene thinks we are and we can really code better than anybody else    so there             '
		dc.b	'well bye bye now as we must reactivate this super scroller now so          cheerio               '                 
		dc.b	0	
		
		
		even
		
		
		
		
space_buffer
		dcb.l	40*32,0
		
intro_pic	incbin	wnkpss1.pi1
pic2		incbin	wnkpss2.pi1
music		incbin	wankstaf.thk
sys_pal		incbin	syspal.dat
		
end_code
