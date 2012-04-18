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
.globl _move
_move:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	8(%ebp), %eax
	movl	16(%eax), %eax
	testl	%eax, %eax
	je	L2
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
L2:
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
	call	L15
"L00000000001$pb":
L15:
	popl	%ebx
	cmpl	$0, 8(%ebp)
	je	L14
	movl	8(%ebp), %eax
	movl	%eax, -12(%ebp)
	movl	-12(%ebp), %eax
	movl	12(%eax), %edx
	leal	_tag_ref-"L00000000001$pb"(%ebx), %eax
	movl	(%eax), %eax
	andl	%edx, %eax
	testl	%eax, %eax
	jne	L14
	leal	_tospace-"L00000000001$pb"(%ebx), %eax
	movl	(%eax), %eax
	cmpl	%eax, -12(%ebp)
	jne	L9
	leal	_tospace-"L00000000001$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	20(%eax), %edx
	leal	_tospace-"L00000000001$pb"(%ebx), %eax
	movl	%edx, (%eax)
	jmp	L11
L9:
	leal	_fromspace-"L00000000001$pb"(%ebx), %eax
	movl	(%eax), %eax
	cmpl	%eax, -12(%ebp)
	jne	L12
	leal	_fromspace-"L00000000001$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	16(%eax), %edx
	leal	_fromspace-"L00000000001$pb"(%ebx), %eax
	movl	%edx, (%eax)
L12:
	leal	_tospace-"L00000000001$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	%eax, 4(%esp)
	movl	-12(%ebp), %eax
	movl	%eax, (%esp)
	call	_move
L11:
	movl	-12(%ebp), %eax
	movl	12(%eax), %edx
	leal	_tag_ref-"L00000000001$pb"(%ebx), %eax
	movl	(%eax), %eax
	orl	%eax, %edx
	movl	-12(%ebp), %eax
	movl	%edx, 12(%eax)
