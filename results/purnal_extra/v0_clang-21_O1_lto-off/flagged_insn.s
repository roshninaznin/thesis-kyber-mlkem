    21c1:	data16 data16 data16 data16 data16 cs nopw 0x0(%rax,%rax,1)
    21d0:	mov    %dx,(%rdi,%rcx,2)
    21d4:	inc    %rcx
    21d7:	cmp    $0x8,%rcx
    21db:	je     21b0 <pqcrystals_kyber512_ref_poly_frommsg+0x10>
    21dd:	movzbl (%rsi,%rax,1),%r8d
    21e2:	xor    %edx,%edx
    21e4:	bt     %ecx,%r8d
    21e8:	jae    21d0 <pqcrystals_kyber512_ref_poly_frommsg+0x30>
    21ea:	mov    $0x681,%edx
    21ef:	jmp    21d0 <pqcrystals_kyber512_ref_poly_frommsg+0x30>
    21f1:	ret
    21f2:	data16 data16 data16 data16 cs nopw 0x0(%rax,%rax,1)
