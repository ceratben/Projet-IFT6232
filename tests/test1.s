    .text
.globl _main
_main:
    movl    $123, %eax
    addl $0, %esp
    ret

_closure_ref:
    call g2
    ret

g2:
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
    call g1
    ret

g1:
    movl    -4(%esp), %eax
    pushl    %eax
    call _getcar_ptr
    ret