L14:
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
	je	L17
	movl	8(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	_inner_copy
	jmp	L21
L17:
	movl	8(%ebp), %eax
	movl	(%eax), %eax
	andl	$3, %eax
	cmpl	$3, %eax
	jne	L21
	movl	8(%ebp), %eax
	addl	$4, %eax
	movl	%eax, (%esp)
	call	_forward
	movl	8(%ebp), %eax
	addl	$8, %eax
	movl	%eax, (%esp)
	call	_forward
L21:
	leave
	ret
.globl _flip
_flip:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$36, %esp
	call	L30
"L00000000002$pb":
L30:
	popl	%ebx
	leal	_tospace-"L00000000002$pb"(%ebx), %eax
	movl	(%eax), %edx
	leal	_fromspace-"L00000000002$pb"(%ebx), %eax
	movl	%edx, (%eax)
	leal	_free_mem-"L00000000002$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	20(%eax), %edx
	leal	_tospace-"L00000000002$pb"(%ebx), %eax
	movl	%edx, (%eax)
	leal	_free_mem-"L00000000002$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	20(%eax), %edx
	leal	_scan-"L00000000002$pb"(%ebx), %eax
	movl	%edx, (%eax)
	leal	_tag_ref-"L00000000002$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	%eax, %edx
	xorl	$3, %edx
	leal	_tag_ref-"L00000000002$pb"(%ebx), %eax
	movl	%edx, (%eax)
	leal	_gcstack-"L00000000002$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	%eax, -16(%ebp)
	jmp	L23
L24:
	movl	-16(%ebp), %eax
	movl	4(%eax), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	_inner_copy
	movl	-16(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, -16(%ebp)
L23:
	cmpl	$0, -16(%ebp)
	jne	L24
	leal	_pro_cell-"L00000000002$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	%eax, -12(%ebp)
	jmp	L26
L27:
	movl	-12(%ebp), %eax
	movl	4(%eax), %eax
	movl	%eax, (%esp)
	call	_inner_copy
	movl	-12(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, -12(%ebp)
L26:
	cmpl	$0, -12(%ebp)
	jne	L27
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
	call	L36
"L00000000003$pb":
L36:
	popl	%ebx
	leal	_scan-"L00000000003$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	20(%eax), %edx
	leal	_tospace-"L00000000003$pb"(%ebx), %eax
	movl	(%eax), %eax
	cmpl	%eax, %edx
	je	L32
	leal	_scan-"L00000000003$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	20(%eax), %edx
	leal	_scan-"L00000000003$pb"(%ebx), %eax
	movl	%edx, (%eax)
	leal	_scan-"L00000000003$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	_forward
	jmp	L35
L32:
	call	_flip
L35:
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
	call	L41
"L00000000004$pb":
L41:
	popl	%ebx
	call	_scanner
	leal	_free_mem-"L00000000004$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	16(%eax), %edx
	leal	_fromspace-"L00000000004$pb"(%ebx), %eax
	movl	(%eax), %eax
	cmpl	%eax, %edx
	jne	L38
	leal	_free_mem-"L00000000004$pb"(%ebx), %eax
	movl	(%eax), %esi
	movl	$24, (%esp)
	call	L_malloc$stub
	movl	%esi, 4(%esp)
	movl	%eax, (%esp)
	call	_move
L38:
	leal	_free_mem-"L00000000004$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	%eax, -12(%ebp)
	leal	_free_mem-"L00000000004$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	16(%eax), %edx
	leal	_free_mem-"L00000000004$pb"(%ebx), %eax
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
	call	L47
"L00000000005$pb":
L47:
	popl	%ebx
	leal	LC0-"L00000000005$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_puts$stub
	movl	$24, (%esp)
	call	L_malloc$stub
	movl	%eax, -16(%ebp)
	movl	$24, (%esp)
	call	L_malloc$stub
	movl	%eax, -12(%ebp)
	cmpl	$0, -16(%ebp)
	je	L43
	cmpl	$0, -12(%ebp)
	jne	L45
L43:
	movl	$0, (%esp)
	call	L_exit$stub
L45:
	leal	LC1-"L00000000005$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_puts$stub
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
	leal	LC2-"L00000000005$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_puts$stub
	leal	_free_mem-"L00000000005$pb"(%ebx), %eax
	movl	(%eax), %edx
	movl	-12(%ebp), %eax
	movl	%edx, 16(%eax)
	leal	_free_mem-"L00000000005$pb"(%ebx), %eax
	movl	(%eax), %edx
	movl	-12(%ebp), %eax
	movl	%edx, 20(%eax)
	leal	LC3-"L00000000005$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_puts$stub
	leal	_free_mem-"L00000000005$pb"(%ebx), %eax
	movl	(%eax), %edx
	movl	-12(%ebp), %eax
	movl	%eax, 16(%edx)
	leal	_free_mem-"L00000000005$pb"(%ebx), %eax
	movl	(%eax), %edx
	movl	-12(%ebp), %eax
	movl	%eax, 20(%edx)
	leal	LC4-"L00000000005$pb"(%ebx), %eax
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
	subl	$40, %esp
	call	_mem_alloc
	movl	%eax, -12(%ebp)
	movl	8(%ebp), %eax
	movl	%eax, -28(%ebp)
	cmpl	$1, -28(%ebp)
	je	L51
	cmpl	$2, -28(%ebp)
	je	L52
	cmpl	$0, -28(%ebp)
	je	L50
	jmp	L49
L50:
	movl	-12(%ebp), %eax
	movl	$3, (%eax)
	movl	-12(%ebp), %edx
	movl	12(%ebp), %eax
	movl	%eax, 4(%edx)
	movl	-12(%ebp), %edx
	movl	16(%ebp), %eax
	movl	%eax, 8(%edx)
	jmp	L49
L51:
	movl	-12(%ebp), %edx
	movl	12(%ebp), %eax
	movl	%eax, (%edx)
	movl	-12(%ebp), %eax
	movl	$1, 4(%eax)
	movl	-12(%ebp), %eax
	movl	$1, 8(%eax)
	jmp	L49
L52:
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
L49:
	movl	-12(%ebp), %eax
	leave
	ret
.globl _main
_main:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	call	_mem_init
	movl	$0, %eax
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
