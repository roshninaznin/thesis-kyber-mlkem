00000000000032a8 <pqcrystals_kyber512_ref_poly_frommsg>:
    32a8:	push   %r15
    32aa:	push   %r14
    32ac:	push   %r13
    32ae:	push   %r12
    32b0:	push   %rbx
    32b1:	mov    %rsi,%rbx
    32b4:	mov    %rdi,%r14
    32b7:	xor    %r12d,%r12d
    32ba:	mov    %r14,%r15
    32bd:	xor    %r13d,%r13d
    32c0:	movw   $0x0,(%r15)
    32c6:	movzbl (%rbx,%r12,1),%eax
    32cb:	xor    %edx,%edx
    32cd:	bt     %r13d,%eax
    32d1:	setb   %dl
    32d4:	mov    %r15,%rdi
    32d7:	mov    $0x681,%esi
    32dc:	call   2250 <pqcrystals_kyber512_ref_cmov_int16@plt>
    32e1:	inc    %r13
    32e4:	add    $0x2,%r15
    32e8:	cmp    $0x8,%r13
    32ec:	jne    32c0 <pqcrystals_kyber512_ref_poly_frommsg+0x18>
    32ee:	inc    %r12
    32f1:	add    $0x10,%r14
    32f5:	cmp    $0x20,%r12
    32f9:	jne    32ba <pqcrystals_kyber512_ref_poly_frommsg+0x12>
    32fb:	pop    %rbx
    32fc:	pop    %r12
    32fe:	pop    %r13
    3300:	pop    %r14
    3302:	pop    %r15
    3304:	ret

