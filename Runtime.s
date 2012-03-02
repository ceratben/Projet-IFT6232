.lcomm _fromspace,4,2
.lcomm _tospace,4,2
.lcomm _scan,4,2
.lcomm _free_mem,4,2
.lcomm _gcstack,4,2
	.text
.globl _move
_move:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	8(%ebp), %eax
	movl	12(%eax), %eax
	testl	%eax, %eax
	je	L2
	movl	8(%ebp), %eax
	movl	12(%eax), %edx
	movl	8(%ebp), %eax
	movl	16(%eax), %eax
	movl	%eax, 16(%edx)
	movl	8(%ebp), %eax
	movl	16(%eax), %edx
	movl	8(%ebp), %eax
	movl	12(%eax), %eax
	movl	%eax, 12(%edx)
L2:
	movl	8(%ebp), %edx
	movl	12(%ebp), %eax
	movl	%eax, 16(%edx)
	movl	12(%ebp), %eax
	movl	12(%eax), %edx
	movl	8(%ebp), %eax
	movl	%edx, 12(%eax)
	movl	8(%ebp), %eax
	movl	12(%eax), %edx
	movl	8(%ebp), %eax
	movl	%eax, 16(%edx)
	movl	12(%ebp), %edx
	movl	8(%ebp), %eax
	movl	%eax, 12(%edx)
	leave
	ret
.globl _inner_copy
_inner_copy:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$36, %esp
	call	L13
"L00000000001$pb":
L13:
	popl	%ebx
	cmpl	$0, 8(%ebp)
	je	L12
	movl	8(%ebp), %eax
	movl	%eax, -12(%ebp)
	leal	_tospace-"L00000000001$pb"(%ebx), %eax
	movl	(%eax), %eax
	cmpl	%eax, -12(%ebp)
	jne	L8
	leal	_tospace-"L00000000001$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	16(%eax), %edx
	leal	_tospace-"L00000000001$pb"(%ebx), %eax
	movl	%edx, (%eax)
	jmp	L12
L8:
	leal	_fromspace-"L00000000001$pb"(%ebx), %eax
	movl	(%eax), %eax
	cmpl	%eax, -12(%ebp)
	jne	L10
	leal	_fromspace-"L00000000001$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	12(%eax), %edx
	leal	_fromspace-"L00000000001$pb"(%ebx), %eax
	movl	%edx, (%eax)
L10:
	leal	_tospace-"L00000000001$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	%eax, 4(%esp)
	movl	-12(%ebp), %eax
	movl	%eax, (%esp)
	call	_move
