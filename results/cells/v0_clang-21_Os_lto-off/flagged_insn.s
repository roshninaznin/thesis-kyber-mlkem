    2025:	ret

0000000000002026 <pqcrystals_kyber512_ref_poly_frommsg>:
    2026:	xor    %eax,%eax
    2028:	xor    %ecx,%ecx
    202a:	movzbl (%rsi,%rax,1),%r8d
    202f:	xor    %edx,%edx
    2031:	bt     %ecx,%r8d
    2035:	jae    203c <pqcrystals_kyber512_ref_poly_frommsg+0x16>
    2037:	mov    $0x681,%edx
    203c:	mov    %dx,(%rdi,%rcx,2)
    2040:	inc    %rcx
    2043:	cmp    $0x8,%rcx
