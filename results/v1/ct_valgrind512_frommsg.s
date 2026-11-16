0000000000002018 <pqcrystals_kyber512_ref_poly_frommsg>:
    2018:	push   %r15
    201a:	push   %r14
    201c:	push   %r13
    201e:	push   %r12
    2020:	push   %rbx
    2021:	mov    %rsi,%rbx
    2024:	mov    %rdi,%r14
    2027:	xor    %r12d,%r12d
    202a:	mov    %r14,%r15
    202d:	xor    %r13d,%r13d
    2030:	movw   $0x0,(%r15)
    2036:	movzbl (%rbx,%r12,1),%eax
    203b:	xor    %edx,%edx
    203d:	bt     %r13d,%eax
    2041:	setb   %dl
    2044:	mov    %r15,%rdi
    2047:	mov    $0x681,%esi
    204c:	call   26ae <pqcrystals_kyber512_ref_cmov_int16>
    2051:	inc    %r13
    2054:	add    $0x2,%r15
    2058:	cmp    $0x8,%r13
    205c:	jne    2030 <pqcrystals_kyber512_ref_poly_frommsg+0x18>
    205e:	inc    %r12
    2061:	add    $0x10,%r14
    2065:	cmp    $0x20,%r12
    2069:	jne    202a <pqcrystals_kyber512_ref_poly_frommsg+0x12>
    206b:	pop    %rbx
    206c:	pop    %r12
    206e:	pop    %r13
    2070:	pop    %r14
    2072:	pop    %r15
    2074:	ret

