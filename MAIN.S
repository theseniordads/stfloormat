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

 * As you can guess, the coding style is quite different to 'Air Dirt' and
 * 'Xmas '97', and the like! We'll add in some extra comments. (These are
 * preceded by a '<-'.)

 * ## Assembly information ##
 * Assembly format: Devpac 3 (VASM compatible)
 * Target processor: Motorola 68000
 * Exectuable format: Atari TOS .PRG
 * Minimum hardware: Atari STFM with 512K RAM

FINAL_VERSION							; < Comment for labels and faster assembly

 	IFD	FINAL_VERSION
	opt	d-
	ENDC

	include	includes\genmacro.s			; <- General macros (Most of them are not used!)

start
		clr.l	-(sp)					; <- As we're addressing the hardware, need to go into supervisor mode	
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,oldstack				; <- Save old stack pointer, as we're going to use our own stack.
		lea		mystack,a7
		bsr		check_falcon
		bsr		save_palette			; <- Before we start attacking the hardware, we need to save the current state of the hardware, and that starts here on the next couple of lines.
		bsr		save_mfp
		bsr		save_screen
		bsr		save_vectors	
		bsr		kill_system		
		bsr		senior_intro			; <- This is the retrofitted intro screen.
		bsr		draw_pic
		bsr		set_my_inters			; <- Startup for the main part of the demo, including the main music.

		bsr		Fear_of_the_dark	; Iron Maiden rule!!!!!!!!!! <- This is the main demo loop, which also includes the retrofiiter Senior Dads Crash ending.
end	; <- Yes, this label is used elsewhere!!!
		bsr		restore_palette
		bsr		restore_mfp
		bsr		restore_vectors
		bsr		restore_screen
		bsr		enable_system
		move.b	#2,$ff820a	; <- In the demo, you flip the screen 50/60Hz, so we're resetting the frequency back to the default of 50Hz. This was in the days when nearly all Atari colour displays were PAL with 50Hz as default. it probably will cause a bit of a problem if it's run on a Falcon with a VGA display!
		move.w	#0,$ff8240+6	
		move.w	#$fff,$ff8240		; fix stupid bug! <- Dunno what this is about, but this line and the previous one appear to reset a couple of colour registers back to the system default.
		move.b	#0,$ff820f
quit	; <- Not sure if this label is used anywhere either! Maybe it was in an earlier version of the demo.
 		move.l	oldstack,-(sp)		; <- Restore the old stack pointer, and exit from supervisor mode.
		move	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		clr.l	(sp)				; <- Now we're back in user mode, we can exit the program and return to the desktop. Of course, on occasion, the desktop may look rather wonky!
		trap	#1

		ds.l	200		; <- Space for our nice big juicy stack! (Remember, stacks grow downwards in memory.)
mystack	ds.l	1		; <- Start of the stack.
oldstack
		ds.l	1		; <- This points to the memory location of stack before we started using our own stack.)
		even			; <- Note sure why this is here, as we've not done anything so far that would cause an odd memory address by this point! Still, it's good practice!


; <- In this subroutine, we need to check if we're running on a Falcon, and set a flag that can referenced later.

; <- First a couple of equates:
cookie_jar	equ	$5a0		; <- The "Cookie Jar" is an area of memory, on the STE onwards, that provides information about the machine.

machine_cookie	equ	'_MCH'	; <- This is the cookie that tells us what machine we're running on.
falcon_machine	equ	3		; <- If it's a Falcon, this is the value.

