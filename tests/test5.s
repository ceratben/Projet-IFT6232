    .text
.globl _main
_main:
    movl    $5, %eax
    addl $0, %esp
    ret

_f:
    call g5
    pushl    %eax
    call    _null
    pushl    %eax
    call _cons
    ret

g5:
    movl    -8(%esp), %eax
    pushl   %eax
    movl    -8(%esp), %eax
    addl    (%esp), %eax
    addl    $4, %esp
    ret

_closure_ref:
    call g4
    ret

g4:
    movl    -8(%esp), %eax
    pushl    %eax
    movl    $0, %eax
    pushl    %eax
    call _is_int_eq
    jz else
    movl    -4(%esp), %eax
    pushl    %eax
    call _getcar_ptr
    jmp end_if
else:
    movl    4(%esp), %eax
    pushl    %eax
    call _getcdr_ptr
    pushl   %eax
    movl    $1, %eax
    pushl   %eax
    movl    4(%esp), %eax
    subl    (%esp), %eax
    addl    $4, %esp
    pushl   %eax
    call    _closure_ref
    addl $8, %esp
end_if:
    ret

_closure_code:
    call g3
    ret

g3:
    movl    -4(%esp), %eax
    pushl    %eax
    call _getcar_ptr
    ret