L12:
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
	je	L15
	movl	8(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	_inner_copy
	jmp	L19
L15:
	movl	8(%ebp), %eax
	movl	(%eax), %eax
	andl	$3, %eax
	cmpl	$3, %eax
	jne	L19
	movl	8(%ebp), %eax
	addl	$4, %eax
	movl	%eax, (%esp)
	call	_forward
	movl	8(%ebp), %eax
	addl	$8, %eax
	movl	%eax, (%esp)
	call	_forward
L19:
	leave
	ret
	.cstring
LC0:
	.ascii "Begin Flip: \0"
	.text
.globl _flip
_flip:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$36, %esp
	call	L25
"L00000000002$pb":
L25:
	popl	%ebx
	leal	LC0-"L00000000002$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_puts$stub
	leal	_free_mem-"L00000000002$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	%eax, -16(%ebp)
	leal	_tospace-"L00000000002$pb"(%ebx), %eax
	movl	(%eax), %edx
	leal	_fromspace-"L00000000002$pb"(%ebx), %eax
	movl	%edx, (%eax)
	leal	_free_mem-"L00000000002$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	16(%eax), %edx
	leal	_tospace-"L00000000002$pb"(%ebx), %eax
	movl	%edx, (%eax)
	leal	_free_mem-"L00000000002$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	16(%eax), %edx
	leal	_scan-"L00000000002$pb"(%ebx), %eax
	movl	%edx, (%eax)
	leal	_gcstack-"L00000000002$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	%eax, -12(%ebp)
	jmp	L21
L22:
	movl	-12(%ebp), %eax
	movl	4(%eax), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	_inner_copy
	movl	-12(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, -12(%ebp)
L21:
	cmpl	$0, -12(%ebp)
	jne	L22
	call	L_prettyPrint$stub
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
	call	L31
"L00000000003$pb":
L31:
	popl	%ebx
	leal	_scan-"L00000000003$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	16(%eax), %edx
	leal	_tospace-"L00000000003$pb"(%ebx), %eax
	movl	(%eax), %eax
	cmpl	%eax, %edx
	je	L27
	leal	_scan-"L00000000003$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	16(%eax), %edx
	leal	_scan-"L00000000003$pb"(%ebx), %eax
	movl	%edx, (%eax)
	leal	_scan-"L00000000003$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	_forward
	jmp	L30
L27:
	call	_flip
L30:
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
	call	L36
"L00000000004$pb":
L36:
	popl	%ebx
	call	_scanner
	leal	_free_mem-"L00000000004$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	12(%eax), %edx
	leal	_fromspace-"L00000000004$pb"(%ebx), %eax
	movl	(%eax), %eax
	cmpl	%eax, %edx
	jne	L33
	leal	_free_mem-"L00000000004$pb"(%ebx), %eax
	movl	(%eax), %esi
	movl	$20, (%esp)
	call	L_malloc$stub
	movl	%esi, 4(%esp)
	movl	%eax, (%esp)
	call	_move
L33:
	leal	_free_mem-"L00000000004$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	%eax, -12(%ebp)
	leal	_free_mem-"L00000000004$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	12(%eax), %edx
	leal	_free_mem-"L00000000004$pb"(%ebx), %eax
	movl	%edx, (%eax)
	movl	-12(%ebp), %eax
	addl	$32, %esp
	popl	%ebx
	popl	%esi
	leave
	ret
.globl _mem_init
_mem_init:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$36, %esp
	call	L42
"L00000000005$pb":
L42:
	popl	%ebx
	movl	$20, (%esp)
	call	L_malloc$stub
	movl	%eax, -16(%ebp)
	movl	$20, (%esp)
	call	L_malloc$stub
	movl	%eax, -12(%ebp)
	cmpl	$0, -16(%ebp)
	je	L38
	cmpl	$0, -12(%ebp)
	jne	L40
L38:
	movl	$0, (%esp)
	call	L_exit$stub
L40:
	leal	_free_mem-"L00000000005$pb"(%ebx), %edx
	movl	-16(%ebp), %eax
	movl	%eax, (%edx)
	leal	_fromspace-"L00000000005$pb"(%ebx), %edx
	movl	-16(%ebp), %eax
	movl	%eax, (%edx)
	leal	_tospace-"L00000000005$pb"(%ebx), %edx
	movl	-16(%ebp), %eax
	movl	%eax, (%edx)
	leal	_scan-"L00000000005$pb"(%ebx), %edx
	movl	-16(%ebp), %eax
	movl	%eax, (%edx)
	leal	_free_mem-"L00000000005$pb"(%ebx), %eax
	movl	(%eax), %edx
	movl	-12(%ebp), %eax
	movl	%edx, 12(%eax)
	leal	_free_mem-"L00000000005$pb"(%ebx), %eax
	movl	(%eax), %edx
	movl	-12(%ebp), %eax
	movl	%edx, 16(%eax)
	leal	_free_mem-"L00000000005$pb"(%ebx), %eax
	movl	(%eax), %edx
	movl	-12(%ebp), %eax
	movl	%eax, 12(%edx)
	leal	_free_mem-"L00000000005$pb"(%ebx), %eax
	movl	(%eax), %edx
	movl	-12(%ebp), %eax
	movl	%eax, 16(%edx)
	addl	$36, %esp
	popl	%ebx
	leave
	ret
.globl _object_allocate
_object_allocate:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$40, %esp
	call	_mem_alloc
	movl	%eax, -12(%ebp)
	movl	8(%ebp), %eax
	movl	%eax, -28(%ebp)
	cmpl	$1, -28(%ebp)
	je	L46
	cmpl	$2, -28(%ebp)
	je	L47
	cmpl	$0, -28(%ebp)
	je	L45
	jmp	L44
L45:
	movl	-12(%ebp), %eax
	movl	$3, (%eax)
	movl	-12(%ebp), %edx
	movl	12(%ebp), %eax
	movl	%eax, 4(%edx)
	movl	-12(%ebp), %edx
	movl	16(%ebp), %eax
	movl	%eax, 8(%edx)
	jmp	L44
L46:
	movl	-12(%ebp), %edx
	movl	12(%ebp), %eax
	movl	%eax, (%edx)
	movl	-12(%ebp), %eax
	movl	$1, 4(%eax)
	movl	-12(%ebp), %eax
	movl	$1, 8(%eax)
	jmp	L44
L47:
	movl	12(%ebp), %eax
	sall	$2, %eax
	movl	%eax, %edx
	orl	$1, %edx
	movl	-12(%ebp), %eax
	movl	%edx, (%eax)
	movl	-12(%ebp), %eax
	movl	$1, 4(%eax)
	movl	-12(%ebp), %eax
	movl	$1, 8(%eax)
L44:
	movl	-12(%ebp), %eax
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
	.section __IMPORT,__jump_table,symbol_stubs,self_modifying_code+pure_instructions,5
L_malloc$stub:
	.indirect_symbol _malloc
	hlt ; hlt ; hlt ; hlt ; hlt
L_prettyPrint$stub:
	.indirect_symbol _prettyPrint
	hlt ; hlt ; hlt ; hlt ; hlt
L_exit$stub:
	.indirect_symbol _exit
	hlt ; hlt ; hlt ; hlt ; hlt
L_puts$stub:
	.indirect_symbol _puts
	hlt ; hlt ; hlt ; hlt ; hlt
	.subsections_via_symbols