check_falcon
	sf		falcon					; <- Set the flag to false as default.	
	move.l	#machine_cookie,d0		; { <- Do a search for the machine cookie.
	bsr		search_cookie			; { <- (We get the result in d0 as a longword)
	tst.l	d0						; <- Exit if there's no cookie. (falcon=False)
	beq.s	.nope
	cmpi.l	#'NULL',d0				; <- Exit if the cookie value is 'NULL'. (falcon=False) This would happen if you get to end of the cookie jar without finding the machine cookie. (I'm not too why sure this would ever happen!)
	beq.s	.nope
	swap	d0						; <- The actual value is in the top word of the longword. (We needed it this way to do the 'NULL' check.) So we swap the top and bottom words, so we can now do a comparision.
	cmpi.l	#falcon_machine,d0		; <- Exit if the cookie value is *not* 3. (falcon=False)
	bne.s	.nope
	st		falcon					; <- If we get here, then we've found the machine cookie, and it's confirmed we're running on a Falcon. (falcon=True)
.nope
	rts


; <- Fairly generic cookie jar search subroutine, which we've used in a few demos.
; <- This assumes d0 contains the longword value of the 4 character name of the cookie we're looking for.
; <- The result is returned in d0 as a longword, which is the value of the cookie, or zero if it's not found.
; <- Note that the result could be a longword comprising of the 4 character string 'NULL', so that's why we 
; <- return the values as a longword, even though the actual cookie value will be in the top word.
search_cookie
	move.l	cookie_jar.w,d1			; <- Get the address of the cookie jar.
	tst	d1							; <- Exit if there's no cookie jar. (STFM or earlier)
	beq.s	.null
.search
	move.l	d1,a0					; <- Now we have the address of the cookie jar, we can start searching it.
.loop
	move.l	(a0)+,d1
	cmpi.l	#'NULL',d1				; < End of cookie jar <- I just love that they represent a null value as a 4 character string 'NULL'!
	beq.s	.null
	tst.l	d1						; < Unofficial 'end' <- We found there was a lot of blank space between the last actual cookie and the 'NULL' terminator.
	beq.s	.null
	cmp.l	d0,d1					; <- Is this the cookie we're looking for?
	beq.s	.found					; <- Yes! Exit out of the loop.
	addq.l	#4,a0					; <- No, so move on to the next cookie.
	bra.s	.loop
.found
	move.l	(a0)+,d0				; <- Get the value of the cookie.
	bra.s	.exit
.null
	move.l	d1,d0					; <- No cookie found, so return zero. (Remember, d1 will be zero at this point. Dunno why we just didn't explicitly set d0 to zero, it would have been just as fast!)
.exit
	rts

falcon	ds.b	1			; <- This is the flag that we set in the check_falcon subroutine.
	even	; <- Now this 'even' makes more sense, as we're on a odd address at this point!

; <- *** SENIOR DADS INTRO ***
; <-
; <- This puts the screemode to ST Low-res, plays the fanfare, displays the "Presents" screen, and 
; <- displays the intro message.
; <-
; <- You'll notice a couple of lines commented out here. We found that the hardware way of putting the
; <- screen into ST Low-res mode (clr.b	$ffff8260.w) didn't work on the Falcon, so we had to use the
; <- TOS Trap #14 method instead. Then we realised thst it was a bit silly to keep the hardware method
; <- in there just for the ST, and the Trap #14 would work on the ST as well, since it was being run 
; <- from the desktop anyway. So we commented out the hardware method and check, and kept the Trap #14 method.
senior_intro
	jsr		senior_fanfare				; <- Initialise the fanfare music.
;	if_false.s	falcon,.st_modechange
	clr.w	-(sp)						; <- Put the screen into ST Low-res mode. (clr.w = 0)
	pea	-1
	pea	-1
	move.w	#5,-(sp)
	trap	#14
	lea		12(sp),sp
;	bra.s	.ok
;.st_modechange
;	clr.b	$ffff8260.w
.ok	move.l	$70.w,-(sp)					; <- Save the current vertical blank interrupt (vbl). We're doing it this way, so that when the intro is over, we'll pop it back off the stack, and leave it free for the main demo to do what it sees fit with it.
	move.l	#wait_shit,$70.w			; <- Intro music play and timer vbl. Now the music will start playing
	move.w	#4-1,$468.w					; <- $468 is a memory location that hosts a counter used by the system vbl, so we'll use that. The intro vbl will decrement this value every frame.
.wait_adjust
	tst.w	$468.w						; <- Wait 4 frames (For some reason, we found this neccessary on the Falcon.)
	bne.s	.wait_adjust
	move.l	$44e.w,a1					; <- Get the memory address of the current screen being displayed.
	move.l	a1,a2
	lea		senior_presents+2,a0		; <- Now we're pointing a0 at the colour pallette information part of the Degas Elite file for the "Presents..." screen.
	movem.l	(a0)+,d0-d7					; <- Extracting that information into the 8 registers, and moving the a0 pointer past the information
	movem.l	d0-d7,$ffff8240.w			; <- Now putting the colours into the hardware colour registers
	move.w	#(32000/4)-1,d0				; <- Now a0 is pointing at the ~32K worth of picture data from the Degas file. We just need to copy it onto the screen.
.loop	
	move.l	(a0)+,(a1)+
	dbf		d0,.loop	
	move.l	a2,d0						; <- Errr... We appear to be setting the screen memory address here by hardware! Even though we're not really changing it!
	lsr		#8,d0						; <- W're also making sure that address is aligned on a 256 byte boundary. Even though it probably already is!
	move.l	d0,$ffff8200.w				; <- This where we're setting the screen memory address by hardware. Might be a Falcon compatibility thing.
	move.w	#(10*50)-1,$468.w			; <- Now we're setting a wait for 50 frames (10 seconds on an RGB monitor) before displaying the intro message.
.loop1	
    cmp.b	#$39,$fffffc02.w			; <- This also waits for the user to press the space bar ($39), if the user is impatient!
	beq.s	.stloop2
	tst.w	$468.w						; <- If the user's not pressed space, wait till the counter counts down.
	bne.s	.loop1
.stloop2
.fuck
	cmp.b	#$39,$fffffc02.w			; <- Not too sure what this is about! Perhaps we're flushing the keyboard here, because the next part also as a check for the space bar.
	beq.s	.fuck
	move.l	(sp),$70.w					; <- Wait, what? We've already done that!
	move.l	#$7770777,d0				; <- The next bit sets up all the colours to be white
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	move.w	$ffff8240.w,d0				; <- ... except the first two colours
	swap	d0							; <- ... which are then swapped around. (Navy blue becomes the background colour)
	movem.l	d0-d7,$ffff8240.w			; <- Set the hardware colours!
	pea		.important_message			; <- Print the important message
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#(15*50)-1,$468.w			; <- Set the timer
	move.l	#wait_shit,$70.w			; <- Hang on! We already set that!
.loop2									; <- The time and space bar wait, again.
	cmp.b	#$39,$fffffc02.w
	beq.s	.end
	tst.w	$468.w
	bne.s	.loop2
.end
	move.l	(sp)+,$70.w					; <- Restore the old system vbl, but hang on!!! There's another copy of this address next on the stack!
	rts		; <- Which means the 'rts' here will pop what it thinks is the return address to go, and instead go through the system vbl, which will then pop off the *real* address, and return there! It seems to still work, but that was a near thing!

.important_message
;	dc.b	'0123456789012345678901234567890123456789'
	dc.b	27,'E',27,'b1'	; <- Clear screen, and set the text colour to one of the white colours.
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

; <- Music and counter vbl. Called 50 frames a second on RGB monitors.
wait_shit
	movem.l	d0-a6,-(sp)
	jsr		senior_fanfare+8		; <- Play a frame's worth of music.
	movem.l	(sp)+,d0-a6
	subq.w	#1,$468.w				; <- Count down counter.
	rte

* Do bombs. Plots the old system bomb bitmap to the screen. Converted
; from a similar procedure in "Colonic Irrigation". Assumes ST lo-res
; screen. d0 = no of bombs

do_bombs
	move.l	front,a1		; Get to front of screen
	adda.l	#100*160,a1		; Go halfway down it.
	lea		bomb_dat,a0		; Get bomb bitmap ready
.loop						; For d0 bombs do...
bi	set	0
bj	set	0
	REPT	16			 
	move.w	bi(a0),bj(a1)		; {
	move.w	bi(a0),bj+2(a1)		; { --- Copy bomb bitmap to screen
	move.w	bi(a0),bj+4(a1)		; {     (all planes ie colour 15)
	move.w	bi(a0),bj+6(a1)		; {
bi	set	bi+2
bj	set	bj+160
	ENDR
	addq.l	#8,a1			; Go to position of next bomb
	dbf		d0,.loop		; Next bomb.
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


; <- Here are the subroutines that save and restore system hardware variables.

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
	
		lea		$ff8240,a0		; palette base
		lea		old_cols,a1		; save palette buffer
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

; <- The subroutine is a little different in that it also plays the crash music at the end of the demo.
restore_mfp
	jsr		crash_sound				; <- Initialise crash music.
	jsr		crash_sound+8			; <- CRAAAAAASH!!! (We only need to call this once, not every vbl.)
	move	#$2700,sr
	;movem.l	d0-a6,-(sp)
	;jsr	music+12
	;movem.l	(sp)+,d0-a6
	move.b	old_inter1,$fffa07	
	move.b	old_inter2,$fffa09
	bset	#3,$fffa17	; automatic end of interrupt	
	move	#$2300,sr
	rts

; <- You'll notice here that we're using the Falcon checks. This is because the more we have to save more than
; <- the usual ST(E) graphics registers, due to the complexity of the Falcon's VIDEL chip. This is where our
; <- macros in INCLUDES/GENMACRO.S kick in. 
; <-
; <- Macros used here:
; <- 'if_false [byte], [address]' - If a [byte] is zero (ie binary false), then jump to an instruction at [address].
; <- 'getphys [address]' - Get the address of the physical screen.
; <- 'getlog [address]' - Get the address of the logical screen.
; <- 'getrez_falc [address]' - Save the details of the Falcon's screen resolution to [address].
save_screen
		move.b	$ff8201,old_screen+1
		move.b	$ff8203,old_screen+2
		;move.b	$ff820d,old_screen+3	; ste only register	
		;move.b	$ff8265,smooth_scrl	; ste only register
		;move.b	$ff820f,plane_mod	; ste only register
		move.b	$ff8260,old_res	
		if_false.s	falcon,.end				; <- If it's not a Falcon, miss out the Falcon bits, because, well, it's not a Falcon!
		getphys	oldphys
		getlog	oldlog
		getrez_falc	old_falcrez
.end	rts

old_falcrez	ds.w	1
oldphys		ds.l	1
oldlog		ds.l	1

; <- Another macro used in this subroutine:
; <- 'setrez_falc [old_falcrez], [oldphys], [oldlog]' - Set the Falcon's screen resolution to [old_falcrez] with [oldphys] and [oldlog] as the physical and logical screen addresses respectively.
restore_screen
		move.b	old_screen+1,$ff8201
		move.b	old_screen+2,$ff8203
		;move.b	old_screen+3,$ff820d	; ste only register
		;move.b	smooth_scrl,$ff8265	; ste only register
		;move.b	plane_mod,$ff820f	; ste only register
		move.b	old_res,$ff8260	
		jsr		music+4							; <- Silence the "CRAAAAAASH!!!" music.
		if_false.s	falcon,.exit
		setrez_falc	old_falcrez,oldphys,oldlog
.exit
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
		lea		$64,a1			; is that the first vector??
		lea		vec_buffer,a0
		moveq.l	#7,d1
get_em
		move.l	(a1)+,(a0)+
		dbf		d1,get_em	
		move.l	d0,(sp)
		rts

restore_vectors
		move.l	(sp),d0
		lea		$64,a0	
		lea		vec_buffer,a1
		moveq.l	#7,d1
get_em2
		move.l	(a1)+,(a0)+
		dbf		d1,get_em2	
		move.l	d0,(sp)
		bsr		waste_time
		rts

; <- Now we set up the main demo interrupts, which use the vbl interrupt for the main demo loop,
; <- and the timer B for the rasters.
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

; <- This draws the intro picture after the Senior Dads intro and message.
draw_pic
		move.l	(sp),-(sp)					; <- Wait, what??!
		move.l	$70.w,-(sp)					; <- Saving the vbl interrupt. You could have done that anyway, without needing the previous instruction!
		move.l	#wait_shit,$70.w			; <- Don't forget we're still playing the tail end of the Senior Dads fanfare.
;		move.b	$44e+1,$ff8201
;		move.b	$44e+2,$ff8202
		move.l	$44e.w,d0					; <- As before, making sure the screen is aligned on a 256 byte boundry
		lsr		#8,d0
		move.l	d0,$ffff8200.w
		
		lea		sys_pal,a0					; <- screen colours to system default pallette.
		lea		$ff8240,a1
		
		rept	16
		move.w	(a0)+,(a1)+
		endr
		
		move.l	#intro_pic+34,a1			; <- Deliberately rubbish slow draw of picture onto screen!
		move.l	$44e,a0
		
		move.l	#(32000/200)-1,d0
crappy_pic
		rept	200
		move.b	(a1)+,(a0)+
		endr
		moveq	#3-1,d6						; <- Every so often, there a pause of 3 frames.
.loop1
		move	$468.w,d7
.loop
		cmp.w	$468.w,d7
		beq.s	.loop
		dbf		d6,.loop1
		dbf		d0,crappy_pic
		
		move.l	#intro_pic+2,a0				; <- Once the picture has been copied, *then* we set the colour pallete to thatof the picture!
		move.l	#$ff8240,a1
		rept	16
		move.w	(a0)+,(a1)+
		endr	
.fuck
		cmp.b	#$39,$fffffc02.w			; <- Flush keyboard if space has been pressed before.
		beq.s	.fuck
		move.w	#(10*50)-1,$468.w			; <- As before, we're waiting for either the space bar to be pressed, or 10 seconds (on RGB monitors) to pass.
munch
		cmp.b	#$39,$fffffc02.w
		beq.s	.emunch
		tst.w	$468.w
		bne.s	munch
.emunch	move.l	(sp)+,$70.w					; <- Restore the vbl
		jsr		music						; <- Initialise the main screen music.
		bset	#0,$484.w					; <- ?????
		
		move.l	(sp)+,(sp)
		rts
			

; <- This is actually the end crash! The crash music is playing by the his point, so this just draws the bombs and waits a couple of seconds. You can also press the space bar if you're impatient.
waste_time
		move.l	#5-1,d0
		bsr		do_bombs
.fuck
		cmp.b	#$39,$fffffc02.w
		beq.s	.fuck
		move	#(2*50)-1,d7
.loop
		cmp.b	#$39,$fffffc02.w
		beq.s	.exit
		move.w	$468.w,d6
.wait
		cmp.w	$468.w,d6
		beq.s	.wait
		dbf		d7,.loop
.exit
		rts

***************************************************************************
*                    This is my wait vblank routine                       *
***************************************************************************
; <- The vbl interupt does the following things every frame:
; <- 1) Restart the Timer B interrupts (hbl), and the raster colours.
; <- 2) Play the music.
; <- 3) Colour cycling.
; <- 4) VBL counter. (Is it us, or do there appear to be *two* of them?)
			  
my_vbl
		addq.w	#1,vbl_count	
		clr.b	$fffffa1b
		move.b	#8,$fffffa1b		; restart timer B
		move.w	#$fff,$ff8242
		move.w	#0,$ff8240
		move.l	#col_list,col_pointer					; <- Reset pointer to raster colours.
		move.w	col_list,$ff8242
		addq.l	#2,col_pointer
		move.l	#scrolls_cols_point-4,scrolls_cols_point
		movem.l	d0-a6,-(sp)
		jsr		music+8
		bsr		cycle
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
; <- This pops off colours from the lists, and changes the colour pallette registers to match.
; <- There appears to be two raster lists, one for the scroller, and another for other colours affected
; <- the scrollers use of one bitplane of the screen.

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
; <- This takes the colours directly from the picture file, which had been included in memory,
; <- and cycles them *in situ*, before copying them to the colour pallette registers! It also does it
; <- without needing a loop, which is a pretty neat trick!

cycle
	lea	pic2+2,a0
	movem.l	(a0),d0-d7					; <- Get all the colours from the picture file.	
	move.w	d0,(15*2)(a0)				; <- Move colour 1 to the end of the pallette. Notice we're doing a word move even thopugh d0 has a longword value. This works because colour 1 is in the low word of d0. We don't need to worry aboout colour 0 since that's the background colour, and we don't want to cycle that!
	movem.l	d1-d7,2(a0)					; <- Move the rest of the colours down once place. Notice again we're missing out colour 0, as we want to remain the same.
	movem.l	(a0),d0-d7					; <- Now the colours are cycled, we can copy them to the pallette registers.
	movem.l	d0-d7,$ffff8240.w
	rts
	
		
***************************************************************************		
*		      This is the my demo init code                       		  *
***************************************************************************	
; <- This sets up the main demo screen, and does the following:
; <- 1) Sets up the screen memory for two screens (front and back).
; <- 2) Slowly draws the main screen onto the front screen.
; <- 3) Waits for about 10 seconds.
; <- 4) Exits, meaing the scroller is about to start.
set_up_stuff
		move.l	(sp),-(sp)
		move.l	#end_code,d0			; <- Find some memory space at the end of this code, and align it on a 256 byte boundary.
		addi.l	#256,d0
		clr.b	d0
		move.l	d0,a0
		move.l	d0,front
		addi.l	#32000,d0				; <- Then add ~32k to it, to get the start of the second screen.
		move.l	d0,back
		moveq	#0,d0					; <- Clear the screens memory.
		move.l	#((32000*2)/4)-1,d1
