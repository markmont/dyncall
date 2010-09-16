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


TEXT dcCall_x86_plan9(SB), $0

    /* Since all registers except SP are scratch, and we have a variable
       argument size depending on the function to call, we have to find
       a way to store and restore SP.
       The idea is to replace the return address with a custom one on the
       stack, and to put some logic there, jumping back to the real
       return address. This allows us, to put the SP somewhere next to
       the fake return address on the stack, so that we can get it back
       with a fixed offset (relative to the program counter, in our case).

       The only real issue with this approach would be a non-executable
       stack. However, Plan9 doesn't support w^x at the time of writing.
    */

    /* On the stack at this point:
       RETADDR  0(SP)
       FUNPTR   4(SP)
       ARGS     8(SP)
       SIZE    12(SP)
    */

    MOVL  SP, BP      /* base pointer for convenience */
    PUSHL SP          /* save stack pointer */

    MOVL   8(BP), SI  /* SI = pointer on args */
    MOVL  12(BP), CX  /* CX = size of args */

	SUBL  $16, SP     /* Make some room for our SP-refetch logic */
	MOVL   SP, BX     /* Copy address to new, executable stack space to BX */

    /* This part fills our executable stack space with instructions. We
       need to get the program counter, first, with a little hack. */
    MOVL  $0x000003e8, 0(SP) /* Copy 'call (cur ip+8)' */
    MOVL  $0x00000000, 4(SP) /* '00' for call address, rest is garbage */
    MOVL  $0x5a909090, 8(SP) /* 'nop, nop, nop, pop edx' to get eip+5 in edx */
    MOVL  $0xc30b628b,12(SP) /* Restore stack ptr and return: 'mov [edx+11] to esp, ret' */

    SUBL  CX, SP      /* allocate 'size' bytes on stack for args */
    MOVL  SP, DI      /* DI = stack args */

    SHRL $2, SP       /* Align stack. */
    SHLL $2, SP       /*   "     "    */

    JMP  copy_loop_cmp
copy_loop:
    MOVL 0(SI), AX     /* Copy args. */
    MOVL AX, 0(DI)
    SUBL $4, CX
copy_loop_cmp:
    CMPL CX, $0
    JGT  copy_loop

    /* Now we try to fake a call, meaning setting up our fake return address,
       and then jumping to the FFI call. This should call the function, but
       the return will jump into our stack space we reserved above. */
    PUSHL BX
    MOVL  4(BP), BX
    JMP   BX

    /* Note that there is no return here, b/c the return is in the asm code
       above, that has been generated on the fly. */
