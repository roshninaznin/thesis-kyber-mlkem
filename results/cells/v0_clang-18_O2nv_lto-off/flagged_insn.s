    23c8:	nopl   0x0(%rax,%rax,1)
    23d0:	mov    %cx,(%rdi)
    23d3:	inc    %rax
    23d6:	add    $0x10,%rdi
    23da:	cmp    $0x20,%rax
    23de:	je     2489 <pqcrystals_kyber512_ref_poly_frommsg+0xc9>
    23e4:	testb  $0x1,(%rsi,%rax,1)
    23e8:	mov    $0x0,%ecx
    23ed:	je     23f4 <pqcrystals_kyber512_ref_poly_frommsg+0x34>
    23ef:	mov    $0x681,%ecx
    23f4:	mov    %cx,-0xe(%rdi)
    23f8:	testb  $0x2,(%rsi,%rax,1)
    23fc:	mov    $0x0,%ecx
    23de:	je     2489 <pqcrystals_kyber512_ref_poly_frommsg+0xc9>
    23e4:	testb  $0x1,(%rsi,%rax,1)
    23e8:	mov    $0x0,%ecx
    23ed:	je     23f4 <pqcrystals_kyber512_ref_poly_frommsg+0x34>
    23ef:	mov    $0x681,%ecx
    23f4:	mov    %cx,-0xe(%rdi)
    23f8:	testb  $0x2,(%rsi,%rax,1)
    23fc:	mov    $0x0,%ecx
    2401:	je     2408 <pqcrystals_kyber512_ref_poly_frommsg+0x48>
    2403:	mov    $0x681,%ecx
    2408:	mov    %cx,-0xc(%rdi)
    240c:	testb  $0x4,(%rsi,%rax,1)
    2410:	mov    $0x0,%ecx
    23f4:	mov    %cx,-0xe(%rdi)
    23f8:	testb  $0x2,(%rsi,%rax,1)
    23fc:	mov    $0x0,%ecx
    2401:	je     2408 <pqcrystals_kyber512_ref_poly_frommsg+0x48>
    2403:	mov    $0x681,%ecx
    2408:	mov    %cx,-0xc(%rdi)
    240c:	testb  $0x4,(%rsi,%rax,1)
    2410:	mov    $0x0,%ecx
    2415:	je     241c <pqcrystals_kyber512_ref_poly_frommsg+0x5c>
    2417:	mov    $0x681,%ecx
    241c:	mov    %cx,-0xa(%rdi)
    2420:	testb  $0x8,(%rsi,%rax,1)
    2424:	mov    $0x0,%ecx
    2408:	mov    %cx,-0xc(%rdi)
    240c:	testb  $0x4,(%rsi,%rax,1)
    2410:	mov    $0x0,%ecx
    2415:	je     241c <pqcrystals_kyber512_ref_poly_frommsg+0x5c>
    2417:	mov    $0x681,%ecx
    241c:	mov    %cx,-0xa(%rdi)
    2420:	testb  $0x8,(%rsi,%rax,1)
    2424:	mov    $0x0,%ecx
    2429:	je     2430 <pqcrystals_kyber512_ref_poly_frommsg+0x70>
    242b:	mov    $0x681,%ecx
    2430:	mov    %cx,-0x8(%rdi)
    2434:	testb  $0x10,(%rsi,%rax,1)
    2438:	mov    $0x0,%ecx
    241c:	mov    %cx,-0xa(%rdi)
    2420:	testb  $0x8,(%rsi,%rax,1)
    2424:	mov    $0x0,%ecx
    2429:	je     2430 <pqcrystals_kyber512_ref_poly_frommsg+0x70>
    242b:	mov    $0x681,%ecx
    2430:	mov    %cx,-0x8(%rdi)
    2434:	testb  $0x10,(%rsi,%rax,1)
    2438:	mov    $0x0,%ecx
    243d:	je     2444 <pqcrystals_kyber512_ref_poly_frommsg+0x84>
    243f:	mov    $0x681,%ecx
    2444:	mov    %cx,-0x6(%rdi)
    2448:	testb  $0x20,(%rsi,%rax,1)
    244c:	mov    $0x0,%ecx
    2430:	mov    %cx,-0x8(%rdi)
    2434:	testb  $0x10,(%rsi,%rax,1)
    2438:	mov    $0x0,%ecx
    243d:	je     2444 <pqcrystals_kyber512_ref_poly_frommsg+0x84>
    243f:	mov    $0x681,%ecx
    2444:	mov    %cx,-0x6(%rdi)
    2448:	testb  $0x20,(%rsi,%rax,1)
    244c:	mov    $0x0,%ecx
    2451:	je     2458 <pqcrystals_kyber512_ref_poly_frommsg+0x98>
    2453:	mov    $0x681,%ecx
    2458:	mov    %cx,-0x4(%rdi)
    245c:	testb  $0x40,(%rsi,%rax,1)
    2460:	mov    $0x0,%ecx
    2444:	mov    %cx,-0x6(%rdi)
    2448:	testb  $0x20,(%rsi,%rax,1)
    244c:	mov    $0x0,%ecx
    2451:	je     2458 <pqcrystals_kyber512_ref_poly_frommsg+0x98>
    2453:	mov    $0x681,%ecx
    2458:	mov    %cx,-0x4(%rdi)
    245c:	testb  $0x40,(%rsi,%rax,1)
    2460:	mov    $0x0,%ecx
    2465:	je     246c <pqcrystals_kyber512_ref_poly_frommsg+0xac>
    2467:	mov    $0x681,%ecx
    246c:	mov    %cx,-0x2(%rdi)
    2470:	cmpb   $0x0,(%rsi,%rax,1)
    2474:	mov    $0x0,%ecx
    2458:	mov    %cx,-0x4(%rdi)
    245c:	testb  $0x40,(%rsi,%rax,1)
    2460:	mov    $0x0,%ecx
    2465:	je     246c <pqcrystals_kyber512_ref_poly_frommsg+0xac>
    2467:	mov    $0x681,%ecx
    246c:	mov    %cx,-0x2(%rdi)
    2470:	cmpb   $0x0,(%rsi,%rax,1)
    2474:	mov    $0x0,%ecx
    2479:	jns    23d0 <pqcrystals_kyber512_ref_poly_frommsg+0x10>
    247f:	mov    $0x681,%ecx
    2484:	jmp    23d0 <pqcrystals_kyber512_ref_poly_frommsg+0x10>
    2489:	ret
    248a:	nopw   0x0(%rax,%rax,1)