.loop
		move.l	d0,(a0)+
		dbf		d1,.loop
		
		bsr		vblank			; to stop the screen going		<- This is proably not needed, since we're already in ST low res at this point.
								; wacky after res change
		clr.b	$ff8260			; low res please

		move.b	front+1,$ff8201			; <- Set the screen to point to the front screen.
		move.b	front+2,$ff8203
		move.b	front+3,$ff820d
	
		;lea	sys_pal,a0
		;lea	$ff8240,a1
		
		;rept	16
		;move.w	(a0)+,(a1)+
		;endr
	
		move.l	#(8000/60)-1,d0			; <- Deliberately slow main screen reveal!
		move.l	#pic2+34,a0
		move.l	front,a1
draw
		rept	60
		move.l	(a0)+,(a1)+
		endr
		movem.l	d6/d7,-(sp)
		moveq	#3-1,d6
.loop1
		move	$468.w,d7
.loop
		cmp.w	$468.w,d7
		beq.s	.loop
		dbf		d6,.loop1
		movem.l	(sp)+,d6/d7
		dbf		d0,draw
		
		bsr		vblank	
		
		rept	500					; <- Wait for about 10 seconds. Well, that's one way to do it!
		bsr		vblank
		endr
		
		lea		pic2+2,a0
		lea		$ff8240,a1
		
		rept	16
		move.w	(a0)+,(a1)+			; <- Copy the colours from the picture file to the pallette registers.
		endr
		
		move.l	(sp)+,(sp)
		
		rts

