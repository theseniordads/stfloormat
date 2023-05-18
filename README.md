# St Floormat

Full assembler source for the "ST Floormat" demo by The Senior Dads, which was released on the Atari 16 bit platform on the 24th February 1997.

## Specifications

* An Atari Falcon 030 with 4 megabytes of memory, TOS 4.04, and an internal hard drive.
* ... Alternatively, a decent emulator like Hatari, configured as above.
* Devpac 3 to assemble the code.
* Atomix packer or better to pack the executable.

## How to assemble

* Load "MAIN.S" into Devpac 3.
* Make sure settings are set to assemble to Motorola 68000.
* Assemble to executable file "MAIN.PRG".
* Rename exectuable to "STFLRMAT.PRG".
* Pack "STFLRMAT.PRG" with packer.
* Run "STFLRMAT.PRG".

## Folders

* `COMPILED` - Original compiled demo and accompanying [README](https://github.com/theseniordads/xmascard97/blob/main/COMPILED/FLOORMAT/STFLRMAT.TXT).
* `GRAPHICS` -
  * Graphics, in Degas Elite `.PI1` files.
  * `MYFONT.DAT`, a plane graphics font, used by the scroller.
  * `SYSPAL.DAT`, a binary which contains the system default colour pallette.
    for ST Lo-res.
* `INCLUDES` - Various macro and helpers code.
* `SOUND` - `.THK` files are chip tune music.
  * `SENIOR.THK` - introductory fanfare.
  * `POPCORN.THK` - main music: a "version" of "Popcorn".
  * `CRASH.THK` - exit crash usic.
* `SRC_DATA` - Original versions of sound and graphics.
  * `GFX` - Source graphics. Formats used are:
    * `.PC1` - Low res Degas Elite images. Can be edited in [Degas Elite](https://dhs.nu/files.php?t=single&ID=16).
  * `SOUND` - Source sounds. Formats used are:
    * `.MUS` Chip-tunes. Can be edited using [Megatizer v2.4](https://dhs.nu/files.php?t=single&ID=50).
