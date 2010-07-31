/*
 Package: dyncall
 File: dyncall/dyncall_call_x86_8a.s
 Description: All x86 abi call kernel implementations in Plan9's assembler
 License:

 Copyright (c) 2007-2010 Daniel Adler <dadler@uni-goettingen.de>,
                         Tassilo Philipp <tphilipp@potion-studios.com>

 Permission to use, copy, modify, and distribute this software for any
 purpose with or without fee is hereby granted, provided that the above
 copyright notice and this permission notice appear in all copies.

 THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

*/

TEXT dcCall_x86_cdecl(SB), $0

	PUSHL BP           /* PROLOG */
 	MOVL  SP, BP

	/* ARGUMENTS:
	   FUNPTR   8(BP)
	   ARGS    12(BP)
	   SIZE    16(BP)
	   RESULT  20(BP)
	 */

	MOVL  12(BP), SI  /* SI = POINTER ON ARGS */
	MOVL  16(BP), CX  /* CX = SIZE */

	SUBL  CX, SP      /* CDECL CALL: ALLOCATE 'SIZE' BYTES ON STACK */
	MOVL  SP, DI      /* DI = STACK ARGS */

	SHRL  $2, CX       /* CX = NUMBER OF DWORDs to copy */
	REP; MOVL SI, DI    /* COPY DWORDs */

	CALL  8(BP)        /* CALL FUNCTION */

	ADDL  16(BP), SP  /* CDECL CALL: CLEANUP STACK */

	MOVL  BP, SP      /* EPILOG */
	POPL  BP

	RET