***************************************************************************
*       This routine checks to see if the space bar has been pressed      *
***************************************************************************

key
		cmp.b	#57,$fffc02	; scan code for space bar	
		beq		end 		; <- See? We told you that label was being used!
		rts

***************************************************************************		
*		      This is the my wait vblank rout                             *
***************************************************************************	
; <- This probably explains why there appear to be two vbl counters in the vbl routine.

vblank
		clr.w	vbl_count
		move.w	vbl_count,d0
		addq.w	#1,d0
wait_for_vbl
		cmp.w	vbl_count,d0
		bne.s	wait_for_vbl
		rts	
		
***************************************************************************		
*		      This is the main loop of my code                            *
***************************************************************************		
; <- This the main part in action. It does the following:
; <- 1) Starts up the timer B interrupt.
; <- 2) Goes into a loop, in wich it displays a scroller.
; <- 3) Checks to see if the space bar has been pressed.
Fear_of_the_dark
		bsr		set_up_stuff
		or.b	#1,$fffffa07	; enable timer B
		or.b	#1,$fffffa13
Somewhere_in_time
		;move.w	#$333,$ff8240		; measure raster time
		;jsr	vblank
		jsr		vert_scrolly		; <- As you can see, this used to be a vertical scroller!
		;move.w	#0,$ff8240		; measure raster time
