.globl _tag_ref
	.data
	.align 2
_tag_ref:
	.long	1
.lcomm _fromspace,4,2
.lcomm _tospace,4,2
.lcomm _scan,4,2
.lcomm _free_mem,4,2
.lcomm _gcstack,4,2
.lcomm _pro_cell,4,2
	.text
.globl _add_root
_add_root:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$36, %esp
	call	L5
"L00000000001$pb":
L5:
	popl	%ebx
	movl	$8, (%esp)
	call	L_malloc$stub
	movl	%eax, -12(%ebp)
	cmpl	$0, -12(%ebp)
	je	L4
	movl	8(%ebp), %edx
	movl	-12(%ebp), %eax
	movl	%edx, 4(%eax)
	leal	_pro_cell-"L00000000001$pb"(%ebx), %eax
	movl	(%eax), %edx
	movl	-12(%ebp), %eax
	movl	%edx, (%eax)
	leal	_pro_cell-"L00000000001$pb"(%ebx), %edx
	movl	-12(%ebp), %eax
	movl	%eax, (%edx)
L4:
	addl	$36, %esp
	popl	%ebx
	leave
	ret
.globl _remove_root
_remove_root:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	call	L10
"L00000000002$pb":
L10:
	popl	%ecx
	leal	_pro_cell-"L00000000002$pb"(%ecx), %eax
	movl	(%eax), %eax
	testl	%eax, %eax
	je	L9
	leal	_pro_cell-"L00000000002$pb"(%ecx), %eax
	movl	(%eax), %eax
	movl	(%eax), %eax
	movl	%eax, -12(%ebp)
	leal	_pro_cell-"L00000000002$pb"(%ecx), %edx
	movl	-12(%ebp), %eax
	movl	%eax, (%edx)
L9:
	leave
	ret
.globl _move
_move:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	8(%ebp), %eax
	movl	16(%eax), %eax
	testl	%eax, %eax
	je	L12
	movl	8(%ebp), %eax
	movl	16(%eax), %edx
	movl	8(%ebp), %eax
	movl	20(%eax), %eax
	movl	%eax, 20(%edx)
	movl	8(%ebp), %eax
	movl	20(%eax), %edx
	movl	8(%ebp), %eax
	movl	16(%eax), %eax
	movl	%eax, 16(%edx)
L12:
	movl	8(%ebp), %edx
	movl	12(%ebp), %eax
	movl	%eax, 20(%edx)
	movl	12(%ebp), %eax
	movl	16(%eax), %edx
	movl	8(%ebp), %eax
	movl	%edx, 16(%eax)
	movl	8(%ebp), %eax
	movl	16(%eax), %edx
	movl	8(%ebp), %eax
	movl	%eax, 20(%edx)
	movl	12(%ebp), %edx
	movl	8(%ebp), %eax
	movl	%eax, 16(%edx)
	leave
	ret
.globl _inner_copy
_inner_copy:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$36, %esp
	call	L25
"L00000000003$pb":
L25:
	popl	%ebx
	cmpl	$0, 8(%ebp)
	je	L24
	movl	8(%ebp), %eax
	movl	%eax, -12(%ebp)
	movl	-12(%ebp), %eax
	movl	12(%eax), %edx
	leal	_tag_ref-"L00000000003$pb"(%ebx), %eax
	movl	(%eax), %eax
	andl	%edx, %eax
	testl	%eax, %eax
	jne	L24
	leal	_tospace-"L00000000003$pb"(%ebx), %eax
	movl	(%eax), %eax
	cmpl	%eax, -12(%ebp)
	jne	L19
	leal	_tospace-"L00000000003$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	20(%eax), %edx
	leal	_tospace-"L00000000003$pb"(%ebx), %eax
	movl	%edx, (%eax)
	jmp	L21
L19:
	leal	_fromspace-"L00000000003$pb"(%ebx), %eax
	movl	(%eax), %eax
	cmpl	%eax, -12(%ebp)
	jne	L22
	leal	_fromspace-"L00000000003$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	16(%eax), %edx
	leal	_fromspace-"L00000000003$pb"(%ebx), %eax
	movl	%edx, (%eax)
