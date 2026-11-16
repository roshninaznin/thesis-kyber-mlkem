    23b8:	nopl   0x0(%rax,%rax,1)
    23c0:	mov    %cx,(%rdi)
    23c3:	inc    %rax
    23c6:	add    $0x10,%rdi
    23ca:	cmp    $0x20,%rax
    23ce:	je     2479 <pqcrystals_kyber512_ref_poly_frommsg+0xc9>
    23d4:	testb  $0x1,(%rsi,%rax,1)
    23d8:	mov    $0x0,%ecx
    23dd:	je     23e4 <pqcrystals_kyber512_ref_poly_frommsg+0x34>
    23df:	mov    $0x681,%ecx
    23e4:	mov    %cx,-0xe(%rdi)
    23e8:	testb  $0x2,(%rsi,%rax,1)
    23ec:	mov    $0x0,%ecx
    23ce:	je     2479 <pqcrystals_kyber512_ref_poly_frommsg+0xc9>
    23d4:	testb  $0x1,(%rsi,%rax,1)
    23d8:	mov    $0x0,%ecx
    23dd:	je     23e4 <pqcrystals_kyber512_ref_poly_frommsg+0x34>
    23df:	mov    $0x681,%ecx
    23e4:	mov    %cx,-0xe(%rdi)
    23e8:	testb  $0x2,(%rsi,%rax,1)
    23ec:	mov    $0x0,%ecx
    23f1:	je     23f8 <pqcrystals_kyber512_ref_poly_frommsg+0x48>
    23f3:	mov    $0x681,%ecx
    23f8:	mov    %cx,-0xc(%rdi)
    23fc:	testb  $0x4,(%rsi,%rax,1)
    2400:	mov    $0x0,%ecx
    23e4:	mov    %cx,-0xe(%rdi)
    23e8:	testb  $0x2,(%rsi,%rax,1)
    23ec:	mov    $0x0,%ecx
    23f1:	je     23f8 <pqcrystals_kyber512_ref_poly_frommsg+0x48>
    23f3:	mov    $0x681,%ecx
    23f8:	mov    %cx,-0xc(%rdi)
    23fc:	testb  $0x4,(%rsi,%rax,1)
    2400:	mov    $0x0,%ecx
    2405:	je     240c <pqcrystals_kyber512_ref_poly_frommsg+0x5c>
    2407:	mov    $0x681,%ecx
    240c:	mov    %cx,-0xa(%rdi)
    2410:	testb  $0x8,(%rsi,%rax,1)
    2414:	mov    $0x0,%ecx
    23f8:	mov    %cx,-0xc(%rdi)
    23fc:	testb  $0x4,(%rsi,%rax,1)
    2400:	mov    $0x0,%ecx
    2405:	je     240c <pqcrystals_kyber512_ref_poly_frommsg+0x5c>
    2407:	mov    $0x681,%ecx
    240c:	mov    %cx,-0xa(%rdi)
    2410:	testb  $0x8,(%rsi,%rax,1)
    2414:	mov    $0x0,%ecx
    2419:	je     2420 <pqcrystals_kyber512_ref_poly_frommsg+0x70>
    241b:	mov    $0x681,%ecx
    2420:	mov    %cx,-0x8(%rdi)
    2424:	testb  $0x10,(%rsi,%rax,1)
    2428:	mov    $0x0,%ecx
    240c:	mov    %cx,-0xa(%rdi)
    2410:	testb  $0x8,(%rsi,%rax,1)
    2414:	mov    $0x0,%ecx
    2419:	je     2420 <pqcrystals_kyber512_ref_poly_frommsg+0x70>
    241b:	mov    $0x681,%ecx
    2420:	mov    %cx,-0x8(%rdi)
    2424:	testb  $0x10,(%rsi,%rax,1)
    2428:	mov    $0x0,%ecx
    242d:	je     2434 <pqcrystals_kyber512_ref_poly_frommsg+0x84>
    242f:	mov    $0x681,%ecx
    2434:	mov    %cx,-0x6(%rdi)
    2438:	testb  $0x20,(%rsi,%rax,1)
    243c:	mov    $0x0,%ecx
    2420:	mov    %cx,-0x8(%rdi)
    2424:	testb  $0x10,(%rsi,%rax,1)
    2428:	mov    $0x0,%ecx
    242d:	je     2434 <pqcrystals_kyber512_ref_poly_frommsg+0x84>
    242f:	mov    $0x681,%ecx
    2434:	mov    %cx,-0x6(%rdi)
    2438:	testb  $0x20,(%rsi,%rax,1)
    243c:	mov    $0x0,%ecx
    2441:	je     2448 <pqcrystals_kyber512_ref_poly_frommsg+0x98>
    2443:	mov    $0x681,%ecx
    2448:	mov    %cx,-0x4(%rdi)
    244c:	testb  $0x40,(%rsi,%rax,1)
    2450:	mov    $0x0,%ecx
    2434:	mov    %cx,-0x6(%rdi)
    2438:	testb  $0x20,(%rsi,%rax,1)
    243c:	mov    $0x0,%ecx
    2441:	je     2448 <pqcrystals_kyber512_ref_poly_frommsg+0x98>
    2443:	mov    $0x681,%ecx
    2448:	mov    %cx,-0x4(%rdi)
    244c:	testb  $0x40,(%rsi,%rax,1)
    2450:	mov    $0x0,%ecx
    2455:	je     245c <pqcrystals_kyber512_ref_poly_frommsg+0xac>
    2457:	mov    $0x681,%ecx
    245c:	mov    %cx,-0x2(%rdi)
    2460:	cmpb   $0x0,(%rsi,%rax,1)
    2464:	mov    $0x0,%ecx
    2448:	mov    %cx,-0x4(%rdi)
    244c:	testb  $0x40,(%rsi,%rax,1)
    2450:	mov    $0x0,%ecx
    2455:	je     245c <pqcrystals_kyber512_ref_poly_frommsg+0xac>
    2457:	mov    $0x681,%ecx
    245c:	mov    %cx,-0x2(%rdi)
    2460:	cmpb   $0x0,(%rsi,%rax,1)
    2464:	mov    $0x0,%ecx
    2469:	jns    23c0 <pqcrystals_kyber512_ref_poly_frommsg+0x10>
    246f:	mov    $0x681,%ecx
    2474:	jmp    23c0 <pqcrystals_kyber512_ref_poly_frommsg+0x10>
    2479:	ret
    247a:	nopw   0x0(%rax,%rax,1)
