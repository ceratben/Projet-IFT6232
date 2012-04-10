    .text
.globl _main
_main:
    call g5
    pushl    %eax
    call    _null
    pushl    %eax
    call _cons
    pushl   %eax
    call g4
    addl $4, %esp
    addl $0, %esp
    ret

g5:
    movl    -8(%esp), %eax
    pushl   %eax
    movl    -4(%esp), %eax
    imull    (%esp), %eax
    addl    $4, %esp
    ret

g4:
    movl    4(%esp), %eax
    pushl   %eax
    movl    $3, %eax
    pushl   %eax
    movl    8(%esp), %eax
    pushl   %eax
    call    _closure_code
    addl $4, %esp
    addl $8, %esp
    ret

_closure_ref:
    call g3
    ret

g3:
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
    call g2
    ret

g2:
    movl    -4(%esp), %eax
    pushl    %eax
    call _getcar_ptr
    ret