L22:
	leal	_tospace-"L00000000003$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	%eax, 4(%esp)
	movl	-12(%ebp), %eax
	movl	%eax, (%esp)
	call	_move
L21:
	movl	-12(%ebp), %eax
	movl	12(%eax), %edx
	leal	_tag_ref-"L00000000003$pb"(%ebx), %eax
	movl	(%eax), %eax
	orl	%eax, %edx
	movl	-12(%ebp), %eax
	movl	%edx, 12(%eax)
L24:
	addl	$36, %esp
	popl	%ebx
	leave
	ret
.globl _forward
_forward:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	8(%ebp), %eax
	movl	(%eax), %eax
	xorl	$1, %eax
	andl	$1, %eax
	testb	%al, %al
	je	L27
	movl	8(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	_inner_copy
	jmp	L31
L27:
	movl	8(%ebp), %eax
	movl	(%eax), %eax
	andl	$3, %eax
	cmpl	$3, %eax
	jne	L31
	movl	8(%ebp), %eax
	addl	$4, %eax
	movl	%eax, (%esp)
	call	_forward
	movl	8(%ebp), %eax
	addl	$8, %eax
	movl	%eax, (%esp)
	call	_forward
L31:
	leave
	ret
.globl _flip
_flip:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$36, %esp
	call	L44
"L00000000004$pb":
L44:
	popl	%ebx
	leal	_tospace-"L00000000004$pb"(%ebx), %eax
	movl	(%eax), %edx
	leal	_fromspace-"L00000000004$pb"(%ebx), %eax
	movl	%edx, (%eax)
	leal	_free_mem-"L00000000004$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	20(%eax), %edx
	leal	_tospace-"L00000000004$pb"(%ebx), %eax
	movl	%edx, (%eax)
	leal	_free_mem-"L00000000004$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	20(%eax), %edx
	leal	_scan-"L00000000004$pb"(%ebx), %eax
	movl	%edx, (%eax)
	leal	_tag_ref-"L00000000004$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	%eax, %edx
	xorl	$3, %edx
	leal	_tag_ref-"L00000000004$pb"(%ebx), %eax
	movl	%edx, (%eax)
	leal	_gcstack-"L00000000004$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	%eax, -16(%ebp)
	jmp	L33
L34:
	movl	-16(%ebp), %eax
	movl	4(%eax), %eax
	movl	(%eax), %eax
	xorl	$1, %eax
	andl	$1, %eax
	testb	%al, %al
	je	L35
	movl	-16(%ebp), %eax
	movl	4(%eax), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	_inner_copy
L35:
	movl	-16(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, -16(%ebp)
L33:
	cmpl	$0, -16(%ebp)
	jne	L34
	leal	_pro_cell-"L00000000004$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	%eax, -12(%ebp)
	jmp	L38
L39:
	movl	-12(%ebp), %eax
	movl	4(%eax), %eax
	xorl	$1, %eax
	andl	$1, %eax
	testb	%al, %al
	je	L40
	movl	-12(%ebp), %eax
	movl	4(%eax), %eax
	movl	%eax, (%esp)
	call	_inner_copy
L40:
	movl	-12(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, -12(%ebp)
L38:
	cmpl	$0, -12(%ebp)
	jne	L39
	addl	$36, %esp
	popl	%ebx
	leave
	ret
.globl _scanner
_scanner:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$20, %esp
	call	L50
"L00000000005$pb":
L50:
	popl	%ebx
	leal	_scan-"L00000000005$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	20(%eax), %edx
	leal	_tospace-"L00000000005$pb"(%ebx), %eax
	movl	(%eax), %eax
	cmpl	%eax, %edx
	je	L46
	leal	_scan-"L00000000005$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	20(%eax), %edx
	leal	_scan-"L00000000005$pb"(%ebx), %eax
	movl	%edx, (%eax)
	leal	_scan-"L00000000005$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	_forward
	jmp	L49
L46:
	call	_flip
L49:
	addl	$20, %esp
	popl	%ebx
	leave
	ret
.globl _mem_alloc
_mem_alloc:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%esi
	pushl	%ebx
	subl	$32, %esp
	call	L55
"L00000000006$pb":
L55:
	popl	%ebx
	call	_scanner
	leal	_free_mem-"L00000000006$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	16(%eax), %edx
	leal	_fromspace-"L00000000006$pb"(%ebx), %eax
	movl	(%eax), %eax
	cmpl	%eax, %edx
	jne	L52
	leal	_free_mem-"L00000000006$pb"(%ebx), %eax
	movl	(%eax), %esi
	movl	$24, (%esp)
	call	L_malloc$stub
	movl	%esi, 4(%esp)
	movl	%eax, (%esp)
	call	_move
L52:
	leal	_free_mem-"L00000000006$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	%eax, -12(%ebp)
	leal	_free_mem-"L00000000006$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	16(%eax), %edx
	leal	_free_mem-"L00000000006$pb"(%ebx), %eax
	movl	%edx, (%eax)
	movl	-12(%ebp), %eax
	addl	$32, %esp
	popl	%ebx
	popl	%esi
	leave
	ret
	.cstring
LC0:
	.ascii "Begin mem_inti\0"
LC1:
	.ascii "after alloc\0"
LC2:
	.ascii "Pointer init\0"
LC3:
	.ascii "temp2 init\0"
LC4:
	.ascii "mem_init done\0"
	.text
.globl _mem_init
_mem_init:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$36, %esp
	call	L61
"L00000000007$pb":
L61:
	popl	%ebx
	leal	LC0-"L00000000007$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_puts$stub
	movl	$24, (%esp)
	call	L_malloc$stub
	movl	%eax, -16(%ebp)
	movl	$24, (%esp)
	call	L_malloc$stub
	movl	%eax, -12(%ebp)
	cmpl	$0, -16(%ebp)
	je	L57
	cmpl	$0, -12(%ebp)
	jne	L59
L57:
	movl	$0, (%esp)
	call	L_exit$stub
L59:
	leal	LC1-"L00000000007$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_puts$stub
	leal	_free_mem-"L00000000007$pb"(%ebx), %edx
	movl	-16(%ebp), %eax
	movl	%eax, (%edx)
	leal	_fromspace-"L00000000007$pb"(%ebx), %edx
	movl	-16(%ebp), %eax
	movl	%eax, (%edx)
	leal	_tospace-"L00000000007$pb"(%ebx), %edx
	movl	-16(%ebp), %eax
	movl	%eax, (%edx)
	leal	_scan-"L00000000007$pb"(%ebx), %edx
	movl	-16(%ebp), %eax
	movl	%eax, (%edx)
	leal	LC2-"L00000000007$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_puts$stub
	leal	_free_mem-"L00000000007$pb"(%ebx), %eax
	movl	(%eax), %edx
	movl	-12(%ebp), %eax
	movl	%edx, 16(%eax)
	leal	_free_mem-"L00000000007$pb"(%ebx), %eax
	movl	(%eax), %edx
	movl	-12(%ebp), %eax
	movl	%edx, 20(%eax)
	leal	LC3-"L00000000007$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_puts$stub
	leal	_free_mem-"L00000000007$pb"(%ebx), %eax
	movl	(%eax), %edx
	movl	-12(%ebp), %eax
	movl	%eax, 16(%edx)
	leal	_free_mem-"L00000000007$pb"(%ebx), %eax
	movl	(%eax), %edx
	movl	-12(%ebp), %eax
	movl	%eax, 20(%edx)
	leal	LC4-"L00000000007$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_puts$stub
	addl	$36, %esp
	popl	%ebx
	leave
	ret
.globl _object_allocate
_object_allocate:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$36, %esp
	call	L68
"L00000000008$pb":
L68:
	popl	%ebx
	call	_mem_alloc
	movl	%eax, -12(%ebp)
	leal	-12(%ebp), %eax
	movl	%eax, -16(%ebp)
	leal	_gcstack-"L00000000008$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	%eax, -20(%ebp)
	leal	_gcstack-"L00000000008$pb"(%ebx), %edx
	leal	-20(%ebp), %eax
	movl	%eax, (%edx)
	movl	8(%ebp), %eax
	movl	%eax, -28(%ebp)
	cmpl	$1, -28(%ebp)
	je	L65
	cmpl	$2, -28(%ebp)
	je	L66
	cmpl	$0, -28(%ebp)
	je	L64
	jmp	L63
L64:
	movl	-12(%ebp), %eax
	movl	$3, (%eax)
	movl	-12(%ebp), %edx
	movl	12(%ebp), %eax
	movl	%eax, 4(%edx)
	movl	-12(%ebp), %edx
	movl	16(%ebp), %eax
	movl	%eax, 8(%edx)
	jmp	L63
L65:
	movl	-12(%ebp), %edx
	movl	12(%ebp), %eax
	movl	%eax, (%edx)
	movl	-12(%ebp), %eax
	movl	$1, 4(%eax)
	movl	-12(%ebp), %eax
	movl	$1, 8(%eax)
	jmp	L63
L66:
	movl	-12(%ebp), %edx
	movl	12(%ebp), %eax
	sall	$2, %eax
	orl	$1, %eax
	movl	%eax, (%edx)
	movl	-12(%ebp), %eax
	movl	$1, 4(%eax)
	movl	-12(%ebp), %eax
	movl	$1, 8(%eax)
L63:
	movl	-20(%ebp), %edx
	leal	_gcstack-"L00000000008$pb"(%ebx), %eax
	movl	%edx, (%eax)
	movl	-12(%ebp), %eax
	addl	$36, %esp
	popl	%ebx
	leave
	ret
.globl _box_fixnum
_box_fixnum:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	8(%ebp), %eax
	sall	$2, %eax
	orl	$1, %eax
	leave
	ret
.globl _unbox_fixnum
_unbox_fixnum:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	8(%ebp), %eax
	sarl	$2, %eax
	leave
	ret
.globl _cons
_cons:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$40, %esp
	movl	12(%ebp), %eax
	movl	%eax, 8(%esp)
	movl	8(%ebp), %eax
	movl	%eax, 4(%esp)
	movl	$0, (%esp)
	call	_object_allocate
	movl	%eax, -12(%ebp)
	movl	-12(%ebp), %eax
	leave
	ret
.globl _cons_null
_cons_null:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	$0, 4(%esp)
	movl	$0, (%esp)
	call	_cons
	leave
	ret
.globl _null
_null:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	$0, %eax
	leave
	ret
.globl _is_null
_is_null:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	cmpl	$0, 8(%ebp)
	sete	%al
	movzbl	%al, %eax
	leave
	ret
.globl _is_pair
_is_pair:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	8(%ebp), %eax
	andl	$3, %eax
	cmpl	$3, %eax
	sete	%al
	movzbl	%al, %eax
	leave
	ret
.globl _is_number
_is_number:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	8(%ebp), %eax
	andl	$3, %eax
	cmpl	$1, %eax
	sete	%al
	movzbl	%al, %eax
	leave
	ret
.globl _is_string
_is_string:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	8(%ebp), %eax
	movl	(%eax), %eax
	shrl	$4, %eax
	andl	$1, %eax
	leave
	ret
.globl _setcar_ptr
_setcar_ptr:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	8(%ebp), %edx
	movl	12(%ebp), %eax
	movl	%eax, 4(%edx)
	leave
	ret
.globl _setcdr_ptr
_setcdr_ptr:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	8(%ebp), %edx
	movl	12(%ebp), %eax
	movl	%eax, 8(%edx)
	leave
	ret
.globl _setcar
_setcar:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	12(%ebp), %eax
	sall	$2, %eax
	movl	%eax, %edx
	orl	$1, %edx
	movl	8(%ebp), %eax
	movl	%edx, 4(%eax)
	leave
	ret
.globl _setcdr
_setcdr:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	12(%ebp), %eax
	sall	$2, %eax
	movl	%eax, %edx
	orl	$1, %edx
	movl	8(%ebp), %eax
	movl	%edx, 8(%eax)
	leave
	ret
.globl _getcar_ptr
_getcar_ptr:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	8(%ebp), %eax
	movl	4(%eax), %eax
	leave
	ret
.globl _getcdr_ptr
_getcdr_ptr:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	8(%ebp), %eax
	movl	8(%eax), %eax
	leave
	ret
.globl _getcar
_getcar:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	8(%ebp), %eax
	movl	4(%eax), %eax
	sarl	$2, %eax
	leave
	ret
.globl _getcdr
_getcdr:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	8(%ebp), %eax
	movl	8(%eax), %eax
	sarl	$2, %eax
	leave
	ret
.globl _string_cons
_string_cons:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$36, %esp
	call	L105
"L00000000009$pb":
L105:
	popl	%ebx
	leal	-12(%ebp), %eax
	movl	%eax, -16(%ebp)
	leal	_gcstack-"L00000000009$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	%eax, -20(%ebp)
	leal	_gcstack-"L00000000009$pb"(%ebx), %edx
	leal	-20(%ebp), %eax
	movl	%eax, (%edx)
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_string_cons
	movl	%eax, %edx
	movl	8(%ebp), %eax
	movzbl	(%eax), %eax
	movsbl	%al,%eax
	sall	$2, %eax
	orl	$1, %eax
	incl	8(%ebp)
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	_cons
	movl	%eax, -12(%ebp)
	movl	-12(%ebp), %edx
	movl	-12(%ebp), %eax
	movl	(%eax), %eax
	orl	$16, %eax
	movl	%eax, (%edx)
	movl	-20(%ebp), %edx
	leal	_gcstack-"L00000000009$pb"(%ebx), %eax
	movl	%edx, (%eax)
	movl	-12(%ebp), %eax
	addl	$36, %esp
	popl	%ebx
	leave
	ret
.globl _is_eq
_is_eq:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	8(%ebp), %eax
	cmpl	12(%ebp), %eax
	sete	%al
	movzbl	%al, %eax
	leave
	ret
.globl _is_int_eq
_is_int_eq:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$40, %esp
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_is_number
	testl	%eax, %eax
	je	L109
	movl	12(%ebp), %eax
	movl	%eax, (%esp)
	call	_is_number
	testl	%eax, %eax
	je	L109
	movl	8(%ebp), %eax
	cmpl	12(%ebp), %eax
	sete	%al
	movzbl	%al, %eax
	movl	%eax, -12(%ebp)
	jmp	L112
L109:
	movl	$0, -12(%ebp)
L112:
	movl	-12(%ebp), %eax
	leave
	ret
.globl _smaller
_smaller:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$40, %esp
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_is_number
	testl	%eax, %eax
	je	L115
	movl	12(%ebp), %eax
	movl	%eax, (%esp)
	call	_is_number
	testl	%eax, %eax
	je	L115
	movl	8(%ebp), %eax
	cmpl	12(%ebp), %eax
	setl	%al
	movzbl	%al, %eax
	movl	%eax, -12(%ebp)
	jmp	L118
L115:
	movl	$0, -12(%ebp)
L118:
	movl	-12(%ebp), %eax
	leave
	ret
	.section __IMPORT,__jump_table,symbol_stubs,self_modifying_code+pure_instructions,5
L_malloc$stub:
	.indirect_symbol _malloc
	hlt ; hlt ; hlt ; hlt ; hlt
L_exit$stub:
	.indirect_symbol _exit
	hlt ; hlt ; hlt ; hlt ; hlt
L_puts$stub:
	.indirect_symbol _puts
	hlt ; hlt ; hlt ; hlt ; hlt
	.subsections_via_symbols