yet
		jsr		key
		;movem.l	d0-a6,-(sp)
		;jsr	music+8
		;movem.l	(sp)+,d0-a6
		
		jmp		Somewhere_in_time	; a bit faster than jmp 	<- Ummm, it is a jmp?!?!
		
		

		
***************************************************************************
*        This is the code that swaps physical and logical  screeens       *
***************************************************************************	
; <- ... except that as you might have noticed, it doesn't appear to do that!
; <- It just appears to set the display to the front screen, and then return.
; <- Unless the values for 'front' and 'back' are being swapped somewhere else
; <- in the code, it's not screen flipping at all!

swap
		move.b	front+1,$ff8201
		move.b	front+2,$ff8203
		move.b	front+3,$ff820d
		
		rts 
		
***************************************************************************
*                      This is my scrolltext routine                      *
***************************************************************************
; <- This is the scroller. it uses a 32x32 1 plane font, scrolling across 
; <- the first bitplane in 1 pixel movements from right to left.

vert_scrolly
		move.l	(sp),-(sp)
		
		bsr	update_scroll			; <- Scroll the scroller left one pixel.
		cmp.w	#32,vert_counter	; <- Every 32 pixels, we need to get a new character to scroll in from the right.
		beq	get_new_char
mince	
		addq.w	#1,vert_counter		; <- If we've just received a new character, this will have been reset to zero.
		
		move.l	(sp)+,(sp)
		rts
		
