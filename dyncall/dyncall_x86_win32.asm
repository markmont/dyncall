;///////////////////////////////////////////////////////////////////////
;
;	dyncall_x86_win32.asm
;	Copyright 2007 Daniel Adler.
;
;	MS Windows x86 calls (for MASM)
;	November 28, 2007
;
;///////////////////////////////////////////////////////////////////////


.386
.MODEL FLAT
.CODE


; Main dyncall call.
_dcCall_x86_cdecl PROC EXPORT

    OPTION PROLOGUE:NONE, EPILOGUE:NONE

    push ebp                       ; prolog 
    mov  ebp, esp         

    ; arguments:
    ; funptr  ebp+8
    ; args    ebp+12
    ; size    ebp+16
  
    push esi                       ; save esi, edi
    push edi

    mov  esi, dword ptr[ebp+12]    ; esi = pointer on args
    mov  ecx, dword ptr[ebp+16]    ; ecx = size

    sub  esp, ecx                  ; cdecl call: allocate 'size' bytes on stack
    mov  edi, esp                  ; edi = stack args
    
    rep movsb                      ; copy arguments

    call dword ptr[ebp+8]          ; call function

    add  esp, dword ptr[ebp+16]    ; cdecl call: cleanup stack

    pop  edi                       ; restore edi, esi
    pop  esi

    mov  esp, ebp                  ; epilog
    pop  ebp

    ret

_dcCall_x86_cdecl ENDP


_dcCall_x86_win32_msthis PROC EXPORT

    OPTION PROLOGUE:NONE, EPILOGUE:NONE

    push ebp                       ; prolog 
    mov  ebp, esp         

    ; arguments:
    ;
    ; funptr  ebp+8
    ; args    ebp+12
    ; size    ebp+16
  
    push esi                       ; save esi, edi
    push edi

    mov  esi, dword ptr[ebp+12]    ; esi = pointer on args
    mov  ecx, dword ptr[ebp+16]    ; ecx = size

    mov  eax, dword ptr[esi]       ; eax = this pointer
    add  esi, 4                    ; increment args pointer by thisptr
    sub  ecx, 4                    ; decrement size by sizeof(thisptr)

    sub  esp, ecx                  ; allocate argument-block on stack
    mov  edi, esp                  ; edi = stack args
    
    rep movsb                      ; copy arguments

    mov  ecx, eax                  ; ecx = this pointer

    call dword ptr[ebp+8]          ; call function (thiscall: cleanup by callee)

    pop  edi                       ; restore edi, esi
    pop  esi

    mov  esp, ebp                  ; epilog
    pop  ebp

    ret

_dcCall_x86_win32_msthis ENDP


_dcCall_x86_win32_std PROC EXPORT

    OPTION PROLOGUE:NONE, EPILOGUE:NONE

    push ebp                       ; prolog 
    mov  ebp, esp         

    ; arguments:
    ;
    ; funptr  ebp+8
    ; args    ebp+12
    ; size    ebp+16
  
    push esi                       ; save esi, edi
    push edi

    mov  esi, dword ptr[ebp+12]    ; esi = pointer on args
    mov  ecx, dword ptr[ebp+16]    ; ecx = size

    sub  esp, ecx                  ; stdcall: allocate 'size'-8 bytes on stack
    mov  edi, esp                  ; edi = stack args
    
    rep movsb                      ; copy arguments

    call dword ptr[ebp+8]          ; call function (stdcall: cleanup by callee)

    pop  edi                       ; restore edi, esi
    pop  esi

    mov  esp, ebp                  ; epilog
    pop  ebp

    ret

_dcCall_x86_win32_std ENDP


_dcCall_x86_win32_fast PROC EXPORT

    OPTION PROLOGUE:NONE, EPILOGUE:NONE

    push ebp                       ; prolog 
    mov  ebp, esp

    ; arguments:
    ;
    ; funptr  ebp+8
    ; args    ebp+12
    ; size    ebp+16
  
    push esi                       ; save esi, edi
    push edi

    mov  esi, dword ptr[ebp+12]    ; esi = pointer on args
    mov  ecx, dword ptr[ebp+16]    ; ecx = size
    mov  eax, dword ptr[esi]       ; eax = first argument
    mov  edx, dword ptr[esi+4]     ; edx = second argument
    add  esi, 8                    ; increment source pointer
    sub  ecx, 8                    ; decrement size by 8

    sub  esp, ecx                  ; fastcall: allocate 'size'-8 bytes on stack
    mov  edi, esp                  ; edi = stack args
    
    rep movsb                      ; copy arguments

    mov  ecx, eax                  ; ecx = first argument

    call dword ptr[ebp+8]          ; call function (fastcall: cleanup by callee)

    pop  edi                       ; restore edi, esi
    pop  esi

    mov  esp, ebp                  ; epilog
    pop  ebp

    ret

_dcCall_x86_win32_fast ENDP

END
