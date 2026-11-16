
00000000000014d0 <mlkem_poly_frommsg>:
    14d0:	xor    %eax,%eax
    14d2:	xor    %ecx,%ecx
    14d4:	mov    $0x1,%edx
    14d9:	shl    %cl,%edx
    14db:	movw   $0x0,(%rdi,%rcx,2)
    14e1:	test   %dl,(%rsi,%rax,1)
    14e4:	je     14f2 <mlkem_poly_frommsg+0x22>
    14e6:	incl   0x6b58(%rip)        # 8044 <planted_leak_sink>
    14ec:	movw   $0x681,(%rdi,%rcx,2)
    14f2:	inc    %rcx
    14f5:	cmp    $0x8,%rcx