; <- Here's the scroller routine. You'll notice it uses the old-school roxl method of scrolling the bitplane data!
update_scroll
		move.l	(sp),-(sp)
		move.l	front,a1
		moveq 	#0,d6				; <- Why are doing this? Wait and see...
		move.l	#31,d7				; <- for 32 scanlines do....
lines
offset	set	152		; maybe 44?	 	; <- Start at the end of the line and work backwards.
		;move.b	#0,ccr				; <- This clears the extension flag, as we don't graphics from the previous scanline to be shifted in!
		roxl.l	d6					; <- Unfortunately the above line doesn't compile on VASM, so this is our workaround.
		
		rept	20					; <- Working backwards for the 20 words in the line...
		roxl.w	offset(a1)			; <- roxl shifts the bitplane word left, adding any bit shifted out in the previous roxl statement, thus shifting the whole bitplane line 1 pixel to the left as we work backwards.
offset	set	offset-8				; <- Move to the previous word of the bitplane.
		endr	
		
		add.l	#160,a1				; <- Move to the next line of the bitplane.
		
		dbf		d7,lines
		
		move.l	(sp)+,(sp)
		rts
		
get_new_char
		clr.w	vert_counter			; <- Reset the scroll character counter.
		bsr		vblank					; <- Wait for a couple of frames. Makes it look clunky!
		bsr		vblank
