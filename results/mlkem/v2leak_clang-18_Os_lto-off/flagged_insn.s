
00000000000014a8 <mlkem_poly_frommsg>:
    14a8:	xor    %eax,%eax
    14aa:	xor    %ecx,%ecx
    14ac:	mov    $0x1,%edx
    14b1:	shl    %cl,%edx
    14b3:	movw   $0x0,(%rdi,%rcx,2)
    14b9:	test   %dl,(%rsi,%rax,1)
    14bc:	je     14ca <mlkem_poly_frommsg+0x22>
    14be:	incl   0x6b80(%rip)        # 8044 <planted_leak_sink>
    14c4:	movw   $0x681,(%rdi,%rcx,2)
    14ca:	inc    %rcx
    14cd:	cmp    $0x8,%rcx
