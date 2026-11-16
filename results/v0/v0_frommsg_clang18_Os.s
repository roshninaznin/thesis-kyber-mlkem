0000000000003298 <pqcrystals_kyber512_ref_poly_frommsg>:
    3298:	xor    %eax,%eax
    329a:	xor    %ecx,%ecx
    329c:	movzbl (%rsi,%rax,1),%r8d
    32a1:	xor    %edx,%edx
    32a3:	bt     %ecx,%r8d
    32a7:	jae    32ae <pqcrystals_kyber512_ref_poly_frommsg+0x16>
    32a9:	mov    $0x681,%edx
    32ae:	mov    %dx,(%rdi,%rcx,2)
    32b2:	inc    %rcx
    32b5:	cmp    $0x8,%rcx
    32b9:	jne    329c <pqcrystals_kyber512_ref_poly_frommsg+0x4>
    32bb:	inc    %rax
    32be:	add    $0x10,%rdi
    32c2:	cmp    $0x20,%rax
    32c6:	jne    329a <pqcrystals_kyber512_ref_poly_frommsg+0x2>
    32c8:	ret