find_char
		move.l	char_pointer,a0			; <- Retreive the position where were are in the scrolltext.
		moveq.l	#0,d0
		move.b	(a0)+,d0				; <- Now d0 contains the character we want to search for.
		
		cmp.b	#' ',d0
		beq		load_spaces
		
		cmp.b	#0,d0					; <- Check for end of scrolltext.
		bne.s	calm
		
		move.l	#text,char_pointer		; <- If we've reached the end of the scrolltext, go back to the start.
		bra.s	find_char		
calm
		move.l	a0,char_pointer			; <- Store the new position in the scrolltext.
		move.l	#space,d1				; <- the first character in the font is a space, so we'll need to start from that address.
		sub.b	#$60,d0			; is that right? <- Yes! The font is only capital letters, so we need to subtract $60 from the ascii value to get the correct position in the font. eg 'a' is $61, so take away $60, and we have $01, which is the first letter in the font data.
		lsl		#2,d0					; <- Multiply by 4 to get the correct position in the font pointer table, as each pointer is a longword. (ie 4 bytes long.)
		add.l	d0,d1					; <- Add that to the address of the first character in the font, and now d1 contains the address of the character pointer.
		move.l	d1,a0
		move.l	(a0),bitmap_pointer		; <- Store that pointer. (Not sure if we actually need to, given the next step.)

display_char
		move.l	front,a0
		move.l	bitmap_pointer,a2
		
offset		set	152-8

		rept	32						; <- Yes, you're reading this right! The entire character is compied wholesave directly onto the displayed screen! That's why you see the character just plop onto the screen rather than scrolled in!
		move.w	(a2),offset(a0)
		move.w	2(a2),offset+8(a0)
		add.l	#40,a2
		
offset		set	offset+160
		
		endr
		
		bra	mince						; <- Return to the main scroller routine. 

; <- For the space character, we just set the bitmap pointer, and do nothing else, since the character is blank.
; <- Maybe there was some point where it was planned to have the charaacter scrolled in rather than just plonked 
; <- onto the screen, but it was never implemented. Who knows?!		
load_spaces
		move.l	#space_buffer,bitmap_pointer
		move.l	a0,char_pointer
		bra	mince						; <- Don't you just love those descriptive labels?!
		
		
		rts
		
		
		
				
