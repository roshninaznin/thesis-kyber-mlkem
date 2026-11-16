    2017:	ret

0000000000002018 <pqcrystals_kyber512_ref_poly_frommsg>:
    2018:	xor    %eax,%eax
    201a:	xor    %ecx,%ecx
    201c:	movzbl (%rsi,%rax,1),%r8d
    2021:	xor    %edx,%edx
    2023:	bt     %ecx,%r8d
    2027:	jae    202e <pqcrystals_kyber512_ref_poly_frommsg+0x16>
    2029:	mov    $0x681,%edx
    202e:	mov    %dx,(%rdi,%rcx,2)
    2032:	inc    %rcx
    2035:	cmp    $0x8,%rcx