***************************************************************************
*                This is my variables and my screen data                  *
***************************************************************************

old_cols			ds.l	8
old_screen			dc.l	0
old_inter1			dc.b	0
old_inter2			dc.b	0
smooth_scrl			dc.b	0
plane_mod			dc.b	0
old_res				dc.b	0
		even
bitmap_pointer		dc.l	0
vert_counter		dc.w	32
char_pointer		dc.l	text		; <- The initial value here points to the scrolltext.
old_sr				dc.w	0
vec_buffer			ds.l	8
vbl_count			dc.w	0
horiz_count			dc.w	2
buffer				dc.l	0
front				dc.l	0
back				dc.l	0
col_pointer			dc.l	col_list+2



	even

; <- Here's the raster colour list. As you can see, there was originally 
; <- going to be much more, but we cut down the number of rasters, and increased
; <- spacing, as the original settings combined with the colour cycling made it
; <- almost impossible to read the scrolltext!
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

	even
scrolls_cols_point	dc.l	scrolls_cols_point-4

; <- This the 32x32 font. We're not sure of source, but it looks like a 
; <- one bitplane capture of a font from a Degas PI1 type file, which
; <- will explain what we see immediately below.
	even
scroll_font	incbin	graphics\myfont.dat

; <- Yes, this is a list of pointers to every character in the font!
; <- It looks like this is stored as a single bitplane, characters going 
; <- from left to right, top to bottom. The exception here appears to be 
; <- the space, which appears to the last character on the first line!
; <- This probably explains all these pointers. If the space was the first
; <- character on the first line, and the other letters on that line were
; <- shifed rightwards by one character, then we could just do a simple 
; <- calculation in the 'get_new_char' subroutine to get the address of the 
; <- character we want in the font.
	even
font_pointers
space		dc.l	scroll_font+36		; points to a space
a			dc.l	scroll_font
b			dc.l	scroll_font+4
c			dc.l	scroll_font+8
d			dc.l	scroll_font+12
e			dc.l	scroll_font+16
f			dc.l	scroll_font+20
g			dc.l	scroll_font+24
h			dc.l	scroll_font+28
i			dc.l	scroll_font+32
j			dc.l	scroll_font+(40*32)
k			dc.l	scroll_font+(40*32)+4
l			dc.l	scroll_font+(40*32)+8
m			dc.l	scroll_font+(40*32)+12
n			dc.l	scroll_font+(40*32)+16
o			dc.l	scroll_font+(40*32)+20
p			dc.l	scroll_font+(40*32)+24
q			dc.l	scroll_font+(40*32)+28
r			dc.l	scroll_font+(40*32)+32
s			dc.l	scroll_font+(80*32)
t			dc.l	scroll_font+(80*32)+4
u			dc.l	scroll_font+(80*32)+8
v			dc.l	scroll_font+(80*32)+12
w			dc.l	scroll_font+(80*32)+16
x			dc.l	scroll_font+(80*32)+20
y			dc.l	scroll_font+(80*32)+24
z			dc.l	scroll_font+(80*32)+28
			dc.l	0							; <- Errr, I don't think we really need this!

		dc.b	$61+30			; <- ?????????????

; <- This is the scrolltext. As you can see, it's all lowercase with no punctuation, and terminates witha zero byte.
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
		dc.b	0				; <- End of the scroller.
		even
		
space_buffer
		dcb.l	40*32,0								; <- Again, not sure we need this. We're just not drawing anything when we're doing a space!
		
sys_pal			incbin	graphics\syspal.dat			; <- Colour values for the default ST Lo res palette

	even
senior_presents	incbin	graphics\senior.pi1			; <- GRAPHICS: Senior Dads Presents
intro_pic		incbin	graphics\wnkpss1.pi1		; <- GRAPHICS: Intro Pic
pic2			incbin	graphics\wnkpss2.pi1		; <- GRAPHICS: Main demo graphics

	even
senior_fanfare	incbin	sound\senior.thk			; <- MUSIC : Senior Fanfare
	even
music			incbin	sound\popcorn.thk			; <- MUSIC : Popcorn
	even
crash_sound		incbin	sound\crash.thk				; <- MUSIC : Crash

end_code
